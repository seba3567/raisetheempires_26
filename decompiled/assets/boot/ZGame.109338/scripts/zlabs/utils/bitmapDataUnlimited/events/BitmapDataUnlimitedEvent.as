package zlabs.utils.bitmapDataUnlimited.events
{
   import flash.events.Event;
   
   public class BitmapDataUnlimitedEvent extends Event
   {
      
      public static const COMPLETE:String = "bitmapDataComplete";
      
      public static const ERROR:String = "bitmapDataError";
      
      public function BitmapDataUnlimitedEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public function clone() : Event
      {
         return new BitmapDataUnlimitedEvent(type,bubbles,cancelable);
      }
   }
}

