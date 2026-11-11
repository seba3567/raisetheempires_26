package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TCrewNeighborPoll extends Transaction
   {
      
      public function TCrewNeighborPoll()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.crewNeighborPoll");
      }
   }
}

