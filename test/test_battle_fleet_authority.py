"""A battle the server has no troops for must not be fought with borrowed ones.

The shape of the bug
--------------------
The client stopped mid-fight with its own determinism check:

    TResolveBattle: unit strength out of sync: {30,30}|{25,18}

three units against two, for a fight that had opened one against three. Those
numbers are the *client's* arrays; it compares them against the ``ps`` the
gateway returned, and the gateway was simulating an army nobody had given it.

Where the troops went: they only ever reach the server through ``addFleet``,
and ``initUser`` used to reset the fleet registry on every login. After that,
``init_battle`` found nothing under the fleet name the client sent and quietly
used the quest's troops instead -- a different army, wearing the same fight.

The rule pinned here: **an empty registry means the player brought nobody, so
the quest supplies troops. A registry without the named fleet means we lost
them, and that is a fault to report, not a gap to paper over.**

These mirror ``battle_test.py``'s setup, because that is a shape `init_battle`
actually runs: a real quest, a real session, no monkeypatched internals.
"""

from __future__ import annotations

import contextlib

import pytest
from battle_test import app
from flask import session

import battle_engine
from empires_gateway.amf.handlers import player as player_handlers

QUEST = [{'name': 'Q6016', 'complete': False, 'expired': False,
          'progress': [0], 'completedTasks': 0}]


def _user_object():
    return {'userInfo': {'world': {'research': {}}}}


def test_a_missing_fleet_is_reported_rather_than_borrowed_from(caplog):
    """The registry has fleets, and this is not one of them.

    That is the state fault. Falling back to the quest's garrison here is what
    produced a fight the client refuses to play, and it did it silently --
    nothing in the log said a different army had been chosen.
    """
    with app.test_request_context():
        session.sid = "0"
        session.setdefault('quests', default=list(QUEST))
        session['user_object'] = _user_object()
        session['fleets'] = {"otra_flota": ["U1,1,0,0,0"]}

        with caplog.at_level("ERROR", logger="save_engine"):
            with pytest.raises(battle_engine.StaleBattleReference):
                battle_engine.init_battle(
                    {'fleet': 'fleet1_la_que_no_existe', 'target': 'Q6016', 'ch': 1, 'map': None})

        errors = [r for r in caplog.records if r.levelno >= 40]
        assert errors, "a lost fleet was not logged"
        assert "fleet1_la_que_no_existe" in errors[-1].getMessage(), \
            "the log must name the fleet that went missing"


def test_a_session_with_no_fleet_at_all_still_gets_the_quest_garrison():
    """The legitimate case, and the reason the fallback exists at all.

    A player who has brought nobody fights with the mission's troops. Refusing
    here would take that away from them -- and it is the shape every other
    init_battle test in the suite runs in, which is why the guard above is
    about a *populated* registry.
    """
    with app.test_request_context():
        session.sid = "0"
        session.setdefault('quests', default=list(QUEST))
        session['user_object'] = _user_object()
        session['fleets'] = {}

        friendlies, friendly_strengths, baddies, baddie_strengths, _ = \
            battle_engine.init_battle(
                {'fleet': 'fleet1_nadie_la_traido', 'target': 'Q6016', 'ch': 1, 'map': None})

        assert friendlies, "an empty registry should fall back to the quest troops"
        assert len(friendly_strengths) == len(friendlies)


def test_the_fleet_the_client_named_is_the_army():
    """The client registers its garrison and then names it in the fight.

    This is the shape of the wave attack: the client sends `addFleet` with the
    troops it is drawing and then `resolveBattle` naming that fleet, and the
    server has it -- the log said so, in the same breath as the refusal:
    "session has ['fleet1_2361750976462848']".

    It refused the fight anyway, because the check asked whether the registry
    was empty rather than whether the *named* fleet was in it. The client got
    an empty answer, had no `ps` to compare its own units against, and stopped
    with "TResolveBattle: unit strength out of sync".
    """
    with app.test_request_context():
        session.sid = "0"
        session.setdefault('quests', default=list(QUEST))
        session['user_object'] = _user_object()
        session['fleets'] = {"fleet1_123": ["U01,,,", "U01,,,", "U01,,,"]}

        friendlies, friendly_strengths, baddies, baddie_strengths, _ = \
            battle_engine.init_battle(
                {'fleet': 'fleet1_123', 'target': 'Q6016', 'ch': 1, 'map': None})

        assert len(friendlies) == 3, \
            "the army must be the one the client registered"
        assert len(friendly_strengths) == len(friendlies)


def test_a_fleet_that_is_not_the_named_one_is_still_refused():
    """The guard is about the named fleet, not about the registry being full.

    A registry with other fleets in it does not make the client's missing one
    appear: that is still the state fault, and still a refusal.
    """
    with app.test_request_context():
        session.sid = "0"
        session.setdefault('quests', default=list(QUEST))
        session['user_object'] = _user_object()
        session['fleets'] = {"otra_flota": ["U1,1,0,0,0"]}

        with pytest.raises(battle_engine.StaleBattleReference):
            battle_engine.init_battle(
                {'fleet': 'fleet1_123', 'target': 'Q6016', 'ch': 1, 'map': None})


class TestLoginKeepsTheFleets:
    """`initUser` must not wipe the fleet registry.

    The troops only ever arrive through `addFleet`. Resetting the registry on
    login is what left the gateway with nothing to fight with, and the next
    thing that happened was it inventing an army.
    """

    def test_init_user_does_not_reset_the_registry(self):
        """The registry the client filled has to be there after a login.

        The call is ``UserService.initUser``, which is ``user_response``: it is
        the one that ends in ``ensure_fleets()``. Calling ``init_user`` alone
        would not touch the registry at all, so the test would pass without
        proving anything.
        """
        with app.test_request_context():
            session.sid = "0"
            session['fleets'] = {"fleet1_123": ["U1,1,0,0,0"]}
            session['battle'] = ["stale"]

            with contextlib.suppress(Exception):
                player_handlers.user_response()

            # The login got as far as clearing the stale battle, which is the
            # line right before the registry is repaired. Without this the
            # assertion below would also hold if the call had died early.
            assert session.get('battle') is None, \
                "initUser did not run to the point of repairing the registry"
            assert session.get('fleets') == {"fleet1_123": ["U1,1,0,0,0"]}, \
                "init_user must not wipe the fleet registry"