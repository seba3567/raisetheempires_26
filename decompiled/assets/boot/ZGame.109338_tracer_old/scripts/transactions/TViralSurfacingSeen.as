package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TViralSurfacingSeen extends Transaction
   {
      
      private var m_type:String;
      
      public function TViralSurfacingSeen(param1:String)
      {
         this.m_type = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.viralSurfacingSeen",this.m_type);
      }
   }
}

