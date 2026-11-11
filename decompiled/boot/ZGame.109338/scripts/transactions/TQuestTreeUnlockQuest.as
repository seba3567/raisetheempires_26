package transactions
{
   public class TQuestTreeUnlockQuest extends TQuestTreeStartQuest
   {
      
      public function TQuestTreeUnlockQuest(param1:String, param2:String)
      {
         super(param1,param2);
      }
      
      override public function perform() : void
      {
         signedCall("UserService.questTreeUnlockQuest",m_tree,m_quest);
      }
   }
}

