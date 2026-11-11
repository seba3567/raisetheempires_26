package core.ui
{
   import core.gamemode.GameModeManager;
   import core.ui.menuitem.MenuItem;
   import dispatchers.UIDispatcher;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import zlabs.Zlab;
   
   public class UIManager extends MenuItem
   {
      
      private static var _instance:UIManager;
      
      public static const ITEM_ID:String = "UIManager";
      
      public static const UI_MOUSE_DOWN:String = "uiMouseDown";
      
      public static const UI_MOUSE_CLICK:String = "uiMouseClick";
      
      public static const UI_START_MUSIC:String = "uistartmusic";
      
      public static const UI_ENABLE_COMBAT_PAUSE_RETREAT:String = "enablePauseRetreat";
      
      public var screenParent:DisplayObjectContainer = null;
      
      public function UIManager()
      {
         super(ITEM_ID);
         this.screenParent = Zlab.mainClass;
         _uiDisplayObject = new Sprite();
         _uiDisplayObject.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         _uiDisplayObject.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this.onDragStop(null);
         _uiDisplayObject.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         _uiDisplayObject.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         GameModeManager.instance.addEventListener(GameModeManager.DRAGSTART,this.onDragStart,false,0,true);
         GameModeManager.instance.addEventListener(GameModeManager.DRAGSTOP,this.onDragStop,false,0,true);
         m_menuItems = new Dictionary();
      }
      
      public static function get instance() : UIManager
      {
         if(!_instance)
         {
            _instance = new UIManager();
         }
         return _instance;
      }
      
      public function disableMouse(param1:Boolean = false) : void
      {
         this.uiDisplay.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.uiDisplay.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.uiDisplay.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.uiDisplay.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.uiDisplay.mouseEnabled = false;
         if(param1)
         {
            this.uiDisplay.mouseChildren = false;
         }
      }
      
      public function enableMouse() : void
      {
         this.uiDisplay.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.uiDisplay.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this.uiDisplay.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this.uiDisplay.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         this.uiDisplay.mouseEnabled = true;
         this.uiDisplay.mouseChildren = true;
      }
      
      private function onMouseDown(param1:Event) : void
      {
         UIDispatcher.instance.dispatchEvent(new Event(UI_MOUSE_DOWN));
         this.onCaptureEvent(param1);
      }
      
      private function onClick(param1:Event) : void
      {
         UIDispatcher.instance.dispatchEvent(new Event(UI_MOUSE_CLICK));
      }
      
      private function onMouseOver(param1:Event) : void
      {
         GameModeManager.instance.getTopGameMode().overUI = true;
      }
      
      private function onMouseOut(param1:Event) : void
      {
         GameModeManager.instance.getTopGameMode().overUI = false;
      }
      
      private function onCaptureEvent(param1:Event) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
      }
      
      private function onDragStart(param1:Event) : void
      {
         _uiDisplayObject.removeEventListener(MouseEvent.MOUSE_MOVE,this.onCaptureEvent);
         _uiDisplayObject.removeEventListener(MouseEvent.MOUSE_UP,this.onCaptureEvent);
      }
      
      private function onDragStop(param1:Event) : void
      {
         _uiDisplayObject.addEventListener(MouseEvent.MOUSE_MOVE,this.onCaptureEvent,false,0,true);
         _uiDisplayObject.addEventListener(MouseEvent.MOUSE_UP,this.onCaptureEvent,false,0,true);
      }
      
      public function getMenuItemByName(param1:String) : MenuItem
      {
         return m_menuItems[param1];
      }
      
      public function registerComponent(param1:MenuItem, param2:int = 0) : MenuItem
      {
         m_menuItems[param1.id] = param1;
         param1.uiParent = this;
         _uiDisplayObject.addChild(param1);
         return param1;
      }
      
      public function removeMenuItem(param1:Class) : void
      {
         var _loc2_:String = getQualifiedClassName(param1);
         if(m_menuItems[_loc2_])
         {
            m_menuItems[_loc2_].removeItem();
            m_menuItems[_loc2_] = null;
            delete m_menuItems[_loc2_];
         }
      }
      
      public function get uiDisplay() : Sprite
      {
         return _uiDisplayObject;
      }
   }
}

