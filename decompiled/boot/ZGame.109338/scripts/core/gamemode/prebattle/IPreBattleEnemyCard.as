package core.gamemode.prebattle
{
   import flash.display.MovieClip;
   
   public interface IPreBattleEnemyCard
   {
      
      function set visible(param1:Boolean) : void;
      
      function get art() : MovieClip;
      
      function dispose() : void;
   }
}

