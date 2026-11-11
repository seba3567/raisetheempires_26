package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.QuestSurvivalModeManager;
   
   public class TLoadQuestSurvivalMode extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TLoadQuestSurvivalMode(param1:Object, param2:String = null, param3:String = null)
      {
         super();
         this.m_data = new Object();
         this.m_data.set = param2;
         this.m_data.id = param1.id;
         if(param3 != null)
         {
            this.m_data.playerFleetName = param3;
            this.m_data.playerFleet = ZGlobal.player.fleets.getSerialisableFleet(param3);
         }
      }
      
      override public function perform() : void
      {
         signedCall("QuestSurvivalModeService.loadQuestSurvivalMode",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         QuestSurvivalModeManager.instance.onLoadQuestSurvivalMode(param1);
      }
   }
}

