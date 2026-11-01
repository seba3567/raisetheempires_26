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

_current_request: contextvars.ContextVar[Any] = contextvars.ContextVar(
    "fastapi_request", default=None
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


class _RequestProxy:
    def _get(self):
        r = _current_request.get()
        if r is not None:
            return r
        try:
            from flask import has_request_context, request as flask_request

            if has_request_context():
                return flask_request._get_current_object()
        except Exception:
            pass
        return None

    def __getattr__(self, name):
        r = self._get()
        if r is None:
            raise RuntimeError("No request context")
        return getattr(r, name)


request = _RequestProxy()


def set_session(data: dict[str, Any] | None) -> None:
    _current_session.set(data if data is not None else {})


def get_session() -> dict[str, Any]:
    s = _current_session.get()
    if s is None:
        s = {}
        _current_session.set(s)
    return s


def set_request(req: Any) -> None:
    _current_request.set(req)


def get_request() -> Any:
    return _current_request.get()


def has_request_context() -> bool:
    if _current_request.get() is not None:
        return True
    try:
        from flask import has_request_context as _flask_has

        return _flask_has()
    except Exception:
        return False