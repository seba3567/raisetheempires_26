"""The database URL has to be spelled the way SQLAlchemy can use.

PostgreSQL 18 is the only database engine. URLs with shorthand schemes like
``postgres://`` or ``postgresql://`` are normalised to ``postgresql+psycopg2://``
so SQLAlchemy connects cleanly without ambiguity.
"""

from __future__ import annotations

import pytest

from save_engine import _with_installed_driver, save_store_url

#: What SQLAlchemy needs, and what Store connects with.
CANONICAL = "postgresql+psycopg2://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/raisetheempires"


class TestSchemeNormalisation:
    @pytest.mark.parametrize("scheme", ["postgres", "postgresql"])
    def test_the_installed_postgres_driver_is_named_explicitly(self, scheme):
        normalised = _with_installed_driver(f"{scheme}://postgres:pass@127.0.0.1:5432/rte")
        assert normalised.startswith("postgresql+psycopg2://")

    def test_the_rest_of_the_url_is_untouched(self):
        """Only the scheme is rewritten.

        Host, port, credentials and database name are the operator's business.
        """
        normalised = _with_installed_driver("postgres://user:p%40ss@db.example:5433/mygame")
        assert normalised == "postgresql+psycopg2://user:p%40ss@db.example:5433/mygame"

    def test_an_already_correct_url_is_left_alone(self):
        assert _with_installed_driver(CANONICAL) == CANONICAL

    def test_a_url_it_does_not_recognise_is_passed_through(self):
        """No inventing a connection we were not given."""
        for url in ("oracle://h/d", "127.0.0.1:5432/db", ""):
            assert _with_installed_driver(url) == url

    def test_postgres_normalises_to_the_same_url_as_the_default(self):
        from_default = CANONICAL
        from_shorthand = _with_installed_driver(
            "postgres://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/raisetheempires")
        assert from_shorthand == from_default

    def test_the_configured_url_is_normalised_too(self):
        monkeypatch = pytest.MonkeyPatch()
        monkeypatch.setenv(
            "SAVE_STORE_PATH", "postgres://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/raisetheempires")
        try:
            assert save_store_url() == CANONICAL
        finally:
            monkeypatch.undo()

    def test_the_canonical_variable_is_the_one_the_web_uses(self):
        """One deployment configures both halves, so the name has to be one.

        The gateway used to call this ``SAVE_STORE_PATH`` and the front door
        called it ``RTE_DB_URL``. An operator who set one of each pair left
        the two halves pointing at different databases.
        """
        monkeypatch = pytest.MonkeyPatch()
        monkeypatch.setenv(
            "RTE_DB_URL", "postgres://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/raisetheempires")
        try:
            assert save_store_url() == CANONICAL
        finally:
            monkeypatch.undo()

    def test_the_canonical_name_wins_over_the_old_one(self):
        monkeypatch = pytest.MonkeyPatch()
        monkeypatch.setenv("RTE_DB_URL", "postgres://canonical/db")
        monkeypatch.setenv("SAVE_STORE_PATH", "postgres://old/db")
        try:
            assert save_store_url() == "postgresql+psycopg2://canonical/db"
        finally:
            monkeypatch.undo()

    def test_sqlalchemy_can_import_the_driver_of_the_result(self):
        from sqlalchemy.engine import url as sa_url

        dialect = sa_url.make_url(_with_installed_driver("postgres://h/d")).get_dialect()
        assert dialect.driver == "psycopg2"
