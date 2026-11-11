package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.ExperimentsManager;
   import flash.events.Event;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class PurchaseState extends BehaviorState
   {
      
      public static const PURCHASED:String = "purchased";
      
      public function PurchaseState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         stateMachine.propertyBag.eventDispatcher.addEventListener(PURCHASED,this.onPurchased);
         this.setSpriteAlpha(param1,0.5);
      }
      
      override public function exit(param1:IMachine) : void
      {
         super.exit(param1);
         this.removeListeners();
         this.setSpriteAlpha(param1,1);
      }
      
      private function setSpriteAlpha(param1:IMachine, param2:Number) : void
      {
         var _loc3_:IsoSpriteRenderer = IsoSpriteRenderer(IEntity(param1.propertyBag).lookupComponentByType(IsoSpriteRenderer));
         _loc3_.displayObject.alpha = param2;
      }
      
      private function onPurchased(param1:Event) : void
      {
         clickNextState();
      }
      
      override protected function shouldSendSetStateTransaction() : Boolean
      {
         return false;
      }
      
      override protected function removeListeners() : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(PURCHASED,this.onPurchased);
      }
      
      override protected function get defaultClickNextStateIndex() : String
      {
         var _loc1_:String = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_ENERGYPINCH_STRUCTUREBUILDCLICKINCREASE) == ExperimentsManager.VARIANT_ENERGYPINCH_STRUCTUREBUILDCLICKINCREASE_ENABLED)
         {
            _loc1_ = m_data.@variableBuildNext.toString();
            if(Boolean(_loc1_) && Boolean(_loc1_.length))
            {
               return _loc1_;
            }
         }
         return super.defaultClickNextStateIndex;
      }
   }
}

