package core.gamemode.battle.consumable
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import zlabs.events.WorldEvent;
   
   public class BattleAllyConsumable extends BattleConsumable
   {
      
      private var m_group:Array = null;
      
      public function BattleAllyConsumable(param1:ConsumableItem, param2:BattleObject, param3:Boolean, param4:Array)
      {
         this.m_group = param4;
         super(param1,param2,param3);
      }
      
      override protected function get ally() : Boolean
      {
         return true;
      }
      
      override protected function createEffect(param1:ConsumableItem, param2:BattleObject, param3:Boolean) : void
      {
         var _loc6_:String = null;
         super.createEffect(param1,param2,param3);
         var _loc4_:BattleObject = this.m_group[0];
         var _loc5_:int = _loc4_.fleet.getRandomLiveUnitIndexFromFleet(param1.heals);
         for each(_loc4_ in this.m_group)
         {
            if(_loc4_.unit.id == _loc5_)
            {
               _loc6_ = param1.targetsEnemy ? BattleDispatcher.ENEMY_UNIT_CLICKED : BattleDispatcher.PLAYER_UNIT_CLICKED;
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(_loc6_,_loc4_));
               break;
            }
         }
      }
   }
}

