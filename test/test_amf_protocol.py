"""The AMF0 wire rules, pinned.

The client is a 2012 binary that cannot be recompiled, so how it encodes and
expects payloads is a compatibility contract. These rules were the subtlest
part of the gateway and the least protected: they lived in the middle of a
four-thousand-line file, and nothing tested them on their own -- only through
the routes that happened to use them.

They are a module now, with a test each. If one of them has to change, the
test that says why is next to it.

What they are:

- Flash's own NetConnection encodes arrays as dense AMF arrays; Ruffle
  encodes them as objects with numeric keys. The game logic wants lists.
- pyamf decodes an AMF object to ``ASObject``, a dict subclass that also
  answers attribute access. Rebuilding it as a plain dict took that away, and
  the game code reads the payloads both ways.
- pyamf's encoder writes a reference marker whenever the same object appears
  twice. Flash resolves those; Ruffle does not, and the client sees
  ``undefined``.
"""
from __future__ import annotations

import pytest
from pyamf import ASObject

from empires_gateway.amf.protocol import (
    _amf_as_list,
    _amf_detach,
    _amf_field,
    _call_args_summary,
    _pad_batch_results,
    _tolerate_call_failure,
)
from empires_gateway.shared import dummy_response


class TestTheArrays:
    def test_a_dense_array_stays_a_list(self):
        """What Flash's NetConnection sends."""
        assert _amf_as_list([1, 2, 3]) == [1, 2, 3]

    def test_an_object_with_numeric_keys_becomes_a_list(self):
        """What Ruffle sends, with integer keys."""
        assert _amf_as_list({0: "a", 1: "b"}) == ["a", "b"]

    def test_an_object_with_digit_keys_becomes_a_list(self):
        """What Ruffle sends, with string keys."""
        assert _amf_as_list({"0": "a", "1": "b"}) == ["a", "b"]

    def test_the_order_is_the_numeric_one(self):
        """Not the order the keys happen to be in."""
        assert _amf_as_list({2: "c", 0: "a", 1: "b"}) == ["a", "b", "c"]

    def test_a_real_object_stays_an_object(self):
        """A payload with named fields is not an array."""
        result = _amf_as_list({"id": 7, "name": "x"})
        assert not isinstance(result, list)
        assert result["id"] == 7

    def test_a_child_keeps_both_spellings(self):
        """``params[1].id`` and ``params[1].get('id')`` are both used.

        Rebuilding the child as a plain dict took the attribute access away
        and the game code stopped reading its own payloads.
        """
        child = _amf_as_list([{"id": 7}])[0]
        assert child.id == 7
        assert child.get("id") == 7
        assert isinstance(child, ASObject)

    def test_nested_arrays_are_normalised_too(self):
        assert _amf_as_list([{"0": "a", "1": "b"}]) == [["a", "b"]]


class TestTheFields:
    def test_it_reads_a_plain_dict(self):
        assert _amf_field({"id": 7}, "id") == 7

    def test_it_reads_an_as_object(self):
        assert _amf_field(ASObject({"id": 7}), "id") == 7

    def test_a_missing_field_is_the_default(self):
        assert _amf_field({"id": 7}, "nope", "fallback") == "fallback"
        assert _amf_field(ASObject({"id": 7}), "nope", "fallback") == "fallback"


class TestTheReferences:
    """pyamf writes a reference marker when an object appears twice.

    Flash resolves it; Ruffle does not, and the client sees ``undefined`` --
    which is how a save ends up with null objects in it.
    """

    def test_the_same_object_twice_becomes_two(self):
        shared = {"name": "ally"}
        result = _amf_detach({"a": shared, "b": shared})
        assert result["a"] == {"name": "ally"}
        assert result["b"] == {"name": "ally"}
        assert result["a"] is not result["b"]

    def test_the_same_list_twice_becomes_two(self):
        shared = [1, 2]
        result = _amf_detach([shared, shared])
        assert result[0] == [1, 2]
        assert result[0] is not result[1]

    def test_a_value_that_is_not_shared_keeps_its_identity(self):
        """Only the repeats have to go.

        Rebuilding everything would turn every object into a copy, and the
        client would see a response that no longer matches what the handler
        built.
        """
        only = {"name": "ally"}
        result = _amf_detach({"a": only})
        assert result["a"] == only

    def test_a_scalar_is_returned_untouched(self):
        """Repeating ``None`` or an int never writes a reference marker."""
        assert _amf_detach(5) == 5
        assert _amf_detach(None) is None
        assert _amf_detach("x") == "x"

    def test_a_cyclic_payload_is_truncated(self):
        """AMF cannot express one anyway."""
        cyclic = {}
        cyclic["self"] = cyclic
        result = _amf_detach(cyclic)
        assert result["self"] is None


class TestTheBatch:
    def test_a_failing_call_does_not_take_the_batch_with_it(self):
        """One handler raising used to abandon every call after it."""
        calls = []

        def good(name):
            calls.append(name)
            return {"ok": name}

        def bad(name):
            raise RuntimeError("boom")

        assert _tolerate_call_failure("bad", bad, "x") is None
        assert _tolerate_call_failure("good", good, "y") == {"ok": "y"}
        assert calls == ["y"]

    def test_every_call_gets_an_answer(self):
        """The client matches answers to requests.

        A short list is not a shorter turn, it is a mismatched one.
        """
        answers = _pad_batch_results([{"ok": 1}], 3)
        assert len(answers) == 3
        assert answers[0] == {"ok": 1}
        assert answers[1] == dummy_response()
        assert answers[2] == dummy_response()

    def test_a_full_batch_is_left_alone(self):
        answers = _pad_batch_results([{"ok": 1}, {"ok": 2}], 2)
        assert answers == [{"ok": 1}, {"ok": 2}]

    def test_the_summary_is_short_enough_to_read(self):
        """This line exists to be skimmed."""
        summary = _call_args_summary([{"payload": "x" * 500}])
        assert len(summary) <= 160
        assert summary.endswith("...")

    def test_the_summary_of_nothing_is_a_dash(self):
        assert _call_args_summary(None) == "-"
