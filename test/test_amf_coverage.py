"""What the client asks for, and what the gateway actually answers.

The client is a 2012 binary with 198 methods it can call. The gateway
dispatches 197 of them. That number only says the plumbing is there -- it does
not say the method *does* anything: a handler that answers with the empty
result looks exactly like a working one from the outside, and the game
carries on with nothing.

So this file measures the difference, and pins it. The list of methods that
answer with nothing is the backlog of what is not connected yet; when one of
them is implemented, this test fails and the list has to shrink. That is the
point: the backlog cannot quietly grow, and a feature that gets wired up
cannot be forgotten.
"""
from __future__ import annotations

import ast
import inspect
import re
import zlib
from pathlib import Path

import pytest

empires_server = pytest.importorskip("empires-server")

SWF = Path(__file__).resolve().parent.parent / "assets" / "ZGame.109338.swf"

#: The methods the client can call that the gateway answers with the empty
#: result instead of doing anything.
#:
#: Each one is a feature the 2012 client asks for and this server does not
#: have. The two promo ones are the 2013 promotional rewards; the neighbour
#: poll is the little question the neighbours ask you.
KNOWN_EMPTY_ANSWERS = {
    "UserService.checkForPromoReward",
    "UserService.crewNeighborPoll",
}

#: The methods the gateway answers that the client never asks for.
#:
#: The Watch-to-earn family is the mobile monetization feature, which the
#: desktop client does not have. The domination opponent list is a game mode
#: that is only half connected: the client asks for the chat and for the
#: battle, but not for the list of opponents.
KNOWN_UNCALLED = {
    "DominationModeService.getDominationModeOpponentList",
    "WatchToEarnService.VERSION",
    "WatchToEarnService.as",
    "WatchToEarnService.loadObject",
    "WatchToEarnService.startActivity",
}


def client_methods() -> set[str]:
    """The AMF method names the client can call, read out of the SWF.

    The ABC constant pool writes the length of every string in front of it,
    and a name is only a name if the byte in front of it agrees. Without that
    check the neighbouring string is glued on -- ``createClan`` followed by
    ``3assets`` reads as ``createClan3assets`` -- and the extraction starts
    inventing methods the client does not have.
    """
    raw = SWF.read_bytes()
    body = zlib.decompress(raw[8:]) if raw[:3] == b"CWS" else raw[8:]

    names: set[str] = set()
    for match in re.finditer(
        rb"([A-Za-z][A-Za-z0-9_]{2,40}Service\.[A-Za-z][A-Za-z0-9_]{1,40})", body
    ):
        candidate = match.group(1)
        start = match.start()
        for length in range(len(candidate), 5, -1):
            if (start >= 1 and body[start - 1] == length) or (
                start >= 2 and int.from_bytes(body[start - 2 : start], "big") == length
            ):
                names.add(candidate[:length].decode("ascii"))
                break
    return names


def _answers_with_nothing(handler) -> bool:
    """Whether every path out of a handler gives the empty answer.

    A handler with a ``return dummy_response()`` in its ``except`` branch is
    still a real one -- the empty answer is what it falls back to, not what it
    does.
    """
    try:
        source = ast.parse(inspect.getsource(handler))
    except (OSError, TypeError, SyntaxError):
        return False

    node = source.body[0]
    returns = [child for child in ast.walk(node) if isinstance(child, ast.Return)]
    if not returns:
        return True

    for child in returns:
        value = child.value
        if value is None:
            continue
        if isinstance(value, ast.Call):
            name = getattr(value.func, "id", None) or getattr(value.func, "attr", None)
            if name == "dummy_response":
                continue
            if (
                name == "_response"
                and value.args
                and isinstance(value.args[0], (ast.List, ast.Tuple))
                and not value.args[0].elts
            ):
                continue
            return False
        if isinstance(value, (ast.Constant, ast.List, ast.Tuple, ast.Dict)):
            continue
        return False
    return True


class TestThePlumbing:
    def test_every_method_the_client_calls_is_answered(self):
        names = client_methods()
        dispatch = empires_server.AMF_HANDLERS
        missing = sorted(names - set(dispatch) - {"BaseService.dispatchBatch"})
        assert not missing, f"the client calls these and nothing answers them: {missing}"


class TestWhatIsNotConnectedYet:
    """The backlog, as a test.

    A method that answers with the empty result is indistinguishable from a
    working one from the outside, and the game carries on with nothing. These
    are the ones that are in that state today.
    """

    def test_the_empty_answers_are_the_known_ones(self):
        """When one of them is implemented, this fails and the list shrinks."""
        dispatch = empires_server.AMF_HANDLERS
        empty = {
            name
            for name, handler in dispatch.items()
            if _answers_with_nothing(handler)
        }
        assert empty == KNOWN_EMPTY_ANSWERS, (
            "the set of methods that answer with nothing changed: "
            f"new {sorted(empty - KNOWN_EMPTY_ANSWERS)}, "
            f"gone {sorted(KNOWN_EMPTY_ANSWERS - empty)}"
        )

    def test_the_uncalled_handlers_are_the_known_ones(self):
        """Handlers the client never asks for are not dead code by accident.

        They are the mobile monetization feature and the half-connected
        domination mode; the list says so, so nobody has to guess.
        """
        uncalled = set(empires_server.AMF_HANDLERS) - client_methods()
        assert uncalled == KNOWN_UNCALLED, (
            f"new {sorted(uncalled - KNOWN_UNCALLED)}, "
            f"gone {sorted(KNOWN_UNCALLED - uncalled)}"
        )

    def test_the_client_has_more_methods_than_the_gateway_answers(self):
        """The shape of the surface, so a change in it is noticed."""
        names = client_methods()
        dispatch = empires_server.AMF_HANDLERS
        assert len(names) == 198
        assert len(names & set(dispatch)) == 197
