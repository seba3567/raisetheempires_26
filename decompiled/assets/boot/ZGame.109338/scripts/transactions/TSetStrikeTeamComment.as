package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSetStrikeTeamComment extends Transaction
   {
      
      private var m_itemCode:String;
      
      private var m_invaderID:String;
      
      private var m_comment:String;
      
      public function TSetStrikeTeamComment(param1:String, param2:String, param3:String)
      {
         super();
         this.m_itemCode = param1;
         this.m_invaderID = param2;
         this.m_comment = param3;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.setStrikeTeamComment",this.m_itemCode,this.m_invaderID,this.m_comment);
      }
   }
}

