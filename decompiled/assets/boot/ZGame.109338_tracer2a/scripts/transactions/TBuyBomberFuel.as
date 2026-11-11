package transactions
{
   public class TBuyBomberFuel extends TZGameTransaction
   {
      
      public function TBuyBomberFuel()
      {
         super();
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("MiniGameService.buyMiniGameFuel");
      }
      
      final override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

