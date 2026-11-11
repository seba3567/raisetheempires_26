package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IState;
   import displays.popups.SpeechPopup;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   
   public class EspionageHQSpeechClickState extends SimpleClickState
   {
      
      public function EspionageHQSpeechClickState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(m_data.@speechId != undefined)
         {
            PopupManager.instance.push(new SpeechPopup(m_data.@speechId,this.onSpeechPopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
         }
         else
         {
            clickNextState();
         }
      }
      
      protected function onSpeechPopupClosed(param1:Event) : void
      {
         clickNextState();
         Zlab.processManager.schedule(500,this,this.showEspionageHQScreen);
      }
      
      private function showEspionageHQScreen() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         var _loc1_:IState = stateMachine.currentState;
         if(Boolean(_loc1_) && _loc1_ is EspionageHQDialogState)
         {
            EspionageHQDialogState(_loc1_).showEspionageHQScreen();
         }
      }
   }
}

