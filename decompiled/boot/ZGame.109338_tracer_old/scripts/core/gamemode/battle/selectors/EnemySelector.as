package core.gamemode.battle.selectors
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.ISelectionReceiver;
   import zlabs.events.WorldEvent;
   
   public class EnemySelector extends BattleSelector
   {
      
      public function EnemySelector(param1:ISelectionReceiver)
      {
         super(param1);
      }
      
      override public function init() : void
      {
         super.init();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onEnemySelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onEnemyOver);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,this.onEnemyOver);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,true));
      }
      
      override public function dispose() : void
      {
         super.dispose();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onEnemySelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onEnemyOver);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,this.onEnemyOver);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,false));
      }
      
      private function onEnemySelected(param1:WorldEvent) : void
      {
         receiver.enemy = param1.eventData as BattleObject;
      }
      
      private function onEnemyOver(param1:WorldEvent) : void
      {
         receiver.enemyOver = param1.eventData as BattleObject;
      }
   }
}

