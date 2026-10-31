"""The loading screen's artwork, as the 2013 player drew it.

``templates/ruffle.html`` painted one of 139 randomly chosen MOTDs behind the
remastered EA frame, over a gold progress bar that the client's setup callbacks
drove. Both halves of that came back with /juego, and this pins what the front
end now depends on:

* ``/motd.json`` hands over the catalogue and one random pick, so the page has
  art to paint on its first render without asking twice;
* the pick is genuinely random, the way the 2013 template's ``random.choice``
  was -- a fixed one would make the loading screen feel like a screenshot;
* both the art and the frame are still reachable through ``/img/``, which is
  where they are served from. They are deliberately *not* copied into the web
  service's static folder: 139 images and 43 MB in git to fetch one per page
  load is a bad trade, and the gateway route already does exactly that.
"""

from __future__ import annotations

from pathlib import Path

import pytest

import save_engine
from conftest import asset_status

empires_server = __import__("empires-server")


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


class TestMotdCatalogue:
    def test_the_endpoint_lists_the_catalogue_and_a_pick(self, bare):
        state = bare.get("/motd.json").get_json()

        assert state["motds"] == empires_server.get_avail_motds()
        assert state["current"] in state["motds"]

    def test_every_listed_art_is_one_we_ship(self, bare):
        """A name with no file behind it is a blank backdrop on every load."""
        folder = Path(save_engine.my_games_path()) / "web" / "static" / "img" / "motds"
        on_disk = {p.name for p in folder.glob("*.png")}

        missing = [name for name in bare.get("/motd.json").get_json()["motds"]
                   if name not in on_disk]

        assert missing == []

    def test_two_loads_can_pick_different_art(self, bare):
        """A random pick, not a fixed one -- the original re-rolled each load."""
        picks = {bare.get("/motd.json").get_json()["current"] for _ in range(40)}

        assert len(picks) > 1


class TestArtIsServed:
    def test_the_frame_is_still_served(self, bare):
        """The remastered EA border the page layers over the art."""
        assert asset_status(bare, "/img/loading_frame_remastered.png") == 200

    def test_a_motd_file_is_served(self, bare):
        name = bare.get("/motd.json").get_json()["current"]

        assert asset_status(bare, f"/img/motds/{name}") == 200

    def test_a_name_outside_the_folder_is_not(self, bare):
        """The route stays a send_from_directory, not a file server."""
        assert asset_status(bare, "/img/motds/../save.db") != 200