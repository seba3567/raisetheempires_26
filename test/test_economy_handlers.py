"""Los siete handlers de economia: lo que el cliente pide y lo que el servidor responde.

Que son
------
Siete llamadas AMF que el cliente hace cuando el jugador compra algo: un item del
mercado, varios a la vez, una expansion, un refill de energia, un contrato, un
task de quest, o usar un item del inventario. Todas viven en ``empires-server.py``
y todas escriben en el mismo sitio: la sesion del jugador.

Por que estan sin cobertura
---------------------------
No es que esten sin probar porque sean nuevas. Es que los handlers hacen una cosa
muy especial: **cobran**. Cada uno descuenta un recurso distinto --cash, coins,
energia, un item del inventario-- y un error de cuenta no se ve como un error:
se ve como un jugador que pierde coins, o que gana energia gratis, o que pierde
un item que nunca llego a tener.

Y hay tres formas de que eso pase, todas presentes aqui:

* **Se cobra despues de lo que se concede.** ``purchaseEnergyRefill`` rellena la
  energia *y luego* calcula lo que cuesta, con la energia ya rellena: el coste
  sale cero y el refill es gratis.
* **Se cobra un recurso que el item no define.** ``buyItem`` usa siempre
  ``cost["-cash"]``. Pero un item puede costar coins, o no costar nada, o costar
  un recurso que no es cash. El codigo real de los items tiene las tres.
* **Se cobra el precio pero no se entrega el item.** ``buyItem`` con un item que
  tiene ``-resourceType`` anade recursos; con un item que no lo tiene lo anade
  al inventario; pero hay items cuyo ``-resourceType`` no es un recurso del
  mundo (``rare``, ``powerup``, ``fuel``) y esos ni reciben ni se cobran bien.

Que fijan estos tests
---------------------
Cada test dice una regla del juego, no una linea de codigo. Y --esto es lo que
importa-- **cada uno tiene que fallar sin el arreglo**. Un test que pasa con el
codigo viejo no esta probando el bug: esta probando que el bug no existe.

La regla de oro de este fichero: el servidor no inventa el precio. El precio
sale de ``gameSettings`` (``item["cost"]``), el recurso sale de la posicion del
item en el catalogo, y lo que no se puede cobrar no se cobra en silencio: se
dice.
"""

from __future__ import annotations

import math

import pytest
from flask import Flask, session

empires_server = __import__('empires-server')
game_settings = pytest.importorskip('game_settings')

app = Flask(__name__)
app.secret_key = 'test'


def _player(**overrides):
    """Un jugador con la forma que `init_user` escribe.

    Solo las claves que los handlers de economia tocan, mas las que
    `handle_quest_progress` necesita para no reventar por su cuenta.
    """
    player = {
        "uid": 1,
        "level": 1,
        "xp": 0,
        "cash": 1000,
        "energy": 10,
        "energyMax": 25,
        "lastEnergyCheck": 0,
        "socialXpGood": 0,
        "socialXpBad": 0,
        "socialLevelGood": 0,
        "socialLevelBad": 0,
        "playerResourceType": 3,
        "inventory": {"items": {}},
        "unlockedContracts": [],
        "expansions": {"data": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]},
    }
    player.update(overrides)
    return player


def _world(**overrides):
    resources = {"coins": 5000, "energy": 25, "oil": 100, "wood": 200,
                 "aluminum": 1000, "copper": 0, "gold": 0, "iron": 0, "uranium": 0}
    resources.update(overrides.pop("resources", {}))
    return {
        "userInfo": {
            "player": _player(**overrides.pop("player", {})),
            "worldName": "Probe",
            "world": {"resources": resources,
                      "resourceOrder": ["aluminum", "copper", "gold", "iron", "uranium"],
                      "research": {}},
        }
    }


def _call(handler, param, world=None):
    """Invoke a handler with a session in place and hand back the save."""
    with app.test_request_context():
        session.sid = "0"
        session['user_object'] = world if world is not None else _world()
        session['quests'] = []
        response = handler(param)
        return response, session['user_object']


def _player_of(save):
    return save["userInfo"]["player"]


