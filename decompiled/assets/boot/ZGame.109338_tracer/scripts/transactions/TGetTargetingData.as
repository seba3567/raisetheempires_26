package transactions
{
   import zlabs.debug.Logger;
   
   public class TGetTargetingData extends TZGameTransaction
   {
      
      public function TGetTargetingData()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getTargetingData");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         Logger.print(null,"Targeting data result from server: " + param1.toString());
      }
   }
}

