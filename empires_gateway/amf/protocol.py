"""Speaking AMF0 to a client that cannot be recompiled.

The Flash client talks to the gateway over AMF remoting, and the payloads it
sends and expects are a compatibility contract with a binary from 2012. This
module is that contract, and nothing else: it coerces the shapes the client
uses, keeps one failing call from taking the batch with it, and shapes the
answers so the client can match them to its requests.

It is pure on purpose -- no Flask, no session, no database -- so the rules
about the wire can be read and changed without the game in the way.
"""
from __future__ import annotations

import json
import logging

import pyamf

from empires_gateway.shared import dummy_response

logger = logging.getLogger(__name__)


def _tolerate_call_failure(fn_name, handler, *args):
    """Run one gateway call, keeping its failure from killing the batch.

    Every gateway crash this week was the same shape: a handler raised something
    the narrow ``except`` around it did not name, it escaped to Flask, and Flask
    answered 500. Ruffle reads a 500 as an unreachable gateway and retries the
    same batch forever, so one bad call cost the player the whole turn.

    Three of them in a row also showed the cost of fixing that one exception at
    a time -- ``IndexError`` caught but ``TypeError`` not, ``pyamf.DecodeError``
    caught but ``OSError`` not. Enumerating the next one is guesswork, so this
    catches everything at the boundary instead and lets the specific handlers
    above it stay narrow, where they can carry a real recovery.

    The exception is swallowed and logged at ERROR with the full traceback.
    That traceback is how each of these was found in the first place, so it has
    to keep reaching log.txt -- this changes who the client hears from, not
    whether we write it down.

    This guards *one* call. It used to wrap the whole dispatch loop, so the
    first handler that raised abandoned every call after it -- the log line
    claimed the rest were answered, and they were not.
    """
    try:
        return handler(*args)
    except Exception:
        logger.exception("Gateway call %s failed", fn_name)
        return None

def _call_args_summary(params):
    """What the client actually sent, short enough to read in a log line.

    Knowing *which* method a batch called is half the diagnosis; knowing what
    it passed is the other half. Truncated hard, because a world payload can be
    thousands of characters and this line exists to be skimmed.
    """
    if params is None:
        return "-"
    try:
        rendered = json.dumps(params, default=lambda o: "<no serializable>")
    except (TypeError, ValueError):
        rendered = repr(params)
    return rendered if len(rendered) <= 160 else rendered[:157] + "..."

def _pad_batch_results(resps, call_count):
    """Give every call in a batch an answer, even ones that raised.

    The client matches responses to requests, so a short list is not a shorter
    turn -- it is a mismatched one. Anything that did not get a real answer
    gets the empty result, which is what an unimplemented service returns anyway.
    """
    while len(resps) < call_count:
        resps.append(dummy_response())
    return resps


def _amf_as_list(value):
    """Return ``value`` as a list, decoding dense integer-keyed AMF objects.

    Flash's own NetConnection encodes arrays as dense AMF arrays, which pyamf
    decodes to Python lists. Other AVM2 implementations -- Ruffle among them --
    encode them as objects with numeric keys instead (either int or str), which
    pyamf decodes to ``{0: ..., 1: ...}`` or ``{"0": ..., "1": ...}``. The game
    logic expects lists, so accept both shapes and normalize child dicts.

    Normalising must not change the *type* of a child object. pyamf decodes an
    AMF object to ``ASObject``, a dict subclass that also answers attribute
    access; rebuilding it as a plain ``dict`` threw that away, and the game
    code reads these payloads both ways -- ``params[1].id`` and
    ``params[1].get('id')``. Rebuilding as ``ASObject`` keeps both spellings
    working, and it also restores the attribute access the call envelope
    relies on (``reqq.sequence``).
    """
    if isinstance(value, dict):
        keys = list(value.keys())
        if keys and all(
            (isinstance(k, int) and not isinstance(k, bool)) or (isinstance(k, str) and k.isdigit())
            for k in keys
        ):
            sorted_keys = sorted(keys, key=lambda k: int(k))
            return [_amf_as_list(value[k]) for k in sorted_keys]
        return pyamf.ASObject({k: _amf_as_list(v) for k, v in value.items()})
    if isinstance(value, list):
        return [_amf_as_list(item) for item in value]
    return value

def _amf_field(obj, name, default=None):
    """Read one field out of an AMF payload, whatever shape it arrived in.

    The gateway hands the handlers ``ASObject`` children, which answer both
    ``obj["id"]`` and ``obj.id``. A caller that builds its own payload -- a
    test, or a handler that reshapes one -- may well have a plain ``dict``
    instead, and reading it by attribute then raises ``AttributeError``. This
    reads the field either way.
    """
    if isinstance(obj, dict):
        return obj.get(name, default)
    return getattr(obj, name, default)

def _amf_detach(value, _path=None):
    """Rebuild ``value`` so that no object appears twice by identity.

    pyamf's AMF0 encoder writes a reference marker (0x07) whenever the same
    Python object is encountered a second time. Flash resolves those, but
    Ruffle's ``deserialize_value_impl`` does not implement ``AmfValue::Reference``
    and logs an error, yielding ``undefined`` in the client -- which surfaces as
    null objects in the game (e.g. ``TInitRequestFriends/onComplete`` throwing
    #1009).

    Several handlers legitimately reuse one dict in more than one place (for
    example the same ally appears in several friend lists), so the response is
    rebuilt with fresh containers. Scalars are returned untouched: repeating
    ``None`` or an int never produces a reference marker.
    """
    if _path is None:
        _path = set()

    if isinstance(value, (dict, list, tuple)):
        if id(value) in _path:
            # Cyclic payload; AMF has no way to express it anyway.
            print("WARNING: cyclic structure in gateway response, truncating")
            return None
        _path = _path | {id(value)}

        if isinstance(value, dict):
            return {k: _amf_detach(v, _path) for k, v in value.items()}
        return [_amf_detach(item, _path) for item in value]

    return value
