package core.worlds.battleWorld.megaUnit
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.UnitItem;
   import core.managers.FXManager.FXManager;
   import core.managers.animationManager.FireAndForgetAnimation;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleUnit;
   import core.worlds.battleWorld.BattleWorld;
   import zlabs.events.WorldEvent;
   
   public class MegaUnitState
   {
      
      private var m_unit:BattleUnit = null;
      
      public function MegaUnitState(param1:BattleUnit)
      {
         super();
         this.m_unit = param1;
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
      }
      
      public function dispose() : void
      {
         this.m_unit = null;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
      }
      
      public function startRemovalTimer(param1:BattleObject, param2:int) : Boolean
      {
         var _loc3_:Boolean = this.isFleetDead(param1);
         var _loc4_:Boolean = param1.unitItem.hasType(UnitItem.MEGA_UNIT_CONTROLLER);
         if(_loc3_ || !_loc4_)
         {
            if(_loc3_)
            {
               if(_loc4_)
               {
                  this.playControllerDeathFX(param2);
               }
               else
               {
                  this.removeController(param1,param2);
               }
            }
            return true;
         }
         return false;
      }
      
      private function removeController(param1:BattleObject, param2:int) : void
      {
         var _loc3_:BattleObject = null;
         for each(_loc3_ in param1.group)
         {
            if(_loc3_.unitItem.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
            {
               this.playControllerDeathFX(param2);
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_REMOVED,{"battleObject":_loc3_}));
               break;
            }
         }
      }
      
      private function playControllerDeathFX(param1:int) : void
      {
         var _loc2_:String = "TacticalNukeCast";
         var _loc3_:Object = new Object();
         _loc3_.anim = FXManager.instance.getFXAnim(_loc2_);
         _loc3_.sound = FXManager.instance.getFXSound(_loc2_);
         var _loc4_:BattleRendererComponent = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
         _loc3_.anchor = _loc4_.getSidePosition(param1);
         FireAndForgetAnimation.execute2D(_loc4_.getSurface(param1),_loc3_);
      }
      
      private function isFleetDead(param1:BattleObject) : Boolean
      {
         return !param1.fleet.units || param1.fleet.units.length == 0 || param1.fleet.getStrengthPercentage() == 0;
      }
      
      private function onUnitKilled(param1:WorldEvent) : void
      {
         if(Boolean(this.m_unit) && Boolean(param1.eventData.target.unitItem.hasType(UnitItem.MEGA_UNIT_CONTROLLER)))
         {
            if(!this.isFleetDead(param1.eventData.target))
            {
               this.m_unit.recalculateAnimations();
            }
         }
      }
   }
}

