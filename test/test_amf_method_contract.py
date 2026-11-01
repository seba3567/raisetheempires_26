"""The AMF method names are a contract with the client, and the client is a binary.

The Flash client calls the gateway over AMF remoting by name:
``UserService.initUser``, ``ClansService.getClanInfo``, and about two hundred
more. Those names are compiled into the SWF, which cannot be recompiled: this
project revives a 2012 game, it does not rebuild the client.

So the gateway's dispatch table and the client's method names have to agree,
and nothing was checking that they did. The gateway answers a method it does
not know with a silent empty response -- the right behaviour for a client
that pokes at things that are not there, and the wrong behaviour for a
handler that got renamed: the game would carry on with an empty answer and
nothing would say why.

The client's names are read out of the SWF itself, so the test follows the
client instead of a list somebody has to remember to update.

Reading the names out of the SWF
---------------------------------
The strings live in the ABC constant pool, each one prefixed with its
length. That prefix is what makes the reading exact: a name is only a name if
the byte in front of it says how long it is. Without that check the
neighbouring string gets glued on -- ``ClansService.createClan`` followed by
``3assets`` reads as ``createClan3assets`` -- and the extraction starts
inventing methods the client does not have.
"""

from __future__ import annotations

import re
import zlib
from pathlib import Path

import pytest

empires_server = pytest.importorskip("empires-server")

SWF = Path(__file__).resolve().parent.parent / "assets" / "ZGame.109338.swf"

#: The dispatcher of the envelope itself. It is not a game method: the AMF
#: envelope carries the batch to it, and the gateway answers it outside the
#: dispatch table.
ENVELOPE_DISPATCHER = "BaseService.dispatchBatch"

#: A method name, as the client spells it.
METHOD_NAME = re.compile(rb"[A-Za-z][A-Za-z0-9_]{2,40}Service\.[A-Za-z][A-Za-z0-9_]{1,40}")


def _length_prefixed(body: bytes, start: int, length: int) -> bool:
    """Whether the constant at ``start`` is ``length`` bytes long.

    The pool writes the length in front of the string, in one byte while it
    fits and in two once it does not.
    """
    if start >= 1 and body[start - 1] == length:
        return True
    return bool(start >= 2 and int.from_bytes(body[start - 2 : start], "big") == length)


def swf_method_names(path: Path = SWF) -> set[str]:
    """The AMF method names the client can call, read out of the SWF.

    The SWF is zlib-compressed after its header, so it has to be inflated
    before the strings in it can be read.
    """
    raw = path.read_bytes()
    if raw[:3] == b"CWS":
        body = zlib.decompress(raw[8:])
    elif raw[:3] == b"FWS":
        body = raw[8:]
    else:
        raise ValueError(f"not a SWF: {raw[:3]!r}")

    names: set[str] = set()
    for match in METHOD_NAME.finditer(body):
        candidate = match.group(0)
        start = match.start()
        # The longest prefix whose length prefix agrees is the real name.
        for length in range(len(candidate), 5, -1):
            if _length_prefixed(body, start, length):
                names.add(candidate[:length].decode("ascii"))
                break
    return names


@pytest.fixture(scope="module")
def dispatch() -> dict:
    """Everything the gateway answers, core and extended."""
    return empires_server.AMF_HANDLERS


class TestTheClientAndTheGatewayAgree:
    def test_every_method_the_client_can_call_is_answered(self, dispatch):
        """The invariant that keeps the game working.

        A method the client calls and the gateway does not know comes back as
        an empty response, and the game carries on with nothing.
        """
        names = swf_method_names()
        assert names, "no method names found in the SWF: the extraction is wrong"

        unanswered = sorted(names - set(dispatch) - {ENVELOPE_DISPATCHER})
        assert not unanswered, (
            "the client can call these and the gateway does not answer them: "
            + ", ".join(unanswered)
        )

    def test_the_envelope_dispatcher_is_not_a_game_method(self, dispatch):
        """It is answered outside the dispatch table, by the AMF layer."""
        assert ENVELOPE_DISPATCHER not in dispatch

    def test_every_name_answers_something(self, dispatch):
        """A name bound to something that is not callable is a name that fails."""
        for name, handler in dispatch.items():
            assert callable(handler), f"{name} is bound to {handler!r}"

    def test_the_client_calls_a_reasonable_number_of_methods(self, dispatch):
        """A sanity check on the extraction itself.

        If the SWF changed shape -- a different compression, a different
        string table -- the extraction would quietly find nothing, and every
        other test here would pass on an empty set.
        """
        names = swf_method_names()
        assert len(names) > 150, f"only {len(names)} method names found in the SWF"

    def test_the_extraction_is_exact(self):
        """A name is only a name if its length prefix says so.

        Without that check the neighbouring string is glued on and the
        extraction invents methods the client does not have.
        """
        names = swf_method_names()
        for name in names:
            assert not re.search(r"\d", name), f"{name} looks like two strings glued"


class TestTheGatewaySide:
    def test_the_dispatch_is_not_empty(self, dispatch):
        assert len(dispatch) > 100

    def test_the_names_are_the_client_spelling(self, dispatch):
        """``Service.method``, the shape the client uses."""
        for name in dispatch:
            assert re.fullmatch(
                r"[A-Za-z][A-Za-z0-9_]*Service\.[A-Za-z][A-Za-z0-9_]*", name
            ), name
