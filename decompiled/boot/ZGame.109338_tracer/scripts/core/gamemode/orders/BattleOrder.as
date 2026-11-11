package core.gamemode.orders
{
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.GMBattle;
   import flash.events.Event;
   import zlabs.entity.IEntity;
   
   public class BattleOrder extends ClickOrder
   {
      
      public function BattleOrder(param1:IEntity)
      {
         super(param1);
      }
      
      override public function execute(param1:IEntity) : void
      {
         GameModeManager.instance.addEventListener(GMBattle.BATTLE_EXIT,this.onBattleExit);
      }
      
      override public function dispose(param1:IEntity) : void
      {
         super.dispose(param1);
         GameModeManager.instance.removeEventListener(GMBattle.BATTLE_EXIT,this.onBattleExit);
      }
      
      private function onBattleExit(param1:Event) : void
      {
         onActionComplete(null);
      }
   }
}

