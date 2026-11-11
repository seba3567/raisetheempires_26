package displays.screens.neighborScreen
{
   import core.managers.PVPManager;
   import displays.popups.PVPSlotMachinePopup;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import zgame.assets.ui.StrangerBar.StrangerSlot;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class StrangerGridBlankSlot extends GridSlot
   {
      
      private var m_strangerSlotIndex:int = PVPManager.globalPVPMaxProgress;
      
      private var m_helper:StrangerGridSlotHelper;
      
      public function StrangerGridBlankSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip)
      {
         super(param1,param2,param3);
         this.m_helper = new StrangerGridSlotHelper(slot,this.m_strangerSlotIndex);
         this.m_helper.levelsVisible = false;
         this.m_helper.rewardIconVisible = true;
         var _loc4_:int = PVPManager.instance.globalPVPWinProgress;
         if(_loc4_ == PVPManager.globalPVPMaxProgress)
         {
            this.enableSlot();
            this.m_helper.slideNeighborGrid(0);
         }
         PVPManager.instance.addEventListener(PVPManager.GPVP_AWARD_CLAIMED,this.onAwardClaimed,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.GPVP_WINS_CHANGED,this.onWinsChanged,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.m_helper.dispose();
         this.m_helper = null;
         PVPManager.instance.removeEventListener(PVPManager.GPVP_AWARD_CLAIMED,this.onAwardClaimed);
         PVPManager.instance.removeEventListener(PVPManager.GPVP_WINS_CHANGED,this.onWinsChanged);
      }
      
      private function onAwardClaimed(param1:WorldEvent) : void
      {
         if(PVPManager.instance.globalPVPWinProgress == this.m_strangerSlotIndex)
         {
            this.m_helper.slideNeighborGrid(0);
         }
      }
      
      private function updateUnlockButton() : void
      {
         this.m_helper.initializeUnlockButton(true);
         this.m_helper.unlockButtonVisible = this.claimable;
      }
      
      private function onUnlockClicked(param1:MouseEvent) : void
      {
         if(this.claimable)
         {
            WindowManager.instance.push(new PVPSlotMachinePopup());
         }
      }
      
      private function get claimable() : Boolean
      {
         var _loc1_:int = PVPManager.instance.globalPVPWinProgress;
         return _loc1_ == PVPManager.globalPVPMaxProgress;
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         return new StrangerSlot();
      }
      
      private function onWinsChanged(param1:WorldEvent) : void
      {
         if(param1.eventData.newValue == this.m_strangerSlotIndex)
         {
            this.enableSlot();
         }
      }
      
      private function enableSlot() : void
      {
         slot.door_mc.gotoAndPlay("_reveal1");
         this.updateUnlockButton();
      }
      
      override public function get hasContextMenu() : Boolean
      {
         return false;
      }
   }
}

