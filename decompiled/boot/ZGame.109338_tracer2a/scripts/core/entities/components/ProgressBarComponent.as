package core.entities.components
{
   import as3isolib.display.IsoView;
   import as3isolib.geom.Pt;
   import core.entities.BuildingFinishProgressBar;
   import core.entities.ContractProgressBar;
   import core.entities.DynamicProgressBar;
   import core.entities.IDynamicProgressBar;
   import core.gamemode.GameModeManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import events.IsoViewEvent;
   import events.ProgressBarEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import zlabs.core.ObjectPool;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class ProgressBarComponent extends EntityComponent
   {
      
      protected var m_progressBar:IDynamicProgressBar;
      
      protected var m_sprite:Sprite = new Sprite();
      
      public var volumeProperty:PropertyReference = null;
      
      public var gameDataProperty:PropertyReference = null;
      
      private var m_referenceItem:String = null;
      
      private var m_scale:Number = 1;
      
      private var m_visible:Boolean = true;
      
      public function ProgressBarComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         owner.eventDispatcher.addEventListener(ProgressBarEvent.START_PROGRESS_BAR,this.onShowProgressBar,false,0,true);
         owner.eventDispatcher.addEventListener(ProgressBarEvent.PROGRESS_BAR_ICON,this.onIconUpdated,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite,false,0,true);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         var _loc1_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         this.m_scale = 1 / _loc1_.currentZoom;
      }
      
      private function allocateBar(param1:int) : void
      {
         var _loc2_:Class = this.getClass(param1);
         if(Boolean(this.m_progressBar) && !(this.m_progressBar is _loc2_))
         {
            this.m_referenceItem = this.m_progressBar.referenceItem;
            this.disposeProgressBar();
         }
         if(null == this.m_progressBar)
         {
            this.m_progressBar = ObjectPool.instance.getObject(_loc2_);
            this.m_progressBar.referenceItem = this.m_referenceItem;
            this.m_progressBar.ownerGameItem = owner.getProperty(this.gameDataProperty);
            this.m_referenceItem = null;
            this.m_progressBar.scaleX = this.m_progressBar.scaleY = this.m_scale;
            this.m_progressBar.visible = this.m_visible;
            this.setBarPosition();
         }
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         if(param1.value <= 0.25)
         {
            if(null != this.m_progressBar)
            {
               this.m_progressBar.visible = false;
            }
            else
            {
               this.m_visible = false;
            }
         }
         else if(null != this.m_progressBar)
         {
            this.m_progressBar.scaleX = this.m_progressBar.scaleY = 1 / param1.value;
            this.setBarPosition();
            this.m_progressBar.visible = true;
         }
         else
         {
            this.m_visible = true;
            this.m_scale = 1 / param1.value;
         }
      }
      
      private function onIconUpdated(param1:ProgressBarEvent) : void
      {
         if(this.m_progressBar != null)
         {
            this.m_progressBar.referenceItem = param1.message;
         }
         else
         {
            this.m_referenceItem = param1.message;
         }
      }
      
      private function setBarPosition() : void
      {
         var _loc1_:IsoViewComponent = null;
         var _loc2_:IsoView = null;
         var _loc3_:BuildingSpatialComponent = null;
         var _loc4_:Pt = null;
         if(this.m_progressBar)
         {
            if(this.m_progressBar.displaysOverUI)
            {
               _loc1_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
               _loc2_ = _loc1_.isoView;
               _loc3_ = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
               _loc4_ = Pt.toPt(_loc3_.position);
               _loc2_.isoToLocal(_loc4_);
               this.m_progressBar.x = _loc4_.x + this.m_progressBar.UIDisplayOffsetX;
               this.m_progressBar.y = _loc4_.y + this.m_progressBar.UIDisplayOffsetY;
            }
            else
            {
               this.m_progressBar.setPosition(this.getXOffset(),this.getYOffset());
               this.m_progressBar.x += this.m_sprite.parent.x + this.m_sprite.x;
               this.m_progressBar.y += this.m_sprite.parent.y + this.m_sprite.y;
            }
         }
      }
      
      protected function onShowProgressBar(param1:ProgressBarEvent) : void
      {
         var _loc2_:IsoViewComponent = null;
         var _loc3_:IsoView = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:DisplayObject = null;
         if(param1.type == ProgressBarEvent.START_PROGRESS_BAR)
         {
            if(null != this.m_sprite.parent)
            {
               this.allocateBar(param1.barType);
               owner.eventDispatcher.addEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onShowProgressBar,false,0,true);
               owner.eventDispatcher.addEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onUpdateProgressBar,false,0,true);
               if(this.m_progressBar.displaysOverUI)
               {
                  _loc2_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
                  _loc3_ = _loc2_.isoView;
                  _loc3_.foregroundContainer.addChild(DisplayObject(this.m_progressBar));
                  _loc4_ = this.m_progressBar.parent.numChildren;
                  if(_loc4_ > 1)
                  {
                     _loc5_ = _loc4_ - 1;
                     this.m_progressBar.parent.setChildIndex(DisplayObject(this.m_progressBar),_loc5_);
                  }
               }
               else
               {
                  this.m_sprite.parent.parent.addChild(DisplayObject(this.m_progressBar));
               }
            }
         }
         else
         {
            owner.eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onShowProgressBar);
            owner.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onUpdateProgressBar);
            _loc6_ = DisplayObject(this.m_progressBar);
            _loc6_.parent.removeChild(_loc6_);
         }
      }
      
      protected function getXOffset() : Number
      {
         return 0;
      }
      
      private function disposeProgressBar() : void
      {
         if(null != this.m_progressBar)
         {
            if(this.m_progressBar.parent)
            {
               DisplayObject(this.m_progressBar).parent.removeChild(DisplayObject(this.m_progressBar));
            }
            ObjectPool.instance.disposeObject(this.m_progressBar);
            this.m_progressBar = null;
         }
      }
      
      protected function getYOffset() : Number
      {
         var _loc1_:Number = 0;
         if(owner.getProperty(this.volumeProperty))
         {
            _loc1_ = Number(owner.getProperty(this.volumeProperty).z);
         }
         return _loc1_;
      }
      
      protected function onUpdateProgressBar(param1:ProgressBarEvent) : void
      {
         this.m_progressBar.updateProgressBarPercentage(param1.message,param1.progress);
      }
      
      override protected function onRemove() : void
      {
         owner.eventDispatcher.removeEventListener(ProgressBarEvent.START_PROGRESS_BAR,this.onShowProgressBar);
         owner.eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onShowProgressBar);
         owner.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onUpdateProgressBar);
         owner.eventDispatcher.removeEventListener(ProgressBarEvent.PROGRESS_BAR_ICON,this.onIconUpdated);
         owner.eventDispatcher.removeEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite);
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         this.disposeProgressBar();
         super.onRemove();
      }
      
      public function get sprite() : Sprite
      {
         return this.m_sprite;
      }
      
      private function getClass(param1:int) : Class
      {
         if(param1 == ProgressBarEvent.TYPE_HOMECONTRACT)
         {
            return ContractProgressBar;
         }
         if(param1 == ProgressBarEvent.TYPE_FINISHBUILDING)
         {
            return BuildingFinishProgressBar;
         }
         return DynamicProgressBar;
      }
      
      private function onUpdateSprite(param1:Event) : void
      {
         if(Boolean(this.m_progressBar) && this.m_progressBar.displaysOverUI)
         {
            this.setBarPosition();
         }
      }
   }
}

