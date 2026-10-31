"""The runtime contract is the single place the two runtimes agree.

The gateway (this side) and the SvelteKit front door in ``web/`` are separate
programs in two languages. They meet over HTTP, over one PostgreSQL database
and over the identity of the player, and every value that crosses one of those
seams is written down once, in ``contract/runtime.json``.

The point of these tests is not that the file parses. It is that **each runtime
derives its values from that file**, so a value that drifts cannot reach a
build: the moment one side stops reading the contract, the equality below
fails.

The failure this protects against is not hypothetical. The front door bound
port 3000 while the origin compiled into its build said 8080, the Bun adapter
rewrote every request onto that baked origin, and SvelteKit refused every form
POST as a cross-site submission -- the login included -- while every page
loaded normally.
"""

from __future__ import annotations

import json
from pathlib import Path

import contract
import crc64_go_iso

CONTRACT_FILE = Path(contract.CONTRACT_PATH)


def _raw() -> dict:
    return json.loads(CONTRACT_FILE.read_text(encoding="utf-8"))


class TestTheContractFile:
    def test_it_is_where_the_module_says_it_is(self):
        assert CONTRACT_FILE.is_file()
        assert CONTRACT_FILE.name == "runtime.json"

    def test_it_has_every_section_both_runtimes_need(self):
        raw = _raw()
        for section in ("database", "gateway", "public", "headers", "zid"):
            assert section in raw, f"the contract has no {section} section"

    def test_the_documentation_lives_with_the_values(self):
        """A file with no explanation is a file nobody dares to change.

        The `_readme` keys are not decoration: they are the reason the next
        person knows these two runtimes have to agree, and what happens when
        they do not.
        """
        raw = _raw()
        assert "_readme" in raw
        assert raw["_readme"], "the contract has no explanation"

    def test_it_can_be_pointed_somewhere_else(self):
        """A deployment may ship the file next to the executable.

        The installed Windows player keeps its data files beside the binary,
        so the lookup has to be able to find the contract there and not only
        in the repository checkout.
        """
        assert contract.RTE_CONTRACT_FILE_ENV == "RTE_CONTRACT_FILE"


class TestTheGatewayReadsIt:
    def test_the_database_url_is_built_from_the_file(self):
        raw = _raw()["database"]
        expected = (
            f"postgresql+psycopg2://{raw['user']}:{raw['password']}"
            f"@{raw['host']}:{raw['port']}/{raw['name']}"
        )
        assert expected == contract.DATABASE_URL

    def test_the_database_name_is_the_one_in_the_file(self):
        assert _raw()["database"]["name"] == contract.DATABASE_NAME

    def test_the_gateway_address_is_the_one_in_the_file(self):
        raw = _raw()["gateway"]
        assert f"http://{raw['host']}:{raw['port']}" == contract.GATEWAY_ORIGIN

    def test_the_public_address_is_the_one_in_the_file(self):
        raw = _raw()["public"]
        assert raw["host"] == contract.PUBLIC_HOST
        assert raw["port"] == contract.PUBLIC_PORT

    def test_the_player_id_header_is_the_one_in_the_file(self):
        assert _raw()["headers"]["playerZid"] == contract.PLAYER_ZID_HEADER

    def test_the_zid_parameters_are_the_ones_in_the_file(self):
        raw = _raw()["zid"]
        assert raw["divisor"] == contract.ZID_DIVISOR
        assert raw["maxSafe"] == contract.MAX_SAFE_ZID


