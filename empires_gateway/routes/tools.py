"""The tools an operator uses on a running world.

These are the routes the cheat surface is made of: handing out resources,
moving the player around the map, unlocking quests, and the ones that delete
saves. The gateway refuses them to anybody who is not an admin, and the front
door refuses them before they get here -- see ``admin_gate.py`` and
``contract/runtime.json``.
"""
from __future__ import annotations

import logging

from flask import Blueprint, current_app, jsonify, make_response, redirect, request, session

from battle_engine import get_active_island_by_map, set_active_island_by_map
from quest_engine import (
    handle_quest_progress,
    merge_quest_progress,
    new_quest_with_sequels,
    progress_quest,
)
from save_engine import (
    create_backup,
    get_saves,
    validate_save,
)

logger = logging.getLogger(__name__)

bp = Blueprint("tools", __name__)


@bp.route("/wipe_session", methods=['GET', 'POST'])
def wipe_session():
    session.clear()
    # Used to land on /login.html, the 2013 session picker. That page is gone;
    # the front door is this service's own landing page, which offers both
    # signing in and starting a new account.
    response = make_response(redirect('/'))
    # response.set_cookie('session', '', expires=0)
    return response


# @bp.route("/switch-session/session-id/<session_id>", methods=['GET', 'POST'])
# def switch_session(session_id):
#     response = make_response(redirect('/home.html'))
#     #session.sid = session_id.split(":")[1]
#     #response.set_cookie('sessions3', session_id.split(":")[1], max_age=60*60*24*365*2)
#     return response


@bp.route("/list_session", methods=['GET', 'POST'])
def list_session():
    # get_all_sessions() returns raw SQLAlchemy rows; get_sessions_dropdown_info
    # expects decoded save dicts, so passing rows here raised AttributeError
    # ('Session' object has no attribute 'get') as soon as one save existed.
    #
    # Served as JSON rather than as a bare string: the web front end reads this
    # to render /admin/sessions, and text/html for a JSON document means the
    # browser has to guess. The route is admin-gated at the proxy, which is the
    # only layer that knows who is signed in.
    try:
        saves = get_saves()
    except Exception as e:
        logger.warning("list_session failed to read saves: %s", e)
        saves = []
    return jsonify(get_sessions_dropdown_info(saves))


@bp.route("/save", methods=['DELETE'])
def delete_save():
    """Delete one saved game, so a player can start over.

    Keyed by the store id that ``/list_session`` already hands out -- the same
    ``session:acct<zid>`` the account row is filed under, so deleting here
    removes exactly the row that row in the list refers to and no other.

    Backed by ``save_store.Store.delete``, which removes the save and, by
    cascade, its snapshots. Nothing else touches the database: the account row
    in ``users`` is a different thing and survives, so deleting an empire does
    not delete the login.
    """
    # Flask does not populate request.form for a DELETE -- it parses bodies for
    # POST and PUT only -- so the id arrives here empty and every delete answers
    # "falta el id". Parsed by hand rather than switched to POST: the verb is
    # part of the contract, and a client that gets it wrong should not be able
    # to delete anything.
    store_id = request.values.get('store_id')
    if not store_id:
        from urllib.parse import parse_qs
        parsed_ids = parse_qs(request.get_data(as_text=True) or '').get('store_id', [])
        store_id = parsed_ids[0] if parsed_ids else None

    if not store_id:
        return jsonify({"ok": False, "message": "Falta el id de la partida"}), 400

    # Only a key this server issues. `get_saves` is the list of them, and it is
    # also what stops this route being a way to delete anything else in the
    # database by passing an arbitrary string.
    known = {save['session_id'] for save in get_saves()}
    if store_id not in known:
        return jsonify({
            "ok": False,
            "message": "No existe esa partida"
        }), 404

    deleted = _current_save_store().delete(store_id)
    print("Deleted save", store_id, "->", deleted)

    return jsonify({"ok": True, "store_id": store_id, "deleted": deleted})


def _current_save_store():
    """The save store this app is configured to use."""
    return current_app.session_interface.save_store


def get_sessions_dropdown_info(saves):
    if saves:
        response = [{
            "session_id": save['session_id'],
            "uid": save['user_object']["userInfo"]["player"]["uid"],
            "world_name": save['user_object']["userInfo"]["worldName"],
            "level": save['user_object']["userInfo"]["player"]["level"],
            "xp": save['user_object']["userInfo"]["player"]["xp"],
            "profilePic": "img/avatars/" + (save['profilePic'] if 'profilePic' in save and save['profilePic'] is not None else "blank.png"),
        } for save in saves if validate_save(save)]
    else:
        response = []
    return response

@bp.route("/gazillionaire", methods=['GET', 'POST'])
def more_money():
    if 'user_object' in session:
        create_backup("gazillionaire cheat")
        player = session['user_object']["userInfo"]["player"]
        player['cash'] += 10000
        session['saved'] = str(session.get('saved', "")) +  "gazillionaire"
        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/deprogress", methods=['GET', 'POST'])
