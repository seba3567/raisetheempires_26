package core.gamemode.battle
{
   import core.gameobjects.ConsumableItem;
   
   public interface ISelectionReceiver
   {
      
      function set player(param1:BattleObject) : void;
      
      function set playerOver(param1:BattleObject) : void;
      
      function set enemy(param1:BattleObject) : void;
      
      function set enemyOver(param1:BattleObject) : void;
      
      function set consumable(param1:ConsumableItem) : void;
      
      function set ally(param1:String) : void;
      
      function set merc(param1:String) : void;
      
      function set questPower(param1:String) : void;
   }
}

