package zlabs.core
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FullScreenEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.system.Security;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class InputManager extends EventDispatcher implements ITickedObject
   {
      
      public static const MOUSE_LEAVE:String = "im_mouseleave";
      
      protected static var m_disableMutex:int = 0;
      
      protected static var m_disableButtonMutex:int = 0;
      
      private var _keyState:Array;
      
      private var _keyStateOld:Array;
      
      private var _justPressed:Array;
      
      private var _justReleased:Array;
      
      public function InputManager()
      {
         this._keyState = new Array();
         this._keyStateOld = new Array();
         this._justPressed = new Array();
         this._justReleased = new Array();
         super();
         Security.allowDomain("*","*.zynga.com");
         Zlab.mainStage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         Zlab.mainStage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         Zlab.mainStage.tabChildren = false;
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("onMouseWheel",this.onExternalMouseWheel);
               ExternalInterface.addCallback("onMouseLeave",this.onExternalMouseLeave);
            }
         }
         catch(e:Error)
         {
         }
         Zlab.processManager.addTickedObject(this,Number.MAX_VALUE);
      }
      
      public static function get enabled() : Boolean
      {
         return m_disableMutex == 0;
      }
      
      public static function enableInput() : void
      {
         --m_disableMutex;
         m_disableMutex = Math.max(m_disableMutex,0);
      }
      
      public static function disableInput() : void
      {
         ++m_disableMutex;
      }
      
      public static function enableButtonInput() : void
      {
         --m_disableButtonMutex;
         m_disableButtonMutex = Math.max(m_disableButtonMutex,0);
      }
      
      public static function disableButtonInput() : void
      {
         ++m_disableButtonMutex;
      }
      
      public function setupListeners() : void
      {
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onScreenEvent);
      }
      
      public function onScreenEvent(param1:Event) : void
      {
         var _loc3_:IWindow = null;
         var _loc4_:IWindow = null;
         if(WindowManager.instance.isInitialized())
         {
            for each(_loc3_ in WindowManager.instance.windows)
            {
               _loc3_.centerWithinStage(Zlab.mainStage);
            }
         }
         if(PopupManager.instance.isInitialized())
         {
            for each(_loc4_ in PopupManager.instance.windows)
            {
               _loc4_.centerWithinStage(Zlab.mainStage);
            }
         }
         var _loc2_:Boolean = WindowManager.isFullScreen();
         dispatchEvent(new FullScreenEvent(FullScreenEvent.FULL_SCREEN,false,false,_loc2_));
      }
      
      protected function onExternalMouseWheel(param1:int) : void
      {
         this.onMouseWheel(new MouseEvent(MouseEvent.MOUSE_WHEEL,true,false,0,0,null,false,false,false,false,param1));
      }
      
      protected function onExternalMouseLeave(param1:Object = null) : void
      {
         dispatchEvent(new Event(MOUSE_LEAVE));
         if(param1)
         {
            Logger.info(this,"onExternalMouseLeave","got a param!");
         }
      }
      
      public function onTick(param1:Number) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this._keyState.length)
         {
            if(Boolean(this._keyState[_loc2_]) && !this._keyStateOld[_loc2_])
            {
               this._justPressed[_loc2_] = true;
            }
            else
            {
               this._justPressed[_loc2_] = false;
            }
            if(!this._keyState[_loc2_] && Boolean(this._keyStateOld[_loc2_]))
            {
               this._justReleased[_loc2_] = true;
            }
            else
            {
               this._justReleased[_loc2_] = false;
            }
            this._keyStateOld[_loc2_] = this._keyState[_loc2_];
            _loc2_++;
         }
      }
      
      public function keyJustPressed(param1:int) : Boolean
      {
         return this._justPressed[param1];
      }
      
      public function keyJustReleased(param1:int) : Boolean
      {
         return this._justReleased[param1];
      }
      
      public function isKeyDown(param1:int) : Boolean
      {
         return this._keyState[param1];
      }
      
      public function isAnyKeyDown() : Boolean
      {
         var _loc1_:Boolean = false;
         for each(_loc1_ in this._keyState)
         {
            if(_loc1_)
            {
               return true;
            }
         }
         return false;
      }
      
      public function simulateKeyDown(param1:int) : void
      {
         dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,param1));
         this._keyState[param1] = true;
      }
      
      public function simulateKeyUp(param1:int) : void
      {
         dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP,true,false,0,param1));
         this._keyState[param1] = false;
      }
      
      public function simulateMouseDown() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
      }
      
      public function simulateMouseUp() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
      }
      
      public function simulateMouseMove() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE,true,false,Math.random() * 100,Math.random() * 100));
      }
      
      public function simulateMouseOver() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
      }
      
      public function simulateMouseOut() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
      }
      
      public function simulateMouseWheel() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL));
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(this._keyState[param1.keyCode])
         {
            return;
         }
         this._keyState[param1.keyCode] = true;
         dispatchEvent(param1);
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         this._keyState[param1.keyCode] = false;
         dispatchEvent(param1);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(m_disableMutex == 0 && m_disableButtonMutex == 0)
         {
            dispatchEvent(param1);
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(m_disableMutex == 0 && m_disableButtonMutex == 0)
         {
            dispatchEvent(param1);
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         if(m_disableMutex == 0)
         {
            dispatchEvent(param1);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(m_disableMutex == 0)
         {
            dispatchEvent(param1);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(m_disableMutex == 0)
         {
            dispatchEvent(param1);
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         if(m_disableMutex == 0)
         {
            dispatchEvent(param1);
         }
      }
   }
}

