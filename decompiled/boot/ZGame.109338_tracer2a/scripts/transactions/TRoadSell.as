package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TRoadSell extends Transaction
   {
      
      private var m_roadList:Array;
      
      public function TRoadSell(param1:Array)
      {
         super();
         this.m_roadList = param1;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.sellRoad",this.m_roadList);
      }
   }
}

