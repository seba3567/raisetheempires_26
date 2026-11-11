package core.entities.components
{
   import core.entities.components.behaviors.states.DecoBuildableDefenseState;
   import core.entities.components.behaviors.states.DefenseTowerDialogState;
   import core.managers.PVPManager;
   import core.ui.feedbacktext.AreaProtectorFeedbackText;
   import zlabs.events.WorldEvent;
   
   public class AreaProtectorComponent extends ObjectHighlightComponent
   {
      
      public function AreaProtectorComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(ProtectorComponent.PROTECTOR_ACTIVATED,this.onDefenseActivated,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(ProtectorComponent.PROTECTOR_ACTIVATED,this.onDefenseActivated);
         PVPManager.instance.removeEventListener(ProtectorComponent.PROTECTOR_DEACTIVATED,this.onDefenseDeactivated);
         cleanupTextFields();
      }
      
      private function onDefenseActivated(param1:WorldEvent) : void
      {
         var _loc8_:DecoBuildableDefenseState = null;
         PVPManager.instance.addEventListener(ProtectorComponent.PROTECTOR_DEACTIVATED,this.onDefenseDeactivated,false,0,true);
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(owner.lookupComponentByType(BuildingFSMComponent));
         var _loc3_:DefenseTowerDialogState = _loc2_.stateMachine.getCurrentState() as DefenseTowerDialogState;
         var _loc4_:Boolean = false;
         if(!_loc3_)
         {
            _loc8_ = _loc2_.stateMachine.getCurrentState() as DecoBuildableDefenseState;
            _loc4_ = (Boolean(_loc8_)) && _loc8_.canProtectAlways();
         }
         var _loc5_:Boolean = Boolean(_loc3_) && _loc3_.isActive();
         var _loc6_:Boolean = Boolean(param1.eventData) && param1.eventData.validity == PVPManager.OCCUPATION_VALID_PROTECTED_AREA;
         var _loc7_:Boolean = Boolean(param1.eventData) && param1.eventData.validity == PVPManager.OCCUPATION_VALID_PROTECTED_BUILDING;
         this.updateFeedback((_loc5_ || _loc4_) && _loc6_ && !_loc7_,false);
      }
      
      private function onDefenseDeactivated(param1:WorldEvent) : void
      {
         PVPManager.instance.removeEventListener(ProtectorComponent.PROTECTOR_DEACTIVATED,this.onDefenseDeactivated);
         this.updateFeedback(false,false);
      }
      
      private function updateFeedback(param1:Boolean, param2:Boolean) : void
      {
         removeFeedback();
         if(param1)
         {
            addFeedback(new AreaProtectorFeedbackText());
         }
         var _loc3_:String = UIControllerComponent.EVENT_FILTER_EFFECT;
         if(param2)
         {
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_ON));
         }
         else
         {
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_OFF));
         }
      }
   }
}

