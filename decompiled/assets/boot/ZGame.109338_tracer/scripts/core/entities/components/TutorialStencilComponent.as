package core.entities.components
{
   import core.entities.components.behaviors.states.DormantState;
   import core.managers.WorldObjectManager;
   import core.managers.tutorialManager.TutorialManager;
   import entity.GameDataComponent;
   import flash.events.Event;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class TutorialStencilComponent extends EntityComponent
   {
      
      private var m_active:Boolean = true;
      
      public function TutorialStencilComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         WorldObjectManager.instance.addEventListener(WorldObjectManager.ATTACH_STENCIL,this.onAttachStencil);
         WorldObjectManager.instance.addEventListener(WorldObjectManager.CLEAR_STENCIL,this.onClearStencil);
         owner.eventDispatcher.addEventListener(DormantState.SLEEP,this.onSleep);
         owner.eventDispatcher.addEventListener(DormantState.AWAKE,this.onAwake);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.ATTACH_STENCIL,this.onAttachStencil);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.CLEAR_STENCIL,this.onClearStencil);
         owner.eventDispatcher.removeEventListener(DormantState.SLEEP,this.onSleep);
         owner.eventDispatcher.removeEventListener(DormantState.AWAKE,this.onAwake);
         this.onClearStencil(null);
      }
      
      private function onAttachStencil(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:IsoSpriteRenderer = null;
         var _loc4_:Number = NaN;
         if(this.m_active)
         {
            _loc2_ = GameDataComponent(owner.lookupComponentByType(GameDataComponent));
            if(param1.eventData.code.indexOf(_loc2_.gameData.code) >= 0)
            {
               _loc3_ = owner.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
               if(_loc3_.displayObject.width > 0)
               {
                  _loc4_ = 1;
                  if(param1.eventData.mod)
                  {
                     _loc4_ = Number(param1.eventData.mod);
                  }
                  this.attachStencil(_loc4_);
               }
            }
         }
      }
      
      private function attachStencil(param1:Number) : void
      {
         var _loc2_:IsoSpriteRenderer = owner.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ADD_STENCIL,{
            "obj":_loc2_.displayObject,
            "modifier":param1
         }));
      }
      
      private function onClearStencil(param1:Event) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.REMOVE_STENCIL));
      }
      
      private function onSleep(param1:Event) : void
      {
         this.onClearStencil(null);
         this.m_active = false;
      }
      
      private function onAwake(param1:Event) : void
      {
         this.m_active = true;
      }
   }
}

