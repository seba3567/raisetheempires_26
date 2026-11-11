package zlabs.managers
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FullScreenEvent;
   import flash.utils.getQualifiedClassName;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.debug.Logger;
   import zlabs.displays.cinema.ICinematic;
   import zlabs.displays.popups.IWindow;
   import zlabs.displays.zflex.ZCanvas;
   import zlabs.events.WorldEvent;
   
   public class WindowManager extends EventDispatcher
   {
      
      private static var _instance:WindowManager;
      
      public static const SHOW_SCREEN:String = "ShowScreen";
      
      public static const HIDE_SCREEN:String = "HideScreen";
      
      public static const LAST_HIDE_SCREEN:String = "LastHideScreen";
      
      private static var m_block_all_popups:Boolean = false;
      
      protected var m_container:ZCanvas;
      
      protected var m_windows:Array = new Array();
      
      protected var m_queue:Array = new Array();
      
      protected var m_delayedWindows:Array = new Array();
      
      protected var m_loadedWindows:Array = new Array();
      
      public var windowParent:DisplayObjectContainer = null;
      
      private var m_cinema:ICinematic;
      
      public function WindowManager()
      {
         super();
         this.m_container = new ZCanvas();
         this.m_container.backgroundColor = 0;
         this.m_container.backgroundAlpha = 0.5;
         this.m_container.mouseEnabled = true;
         this.m_container.useHandCursor = false;
      }
      
      public static function get instance() : WindowManager
      {
         if(!_instance)
         {
            _instance = new WindowManager();
         }
         return _instance;
      }
      
      public static function blockAllPopups() : void
      {
         m_block_all_popups = true;
      }
      
      public static function setFullScreen(param1:Boolean) : void
      {
         var fullscreen:Boolean = param1;
         if(Zlab.mainStage)
         {
            try
            {
               if(fullscreen)
               {
                  Zlab.mainStage.displayState = StageDisplayState.FULL_SCREEN;
               }
               else
               {
                  Zlab.mainStage.displayState = StageDisplayState.NORMAL;
               }
            }
            catch(err:SecurityError)
            {
               Logger.error(WindowManager.instance,"setFullScreen","SecurityError: " + err.message);
            }
            Logger.info(WindowManager.instance,"setFullScreen","Toggling Fullscreen, DisplayState: " + Zlab.mainStage.displayState.toString());
         }
      }
      
      public static function isFullScreen() : Boolean
      {
         return Zlab.mainStage.displayState == StageDisplayState.FULL_SCREEN;
      }
      
      public static function toggleFullScreen() : void
      {
         setFullScreen(isFullScreen() == false);
      }
      
      public function isInitialized() : Boolean
      {
         return this.windowParent != null;
      }
      
      public function initialize(param1:DisplayObjectContainer) : void
      {
         this.windowParent = param1;
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
      }
      
      public function get container() : Sprite
      {
         return this.m_container as Sprite;
      }
      
      public function get containerCanvas() : ZCanvas
      {
         return this.m_container;
      }
      
      public function get windows() : Array
      {
         return this.m_windows;
      }
      
      public function get displayedWindow() : IWindow
      {
         if(this.m_windows.length > 0)
         {
            return this.m_windows[this.m_windows.length - 1];
         }
         return null;
      }
      
      public function notifyLoadComplete(param1:IWindow) : void
      {
         if(this.getDelayedWindowsIndex(param1) > -1)
         {
            return;
         }
         var _loc2_:IWindow = this.displayedWindow;
         if(_loc2_ == param1 || _loc2_ == null)
         {
            param1.onShow();
         }
         else if(this.m_loadedWindows.indexOf(param1) < 0)
         {
            this.m_loadedWindows.push(param1);
         }
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.m_container.contentWidth = Zlab.mainStage.stageWidth;
         this.m_container.contentHeight = Zlab.mainStage.stageHeight;
      }
      
      public function push(param1:IWindow, param2:int = 0, param3:Boolean = false, param4:Boolean = true, param5:Boolean = false) : void
      {
         var _loc6_:IWindow = null;
         param1.setManagerToNotifyOnLoad(this);
         Logger.print(WindowManager,"push(): " + param3 + " window: " + getQualifiedClassName(param1));
         if(param2 > 0)
         {
            this.m_delayedWindows.push({
               "window":param1,
               "addToQueue":param3
            });
            Zlab.processManager.schedule(param2,this,this.delayedPopUp,param1);
         }
         else if(param3 && this.m_windows.length > 0 || this.m_delayedWindows.length > 0 && param5)
         {
            this.m_queue.push({
               "window":param1,
               "delay":param2,
               "addToQueue":param3,
               "stall":param4,
               "waitOnDelayedWindows":param5
            });
         }
         else
         {
            param1.setManager(this);
            param1.eventDispatcher.addEventListener(Event.COMPLETE,this.onWindowLoadComplete);
            param1.onShow();
            if(param4)
            {
               param1.eventDispatcher.dispatchEvent(new Event(Event.COMPLETE));
            }
            for each(_loc6_ in this.m_windows)
            {
               DisplayObjectContainer(_loc6_).mouseEnabled = false;
               DisplayObjectContainer(_loc6_).mouseChildren = false;
            }
            this.m_windows.push(param1);
         }
      }
      
      private function onWindowLoadComplete(param1:Event) : void
      {
         var _loc2_:IWindow = param1.target as IWindow;
         _loc2_.eventDispatcher.removeEventListener(Event.COMPLETE,this.onWindowLoadComplete);
         if(m_block_all_popups)
         {
            return;
         }
         InputManager.disableInput();
         dispatchEvent(new WorldEvent(SHOW_SCREEN,_loc2_));
         this.m_container.contentWidth = Zlab.mainStage.stageWidth;
         this.m_container.contentHeight = Zlab.mainStage.stageHeight;
         this.m_container.addChild(_loc2_ as DisplayObject);
         if(!this.windowParent.contains(this.m_container))
         {
            this.windowParent.addChild(this.m_container as DisplayObject);
         }
         Logger.print(WindowManager,"onWindowLoadComplete(): " + _loc2_);
         if(GlobalEngine.zaspManager)
         {
            GlobalEngine.zaspManager.zaspPopup();
         }
      }
      
      private function delayedPopUp(param1:IWindow) : void
      {
         var _loc2_:int = this.getDelayedWindowsIndex(param1);
         if(_loc2_ > -1)
         {
            Logger.print(WindowManager,"delayedPopup(): " + param1);
            this.push(this.m_delayedWindows[_loc2_].window,0,this.m_delayedWindows[_loc2_].addToQueue);
            this.m_delayedWindows.splice(_loc2_,1);
         }
      }
      
      public function pop() : void
      {
         var _loc2_:Object = null;
         var _loc3_:IWindow = null;
         var _loc4_:int = 0;
         var _loc1_:DisplayObject = this.m_windows.pop();
         Logger.print(WindowManager,"pop(): " + _loc1_);
         if(this.displayedWindow)
         {
            DisplayObjectContainer(this.displayedWindow).mouseEnabled = true;
            DisplayObjectContainer(this.displayedWindow).mouseChildren = true;
         }
         if(Boolean(_loc1_) && this.m_container.contains(_loc1_))
         {
            this.m_container.removeChild(_loc1_);
            dispatchEvent(new Event(HIDE_SCREEN));
            InputManager.enableInput();
         }
         if(this.m_windows.length == 0)
         {
            if(this.m_container.parent)
            {
               this.windowParent.removeChild(this.m_container as DisplayObject);
               Logger.print(WindowManager,"pop() 2: " + _loc1_);
            }
            if(this.m_queue.length > 0)
            {
               _loc2_ = this.m_queue.shift();
               Logger.print(WindowManager,"pop() 3: " + _loc1_ + " pushing: " + _loc2_.window);
               this.push(_loc2_.window);
            }
            else
            {
               dispatchEvent(new Event(LAST_HIDE_SCREEN));
            }
         }
         else if(this.m_loadedWindows.length > 0)
         {
            for each(_loc3_ in this.m_loadedWindows)
            {
               if(_loc3_ == this.displayedWindow)
               {
                  _loc4_ = this.m_loadedWindows.indexOf(_loc3_);
                  this.m_loadedWindows.splice(_loc4_,1);
                  _loc3_.onShow();
                  break;
               }
            }
         }
      }
      
      private function getDelayedWindowsIndex(param1:IWindow) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_delayedWindows.length)
         {
            if(this.m_delayedWindows[_loc2_].window == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function playCinematics(param1:ICinematic) : void
      {
         this.m_cinema = param1;
         this.m_cinema.loadAndPlay();
         Zlab.mainStage.addChild(this.m_cinema as DisplayObject);
         this.m_cinema.addEventListener(Event.COMPLETE,this.onCinematicComplete,false,0,true);
      }
      
      private function onCinematicComplete(param1:Event) : void
      {
         this.m_cinema.removeEventListener(Event.COMPLETE,this.onCinematicComplete);
         this.m_cinema = null;
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

