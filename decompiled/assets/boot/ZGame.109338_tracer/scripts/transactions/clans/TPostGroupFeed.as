package transactions.clans
{
   import transactions.TZGameTransaction;
   
   public class TPostGroupFeed extends TZGameTransaction
   {
      
      private var m_msg:String = "";
      
      private var m_source:String;
      
      public function TPostGroupFeed(param1:String, param2:String = "dashboard")
      {
         this.m_msg = param1;
         this.m_source = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.postGroupFeed",modifiedData({"msg":this.m_msg}),this.m_source);
      }
   }
}

