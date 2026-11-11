package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TRoadBuy extends Transaction
   {
      
      private var m_roadList:Array;
      
      private var m_count:Number;
      
      public function TRoadBuy(param1:Array, param2:Number)
      {
         super();
         this.m_roadList = param1;
         this.m_count = param2;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.updateRoads",this.m_roadList,this.m_count);
      }
      
      override protected function onComplete(param1:Object) : void
      {
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
      }
   }
}

