package core.gamemode.battle
{
   import core.gameobjects.Fleet;
   
   public class BattleDefenseForceEdit extends BattleHost
   {
      
      public function BattleDefenseForceEdit(param1:Fleet, param2:Fleet)
      {
         super(param1,param2);
      }
      
      override public function get isDefenseForceEditMode() : Boolean
      {
         return true;
      }
   }
}

