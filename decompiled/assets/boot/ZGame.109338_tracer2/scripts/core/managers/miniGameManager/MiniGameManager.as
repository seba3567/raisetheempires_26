package core.managers.miniGameManager
{
   public class MiniGameManager
   {
      
      private static var m_instance:MiniGameManager = new MiniGameManager();
      
      protected var m_mgxml:XMLList;
      
      public function MiniGameManager()
      {
         super();
      }
      
      public static function get instance() : MiniGameManager
      {
         return m_instance;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_mgxml = param1;
         BomberGameManager.instance.initFromSettings(param1);
      }
   }
}

