package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.SuperOreManager;
   
   public class TSuperOre extends Transaction
   {
      
      public function TSuperOre()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.superOreOrder");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1.resourceOrder))
         {
            SuperOreManager.instance.resourceOrder = param1.resourceOrder;
         }
      }
   }
}

