package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CommandoManager;
   import displays.popups.CommandoKillDialog;
   import zlabs.managers.WindowManager;
   
   public class CommandoKillDialogState extends DialogState
   {
      
      public function CommandoKillDialogState(param1:BehaviorStateInit)
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
            CommandoManager.instance.setCurrentState(CommandoManager.STATE_ACCUMULATING,_loc1_);
         }
      }
      
      override protected function showDialog() : void
      {
         WindowManager.instance.push(new CommandoKillDialog(this));
      }
      
      public function done() : void
      {
         clicked();
      }
   }
}

