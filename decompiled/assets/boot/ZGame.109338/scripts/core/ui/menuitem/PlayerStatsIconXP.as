package core.ui.menuitem
{
   import core.managers.prisoncamp.PrisonCampManager;
   import core.player.Player;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import zlabs.events.WorldEvent;
   
   public class PlayerStatsIconXP extends PlayerStatsIconBase
   {
      
      private var m_currentMC:MovieClip;
      
      public function PlayerStatsIconXP(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super(param1,param2,param3,param4,param5);
         UIDispatcher.instance.addEventListener(Player.XP_MULT_CHANGED,this.onXPMultChanged,false,0,true);
      }
      
      private function onXPMultChanged(param1:WorldEvent = null) : void
      {
         var _loc2_:Number = param1 ? param1.eventData as Number : 1;
         var _loc3_:MovieClip = this.getAppropriateMC(_loc2_);
         this.currentMC = _loc3_;
      }
      
      private function set currentMC(param1:MovieClip) : void
      {
         if(param1 != this.m_currentMC)
         {
            m_displayObject.icon_mc.visible = false;
            m_displayObject.icon_mc2.visible = false;
            m_displayObject.icon_mc3.visible = false;
            this.m_currentMC = param1;
            this.m_currentMC.visible = true;
         }
      }
      
      private function getAppropriateMC(param1:Number) : MovieClip
      {
         if(param1 >= PrisonCampManager.MULTIPLIER_20_FLOAT)
         {
            return m_displayObject.icon_mc3;
         }
         if(param1 >= PrisonCampManager.MULTIPLIER_15_FLOAT)
         {
            return m_displayObject.icon_mc2;
         }
         return iconMC;
      }
   }
}

