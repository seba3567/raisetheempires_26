package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TRoadMove extends Transaction
   {
      
      private var m_roadList:Array;
      
      public function TRoadMove(param1:Array)
      {
         super();
         this.m_roadList = param1;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.moveRoad",this.m_roadList);
      }
   }
}

