package core.gamemode.prebattle
{
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.worlds.battleWorld.BattleSide;
   import core.worlds.battleWorld.BattleUnit;
   import flash.display.MovieClip;
   
   public class PreBattleBattleUnit extends BattleUnit
   {
      
      public function PreBattleBattleUnit(param1:MovieClip, param2:UnitItem)
      {
         var _loc3_:BattleObject = new BattleObject(new Unit(param2.code,0,null),null,null);
         super(BattleSide.PLAYER,_loc3_);
         init(param1,null,0,0);
         this.paused = true;
         this.bar.visible = false;
      }
      
      override protected function updateConsumables(param1:Boolean) : void
      {
      }
   }
}

