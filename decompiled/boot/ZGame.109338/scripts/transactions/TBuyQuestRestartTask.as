package transactions
{
   public class TBuyQuestRestartTask extends TGameTransaction
   {
      
      private var m_questName:String = null;
      
      public function TBuyQuestRestartTask(param1:String)
      {
         super();
         this.m_questName = param1;
      }
      
      public function get name() : String
      {
         return this.m_questName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyQuestRestartTask",{"name":this.m_questName});
      }
   }
}

