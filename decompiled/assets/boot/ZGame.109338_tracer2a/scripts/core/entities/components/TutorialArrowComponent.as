package core.entities.components
{
   import core.entities.components.behaviors.states.DormantState;
   import core.managers.WorldObjectManager;
   import core.managers.tutorialManager.TutorialHighlighter;
   import core.managers.tutorialManager.TutorialManager;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class TutorialArrowComponent extends EntityComponent
   {
      
      private var m_arrow:TutorialHighlighter = null;
      
      private var m_active:Boolean = true;
      
      private var m_offset:Point = null;
      
      public function TutorialArrowComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         WorldObjectManager.instance.addEventListener(WorldObjectManager.ATTACH_ARROW,this.onAttachArrow);
         WorldObjectManager.instance.addEventListener(WorldObjectManager.CLEAR_ARROWS,this.onClearArrows);
         owner.eventDispatcher.addEventListener(DormantState.SLEEP,this.onSleep);
         owner.eventDispatcher.addEventListener(DormantState.AWAKE,this.onAwake);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.ATTACH_ARROW,this.onAttachArrow);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.CLEAR_ARROWS,this.onClearArrows);
         owner.eventDispatcher.removeEventListener(DormantState.SLEEP,this.onSleep);
         owner.eventDispatcher.removeEventListener(DormantState.AWAKE,this.onAwake);
         this.dispose();
      }
      
      private function onAttachArrow(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:IsoSpriteRenderer = null;
         if(this.m_active)
         {
            _loc2_ = GameDataComponent(owner.lookupComponentByType(GameDataComponent));
            if(param1.eventData.codes.indexOf(_loc2_.gameData.code) >= 0)
            {
               if(param1.eventData.offset)
               {
                  this.m_offset = param1.eventData.offset;
               }
               _loc3_ = owner.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
               if(_loc3_.displayObject.width > 0)
               {
                  this.onImageUpdated(null);
               }
               else
               {
                  owner.eventDispatcher.addEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onImageUpdated,false,0,true);
               }
            }
         }
      }
      
      private function onImageUpdated(param1:Event) : void
      {
         if(null != param1)
         {
            owner.eventDispatcher.removeEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onImageUpdated);
         }
         if(!TutorialManager.instance.arrowActive)
         {
            return;
         }
         var _loc2_:IsoSpriteRenderer = owner.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
         this.m_arrow = new TutorialHighlighter();
         this.m_arrow.setMovieClip(_loc2_.displayObject as MovieClip,true,true,false,this.m_offset);
      }
      
      private function onClearArrows(param1:Event) : void
      {
         this.dispose();
      }
      
      private function onSleep(param1:Event) : void
      {
         this.dispose();
         this.m_active = false;
      }
      
      private function onAwake(param1:Event) : void
      {
         this.m_active = true;
      }
      
      private function dispose() : void
      {
         if(null != this.m_arrow)
         {
            this.m_arrow.dispose();
            this.m_arrow = null;
         }
         this.m_offset = null;
      }
   }
}

