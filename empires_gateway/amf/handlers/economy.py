"""What the empire spends.

Everything the player buys: the catalogue items, the energy, the ammunition
and the mana refills, the contract unlocks, the quest tasks and the expansions.
The pricing lives here too, because the price and the thing being paid for
are the same decision.
"""
from __future__ import annotations

import logging
import math

from flask import session

from empires_gateway.shared import WORLD_RESOURCES
from game_settings import (
    game_settings,
    lookup_item_by_code,
    unlock_expansion,
)
from quest_engine import (
    get_tasks,
    handle_quest_progress,
    lookup_quest,
    progress_action,
    progress_buy_consumable,
    progress_market_added_count,
    progress_quest_task,
)

logger = logging.getLogger(__name__)


def _economy_session():
    """The player's save, or None if there is no session to charge.

    A purchase that arrives before `initUser` has no player to charge, and
    `session['user_object']` raises KeyError when it is not there -- a KeyError
    that took the whole call, and with it the rest of the batch, down. There
    is nothing to buy and nobody to buy it for, so the answer is the same
    empty one an unimplemented service gives.
    """
    save = session.get('user_object')
    if not save:
        # Nothing to charge and nobody to charge it to. The answer is the
        # empty one an unimplemented service gives, so this is expected
        # traffic from a client that bought before it logged in.
        logger.info("Purchase without a session to charge")
        return None
    return save


