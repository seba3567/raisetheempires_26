"""The empire editor, for the web front door.

Everything the editor needs to show an empire and everything it needs to write
one back.
"""
from __future__ import annotations

import json

from flask import Blueprint, Response, current_app, jsonify, request, session

from contract import RESOURCE_ORDER
from empires_gateway.shared import (
    _backup_chain,
    _backup_count,
    _backup_summary_payload,
    _session_snapshot,
    format_backup_message,
    get_avatar_pic,
    not_serializable,
)
from game_settings import get_zid
from quest_settings import quest_titles
from save_engine import (
    MAX_BACKUPS,
    _current_store_id,
    create_backup,
    ensure_fleets,
    validate_save,
)

bp = Blueprint("editor", __name__)


@bp.route("/editor.json")
def editor_state():
    """Everything the empire editor needs, for the web front end.

    Replaces the 2013 /save-editor page: same numbers, same quest lists, same
    raw JSON, but as JSON the new UI can render instead of a wall of <a> tags.

    Quests come in the three buckets the old page showed, because those are the
    three different things you can do to one: start it, finish it, or take it
    off the save entirely.
    """
    snapshot = _session_snapshot()
    quests = session.get('quests') or []
    incomplete = [q["name"] for q in quests if not q["complete"]]
    complete = [q["name"] for q in quests if q["complete"]]

    info = (snapshot['user_object'] or {}).get('userInfo') or {}
    player = info.get('player') or {}
    resources = (info.get('world') or {}).get('resources') or {}

    # The session is not plain JSON. ``session['battle']`` and ``last_battle``
    # decode back into ``BattleContext`` -- a tagged ``msgspec.Struct`` -- the
    # moment a save carries one, and ``jsonify`` raises on it. The 2013 editor
    # dumped this same snapshot with ``default=lambda o: '<not serializable>'``;
    # losing that when the page was migrated turned "a battle is in progress"
    # into a 500, and a 500 into the front end reporting that the gateway is
    # unreachable. The marker keeps the endpoint answering; the raw editor is
    # for reading and the typed fields are what you actually edit.
    #
    # ``jsonify`` itself cannot take ``default=`` alongside a positional
    # payload, so the response is built through the JSON provider directly.
    payload = {
        "hasSave": validate_save(session, False),
        "zid": get_zid(),
        "level": player.get('level'),
        "xp": player.get('xp'),
        "empirePoints": player.get('cash'),
        "ore": player.get('playerResourceType'),
        "worldName": info.get('worldName'),
        "picture": get_avatar_pic(),
        "resources": {name: resources.get(name) for name in RESOURCE_ORDER},
        "quests": {
            # Not started yet: these are the ones an admin can unlock.
            "locked": {q: v for q, v in quest_titles.items()
                       if q not in complete and q not in incomplete},
            "incomplete": {q: v for q, v in quest_titles.items() if q in incomplete},
            "complete": {q: v for q, v in quest_titles.items() if q in complete},
        },
        "raw": snapshot,
        "backups": _backup_count(),
        # The editor shows the ceiling instead of hard-coding it, so raising
        # MAX_BACKUPS in save_engine is a one-line change.
        "maxBackups": MAX_BACKUPS,
        # The snapshots themselves. Was the chain of nested copies walked into
        # <a> tags by the 2013 page; now it is a table, and an entry is a
        # BackupRow plus the numbers an admin picks between by.
        #
        # ``index`` is kept alongside ``revision`` so the editor UI and any old
        # links keep working, but restore is addressed by revision -- an index
        # shifts whenever the history is trimmed or a write lands between
        # rendering the page and pressing the button.
        "backupList": [
            {
                "index": i,
                "revision": row.revision,
                "label": format_backup_message(row),
                "saveVersion": row.reason,
                "message": row.reason or "",
                "size": row.size,
                "created": row.created_at,
                **(_backup_summary_payload(_current_store_id(), row.revision) if i < 25 else {"level": None, "empirePoints": None, "coins": None}),
            }
            for i, row in enumerate(_backup_chain())
        ],
    }
    return Response(
        current_app.json.dumps(payload, default=not_serializable) + "\n",
        mimetype="application/json",
    )


