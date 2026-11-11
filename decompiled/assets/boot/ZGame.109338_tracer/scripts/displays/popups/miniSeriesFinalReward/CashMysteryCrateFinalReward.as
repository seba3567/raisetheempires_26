package displays.popups.miniSeriesFinalReward
{
   import ZQuest.Init.QuestSettingsInit;
   import core.managers.WorldResourceManager;
   import core.managers.questManager.ZGameQuest;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   
   public class CashMysteryCrateFinalReward extends MysteryCrateFinalReward
   {
      
      public function CashMysteryCrateFinalReward(param1:String, param2:String = null)
      {
         super(param1,param2);
      }
      
      override protected function initUI() : void
      {
         var _loc1_:Rectangle = null;
         var _loc5_:Number = NaN;
         _loc1_ = getVisibleBounds(screen);
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         m_buttonSounds = new ButtonMouseEventSoundContainer();
         TextFieldUtil.compactTextField(screen.header_tf,ZGameUtils.ZlocT("QuestTrees","QT06_RewardDialogDesc_1"));
         screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit);
         m_buttonSounds.addButton(screen.exit_bt,ButtonSound.DEFAULT);
         m_button = new ZGameButton(screen.place_btn,onOkay);
         m_button.text = ZGameUtils.ZlocT("Dialogs","Okay");
         m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(m_quest) as ZGameQuest;
         var _loc3_:Object = _loc2_.getRewardTextObject(WorldResourceManager.XTRA_LARGE_ICON);
         TextFieldUtil.compactTextField(screen.finalReward_mc.itemName_tf,_loc3_.rewardText[0]);
         var _loc4_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[0],screen.finalReward_mc.icon);
         _loc4_.smooth = true;
         m_loaders.push(_loc4_);
         if(m_quest == "QT026_reward_b")
         {
            _loc5_ = Number(_loc3_.rewardPairs[0].count);
            TextFieldUtil.compactTextField(screen.finalReward_mc.qty_tf,"x" + _loc5_.toString());
         }
         screen.crate_mc_S.visible = true;
         screen.crate_mc_M.visible = false;
         screen.crate_mc_L.visible = false;
         screen.crate_mc_S.gotoAndPlay(1);
         screen.gotoAndPlay(1);
      }
   }
}

