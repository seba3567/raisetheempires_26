package init
{
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   import transactions.TGetUsersInvaderChallenges;
   
   public class ChallengeListInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "ChallengeListInit";
      
      public function ChallengeListInit()
      {
         super(INIT_ID);
         addDependency(UIInit.INIT_ID);
         addDependency(TransactionsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         TransactionManager.addTransaction(new TGetUsersInvaderChallenges(),true);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

