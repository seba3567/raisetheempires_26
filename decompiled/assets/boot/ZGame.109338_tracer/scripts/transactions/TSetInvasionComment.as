package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TSetInvasionComment extends Transaction
   {
      
      private var m_invasionID:String;
      
      private var m_comment:String;
      
      public function TSetInvasionComment(param1:String, param2:String)
      {
         super();
         this.m_invasionID = param1;
         this.m_comment = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.setInvasionComment",ZGlobal.hostPlayer.uid,this.m_invasionID,this.m_comment);
      }
   }
}

