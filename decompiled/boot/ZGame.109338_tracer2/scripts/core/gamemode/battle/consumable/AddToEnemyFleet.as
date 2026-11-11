package core.gamemode.battle.consumable
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.ConsumableItem;
   import zlabs.events.WorldEvent;
   
   public class AddToEnemyFleet extends AddToFleet
   {
      
      public function AddToEnemyFleet(param1:ConsumableItem, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function init(param1:Boolean) : void
      {
         this.modifyEventListeners(true);
         super.init(param1);
      }
      
      override public function dispose() : void
      {
         this.modifyEventListeners(false);
         super.dispose();
      }
      
      override protected function onUnitSelected(param1:WorldEvent) : void
      {
         this.modifyEventListeners(false);
         super.onUnitSelected(param1);
      }
      
      private function modifyEventListeners(param1:Boolean) : void
      {
         if(param1)
         {
            BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onUnitSelected);
         }
         else
         {
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onUnitSelected);
         }
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,param1));
      }
   }
}

