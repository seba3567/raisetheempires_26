"""Picking an avatar, as the 2013 /new.html grid did.

The picker is the one piece of the new empire flow that never migrated: once
the player page became the front door, nothing linked to /new.html any more and
The choice became unreachable. It lives on /juego and on /cuenta now, and
both write the same field, so this file pins the behaviour they share:

* ``/avatar.json`` lists the catalogue the gateway actually ships, so neither
  front end has to hardcode the filenames;
* ``/chooseavatar/<file>`` stores the name on the save, which is what the client
  payload, the friend lists and the empire editor read back;
* anything outside the catalogue is refused. The route takes a *path* parameter
  and the value used to be stored verbatim, so this is the only thing standing
  between a caller-supplied string and a save that carries it.

It stays on the save rather than becoming a column on ``users`` on purpose: the
SWF asks the host page for its picture through ExternalInterface, so a copy in
the account store would be a second picture the game never looks at.
"""

from __future__ import annotations

from pathlib import Path

import pytest

import save_engine
from conftest import asset_status
from empires_gateway.routes import catalog as catalog_routes

get_avail_avatars = catalog_routes.get_avail_avatars


@pytest.fixture(scope="module")
def client(gateway_app):
    """A client on the shared throwaway gateway app. See test/conftest.py."""
    return gateway_app.test_client()


@pytest.fixture
def bare(client):
    """A session with nothing in it, so no test can see another's leftovers."""
    with client.session_transaction() as session:
        session.clear()
    return client


class TestAvatarCatalogue:
    def test_the_endpoint_lists_the_catalogue(self, bare):
        response = bare.get("/avatar.json")

        assert response.status_code == 200
        assert response.get_json()["avatars"] == get_avail_avatars()

    def test_every_listed_avatar_is_one_we_ship(self, bare):
        """The list and the files on disk must not drift apart.

        A name in the catalogue with no file behind it is a broken <img> in the
        picker, and the gateway would happily store it.
        """
        folder = Path(save_engine.my_games_path()) / "web" / "static" / "img" / "avatars"
        on_disk = {p.name for p in folder.glob("*.png")}

        missing = [name for name in bare.get("/avatar.json").get_json()["avatars"]
                   if name not in on_disk]

        assert missing == []

    def test_a_save_with_no_choice_reports_the_default(self, bare):
        state = bare.get("/avatar.json").get_json()

        assert state["current"] is None
        # What the friend lists would show: blank.png, same as get_avatar_pic.
        assert state["picture"] == "img/avatars/blank.png"


class TestChooseAvatar:
    def test_a_catalogue_name_is_stored_on_the_save(self, bare):
        avatar = get_avail_avatars()[0]

        response = bare.get(f"/chooseavatar/{avatar}")

        assert response.status_code == 302
        with bare.session_transaction() as session:
            assert session["profilePic"] == avatar

    def test_the_stored_name_is_read_back_by_the_editor(self, bare):
        """The editor's "picture" is what an admin sees, so it has to agree."""
        avatar = get_avail_avatars()[3]
        bare.get(f"/chooseavatar/{avatar}")

        assert bare.get("/editor.json").get_json()["picture"] == f"img/avatars/{avatar}"

    def test_a_path_outside_the_catalogue_is_refused(self, bare):
        response = bare.get("/chooseavatar/..%2F..%2F..%2Fetc%2Fpasswd")

        assert response.status_code == 400
        with bare.session_transaction() as session:
            # Nothing was written, so the save carries no caller-supplied path.
            assert "profilePic" not in session

    def test_refusing_one_leaves_the_previous_choice_alone(self, bare):
        chosen = get_avail_avatars()[2]
        bare.get(f"/chooseavatar/{chosen}")

        assert bare.get("/chooseavatar/not-an-avatar.png").status_code == 400

        with bare.session_transaction() as session:
            assert session["profilePic"] == chosen


class TestTheGameSeesIt:
    """The whole point of writing to the save rather than to the account row.

    The account page and the player page both write here, and neither of them is
    the game. These pin the places the client actually reads the picture, so a
    change cannot appear to work on the web and quietly stop reaching the game.
    """

    def _pic(self, client) -> str:
        return client.get("/avatar.json").get_json()["picture"]

    def test_the_client_payload_carries_the_choice(self, bare):
        """/snapi.json is what ExternalInterface serves the SWF at setup."""
        avatar = get_avail_avatars()[6]
        bare.get(f"/chooseavatar/{avatar}")

        payload = bare.get("/snapi.json").get_json()

        assert payload["user"]["pic_square"] == f"img/avatars/{avatar}"

    def test_the_client_payload_falls_back_to_blank(self, bare):
        """No choice yet is the blank silhouette, not a missing field.

        The client dereferences pic_square without checking, so this key has to
        always be a usable path.
        """
        assert bare.get("/snapi.json").get_json()["user"]["pic_square"] == \
            "img/avatars/blank.png"

    def test_the_account_page_reads_the_same_thing(self, bare):
        avatar = get_avail_avatars()[9]
        bare.get(f"/chooseavatar/{avatar}")

        assert bare.get("/player.json").get_json()["picture"] == self._pic(bare)

    def test_the_save_carries_it(self, bare):
        """Not a column on the account: it is inside the session, with the empire."""
        bare.get(f"/chooseavatar/{get_avail_avatars()[1]}")

        with bare.session_transaction() as session:
            assert "profilePic" in session

    def test_the_service_worker_can_cache_the_art(self, bare):
        """The images are served under /img/, which the loader's cache list matches."""
        avatar = get_avail_avatars()[0]

        assert asset_status(bare, f"/img/avatars/{avatar}") == 200