package core.ui.components.PortraitSlidePick
{
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class PortraitSlidePickPVPFriendDefend extends PortraitSlidePickPVP
   {
      
      public function PortraitSlidePickPVPFriendDefend(param1:IEntity, param2:IPVPPlayer, param3:Number, param4:Class, param5:Object)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function setButtons() : void
      {
         m_buttonSounds = new ButtonMouseEventSoundContainer();
         m_repelButton = new ZGameButton(slideCard.green_btn_1,onRepel);
         m_buttonSounds.addButton(m_repelButton.m_overlay,ButtonSound.DEFAULT);
         if(slideCard.green_btn_0)
         {
            slideCard.green_btn_0.visible = false;
         }
         if(slideCard.orange_btn)
         {
            slideCard.orange_btn.visible = false;
         }
         if(slideCard.green_btn_2)
         {
            slideCard.green_btn_2.visible = false;
         }
         if(slideCard.clock_mc)
         {
            slideCard.clock_mc.visible = false;
         }
      }
      
      override protected function getIconURL() : String
      {
         return "assets/game/GeneralAssetGroup_UI.swf/friendOccupied_icon_24.png";
      }
      
      override protected function setPickText() : void
      {
         var _loc1_:Object = PVPManager.instance.getNeighborAssist(ZGlobal.hostPlayer.uid);
         var _loc2_:String = _loc1_ ? _loc1_.invID : null;
         if(Boolean(_loc2_ && _loc2_ == m_neighbor.uid) && Boolean(_loc1_) && ChallengeModeManager.instance.isChallengeIDInProgress(_loc1_.chID))
         {
            m_repelButton.text = ZGameUtils.ZlocT("Dialogs","InProgressButton");
         }
         else
         {
            m_repelButton.text = ZGameUtils.ZlocT("Dialogs","Accept");
         }
         TextFieldUtil.processTextField(slideCard.title01_tf,ZGameUtils.ZlocT("Dialogs","friendDefendText"));
      }
   }
}

