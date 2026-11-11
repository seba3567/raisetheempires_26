package core.managers.viralsManager
{
   import core.ZGlobal;
   
   public class Viral
   {
      
      private var m_viralType:String;
      
      private var m_originTimestamp:Number;
      
      private var m_timesPosted:uint;
      
      public function Viral(param1:String, param2:uint, param3:Number)
      {
         super();
         this.m_viralType = param1;
         this.m_originTimestamp = param3;
         this.m_timesPosted = param2;
      }
      
      private static function checkIfRewardIsPresent(param1:XMLList, param2:String) : Boolean
      {
         var _loc4_:XML = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.reward.length())
         {
            _loc4_ = param1.reward[_loc3_];
            if(_loc4_.@type == param2)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public static function getViralHelperRewardText(param1:String) : String
      {
         var _loc2_:XML = ZGlobal.gameSettings.getViralXMLByName(param1);
         if(_loc2_.reward == null)
         {
            return ZLoc.t("Dialogs","Share");
         }
         if(_loc2_.reward.helperRewards == null)
         {
            return ZLoc.t("Dialogs","Share");
         }
         if(checkIfRewardIsPresent(_loc2_.reward.helperRewards,"reward_cash"))
         {
            return ZLoc.t("Dialogs","ShareCash");
         }
         if(checkIfRewardIsPresent(_loc2_.reward.helperRewards,"reward_energy"))
         {
            return ZLoc.t("Dialogs","ShareEnergy");
         }
         if(checkIfRewardIsPresent(_loc2_.reward.helperRewards,"reward_xp"))
         {
            return ZLoc.t("Dialogs","ShareExperience");
         }
         if(checkIfRewardIsPresent(_loc2_.reward.helperRewards,"reward_coins"))
         {
            return ZLoc.t("Dialogs","ShareCoins");
         }
         if(checkIfRewardIsPresent(_loc2_.reward.helperRewards,"reward_goods"))
         {
            return ZLoc.t("Dialogs","ShareGoods");
         }
         return ZLoc.t("Dialogs","Share");
      }
      
      public function set timesPosted(param1:uint) : void
      {
         this.m_timesPosted = param1;
      }
      
      public function get timesPosted() : uint
      {
         return this.m_timesPosted;
      }
      
      public function getType() : String
      {
         return this.m_viralType;
      }
      
      public function getResetTime() : Number
      {
         var _loc1_:XML = ZGlobal.gameSettings.getViralXMLByName(this.m_viralType);
         return this.m_originTimestamp + Number(_loc1_.timeTillReset * 3600);
      }
      
      public function hasReset() : Boolean
      {
         var _loc1_:Number = GlobalEngine.serverTime / 1000;
         var _loc2_:Number = _loc1_ - this.m_originTimestamp;
         var _loc3_:XML = ZGlobal.gameSettings.getViralXMLByName(this.m_viralType);
         if(_loc3_)
         {
            return _loc2_ >= Number(_loc3_.timeTillReset * 3600);
         }
         return true;
      }
      
      public function hasHitPostLimit() : Boolean
      {
         var _loc1_:XML = ZGlobal.gameSettings.getViralXMLByName(this.m_viralType);
         if(_loc1_.maxPosts.length() > 0)
         {
            return this.m_timesPosted >= uint(_loc1_.maxPosts);
         }
         return false;
      }
   }
}