def buy_item_response(param):
    """`UserService.buyItem` -- comprar un item suelto del mercado."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("buyItem without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    buy_item(meta, param.get("code"), param.get("amount"))
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def buy_item(meta, code, amount):
    """Compra un item del mercado y lo entrega.

    El precio sale del catalogo (`cost` e `itemcost`), nunca de una cuenta
    hecha aqui: el servidor cobra lo que el juego dice que cuesta, y lo cobra
    en la moneda que el item declara.

    Antes se cobraba siempre `cost["-cash"]`, que hacia tres cosas mal a la
    vez: reventaba con los items que no cuestan cash (una KeyError que se
    llevaba la llamada entera), cobraba cash a items que cuestan coins, y
    cobraba de mas a los que no tienen `cost` (774 de los 3990 items del
    catalogo no lo tienen, y son los que el juego regala).
    """
    item = _catalogue_item(code)
    if item is None:
        return False

    amount = _purchase_amount(amount)
    player = session['user_object']["userInfo"]["player"]
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    inventory = player["inventory"]["items"]

    price = _item_price(item, amount)
    key_costs = _item_key_costs(item, amount)
    if not _can_afford(player, resources, inventory, price, key_costs):
        logger.info("Purchase refused, cannot afford %r x%s (price %s, keys %s)",
                    code, amount, price, key_costs)
        return False

    # Entrega: un item que da un recurso lo da; el resto es un objeto que
    # acaba en el inventario.
    #
    # El `-resourceType` de un item no es siempre un recurso del mundo: los
    # contratos de mina son `rare`, el fuel es `fuel` y la fabrica de powerups
    # es `powerup`. Esos no se pueden sumar a `resources` (KeyError), y un
    # contrato de mina no da 8 de rare al comprarlo: da el contrato.
    resource_type = item.get("-resourceType")
    resource_yield = item.get("resourceYield")
    if resource_type in WORLD_RESOURCES and resource_yield is not None:
        resources[resource_type] += amount * int(resource_yield)
        print("Buy: received", resource_type + ":", str(amount) +
              "(" + str(resources[resource_type]) + ")")
    else:
        inventory[code] = inventory.get(code, 0) + amount

    _charge(player, resources, inventory, price, key_costs)
    handle_quest_progress(meta, progress_buy_consumable(item))
    return True


def buy_items_response(param):
    """`UserService.buyItems` -- comprar varios items de una vez."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("buyItems without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    for code, amount in _purchase_batch(param.get("itemData")):
        buy_item(meta, code, amount)

    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def use_item_response(param):
    """`UserService.useItem` -- gastar un item del inventario.

    Antes: `item_inventory[param] -= 1`, sin mirar si el item existia. Gastar
    un item que el jugador no tiene reventaba con KeyError, y gastar el
    ultimo dejaba el contador en -1: un item que el jugador no tiene pero que
    el cliente cuenta.
    """
    code = param
    if isinstance(param, dict):
        code = param.get("code") or param.get("itemCode") or param.get("item")

    save = _economy_session()
    if save is None:
        return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}

    item_inventory = save["userInfo"]["player"]["inventory"]["items"]
    if isinstance(code, str) and item_inventory.get(code, 0) > 0:
        item_inventory[code] -= 1
    else:
        logger.info("Use of an item the player does not have: %r", code)

    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def purchase_energy_refill_response(param):
    """`UserService.purchaseEnergyRefill` -- rellenar la energia.

    El coste se calcula con la energia *antes* del refill. Antes se rellenaba
    primero y luego se hacia `energyMax - energy`, con la energia ya llena:
    el coste salia cero y el refill era gratis.

    El precio por punto de energia es el del catalogo: el consumible EN4
    cuesta 5 de cash y da 5 de energia, o sea 1 de cash por punto.
    """
    save = _economy_session()
    if save is None:
        return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}

    player = save["userInfo"]["player"]

    energy_max = int(player.get('energyMax', 0))
    energy = int(player.get('energy', 0))
    missing = energy_max - energy

    if missing > 0:
        player['energy'] = energy_max
        player['cash'] = int(player.get('cash', 0)) - missing
    else:
        # Nada que rellenar: no se cobra y no se toca la energia. Un jugador
        # por encima del tope (un item de energia de mas) no pierde lo que
        # tiene por pedir un refill.
        logger.info("Energy refill with nothing to refill: %s/%s", energy, energy_max)

    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def buy_quest_task_response(param):
    """`UserService.buyQuestTask` -- comprar un task de quest."""
    meta = {"newPVE": 0}
    save = _economy_session()
    if not isinstance(param, dict) or save is None:
        if not isinstance(param, dict):
            logger.info("buyQuestTask without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    name = param.get("name")
    task_index = param.get("taskIndex")
    if name is None or task_index is None:
        logger.info("buyQuestTask without a name or a task index: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    player = save["userInfo"]["player"]
    q = lookup_quest(name)
    if q is not None:
        tasks = get_tasks(q)
        if isinstance(task_index, int) and 0 <= task_index < len(tasks):
            cost_info = tasks[task_index].get('cost')
            if isinstance(cost_info, dict) and '_amount' in cost_info:
                try:
                    amount = int(cost_info['_amount'])
                except (ValueError, TypeError):
                    amount = 0
                if amount > 0:
                    current_cash = int(player.get('cash', 0))
                    if current_cash < amount:
                        logger.info("buyQuestTask refused, cannot afford %r task %s (cost %d, cash %d)", name, task_index, amount, current_cash)
                        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}
                    player['cash'] = current_cash - amount

    handle_quest_progress(meta, progress_quest_task(name, task_index))
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def buy_expansion_response(param):
    """`UserService.buyExpansion` -- encender una expansion de la isla.

    Las expansiones se guardan como un mapa de bits: `index >> 5` es la
    palabra y `index & 31` es el bit dentro de esa palabra. El precio lo cobra
    la compra del item de expansion (`x01` y hermanos), no esta llamada: esta
    enciende el bit que el jugador ya pagado.
    """
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("buyExpansion without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    index = param.get('index')
    if not isinstance(index, int) or isinstance(index, bool) or index < 0:
        logger.info("buyExpansion without a usable index: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    unlock_expansion(index)
    handle_quest_progress(meta, progress_action("expansionsPurchased"))
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def purchase_contact_unlock(param):
    """`UserService.purchaseContractUnlock` -- desbloquear un contrato.

    El precio sale del catalogo: el item que se desbloquea mas el multiplicador
    que el propio juego dice (`-contractUnlockMultiple`).
    """
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("purchaseContractUnlock without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    item_code = param.get("itemCode")
    item = _catalogue_item(item_code)
    if item is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    # Un unlock abre varios contratos a la vez, y se paga por cada uno.
    multiple = int(game_settings['settings']['gamesettings'].get('-contractUnlockMultiple', 1))
    price = {resource: units * multiple
             for resource, units in _item_price(item, 1).items()}
    key_costs = _item_key_costs(item, 1)

    player = session['user_object']["userInfo"]["player"]
    resources = session['user_object']["userInfo"]["world"]['resources']
    inventory = player["inventory"]["items"]
    if not _can_afford(player, resources, inventory, price, key_costs):
        logger.info("Contract unlock refused, cannot afford %r (price %s)",
                       item_code, price)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    _charge(player, resources, inventory, price, key_costs)

    unlocked = player.setdefault("unlockedContracts", [])
    if item_code not in unlocked:
        unlocked.append(item_code)
    inventory[item_code] = inventory.get(item_code, 0) + 1

    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def _catalogue_item(code):
    """El item del catalogo con ese codigo, o None si no existe.

    `lookup_item_by_code` levanta ValueError cuando no encuentra el codigo, y
    un ValueError a mitad de una compra se lleva por delante la llamada
    entera: el cliente se queda sin respuesta y el turno se descuadra.
    """
    if not isinstance(code, str) or not code:
        logger.info("Purchase of an item without a code: %r", code)
        return None
    try:
        return lookup_item_by_code(code)
    except ValueError:
        # The client asks for items this catalogue does not carry. It happens
        # on every load, it is answered by not buying anything, and the player
        # carries on -- so it is not a warning, it is the log telling you the
        # two content sets drifted apart.
        logger.info("Purchase of an item code the catalogue does not know: %r", code)
        return None


def _purchase_amount(amount):
    """La cantidad que pidio el cliente, como un entero positivo."""
    try:
        value = int(amount)
    except (TypeError, ValueError):
        return 1
    return value if value > 0 else 1


def _purchase_batch(item_data):
    """Los pares (codigo, cantidad) de un `buyItems`, sea como llegue.

    El cliente manda esto como un mapa. Se acepta tambien como lista de pares
    y como lista de objetos, porque el juego tiene mas de un sitio desde el
    que se compra y no todas mandan lo mismo.
    """
    if isinstance(item_data, dict):
        return list(item_data.items())
    if isinstance(item_data, list):
        batch = []
        for entry in item_data:
            if isinstance(entry, dict):
                code = entry.get("code") or entry.get("itemCode")
                batch.append((code, entry.get("amount", 1)))
            elif isinstance(entry, (list, tuple)) and len(entry) == 2:
                batch.append((entry[0], entry[1]))
        return batch
    return []


def _level_discount(item):
    """El descuento por nivel que el propio catalogo implica."""
    required_level = int(item.get("requiredLevel", "0"))
    player_level = session["user_object"]["userInfo"]["player"].get("level", 1)

    if "requiredDate" not in item:
        return 0

    if required_level >= 25:
        if player_level >= 51:
            return .25
        if player_level >= 35:
            return .15
    elif required_level >= 15:
        if player_level >= 51:
            return .30
        if player_level >= 35:
            return .20
        if player_level >= 20:
            return .10
    return 0


def _item_price(item, amount):
    """Lo que cuesta un item, por moneda.

    `cost` es un mapa de `-<recurso>` a cantidad: cash es del jugador, el
    resto son recursos del mundo. Un item sin `cost` es gratis, que es
    exactamente lo que dice el catalogo (los regalos de recursos lo tienen
    vacio).
    """
    cost = item.get("cost") or {}
    price = {}
    for key, value in cost.items():
        resource = str(key).lstrip("-")
        try:
            units = float(value)
        except (TypeError, ValueError):
            continue
        price[resource] = price.get(resource, 0.0) + units

    discount = _level_discount(item)
    for resource in list(price):
        units = price[resource] * amount
        if resource == "cash":
            units *= (1 - discount)
        price[resource] = math.ceil(units)
    return price


def _item_key_costs(item, amount):
    """Las llaves que un item exige (`itemcost`), por codigo de item.

    Una expansion cuesta coins *y* llaves de expansion (`xk01`), y las llaves
    se llevan del inventario: son un item mas, y se gastan.
    """
    item_cost = item.get("itemcost") or {}
    keys = {}
    for key, value in item_cost.items():
        code = str(key).lstrip("-")
        try:
            units = int(value)
        except (TypeError, ValueError):
            continue
        keys[code] = units * amount
    return keys


def _can_afford(player, resources, inventory, price, key_costs):
    """Se puede pagar este precio con lo que el jugador tiene."""
    for resource, units in price.items():
        if resource == "cash":
            if player.get("cash", 0) < units:
                return False
        elif resource in WORLD_RESOURCES:
            if resources.get(resource, 0) < units:
                return False
        else:
            # Una moneda que ni el jugador ni el mundo llevan: no se puede
            # pagar, y cobrar de mas no es una opcion.
            return False

    return all(inventory.get(code, 0) >= units for code, units in key_costs.items())


def _charge(player, resources, inventory, price, key_costs):
    """Cobra el precio, que ya se ha comprobado que se puede pagar."""
    for resource, units in price.items():
        if resource == "cash":
            player["cash"] = int(player.get("cash", 0)) - units
        else:
            resources[resource] = resources.get(resource, 0) - units

    for code, units in key_costs.items():
        inventory[code] = inventory.get(code, 0) - units


def place_market_order(market, order, meta):
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    if order["type"] == "resource":
        standard_resources = ["coins", "oil", "wood", "aluminum", "copper", "gold", "iron", "uranium"]
        resources[standard_resources[int(order["item"])]] -= order["units"]
        print("Market: Order placed & removed", standard_resources[int(order["item"])] + ":", str(order["units"])
              + "(" + str(resources[standard_resources[int(order["item"])]]) + ")")
        handle_quest_progress(meta, progress_market_added_count(order["units"]))
    else:
        print("TODO: Can't reserve market type", order.get("type"), "yet")
    market["type"] = order["type"]
    market["item"] = order["item"]
    market["units"] = order["units"]


def refund_market_order(market):
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    if market.get("type") == "resource":
        standard_resources = ["coins", "oil" , "wood", "aluminum", "copper", "gold", "iron", "uranium"]
        item_idx = market.get("item")
        if item_idx is not None:
            try:
                item_idx = int(item_idx)
                if 0 <= item_idx < len(standard_resources):
                    res_name = standard_resources[item_idx]
                    units = market.get("units", 0) or 0
                    resources[res_name] = resources.get(res_name, 0) + units
                    print(f"Market: Refunded {res_name}: {units} ({resources[res_name]})")
            except (ValueError, TypeError) as e:
                print(f"Market refund error: {e}")
    else:
        print("TODO: Can't refund market type", market.get("type"), "yet")
    market["type"] = None
    market["item"] = None
    market["units"] = None

