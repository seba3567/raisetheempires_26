package zlabs.events
{
   import flash.events.Event;
   
   public class GenericPopupEvent extends Event
   {
      
      public static const SELECTED:String = "selected";
      
      public var button:int = 0;
      
      public var userData:Object = null;
      
      public function GenericPopupEvent(param1:String, param2:int, param3:Object = null)
      {
         super(param1);
         this.button = param2;
         this.userData = param3;
      }
   }
}

