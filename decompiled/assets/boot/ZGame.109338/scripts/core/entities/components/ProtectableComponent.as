package core.entities.components
{
   import core.managers.PVPManager;
   import core.ui.feedbacktext.ProtectedFeedbackText;
   import zlabs.events.WorldEvent;
   
   public class ProtectableComponent extends ObjectHighlightComponent
   {
      
      public static const DEFENSE_ACTIVATED:String = "defenseActivated";
      
      public static const DEFENSE_DEACTIVATED:String = "defenseDeactivated";
      
      public function ProtectableComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(DEFENSE_ACTIVATED,this.onDefenseActivated,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(DEFENSE_ACTIVATED,this.onDefenseActivated);
         PVPManager.instance.removeEventListener(DEFENSE_DEACTIVATED,this.onDefenseDeactivated);
         cleanupTextFields();
      }
      
      private function onDefenseActivated(param1:WorldEvent) : void
      {
         PVPManager.instance.addEventListener(DEFENSE_DEACTIVATED,this.onDefenseDeactivated,false,0,true);
         this.updateFeedback(true);
      }
      
      private function onDefenseDeactivated(param1:WorldEvent) : void
      {
         PVPManager.instance.removeEventListener(DEFENSE_DEACTIVATED,this.onDefenseDeactivated);
         this.updateFeedback(false);
      }
      
      private function updateFeedback(param1:Boolean) : void
      {
         var _loc2_:String = UIControllerComponent.EVENT_FILTER_EFFECT;
         if(param1)
         {
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc2_,UIControllerComponent.FILTER_EFFECT_PROTECTED_ON));
            removeFeedback();
            addFeedback(new ProtectedFeedbackText());
         }
         else
         {
            removeFeedback();
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc2_,UIControllerComponent.FILTER_EFFECT_PROTECTED_OFF));
         }
      }
   }
}

