package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSeenPrisonCampNotification extends Transaction
   {
      
      public static const ESCAPED:String = "ESCAPED";
      
      public static const CAPTURED:String = "CAPTURED";
      
      private var m_type:String = null;
      
      private var m_zid:String = null;
      
      public function TSeenPrisonCampNotification(param1:String, param2:String)
      {
         super();
         this.m_type = param1;
         this.m_zid = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.seenPrisonCampNotification",this.m_type,this.m_zid);
      }
   }
}

