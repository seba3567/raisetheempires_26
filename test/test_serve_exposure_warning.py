"""The gateway should say so when it is reachable from outside the machine.

The front door in ``web/`` is meant to be the only public service. The gateway
trusts the ``x-player-zid`` header, and its admin routes only check for a game
session -- both hold only because nothing else can reach it.

Binding it elsewhere breaks the two at once and nothing in the code notices,
so the startup has to say it out loud.
"""

from __future__ import annotations

import pytest

serve_module = pytest.importorskip("serve")


@pytest.mark.parametrize("host", ["0.0.0.0", "192.168.1.5", "::", ""])
def test_binding_anything_but_loopback_warns(host, capsys):
    serve_module._warn_if_exposed(host)
    out = capsys.readouterr().out
    assert "WARNING" in out
    assert host in out or host == ""


@pytest.mark.parametrize("host", ["127.0.0.1", "::1", "localhost"])
def test_loopback_says_nothing(host, capsys):
    serve_module._warn_if_exposed(host)
    assert capsys.readouterr().out == ""


def test_the_warning_names_the_two_things_at_stake(capsys):
    serve_module._warn_if_exposed("0.0.0.0")
    out = capsys.readouterr().out
    assert "x-player-zid" in out
    assert "admin" in out
