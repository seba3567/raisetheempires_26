package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSeenStrikeTeamComment extends Transaction
   {
      
      private var m_victimID:String;
      
      public function TSeenStrikeTeamComment(param1:String)
      {
         super();
         this.m_victimID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.seenStrikeTeamComment",this.m_victimID);
      }
   }
}

