package core.gamemode.battle
{
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   
   public class GMBattleReplay extends GMBattle
   {
      
      public function GMBattleReplay(param1:Fleet, param2:Fleet, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override protected function startRematch() : void
      {
         ZGlobal.player.campaign.currentMap.replay(ZGlobal.player.campaign.currentMap.currentIslandItem);
         super.startRematch();
      }
   }
}

