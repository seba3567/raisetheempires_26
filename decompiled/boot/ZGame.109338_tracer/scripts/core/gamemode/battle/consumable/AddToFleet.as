package core.gamemode.battle.consumable
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import zlabs.events.WorldEvent;
   
   public class AddToFleet implements IConsumableEffect
   {
      
      private var m_consumable:ConsumableItem = null;
      
      private var m_ally:Boolean = false;
      
      private var m_playerTurn:Boolean = false;
      
      public function AddToFleet(param1:ConsumableItem, param2:Boolean)
      {
         super();
         this.m_consumable = param1;
         this.m_ally = param2;
      }
      
      public function init(param1:Boolean) : void
      {
         this.m_playerTurn = param1;
      }
      
      public function update() : Boolean
      {
         return false;
      }
      
      public function dispose() : void
      {
         this.m_consumable = null;
      }
      
      protected function get ally() : Boolean
      {
         return this.m_ally;
      }
      
      protected function onUnitSelected(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = param1.eventData as BattleObject;
         if(_loc2_.fleet.addConsumable(this.m_consumable.code,_loc2_.unit.id,this.m_ally,this.m_playerTurn,_loc2_))
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONTINUE_FROM_CONSUMABLE,this.m_consumable));
         }
      }
   }
}

