package core.worlds.battleWorld
{
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BattleText extends BattleMovie
   {
      
      private static const PLAYER:int = 0;
      
      private static const ENEMY:int = 1;
      
      private static const VICTORY:int = 2;
      
      public function BattleText(param1:DisplayObjectContainer, param2:SWFResource)
      {
         super(param1,param2);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         m_classes = new Array(3);
         m_classes[PLAYER] = param2.getAssetClass("PlayerTurnAni");
         m_classes[ENEMY] = param2.getAssetClass("EnemyTurnAni");
         m_classes[VICTORY] = param2.getAssetClass("VictoryAni");
      }
      
      override public function dispose() : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         super.dispose();
      }
      
      override protected function initMovie(param1:MovieClip, param2:int) : void
      {
         param1.x = BattleRendererComponent.WIDTH * 0.5;
         param1.y = 200;
         var _loc3_:String = null;
         switch(param2)
         {
            case PLAYER:
               _loc3_ = ZGameUtils.ZlocT("Combat","PlayerTurn");
               break;
            case ENEMY:
               _loc3_ = ZGameUtils.ZlocT("Combat","EnemyTurn");
               break;
            case VICTORY:
               _loc3_ = ZGameUtils.ZlocT("Combat","Victory");
         }
         TextFieldUtil.processTextField(param1.textBox.title_tf,_loc3_);
      }
      
      private function onBattleComplete(param1:WorldEvent) : void
      {
         if(param1.eventData.result == Battle.BATTLE_RESULT_WON)
         {
            triggerMovie(VICTORY);
         }
      }
   }
}

