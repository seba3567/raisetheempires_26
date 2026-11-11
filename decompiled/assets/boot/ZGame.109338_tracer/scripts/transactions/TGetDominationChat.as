package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.domination.DominationModeManager;
   
   public class TGetDominationChat extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TGetDominationChat(param1:String)
      {
         super();
         this.m_data = new Object();
         this.m_data.enemyID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("DominationModeService.getDominationChat",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         DominationModeManager.instance.onReceivedDominationChat(param1,this.m_data.enemyID);
      }
   }
}

