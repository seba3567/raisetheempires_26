package core.worlds.battleWorld.megaUnit
{
   import core.gamemode.battle.BattleObject;
   import core.worlds.battleWorld.EnemyUnit;
   import flash.display.Sprite;
   
   public class EnemyMegaUnit extends EnemyUnit
   {
      
      private var m_state:MegaUnitState = new MegaUnitState(this);
      
      public function EnemyMegaUnit(param1:int, param2:BattleObject)
      {
         super(param1,param2);
      }
      
      override public function dispose(param1:Sprite) : void
      {
         this.m_state.dispose();
         this.m_state = null;
         super.dispose(param1);
      }
      
      override public function init(param1:Sprite, param2:BattleObject, param3:int, param4:int) : void
      {
         super.init(param1,param2,param3,param4);
         (art as Sprite).mouseEnabled = false;
         (art as Sprite).mouseChildren = false;
      }
      
      override protected function get centreUnit() : Boolean
      {
         return false;
      }
      
      override protected function get unitRewardsMultipler() : Number
      {
         return 0.3;
      }
      
      override protected function setupDrift() : void
      {
      }
      
      override protected function initBar() : void
      {
         if(!battleObject.unit.dead)
         {
            super.initBar();
         }
      }
      
      override public function set classIconVisible(param1:Boolean) : void
      {
         if(bar)
         {
            super.classIconVisible = param1;
         }
      }
      
      override protected function updateConsumables(param1:Boolean) : void
      {
         if(bar)
         {
            super.updateConsumables(param1);
         }
      }
      
      override protected function repositionBar() : void
      {
         if(bar)
         {
            super.repositionBar();
         }
      }
      
      override protected function disablePowerButton() : void
      {
         if(bar)
         {
            super.disablePowerButton();
         }
      }
      
      override protected function addClassIcon() : void
      {
         if(bar)
         {
            super.addClassIcon();
         }
      }
      
      override protected function startRemovalTimer() : void
      {
         if(this.m_state.startRemovalTimer(battleObject,side))
         {
            super.startRemovalTimer();
         }
      }
   }
}