def _apply_save(save_game):
    """Write a save dict back over the live session.

    The same seven keys the 2013 editor's POST wrote, in the same order. Both
    the raw JSON paste and the backup restore land here so they cannot drift
    apart and leave one of them half-applying a save.
    """
    session['saved'] = str(session.get('saved', "")) + "edit"
    session['user_object'] = save_game.get('user_object')
    if 'profilePic' in session and 'profilePic' in save_game:
        session['profilePic'] = save_game['profilePic']
    session['quests'] = save_game.get('quests')
    session['battle'] = save_game.get('battle')
    session['fleets'] = save_game.get('fleets')
    session['population'] = save_game.get('population')
    session['save_version'] = save_game.get('save_version')

    # `save_game.get('fleets')` is None for a paste that omits the key, and a
    # None registry makes every later `session["fleets"][x] = y` a TypeError --
    # the same 500 this page was called in to fix, one request later.
    ensure_fleets()


@bp.route("/editor/save", methods=['POST'])
def editor_save():
    """Replace the save from a raw JSON paste.

    The escape hatch from the 2013 editor, kept because it is the only way to
    change something the typed fields do not cover. Admin-gated at the proxy,
    and the web editor refuses to post here without an admin session.
    """
    try:
        save_game = json.loads(request.form['savegame'])
    except (KeyError, ValueError) as error:
        return jsonify({"ok": False, "message": f"No se pudo leer el JSON: {error}"}), 400

    create_backup("before " + request.form.get("message", "raw edit"))
    _apply_save(save_game)

    return jsonify({"ok": True})


@bp.route("/editor/restore", methods=['POST'])
def editor_restore():
    """Roll the save back to one of its snapshots.

    The 2013 editor had this as a row of "Restore this backup" buttons posting
    ``restore<n>``, walking a chain nested inside the save. It is the only way
    back from a bad raw paste or a wipe, so it moves with the editor instead of
    dying with the old page.

    Takes a **revision**, not an index into a chain. An index shifts every time
    the history is trimmed or a write happens between the page being rendered
    and the button being pressed, so it could restore the wrong save; a revision
    names exactly one state. The index is still accepted, and resolved against
    the current listing, so old links keep working.
    """
    form = request.form

    revision = form.get('revision')
    if revision is not None:
        try:
            revision = int(revision)
        except ValueError:
            return jsonify({"ok": False, "message": "Revisión inválida"}), 400
    else:
        try:
            index = int(form['index'])
        except (KeyError, ValueError):
            return jsonify({"ok": False, "message": "Falta el respaldo a restaurar"}), 400

        chain = _backup_chain()
        if not chain:
            return jsonify({"ok": False, "message": "Esta partida no tiene respaldos"}), 400
        if index < 0 or index >= len(chain):
            return jsonify({
                "ok": False,
                "message": f"El respaldo {index} no existe; hay {len(chain)}"
            }), 400
        revision = chain[index].revision

    store = current_app.session_interface.save_store
    payload = store.read_backup(_current_store_id(), revision)
    if payload is None:
        return jsonify({"ok": False, "message": "Ese respaldo ya no existe"}), 400

    row = next((r for r in _backup_chain() if r.revision == revision), None)
    label = format_backup_message(row) if row else f"revision {revision}"
    print("restoring revision", revision, label)

    # store.restore snapshots the current state before replacing it, so the
    # rollback is undoable -- which is what the old chain could not offer once
    # it started trimming.
    create_backup(f'revert to backup "{label}"')
    _apply_save(payload)

    return jsonify({"ok": True, "restored": revision, "label": label})
