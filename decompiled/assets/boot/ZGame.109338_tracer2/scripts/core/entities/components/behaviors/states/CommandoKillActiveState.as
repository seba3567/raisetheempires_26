package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CommandoManager;
   
   public class CommandoKillActiveState extends SimpleAutoState
   {
      
      public function CommandoKillActiveState(param1:BehaviorStateInit)
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
            CommandoManager.instance.setCurrentState(CommandoManager.STATE_ACTIVE,_loc1_);
         }
      }
   }
}

