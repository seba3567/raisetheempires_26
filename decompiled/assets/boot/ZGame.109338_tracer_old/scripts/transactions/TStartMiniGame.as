package transactions
{
   import core.managers.miniGameManager.BomberGameManager;
   import displays.popups.bomberGame.PlayBomberGame;
   
   public class TStartMiniGame extends TZGameTransaction
   {
      
      private var m_dialog:PlayBomberGame;
      
      public function TStartMiniGame(param1:BomberGameManager)
      {
         super();
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("MiniGameService.loadGame");
      }
      
      final override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         BomberGameManager.instance.loadGame(param1);
      }
   }
}

