"""The log should mean something.

Two rules, both learned from log.txt:

* The suite writes to its own log file. It shares the gateway's logging
  setup, and it deliberately makes handlers raise to prove the gateway
  survives them -- so without a separate file those failures land in the
  server's own log and make it look as though the server were the thing that
  was broken. Of the 1,481 traceback lines log.txt carried, every one of
  them pointed at a test file.

* A gift addressed to something that is not a uid is skipped, not a crash.
  The client sends recipients as a list whose entries are not always bare
  numbers, and converting one of those took the whole batch of gifts down
  with it.
"""

from __future__ import annotations

import os

import pytest
from flask import Flask, session

app = Flask(__name__)
app.secret_key = "test-secret"


def test_the_suite_writes_to_its_own_log_file():
    """The server's log.txt belongs to the server."""
    from save_engine import log_file_name

    assert log_file_name() == "log-test.txt"
    assert log_file_name() != "log.txt"


def test_the_log_file_name_follows_the_environment(monkeypatch):
    from save_engine import log_file_name

    monkeypatch.setenv("RTE_LOG_FILE", "somewhere-else.log")
    assert log_file_name() == "somewhere-else.log"

    monkeypatch.delenv("RTE_LOG_FILE", raising=False)
    assert log_file_name() == "log.txt"


def test_the_log_file_is_not_the_servers_log_file():
    """The environment really is set, and it is not the server's name."""
    assert os.environ.get("RTE_LOG_FILE") == "log-test.txt"


def test_a_gift_addressed_to_an_object_is_skipped():
    """The client sends objects as recipients; the batch survives them."""
    import service_handlers

    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {"player": {"uid": 1}, "world": {"worldName": "Commander"}}
        }
        response = service_handlers.request_gift([[{"test": True}], "energy"])

    assert response["errorType"] == 0


def test_a_gift_addressed_to_a_uid_still_goes_through():
    """The normal path is untouched by the fix."""
    import service_handlers

    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {"player": {"uid": 1}, "world": {"worldName": "Commander"}}
        }
        response = service_handlers.request_gift([[12345], "energy"])
        tracker = session["user_object"]["requestTracker"]["giftRequestSent"]

    assert response["errorType"] == 0
    assert "12345" in tracker


@pytest.mark.parametrize(
    "value,expected",
    [
        (42, 42),
        ("42", 42),
        ({"uid": 42}, 42),
        ({"zid": 42}, 42),
        ({"userId": 42}, 42),
        ({"id": 42}, 42),
        ({"test": True}, None),
        ({"uid": "42"}, 42),
        ("not a number", None),
        (True, None),
        (None, None),
    ],
)
def test_the_recipient_uid_is_read_off_whatever_the_client_sent(value, expected):
    from service_handlers import _gift_recipient_uid

    assert _gift_recipient_uid(value) == expected