def _resources_of(save):
    return save["userInfo"]["world"]["resources"]


class TestBuyItem:
    """`UserService.buyItem` -- comprar un item suelto del mercado."""

    def test_buying_a_resource_item_gives_the_resource(self):
        """RS01 es aluminio: `resourceYield: 10`, `cost: {cash: 13}`.

        El item dice las dos cosas: cuanto da y cuanto cuesta. El servidor tiene
        que leer las dos del mismo sitio.
        """
        _, save = _call(empires_server.buy_item_response,
                        {"code": "RS01", "amount": 1})

        assert _resources_of(save)["aluminum"] == 1010

    def test_buying_a_resource_item_costs_its_cash_price(self):
        _, save = _call(empires_server.buy_item_response,
                        {"code": "RS01", "amount": 1})

        assert _player_of(save)["cash"] == 1000 - 13

    def test_buying_several_costs_several_times_the_price(self):
        """El precio es por unidad: tres RS01 son tres precios."""
        _, save = _call(empires_server.buy_item_response,
                        {"code": "RS01", "amount": 3})

        assert _player_of(save)["cash"] == 1000 - 39

    def test_buying_a_consumable_puts_it_in_the_inventory(self):
        """N01 es un consumible sin `resourceType`: va al inventario, no a los recursos."""
        _, save = _call(empires_server.buy_item_response,
                        {"code": "N01", "amount": 2})

        assert _player_of(save)["inventory"]["items"]["N01"] == 2

    def test_buying_a_consumable_still_costs_its_price(self):
        _, save = _call(empires_server.buy_item_response,
                        {"code": "N01", "amount": 2})

        assert _player_of(save)["cash"] == 1000 - 8

    def test_a_mercenery_goes_to_the_inventory_too(self):
        """M01 es un mercenario: `-type: mercenary`, sin `resourceType`.

        Antes solo imprimia "Buying mercenary" y no entregaba nada: el jugador
        pagaba y no recibia. Ahora va al inventario, que es donde puede usarse.
        """
        _, save = _call(empires_server.buy_item_response,
                        {"code": "M01", "amount": 1})

        assert _player_of(save)["inventory"]["items"]["M01"] == 1

    def test_an_item_with_a_resource_type_the_world_does_not_have_still_arrives(self):
        """G22 es un contrato de mina: `-resourceType: rare`, y `rare` no es un
        recurso del mundo (los recursos son coins, oil, wood, aluminum, copper,
        gold, iron, uranium).

        La compra no puede fallar por esto. Un `rare` no se puede sumar a los
        recursos del mundo, asi que lo que se reparte es el item.
        """
        _, save = _call(empires_server.buy_item_response,
                        {"code": "G22", "amount": 1})

        items = _player_of(save)["inventory"]["items"]
        assert items.get("G22") == 1
        assert "rare" not in _resources_of(save)

    def test_an_item_that_costs_coins_is_paid_in_coins(self):
        """G01 (mina de hierro) cuesta `-coins: 100`, no cash.

        El precio dice en que moneda se paga. Cobrar cash cuando el item pide
        coins es cobrar la moneda equivocada.
        """
        _, save = _call(empires_server.buy_item_response,
                        {"code": "G01", "amount": 1})

        assert _resources_of(save)["coins"] == 5000 - 100

    def test_an_item_that_costs_coins_does_not_cost_cash(self):
        _, save = _call(empires_server.buy_item_response,
                        {"code": "G01", "amount": 1})

        assert _player_of(save)["cash"] == 1000

    def test_an_item_with_no_cost_at_all_is_free(self):
        """RG28 (coins_gift) no tiene `cost`: no cuesta nada, y no debe inventar
        un precio que el catalogo no dice."""
        _, save = _call(empires_server.buy_item_response,
                        {"code": "RG28", "amount": 1})

        assert _player_of(save)["cash"] == 1000

    def test_an_unknown_code_does_not_take_the_payment(self):
        """Un codigo que no existe en el catalogo no se puede cobrar.

        Antes `lookup_item_by_code` reventaba con ValueError y el handler entero
        se caia: el batch perdia esa llamada y el resto del turno tambien.
        """
        response, save = _call(empires_server.buy_item_response,
                               {"code": "NOEXISTE", "amount": 1})

        assert response["errorType"] == 0
        assert _player_of(save)["cash"] == 1000

    def test_a_missing_amount_is_treated_as_one(self):
        """El cliente puede mandar solo el codigo. Compre uno, no cero y no
        reviente."""
        response, save = _call(empires_server.buy_item_response,
                               {"code": "RS01"})

        assert response["errorType"] == 0
        assert _resources_of(save)["aluminum"] == 1010

    def test_the_answer_has_the_shape_the_client_expects(self):
        response, _ = _call(empires_server.buy_item_response,
                            {"code": "RS01", "amount": 1})

        assert response["errorType"] == 0
        assert response["userId"] == 1
        assert response["metadata"] == {"newPVE": 0}
        assert response["data"] == []


