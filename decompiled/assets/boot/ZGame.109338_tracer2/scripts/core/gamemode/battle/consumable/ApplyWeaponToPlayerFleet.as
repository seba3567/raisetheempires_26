package core.gamemode.battle.consumable
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import zlabs.events.WorldEvent;
   
   public class ApplyWeaponToPlayerFleet extends ApplyWeaponToFleet
   {
      
      public function ApplyWeaponToPlayerFleet(param1:ConsumableItem, param2:BattleObject, param3:Boolean)
      {
         super(param1,param2,param3);
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
      
      override protected function unitSelected(param1:BattleObject) : Boolean
      {
         if(super.unitSelected(param1))
         {
            this.modifyEventListeners(false);
            return true;
         }
         return false;
      }
      
      private function modifyEventListeners(param1:Boolean) : void
      {
         if(param1)
         {
            BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_UNIT_CLICKED,onUnitSelected);
         }
         else
         {
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_UNIT_CLICKED,onUnitSelected);
         }
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,{
            "active":param1,
            "consumable":true
         }));
      }
   }
}

