package transactions
{
   public class TBuyRewardItem extends TZGameTransaction
   {
      
      private var m_code:String = null;
      
      private var m_questId:String = null;
      
      public function TBuyRewardItem(param1:String, param2:String = "")
      {
         super();
         this.m_code = param1;
         this.m_questId = param2;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyRewardItem",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         return {
            "code":this.m_code,
            "quest_name":this.m_questId
         };
      }
   }
}

