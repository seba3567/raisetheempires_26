package core.gamemode.battle.consumable.suggester
{
   public interface IConsumableSuggestion
   {
      
      function get algorithmName() : String;
      
      function get weight() : Number;
      
      function get consumableCode() : String;
      
      function get consumableMessage() : String;
      
      function get forceIfSuggested() : Boolean;
   }
}

