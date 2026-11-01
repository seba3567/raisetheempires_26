"""A JSON mirror of the AMF0 dispatch table.

This is the first step of modernising the network layer: the same handlers
the Flash client reaches through AMF0 are now reachable as plain HTTP+JSON,
so tools, dashboards and future clients can talk to the gateway without
speaking AMF0. The handlers are not duplicated -- they are the same callables
from ``empires_gateway.amf.dispatch``.
"""
from __future__ import annotations

import json
import logging
from typing import Any

from flask import Blueprint, Response, request

from empires_gateway.amf import dispatch as _amf_dispatch

bp = Blueprint("json_api", __name__)

logger = logging.getLogger(__name__)


def _json_default(obj: Any) -> Any:
    """Best-effort serialisation for objects the handlers return."""
    if hasattr(obj, "__dict__"):
        return obj.__dict__
    return str(obj)


@bp.route("/api/v1/methods", methods=["GET"])
def list_methods():
    """List every method the gateway can answer."""
    return Response(
        json.dumps({"methods": sorted(_amf_dispatch.AMF_HANDLERS.keys())}),
        mimetype="application/json",
    )


def _dispatch(method: str, params: list[Any]) -> Response:
    """Shared implementation used by the generic and the friendly endpoints."""
    handler = _amf_dispatch.AMF_HANDLERS.get(method)
    if handler is None:
        return Response(
            json.dumps({"error": "unknown method", "method": method}),
            status=404,
            mimetype="application/json",
        )

    reqq = {"sequence": 0, "params": params}
    called_at = None
    try:
        import time

        called_at = time.perf_counter()
        result = handler(params, reqq, None)
    except Exception as error:  # noqa: BLE001 - surface handler errors as JSON
        logger.exception("JSON API call failed: %s", method)
        return Response(
            json.dumps({"error": str(error), "method": method}),
            status=500,
            mimetype="application/json",
        )

    elapsed_ms = (time.perf_counter() - called_at) * 1000 if called_at else 0.0
    logger.info("  JSON %-46s atendido (%.1fms)", (method or "")[:46], elapsed_ms)

    return Response(
        json.dumps({"method": method, "result": result}, default=_json_default),
        mimetype="application/json",
    )


@bp.route("/api/v1/call", methods=["POST"])
def call():
    """Invoke one handler by name, with JSON params, and return its result."""
    data = request.get_json(silent=True) or {}
    method = data.get("method")
    params = data.get("params", [])
    if not isinstance(params, list):
        params = [params]
    return _dispatch(method, params)


# ---------------------------------------------------------------------------
# Friendly aliases for the methods external tools reach for most often.
# They keep the same contract as /call but hide the AMF method name.
# ---------------------------------------------------------------------------
@bp.route("/api/v1/user/init", methods=["POST"])
def user_init():
    return _dispatch("UserService.initUser", [])


@bp.route("/api/v1/world/load", methods=["POST"])
def world_load():
    data = request.get_json(silent=True) or {}
    params = data.get("params", [])
    if not isinstance(params, list):
        params = [params]
    return _dispatch("WorldService.loadWorld", params)
