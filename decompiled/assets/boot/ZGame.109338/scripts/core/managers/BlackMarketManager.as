package core.managers
{
   public class BlackMarketManager
   {
      
      private static var m_instance:BlackMarketManager = null;
      
      private var m_blackMarketData:Object;
      
      public function BlackMarketManager()
      {
         super();
      }
      
      public static function get instance() : BlackMarketManager
      {
         if(!m_instance)
         {
            m_instance = new BlackMarketManager();
         }
         return m_instance;
      }
      
      public function init(param1:Object) : void
      {
         this.m_blackMarketData = param1;
      }
      
      public function get blackMarketData() : Object
      {
         return this.m_blackMarketData;
      }
   }
}

