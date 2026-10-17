"""Which player id the gateway files a save under.

``get_zid()`` is the hinge between the account system in ``web/`` and the game
itself. Two behaviours matter and they pull in opposite directions, so both are
pinned here:

* an authenticated request through the front door must use the account's id, so
  that signing in actually sticks in the game instead of the save belonging to
  a cookie;
* anything unauthenticated, malformed or out of range must fall back to the
  original cookie derivation, so anonymous play and direct requests to the
  gateway keep working exactly as before.
"""

from __future__ import annotations

from flask import Flask, session

from crc64_go_iso import zid_from_sid
from game_settings import MAX_SAFE_ZID, get_zid

app = Flask(__name__)
app.secret_key = 'test'

# A real account zid, derived by the TypeScript side for account id 1. Kept as a
# literal rather than recomputed here: the whole point is that this value
# crosses the Bun/Python boundary unchanged.
ACCOUNT_ZID = 2361750976462848

# Every legacy derivation in the test-suite assumes this sid, so it is the
# fallback value these tests assert against.
SID = "0"
SID_ZID = 2341959767162880


def test_falls_back_to_the_cookie_without_a_header():
    with app.test_request_context():
        session.sid = SID
        assert get_zid() == SID_ZID == zid_from_sid(SID)


def test_prefers_the_account_supplied_by_the_front_door():
    with app.test_request_context(headers={'x-player-zid': str(ACCOUNT_ZID)}):
        session.sid = SID
        assert get_zid() == ACCOUNT_ZID


def test_the_account_wins_even_when_a_save_already_exists_for_the_cookie():
    """The case that was broken: a save filed under the old cookie id.

    Loading it has to present the account's id, or the level a player reached
    stays attached to a cookie that can be thrown away at any moment.
    """
    with app.test_request_context(headers={'x-player-zid': str(ACCOUNT_ZID)}):
        session.sid = SID
        assert get_zid() != zid_from_sid(SID)
        assert get_zid() == ACCOUNT_ZID


def test_ignores_a_malformed_header():
    for value in ('', 'not-a-number', '12.5', '0x10', ' '):
        with app.test_request_context(headers={'x-player-zid': value}):
            session.sid = SID
            assert get_zid() == SID_ZID, f"header {value!r} should not be trusted"


def test_ignores_an_out_of_range_header():
    """ActionScript has no integers, so the client cannot hold these exactly.

    A value past 2^53-1 would arrive corrupted in the game, so it is rejected
    rather than passed on.
    """
    for value in ('0', '-1', str(MAX_SAFE_ZID + 1)):
        with app.test_request_context(headers={'x-player-zid': value}):
            session.sid = SID
            assert get_zid() == SID_ZID, f"header {value!r} should not be trusted"


def test_accepts_the_largest_safe_value():
    with app.test_request_context(headers={'x-player-zid': str(MAX_SAFE_ZID)}):
        session.sid = SID
        assert get_zid() == MAX_SAFE_ZID