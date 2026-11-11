package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TQuestTreeReset extends Transaction
   {
      
      private var m_tree:String;
      
      private var m_quest:String;
      
      public function TQuestTreeReset(param1:String, param2:String = null)
      {
         this.m_tree = param1;
         this.m_quest = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.questTreeReset",this.m_tree,this.m_quest);
      }
   }
}

