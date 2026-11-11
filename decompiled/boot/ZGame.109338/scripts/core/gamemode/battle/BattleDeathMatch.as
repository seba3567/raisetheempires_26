package core.gamemode.battle
{
   import core.gameobjects.Fleet;
   
   public class BattleDeathMatch extends BattleHost
   {
      
      public function BattleDeathMatch(param1:Fleet, param2:Fleet)
      {
         super(param1,param2);
      }
      
      override public function get isDeathMatchBattle() : Boolean
      {
         return true;
      }
   }
}

