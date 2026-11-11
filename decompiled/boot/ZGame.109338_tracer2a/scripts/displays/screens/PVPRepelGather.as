package displays.screens
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.PVPManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import transactions.TBuyCrewRepelPosition;
   import transactions.TCompleteSocialRepel;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class PVPRepelGather extends CrewResizablePopUp
   {
      
      private var m_invaderName:String;
      
      private var m_neighborID:String;
      
      private var m_repelButton:ZGameButton = null;
      
      private var m_repelShareButton:ZGameButton = null;
      
      public function PVPRepelGather(param1:CrewTemplateWrapper, param2:Array, param3:String, param4:String)
      {
         super(param1,param2,CrewGatherSlotOwnerPartial);
         this.m_invaderName = param3;
         this.m_neighborID = param4;
      }
      
      override protected function getAsset() : String
      {
         return "assets/displays/dialogs/PU_Pvp_Crew.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initRepelButtons();
         this.m_repelButton = new ZGameButton(m_mc.repel_bt,onConfirmClick);
         m_fixedButtonSounds.addButton(this.m_repelButton.m_overlay,ButtonSound.DEFAULT);
         this.m_repelShareButton = new ZGameButton(m_mc.share_bt,this.onConfirmShareClick);
         m_fixedButtonSounds.addButton(this.m_repelShareButton.m_overlay,ButtonSound.DEFAULT);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","PVPRepelGatherFinish");
         this.m_repelButton.compactText(_loc2_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         _loc2_ = ZGameUtils.ZlocT("Dialogs","PVPRepelGatherFinishShare");
         this.m_repelShareButton.compactText(_loc2_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.disableRepelButtons();
         initDialog();
         PVPManager.instance.addEventListener(PVPManager.REPEL_CREW_UPDATED,this.onRepelCrewUpdated,false,0,true);
      }
      
      override protected function setupText() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","PVPRepelGatherTitle");
         TextFieldUtil.processTextField(m_mc.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","PVPRepelGatherDialogDesc",{"invader":this.m_invaderName});
         TextFieldUtil.processTextField(m_mc.description_tf,_loc2_);
      }
      
      override protected function getButtonTextKey() : String
      {
         return canFinishBuilding() ? "PVPRepelGatherFinish" : "PVPAskForHelpButton";
      }
      
      override protected function showHireController() : void
      {
         ViralsManager.instance.requestRepelInvasionHelp(this.m_neighborID);
         closeWindow(null);
      }
      
      override protected function buyStaff(param1:int, param2:int) : void
      {
         ZGlobal.player.cash -= param1;
         TransactionManager.addTransaction(new TBuyCrewRepelPosition(this.m_neighborID,param1),true);
         m_crewInfo[param2] = Player.FAKE_PLAYER_ID;
         this.updateElements();
      }
      
      override protected function onConfirmFinish() : void
      {
         PVPManager.instance.completeSocialRepel(this.m_neighborID);
         TransactionManager.addTransaction(new TCompleteSocialRepel(this.m_neighborID),true);
      }
      
      private function onConfirmShareClick(param1:MouseEvent) : void
      {
         if(canFinishBuilding())
         {
            this.onConfirmFinish();
            ViralsManager.instance.feedPVPDefeatAttackerViaCrew(this.m_invaderName);
            closeWindow(param1);
         }
         else
         {
            this.showHireController();
         }
      }
      
      override protected function onWidthSet(param1:uint) : void
      {
         var _loc2_:uint = dialogWidth - param1;
         mc.speechBubble_mc.width += _loc2_;
         var _loc3_:Number = 0;
         if(ZGlobal.localizer.localeCode == "ja_JP")
         {
            _loc3_ = 10;
         }
         mc.description_tf.width += _loc2_ - _loc3_;
      }
      
      override protected function get dialogPaddingTop() : uint
      {
         return 140;
      }
      
      override protected function updateElements() : void
      {
         super.updateElements();
         if(canFinishBuilding())
         {
            this.enableRepelButtons();
         }
         else
         {
            this.disableRepelButtons();
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         PVPManager.instance.removeEventListener(PVPManager.REPEL_CREW_UPDATED,this.onRepelCrewUpdated);
         if(this.m_repelButton != null)
         {
            this.m_repelButton.dispose();
            this.m_repelButton = null;
         }
         if(this.m_repelShareButton != null)
         {
            this.m_repelShareButton.dispose();
            this.m_repelShareButton = null;
         }
      }
      
      private function initRepelButtons() : void
      {
         var _loc1_:int = dialogHeight;
         _loc1_ -= m_mc.repel_bt.height * 0.5;
         m_mc.repel_bt.y = _loc1_;
         m_mc.repel_bt.x = (dialogWidth - m_mc.repel_bt.width - m_mc.share_bt.width) * 0.5 * 0.75;
         _loc1_ = dialogHeight;
         _loc1_ -= m_mc.share_bt.height * 0.5;
         m_mc.share_bt.y = _loc1_;
         var _loc2_:Number = m_mc.repel_bt.x + m_mc.repel_bt.width;
         m_mc.share_bt.x = _loc2_ + (dialogWidth - _loc2_ - m_mc.share_bt.width) * 0.5;
      }
      
      private function disableRepelButtons() : void
      {
         m_mc.build_bt.visible = true;
         m_confirmButton.enable();
         if(this.m_repelButton)
         {
            m_mc.repel_bt.visible = false;
            this.m_repelButton.disable();
         }
         if(this.m_repelShareButton)
         {
            m_mc.share_bt.visible = false;
            this.m_repelShareButton.disable();
         }
      }
      
      private function enableRepelButtons() : void
      {
         m_mc.build_bt.visible = false;
         m_confirmButton.disable();
         if(this.m_repelButton)
         {
            m_mc.repel_bt.visible = true;
            this.m_repelButton.enable();
         }
         if(this.m_repelShareButton)
         {
            m_mc.share_bt.visible = true;
            this.m_repelShareButton.enable();
         }
      }
      
      private function onRepelCrewUpdated(param1:WorldEvent) : void
      {
         if(param1.eventData.invader == this.m_neighborID)
         {
            m_crewInfo = param1.eventData.crew;
            this.updateElements();
         }
      }
   }
}

