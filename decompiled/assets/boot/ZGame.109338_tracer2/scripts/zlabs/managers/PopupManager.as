package zlabs.managers
{
   import flash.utils.getQualifiedClassName;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.events.WorldEvent;
   
   public class PopupManager extends WindowManager
   {
      
      private static var _instance:PopupManager;
      
      public static const SHOW_POPUP:String = "ShowPopup";
      
      public function PopupManager()
      {
         super();
      }
      
      public static function get instance() : PopupManager
      {
         if(!_instance)
         {
            _instance = new PopupManager();
         }
         return _instance;
      }
      
      override public function push(param1:IWindow, param2:int = 0, param3:Boolean = true, param4:Boolean = true, param5:Boolean = false) : void
      {
         var _loc6_:String = getQualifiedClassName(param1);
         var _loc7_:Error = new Error();
         var _loc8_:String = _loc7_.getStackTrace();
         Logger.print(PopupManager,"PopupManager.push() - class: " + _loc6_);
         Logger.print(PopupManager,_loc8_ + "\n\n\n\n");
         super.push(param1,param2,param3,param4,param5);
         if(displayedWindow == param1)
         {
            dispatchEvent(new WorldEvent(SHOW_POPUP,param1));
         }
      }
   }
}

