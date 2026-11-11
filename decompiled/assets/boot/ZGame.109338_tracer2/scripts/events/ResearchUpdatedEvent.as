package events
{
   import flash.events.Event;
   
   public class ResearchUpdatedEvent extends Event
   {
      
      public static const UPGRADE_ADDED:String = "upgradeAdded";
      
      public static const DURATION_UPGRADE_ADDED:String = "durationUpgradeAdded";
      
      private var m_itemCode:String = null;
      
      private var m_upgradeCode:String = null;
      
      public function ResearchUpdatedEvent(param1:String, param2:String, param3:String)
      {
         super(param1);
         this.m_itemCode = param2;
         this.m_upgradeCode = param3;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function get upgradeCode() : String
      {
         return this.m_upgradeCode;
      }
   }
}

