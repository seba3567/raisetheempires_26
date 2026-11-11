package displays.popups.quest
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.GoldenStatueDialogState;
   import core.gameobjects.GameItem;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.MegaseriesManager;
   import core.managers.QuestBuildableManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.player.questTrees.QuestTree;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.AllianceQuestMain;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.MegaseriesPlayAgain;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.popups.megaseries.MegaseriesDetailsPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class QuestCompletePopup extends QuestPopup
   {
      
      public static const EVENT_QUEST_COMPLETE_POPUP_CLOSED:String = "questCompletePopupClosed";
      
      private var m_closeCallback:Function = null;
      
      private var m_loaders:Array = null;
      
      private var m_questId:String = null;
      
      private var m_buyButtons:Array = null;
      
      private var m_buyPopup:GenericPopup;
      
      private var m_allianceRewards:int = 0;
      
      private var m_allianceRewardsSet:Boolean = false;
      
      public function QuestCompletePopup(param1:String, param2:Function)
      {
         super(param1,true);
         this.m_questId = param1;
         if(questTree != null)
         {
            if(questTree.isQuestTreeDialogActive)
            {
            }
         }
         if(null != param2)
         {
            this.m_closeCallback = param2;
            addEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback,false,0,true);
         }
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window;
      }
      
      override protected function getTextObject(param1:String) : Object
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         return _loc2_.getRewardTextObject();
      }
      
      public function set allianceRewards(param1:int) : void
      {
         this.m_allianceRewards = param1;
         this.m_allianceRewardsSet = true;
      }
      
      protected function get numRewards() : int
      {
         var _loc3_:String = null;
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_questId) as ZGameQuest;
         if(_loc1_.isAllianceQuest && this.m_allianceRewardsSet)
         {
            return this.m_allianceRewards;
         }
         var _loc2_:int = 0;
         for each(_loc3_ in textObj.rewardText)
         {
            _loc2_ += 1;
         }
         return _loc2_;
      }
      
      private function getRewardClips() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_questId) as ZGameQuest;
         if(this.screen.rewards_four)
         {
            this.screen.rewards_four.visible = false;
         }
         if(Boolean(_loc2_) && Boolean(_loc2_.isAllianceQuest) && this.numRewards == 4)
         {
            _loc1_ = [this.screen.rewards_four.reward1_mc,this.screen.rewards_four.reward2_mc,this.screen.rewards_four.reward3_mc,this.screen.rewards_four.reward4_mc];
            this.screen.rewards_even.visible = false;
            this.screen.rewards_odd.visible = false;
            this.screen.rewards_four.visible = true;
            this.screen.rewards_four.alpha = 1;
            return _loc1_;
         }
         if(this.numRewards == 0)
         {
            _loc1_ = [];
            this.screen.rewards_even.visible = false;
            this.screen.rewards_odd.visible = false;
         }
         else if(this.numRewards % 2 == 0)
         {
            _loc1_ = [this.screen.rewards_even.reward1_mc,this.screen.rewards_even.reward2_mc];
            this.screen.rewards_even.visible = true;
            this.screen.rewards_odd.visible = false;
         }
         else if(_loc2_.isAllianceQuest && this.numRewards == 1)
         {
            _loc1_ = [this.screen.rewards_odd.reward2_mc];
            this.screen.rewards_odd.reward1_mc.visible = false;
            this.screen.rewards_odd.reward3_mc.visible = false;
            this.screen.rewards_even.visible = false;
            this.screen.rewards_odd.visible = true;
         }
         else
         {
            _loc1_ = [this.screen.rewards_odd.reward2_mc,this.screen.rewards_odd.reward1_mc,this.screen.rewards_odd.reward3_mc];
            this.screen.rewards_even.visible = false;
            this.screen.rewards_odd.visible = true;
         }
         return _loc1_;
      }
      
      private function onContinueClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function setUpQuestUI() : void
      {
         var _loc4_:String = null;
         var _loc5_:ImageLoader = null;
         var _loc6_:GameItem = null;
         var _loc7_:String = null;
         var _loc8_:ZGameButton = null;
         var _loc9_:Object = null;
         super.setUpQuestUI();
         this.screen.visible = true;
         if(questTree != null && !questTree.isQuestTreeDialogActive && !m_isQuestTree)
         {
            enableAcceptButtonArt(true);
            m_acceptBt = new ZGameButton(this.screen.accept_bt,this.onContinueClicked);
            m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","DominationContinue");
            m_buttonSounds.addButton(m_acceptBt.m_overlay,ButtonSound.DEFAULT);
            TextFieldUtil.compactTextField(this.screen.note_tf,"");
         }
         else if(MegaseriesManager.instance.isMegaseriesReward(id))
         {
            enableAcceptButtonArt(true);
            m_acceptBt = new ZGameButton(this.screen.accept_bt,this.onPlaceMSRewardClicked);
            m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","PlaceReward");
            m_buttonSounds.addButton(m_acceptBt.m_overlay,ButtonSound.DEFAULT);
            TextFieldUtil.compactTextField(this.screen.note_tf,"");
         }
         else if(shouldShowAcceptButton())
         {
            enableAcceptButtonArt(true);
            m_acceptBt = new ZGameButton(this.screen.accept_bt,this.onShareClicked);
            m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","ShareRewards");
            m_buttonSounds.addButton(m_acceptBt.m_overlay,ButtonSound.DEFAULT);
            if(this.screen.note_tf)
            {
               TextFieldUtil.compactTextField(this.screen.note_tf,ZGameUtils.ZlocT("Dialogs","FeedPublishDesc"));
            }
         }
         else
         {
            enableAcceptButtonArt(false);
         }
         this.m_loaders = new Array();
         if(m_isQuestTree)
         {
            TextFieldUtil.compactTextField(this.screen.title01_tf,ZGameUtils.ZlocT("Dialogs","Rewards"));
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen.title01_tf,ZGameUtils.ZlocT("Dialogs","QuestRewards"));
         }
         TextFieldUtil.compactTextField(this.screen.goal_tf,ZGameUtils.ZlocT("Dialogs","QuestCompleted"));
         TextFieldUtil.compactTextField(this.screen.popupBox_tf,textObj.desc,{"filter":"ignore"});
         var _loc1_:String = MegaseriesManager.instance.isMegaseriesReward(id);
         if(_loc1_ != null)
         {
            TextFieldUtil.compactTextField(this.screen.title01_tf,ZGameUtils.ZlocT("QuestTrees","Reward"));
            TextFieldUtil.compactTextField(this.screen.goal_tf,ZGameUtils.ZlocT("Dialogs","FirstVictoryTitle"));
            if(this.screen.popupBox_tf)
            {
               TextFieldUtil.compactTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Megaseries",_loc1_ + "_megaseries_reward_desc"),{"minScale":1.1});
            }
         }
         var _loc2_:Array = this.getRewardClips();
         this.m_buyButtons = new Array();
         var _loc3_:int = 0;
         for each(_loc4_ in textObj.rewardText)
         {
            if(_loc3_ < _loc2_.length)
            {
               _loc2_[_loc3_].visible = true;
               TextFieldUtil.compactTextField(_loc2_[_loc3_].name_tf,_loc4_,{"minScale":0.65});
               _loc5_ = ImageLoaderFactory.CreateImageLoader(textObj.rewardIcons[_loc3_],_loc2_[_loc3_].uiloader_mc);
               _loc5_.smooth = true;
               this.m_loaders.push(_loc5_);
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_REWARD_BUY) == 2)
               {
                  if(_loc2_[_loc3_].buy_bt != null)
                  {
                     if(textObj.rewardBuyable[_loc3_] == true)
                     {
                        _loc6_ = ZGlobal.gameSettings.getItemByCode(textObj.rewardItems[_loc3_],GameItem) as GameItem;
                        _loc7_ = ZGameUtils.ZlocT("Dialogs","BuyOneMoreForAmount",{"amount":_loc6_.cash});
                        _loc8_ = new ZGameButton(_loc2_[_loc3_].buy_bt,this.onBuyClick);
                        TextFieldUtil.compactTextField(_loc2_[_loc3_].buy_bt.generic_tf,_loc7_);
                        _loc2_[_loc3_].buy_bt.visible = true;
                        _loc9_ = new Object();
                        _loc9_.item = _loc6_;
                        _loc9_.button = _loc8_;
                        this.m_buyButtons.push(_loc9_);
                     }
                     else
                     {
                        _loc2_[_loc3_].buy_bt.visible = false;
                     }
                  }
               }
               else if(_loc2_[_loc3_].buy_bt != null)
               {
                  _loc2_[_loc3_].buy_bt.visible = false;
               }
            }
            _loc3_++;
         }
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_].visible = false;
            _loc3_++;
         }
         SoundEvent.getSoundEvent("QuestComplete").play();
      }
      
      private function onBuyClick(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_questId) as ZGameQuest;
         var _loc3_:GameItem = null;
         for each(_loc4_ in this.m_buyButtons)
         {
            if(_loc4_.button == param1.target.buttonPointer)
            {
               _loc3_ = _loc4_.item;
               if(ZGlobal.player.canBuyCash(_loc3_.cash,false))
               {
                  if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_.cash))
                  {
                     _loc5_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc3_.cash));
                     _loc6_ = new Array("EmpirePointsConfirm","","","");
                     this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,null,this.onBuyConfirmed,_loc6_);
                     this.m_buyPopup.userData = _loc3_;
                     PopupManager.instance.push(this.m_buyPopup,0,false);
                  }
                  else
                  {
                     ZGlobal.player.buyRewardItem(_loc3_,1,this.m_questId);
                     _loc7_ = _loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     if(null == _loc7_)
                     {
                        _loc7_ = "";
                     }
                     PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","PurchasedItem",{
                        "num":1,
                        "item":_loc7_
                     })),0,false);
                  }
               }
               else
               {
                  PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash")),0,false);
               }
               break;
            }
         }
      }
      
      private function onPlaceMSRewardClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = (QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest).placeableReward;
         MegaseriesManager.instance.dispatchEvent(new WorldEvent(MegaseriesManager.MEGASERIES_REWARD_ACCEPT,{"item":_loc2_}));
         param1.stopPropagation();
         this.close();
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:String = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData as GameItem;
            _loc3_ = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            if(null == _loc3_)
            {
               _loc3_ = "";
            }
            ZGlobal.player.buyRewardItem(_loc2_,1,this.m_questId);
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","PurchasedItem",{
               "num":1,
               "item":_loc3_
            })),0,false);
         }
         this.m_buyPopup = null;
      }
      
      private function onShareClicked(param1:MouseEvent) : void
      {
         var _loc2_:Object = new Object();
         if(textObj != null && textObj.title != null)
         {
            _loc2_.title = textObj.title;
         }
         _loc2_.id = id;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT,_loc2_));
         param1.stopPropagation();
         this.close();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:Object = null;
         super.deinitDialog();
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         if(m_acceptBt)
         {
            m_acceptBt.dispose();
            m_acceptBt = null;
         }
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
            this.m_closeCallback = null;
         }
         if(this.m_buyButtons != null)
         {
            for each(_loc2_ in this.m_buyButtons)
            {
               _loc2_ = null;
            }
            this.m_buyButtons = null;
         }
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,id));
         UIDispatcher.instance.dispatchEvent(new Event(QuestCompletePopup.EVENT_QUEST_COMPLETE_POPUP_CLOSED));
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc3_:ZGameQuest = null;
         var _loc4_:Array = null;
         super.close(param1);
         if(ZGlobal.player.questTrees.isQuestTreeQuest(id))
         {
            PlayerQuestTrees.checkFinalReward(id);
         }
         if(questTree != null && !questTree.isQuestTreeComplete() && !questTree.isQuestTreeDialogActive)
         {
            QuestTree.showScreen(questTree.id,"loginQuestComplete");
         }
         var _loc2_:String = MegaseriesManager.instance.isMegaseriesQuest(id);
         if(_loc2_)
         {
            if(MegaseriesManager.instance.isMegaseriesStageCompletion(id))
            {
               MegaseriesManager.instance.notifyMSStageCompletion(_loc2_,{"questId":id});
            }
            else
            {
               _loc3_ = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
               _loc4_ = _loc3_.sequels;
               if(!MegaseriesManager.instance.isMegaseriesReward(_loc4_[0]))
               {
                  MegaseriesDetailsPopup.show(_loc4_[0],_loc2_);
               }
            }
         }
         if(Boolean(MegaseriesManager.instance.isMegaseriesReward(id)) && MegaseriesManager.instance.getStateMachineName(MegaseriesManager.instance.isMegaseriesReward(id)) == MegaseriesManager.MEGASERIES_STATEMACHINE_NAME)
         {
            PopupManager.instance.push(new MegaseriesPlayAgain(MegaseriesManager.instance.isMegaseriesReward(id)));
         }
         if(id == "QB002" || id == "QB003" || id == "QB004")
         {
            QuestBuildableManager.instance.dispatchEvent(new Event(GoldenStatueDialogState.SHOWUI));
         }
         else if(id == "QALL1" || id == "QALL2" || id == "QALL3")
         {
            if(!AlliancesManager.instance.isInitialised())
            {
               PopupManager.instance.push(new AllianceQuestMain());
            }
         }
      }
      
      override protected function getWindowClass(param1:SWFResource) : Class
      {
         if(MegaseriesManager.instance.isMegaseriesReward(id) != null && MegaseriesManager.instance.isMegaseriesReward(id) != "MS01")
         {
            return param1.getAssetClass("victory_mc");
         }
         return param1.getAssetClass("questCompleted_mc");
      }
   }
}

