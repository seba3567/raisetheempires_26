package transactions
{
   import core.ZGlobal;
   import zlabs.debug.Logger;
   
   public class TGetTargetingGroups extends TZGameTransaction
   {
      
      public function TGetTargetingGroups()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getTargetingGroups");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         Logger.print(null,"Targeting result from server: " + param1.toString());
         ZGlobal.player.userGroups = param1["groups"];
      }
   }
}

