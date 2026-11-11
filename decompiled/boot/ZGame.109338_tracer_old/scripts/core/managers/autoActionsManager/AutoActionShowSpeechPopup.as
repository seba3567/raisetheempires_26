package core.managers.autoActionsManager
{
   import core.ZGlobal;
   import core.managers.visitorManager.VisitorManager;
   import displays.popups.SpeechPopup;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import zlabs.managers.PopupManager;
   
   public class AutoActionShowSpeechPopup extends AutoAction
   {
      
      public function AutoActionShowSpeechPopup(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         if(!ZGlobal.isVisiting())
         {
            this.doPopup();
         }
         else
         {
            VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
         }
      }
      
      private function doPopup() : void
      {
         PopupManager.instance.push(new SpeechPopup(data.speechId,this.onSpeechClosed));
      }
      
      private function onSpeechClosed(param1:Event) : void
      {
         doDisableInput();
         startEndAction();
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(!ZGlobal.isVisiting())
         {
            VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
            this.doPopup();
         }
      }
   }
}

