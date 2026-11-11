package transactions
{
   import displays.popups.bomberGame.PlayBomberGame;
   
   public class TDropBomb extends TZGameTransaction
   {
      
      private var m_dialog:PlayBomberGame;
      
      public function TDropBomb(param1:PlayBomberGame)
      {
         super();
         this.m_dialog = param1;
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("MiniGameService.dropBomb");
      }
      
      final override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         this.m_dialog.onBombDropSuccess(param1);
      }
   }
}

