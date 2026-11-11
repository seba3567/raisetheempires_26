package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TRemoveExtraWorldBuilding extends Transaction
   {
      
      private var m_objId:Object;
      
      public function TRemoveExtraWorldBuilding(param1:Object)
      {
         this.m_objId = param1;
         super();
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("WorldService.removeExtraWorldBuildings",this.m_objId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

