package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.survivalModeManager.SurvivalModeManager;
   
   public class TLoadSurvivalMode extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TLoadSurvivalMode(param1:String = null, param2:String = null, param3:Boolean = false, param4:Boolean = false)
      {
         super();
         this.m_data = new Object();
         this.m_data.set = param1;
         this.m_data.eliteMode = param4;
         if(param2 != null)
         {
            this.m_data.playerFleetName = param2;
            this.m_data.playerFleet = ZGlobal.player.fleets.getSerialisableFleet(param2);
         }
         if(param3)
         {
            this.m_data.continueGame = true;
         }
      }
      
      override public function perform() : void
      {
         signedCall("SurvivalModeService.loadSurvivalMode",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         SurvivalModeManager.instance.onLoadSurvivalMode(param1);
      }
   }
}

