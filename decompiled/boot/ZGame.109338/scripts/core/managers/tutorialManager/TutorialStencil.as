package core.managers.tutorialManager
{
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.ui.UIManager;
   import core.ui.menuitem.MenuItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import events.IsoViewEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BitmapDataChannel;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.filters.BitmapFilter;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.BlurFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class TutorialStencil extends MenuItem
   {
      
      public static const ITEM_ID:String = "tutorialStencil";
      
      private var m_container:Bitmap;
      
      private var m_stencilObject:DisplayObject;
      
      private var m_circleOffset:Point = null;
      
      private var m_circleMod:Number = 1;
      
      private var MAX_BITMAP_SIZE:int = 2800;
      
      public function TutorialStencil()
      {
         super(ITEM_ID);
         this.m_container = new Bitmap();
         this.m_container.smoothing = true;
         this.mouseEnabled = false;
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onViewChanged,false,0,true);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
         TutorialManager.instance.addEventListener(TutorialManager.ADD_STENCIL,this.onAddStencil);
         TutorialManager.instance.addEventListener(TutorialManager.REMOVE_STENCIL,this.onRemoveStencil);
      }
      
      public static function getTutorialStencil() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(TutorialStencil.ITEM_ID);
      }
      
      public function dispose() : void
      {
         Zlab.inputManager.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onViewChanged);
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onViewChanged);
         Zlab.mainStage.removeEventListener(Event.RESIZE,this.onReposition);
         removeEventListener(TutorialManager.ADD_STENCIL,this.onAddStencil);
         removeEventListener(TutorialManager.REMOVE_STENCIL,this.onRemoveStencil);
         if(Boolean(this.m_stencilObject) && Boolean(this.m_container))
         {
            if(this.m_stencilObject.parent)
            {
               this.m_stencilObject.parent.removeChild(this.m_container);
            }
            this.m_stencilObject = null;
            this.m_container = null;
            ZGlobal.stencilActive = false;
         }
      }
      
      private function onAddStencil(param1:WorldEvent) : void
      {
         UIManager.instance.disableMouse(param1.eventData.disableChildren);
         this.m_stencilObject = param1.eventData.obj;
         var _loc2_:Boolean = false;
         if(param1.eventData.offset)
         {
            this.m_circleOffset = param1.eventData.offset;
         }
         if(param1.eventData.modifier)
         {
            this.m_circleMod = param1.eventData.modifier;
         }
         this.drawStencil();
      }
      
      private function onRemoveStencil(param1:WorldEvent) : void
      {
         if(this.m_stencilObject)
         {
            removeChild(this.m_container);
            this.m_stencilObject = null;
            ZGlobal.stencilActive = false;
         }
         this.m_circleOffset = null;
         this.m_circleMod = 1;
         UIManager.instance.enableMouse();
      }
      
      private function drawStencil() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:IsoViewComponent = null;
         var _loc4_:Number = NaN;
         var _loc5_:BitmapData = null;
         var _loc6_:BitmapData = null;
         var _loc7_:Point = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Sprite = null;
         var _loc12_:BitmapFilter = null;
         if(!this.m_circleOffset)
         {
            this.m_circleOffset = new Point(0,0);
         }
         if(this.m_stencilObject)
         {
            ZGlobal.stencilActive = true;
            _loc1_ = Zlab.mainStage.stageWidth;
            _loc2_ = Zlab.mainStage.stageHeight;
            _loc3_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc4_ = _loc3_.currentZoom;
            _loc5_ = new BitmapData(_loc1_,_loc1_,true,255);
            _loc6_ = new BitmapData(_loc1_,_loc1_,true,301989887);
            _loc5_.floodFill(0,0,0);
            _loc7_ = ZGameUtils.localToLocal(this.m_stencilObject,this);
            _loc8_ = this.m_stencilObject.width * _loc4_ * this.m_circleMod;
            _loc9_ = _loc7_.x * _loc4_ + this.m_circleOffset.x * _loc4_;
            _loc10_ = _loc7_.y * _loc4_ + this.m_circleOffset.y * _loc4_;
            _loc11_ = new Sprite();
            _loc11_.graphics.clear();
            _loc11_.graphics.beginFill(16711680);
            _loc11_.graphics.drawCircle(_loc9_,_loc10_,_loc8_);
            _loc11_.graphics.endFill();
            _loc6_.draw(_loc11_);
            _loc5_.copyChannel(_loc6_,_loc5_.rect,new Point(0,0),BitmapDataChannel.BLUE,BitmapDataChannel.ALPHA);
            _loc12_ = new BlurFilter(2,2,BitmapFilterQuality.HIGH);
            _loc5_.applyFilter(_loc5_,new Rectangle(0,0,_loc1_,_loc2_),new Point(),_loc12_);
            this.m_container.bitmapData = _loc5_;
            this.m_container.scaleX = 1 / _loc4_;
            this.m_container.scaleY = 1 / _loc4_;
            this.m_container.alpha = 0.5;
            addChild(this.m_container);
         }
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.drawStencil();
      }
      
      private function onReposition(param1:Event) : void
      {
         this.drawStencil();
      }
      
      private function onViewChanged(param1:Event) : void
      {
         this.drawStencil();
      }
   }
}

