package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TVisitorHelpInvalid extends Transaction
   {
      
      private var m_helper:String;
      
      private var m_objid:int;
      
      public function TVisitorHelpInvalid(param1:String, param2:int)
      {
         super();
         this.m_helper = param1;
         this.m_objid = param2;
      }
      
      override public function perform() : void
      {
         signedCall("VisitorService.helpedInvalid",this.m_helper,this.m_objid);
      }
   }
}

