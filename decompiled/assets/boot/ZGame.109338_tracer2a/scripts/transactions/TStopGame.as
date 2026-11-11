package transactions
{
   import core.managers.miniGameManager.BomberGameManager;
   import displays.popups.bomberGame.PlayBomberGame;
   
   public class TStopGame extends TZGameTransaction
   {
      
      private var m_dialog:PlayBomberGame;
      
      public function TStopGame(param1:PlayBomberGame = null)
      {
         super();
         this.m_dialog = param1;
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("MiniGameService.stop",BomberGameManager.instance.Fuel);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.fuel < BomberGameManager.instance.Fuel)
         {
            BomberGameManager.instance.Fuel = param1.fuel;
         }
         this.m_dialog.loadEndBomberPopup();
      }
   }
}

