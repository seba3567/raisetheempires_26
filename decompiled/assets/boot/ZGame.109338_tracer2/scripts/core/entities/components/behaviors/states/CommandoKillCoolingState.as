package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CommandoManager;
   import entity.GameDataComponent;
   
   public class CommandoKillCoolingState extends SimpleAutoState
   {
      
      public function CommandoKillCoolingState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:int = 0;
         var _loc2_:GameDataComponent = null;
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
            if(CommandoManager.instance.isInited == false)
            {
               _loc2_ = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
               if(_loc2_)
               {
                  CommandoManager.instance.init(_loc2_,owner);
               }
            }
            if(CommandoManager.instance.isActivatedAgain())
            {
               CommandoManager.instance.setCurrentState(CommandoManager.STATE_COOLING,_loc1_);
            }
            else
            {
               stopProgressBar();
               switchToState(CommandoManager.STATE_ACCUMULATING.toString());
            }
         }
      }
   }
}

