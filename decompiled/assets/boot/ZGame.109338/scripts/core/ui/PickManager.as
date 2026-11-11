package core.ui
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class PickManager extends EventDispatcher
   {
      
      public static const PICKS_ACTIVE_UPDATED:String = "picksActiveUpdated";
      
      public static const SELECT_PICKS_UPDATED:String = "selectPicksUpdated";
      
      private static var m_enabled:Boolean = true;
      
      private static var m_selectPicks:Boolean = false;
      
      private static var m_instance:PickManager = new PickManager();
      
      public function PickManager()
      {
         super();
      }
      
      public static function get instance() : PickManager
      {
         return m_instance;
      }
      
      public static function get enabled() : Boolean
      {
         return m_enabled;
      }
      
      public static function set picksEnabled(param1:Boolean) : void
      {
         if(m_enabled != param1)
         {
            m_enabled = param1;
            instance.dispatchEvent(new Event(PICKS_ACTIVE_UPDATED));
         }
      }
      
      public static function set selectPicks(param1:Boolean) : void
      {
         if(param1 != m_selectPicks)
         {
            m_selectPicks = param1;
            instance.dispatchEvent(new WorldEvent(SELECT_PICKS_UPDATED,m_selectPicks));
         }
      }
      
      public static function get selectPicks() : Boolean
      {
         return m_selectPicks;
      }
   }
}

