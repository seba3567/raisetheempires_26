package displays.popups.miniSeriesFinalReward
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import events.MarketEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.events.WorldEvent;
   
   public class MysteryCrateFinalReward extends MiniSeriesFinalReward
   {
      
      public function MysteryCrateFinalReward(param1:String, param2:String = null)
      {
         super(param1,param2);
      }
      
      override protected function initUI() : void
      {
         var _loc1_:Rectangle = null;
         var _loc8_:UnitItem = null;
         var _loc9_:ImageLoader = null;
         _loc1_ = getVisibleBounds(screen);
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         m_buttonSounds = new ButtonMouseEventSoundContainer();
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(m_quest) as ZGameQuest;
         var _loc3_:String = _loc2_.xml.reward[0].@item;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
         if(_loc4_.placeable)
         {
            m_button = new ZGameButton(screen.place_btn,this.onPlace);
            m_button.text = ZGameUtils.ZlocT("Dialogs","PlaceReward");
         }
         else
         {
            m_button = new ZGameButton(screen.place_btn,this.onOkay);
            m_button.text = ZGameUtils.ZlocT("Dialogs","Okay");
         }
         if(_loc4_.isUnit())
         {
            _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc4_.code,UnitItem) as UnitItem;
            TextFieldUtil.compactTextField(screen.finalReward_mc.strength_mc.value_tf,_loc8_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc8_.code)).toString());
            screen.finalReward_mc.strength_mc.visible = true;
         }
         else if(screen.finalReward_mc.strength_mc)
         {
            screen.finalReward_mc.strength_mc.visible = false;
         }
         TextFieldUtil.compactTextField(screen.header_tf,m_questTree.rewardTextHeader);
         TextFieldUtil.compactTextField(screen.header2_tf,m_questTree.rewardTextHeader2);
         var _loc5_:String = ZGameUtils.ZlocTP("QuestTrees",m_questTree.xml.ui.finalReward.@description + "_" + _loc2_.rewardCrateType);
         TextFieldUtil.compactTextField(screen.desc_tf,_loc5_);
         var _loc6_:String = ZGlobal.getAssetURL(_loc2_.advisorQuestPopupIconOverride);
         if(screen.uiloader_mc)
         {
            _loc9_ = ImageLoaderFactory.CreateImageLoader(_loc6_,screen.uiloader_mc);
            _loc9_.smooth = true;
            m_loaders.push(_loc9_);
         }
         switch(_loc2_.rewardCrateType)
         {
            case "S":
               screen.crate_mc_S.visible = true;
               screen.crate_mc_M.visible = false;
               screen.crate_mc_L.visible = false;
               screen.crate_mc_S.gotoAndPlay(1);
               break;
            case "M":
               screen.crate_mc_S.visible = false;
               screen.crate_mc_M.visible = true;
               screen.crate_mc_L.visible = false;
               screen.crate_mc_M.gotoAndPlay(1);
               break;
            case "L":
               screen.crate_mc_S.visible = false;
               screen.crate_mc_M.visible = false;
               screen.crate_mc_L.visible = true;
               screen.crate_mc_L.gotoAndPlay(1);
               break;
            default:
               if(screen.crate_mc_S)
               {
                  screen.crate_mc_S.visible = true;
                  screen.crate_mc_S.gotoAndPlay(1);
               }
               if(screen.crate_mc_M)
               {
                  screen.crate_mc_M.visible = false;
               }
               if(screen.crate_mc_L)
               {
                  screen.crate_mc_L.visible = false;
               }
         }
         screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit);
         m_buttonSounds.addButton(screen.exit_bt,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_button.m_overlay,ButtonSound.DEFAULT);
         var _loc7_:Object = _loc2_.getRewardTextObject(WorldResourceManager.XTRA_LARGE_ICON);
         TextFieldUtil.compactTextField(screen.finalReward_mc.itemName_tf,_loc7_.rewardText[0],{"minScale":0.7});
         _loc9_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon"),screen.finalReward_mc.icon);
         _loc9_.smooth = true;
         m_loaders.push(_loc9_);
         screen.gotoAndPlay(1);
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
      }
      
      override protected function onPlace(param1:MouseEvent) : void
      {
         close();
         ZGameQuestManager.instance.dispatchEvent(new WorldEvent(PlayerQuestTrees.FINAL_REWARD_PLACE));
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(m_quest) as ZGameQuest;
         var _loc3_:String = _loc2_.xml.reward[0].@item;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
         if(_loc4_)
         {
            GameModeManager.instance.addGameMode(new GMObjectPlace(_loc4_.name,MarketEvent.SOURCE_INVENTORY,true));
         }
      }
      
      protected function onOkay(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(m_quest) as ZGameQuest;
         var _loc3_:String = _loc2_.xml.reward[0].@item;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
         if(_loc4_)
         {
            GMObjectPlace.notifyPlacementPopup(_loc4_);
         }
         close();
      }
   }
}

