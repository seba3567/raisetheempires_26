package displays.screens.pickUnitsScreen
{
   import core.managers.domination.DominationModeManager;
   import flash.display.MovieClip;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StackedUnitsSlotDominationMode extends StackedUnitsSlot
   {
      
      private static const NOT_INITIALIZED:int = 0;
      
      private static const ENABLED:int = 1;
      
      private static const DISABLED:int = 2;
      
      private var m_state:int = 0;
      
      public function StackedUnitsSlotDominationMode(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:StackedUnitInfo, param7:int, param8:Number)
      {
         DominationModeManager.instance.addEventListener(DominationModeManager.MAX_FLEET_STRENGTH_UPDATED,this.onStrengthUpdated,false,0,true);
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         this.updateStrengthLimitState();
      }
      
      override public function dispose() : void
      {
         DominationModeManager.instance.removeEventListener(DominationModeManager.MAX_FLEET_STRENGTH_UPDATED,this.onStrengthUpdated);
         super.dispose();
      }
      
      private function onStrengthUpdated(param1:WorldEvent) : void
      {
         this.updateStrengthLimitState(param1.eventData.remaining);
      }
      
      override protected function get canEnableAddButton() : Boolean
      {
         return this.m_state != DISABLED;
      }
      
      private function updateStrengthLimitState(param1:int = -1) : void
      {
         if(param1 == -1)
         {
            param1 = DominationModeManager.instance.getMaxRemainingSetupFleetStrength();
         }
         var _loc2_:int = m_unitItem.getUpgradedStrength();
         var _loc3_:Boolean = _loc2_ > param1;
         var _loc4_:int = _loc3_ ? DISABLED : ENABLED;
         if(_loc4_ != this.m_state)
         {
            if(_loc3_)
            {
               disable_visual();
               disableAddButton();
               addTooltip(ZGameUtils.ZlocT("Tooltips","PreBattleUnitExceedsFleetStrength"));
            }
            else
            {
               enable_visual();
               enableAddButton();
               removeTooltip();
            }
            this.m_state = _loc4_;
         }
      }
   }
}