class TestBuyItems:
    """`UserService.buyItems` -- comprar varios a la vez."""

    def test_it_buys_every_item_in_the_batch(self):
        _, save = _call(empires_server.buy_items_response,
                        {"itemData": {"RS01": 2, "N01": 1}})

        assert _resources_of(save)["aluminum"] == 1020
        assert _player_of(save)["inventory"]["items"]["N01"] == 1

    def test_it_charges_the_total(self):
        """2 RS01 (13) + 1 N01 (4) = 30."""
        _, save = _call(empires_server.buy_items_response,
                        {"itemData": {"RS01": 2, "N01": 1}})

        assert _player_of(save)["cash"] == 1000 - 30

    def test_one_unknown_code_does_not_cancel_the_others(self):
        """El lote es del jugador: un codigo raro no puede cancelar lo que si
        se pudo comprar."""
        _, save = _call(empires_server.buy_items_response,
                        {"itemData": {"NOEXISTE": 1, "RS01": 1}})

        assert _resources_of(save)["aluminum"] == 1010

    def test_an_empty_batch_is_not_an_error(self):
        response, save = _call(empires_server.buy_items_response,
                               {"itemData": {}})

        assert response["errorType"] == 0
        assert _player_of(save)["cash"] == 1000


class TestUseItem:
    """`UserService.useItem` -- gastar un item del inventario."""

    def test_using_an_item_removes_one_from_the_inventory(self):
        world = _world()
        _player_of(world)["inventory"]["items"]["N01"] = 3

        _, save = _call(empires_server.use_item_response, "N01", world)

        assert _player_of(save)["inventory"]["items"]["N01"] == 2

    def test_using_an_item_the_player_does_not_have_does_not_go_negative(self):
        """Sin el item, el contador no puede volverse -1: eso es un item que el
        jugador no tiene pero que el cliente cuenta."""
        world = _world()

        response, save = _call(empires_server.use_item_response, "N01", world)

        assert response["errorType"] == 0
        assert _player_of(save)["inventory"]["items"].get("N01", 0) >= 0

    def test_using_the_last_one_leaves_zero_not_minus_one(self):
        world = _world()
        _player_of(world)["inventory"]["items"]["N01"] = 1

        _, save = _call(empires_server.use_item_response, "N01", world)

        assert _player_of(save)["inventory"]["items"]["N01"] == 0


class TestPurchaseEnergyRefill:
    """`UserService.purchaseEnergyRefill` -- rellenar la energia."""

    def test_the_refill_fills_the_energy_to_the_maximum(self):
        _, save = _call(empires_server.purchase_energy_refill_response, {})

        assert _player_of(save)["energy"] == 25

    def test_the_refill_costs_cash(self):
        """El coste se calcula con la energia *antes* del refill.

        Antes se rellenaba primero y luego se calculaba el coste, con la energia
        ya llena: `energyMax - energy` daba cero y el refill salia gratis.
        """
        _, save = _call(empires_server.purchase_energy_refill_response, {})

        assert _player_of(save)["cash"] == 1000 - 15

    def test_a_full_player_is_not_charged_for_a_refill(self):
        """No hay nada que rellenar, asi que no hay nada que cobrar."""
        world = _world()
        _player_of(world)["energy"] = 25

        _, save = _call(empires_server.purchase_energy_refill_response, {}, world)

        assert _player_of(save)["cash"] == 1000

    def test_the_energy_stays_an_integer(self):
        _, save = _call(empires_server.purchase_energy_refill_response, {})

        assert isinstance(_player_of(save)["energy"], int)

    def test_the_refill_leaves_the_energy_exactly_at_the_maximum(self):
        """Ni un punto por encima: un refill llena, no rebosa."""
        world = _world()
        _player_of(world)["energy"] = 24

        _, save = _call(empires_server.purchase_energy_refill_response, {}, world)

        assert _player_of(save)["energy"] == 25


