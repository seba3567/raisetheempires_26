"""The files the client downloads.

The SWF itself, the settings it reads, the artwork, and the few statistics
the game posts back. The asset index is cached because the client asks for
the same files over and over.
"""
from __future__ import annotations

import contextlib
import logging
import os
from pathlib import Path

from flask import Blueprint, make_response, send_from_directory
from werkzeug.utils import safe_join

import mod_engine
from save_engine import install_path

logger = logging.getLogger(__name__)

bp = Blueprint("assets", __name__)


@bp.route("/record_stats.php", methods=['GET', 'POST'])
@bp.route("/127.0.0.1record_stats.php", methods=['GET', 'POST'])
def record_stats():
    return ('', 204)


ASSET_MAX_AGE = 60 * 60 * 24 * 7


@bp.route("/files/empire-s.assets.zgncdn.com/assets/109338/ZGame.109338.swf")
def flashFile():
    # return send_from_directory_mod("assets", "ZGame.109338.swf")
    resp = send_from_directory_mod("assets", "ZGame.109338_tracer2.swf", max_age=0)
    resp.headers["Cache-Control"] = "no-cache, must-revalidate"
    return resp


@bp.route("/gameSettings.xml")
@bp.route("/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gameSettings.xml")
@bp.route("/assets/109338/127.0.0.1flashservices/gameSettings.xml")
def game_settings_file():
    # return send_from_directory_mod("assets/32995", "gameSettings.xml")
    # return send_from_directory_mod("assets/32995", "gameSettings.xml")
    # return send_from_directory_mod("assets/29oct2012", "gameSettings.xml")
    # return send_from_directory_mod("assets/29oct2012", "gameSettings_placeholders.xml")
    return send_from_directory_mod("assets/29oct2012", "gameSettings_with_fixes.xml", max_age=ASSET_MAX_AGE)


@bp.route("/en_US.xml")
@bp.route("/127.0.0.1en_US.xml")
@bp.route("/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/en_US.xml")
@bp.route("/assets/109338/127.0.0.1flashservices/en_US.xml")
def en_us_file():
    # return send_from_directory_mod("assets/32995", "en_US.xml")
    return send_from_directory_mod("assets/29oct2012", "en_US.xml", max_age=ASSET_MAX_AGE)


@bp.route("/zh_CN.xml")
@bp.route("/127.0.0.1zh_CN.xml")
def zh_cn_file():
    """La traduccion china, servida donde el cliente la pide.

    El fichero estaba en `assets/` pero no en el directorio que se sirve, y
    ademas no se podia parsear: 77 ampersands sin escapar. Un parser de XML
    los rechaza, asi que el fichero estaba muerto donde estaba, y ni siquiera
    como eso: un `&` suelto es un error de sintaxis, no un caracter raro.

    Ahora escapa, parsea, y llega al cliente. La cobertura es parcial (el
    chino tiene 13.978 de las 35.488 cadenas del ingles) pero lo que hay esta
    traducido: 92,6% de las compartidas.
    """
    return send_from_directory_mod("assets", "zh_CN.xml", max_age=ASSET_MAX_AGE)


@bp.route("/questSettings.xml")
@bp.route("/127.0.0.1questSettings.xml")
@bp.route("/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/questSettings.xml")
@bp.route("/assets/109338/127.0.0.1flashservices/questSettings.xml")
def quest_settings_file():
    """El catalogo de misiones, en todas las rutas donde el cliente lo pide.

    The SWF asks for some of its files relative to its own directory, under a
    folder named after the host the original game was served from -- "127.0.0.1"
    in 2013. The AMF endpoint in that folder was served and the quest catalogue
    beside it was not, so the client got a 404 for the quests and played
    without them.
    """
    return send_from_directory_mod("assets/29oct2012", "questSettings_with_fixes.xml", max_age=ASSET_MAX_AGE)

@bp.route("/img/<path:path>")
def template_img(path):
    return send_from_directory_mod("web/static/img", path, max_age=ASSET_MAX_AGE)

@bp.route("/js/<path:path>")
def template_js(path):
    return send_from_directory_mod("web/static/js", path)

@bp.route("/css/<path:path>")
def template_css(path):
    return send_from_directory_mod("web/static/css", path)

@bp.route('/nullassets/<path:path>')
def send_sol_assets(path):
    return send_from_directory_mod('assets/sol_assets_octdict/assets', path, max_age=ASSET_MAX_AGE)

@bp.route('/assets/<path:path>')
def send_sol_assets_alternate(path):
    return send_from_directory_mod('assets/sol_assets_octdict/assets', path, max_age=ASSET_MAX_AGE)


KNOWN_ASSET_FALLBACKS = {
    'displays/dialogs/PU_OutOfResources.swf': 'displays/dialogs/PU_GenericPopUp.swf',
    'displays/dialogs/PU_BattleBlitzFailover.swf': 'displays/dialogs/PU_BattleBlitzOptin.swf',
    'displays/dialogs/PU_BattleBlitzConfirm.swf': 'displays/dialogs/PU_BattleBlitzOptin.swf',
    'displays/screens/Leaderboard.swf': 'displays/screens/Leaderboard2.swf',
    'displays/screens/PU_Leaderboard.swf': 'displays/screens/PU_Leaderboard2.swf',
}

