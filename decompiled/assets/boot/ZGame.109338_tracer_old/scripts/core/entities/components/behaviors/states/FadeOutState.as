package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gamemode.GMSell;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class FadeOutState extends SimpleAutoState
   {
      
      private var m_clientOnlyClear:Boolean;
      
      public function FadeOutState(param1:BehaviorStateInit)
      {
         if(param1.m_stateData.@clientOnlyClear)
         {
            this.m_clientOnlyClear = param1.m_stateData.@clientOnlyClear.toString() == "true";
         }
         super(param1);
      }
      
      protected function setAlpha(param1:Number) : void
      {
         var _loc2_:IsoSpriteRenderer = IsoSpriteRenderer(IEntity(stateMachine.propertyBag).lookupComponentByType(IsoSpriteRenderer));
         _loc2_.displayObject.alpha = param1;
      }
      
      override protected function onProgress(param1:Number) : void
      {
         super.onProgress(param1);
         this.setAlpha(1 - param1);
      }
      
      override protected function onProgressComplete() : void
      {
         GMSell.clearObject(owner,this.m_clientOnlyClear);
      }
   }
}

