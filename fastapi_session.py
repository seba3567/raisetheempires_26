"""FastAPI-native session proxy.

Handlers import ``session`` from here. The persistence is delegated to the
existing save store through a Flask request context (Flask is a library, not a
server), but the interface the handlers see is FastAPI-native.
"""
from __future__ import annotations

import contextvars
from typing import Any

_current_session: contextvars.ContextVar[dict[str, Any] | None] = contextvars.ContextVar(
    "fastapi_session", default=None
)


class _SessionProxy(dict):
    def _get(self) -> dict[str, Any]:
        # Prefer the FastAPI context var when set.
        s = _current_session.get()
        if s is not None:
            return s
        # Fall back to Flask's session when running under the Flask test client.
        try:
            from flask import has_request_context, session as flask_session

            if has_request_context():
                return flask_session._get_current_object()  # type: ignore[attr-defined]
        except Exception:
            pass
        s = {}
        _current_session.set(s)
        return s

    def __getitem__(self, key):
        return self._get()[key]

    def __setitem__(self, key, value):
        self._get()[key] = value

    def __delitem__(self, key):
        del self._get()[key]

    def __contains__(self, key):
        return key in self._get()

    def get(self, key, default=None):
        return self._get().get(key, default)

    def setdefault(self, key, default=None):
        return self._get().setdefault(key, default)

    def items(self):
        return self._get().items()

    def keys(self):
        return self._get().keys()

    def values(self):
        return self._get().values()

    def __iter__(self):
        return iter(self._get())

    def __len__(self):
        return len(self._get())

    def __getattr__(self, name):
        return getattr(self._get(), name)

    @property
    def modified(self):
        s = _current_session.get()
        if s is not None:
            return s.get("_modified", False)
        try:
            from flask import has_request_context, session as flask_session

            if has_request_context():
                return getattr(flask_session, "modified", False)
        except Exception:
            pass
        return False

    @modified.setter
    def modified(self, value):
        s = _current_session.get()
        if s is not None:
            s["_modified"] = value
        else:
            try:
                from flask import has_request_context, session as flask_session

                if has_request_context():
                    flask_session.modified = value
            except Exception:
                pass


session = _SessionProxy()


def set_session(data: dict[str, Any] | None) -> None:
    _current_session.set(data if data is not None else {})


def get_session() -> dict[str, Any]:
    s = _current_session.get()
    if s is None:
        s = {}
        _current_session.set(s)
    return s