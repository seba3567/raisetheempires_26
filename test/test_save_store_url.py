"""The database URL has to be spelled the way SQLAlchemy can use.

Why this file exists
--------------------

``log.txt`` on 2026-10-18 carries the crash that stopped the server from ever
starting::

    ModuleNotFoundError: No module named 'MySQLdb'
      configure_app() -> db.init_app(app) -> create_engine -> MySQLdb

``SAVE_STORE_PATH`` had been set with the ``mariadb://`` scheme. That is the
natural spelling and it is what several fixtures use, but SQLAlchemy resolves
``mariadb`` to ``mysql+mysqldb`` and imports MySQLdb -- which is not installed,
because this project uses PyMySQL. The failure surfaces as a missing module
rather than as anything that mentions a URL, so it cost real time to trace.

``save_store_url()`` now rewrites the shorthand spellings to the driver that is
actually installed. These tests pin that, because the failure mode if it
regresses is a server that does not boot.
"""

from __future__ import annotations

import pytest

from save_engine import _with_installed_driver, save_store_url

#: What SQLAlchemy needs, and what Store ignores.
CANONICAL = "mysql+pymysql://root:2001@127.0.0.1:3306/raisetheempires"


class TestSchemeNormalisation:
    @pytest.mark.parametrize("scheme", ["mariadb", "mysql"])
    def test_the_installed_driver_is_named_explicitly(self, scheme):
        """Both shorthands must land on PyMySQL, the one we install."""
        normalised = _with_installed_driver(f"{scheme}://root:2001@127.0.0.1:3306/rte")

        assert normalised.startswith("mysql+pymysql://")

    def test_the_rest_of_the_url_is_untouched(self):
        """Only the scheme is rewritten.

        Host, port, credentials and database name are the operator's business.
        Rewriting anything past the scheme would quietly point the server at a
        different database, which is the kind of bug that eats a player's empire.
        """
        normalised = _with_installed_driver("mariadb://user:p%40ss@db.example:3307/mygame")

        assert normalised == "mysql+pymysql://user:p%40ss@db.example:3307/mygame"

    def test_an_already_correct_url_is_left_alone(self):
        assert _with_installed_driver(CANONICAL) == CANONICAL

    def test_a_url_it_does_not_recognise_is_passed_through(self):
        """No inventing a connection we were not given.

        Anything that is not one of the two shorthands comes back byte for byte.
        """
        for url in ("postgresql://h/d", "sqlite:///save.db", "127.0.0.1:3306/db", ""):
            assert _with_installed_driver(url) == url

    def test_mariadb_normalises_to_the_same_url_as_the_default(self):
        """The crash case, end to end.

        `mariadb://` with the default's host, port and database must become
        exactly the string the default produces -- same database, no surprise.
        """
        from_default = CANONICAL
        from_shorthand = _with_installed_driver(
            "mariadb://root:2001@127.0.0.1:3306/raisetheempires")

        assert from_shorthand == from_default

    def test_the_configured_url_is_normalised_too(self):
        """The rewrite happens on the env var, not just on hand-written URLs."""
        monkeypatch = pytest.MonkeyPatch()
        monkeypatch.setenv(
            "SAVE_STORE_PATH", "mariadb://root:2001@127.0.0.1:3306/raisetheempires")
        try:
            assert save_store_url() == CANONICAL
        finally:
            monkeypatch.undo()

    def test_sqlalchemy_can_import_the_driver_of_the_result(self):
        """The assertion that actually matters: the driver exists.

        Checking the resolved driver rather than the string, because the string
        can be right in a way SQLAlchemy still cannot use, and that is the exact
        shape of the bug this file is about.
        """
        from sqlalchemy.engine import url as sa_url

        dialect = sa_url.make_url(_with_installed_driver("mariadb://h/d")).get_dialect()

        assert dialect.driver == "pymysql"