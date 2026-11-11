package core.gameobjects.questPower
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.player.IAlly;
   
   public class QuestPower implements IAlly
   {
      
      public static const POWER_TAG:String = "pwr";
      
      private var m_code:String = null;
      
      private var m_item:ConsumableItem = null;
      
      public function QuestPower(param1:String)
      {
         super();
         this.m_code = param1;
         this.m_item = ZGlobal.gameSettings.getItemByCode(param1,ConsumableItem) as ConsumableItem;
      }
      
      public static function isQuestPower(param1:String) : Boolean
      {
         return getCodeFromId(param1) != null;
      }
      
      public static function getCodeFromId(param1:String) : String
      {
         var _loc2_:Array = null;
         if(param1.indexOf(POWER_TAG) == 0)
         {
            _loc2_ = param1.split("_");
            return _loc2_[1];
         }
         return null;
      }
      
      public function get firstName() : String
      {
         return "power";
      }
      
      public function get id() : String
      {
         return this.m_code;
      }
      
      public function get imageUrl() : String
      {
         return this.m_item.getCachedImage("icon").url;
      }
      
      public function get level() : int
      {
         return 0;
      }
      
      public function get gender() : String
      {
         return "M";
      }
   }
}

