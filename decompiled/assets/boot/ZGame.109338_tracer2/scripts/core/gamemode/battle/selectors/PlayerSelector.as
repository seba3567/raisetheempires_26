package core.gamemode.battle.selectors
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.ISelectionReceiver;
   import zlabs.events.WorldEvent;
   
   public class PlayerSelector extends BattleSelector
   {
      
      public function PlayerSelector(param1:ISelectionReceiver)
      {
         super(param1);
      }
      
      override public function init() : void
      {
         super.init();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_UNIT_CLICKED,this.onPlayerSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onConsumableSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_ALLY_CONSUMABLE_USED,this.onPlayerAllySelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_MERC_CONSUMABLE_USED,this.onPlayerMercSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,this.onPlayerOver);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onEnemyOver);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,{"active":true}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,true));
      }
      
      override public function dispose() : void
      {
         super.dispose();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_UNIT_CLICKED,this.onPlayerSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onConsumableSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_ALLY_CONSUMABLE_USED,this.onPlayerAllySelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_MERC_CONSUMABLE_USED,this.onPlayerMercSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,this.onPlayerOver);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onEnemyOver);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,{"active":false}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,false));
      }
      
      private function onPlayerSelected(param1:WorldEvent) : void
      {
         receiver.player = param1.eventData as BattleObject;
      }
      
      private function onPlayerOver(param1:WorldEvent) : void
      {
         receiver.playerOver = param1.eventData as BattleObject;
      }
      
      private function onEnemyOver(param1:WorldEvent) : void
      {
         receiver.enemyOver = param1.eventData as BattleObject;
      }
      
      private function onConsumableSelected(param1:WorldEvent) : void
      {
         receiver.consumable = param1.eventData.consumableItem;
      }
      
      private function onPlayerAllySelected(param1:WorldEvent) : void
      {
         receiver.ally = param1.eventData as String;
      }
      
      private function onPlayerMercSelected(param1:WorldEvent) : void
      {
         receiver.merc = param1.eventData as String;
      }
   }
}

