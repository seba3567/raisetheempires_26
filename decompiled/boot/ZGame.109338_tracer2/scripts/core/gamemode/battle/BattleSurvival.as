package core.gamemode.battle
{
   import core.gameobjects.Fleet;
   
   public class BattleSurvival extends BattleHost
   {
      
      public function BattleSurvival(param1:Fleet, param2:Fleet)
      {
         super(param1,param2);
      }
      
      override public function endBattleWithRetreat() : void
      {
         super.endBattleWithRetreat();
      }
      
      override protected function battleOver(param1:int) : void
      {
         super.battleOver(param1);
      }
      
      override public function get isSurvivalMode() : Boolean
      {
         return true;
      }
   }
}

