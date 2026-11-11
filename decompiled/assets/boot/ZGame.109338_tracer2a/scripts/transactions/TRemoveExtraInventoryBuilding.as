package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TRemoveExtraInventoryBuilding extends Transaction
   {
      
      private var m_count:int;
      
      private var m_itemCode:String;
      
      public function TRemoveExtraInventoryBuilding(param1:String, param2:int)
      {
         this.m_itemCode = param1;
         this.m_count = param2;
         super();
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("WorldService.removeExtraInventoryBuildings",this.m_itemCode,this.m_count);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

