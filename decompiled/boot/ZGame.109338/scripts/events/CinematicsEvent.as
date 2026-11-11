package events
{
   import flash.events.Event;
   
   public class CinematicsEvent extends Event
   {
      
      private var m_movieUrl:String = null;
      
      public function CinematicsEvent(param1:String, param2:String)
      {
         super(param1,true);
         this.m_movieUrl = param2;
      }
      
      public function get movieUrl() : String
      {
         return this.m_movieUrl;
      }
   }
}

