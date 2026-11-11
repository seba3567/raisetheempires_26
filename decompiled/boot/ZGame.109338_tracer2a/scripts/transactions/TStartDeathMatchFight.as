package transactions
{
   import core.ZGlobal;
   import core.managers.deathMatchManager.DeathMatchManager;
   
   public class TStartDeathMatchFight extends TZGameTransaction
   {
      
      private var m_data:Object = null;
      
      private var m_enemyID:String = null;
      
      private var m_roomID:String = null;
      
      public function TStartDeathMatchFight(param1:String = null, param2:String = null, param3:String = null)
      {
         super();
         this.m_data = new Object();
         if(param1 != null && param1 != "")
         {
            this.m_data.playerFleet = ZGlobal.player.fleets.getSerialisableFleet(param1);
         }
         if(param2 != null)
         {
            this.m_data.enemyID = param2;
            this.m_enemyID = param2;
         }
         if(param3 != null)
         {
            this.m_data.roomID = param3;
            this.m_roomID = param3;
         }
      }
      
      override public function perform() : void
      {
         signedCall("DeathMatchService.loadBattle",modifiedData(this.m_data));
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.battleInfo)
         {
            DeathMatchManager.instance.updateBattleInfo(param1.battleInfo);
         }
         DeathMatchManager.instance.onLoadBattle(param1,this.m_enemyID,this.m_roomID);
      }
   }
}

