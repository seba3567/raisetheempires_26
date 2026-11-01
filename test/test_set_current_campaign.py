"""``UserService.setCurrentCampaign`` -- the boot call that was going nowhere.

What it is
----------
The client names the PvE campaign it is playing as its first act after
``initUser``, with the campaign id as the only argument -- ``["camp001"]``,
captured off the wire once the AMF log started recording arguments.

Before this was implemented the call fell through to ``dummy_response()``:
``errorType: 0`` and no data, which the client reads as "fine, nothing to do".
So the server never learned which campaign the player was on. ``init_user``
seeds ``campaign.current`` with the first campaign, which is why the game booted
anyway -- and why the saved empire was found with ``campaign.active`` empty:
nothing on the server ever registered the campaign the client was playing.

These tests pin the two things that matter: the save ends up saying what the
client said, and a name the catalogue does not know cannot get in.
"""

from __future__ import annotations

import pytest
from flask import Flask, session

empires_server = __import__('empires-server')
from empires_gateway.amf.handlers.world import (
    _known_campaigns,
    set_current_campaign_response,
)

app = Flask(__name__)
app.secret_key = 'test'


def _world():
    """A session with the same campaign shape ``init_user`` writes."""
    return {"userInfo": {"world": {"campaign": {"current": "camp001",
                                               "active": {},
                                               "mastery": {}}},
                         "player": {"uid": 1, "level": 1}}}


def _call(param):
    with app.test_request_context():
        session.sid = "0"
        session['user_object'] = _world()
        response = set_current_campaign_response(param)
        return response, session['user_object']["userInfo"]["world"]["campaign"]


class TestSetCurrentCampaign:
    def test_it_records_the_campaign_the_client_named(self):
        _, campaign = _call(["camp001"])

        assert campaign["current"] == "camp001"

    def test_it_switches_campaign_when_the_client_asks_for_another(self):
        """The point of the call: an editor paste can leave `current` anywhere."""
        _, campaign = _call(["camp002"])

        assert campaign["current"] == "camp002"

    def test_it_registers_the_opening_chapter(self):
        """Without this, `campaign.active` stays empty in the save.

        That empty map is what the campaign code reads to work out how far the
        player has got, so an account that booted through this call should come
        out of it with a real entry rather than nothing.
        """
        _, campaign = _call(["camp001"])

        start = _known_campaigns()["camp001"]["-startChapter"]
        assert campaign["active"][start] == {"status": 0, "fleets": []}

    def test_an_existing_chapter_is_not_wiped(self):
        """Re-announcing a campaign must not reset progress on it.

        The entry holds the packed status word -- island id in the top bits,
        wave damage in the low ones -- so re-creating it would send a player
        back to the start of the chapter they had already cleared.
        """
        with app.test_request_context():
            session.sid = "0"
            world = _world()
            start = _known_campaigns()["camp001"]["-startChapter"]
            world["userInfo"]["world"]["campaign"]["active"][start] = {
                "status": 3 << 20, "fleets": []}
            session['user_object'] = world

            set_current_campaign_response(["camp001"])

            assert session['user_object']["userInfo"]["world"]["campaign"]["active"][start] == {
                "status": 3 << 20, "fleets": []}

    def test_an_unknown_campaign_is_refused_without_touching_the_save(self):
        """A name no map lookup will ever match must not get in.

        This is the one input that is genuinely untrusted: the save can be
        hand-edited through /editor/save, and `campaign.current` is read back by
        the map code.
        """
        with app.test_request_context():
            session.sid = "0"
            session['user_object'] = _world()

            set_current_campaign_response(["camp999"])

            assert session['user_object']["userInfo"]["world"]["campaign"]["current"] == "camp001"

    @pytest.mark.parametrize("param", [None, [], "", {}, ["", ]])
    def test_rubbish_arguments_do_not_raise(self, param):
        """The client is free to put anything in a batch entry."""
        response, campaign = _call(param)

        assert response["errorType"] == 0
        assert campaign["current"] == "camp001"

    def test_the_answer_is_the_shape_the_other_setters_use(self):
        response, _ = _call(["camp001"])

        assert response["errorType"] == 0
        assert response["userId"] == 1
        assert response["metadata"] == {"newPVE": 0}
        assert response["data"] == []

    def test_it_is_registered_on_the_dispatch_table(self):
        """A handler that exists but is not wired answers nothing.

        That is exactly how this call was lost in the first place: it was a
        function nobody called, and the gap was invisible because the fallback
        answers `errorType: 0`.
        """
        assert 'UserService.setCurrentCampaign' in empires_server.AMF_HANDLERS

    def test_the_catalogue_it_validates_against_is_the_gamesettings_one(self):
        """Not a hardcoded list: the client's campaign list is data."""
        catalogue = _known_campaigns()

        assert "camp001" in catalogue
        assert catalogue["camp001"]["-startChapter"]
        assert "camp002" in catalogue