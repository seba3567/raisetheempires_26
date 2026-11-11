package events
{
   import flash.events.Event;
   
   public class IsoViewEvent extends Event
   {
      
      public static const ISOVIEW_PAN:String = "isoViewPan";
      
      public static const ISOVIEW_ZOOM:String = "isoViewZoom";
      
      private var m_value:Number = 0;
      
      public function IsoViewEvent(param1:String, param2:Number = 0, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.m_value = param2;
      }
      
      public function get value() : Number
      {
         return this.m_value;
      }
   }
}

