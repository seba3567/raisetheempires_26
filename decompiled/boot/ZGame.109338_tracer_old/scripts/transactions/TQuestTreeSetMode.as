package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TQuestTreeSetMode extends Transaction
   {
      
      private var m_tree:String;
      
      private var m_difficultyMode:String;
      
      public function TQuestTreeSetMode(param1:String, param2:String)
      {
         this.m_tree = param1;
         this.m_difficultyMode = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.questTreeSetMode",this.m_tree,this.m_difficultyMode);
      }
   }
}

