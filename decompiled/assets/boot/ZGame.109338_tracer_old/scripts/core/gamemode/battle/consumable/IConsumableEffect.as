package core.gamemode.battle.consumable
{
   public interface IConsumableEffect
   {
      
      function init(param1:Boolean) : void;
      
      function update() : Boolean;
      
      function dispose() : void;
   }
}

