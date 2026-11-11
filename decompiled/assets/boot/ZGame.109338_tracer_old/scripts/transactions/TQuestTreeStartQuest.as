package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TQuestTreeStartQuest extends Transaction
   {
      
      protected var m_tree:String;
      
      protected var m_quest:String;
      
      public function TQuestTreeStartQuest(param1:String, param2:String)
      {
         this.m_tree = param1;
         this.m_quest = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.questTreeStartQuest",this.m_tree,this.m_quest);
      }
   }
}

