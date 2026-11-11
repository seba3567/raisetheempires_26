package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TSetDefenderComment extends Transaction
   {
      
      private var m_invasionID:String;
      
      private var m_comment:String;
      
      public function TSetDefenderComment(param1:String, param2:String)
      {
         super();
         this.m_invasionID = param1;
         this.m_comment = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.setDefenderComment",ZGlobal.hostPlayer.uid,this.m_invasionID,ZGlobal.player.uid,this.m_comment);
      }
   }
}