EMPTY_SWF_BYTES = b'FWS\x0a\x14\x00\x00\x00\x28\x28\x28\x00\x18\x00\x01\x00\x40\x00\x00\x00'
EMPTY_PNG_BYTES = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15c4\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82'

_ASSET_CACHE_INDEX: dict[str, Path] = {}
_ASSET_CACHE_BASENAMES: dict[str, Path] = {}


def _init_asset_index():
    if _ASSET_CACHE_INDEX:
        return
    base_install = Path(install_path())
    search_dirs = [
        base_install / "assets/sol_assets_octdict/assets",
        base_install / "assets/sol_assets_unknown",
        base_install / "assets/sol_assets_old",
        base_install / "assets/sol_assets_dict1_only/assets",
        base_install / "assets/sol_assets_dict1_only",
    ]
    for sdir in search_dirs:
        if not sdir.exists():
            continue
        for root, _, files in os.walk(sdir):
            for f in files:
                full = Path(root) / f
                with contextlib.suppress(Exception):
                    rel = full.relative_to(sdir).as_posix().lower()
                    if rel not in _ASSET_CACHE_INDEX:
                        _ASSET_CACHE_INDEX[rel] = full
                f_lower = f.lower()
                if f_lower not in _ASSET_CACHE_BASENAMES:
                    _ASSET_CACHE_BASENAMES[f_lower] = full
                if '_' in f and f.endswith(('.swf', '.png')):
                    parts = f.rsplit('_', 1)
                    ext = Path(f).suffix
                    clean_base = parts[0]
                    if clean_base.startswith(('OLDER_', 'MAYBE_', 'MAYBEOLDER_')):
                        clean_base = clean_base.split('_', 1)[1]
                    clean_f = (clean_base + ext).lower()
                    if clean_f not in _ASSET_CACHE_BASENAMES:
                        _ASSET_CACHE_BASENAMES[clean_f] = full


def send_from_directory_mod(directory, filename, max_age=None, **options):
    """Serve one file, letting a mod override win if one is loaded.

    ``max_age`` sets how long the browser may reuse the file without asking
    again. It applies to the mod branch too: a modded file is served from
    memory, and without the header it would keep revalidating on every load
    like everything else did.
    """
    _init_asset_index()
    absolute_directory = str(Path(install_path()) / directory)
    target_path = Path(absolute_directory) / filename

    if not target_path.is_file():
        if filename in KNOWN_ASSET_FALLBACKS:
            filename = KNOWN_ASSET_FALLBACKS[filename]
            target_path = Path(absolute_directory) / filename

        if not target_path.is_file():
            fn_clean = filename.replace("\\", "/").lower()
            fn_base = Path(filename).name.lower()
            indexed = _ASSET_CACHE_INDEX.get(fn_clean) or _ASSET_CACHE_BASENAMES.get(fn_base)
            if indexed and indexed.is_file():
                absolute_directory = str(indexed.parent)
                filename = indexed.name
                target_path = indexed
            else:
                if filename.startswith('displays/dialogs/'):
                    if 'battleblitz' in filename.lower():
                        fallback = 'displays/dialogs/PU_BattleBlitzOptin.swf'
                    elif 'dominance' in filename.lower() or 'domination' in filename.lower():
                        fallback = 'displays/dialogs/PU_ModalPopUp_Dominance.swf'
                    else:
                        fallback = 'displays/dialogs/PU_GenericPopUp.swf'
                    fb_path = Path(absolute_directory) / fallback
                    if fb_path.is_file():
                        filename = fallback
                        target_path = fb_path
                elif filename.startswith('displays/screens/'):
                    if 'leaderboard' in filename.lower():
                        fallback = 'displays/screens/Leaderboard2.swf'
                        fb_path = Path(absolute_directory) / fallback
                        if fb_path.is_file():
                            filename = fallback
                            target_path = fb_path

        # If not found after searching all archives and fallbacks,
        # send_from_directory below will return a clean 404.

    path = safe_join(os.fspath(absolute_directory), os.fspath(filename))

    if path in mod_engine.mod:
        response = make_response(mod_engine.mod.get(path)())
    else:
        response = send_from_directory(
            absolute_directory, filename, max_age=max_age, **options
        )

    if max_age is not None:
        cc = response.headers.get("Cache-Control", "")
        if "max-age" not in cc:
            response.headers["Cache-Control"] = f"public, max-age={max_age}, immutable, stale-while-revalidate=86400"
        else:
            parts = [cc]
            if "immutable" not in cc:
                parts.append("immutable")
            if "stale-while-revalidate" not in cc:
                parts.append("stale-while-revalidate=86400")
            response.headers["Cache-Control"] = ", ".join(parts)

    return response


# The Flash client builds its endpoint URLs from the app_url FlashVar. When that
# is missing it falls back to the compiled-in default "127.0.0.1", producing a
# scheme-less URL such as "127.0.0.1flashservices/gateway.php". Relative URLs
# are fine for record_stats (plain URLRequest), but Ruffle's
# NetConnection.connect() only accepts URLs starting with http:// or https:// --
# anything else is stubbed out and every call() afterwards throws Error #2126.
# So the absolute variants are registered alongside the legacy relative ones.
