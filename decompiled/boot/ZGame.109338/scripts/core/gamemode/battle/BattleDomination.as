package core.gamemode.battle
{
   import core.gameobjects.Fleet;
   
   public class BattleDomination extends BattleHost
   {
      
      public function BattleDomination(param1:Fleet, param2:Fleet)
      {
         super(param1,param2);
      }
      
      override public function get isDominationMode() : Boolean
      {
         return true;
      }
   }
}

