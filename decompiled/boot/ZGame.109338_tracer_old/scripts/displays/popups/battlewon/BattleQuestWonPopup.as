package displays.popups.battlewon
{
   import core.player.IPVPPlayer;
   import core.player.PlayerVillain;
   import flash.utils.Dictionary;
   
   public class BattleQuestWonPopup extends BattleChallengeWonPopup
   {
      
      private var m_questData:Object = null;
      
      public function BattleQuestWonPopup(param1:Object, param2:String, param3:Array, param4:Dictionary, param5:Function)
      {
         this.m_questData = param1;
         super(param2,param3,param4,param5);
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_questData = null;
      }
      
      override protected function get enemyPlayer() : IPVPPlayer
      {
         var _loc1_:String = null;
         return new PlayerVillain(this.m_questData.villain);
      }
   }
}

