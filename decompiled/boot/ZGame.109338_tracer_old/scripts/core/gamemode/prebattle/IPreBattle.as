package core.gamemode.prebattle
{
   import core.gameobjects.Fleet;
   
   public interface IPreBattle
   {
      
      function get fleet() : Fleet;
      
      function get enemyFleet() : Fleet;
      
      function get numUnits() : int;
      
      function get questData() : Object;
      
      function startFight() : void;
      
      function cancelFight() : void;
   }
}

