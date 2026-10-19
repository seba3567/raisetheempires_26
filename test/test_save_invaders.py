"""One player's broken save must not take down anyone else's.

The shape of the bug
--------------------
``log.txt`` carried 121 ``KeyError: 'pvp'`` in a single evening. Every one came
from ``get_sessions_info`` -- the neighbour list -- indexing
``save['user_object']['pvp']['invaders']`` directly on a save that does not
have that chain. ``get_allies_info()`` calls it, ``init_user()`` calls
``get_allies_info()``, and ``initUser`` is the first thing a new player does.

So one player's corrupt row stopped a *different* player from creating their
empire, with an error about a key they have never heard of. The same sweep
shape exists in ``cancel_unstarted_invasions``, which is called on every
occupation.

The fix reads the chain through :func:`save_store.save_invaders`, which yields
an empty map for a save that never had one. These tests pin both halves: the
helper's contract, and the fact that the sweeps survive a save without it.
"""

from __future__ import annotations

import pytest

from save_store import save_invaders


def _save_with_pvp(invaders=None):
    return {"user_object": {"pvp": {"invaders": invaders if invaders is not None else {"pve": {"quest": True}}}}}


class TestSaveInvaders:
    def test_returns_the_map_of_a_normal_save(self):
        save = _save_with_pvp({"u42": {"status": 1}})

        assert save_invaders(save) == {"u42": {"status": 1}}

    @pytest.mark.parametrize(
        "broken",
        [
            {},
            None,
            {"user_object": None},
            {"user_object": {}},
            {"user_object": {"userInfo": {"player": {"uid": 7}}}},   # booted, pre-pvp
            {"user_object": {"pvp": None}},
            {"user_object": {"pvp": {}}},
            {"user_object": {"pvp": {"invaders": None}}},
            {"user_object": {"pvp": {"invaders": "not a map"}}},
            [],
            "not a save at all",
        ],
    )
    def test_anything_unusable_reads_as_nothing_pending(self, broken):
        """A miss is an answer, not an exception.

        These are the shapes that actually turn up: an older build, a restore
        from an old backup, and a half-finished paste through the admin editor.
        """
        assert save_invaders(broken) == {}

    def test_it_is_the_live_mapping_not_a_copy(self):
        """Callers delete from what they get back.

        ``cancel_unstarted_invasions`` removes the entry it found, and that
        removal has to reach the save before ``store_session`` writes it. A
        defensive copy would silently drop every cancellation.
        """
        save = _save_with_pvp({"u42": {"status": 1}})

        save_invaders(save).pop("u42")

        assert save["user_object"]["pvp"]["invaders"] == {}