class TestPurchaseContractUnlock:
    """`UserService.purchaseContractUnlock` -- desbloquear un contrato."""

    def test_unlocking_records_the_contract(self):
        _, save = _call(empires_server.purchase_contact_unlock,
                        {"itemCode": "UL2"})

        assert "UL2" in _player_of(save)["unlockedContracts"]

    def test_unlocking_costs_cash(self):
        """UL2 cuesta 10 de cash, y el catalogo dice que un unlock de contrato
        se paga cuatro veces (`-contractUnlockMultiple: 4`)."""
        _, save = _call(empires_server.purchase_contact_unlock,
                        {"itemCode": "UL2"})

        assert _player_of(save)["cash"] == 1000 - 40

    def test_unlocking_twice_does_not_record_it_twice(self):
        """El mismo contrato desbloqueado dos veces no es dos contratos."""
        world = _world()
        _call(empires_server.purchase_contact_unlock, {"itemCode": "UL2"}, world)
        _, save = _call(empires_server.purchase_contact_unlock,
                        {"itemCode": "UL2"}, world)

        assert _player_of(save)["unlockedContracts"].count("UL2") == 1

    def test_an_unknown_code_does_not_take_the_payment(self):
        response, save = _call(empires_server.purchase_contact_unlock,
                               {"itemCode": "NOEXISTE"})

        assert response["errorType"] == 0
        assert _player_of(save)["cash"] == 1000


class TestBuyQuestTask:
    """`UserService.buyQuestTask` -- comprar un task de quest."""

    def test_buying_a_task_answers_without_error(self):
        response, _ = _call(empires_server.buy_quest_task_response,
                            {"name": "Q0001", "taskIndex": 0})

        assert response["errorType"] == 0

    def test_buying_a_task_does_not_touch_the_wallet(self):
        """Comprar un task no es comprar un item: no se descuenta cash."""
        _, save = _call(empires_server.buy_quest_task_response,
                        {"name": "Q0001", "taskIndex": 0})

        assert _player_of(save)["cash"] == 1000

    def test_a_missing_name_does_not_reach_the_crash_handler(self):
        """Un parametro ausente no puede tumbar la llamada entera."""
        response, _ = _call(empires_server.buy_quest_task_response, {})

        assert response["errorType"] == 0

    def test_a_missing_task_index_does_not_reach_the_crash_handler(self):
        response, _ = _call(empires_server.buy_quest_task_response,
                            {"name": "Q0001"})

        assert response["errorType"] == 0


