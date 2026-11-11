package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.DroneCommandManager;
   
   public class DroneCommandCooldownState extends SimpleAutoState
   {
      
      public function DroneCommandCooldownState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:int = 0;
         if(!m_startTime)
         {
            _loc1_ = GlobalEngine.serverTime / 1000;
         }
         else
         {
            _loc1_ = m_startTime / 1000;
         }
         super.performEnterActions();
         if(!ZGlobal.isVisiting())
         {
            DroneCommandManager.instance.setCurrentState(DroneCommandManager.STATE_COOLING,_loc1_);
         }
      }
   }
}

