package core.entities.components
{
   import core.managers.PVPManager;
   import core.ui.feedbacktext.ProtectorFeedbackText;
   import zlabs.events.WorldEvent;
   
   public class ProtectorComponent extends ObjectHighlightComponent
   {
      
      public static const PROTECTOR_ACTIVATED:String = "protectorActivated";
      
      public static const PROTECTOR_DEACTIVATED:String = "protectorDeactivated";
      
      public function ProtectorComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(PROTECTOR_ACTIVATED,this.onDefenseActivated,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(PROTECTOR_ACTIVATED,this.onDefenseActivated);
         PVPManager.instance.removeEventListener(PROTECTOR_DEACTIVATED,this.onDefenseDeactivated);
         cleanupTextFields();
      }
      
      private function onDefenseActivated(param1:WorldEvent) : void
      {
         PVPManager.instance.addEventListener(PROTECTOR_DEACTIVATED,this.onDefenseDeactivated,false,0,true);
         this.updateFeedback(true);
      }
      
      private function onDefenseDeactivated(param1:WorldEvent) : void
      {
         PVPManager.instance.removeEventListener(PROTECTOR_DEACTIVATED,this.onDefenseDeactivated);
         this.updateFeedback(false);
      }
      
      private function updateFeedback(param1:Boolean) : void
      {
         var _loc2_:String = UIControllerComponent.EVENT_FILTER_EFFECT;
         if(param1)
         {
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc2_,UIControllerComponent.FILTER_EFFECT_PROTECTOR_ON));
            removeFeedback();
            addFeedback(new ProtectorFeedbackText());
         }
         else
         {
            removeFeedback();
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc2_,UIControllerComponent.FILTER_EFFECT_PROTECTOR_OFF));
         }
      }
   }
}

