package displays.popups.megaseries
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.MegaseriesManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.MOTDCountdownClock;
   import displays.popups.quest.QuestDetailsPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TBuyQuestTask;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MegaseriesDetailsPopup extends QuestDetailsPopup
   {
      
      private static var m_questOnQueue:String;
      
      private static var m_msIdOnQueue:String;
      
      private var m_buyPopup:GenericPopup;
      
      private var m_megaSereisCode:String;
      
      private var m_megaseriesId:String;
      
      private var m_megaseriesPopup:String;
      
      protected var m_clock:MOTDCountdownClock;
      
      protected var m_button:ZGameButton;
      
      public function MegaseriesDetailsPopup(param1:String, param2:String)
      {
         this.m_megaseriesId = param2;
         super(param1);
      }
      
      public static function show(param1:String, param2:String) : void
      {
         var _loc5_:ZGamePopUp = null;
         if(m_questOnQueue)
         {
            return;
         }
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc4_:Object = (QuestManager.getInstance() as ZGameQuestManager).getTextObject(param1);
         if(_loc4_.hasOwnProperty("taskText"))
         {
            _loc5_ = new MegaseriesDetailsPopup(param1,param2);
            PopupManager.instance.push(_loc5_);
         }
         else if(param1 != MegaseriesManager.instance.getMegaseries(param2).msRewardQuest)
         {
            m_questOnQueue = param1;
            m_msIdOnQueue = param2;
            QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,displayFromQueue);
         }
      }
      
      private static function displayFromQueue(param1:QuestEvent) : void
      {
         var _loc2_:ZGamePopUp = null;
         if(param1.quest.name == m_questOnQueue)
         {
            QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,displayFromQueue);
            _loc2_ = new MegaseriesDetailsPopup(m_questOnQueue,m_msIdOnQueue);
            PopupManager.instance.push(_loc2_);
            m_questOnQueue = null;
            m_msIdOnQueue = null;
         }
      }
      
      private function startDateTimer() : void
      {
         this.stopDateTimer();
         Zlab.processManager.schedule(1000,this,this.onDateTimer);
      }
      
      private function stopDateTimer() : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onDateTimer() : void
      {
         this.updateDate();
      }
      
      override protected function updateDate() : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(_loc3_)
         {
            _loc1_ = _loc3_.hasDate;
            _loc2_ = _loc3_.hasLifeTime;
            if(_loc1_)
            {
               TextFieldUtil.processTextField(this.screen.limited_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionBanner"));
               _loc4_ = new Object();
               _loc5_ = ZGameTimeUtil.instance.getDateStatus(_loc4_,_loc3_.xml);
               if(_loc5_ == ZGameTimeUtil.DATE_STATUS_LATE)
               {
                  QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_COMPLETE,{"name":_loc3_.name}));
               }
               else
               {
                  this.m_clock = new MOTDCountdownClock(this.screen.clock_mc,_loc3_.xml,true);
                  TextFieldUtil.processTextField(this.screen.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionCountdown",{"time":_loc4_.string}));
                  this.startDateTimer();
               }
            }
            if(_loc2_)
            {
               _loc6_ = ZGameTimeUtil.instance.getClockString(_loc3_.getTimeRemaining());
               TextFieldUtil.processTextField(this.screen.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionCountdown",{"time":_loc6_}));
               this.startDateTimer();
            }
         }
         if(this.screen.limited_tf)
         {
            this.screen.daysLeft_tf.visible = _loc1_ || _loc2_;
            this.screen.limited_tf.visible = _loc1_;
         }
         if(this.m_megaseriesId == "MS08")
         {
            this.screen.clock_mc.visible = false;
         }
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window;
      }
      
      override protected function getTextObject(param1:String) : Object
      {
         return (QuestManager.getInstance() as ZGameQuestManager).getTextObject(param1);
      }
      
      private function getRewardTextObject() : Object
      {
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         return _loc1_.getRewardTextObject(WorldResourceManager.SMALL_ICON);
      }
      
      override protected function addTitleText(param1:MovieClip) : void
      {
         var _loc3_:UnitItem = null;
         var _loc4_:UnitItem = null;
         var _loc5_:UnitItem = null;
         var _loc6_:ImageLoader = null;
         var _loc7_:ImageLoader = null;
         var _loc8_:ImageLoader = null;
         var _loc2_:Object = {
            "minScale":0.7,
            "filter":"ignore"
         };
         if(param1.hasOwnProperty("hint_tf") && Boolean(param1.hint_tf.hasOwnProperty("description_tf")))
         {
            TextFieldUtil.compactTextField(param1.hint_tf.description_tf,textObj.hint,_loc2_);
         }
         if(Boolean(this.m_megaseriesId == "MS05" && param1.hasOwnProperty("hint_tf")) && Boolean(param1.hint_tf.hasOwnProperty("icon1")) && Boolean(param1.hint_tf.hasOwnProperty("icon2")) && Boolean(param1.hint_tf.hasOwnProperty("icon3")) && Boolean(param1.hint_tf.hasOwnProperty("name1_tf")) && Boolean(param1.hint_tf.hasOwnProperty("name2_tf")) && Boolean(param1.hint_tf.hasOwnProperty("name3_tf")))
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode("UC26",UnitItem) as UnitItem;
            _loc4_ = ZGlobal.gameSettings.getItemByCode("UC27",UnitItem) as UnitItem;
            _loc5_ = ZGlobal.gameSettings.getItemByCode("UC28",UnitItem) as UnitItem;
            _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"icon"),param1.hint_tf.icon1);
            _loc6_.smooth = true;
            _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon"),param1.hint_tf.icon2);
            _loc7_.smooth = true;
            _loc8_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc5_.name,"icon"),param1.hint_tf.icon3);
            _loc8_.smooth = true;
            TextFieldUtil.compactTextField(param1.hint_tf.name1_tf,_loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(param1.hint_tf.name2_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(param1.hint_tf.name3_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         }
         if(param1.hasOwnProperty("desc_tf"))
         {
            TextFieldUtil.compactTextField(param1.desc_tf,textObj.desc,_loc2_);
         }
         if(param1.hasOwnProperty("hint_tf") && Boolean(param1.hint_tf.hasOwnProperty("title_tf")))
         {
            TextFieldUtil.compactTextField(param1.hint_tf.title_tf,ZGameUtils.ZlocT("QuestTrees","Hint"),_loc2_);
            param1.hint_tf.visible = false;
         }
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData as String;
            _loc3_ = int(_loc2_);
            this.buyTask(_loc3_);
         }
         this.m_buyPopup = null;
      }
      
      private function buyTask(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:TBuyQuestTask = null;
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc3_:Array = _loc2_.getQuestTasks(m_id);
         if(param1 < _loc3_.length)
         {
            _loc4_ = int(_loc3_[param1].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            ZGlobal.player.cash -= _loc4_;
            _loc3_[param1].buyCompletion();
            _loc5_ = new TBuyQuestTask(id,param1,_loc4_);
            TransactionManager.addTransaction(_loc5_,true);
            _loc5_ = null;
         }
      }
      
      override protected function onAcceptClicked() : void
      {
         super.onAcceptClicked();
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(Boolean(_loc1_) && Boolean(_loc1_.onDialogClosedShowInviteTabView))
         {
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST,_loc1_.onDialogClosedShowInviteTabView,null,null,true);
         }
      }
      
      override protected function shouldShowAcceptButton() : Boolean
      {
         return !m_isQuestTree;
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc3_:GameItem = null;
         var _loc4_:Number = NaN;
         var _loc5_:Array = null;
         this.closeBuyConfirmation();
         m_questOnQueue = null;
         m_msIdOnQueue = null;
         super.close();
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(_loc2_)
         {
            if(Boolean(_loc2_.placeObjectOnQuestDialogClosed) && ZGlobal.isHome())
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.placeObjectOnQuestDialogClosed,GameItem) as GameItem;
               if(_loc3_)
               {
                  if(ZGlobal.player.getNumberOfInventoryItems(_loc2_.placeObjectOnQuestDialogClosed) > 0)
                  {
                     GameModeManager.instance.addGameMode(new GMObjectPlace(_loc3_.name,MarketEvent.SOURCE_INVENTORY,true));
                  }
               }
            }
         }
         if(Boolean(_loc2_) && (_loc2_.firstArmyResearchQuest || _loc2_.firstNavyResearchQuest || _loc2_.firstAirResearchQuest))
         {
            ZGlobal.player.setSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG);
         }
         if(this.m_megaseriesId == "MS09" || this.m_megaseriesId == "MS10" || this.m_megaseriesId == "MS11" || this.m_megaseriesId == "MS12")
         {
            _loc4_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).activeQuestNumber;
            _loc5_ = [this.screen.tab1_mc,this.screen.tab2_mc,this.screen.tab3_mc];
            _loc5_[_loc4_].removeEventListener(MouseEvent.CLICK,this.onShowQuest);
         }
      }
      
      private function closeBuyConfirmation() : void
      {
         if(this.m_buyPopup)
         {
            this.m_buyPopup.closeWindow();
            this.m_buyPopup = null;
         }
      }
      
      private function clearButtonsForTask(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(m_dialogButtons)
         {
            _loc2_ = 0;
            while(_loc2_ < m_dialogButtons.length)
            {
               _loc3_ = m_dialogButtons[_loc2_];
               if(_loc3_.taskIndex == param1)
               {
                  if(_loc3_.button)
                  {
                     _loc3_.button.dispose();
                     _loc3_.button = null;
                  }
                  m_dialogButtons.splice(_loc2_,1);
               }
               else
               {
                  _loc2_++;
               }
            }
         }
      }
      
      override protected function getWindowClass(param1:SWFResource) : Class
      {
         var _loc2_:uint = 1;
         if(textObj.taskText)
         {
            _loc2_ = uint(textObj.taskText.length);
         }
         switch(_loc2_)
         {
            case 1:
               return param1.getAssetClass("quest01_mc");
            case 2:
               return param1.getAssetClass("quest02_mc");
            case 3:
               return param1.getAssetClass("quest03_mc");
            default:
               Logger.error(this,"getWindowClass","no window class for " + _loc2_ + " tasks in quest " + m_id);
               return null;
         }
      }
      
      private function onBattleStart(param1:Event) : void
      {
         this.close();
      }
      
      override protected function getTasks() : Array
      {
         var _loc1_:MovieClip = this.screen;
         if(this.m_megaseriesId == "MS09" || this.m_megaseriesId == "MS10" || this.m_megaseriesId == "MS11" || this.m_megaseriesId == "MS12")
         {
            return [_loc1_.questDetails_mc.requirement1_mc,_loc1_.questDetails_mc.requirement2_mc,_loc1_.questDetails_mc.requirement3_mc];
         }
         return [_loc1_.requirement1_mc,_loc1_.requirement2_mc,_loc1_.requirement3_mc];
      }
      
      override protected function setUpQuestUI() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Array = null;
         if(this.m_megaseriesId == "MS09" || this.m_megaseriesId == "MS10" || this.m_megaseriesId == "MS11" || this.m_megaseriesId == "MS12")
         {
            _loc1_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).activeQuestNumber;
            _loc2_ = [this.screen.tab1_mc,this.screen.tab2_mc,this.screen.tab3_mc];
            _loc2_[_loc1_].addEventListener(MouseEvent.CLICK,this.onShowQuest);
            this.screen.questDetails_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClick);
         }
         super.setUpQuestUI();
         this.updateDate();
         this.setRewardDetails();
         this.setUpTabs();
         this.setUpInfoBtn();
         this.setUpMainReward();
         this.screen.accept_bt.visible = false;
      }
      
      public function onShowQuest(param1:MouseEvent) : void
      {
         this.screen.questDetails_mc.visible = true;
         this.screen.questDetails_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClick);
      }
      
      protected function onExitClick(param1:MouseEvent) : void
      {
         this.screen.questDetails_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClick);
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         this.screen.questDetails_mc.visible = false;
      }
      
      private function setUpMainReward() : void
      {
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:ImageLoader = null;
         var _loc7_:ImageLoader = null;
         var _loc8_:UnitItem = null;
         var _loc9_:MovieClip = null;
         if(this.m_megaseriesId == "MS09")
         {
            this.setUpMainRewardForMS09();
         }
         else
         {
            _loc4_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId) ? MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).displayReward : null;
            if(_loc4_ != null)
            {
               if(Boolean(this.screen.mainReward_mc.instructions_tf) && (this.m_megaseriesId == "MS07" || this.m_megaseriesId == "MS08"))
               {
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.instructions_tf,ZGameUtils.ZlocT("Megaseries","MS07_megaseries_reward_desc_2"));
               }
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
               if(_loc5_)
               {
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc5_.name,"icon"),this.screen.mainReward_mc.icon);
                  _loc6_.smooth = true;
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"));
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.name_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
                  if(this.screen.titleReward_mc)
                  {
                     _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc5_.name,"icon"),this.screen.titleReward_mc.icon);
                     _loc7_.smooth = true;
                  }
                  if(Boolean(this.screen.mainReward_mc.tier_mc) && Boolean(this.screen.mainReward_mc.strength_mc) && Boolean(this.screen.mainReward_mc.tier_mc.tier_tf) && Boolean(this.screen.mainReward_mc.strength_mc.strength_tf))
                  {
                     _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
                     TextFieldUtil.compactTextField(this.screen.mainReward_mc.tier_mc.tier_tf,String(_loc8_.tier));
                     TextFieldUtil.compactTextField(this.screen.mainReward_mc.strength_mc.strength_tf,String(_loc8_.getStrength(null,null)));
                  }
               }
            }
         }
         var _loc1_:Number = 0;
         var _loc2_:Array = [this.screen.mainReward_mc.lock1_mc,this.screen.mainReward_mc.lock2_mc,this.screen.mainReward_mc.lock3_mc];
         var _loc3_:Object = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId) ? MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).progress : null;
         if(_loc3_ != null)
         {
            for each(_loc9_ in _loc2_)
            {
               if(_loc1_ < _loc3_.completed)
               {
                  _loc9_.gotoAndStop(2);
               }
               _loc1_++;
            }
         }
      }
      
      private function setUpMainRewardForMS09() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:ImageLoader = null;
         var _loc3_:ImageLoader = null;
         var _loc4_:UnitItem = null;
         var _loc5_:int = 0;
         var _loc8_:String = null;
         var _loc6_:Array = MegaseriesManager.instance.getStageReward(this.m_megaseriesId);
         var _loc7_:Object = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId) ? MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).progress : null;
         if(_loc7_.completed < 2)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(_loc6_[_loc7_.completed],GameItem) as GameItem;
            if(_loc1_)
            {
               _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon"),this.screen.mainReward_mc.icon);
               _loc2_.smooth = true;
               _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon"),this.screen.titleReward_mc.icon);
               _loc3_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.mainReward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"));
               TextFieldUtil.compactTextField(this.screen.mainReward_mc.name_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc6_[_loc7_.completed],UnitItem) as UnitItem;
               _loc5_ = _loc4_.tier;
               TextFieldUtil.compactTextField(this.screen.mainReward_mc.tier_mc.tier_tf,String(_loc5_));
               TextFieldUtil.compactTextField(this.screen.mainReward_mc.strength_mc.strength_tf,String(_loc4_.getStrength(null,null)));
            }
         }
         else
         {
            _loc8_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId) ? MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).displayReward : null;
            if(_loc8_ != null)
            {
               this.screen.mainReward_mc.instructions_tf.visible = false;
               _loc1_ = ZGlobal.gameSettings.getItemByCode(_loc8_,GameItem) as GameItem;
               if(_loc1_)
               {
                  _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon"),this.screen.mainReward_mc.icon);
                  _loc2_.smooth = true;
                  _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon"),this.screen.titleReward_mc.icon);
                  _loc3_.smooth = true;
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"));
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.name_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
                  _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc8_,UnitItem) as UnitItem;
                  _loc5_ = _loc4_.tier;
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.tier_mc.tier_tf,String(_loc5_));
                  TextFieldUtil.compactTextField(this.screen.mainReward_mc.strength_mc.strength_tf,String(_loc4_.getStrength(null,null)));
               }
            }
         }
      }
      
      private function setUpInfoBtn() : void
      {
         var _loc1_:ZGameButton = new ZGameButton(this.screen.info_bt,this.onShowInfo,1.1,false,this.onHideInfo,this.onShowInfo);
      }
      
      private function onShowInfo(param1:MouseEvent) : void
      {
         this.screen.hint_tf.visible = true;
      }
      
      private function onHideInfo(param1:MouseEvent) : void
      {
         this.screen.hint_tf.visible = false;
      }
      
      private function setRewardDetails() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Number = NaN;
         var _loc3_:Array = null;
         var _loc4_:MovieClip = null;
         var _loc5_:ImageLoader = null;
         if(this.m_megaseriesId == "MS09" || this.m_megaseriesId == "MS10" || this.m_megaseriesId == "MS11" || this.m_megaseriesId == "MS12")
         {
            this.setRewardDetailsForMS09();
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen.rewards_tf,ZGameUtils.ZlocT("Dialogs","Rewards"));
            _loc1_ = this.getRewardTextObject();
            _loc2_ = 0;
            _loc3_ = [this.screen.reward1_mc,this.screen.reward2_mc,this.screen.reward3_mc];
            for each(_loc4_ in _loc3_)
            {
               TextFieldUtil.compactTextField(_loc4_.name_tf,_loc1_.rewardText[_loc2_]);
               _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc1_.rewardIcons[_loc2_],_loc4_.icon);
               _loc5_.smooth = true;
               _loc2_++;
            }
            TextFieldUtil.compactTextField(this.screen.rewards_tf,ZGameUtils.ZlocT("Dialogs","Rewards"));
         }
      }
      
      private function setRewardDetailsForMS09() : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:ImageLoader = null;
         TextFieldUtil.compactTextField(this.screen.questDetails_mc.rewards_tf,ZGameUtils.ZlocT("Dialogs","Rewards"));
         var _loc1_:Object = this.getRewardTextObject();
         var _loc2_:Number = 0;
         var _loc3_:Array = [this.screen.questDetails_mc.reward1_mc,this.screen.questDetails_mc.reward2_mc,this.screen.questDetails_mc.reward3_mc];
         for each(_loc4_ in _loc3_)
         {
            TextFieldUtil.compactTextField(_loc4_.name_tf,_loc1_.rewardText[_loc2_]);
            _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc1_.rewardIcons[_loc2_],_loc4_.icon);
            _loc5_.smooth = true;
            _loc2_++;
         }
      }
      
      private function setUpTabs() : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:MovieClip = null;
         var _loc7_:ImageLoader = null;
         var _loc1_:Array = [this.screen.tab1_mc,this.screen.tab2_mc,this.screen.tab3_mc];
         var _loc2_:Number = 0;
         if(MegaseriesManager.instance.getMegaseries(this.m_megaseriesId) != null)
         {
            _loc3_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).currentStageProgress();
            _loc4_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).tabIcons;
            _loc5_ = MegaseriesManager.instance.getMegaseries(this.m_megaseriesId).currentStage;
            for each(_loc6_ in _loc1_)
            {
               _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(_loc4_[_loc2_ + (_loc5_ - 1) * 3]),_loc6_.tab);
               _loc7_.smooth = true;
               if(_loc2_ < _loc3_.completed)
               {
                  _loc6_.gotoAndStop(4);
               }
               else if(_loc2_ > _loc3_.completed)
               {
                  _loc6_.gotoAndStop(2);
               }
               else
               {
                  _loc6_.gotoAndStop(3);
               }
               _loc2_++;
            }
         }
      }
   }
}

