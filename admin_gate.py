"""The gateway's own lock on its admin tools.

Why this module exists
----------------------
The gateway's debugging and cheat routes -- ``/gazillionaire``, ``/patch/...``,
``/save-editor``, ``/wipe_session``, ``DELETE /save`` -- used to have no
authorization of their own. The only thing standing between an anonymous
visitor and every player's session id was a list of paths in the SvelteKit
front door, in another runtime, in another language.

That is one lock, on one door, for a building with several. Bind the gateway
to ``0.0.0.0`` -- which ``--host 0.0.0.0`` does, and which the WSGI entry
point used to do by accident -- and the gate was gone: ``/list_session``
handed over every player's session id, ``DELETE /save`` deleted any empire,
and ``/patch/...`` granted any resource.

A lock belongs on the data, not only on the door, so the gateway checks it
too. The caller has to present an account whose role says admin; the account
table belongs to the front door, and if it cannot be read the answer is no.
"""

from __future__ import annotations

from flask import request

import contract


def caller_is_admin() -> bool:
    """Whether the caller presented an admin role.

    The role arrives in a header the front door sets from the session it
    verified, and never forwards from the browser: the proxy copies whatever
    the client sent, so a player must not be able to claim a role by sending
    the header itself.

    The gateway trusts it for the same reason it trusts the account id: it
    listens on loopback and the front door is its only door. That is also why
    the role is not looked up in the accounts table here -- the accounts are
    the front door's, their schema is the front door's, and asking this half
    to read it is the coupling that let the two drift apart in the first place.

    Failing closed is deliberate. No header means no claim, and a claim that
    is not "admin" is not an admin.
    """
    claimed = request.headers.get(contract.PLAYER_ROLE_HEADER, "")
    return claimed.strip().lower() == "admin"


def is_admin_tool(path: str) -> bool:
    """Whether a gateway path is one of the admin tools."""
    return contract.is_admin_only_path(path)
