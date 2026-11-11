package transactions
{
   public class TBuyQuestTask extends TGameTransaction
   {
      
      private var m_questName:String = null;
      
      private var m_taskIndex:int = -1;
      
      private var m_cost:int = 0;
      
      public function TBuyQuestTask(param1:String, param2:int, param3:int)
      {
         super();
         this.m_questName = param1;
         this.m_taskIndex = param2;
         this.m_cost = param3;
      }
      
      public function get name() : String
      {
         return this.m_questName;
      }
      
      public function get index() : int
      {
         return this.m_taskIndex;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyQuestTask",{
            "name":this.m_questName,
            "taskIndex":this.m_taskIndex,
            "cost":this.m_cost
         });
      }
   }
}

