package core.managers.worldEventManager
{
   public class WorldEventManager
   {
      
      public static var instance:WorldEventManager = new WorldEventManager();
      
      private var m_worldEvent:BaseWorldEvent = null;
      
      private var m_xml:XMLList = null;
      
      public function WorldEventManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_xml = param1;
      }
      
      public function getWorldEvent(param1:String) : BaseWorldEvent
      {
         return this.m_worldEvent;
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         loop0:
         for each(_loc2_ in param1)
         {
            var _loc6_:int = 0;
            var _loc7_:* = this.m_xml.worldEvent;
            do
            {
               for each(_loc3_ in _loc7_)
               {
               }
               continue loop0;
            }
            while(_loc3_.@code != _loc2_);
            this.m_worldEvent = new DestroyItemsEvent(this.m_xml.worldEvent[0]);
            return;
         }
      }
   }
}

