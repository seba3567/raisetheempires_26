package core.gamemode.prebattle
{
   import core.managers.formationManager.FormationManager;
   import core.worlds.battleWorld.BattleSide;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class PreBattleMegaUnitCard extends PreBattleUnitCard
   {
      
      public function PreBattleMegaUnitCard(param1:EventDispatcher, param2:Class, param3:int, param4:int)
      {
         super(param1,param2,param3,param4);
         m_movieClip.grid_mc.visible = param4 == 0;
      }
      
      override protected function getFormationPosition(param1:int, param2:int) : Point
      {
         return FormationManager.instance.getLocalOffset(BattleSide.PLAYER.toString() + "_5_mega",param2,1);
      }
      
      override protected function addCancelButton() : void
      {
         m_movieClip.card_mc.remove_bt.visible = false;
         m_movieClip.grid_mc.SelectUnitInd.generic_tf.visible = false;
      }
   }
}