class TestBuyExpansion:
    """`UserService.buyExpansion` -- comprar una expansion de la isla."""

    def test_buying_an_expansion_sets_its_bit(self):
        """Las expansiones se guardan como un mapa de bits: `index >> 5` es el
        indice del entero y `index & 31` es el bit dentro de ese entero."""
        _, save = _call(empires_server.buy_expansion_response, {"index": 3})

        expansions = _player_of(save)["expansions"]["data"]
        assert expansions[0] & (1 << 3)

    def test_buying_an_expansion_just_over_a_word_boundary_sets_the_next_word(self):
        """El indice 32 es el bit 0 del segundo entero: si el calculo del
        desplazamiento estuviera mal, pondria el bit 32 del primero."""
        _, save = _call(empires_server.buy_expansion_response, {"index": 32})

        expansions = _player_of(save)["expansions"]["data"]
        assert expansions[1] & (1 << 0)
        assert not (expansions[0] & (1 << 32)) if expansions[0] > (1 << 31) else True

    def test_buying_an_expansion_item_costs_coins_and_keys(self):
        """`expansion01` (x01) cuesta `-coins: 5000` y `-xk01: 10`.

        Las llaves de expansion (`xk01`) son un item del inventario: se
        compran aparte con cash y se gastan al comprar la expansion.
        """
        world = _world()
        _player_of(world)["inventory"]["items"]["xk01"] = 20

        _, save = _call(empires_server.buy_item_response,
                        {"code": "x01", "amount": 1}, world)

        assert _resources_of(save)["coins"] == 5000 - 5000
        assert _player_of(save)["inventory"]["items"]["xk01"] == 20 - 10

    def test_buying_an_expansion_without_the_keys_is_refused(self):
        """No hay llaves, no hay expansion: y no se cobran las coins."""
        world = _world()
        _player_of(world)["inventory"]["items"]["xk01"] = 3

        _, save = _call(empires_server.buy_item_response,
                        {"code": "x01", "amount": 1}, world)

        assert _resources_of(save)["coins"] == 5000
        assert _player_of(save)["inventory"]["items"]["xk01"] == 3

    def test_the_expansion_price_table_matches_the_expansion_item(self):
        """La fila 0 de `expansionTunedResourceCosts` es el precio de `x01`.

        Es la comprobacion cruzada que dice que el item y la tabla cuentan la
        misma historia: 5000 coins y 10 llaves.
        """
        item = game_settings.lookup_item_by_code("x01")
        row = game_settings.game_settings['settings']['expansionData'][
            'expansionTunedResourceCosts']['expansionTunedResourceCost'][0]

        assert int(item["cost"]["-coins"]) == int(row["-coins"])
        assert int(item["itemcost"]["-xk01"]) == int(row["-xk01"])

    def test_an_index_beyond_the_word_list_does_not_crash(self):
        """El mapa de bits tiene 11 palabras. Un indice fuera de rango no puede
        reventar la llamada."""
        response, _ = _call(empires_server.buy_expansion_response, {"index": 9999})

        assert response["errorType"] == 0

    def test_a_missing_index_does_not_crash(self):
        response, _ = _call(empires_server.buy_expansion_response, {})

        assert response["errorType"] == 0


class TestThePriceCatalogueIsTheSource:
    """El precio no lo inventa el servidor: lo lee del catalogo.

    Estos tests miran el catalogo directamente, asi que si alguien cambia
    `gameSettings` el test sigue siendo cierto.
    """

    def test_the_cash_price_of_a_resource_item_is_what_the_catalogue_says(self):
        item = game_settings.lookup_item_by_code("RS01")

        assert float(item["cost"]["-cash"]) == 13

    def test_the_contract_unlock_multiple_is_four(self):
        assert int(game_settings.game_settings['settings']['gamesettings'][
            '-contractUnlockMultiple']) == 4

    def test_the_unlock_item_costs_ten_cash(self):
        item = game_settings.lookup_item_by_code("UL2")

        assert float(item["cost"]["-cash"]) == 10

    def test_the_cheapest_resource_item_costs_what_we_charged(self):
        """La suma de los precios del catalogo tiene que ser la que el handler
        descuenta. Si el handler inventa un precio, esta suma no cuadra."""
        _, save = _call(empires_server.buy_item_response,
                        {"code": "RS01", "amount": 1})

        item = game_settings.lookup_item_by_code("RS01")
        assert _player_of(save)["cash"] == 1000 - math.ceil(float(item["cost"]["-cash"]))


class TestTheHandlersAreWired:
    """Un handler que existe pero no esta conectado no responde a nada.

    Ese fue el modo de fallo de `setCurrentCampaign`: una funcion que nadie
    llamaba, con un hueco invisible porque el fallback responde `errorType: 0`.
    """

    @pytest.mark.parametrize("method", [
        "UserService.buyItem",
        "UserService.buyItems",
        "UserService.useItem",
        "UserService.buyExpansion",
        "UserService.buyQuestTask",
        "UserService.purchaseContractUnlock",
        "UserService.purchaseEnergyRefill",
    ])
    def test_it_is_registered_on_the_dispatch_table(self, method):
        assert method in empires_server.AMF_HANDLERS
