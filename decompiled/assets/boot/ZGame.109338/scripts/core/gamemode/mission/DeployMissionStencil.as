package core.gamemode.mission
{
   import core.gamemode.GameModeManager;
   import core.ui.UIManager;
   import core.ui.menuitem.MenuItem;
   import dispatchers.UIDispatcher;
   import events.IsoViewEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BitmapDataChannel;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.filters.BitmapFilter;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.BlurFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class DeployMissionStencil extends MenuItem
   {
      
      public static const ITEM_ID:String = "deployMissionStencil";
      
      public static const ADD_DEPLOY_STENCIL:String = "addDeployStencil";
      
      public static const REMOVE_DEPLOY_STENCIL:String = "removeDeployStencil";
      
      private var m_container:Bitmap;
      
      private var m_active:Boolean = false;
      
      private var m_borderTop:Number = 100;
      
      private var m_borderBottom:Number = 150;
      
      private var m_borderLeft:Number = 100;
      
      private var m_borderRight:Number = 100;
      
      private var MAX_BITMAP_SIZE:int = 2800;
      
      public function DeployMissionStencil()
      {
         super(ITEM_ID);
         this.m_container = new Bitmap();
         this.m_container.smoothing = true;
         this.mouseEnabled = false;
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onViewChanged,false,0,true);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
         UIDispatcher.instance.addEventListener(DeployMissionStencil.ADD_DEPLOY_STENCIL,this.onAddStencil);
         UIDispatcher.instance.addEventListener(DeployMissionStencil.REMOVE_DEPLOY_STENCIL,this.onRemoveStencil);
      }
      
      public static function getDeployMissionStencil() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(DeployMissionStencil.ITEM_ID);
      }
      
      public function dispose() : void
      {
         Zlab.inputManager.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onViewChanged);
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onViewChanged);
         Zlab.mainStage.removeEventListener(Event.RESIZE,this.onReposition);
         UIDispatcher.instance.removeEventListener(DeployMissionStencil.ADD_DEPLOY_STENCIL,this.onAddStencil);
         UIDispatcher.instance.removeEventListener(DeployMissionStencil.REMOVE_DEPLOY_STENCIL,this.onRemoveStencil);
         if(this.m_container)
         {
            if(this.m_container.parent != null)
            {
               this.m_container.parent.removeChild(this.m_container);
            }
            this.m_container = null;
         }
      }
      
      private function onAddStencil(param1:WorldEvent) : void
      {
         UIManager.instance.disableMouse(false);
         var _loc2_:Boolean = false;
         this.m_active = true;
         this.drawStencil();
      }
      
      private function onRemoveStencil(param1:WorldEvent) : void
      {
         if(this.m_active)
         {
            if(this.m_container.parent != null)
            {
               this.m_container.parent.removeChild(this.m_container);
            }
         }
         this.m_active = false;
         UIManager.instance.enableMouse();
      }
      
      private function drawStencil() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:BitmapData = null;
         var _loc4_:BitmapData = null;
         var _loc5_:Sprite = null;
         var _loc6_:BitmapFilter = null;
         if(this.m_active)
         {
            _loc1_ = Zlab.mainStage.stageWidth;
            _loc2_ = Zlab.mainStage.stageHeight;
            _loc3_ = new BitmapData(_loc1_,_loc2_,true,255);
            _loc4_ = new BitmapData(_loc1_,_loc2_,true,301989887);
            _loc3_.floodFill(0,0,0);
            _loc5_ = new Sprite();
            _loc5_.graphics.clear();
            _loc5_.graphics.beginFill(16711680);
            _loc5_.graphics.drawRoundRect(this.m_borderLeft,this.m_borderTop,_loc1_ - this.m_borderRight * 2,_loc2_ - this.m_borderBottom * 2,100);
            _loc5_.graphics.endFill();
            _loc4_.draw(_loc5_);
            _loc3_.copyChannel(_loc4_,_loc3_.rect,new Point(0,0),BitmapDataChannel.BLUE,BitmapDataChannel.ALPHA);
            _loc6_ = new BlurFilter(60,60,BitmapFilterQuality.HIGH);
            _loc3_.applyFilter(_loc3_,new Rectangle(0,0,_loc1_,_loc2_),new Point(),_loc6_);
            this.m_container.bitmapData = _loc3_;
            this.m_container.alpha = 0.8;
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

