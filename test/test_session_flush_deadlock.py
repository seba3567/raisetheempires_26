"""A lock collision during the end-of-request session flush.

MariaDB picks one side of a deadlock as the victim and rolls it back; the other
carries on. That is not a lost write and not a broken statement, so the flush is
retried once and the response goes out normally. Only if the retry collides too
does the write get abandoned -- and even then the response still goes out,
because by then it has already been built.

Both halves matter. Retrying forever turns a transient collision into a hung
request, and letting the driver's error escape turns a deadlock into a 500 the
player cannot read.

The property `save_store` is read-only, so the double is swapped by patching the
property on the class -- which is also what makes this a test of the retry policy
rather than of how the store is wired up.
"""
from __future__ import annotations

import pytest

from account_saves import SaveStoreSessionInterface
from save_store import TransientStoreError, is_transient_store_error


class DriverError(Exception):
    """Shaped like pymysql's, which is what ``is_transient_store_error`` reads."""


class FlakyStore:
    """A store whose writes collide for the first `failures` attempts."""

    def __init__(self, failures: int, error: Exception | None = None, succeeds: bool = True):
        self.failures = failures
        self.calls = 0
        self.written = None
        self._error = error or DriverError(1213, "Deadlock found when trying to get lock")
        self._succeeds = succeeds

    def store(self, store_id, payload, reason=None, expected_revision=None):
        self.calls += 1
        if self.calls <= self.failures:
            raise self._error
        if self._succeeds:
            self.written = payload
            return 7  # a revision
        return 8


@pytest.fixture
def flush(gateway_app):  # noqa: F811 - the fixture this module needs
    """Swap in a store double and hand back the interface."""
    interface = gateway_app.session_interface

    def use(double):
        type(interface).save_store = property(lambda self: double)
        return double

    original = type(interface).save_store
    yield interface, use
    type(interface).save_store = original


class TestOnlyLockCollisionsAreRetried:
    def test_a_collision_that_clears_writes_and_stops(self, flush):
        _, use = flush
        double = use(FlakyStore(failures=1))

        written = flush[0]._store_with_retry("s", {"level": 1}, None, 0)

        assert written == 7, "the retry is the one that should have landed"
        assert double.written == {"level": 1}
        assert double.calls == 2

    def test_a_collision_that_survives_is_given_up_on(self, flush):
        _, use = flush
        double = use(FlakyStore(failures=99))

        with pytest.raises(TransientStoreError):
            flush[0]._store_with_retry("s", {"level": 1}, None, 0)
        assert double.calls == 2, "exactly one retry, not a loop"

    def test_a_clean_write_is_not_retried(self, flush):
        _, use = flush
        double = use(FlakyStore(failures=0))

        assert flush[0]._store_with_retry("s", {"level": 1}, None, 0) == 7
        assert double.calls == 1

    @pytest.mark.parametrize("errno, text", [
        (1062, "Duplicate entry"),
        (1146, "No such table"),
        (1054, "Unknown column"),
    ])
    def test_a_real_error_propagates_without_retrying(self, flush, errno, text):
        _, use = flush
        double = use(FlakyStore(failures=99, error=DriverError(errno, text)))

        with pytest.raises(DriverError):
            flush[0]._store_with_retry("s", {"level": 1}, None, 0)
        assert double.calls == 1, "retrying cannot fix a wrong statement"

    def test_a_non_database_error_propagates_immediately(self, flush):
        _, use = flush

        class Weird(FlakyStore):
            def store(self, *a, **k):
                self.calls += 1
                raise ValueError("no errno at all")

        double = use(Weird(failures=99))
        with pytest.raises(ValueError):
            flush[0]._store_with_retry("s", {}, None, 0)
        assert double.calls == 1


class TestWhatCountsAsTransient:
    def test_the_two_lock_errors(self):
        assert is_transient_store_error(DriverError(1213, "Deadlock"))
        assert is_transient_store_error(DriverError(1205, "Lock wait timeout"))

    def test_everything_else(self):
        assert not is_transient_store_error(DriverError(1062, "Duplicate entry"))
        assert not is_transient_store_error(ValueError("not a database error"))

    def test_a_message_with_an_errno_is_not_mistaken_for_one(self):
        """The errno is read from args[0], never parsed out of the text."""
        assert not is_transient_store_error(Exception("1213 Deadlock"))


def test_transient_store_error_is_raised_not_the_driver_error(flush):
    """The caller catches this by name, so wrapping has to actually happen."""
    _, use = flush
    use(FlakyStore(failures=99))

    with pytest.raises(TransientStoreError) as caught:
        flush[0]._store_with_retry("s", {}, None, 0)
    assert isinstance(caught.value.__cause__, DriverError), "the original is kept as the cause"


def test_the_interface_owns_the_retry():
    assert hasattr(SaveStoreSessionInterface, "_store_with_retry")