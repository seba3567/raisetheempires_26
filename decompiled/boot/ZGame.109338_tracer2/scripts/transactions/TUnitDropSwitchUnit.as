package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TUnitDropSwitchUnit extends Transaction
   {
      
      private var m_objectID:int;
      
      public function TUnitDropSwitchUnit(param1:int)
      {
         super();
         this.m_objectID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.unitDropSwitchUnit",{"objectID":this.m_objectID});
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

