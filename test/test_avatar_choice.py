"""Picking an avatar, as the 2013 /new.html grid did.

The picker is the one piece of the new empire flow that never migrated: once
the player page became the front door, nothing linked to /new.html any more and
the choice became unreachable. /juego now posts here instead, so this file pins
the behaviour both routes depend on:

* ``/avatar.json`` lists the catalogue the gateway actually ships, so the front
  end never has to hardcode the filenames;
* ``/chooseavatar/<file>`` stores the name on the save, which is what the friend
  lists and the empire editor read back;
* anything outside the catalogue is refused. The route takes a *path* parameter
  and the value used to be stored verbatim, so this is the only thing standing
  between a caller-supplied string and a save that carries it.
"""

from __future__ import annotations

from pathlib import Path

import pytest

import save_engine

empires_server = __import__("empires-server")
get_avail_avatars = empires_server.get_avail_avatars


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
        folder = Path(save_engine.my_games_path()) / "templates" / "img" / "avatars"
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