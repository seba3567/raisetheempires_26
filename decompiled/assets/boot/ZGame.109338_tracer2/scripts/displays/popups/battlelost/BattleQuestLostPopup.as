package displays.popups.battlelost
{
   import core.player.IPVPPlayer;
   import core.player.PlayerVillain;
   import flash.utils.Dictionary;
   
   public class BattleQuestLostPopup extends BattleChallengeLostPopup
   {
      
      private var m_villain:String = null;
      
      public function BattleQuestLostPopup(param1:String, param2:Array, param3:Dictionary, param4:Function = null)
      {
         this.m_villain = param1;
         super(param2,param3,param4);
      }
      
      override protected function getPVPPlayer(param1:String) : IPVPPlayer
      {
         if(this.m_villain)
         {
            return new PlayerVillain(this.m_villain);
         }
         return super.getPVPPlayer(param1);
      }
   }
}

