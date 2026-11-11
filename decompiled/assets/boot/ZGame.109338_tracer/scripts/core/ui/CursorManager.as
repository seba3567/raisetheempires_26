package core.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   
   public class CursorManager extends EventDispatcher
   {
      
      private static var instance:CursorManager;
      
      private static var cursorBitmap:Bitmap;
      
      private static var keys:Dictionary;
      
      public static const SHOW_CURSOR:String = "showCursor";
      
      public static const HIDE_CURSOR:String = "hideCursor";
      
      protected static var m_cursors:Array = [];
      
      protected static var m_currentCursor:Object = null;
      
      private static var count:int = 1;
      
      private static var disabledCursor:Boolean = false;
      
      private static var m_enabled:Boolean = true;
      
      public function CursorManager()
      {
         super();
      }
      
      public static function initialize() : void
      {
         Zlab.inputManager.addEventListener(SHOW_CURSOR,onEnableCursor,false,0,true);
         Zlab.inputManager.addEventListener(HIDE_CURSOR,onEnableCursor,false,0,true);
         keys = new Dictionary(true);
      }
      
      public static function loadCursor(param1:String, param2:String = "") : void
      {
      }
      
      public static function hasCursor(param1:int) : Boolean
      {
         var _loc4_:Object = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < m_cursors.length)
         {
            _loc4_ = m_cursors[_loc3_];
            if(_loc4_.id == param1)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function getCurrentCursor() : Object
      {
         return m_currentCursor;
      }
      
      public static function setCursorByID(param1:String) : void
      {
      }
      
      public static function setCursor(param1:Object, param2:Boolean = false) : int
      {
         var _loc3_:DisplayObject = null;
         if(!param1)
         {
            return 0;
         }
         if(param1 is DisplayObject)
         {
            _loc3_ = param1 as DisplayObject;
         }
         else if(param1 is Class)
         {
            _loc3_ = new param1();
         }
         else if(param1 is BitmapData)
         {
            _loc3_ = new Bitmap(param1 as BitmapData);
         }
         var _loc4_:int = count++;
         var _loc5_:Object = {
            "displayObj":_loc3_,
            "id":_loc4_,
            "keepSystemCursor":param2
         };
         m_cursors.push(_loc5_);
         updateCurrentCursor();
         return int(_loc5_.id);
      }
      
      public static function removeCursor(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < m_cursors.length)
         {
            _loc3_ = m_cursors[_loc2_];
            if(_loc3_.id == param1)
            {
               m_cursors.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         updateCurrentCursor();
      }
      
      public static function removeAllCursors() : void
      {
         m_cursors.length = 0;
         updateCurrentCursor();
      }
      
      public static function updateCurrentCursor(param1:Boolean = false) : void
      {
         if(!m_enabled)
         {
            return;
         }
         var _loc2_:Object = null;
         if(Boolean(m_cursors.length) && !disabledCursor)
         {
            _loc2_ = m_cursors[m_cursors.length - 1];
            if(Boolean(_loc2_.keepSystemCursor) || _loc2_.displayObj == null)
            {
               Mouse.show();
            }
            else
            {
               Mouse.hide();
            }
            Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove,false,10,true);
         }
         else
         {
            Mouse.show();
            Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
         }
         if(_loc2_ != m_currentCursor || param1)
         {
            if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj))
            {
               if(m_currentCursor.displayObj.parent)
               {
                  m_currentCursor.displayObj.parent.removeChild(m_currentCursor.displayObj);
               }
            }
            m_currentCursor = _loc2_;
            if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj))
            {
               m_currentCursor.displayObj.x = Zlab.mainStage.mouseX;
               m_currentCursor.displayObj.y = Zlab.mainStage.mouseY;
               Zlab.mainStage.addChild(m_currentCursor.displayObj);
            }
         }
      }
      
      public static function getInstance(param1:DisplayObject = null) : CursorManager
      {
         if(CursorManager.instance == null)
         {
            CursorManager.instance = new CursorManager();
         }
         return CursorManager.instance;
      }
      
      public static function subscribe(param1:DisplayObject, param2:Object = null, param3:Object = null) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc4_:CursorManager = getInstance(param1);
         _loc4_.addTargetProps(param1,param2,param3);
         param1.addEventListener(MouseEvent.ROLL_OVER,_loc4_.showCursor,false,0,true);
         param1.addEventListener(MouseEvent.ROLL_OUT,_loc4_.hideCursor,false,0,true);
      }
      
      public static function unsubscribe(param1:DisplayObject) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:CursorManager = getInstance(param1);
         param1.removeEventListener(MouseEvent.ROLL_OVER,_loc2_.showCursor);
         param1.removeEventListener(MouseEvent.ROLL_OUT,_loc2_.hideCursor);
         param1.removeEventListener(Event.MOUSE_LEAVE,_loc2_.hideCursor);
      }
      
      public static function onEnableCursor(param1:Event) : void
      {
         enabled = param1.type == SHOW_CURSOR;
      }
      
      public static function set enabled(param1:Boolean) : void
      {
         m_enabled = param1;
         if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj))
         {
            if(param1)
            {
               updateCurrentCursor(true);
            }
            else
            {
               Mouse.show();
               if(Zlab.inputManager.hasEventListener(MouseEvent.MOUSE_MOVE))
               {
                  Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
               }
               if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj.parent))
               {
                  m_currentCursor.displayObj.parent.removeChild(m_currentCursor.displayObj);
               }
            }
         }
      }
      
      public static function get enabled() : Boolean
      {
         return m_enabled;
      }
      
      public static function onStageMouseMove(param1:MouseEvent) : void
      {
         if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj))
         {
            m_currentCursor.displayObj.x = Zlab.mainStage.mouseX;
            m_currentCursor.displayObj.y = Zlab.mainStage.mouseY;
            param1.updateAfterEvent();
         }
      }
      
      private function addTargetProps(param1:DisplayObject, param2:Object = null, param3:Object = null) : void
      {
         var _loc4_:int = count++;
         var _loc5_:Object = {
            "target":param1,
            "id":_loc4_,
            "cursor":param2,
            "options":param3
         };
         keys[param1] = _loc5_;
      }
      
      private function getProps(param1:DisplayObject) : Object
      {
         return keys[param1];
      }
      
      private function showCursor(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         var _loc3_:Object = CursorManager.instance.getProps(_loc2_);
         if(_loc3_ != null)
         {
            if(_loc3_.cursor == "")
            {
               Logger.info(this,"showCursor","subscibed item wants regular cursor");
            }
         }
         disabledCursor = true;
         updateCurrentCursor(true);
      }
      
      private function hideCursor(param1:Event) : void
      {
         disabledCursor = false;
         updateCurrentCursor(true);
      }
   }
}

import flash.display.DisplayObject;

final class CursorObject
{
   
   public var displayObj:DisplayObject;
   
   public var id:Object;
   
   public var keepSystemCursor:Boolean;
   
   public function CursorObject(param1:DisplayObject, param2:Object, param3:Boolean = false)
   {
      super();
      this.displayObj = param1;
      this.id = param2;
      this.keepSystemCursor = param3;
   }
}
