package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CommandoManager;
   import dispatchers.UIDispatcher;
   import displays.screens.commando.CommandoDialog;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class CommandoKillActivateDialogState extends DialogState
   {
      
      public static const SHOW_COMMANDO_DIALOG:String = "SHOW_COMMANDO_DIALOG";
      
      public function CommandoKillActivateDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(Boolean(param1.m_gameItem) && param1.m_gameItem.code.length > 0)
         {
            UIDispatcher.instance.addEventListener(SHOW_COMMANDO_DIALOG,this.showDialogEvent);
         }
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
            CommandoManager.instance.setCurrentState(CommandoManager.STATE_READY,_loc1_);
         }
      }
      
      private function showDialogEvent(param1:WorldEvent) : void
      {
         if(Boolean(stateMachine.currentStateName) && Boolean(stateMachine.states[stateMachine.currentStateName]) && stateMachine.states[stateMachine.currentStateName] is CommandoKillActivateDialogState)
         {
            this.showDialog();
            UIDispatcher.instance.removeEventListener(SHOW_COMMANDO_DIALOG,this.showDialogEvent);
         }
      }
      
      override protected function showDialog() : void
      {
         WindowManager.instance.push(new CommandoDialog(this));
      }
      
      public function done() : void
      {
         clicked();
      }
   }
}

