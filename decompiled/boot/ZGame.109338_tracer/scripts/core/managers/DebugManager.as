package core.managers
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import com.greensock.TweenMax;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.UI;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.UIDispatcher;
   import events.MarketEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import rendering.renderingIso.QuadTreeLayoutRenderer;
   import zlabs.Zlab;
   import zlabs.core.InputKey;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class DebugManager
   {
      
      public static var instance:DebugManager = new DebugManager();
      
      public static const DEBUG_PLACEITEM:String = "placeitem";
      
      public static const DEBUG_MULTIITEM:String = "placemulti";
      
      public static const DEBUG_OVERLAYS:String = "overlays";
      
      public static const DEBUG_ABCOMBAT:String = "abcombat";
      
      public static const DEBUG_3DWORLD:String = "3dworld";
      
      public static const DEBUG_CAMPAIGNDEBUG:String = "campaigndebug";
      
      private var m_textField:TextField = null;
      
      private var m_mouseWorldPos:Pt = new Pt(0,0,0);
      
      private var m_mouseTilePos:Pt = new Pt(0,0,0);
      
      private var m_screenPos:Pt = new Pt(0,0,0);
      
      private var m_active:Boolean = false;
      
      private var m_multiPlaceActive:Boolean = false;
      
      private var m_overlays:Boolean = true;
      
      private var m_abCombat:Boolean = true;
      
      private var m_3Dworld:Boolean = false;
      
      private var m_highlightedObject:String = "";
      
      private var m_campaignDebug:Boolean = false;
      
      private var m_togglePoolfx:Boolean = true;
      
      public function DebugManager()
      {
         super();
         UIDispatcher.instance.addEventListener("toggleDebugText",this.onToggleDebugText);
         UIDispatcher.instance.addEventListener(DEBUG_PLACEITEM,this.onDebugPlaceItem);
         UIDispatcher.instance.addEventListener(DEBUG_MULTIITEM,this.onDebugMultiItem);
         UIDispatcher.instance.addEventListener(DEBUG_OVERLAYS,this.onDebugOverlays);
         UIDispatcher.instance.addEventListener(DEBUG_ABCOMBAT,this.onToggleABCombat);
         UIDispatcher.instance.addEventListener(DEBUG_3DWORLD,this.onToggle3DWorld);
         UIDispatcher.instance.addEventListener(DEBUG_CAMPAIGNDEBUG,this.onToggleCampaignDebug);
         UIDispatcher.instance.addEventListener(ZGlobal.LOW_QUALITY_MODE,this.onLowQualityToggle);
         Zlab.inputManager.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
      }
      
      public function get campaignDebug() : Boolean
      {
         return this.m_campaignDebug;
      }
      
      public function togglePoolfx() : Boolean
      {
         this.m_togglePoolfx = !this.m_togglePoolfx;
         return this.m_togglePoolfx;
      }
      
      public function get poolfx() : Boolean
      {
         return this.m_togglePoolfx;
      }
      
      public function register() : void
      {
         this.m_active = false;
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == InputKey.UP.keyCode)
         {
            this.m_multiPlaceActive = true;
            Logger.info(this,"onDebugPlaceItem","active: " + this.m_multiPlaceActive);
         }
         else if(param1.keyCode == InputKey.DOWN.keyCode)
         {
            this.m_multiPlaceActive = false;
            Logger.info(this,"onDebugPlaceItem","active: " + this.m_multiPlaceActive);
         }
      }
      
      private function onToggleCampaignDebug(param1:Event) : void
      {
         this.m_campaignDebug = !this.m_campaignDebug;
         Logger.info(this,"campaignDebugInfo","active: " + this.m_campaignDebug);
      }
      
      private function onToggleDebugText(param1:Event) : void
      {
         this.m_active = !this.m_active;
         if(this.m_active)
         {
            this.createText();
            Zlab.mainStage.addChild(this.m_textField);
            Zlab.mainStage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         }
         else
         {
            this.m_textField.parent.removeChild(this.m_textField);
            Zlab.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         }
      }
      
      private function onDebugMultiItem(param1:Event) : void
      {
         this.m_multiPlaceActive = !this.m_multiPlaceActive;
         Logger.info(this,"onDebugPlaceItem","active: " + this.m_multiPlaceActive);
      }
      
      private function onDebugOverlays(param1:WorldEvent) : void
      {
         this.m_overlays = param1.eventData;
         Logger.info(this,"onDebugOverlays","active: " + this.m_overlays);
      }
      
      private function onLowQualityToggle(param1:WorldEvent) : void
      {
         Logger.info(this,"onLowQualityToggle","low quality mode: " + ZGlobal.lowQualityMode);
      }
      
      private function onToggleABCombat(param1:Event) : void
      {
         this.m_abCombat = !this.m_abCombat;
         Logger.info(this,"onToggleABCombat","active: " + this.m_abCombat);
      }
      
      private function onToggle3DWorld(param1:Event) : void
      {
         this.m_3Dworld = !this.m_3Dworld;
         Logger.info(this,"onToggle3DWorld","active: " + this.m_3Dworld);
      }
      
      public function get multiPlaceActive() : Boolean
      {
         return this.m_multiPlaceActive;
      }
      
      public function get overlaysActive() : Boolean
      {
         return this.m_overlays;
      }
      
      public function get abCombatActive() : Boolean
      {
         return this.m_abCombat;
      }
      
      public function get world3DActive() : Boolean
      {
         return this.m_3Dworld;
      }
      
      public function set highlightedObject(param1:String) : void
      {
         this.m_highlightedObject = param1;
      }
      
      public function flashDump() : void
      {
         this.dump(Zlab.mainStage);
      }
      
      private function dump(param1:DisplayObjectContainer) : void
      {
         var _loc2_:uint = 0;
         if(param1)
         {
            if(!(param1 is Stage) && param1.mouseEnabled)
            {
               param1.mouseEnabled = false;
            }
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               this.dump(param1.getChildAt(_loc2_) as DisplayObjectContainer);
               _loc2_++;
            }
         }
      }
      
      private function onDebugPlaceItem(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(String(param1.eventData),GameItem) as GameItem;
         if(_loc2_ != null)
         {
            UI.instance.setupForItemPlacement();
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_USE,MarketEvent.BUILDABLE,String(param1.eventData),MarketEvent.SOURCE_INVENTORY));
         }
         else
         {
            Logger.warn(this,"onDebugPlaceItem","can\'t find item: " + String(param1.eventData));
         }
      }
      
      private function createText() : void
      {
         if(this.m_textField == null)
         {
            this.m_textField = new TextField();
            this.m_textField.selectable = false;
            this.m_textField.mouseEnabled = false;
            this.m_textField.text = "";
            this.m_textField.x = 50;
            this.m_textField.textColor = 16777215;
            this.m_textField.y = 170;
            this.m_textField.width = Zlab.mainStage.stageWidth;
            this.m_textField.height = Zlab.mainStage.stageHeight;
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         this.m_screenPos = new Pt(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc3_:IsoScene = IsoScene(_loc2_.getSceneByID("gameScene"));
         var _loc4_:Point = _loc3_.container.globalToLocal(this.m_screenPos);
         this.m_mouseWorldPos = IsoMath.screenToIso(new Pt(_loc4_.x,_loc4_.y,0));
         this.m_mouseTilePos = MathUtils.worldToTile(this.m_mouseWorldPos,ZGlobal.cellSize);
         this.updateText();
      }
      
      private function getExpansionIndex(param1:int, param2:int) : int
      {
         param1 /= 4;
         param2 /= 4;
         var _loc3_:int = 112 / 8;
         var _loc4_:int = param2 - param2 % 2;
         var _loc5_:int = _loc4_ * _loc3_ / 2;
         return int(_loc5_ + param1 / 2);
      }
      
      private function updateText() : void
      {
         if(this.m_active)
         {
            this.m_textField.text = "Mouse world pos = " + int(this.m_mouseWorldPos.x) + "," + int(this.m_mouseWorldPos.y) + "\n" + "Mouse tile pos  = " + int(this.m_mouseTilePos.x) + "," + int(this.m_mouseTilePos.y) + "\n" + "Screen pos  = " + int(this.m_screenPos.x) + "," + int(this.m_screenPos.y) + "\n" + "Visible objects = " + QuadTreeLayoutRenderer.getVisibleObjectCount() + "\n" + "Highlighted object = " + this.m_highlightedObject + "\n" + "Expansion index = " + this.getExpansionIndex(this.m_mouseTilePos.x,this.m_mouseTilePos.y) + "\n" + "Tweens max = " + TweenMax.getAllTweens().length + "\n" + "reserv energy = " + ZGlobal.player.m_energy.reservedEnergy + "\n";
         }
      }
   }
}