def deprogress_battle_map():
    if 'user_object' in session:
        # player = session['user_object']["userInfo"]["player"]
        campaign = session['user_object']['userInfo']['world']['campaign']
        # if map_name not in campaign['active'].keys():
        #     campaign['active'][map_name] = {"status": 0, "fleets": []}
        list = sorted(campaign['active'].keys())

        map, island = get_active_island_by_map(list[-1])

        create_backup("before deprogress battle map " + str(island+1) + "=>" + str(island))
        session['saved'] = str(session.get('saved', "")) + "deprogress"
        if island <= 0:
            del campaign['active'][map]
            deprogress_battle_map()
        else:
            set_active_island_by_map(map, island - 1)
        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/seed/w/<int:w>/z/<int:z>", methods=['GET', 'POST'])
def change_seed(w, z):
    if 'user_object' in session:
        create_backup("seed")
        world = session['user_object']["userInfo"]["world"]
        prev_seed = str(world["randSeedW"]) + ', ' + str(world["randSeedZ"])
        world["randSeedW"] = w
        world["randSeedZ"] = z
        print("Seed change", prev_seed, "=>", str(world["randSeedW"]) + ', ' + str(world["randSeedZ"]))

        session['saved'] = str(session.get('saved', "")) +  "seed"
        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/patch/<path:path>/empty-dict", methods=['GET', 'POST'])
def patch_user_empty_dict(path):
    return patch_user(path, {})


@bp.route("/patch/<path:path>/empty-list", methods=['GET', 'POST'])
def patch_user_empty_list(path):
    return patch_user(path, [])


@bp.route("/patch/<path:path>/none", methods=['GET', 'POST'])
def patch_user_dict(path):
    return patch_user(path, None)


@bp.route("/patch/<path:path>/int/<int:value>", methods=['GET', 'POST'])
@bp.route("/patch/<path:path>/string/<value>", methods=['GET', 'POST'])
def patch_user(path, value):
    if 'user_object' in session:
        if path.split('/')[0] not in ("saved", "original_save_version"):
            create_backup("patch")
            dictionary = session
            for p in path.split('/')[:-1]:
                dictionary = dictionary[p]

            dictionary[path.split('/')[-1]] = value

            session['saved'] = str(session.get('saved', "")) + "patch"
            response = make_response(redirect('/home.html'))
            return response
        return ("Nope! Disallowed patch root", 403)
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/patch/<path:path>/list/index/<int:i>/int/<int:value>", methods=['GET', 'POST'])
@bp.route("/patch/<path:path>/list/index/<int:i>/string/<value>", methods=['GET', 'POST'])
def patch_user_list(path, i, value):
    if 'user_object' in session:
        if path.split('/')[0] not in ("saved", "original_save_version"):
            create_backup("patch")
            dictionary = session
            for p in path.split('/'):
                dictionary = dictionary[p]

            dictionary[i] = value

            session['saved'] = str(session.get('saved', "")) + "patch"
            response = make_response(redirect('/home.html'))
            return response
        return ("Nope! Disallowed patch root", 403)
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/unlock_quest/<value>", methods=['GET', 'POST'])
def unlock_quest(value):
    if 'user_object' in session:
        create_backup("Unlocked quest " + value)
        new_quests=[]
        meta = {}
        new_quest_with_sequels(value, new_quests, meta, force=True)
        merge_quest_progress(new_quests, session['quests'], "session quest")
        session['saved'] = str(session.get('saved', "")) + "unlock"

        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/complete_quest/<value>", methods=['GET', 'POST'])
def complete_quest(value):
    if 'user_object' in session:
        create_backup("Complete quest " + value)
        new_quests=[]
        meta = {}
        handle_quest_progress(meta, progress_quest(value))
        session['saved'] = str(session.get('saved', "")) + "complete"

        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/remove_quest/<value>", methods=['GET', 'POST'])
def remove_quest(value):
    if 'user_object' in session:
        create_backup("Remove quest " + value)
        session['quests'] = [e for e in session['quests'] if e["name"] != value]
        session['saved'] = str(session.get('saved', "")) + "remove"

        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@bp.route("/save-editor")
def save_editor():
    """The 2013 editor is gone; /admin/editor replaced it.

    Kept as a redirect so an old bookmark, a post on a forum or a muscle-memory
    URL lands on the current page instead of a 404. The proxy still gates this
    path as admin-only, which is what stops anyone discovering the move.
    """
    return redirect('/admin/editor')


def format_backup_message(backup):
    """One line describing a snapshot, for the editor's list.

    Takes a ``save_store.BackupRow``. It used to take the snapshot dict itself
    and dig out ``replaced_on`` / ``message`` / ``save_version``, all of which
    lived on the node because the chain was nested inside the save. The reason
    and the timestamp are columns now, so there is nothing to dig out.
    """
    reason = backup.reason or ""
    return f"{backup.created_at} - rev {backup.revision} - {reason}"
