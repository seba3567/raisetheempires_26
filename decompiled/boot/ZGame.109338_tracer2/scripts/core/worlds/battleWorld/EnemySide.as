package core.worlds.battleWorld
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.UnitItem;
   import core.worlds.battleWorld.megaUnit.EnemyMegaUnit;
   import flash.display.Sprite;
   import zlabs.entity.IEntity;
   
   public class EnemySide extends BattleSide
   {
      
      private var m_owner:IEntity = null;
      
      public function EnemySide(param1:IEntity)
      {
         super();
         this.m_owner = param1;
         m_direction = ENEMY;
         this.m_owner.eventDispatcher.addEventListener(BattleWorld.REGISTER_ENEMY_UNIT,onUnitRegistered);
      }
      
      override public function init(param1:Sprite) : void
      {
         super.init(param1);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,onUnitHighlighted);
      }
      
      override public function dispose(param1:Sprite) : void
      {
         super.dispose(param1);
         this.m_owner.eventDispatcher.removeEventListener(BattleWorld.REGISTER_ENEMY_UNIT,onUnitRegistered);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,onUnitHighlighted);
      }
      
      override protected function createBattleUnit(param1:int, param2:BattleObject) : BattleUnit
      {
         if(param2.unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            return new EnemyMegaUnit(param1,param2);
         }
         return new EnemyUnit(param1,param2);
      }
   }
}

