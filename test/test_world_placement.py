"""Placing an object in the world must work for every catalogue item.

``WorldService.performAction`` is the one call the player makes constantly:
every hut, mine, unit and decoration goes through it. Two properties of
``gamesettings`` broke it, and both broke it the same way -- the placement
raised, the gateway logged the batch as failed, and the client was answered
with an empty result instead of the world.

Both are catalogue facts, not client mistakes:

* **774 of the 3990 items have no ``cost`` key at all.** ``Super Ore Mine``
  (``S01``), ``SurveillanceTower`` (``BB10``) and the ``Alien_Spate_*`` units
  are among them. The placement path read ``cost`` and called ``.items()`` on
  the result, so a ``None`` cost ended the batch.

* **36 names appear more than once.** ``BuildingPart124`` is listed twice
  (``B124`` twice), and the lookup unwrapped "exactly one match" -- two
  matches raised ``ValueError: too many values to unpack``.
"""

from __future__ import annotations

import pytest
from pyamf import AMF0, remoting

GATEWAY_PATH = "/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gateway.php"

_sequence = iter(range(1001, 100000))


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


@pytest.fixture
def gateway(client):
    """Send one AMF call and return the decoded body."""

    def call(function_name, params=None):
        body = [
            {"flashRevision": None},
            [
                {
                    "transaction": None,
                    "sequence": next(_sequence),
                    "stamp": 1641513847112.56,
                    "params": params if params is not None else [],
                    "functionName": function_name,
                }
            ],
            0,
        ]

        envelope = remoting.Envelope(AMF0)
        envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]

        raw = remoting.encode(envelope)
        raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)

        response = client.post(GATEWAY_PATH, data=raw, content_type="application/x-amf")
        assert response.status_code == 200, response.get_data()[:500]

        decoded = remoting.decode(response.get_data())
        ((_target, message),) = decoded.bodies
        return message.body

    return call


@pytest.fixture
def player(gateway):
    """A freshly created player, as the Flash client creates it on login."""
    result = gateway("UserService.initUser")
    assert result["errorType"] == 0
    payload = result["data"][0]
    assert payload["errorType"] == 0
    return payload["data"]


def _place(gateway, item_name):
    return gateway(
        "WorldService.performAction",
        [
            "place",
            {"id": "999999", "position": "10,10", "itemName": item_name},
            [{"referenceItem": None, "elapsed": 0}],
        ],
    )


def _world_objects(gateway):
    body = gateway("UserService.initUser")
    save = body["data"][0]["data"]
    return save["userInfo"]["world"]["objects"]


def _batch_failed(caplog):
    """Whether the gateway logged a batch failure during this test."""
    return any("Gateway batch failed" in record.getMessage() for record in caplog.records)


class TestCatalogueLookups:
    """Every catalogue row must be reachable through the lookups.

    The catalogue is not a set: 36 names and 34 codes appear twice, and the
    lookups used to unwrap "exactly one match". The first duplicated row the
    game touched raised ``ValueError: too many values to unpack`` and took the
    gateway batch with it -- in a battle, in a placement, in a building's
    state machine. This sweeps the whole catalogue so the next duplicate is
    found here rather than in the game.
    """

    def test_every_item_is_reachable_by_name_and_by_code(self):
        from game_settings import game_settings, lookup_item_by_code, lookup_item_by_name

        items = game_settings['settings']['items']['item']
        assert items, "the catalogue is empty"

        for item in items:
            # A name may be shared by two rows ("quest3090" is B87 and B93),
            # and a code may be listed twice ("B124" is B124 twice). The
            # lookup answers with the first row either way, so the assertion
            # is that the row it answers with is one of the rows that carry
            # that name -- not that it is this particular row.
            by_name = lookup_item_by_name(item['-name'])
            assert by_name['-name'] == item['-name']
            assert by_name in items

            by_code = lookup_item_by_code(item['-code'])
            assert by_code['-code'] == item['-code']
            assert by_code in items

    def test_every_state_machine_of_an_item_is_reachable(self):
        from game_settings import lookup_raw_state_machine

        items = game_settings_items()
        seen = set()
        for item in items:
            values = item.get('stateMachineValues') or {}
            if isinstance(values, dict) and values.get('-stateMachineName'):
                name = values['-stateMachineName']
                if name in seen:
                    continue
                seen.add(name)
                assert lookup_raw_state_machine(name)['-name'] == name

    def test_every_wave_of_every_survival_set_is_reachable(self):
        from game_settings import game_settings, lookup_wave

        for wave_set in game_settings['settings']['survivalModeSets']['set']:
            for wave in wave_set.get('wave') or []:
                found = lookup_wave(wave_set['-name'], wave['-index'])
                assert found['-index'] == wave['-index']


def game_settings_items():
    from game_settings import game_settings

    return game_settings['settings']['items']['item']


class TestPlacement:
    """The placement must survive every item in the catalogue."""

    def test_an_item_without_a_cost_key_still_places(self, gateway, player, caplog):
        # "Super Ore Mine" (S01) has no `cost` entry in gamesettings.
        body = _place(gateway, "Super Ore Mine")

        assert body["errorType"] == 0
        assert body["data"][0]["errorType"] == 0
        # The client learns the id of the object it just placed from here. A
        # batch that failed is answered with an empty result, which still
        # carries errorType 0 -- so the payload is the real assertion.
        assert "id" in body["data"][0]["data"]
        assert not _batch_failed(caplog)

        names = [obj["itemName"] for obj in _world_objects(gateway)]
        assert "Super Ore Mine" in names

    def test_a_unit_without_a_cost_key_still_places(self, gateway, player, caplog):
        # "Alien_Spate_Infantry" (UM93) is a unit: the placement path takes the
        # other branch for units, and it reads the same `cost`.
        body = _place(gateway, "Alien_Spate_Infantry")

        assert body["errorType"] == 0
        assert body["data"][0]["errorType"] == 0
        assert "id" in body["data"][0]["data"]
        assert not _batch_failed(caplog)

        names = [obj["itemName"] for obj in _world_objects(gateway)]
        assert "Alien_Spate_Infantry" in names

    def test_an_ambiguous_name_still_places(self, gateway, player, caplog):
        # "BuildingPart124" (B124) is listed twice under the same name.
        body = _place(gateway, "BuildingPart124")

        assert body["errorType"] == 0
        assert body["data"][0]["errorType"] == 0
        assert "id" in body["data"][0]["data"]
        assert not _batch_failed(caplog)

        names = [obj["itemName"] for obj in _world_objects(gateway)]
        assert "BuildingPart124" in names

    def test_the_placed_object_carries_the_shape_the_client_expects(self, gateway, player):
        _place(gateway, "Small Island Hut")

        # The starting island already carries huts, so pick the one at the
        # position the client asked for.
        placed = [
            obj
            for obj in _world_objects(gateway)
            if obj["itemName"] == "Small Island Hut" and obj["position"] == "10,10"
        ]
        assert placed, "the hut was not added to the world"

        obj = placed[-1]
        assert "id" in obj
        assert "state" in obj
        assert "referenceItem" in obj
