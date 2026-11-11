package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TBuyCrewRepelPosition extends Transaction
   {
      
      private var m_invaderID:String;
      
      private var m_cost:int;
      
      public function TBuyCrewRepelPosition(param1:String, param2:int)
      {
         super();
         this.m_invaderID = param1;
         this.m_cost = param2;
      }
      
      public function get invader() : String
      {
         return this.m_invaderID;
      }
      
      public function get cost() : int
      {
         return this.m_cost;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.buyCrewRepelPosition",this.m_invaderID);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

