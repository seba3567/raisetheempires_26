package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import displays.popups.SpeechPopup;
   import zlabs.managers.PopupManager;
   
   public class SpeechAutoState extends SimpleAutoState
   {
      
      public function SpeechAutoState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function autoNextState() : void
      {
         if(m_data.@speechName != undefined)
         {
            PopupManager.instance.push(new SpeechPopup(m_data.@speechName),0,true,false);
         }
         super.autoNextState();
      }
   }
}

