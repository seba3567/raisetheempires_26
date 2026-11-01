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

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response
from pydantic import BaseModel

# The handlers live in the Flask gateway and rely on Flask's request/session
# context. Reuse that app so they keep working unchanged.
_spec = importlib.util.spec_from_file_location("empires_server", "empires-server.py")
_es = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_es)
_flask_app = _es.configure_app()

from empires_gateway.amf import dispatch as _amf_dispatch
from empires_gateway.shared import dummy_response as _dummy_response

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
    title="Raise the Empires — Gateway",
    description="FastAPI gateway wrapping the legacy Flask app (Fase B migration).",
    version="0.08a",
)


@app.get("/api/v1/methods")
def list_methods() -> dict[str, list[str]]:
    return {"methods": sorted(_amf_dispatch.AMF_HANDLERS.keys())}


# ---------------------------------------------------------------------------
# Migrated routes (Fase B): native FastAPI, OpenAPI-documented.
# TODO: migrate remaining routes from catalog.py, editor.py, tools.py.
#   - /player.json, /snapi.json, /avatar.json (need Flask session bridge)
#   - /editor.json, /editor/save, /editor/restore (need session + store)
#   - /api/gift/*, /api/pvp/reward (need session + store)
#   - redirects: /home.html, /ruffle.html, /nodebug.html, /new.html, /friends.html
# ---------------------------------------------------------------------------
import random

from empires_gateway.routes.catalog import (
    api_gift_claim,
    api_gift_send,
    api_pvp_reward,
    avatar_state,
    get_avail_motds,
    player_state,
    snapi_bridge,
)
from empires_gateway.routes.editor import editor_restore, editor_save, editor_state


@app.get("/motd.json")
def motd_state() -> dict:
    motds = get_avail_motds()
    return {"motds": motds, "current": random.choice(motds)}


async def _call_flask_view(view_func, request: Request):
    cookie = request.headers.get("cookie", "")
    body = await request.body()
    content_type = request.headers.get("content-type", "application/x-www-form-urlencoded")
    with _flask_app.test_request_context(
        request.url.path,
        method=request.method,
        data=body,
        headers={"Cookie": cookie, "Content-Type": content_type},
    ):
        resp = view_func()
        if isinstance(resp, tuple):
            resp = resp[0]
        data = resp.get_json() if hasattr(resp, "get_json") else None
        status = resp.status_code if hasattr(resp, "status_code") else 200
        # Handle redirects
        if hasattr(resp, "location") and resp.status_code in (301, 302, 303, 307, 308):
            from fastapi.responses import RedirectResponse

            return RedirectResponse(url=resp.location, status_code=resp.status_code)
        if data is None:
            return Response(content=resp.get_data() if hasattr(resp, "get_data") else b"", status_code=status, media_type=resp.mimetype if hasattr(resp, "mimetype") else None)
        return JSONResponse(data, status_code=status)


@app.get("/player.json")
async def player_state_route(request: Request):
    return await _call_flask_view(player_state, request)


@app.get("/snapi.json")
async def snapi_route(request: Request):
    return await _call_flask_view(snapi_bridge, request)


@app.get("/avatar.json")
async def avatar_route(request: Request):
    return await _call_flask_view(avatar_state, request)


# Editor (stateful, delegated to Flask view inside request context)
@app.get("/editor.json")
async def editor_state_route(request: Request):
    return await _call_flask_view(editor_state, request)


@app.post("/editor/save")
async def editor_save_route(request: Request):
    return await _call_flask_view(editor_save, request)


@app.post("/editor/restore")
async def editor_restore_route(request: Request):
    return await _call_flask_view(editor_restore, request)


# Gifts / PvP rewards
@app.post("/api/gift/claim")
async def gift_claim_route(request: Request):
    return await _call_flask_view(api_gift_claim, request)


@app.post("/api/gift/send")
async def gift_send_route(request: Request):
    return await _call_flask_view(api_gift_send, request)


@app.post("/api/pvp/reward")
async def pvp_reward_route(request: Request):
    return await _call_flask_view(api_pvp_reward, request)


# Migrated redirects (stateless)
from fastapi.responses import RedirectResponse


@app.get("/")
@app.get("/game")
@app.get("/play")
def index():
    return RedirectResponse(url="/juego", status_code=302)


@app.get("/home.html")
@app.get("/ruffle.html")
@app.get("/nodebug.html")
@app.get("/new.html")
def legacy_player_pages():
    return RedirectResponse(url="/juego", status_code=302)


@app.get("/friends.html")
def friends_page():
    return RedirectResponse(url="/admin/sessions", status_code=302)


@app.get("/changelog.txt")
def change_log():
    from fastapi.responses import FileResponse

    return FileResponse("web/static/changelog.txt", media_type="text/plain")


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


# ---------------------------------------------------------------------------
# Fase C: AMF0 binary endpoint migrated to FastAPI.
# ---------------------------------------------------------------------------
import time as _time
from datetime import datetime as _datetime

import pyamf
from pyamf import remoting

from empires_gateway.amf import protocol as _amf_protocol
from empires_gateway.amf.dispatch import _amf_as_list, _amf_detach, _pad_batch_results, _tolerate_call_failure


@app.post("/flashservices/gateway.php")
async def amf_gateway(request: Request):
    data = await request.body()
    with _flask_app.test_request_context(
        "/flashservices/gateway.php", method="POST", data=data, content_type="application/x-amf"
    ):
        try:
            resp_msg = remoting.decode(data)
        except Exception as error:
            return Response("Bad AMF request", status_code=400)

        try:
            batch_body = resp_msg.bodies[0][1].body
            calls = _amf_as_list(batch_body[1])
        except Exception as error:
            return Response("Bad AMF batch", status_code=400)

        resps = []
        called_methods = []
        for reqq in calls:
            if not isinstance(reqq, dict):
                resps.append(_dummy_response())
                continue
            if reqq.get("params") is not None:
                reqq["params"] = _amf_as_list(reqq["params"])
            fn_name = getattr(reqq, "functionName", None) or reqq.get("functionName")
            if fn_name:
                called_methods.append(fn_name)
            handler = _amf_dispatch.AMF_HANDLERS.get(fn_name)
            if handler is not None:
                resp = _tolerate_call_failure(fn_name, handler, reqq.get("params"), reqq, resp_msg)
            else:
                resp = _dummy_response()
            resps.append(resp if resp is not None else _dummy_response())

        resps = _pad_batch_results(resps, len(calls))

        emsg = _amf_detach({
            "serverTime": _datetime.now().timestamp(),
            "errorType": 0,
            "data": resps,
        })
        req = remoting.Response(emsg)
        ev = remoting.Envelope(pyamf.AMF0)
        ev[resp_msg.bodies[0][0]] = req
        ret_body = remoting.encode(ev, strict=True, logger=True).getvalue()
        return Response(content=ret_body, media_type="application/x-amf")


# Mount the legacy Flask app as a fallback so routes not yet migrated keep
# working. Migrated routes defined above take precedence.
from starlette.middleware.wsgi import WSGIMiddleware

app.mount("/", WSGIMiddleware(_flask_app))