class TestTheEnvironmentNames:
    """One name per fact, across the two runtimes.

    The same deployment configures both halves, so a fact that crosses the
    seam has to have one name. It used to have two: the gateway called the
    database ``SAVE_STORE_PATH`` and the front door called it ``RTE_DB_URL``;
    the front door called the origin ``PUBLIC_ORIGIN`` and the gateway called
    it ``WEB_ORIGIN``. An operator who set one of each pair left the two
    halves pointing at different places -- the gateway writing saves to a
    database the front door never read.
    """

    def test_the_canonical_names_come_from_the_contract(self):
        raw = _raw()["env"]
        assert raw["databaseUrl"] == contract.ENV_DATABASE_URL
        assert raw["publicOrigin"] == contract.ENV_PUBLIC_ORIGIN
        assert raw["gatewayOrigin"] == contract.ENV_GATEWAY_ORIGIN

    def test_the_canonical_name_is_the_one_the_web_uses(self):
        """The front door's names win.

        They are the ones in the shipped `.env.example`, so they are the ones
        an operator is most likely to have copied.
        """
        assert contract.ENV_DATABASE_URL == "RTE_DB_URL"
        assert contract.ENV_PUBLIC_ORIGIN == "PUBLIC_ORIGIN"

    def test_the_old_names_still_work(self):
        """An existing deployment keeps working."""
        environment = {"SAVE_STORE_PATH": "postgres://old", "WEB_ORIGIN": "http://old"}
        assert contract.env_value(contract.ENV_DATABASE_URL, environment) == "postgres://old"
        assert contract.env_value(contract.ENV_PUBLIC_ORIGIN, environment) == "http://old"

    def test_the_canonical_name_wins_over_the_alias(self):
        environment = {"RTE_DB_URL": "postgres://new", "SAVE_STORE_PATH": "postgres://old"}
        assert contract.env_value(contract.ENV_DATABASE_URL, environment) == "postgres://new"

    def test_an_unset_variable_is_none(self):
        assert contract.env_value("NOT_SET_ANYWHERE", {}) is None

    def test_the_aliases_are_the_ones_that_existed(self):
        assert contract.ENV_ALIASES["RTE_DB_URL"] == ("SAVE_STORE_PATH",)
        assert contract.ENV_ALIASES["PUBLIC_ORIGIN"] == ("WEB_ORIGIN",)


class TestTheSettingsFile:
    """One deployment configures both halves, so both read the same file.

    The gateway used to read the process environment and nothing else, while
    the front door read ``web/.env``. An operator who edited ``web/.env`` moved
    the front door and left the gateway pointing somewhere else -- the gateway
    writing saves to a database the front door never read.
    """

    def test_the_file_is_parsed_the_way_the_front_door_parses_it(self):
        parsed = contract._parse_dot_env(
            'A=1\nB = two \nC="quoted"\n# a comment\nNOT_A_PAIR\nD=has # hash\n'
        )
        assert parsed["A"] == "1"
        assert parsed["B"] == "two"
        assert parsed["C"] == "quoted"
        assert parsed["D"] == "has # hash"
        assert "NOT_A_PAIR" not in parsed
        assert "a comment" not in parsed

    def test_the_process_environment_wins_over_the_file(self):
        """The front door's order: process environment, then the file."""
        import os

        os.environ["RTE_CONTRACT_TEST_VAR"] = "from the environment"
        try:
            assert contract.env_value("RTE_CONTRACT_TEST_VAR") == "from the environment"
        finally:
            del os.environ["RTE_CONTRACT_TEST_VAR"]

    def test_the_file_is_the_fallback(self, monkeypatch):
        """A setting that is only in the file still counts."""
        monkeypatch.setattr(contract, "_DOT_ENV", {"RTE_CONTRACT_TEST_VAR": "from the file"})
        assert contract.env_value("RTE_CONTRACT_TEST_VAR") == "from the file"

    def test_the_file_is_optional(self):
        """The standalone Windows player has no ``web`` directory at all."""
        # It simply finds nothing, and the contract's own defaults stand.
        assert isinstance(contract._load_dot_env(), dict)


class TestTheChecksumUsesIt:
    def test_the_divisor_is_the_contracted_one(self):
        """The checksum is divided down so the id fits a Flash double.

        Both runtimes derive the player's id this way, so a change on one side
        has to change on the other: a different divisor here and the gateway
        files the player under a different id than the front door claims.
        """
        assert crc64_go_iso._ZID_DIVISOR == contract.ZID_DIVISOR

    def test_the_divisor_keeps_the_id_inside_the_exact_range(self):
        """2**53 - 1 is the largest integer a double holds exactly.

        The divisor exists for that reason, so the whole 64-bit checksum has
        to land below it. If the contracted divisor stopped being a power of
        two of the right size, every player id would be wrong in the last
        digits.
        """
        assert contract.MAX_SAFE_ZID == 2**53 - 1
        assert contract.ZID_DIVISOR & (contract.ZID_DIVISOR - 1) == 0
        assert (2**64) // contract.ZID_DIVISOR <= contract.MAX_SAFE_ZID + 1
