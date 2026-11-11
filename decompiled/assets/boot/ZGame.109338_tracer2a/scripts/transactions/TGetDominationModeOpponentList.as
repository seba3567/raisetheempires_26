package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.domination.DominationModeManager;
   
   public class TGetDominationModeOpponentList extends Transaction
   {
      
      private var m_data:Object = new Object();
      
      public function TGetDominationModeOpponentList()
      {
         this.m_data.test = true;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DominationModeService.getDominationModeOpponentList",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         DominationModeManager.instance.onGetDominationModeOpponentList(param1);
      }
   }
}

