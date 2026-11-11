package rendering.renderingIso
{
   import as3isolib.display.IsoView;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.views.ViewManager;
   import events.IsoViewEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.geom.Rectangle;
   import rendering.scroller.BackgroundScroller;
   import zlabs.components.AnimatedComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class SceneImageBlitComponent extends AnimatedComponent
   {
      
      public static var BLIT_FORCE_UPDATE:String = "blitCompBlitForceUpdate";
      
      public static var BLIT_UPDATE:String = "blitCompBiltUpdate";
      
      public var isoViewPropRef:PropertyReference = null;
      
      public var isoViewRectPropRef:PropertyReference = null;
      
      public var blitting:Boolean = true;
      
      private var m_blittingStage:Sprite = new Sprite();
      
      private var isInvalidated:Boolean = false;
      
      private var m_blittingRect:Rectangle;
      
      private var m_backgroundScroller:BackgroundScroller;
      
      public function SceneImageBlitComponent()
      {
         super();
      }
      
      public function get blittingStage() : Sprite
      {
         return this.m_blittingStage;
      }
      
      public function addBlittedItem(param1:DisplayObject) : void
      {
         this.m_blittingStage.addChild(param1);
      }
      
      override protected function onReset() : void
      {
         super.onReset();
         if(this.blitting)
         {
            this.m_backgroundScroller.reset();
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         var _loc1_:IsoView = owner.getProperty(this.isoViewPropRef);
         this.isInvalidated = true;
         var _loc2_:DisplayObjectContainer = _loc1_.backgroundContainer;
         if(this.blitting)
         {
            this.m_backgroundScroller = new BackgroundScroller(2972807,6);
            this.m_backgroundScroller.init(20480,10240,4);
            this.m_backgroundScroller.x = -(20480 * 0.5);
            this.m_backgroundScroller.imageToRender(this.m_blittingStage);
            _loc2_.addChildAt(this.m_backgroundScroller,0);
            owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onShow,false,0,true);
            owner.eventDispatcher.addEventListener(FullScreenEvent.FULL_SCREEN,this.onUpdateBlit,false,0,true);
            owner.eventDispatcher.addEventListener(BLIT_FORCE_UPDATE,this.onUpdateForceBlit,false,0,true);
            owner.eventDispatcher.addEventListener(BLIT_UPDATE,this.onUpdateBlit,false,0,true);
            owner.eventDispatcher.addEventListener(IsoViewComponent.UPDATE_VIEW,this.onUpdateBlit,false,0,true);
         }
         else
         {
            _loc2_.addChild(this.m_blittingStage);
            this.registerForUpdates = false;
         }
      }
      
      protected function onShow(param1:Event) : void
      {
         this.onScrollStage(true);
      }
      
      override protected function onRemove() : void
      {
         this.m_backgroundScroller.dispose();
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_PAN,this.onUpdateBlit);
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onUpdateBlit);
         owner.eventDispatcher.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onUpdateBlit);
         owner.eventDispatcher.removeEventListener(BLIT_FORCE_UPDATE,this.onUpdateForceBlit);
         owner.eventDispatcher.removeEventListener(BLIT_UPDATE,this.onUpdateBlit);
      }
      
      public function onUpdateForceBlit(param1:Event) : void
      {
         this.onScrollStage(true);
      }
      
      private function onUpdateBlit(param1:Event = null) : void
      {
         this.onScrollStage();
      }
      
      private function getCurrentViewRect() : Rectangle
      {
         var _loc1_:Rectangle = owner.getProperty(this.isoViewRectPropRef);
         _loc1_.inflate(ZGlobal.cellSize,ZGlobal.cellSize);
         return _loc1_;
      }
      
      public function onScrollStage(param1:Boolean = false) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:IsoView = null;
         if(this.blitting)
         {
            _loc2_ = this.getCurrentViewRect();
            _loc3_ = owner.getProperty(this.isoViewPropRef);
            _loc2_.width /= _loc3_.currentZoom;
            _loc2_.height /= _loc3_.currentZoom;
            this.m_backgroundScroller.onScrollRect(_loc2_,param1);
         }
      }
      
      private function renderFrame() : void
      {
      }
   }
}

