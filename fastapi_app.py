"""FastAPI mirror of the gateway's JSON API (Fase A of the migration).

This service exposes the same `/api/v1/*` endpoints as the Flask gateway,
but through FastAPI so they get OpenAPI/Swagger for free. The AMF0 gateway
stays in Flask for now; this is a parallel surface, not a replacement.

Run with:
    uvicorn fastapi_app:app --host 127.0.0.1 --port 5006
"""
from __future__ import annotations

import hashlib
import importlib.util
import json
import time
from typing import Any

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel

# The handlers live in the Flask gateway and rely on Flask's request/session
# context. Reuse that app so they keep working unchanged.
_spec = importlib.util.spec_from_file_location("empires_server", "empires-server.py")
_es = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_es)
_flask_app = _es.configure_app()

from empires_gateway.amf import dispatch as _amf_dispatch

IDEMPOTENT = {
    "WorldService.loadWorld",
    "DataServicesService.getFriendsInfo",
    "DataServicesService.getRecentPlayers",
    "DataServicesService.getSuggestedNeighbors",
    "DataServicesService.getRecommendedNeighbors",
    "DataServicesService.getRequestFriends",
    "UserService.getTargetingData",
    "UserService.getTargetingGroups",
    "UserService.getLeaderboards",
    "UserService.collectLeaderboards",
}


class CallRequest(BaseModel):
    method: str
    params: list[Any] = []


class CallResponse(BaseModel):
    method: str
    result: Any


app = FastAPI(
    title="Raise the Empires — JSON API",
    description="FastAPI mirror of the AMF0 gateway's JSON surface (Fase A).",
    version="0.08a",
)


@app.get("/api/v1/methods")
def list_methods() -> dict[str, list[str]]:
    return {"methods": sorted(_amf_dispatch.AMF_HANDLERS.keys())}


def _dispatch(method: str, params: list[Any]) -> JSONResponse:
    handler = _amf_dispatch.AMF_HANDLERS.get(method)
    if handler is None:
        return JSONResponse({"error": "unknown method", "method": method}, status_code=404)

    reqq = {"sequence": 0, "params": params}
    called_at = time.perf_counter()
    try:
        with _flask_app.test_request_context("/", headers={}):
            result = handler(params, reqq, None)
    except Exception as error:  # noqa: BLE001
        return JSONResponse({"error": str(error), "method": method}, status_code=500)

    elapsed_ms = (time.perf_counter() - called_at) * 1000
    content = {"method": method, "result": result}

    response = JSONResponse(content)
    if method in IDEMPOTENT:
        body = json.dumps(content, default=str).encode()
        etag = hashlib.md5(body).hexdigest()
        response.headers["Cache-Control"] = "public, max-age=30, stale-while-revalidate=60"
        response.headers["ETag"] = f'"{etag}"'
        response.headers["Vary"] = "Cookie"
    return response


@app.post("/api/v1/call", response_model=CallResponse)
def call(request: CallRequest) -> JSONResponse:
    params = request.params if isinstance(request.params, list) else [request.params]
    return _dispatch(request.method, params)


@app.post("/api/v1/user/init", response_model=CallResponse)
def user_init() -> JSONResponse:
    return _dispatch("UserService.initUser", [])


@app.post("/api/v1/world/load", response_model=CallResponse)
def world_load(request: CallRequest) -> JSONResponse:
    params = request.params if isinstance(request.params, list) else [request.params]
    return _dispatch("WorldService.loadWorld", params)
