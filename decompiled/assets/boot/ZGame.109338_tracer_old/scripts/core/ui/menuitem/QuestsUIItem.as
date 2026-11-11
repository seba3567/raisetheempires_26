package core.ui.menuitem
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Classes.Quest;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.managers.CommandoManager;
   import core.managers.EnergiserManager;
   import core.managers.ExperimentsManager;
   import core.managers.MegaseriesManager;
   import core.managers.RUXManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.ui.UIDirector.CampaignV2DirectorScript;
   import core.ui.UIDirector.UIDirector;
   import core.ui.ZGameButton;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import displays.popups.ConversationPopup;
   import displays.popups.EpisodePopup;
   import displays.popups.GenericPopup;
   import displays.popups.LetterPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.quest.QuestCompletePopup;
   import displays.popups.quest.QuestDetailsPopup;
   import displays.popups.quest.QuestManagerPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.oreInviteScreen.OreInvite;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TQuestNotificationSeen;
   import utils.ZGameUtils;
   import zgame.assets.ui.quest_bar.QuestButtonMC;
   import zgame.assets.ui.quest_bar.quest_bar;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class QuestsUIItem extends MenuItem
   {
      
      public static const PRIORITIZE_QUEST:String = "prioritizeQuest";
      
      public static const ITEM_ID:String = "questsUIItem";
      
      public static var IN_INIT:Boolean = false;
      
      private static const SCROLL_BUTTON_DOWN:uint = 0;
      
      private static const SCROLL_BUTTON_UP:uint = 1;
      
      private static const QUEST_BAR_UNLOCK_LEVEL:Number = 12;
      
      private static var ICON_SPACING:Number = 0;
      
      private static const XPOS:int = 13;
      
      private static const YPOS:int = 245;
      
      private var m_quests:Array = null;
      
      private var m_arrowPosition:Number = 0;
      
      private var m_inCompleteStage:Boolean = false;
      
      private var m_completedQuests:Array = null;
      
      private var m_dialogs:Array = new Array();
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_pauseQuestStart:int = 0;
      
      private var m_pauseQuestStartData:Array = new Array();
      
      private var m_scrollButtons:Array = null;
      
      private var m_scrollPosition:int = 0;
      
      private var m_maxWindowedIcons:uint = 4;
      
      private var m_previousInitFocusQuestButtonIndex:int = -1;
      
      private var m_questBarV2:quest_bar = null;
      
      private var m_questButtonMC:QuestButtonMC = null;
      
      private var isQuestbarShown:Boolean = false;
      
      private var questBarPositionIndex:Number = 0;
      
      private var filterStarButton:ZGameButton;
      
      private var filterByTimeButton:ZGameButton;
      
      private var filterStarCancelButton:ZGameButton;
      
      private var filterByTimeCancelButton:ZGameButton;
      
      private var notifyFilterStarButton:MovieClip;
      
      private var notifyFilterByTimeButton:MovieClip;
      
      private var m_dialogInfo:Object;
      
      private var m_flagPositioned:Boolean = false;
      
      private var m_defaultOrder:Array = new Array();
      
      private var POS_BTN_SCROLL_UP:Number = 0;
      
      private var POS_BTN_SCROLL_DOWN:Number = 0;
      
      private var POS_QUESTBAR_TOP:Number = 0;
      
      private var POS_QUESTBAR_HEIGHT:Number = 0;
      
      public function QuestsUIItem()
      {
         super(ITEM_ID);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleOrPrebattleGMEntered,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.NEW_QUEST_AVAILABLE,this.onNewQuestAvailable,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_EXPIRED,this.onQuestExpired,false,0,true);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition,false,0,true);
         UIDispatcher.instance.addEventListener(UIDispatcher.PLAYER_NAME_LOADED,this.onPlayerLoaded);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_PAUSE_QUEST_ICONS,this.onPauseQuestIcons);
         UIDispatcher.instance.addEventListener(QuestsUIItem.PRIORITIZE_QUEST,this.onPrioritizeQuest);
         UIDispatcher.instance.addEventListener(UIDispatcher.PLAYER_LEVEL_LOADED,this.onPlayerLevelLoaded);
         TutorialManager.instance.addEventListener(TutorialManager.PAUSE_QUEST_STARTS,this.onPauseQuestStarts,false,0,true);
         TutorialManager.instance.addEventListener(TutorialManager.RESUME_QUEST_STARTS,this.onResumeQuestStarts,false,0,true);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ENTERED,this.onStrategicMapEntered,false,0,true);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.EXITED,this.onStrategicMapExited,false,0,true);
         ZGameQuestManager(QuestManager.getInstance()).addEventListener(ZGameQuestManager.QUESTS_LOADED,this.onQuestsLoaded,false,0,true);
         this.m_quests = new Array();
      }
      
      public static function isQuestBar2() : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_V2) == ExperimentsManager.VARIANT_QUEST_BAR_V2_ON && ZGlobal.player.level >= questUnlockLevel)
         {
            return true;
         }
         return false;
      }
      
      public static function get iconSpacing() : Number
      {
         if(ICON_SPACING == 0)
         {
            ICON_SPACING = ZGlobal.gameSettings.getNumber("questIconSpacing",68);
         }
         return ICON_SPACING;
      }
      
      public static function get questUnlockLevel() : Number
      {
         return QUEST_BAR_UNLOCK_LEVEL;
      }
      
      private function onQuestsLoaded(param1:WorldEvent) : void
      {
         if(isQuestBar2())
         {
            this.showOrHideNotifications(null);
         }
      }
      
      private function onPlayerLevelLoaded(param1:Event) : void
      {
         if(isQuestBar2())
         {
            this.initialiseQuestBar2();
         }
      }
      
      private function initialiseQuestBar2() : void
      {
         if(!this.m_questBarV2)
         {
            this.m_questBarV2 = new quest_bar();
         }
         addChild(this.m_questBarV2);
         if(this.m_questBarV2.contains(this.m_questBarV2.quest01_bt))
         {
            this.m_questBarV2.removeChild(this.m_questBarV2.quest01_bt);
         }
         if(this.m_questBarV2.contains(this.m_questBarV2.quest02_bt))
         {
            this.m_questBarV2.removeChild(this.m_questBarV2.quest02_bt);
         }
         if(this.m_questBarV2.contains(this.m_questBarV2.quest03_bt))
         {
            this.m_questBarV2.removeChild(this.m_questBarV2.quest03_bt);
         }
         if(this.m_questBarV2.contains(this.m_questBarV2.quest04_bt))
         {
            this.m_questBarV2.removeChild(this.m_questBarV2.quest04_bt);
         }
         this.filterStarButton = new ZGameButton(this.m_questBarV2.filterstar_bt,this.onFilterFav);
         this.filterByTimeButton = new ZGameButton(this.m_questBarV2.filtertime_bt,this.onSortByExpireTime);
         this.filterStarCancelButton = new ZGameButton(this.m_questBarV2.filterstarcancel_bt,this.onCancelFilter);
         this.filterByTimeCancelButton = new ZGameButton(this.m_questBarV2.filtertimecancel_bt,this.onCancelFilter);
         this.filterStarButton.addTooltip(ZGameUtils.ZlocT("Tooltips","qbar2_star"));
         this.filterByTimeButton.addTooltip(ZGameUtils.ZlocT("Tooltips","qbar2_clock"));
         this.filterStarCancelButton.addTooltip(ZGameUtils.ZlocT("Tooltips","qbar2_cancel"));
         this.filterByTimeCancelButton.addTooltip(ZGameUtils.ZlocT("Tooltips","qbar2_cancel"));
         this.filterStarCancelButton.hide();
         this.filterByTimeCancelButton.hide();
         this.notifyFilterStarButton = this.m_questBarV2.filterstar_bt.superstar as MovieClip;
         this.notifyFilterByTimeButton = this.m_questBarV2.filtertime_bt.superstar as MovieClip;
         addChild(this.m_questBarV2);
         this.questBarPositionIndex = this.m_questBarV2.x - this.m_questBarV2.width - 20;
         this.m_questBarV2.x = this.questBarPositionIndex;
         addEventListener(MouseEvent.MOUSE_OVER,this.onFocusQuestBar,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onUnFocusQuestBar,false,0,true);
         this.m_questBarV2.visible = false;
         this.repositionQuestBarBG();
      }
      
      private function onFocusQuestBar(param1:MouseEvent) : void
      {
         TweenLite.killTweensOf(this.m_questBarV2);
         if(this.isQuestbarShown)
         {
            return;
         }
         TweenLite.to(this.m_questBarV2,0.5,{"x":this.questBarPositionIndex + this.m_questBarV2.width});
         this.isQuestbarShown = true;
      }
      
      public function showOrHideNotifications(param1:WorldEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(isQuestBar2())
         {
            _loc2_ = ZGlobal.player.favCount;
            _loc3_ = ZGlobal.player.timedCount;
            if(_loc2_ > 0)
            {
               this.notifyFilterStarButton.visible = true;
            }
            else
            {
               this.notifyFilterStarButton.visible = false;
            }
            if(_loc3_ > 0)
            {
               this.notifyFilterByTimeButton.visible = true;
            }
            else
            {
               this.notifyFilterByTimeButton.visible = false;
            }
         }
      }
      
      private function onUnFocusQuestBar(param1:MouseEvent) : void
      {
         TweenLite.killTweensOf(this.m_questBarV2);
         if(!this.isQuestbarShown)
         {
            return;
         }
         TweenLite.to(this.m_questBarV2,0.5,{"x":this.questBarPositionIndex});
         this.isQuestbarShown = false;
      }
      
      private function removeNotifyAllStarredQuests() : void
      {
         var _loc2_:QuestButtonUIItem = null;
         var _loc3_:TQuestNotificationSeen = null;
         this.m_questBarV2.filterstar_bt.superstar.visible = false;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_defaultOrder)
         {
            if(ZGlobal.player.isStarredQuest(_loc2_.m_quest.name) && ZGlobal.player.isNotifyQuest(_loc2_.m_quest.name))
            {
               ZGlobal.player.removeQuestNotification(_loc2_.m_quest.name);
               ZGlobal.player.addToSeenQuestNotifications(_loc2_.m_quest.name);
               _loc2_.hideStarNotificationIcon();
               _loc1_.push(_loc2_.m_quest.name);
            }
         }
         if(_loc1_.length > 0)
         {
            _loc3_ = new TQuestNotificationSeen(_loc1_);
            TransactionManager.addTransaction(_loc3_);
         }
         ZGlobal.player.favCount = 0;
      }
      
      private function removeAllTimedQuestNotifications() : void
      {
         var _loc2_:QuestButtonUIItem = null;
         var _loc3_:TQuestNotificationSeen = null;
         this.m_questBarV2.filtertime_bt.superstar.visible = false;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_defaultOrder)
         {
            if(!ZGlobal.player.isStarredQuest(_loc2_.m_quest.name) && ZGlobal.player.isNotifyQuest(_loc2_.m_quest.name))
            {
               ZGlobal.player.removeQuestNotification(_loc2_.m_quest.name);
               ZGlobal.player.addToSeenQuestNotifications(_loc2_.m_quest.name);
               _loc2_.hideStarNotificationIcon();
               _loc1_.push(_loc2_.m_quest.name);
            }
         }
         if(_loc1_.length > 0)
         {
            _loc3_ = new TQuestNotificationSeen(_loc1_);
            TransactionManager.addTransaction(_loc3_);
         }
         ZGlobal.player.timedCount = 0;
      }
      
      private function onSortByExpireTime(param1:MouseEvent) : void
      {
         this.sortFilterTimedQuests();
         this.removeAllTimedQuestNotifications();
         this.assignQuestsIndexes();
         this.filterByTimeCancelButton.show();
         this.filterByTimeButton.hide();
         this.makeTopQuestVisible();
         this.updateScrollButtons();
      }
      
      private function onFilterFav(param1:MouseEvent) : void
      {
         this.sortFavQuests();
         this.removeNotifyAllStarredQuests();
         this.assignQuestsIndexes();
         this.filterStarCancelButton.show();
         this.filterStarButton.hide();
         this.makeTopQuestVisible();
         this.updateScrollButtons();
         this.scrollQuestButtonUIs(-this.m_quests.length,false);
      }
      
      private function onCancelFilter(param1:MouseEvent) : void
      {
         var _loc2_:QuestButtonUIItem = null;
         this.m_quests = this.m_defaultOrder;
         this.sortQuestIconsByTypeAndTimeRemaining();
         this.assignQuestsIndexes();
         for each(_loc2_ in this.m_defaultOrder)
         {
            _loc2_.showBtn();
         }
         this.filterStarCancelButton.hide();
         this.filterStarButton.show();
         this.notifyFilterByTimeButton.visible = false;
         this.filterByTimeCancelButton.hide();
         this.filterByTimeButton.show();
         this.makeTopQuestVisible();
         this.updateScrollButtons();
      }
      
      private function repositionQuestBarBG() : void
      {
         if(!this.m_flagPositioned)
         {
            this.m_questBarV2.y = this.m_questBarV2.y - iconSpacing * this.m_maxWindowedIcons - 103;
            this.m_questBarV2.x = this.questBarPositionIndex;
         }
         this.m_flagPositioned = true;
         this.m_questBarV2.visible = true;
      }
      
      private function sortFilterTimedQuests() : void
      {
         var _loc4_:QuestButtonUIItem = null;
         var _loc5_:int = 0;
         var _loc6_:* = 0;
         var _loc1_:Array = [];
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         this.m_quests = new Array();
         _loc6_ = int(this.m_defaultOrder.length - 1);
         while(_loc6_ >= 0)
         {
            (this.m_defaultOrder[_loc6_] as QuestButtonUIItem).hideBtn();
            if((this.m_defaultOrder[_loc6_] as QuestButtonUIItem).isFromQuestTree)
            {
               _loc1_.push(this.m_defaultOrder[_loc6_]);
               (this.m_defaultOrder[_loc6_] as QuestButtonUIItem).showBtn();
            }
            else if((this.m_defaultOrder[_loc6_] as QuestButtonUIItem).isTimedQuest && !(this.m_defaultOrder[_loc6_] as QuestButtonUIItem).isFromQuestTree)
            {
               _loc2_.push(this.m_defaultOrder[_loc6_]);
               (this.m_defaultOrder[_loc6_] as QuestButtonUIItem).showBtn();
            }
            else if(!(this.m_defaultOrder[_loc6_] as QuestButtonUIItem).isTimedQuest && !(this.m_defaultOrder[_loc6_] as QuestButtonUIItem).isFromQuestTree)
            {
               _loc3_.push(this.m_defaultOrder[_loc6_]);
               (this.m_defaultOrder[_loc6_] as QuestButtonUIItem).showBtn();
            }
            _loc6_--;
         }
         _loc2_.sortOn("timeRemaining",Array.NUMERIC);
         _loc2_.reverse();
         _loc1_.sortOn("timeRemaining",Array.NUMERIC);
         _loc1_.reverse();
         this.m_quests = this.m_quests.concat(_loc3_);
         this.m_quests = this.m_quests.concat(_loc2_);
         this.m_quests = this.m_quests.concat(_loc1_);
         this.scrollQuestButtonUIs(-this.m_quests.length,false);
      }
      
      override public function removeItem() : void
      {
         var _loc1_:QuestButtonUIItem = null;
         super.removeItem();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleOrPrebattleGMEntered);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.NEW_QUEST_AVAILABLE,this.onNewQuestAvailable);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_REWARDS_GIVEN,this.onQuestRewardsGiven);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition);
         UIDispatcher.instance.removeEventListener(UIDispatcher.PLAYER_NAME_LOADED,this.onPlayerLoaded);
         UIDispatcher.instance.removeEventListener(UIDispatcher.UI_PAUSE_QUEST_ICONS,this.onPauseQuestIcons);
         UIDispatcher.instance.removeEventListener(QuestsUIItem.PRIORITIZE_QUEST,this.onPrioritizeQuest);
         TutorialManager.instance.removeEventListener(TutorialManager.PAUSE_QUEST_STARTS,this.onPauseQuestStarts);
         TutorialManager.instance.removeEventListener(TutorialManager.RESUME_QUEST_STARTS,this.onResumeQuestStarts);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ENTERED,this.onStrategicMapEntered);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.EXITED,this.onStrategicMapExited);
         for each(_loc1_ in this.m_quests)
         {
            _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.onStopSpringBackOnMouseOver);
            _loc1_.dispose();
         }
         this.m_quests = null;
         this.m_dialogs = null;
      }
      
      private function onPlayerLoaded(param1:Event) : void
      {
         visible = ZGlobal.visitMode == ZGlobal.MODE_HOME;
         if(isQuestBar2() && visible)
         {
            this.m_questBarV2.visible = true;
         }
         this.disposeScrollButtons();
         this.onReposition(null);
      }
      
      private function onPauseQuestIcons(param1:WorldEvent) : void
      {
         if(param1.eventData)
         {
            this.onPauseQuestStarts(null);
         }
         else
         {
            this.onResumeQuestStarts(null);
         }
      }
      
      protected function onReposition(param1:RepositionEvent) : void
      {
         x = XPOS;
         y = Zlab.mainStage.stageHeight - YPOS;
         var _loc2_:uint = uint(Zlab.mainStage.stageHeight);
         var _loc3_:int = int(this.m_maxWindowedIcons);
         this.m_maxWindowedIcons = (y - (ZGlobal.visitMode == ZGlobal.MODE_HOME ? 140 : 280)) / iconSpacing;
         this.m_maxWindowedIcons += 1;
         this.updateScrollButtons();
         if(this.m_quests.length > _loc3_)
         {
            this.makeTopQuestVisible(true);
         }
         this.assignQuestsIndexes();
         if(null != this.m_scrollButtons)
         {
            this.enableScrollButtons();
         }
      }
      
      private function onPrioritizeQuest(param1:WorldEvent) : void
      {
         var _loc4_:QuestButtonUIItem = null;
         var _loc5_:Array = null;
         var _loc2_:String = param1.eventData as String;
         var _loc3_:uint = 0;
         for each(_loc4_ in this.m_quests)
         {
            if(_loc4_.id == _loc2_)
            {
               break;
            }
            _loc3_++;
         }
         if(_loc3_ < this.m_quests.length)
         {
            _loc5_ = this.m_quests.splice(_loc3_,1);
            for each(_loc4_ in _loc5_)
            {
               this.m_quests.push(_loc4_);
            }
         }
         this.assignQuestsIndexes();
      }
      
      private function onBattleOrPrebattleGMEntered(param1:WorldEvent) : void
      {
         visible = !param1.eventData.entered && ZGlobal.isHome();
      }
      
      private function onQuestExpired(param1:WorldEvent) : void
      {
         var _loc3_:QuestButtonUIItem = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         if(!this.m_completedQuests)
         {
            this.m_completedQuests = new Array();
         }
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_quests)
         {
            if(_loc3_.id == param1.eventData.name)
            {
               _loc3_.dispose();
               this.m_quests.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         if(ZGlobal.player.questTrees.isQuestTreeQuest(param1.eventData.name))
         {
            _loc5_ = ZGlobal.player.questTrees.getFirstActiveQuest(param1.eventData.name);
            if(_loc5_)
            {
               this.newQuestAvailable({
                  "id":_loc5_,
                  "autoOpen":false,
                  "visible":true,
                  "fromInit":false
               });
            }
         }
         this.assignQuestsIndexes();
         this.updateScrollButtons();
         this.onQuestCompleteContinue(null);
         var _loc4_:int = 0;
         while(_loc4_ < this.m_pauseQuestStartData.length)
         {
            _loc6_ = this.m_pauseQuestStartData[_loc4_];
            if(_loc6_.id == param1.eventData.name)
            {
               this.m_pauseQuestStartData.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
         this.removeItemOnComplete(param1.eventData.name);
      }
      
      private function onQuestComplete(param1:WorldEvent) : void
      {
         var _loc3_:QuestButtonUIItem = null;
         var _loc6_:String = null;
         var _loc7_:QuestCompletePopup = null;
         var _loc8_:Object = null;
         this.m_inCompleteStage = true;
         if(!this.m_completedQuests)
         {
            this.m_completedQuests = new Array();
         }
         this.setupDialogs(param1.eventData,"end");
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_quests)
         {
            if(_loc3_.id == param1.eventData.name)
            {
               _loc3_.dispose();
               this.m_quests.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         if(ZGlobal.player.questTrees.isQuestTreeQuest(param1.eventData.name))
         {
            _loc6_ = ZGlobal.player.questTrees.getFirstActiveQuest(param1.eventData.name);
            if(_loc6_)
            {
               this.newQuestAvailable({
                  "id":_loc6_,
                  "autoOpen":false,
                  "visible":true,
                  "fromInit":false
               });
            }
         }
         if(param1.eventData.name == RUXManager.finalQuest)
         {
            ZGlobal.player.isRUXQuestActive = false;
         }
         this.assignQuestsIndexes();
         this.updateScrollButtons();
         var _loc4_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1.eventData.name as String) as ZGameQuest;
         if(Boolean(MegaseriesManager.instance.isMegaseriesReward(param1.eventData.name)) || Boolean(param1.eventData.visible) && Boolean(!param1.eventData.hideCompleteDialog))
         {
            TutorialManager.instance.addEventListener(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,this.onQuestCompleteContinue);
            _loc7_ = new QuestCompletePopup(_loc4_.name,this.onQuestCompletePopupClosed);
            if(param1.eventData.delay != 0)
            {
               PopupManager.instance.push(_loc7_,Number(param1.eventData.delay));
            }
            else if(_loc4_.refillEnergy)
            {
               EnergiserManager.instance.start();
               UIDispatcher.instance.dispatchEvent(new WorldEvent(EnergiserManager.QUEST_COMPLETE,_loc7_));
            }
            else if(_loc4_.customQuestCompletDialog)
            {
               CommandoManager.instance.start();
               UIDispatcher.instance.dispatchEvent(new WorldEvent(CommandoManager.COMMANDO_QUEST_COMPLETE,_loc7_));
            }
            else
            {
               PopupManager.instance.push(_loc7_);
            }
         }
         else if(_loc4_.grantQuestTreeReward || _loc4_.grantMSFinalReward)
         {
            QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_REWARDS_GIVEN,this.onQuestRewardsGiven,false,0,true);
         }
         else
         {
            this.onQuestCompleteContinue(null);
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.m_pauseQuestStartData.length)
         {
            _loc8_ = this.m_pauseQuestStartData[_loc5_];
            if(_loc8_.id == param1.eventData.name)
            {
               this.m_pauseQuestStartData.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
         this.removeItemOnComplete(param1.eventData.name);
      }
      
      public function removeActiveQuestIcon(param1:String) : void
      {
         var _loc4_:QuestButtonUIItem = null;
         var _loc6_:Object = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_quests)
         {
            if(_loc4_.id == param1)
            {
               _loc2_ = true;
               _loc4_.dispose();
               this.m_quests.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            this.assignQuestsIndexes();
            this.updateScrollButtons();
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.m_pauseQuestStartData.length)
         {
            _loc6_ = this.m_pauseQuestStartData[_loc5_];
            if(_loc6_.id == param1)
            {
               this.m_pauseQuestStartData.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
      }
      
      private function removeItemOnComplete(param1:String) : void
      {
         var _loc4_:ZGameTask = null;
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc3_:Array = _loc2_.getQuestTasks(param1);
         for each(_loc4_ in _loc3_)
         {
            _loc2_.removeItemOnComplete(_loc4_);
         }
      }
      
      private function onQuestCompleteContinue(param1:WorldEvent) : void
      {
         if(!this.addDialog())
         {
            this.endQuest();
         }
      }
      
      private function onQuestRewardsGiven(param1:WorldEvent) : void
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1.eventData.name as String) as ZGameQuest;
         if(_loc2_.grantQuestTreeReward || _loc2_.grantMSFinalReward)
         {
            TutorialManager.instance.addEventListener(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,this.onQuestCompleteContinue);
            PlayerQuestTrees.triggerDialog(_loc2_.name);
         }
      }
      
      private function endQuest() : void
      {
         var _loc1_:Object = null;
         if(Boolean(this.m_completedQuests) && this.m_completedQuests.length > 0)
         {
            for each(_loc1_ in this.m_completedQuests)
            {
               this.addNewQuestButton(_loc1_);
            }
            this.makeTopQuestVisible();
         }
         this.m_inCompleteStage = false;
         this.m_completedQuests = null;
         TutorialManager.instance.removeEventListener(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,this.onQuestCompleteContinue);
      }
      
      private function makeTopQuestVisible(param1:Boolean = false) : void
      {
         this.focusOnQuestButtonUIAtIndex(int.MAX_VALUE,true,param1);
      }
      
      public function focusOnQuestButtonUIAtIndex(param1:int, param2:Boolean = true, param3:Boolean = false) : void
      {
         if(param1 >= 0 && param1 < this.m_quests.length - 1 || param2)
         {
            param1 = Math.max(0,Math.min(param1,this.m_quests.length - 1));
            this.focusOnQuestButtonUI(this.m_quests[param1] as QuestButtonUIItem,false,10000,param3);
         }
      }
      
      public function focusOnQuestButtonUI(param1:QuestButtonUIItem, param2:Boolean = false, param3:Number = 10000, param4:Boolean = false) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.m_quests != null && this.m_quests.indexOf(param1) != -1 && (param1.visible == false || param4 == true))
         {
            _loc5_ = this.m_quests.length;
            _loc6_ = this.m_quests.indexOf(param1);
            _loc7_ = this.m_maxWindowedIcons - _loc6_ - this.m_scrollPosition;
            this.scrollQuestButtonUIs(_loc7_,param2,param3);
         }
      }
      
      private function scrollQuestButtonUIs(param1:int, param2:Boolean = false, param3:Number = 10000) : void
      {
         var _loc4_:* = param1;
         if(!IN_INIT && param2)
         {
            Zlab.processManager.schedule(param3,this,this.scrollQuestButtonUIs,-1 * param1);
         }
         if(_loc4_ <= 0)
         {
            while(_loc4_ <= 0)
            {
               this.onScrollUp(null);
               _loc4_++;
            }
            this.updateScrollButtons();
            return;
         }
         if(_loc4_ > 1)
         {
            while(_loc4_ > 1)
            {
               this.onScrollDown(null);
               _loc4_--;
            }
            this.updateScrollButtons();
            return;
         }
         this.assignQuestsIndexes();
         this.updateScrollButtons();
      }
      
      public function setQuestButtonUIItemToTop(param1:QuestButtonUIItem, param2:Boolean = false) : void
      {
         this.setQuestButtonUIItemIndex(param1,int.MAX_VALUE,param2);
      }
      
      public function setQuestButtonUIItemToBottom(param1:QuestButtonUIItem, param2:Boolean = false) : void
      {
         this.setQuestButtonUIItemIndex(param1,int.MIN_VALUE,param2);
      }
      
      public function setQuestButtonUIItemIndex(param1:QuestButtonUIItem, param2:int, param3:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.m_quests != null)
         {
            _loc4_ = this.m_quests.indexOf(param1);
            _loc5_ = Math.max(0,Math.min(this.m_quests.length,param2));
            this.m_quests.splice(_loc4_,1);
            this.m_quests.splice(_loc5_,0,param1);
            this.assignQuestsIndexes();
            if(param3)
            {
               this.focusOnQuestButtonUI(param1);
            }
         }
      }
      
      protected function sortQuestIconsByTypeAndTimeRemaining() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:QuestButtonUIItem = null;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_SORTING) == ExperimentsManager.VARIANT_VALUE_QUEST_BAR_SORTING_ON)
         {
            _loc1_ = [];
            _loc2_ = [];
            _loc3_ = [];
            _loc4_ = [];
            _loc5_ = [];
            this.m_defaultOrder = new Array();
            _loc8_ = int(this.m_quests.length - 1);
            while(_loc8_ >= 0)
            {
               if((this.m_quests[_loc8_] as QuestButtonUIItem).id.toString().indexOf(RUXManager.questPrefix) == 0)
               {
                  _loc5_.push(this.m_quests.splice(_loc8_,1)[0]);
               }
               else if((this.m_quests[_loc8_] as QuestButtonUIItem).isFromQuestTree)
               {
                  _loc1_.push(this.m_quests.splice(_loc8_,1)[0]);
               }
               else if((this.m_quests[_loc8_] as QuestButtonUIItem).isTimedQuest)
               {
                  _loc2_.push(this.m_quests.splice(_loc8_,1)[0]);
               }
               else if((this.m_quests[_loc8_] as QuestButtonUIItem).isLimitedEdition)
               {
                  _loc3_.push(this.m_quests.splice(_loc8_,1)[0]);
               }
               else if((this.m_quests[_loc8_] as QuestButtonUIItem).forced)
               {
                  _loc4_.unshift(this.m_quests.splice(_loc8_,1)[0]);
               }
               _loc8_--;
            }
            _loc3_.sortOn("timeRemaining",Array.NUMERIC);
            _loc3_.reverse();
            _loc2_.sortOn("timeRemaining",Array.NUMERIC);
            _loc2_.reverse();
            _loc1_.sortOn("timeRemaining",Array.NUMERIC);
            _loc1_.reverse();
            this.m_quests = this.m_quests.concat(_loc4_);
            this.m_quests = this.m_quests.concat(_loc3_);
            this.m_quests = this.m_quests.concat(_loc2_);
            this.m_quests = this.m_quests.concat(_loc1_);
            this.m_quests = this.m_quests.concat(_loc5_);
            this.m_defaultOrder = this.m_defaultOrder.concat(this.m_quests);
         }
      }
      
      private function assignQuestsIndexes() : void
      {
         var _loc2_:QuestButtonUIItem = null;
         var _loc1_:* = 0;
         for each(_loc2_ in this.m_quests)
         {
            _loc2_.setIndex(this.m_scrollPosition + _loc1_++,this.m_maxWindowedIcons,false);
         }
      }
      
      private function onNewQuestAvailable(param1:WorldEvent) : void
      {
         this.newQuestAvailable(param1.eventData);
      }
      
      private function newQuestAvailable(param1:Object) : void
      {
         if(this.m_inCompleteStage)
         {
            this.m_completedQuests.push(param1);
         }
         else
         {
            this.addNewQuestButton(param1);
         }
      }
      
      private function addNewQuestButton(param1:Object) : void
      {
         var _loc2_:Boolean = this.setupDialogs(param1,"start");
         if(this.m_pauseQuestStart == 0)
         {
            if(!_loc2_ || !this.addDialog())
            {
               if(param1.id.toString().indexOf(RUXManager.questPrefix) == 0)
               {
                  this.startNewQuest(param1);
               }
               else
               {
                  this.startNewQuest(param1);
               }
            }
         }
         else
         {
            this.m_pauseQuestStartData.push(param1);
         }
      }
      
      public function showTaskArrowOnQuest(param1:String) : void
      {
         var _loc2_:QuestButtonUIItem = null;
         for each(_loc2_ in this.m_quests)
         {
            if(_loc2_.id.toString() == param1)
            {
               this.focusOnQuestButtonUI(_loc2_,true,10000,true);
               _loc2_.showTaskArrow(ZGameUtils.ZlocT("Quests","quest_arrow_text"),8000);
            }
         }
      }
      
      public function showRUXTaskArrowOnQuest() : void
      {
         var _loc1_:QuestButtonUIItem = null;
         for each(_loc1_ in this.m_quests)
         {
            if(_loc1_.id.toString().indexOf(RUXManager.questPrefix) == 0)
            {
               this.showTaskArrowOnQuest(_loc1_.id.toString());
               break;
            }
         }
      }
      
      public function showRUXQuestSpeech() : void
      {
         var _loc1_:QuestButtonUIItem = null;
         for each(_loc1_ in this.m_quests)
         {
            if(_loc1_.id.toString().indexOf(RUXManager.questPrefix) == 0)
            {
               PopupManager.instance.push(new SpeechPopup("Speech_" + _loc1_.id.toString(),this.onRUXSpeechClose),0,true,false);
               break;
            }
         }
      }
      
      private function onRUXSpeechClose(param1:Event = null) : void
      {
         var _loc2_:QuestButtonUIItem = null;
         for each(_loc2_ in this.m_quests)
         {
            if(_loc2_.id.toString().indexOf(RUXManager.questPrefix) == 0)
            {
               this.simulateQuestButtonUIItemClick(_loc2_.id.toString());
               break;
            }
         }
      }
      
      private function startNewQuest(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:QuestButtonUIItem = null;
         var _loc5_:String = null;
         if(!param1.visible)
         {
            return;
         }
         if(ZGlobal.player.questTrees.isQuestTreeQuest(param1.id))
         {
            _loc3_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param1.id);
            for each(_loc4_ in this.m_quests)
            {
               if(ZGlobal.player.questTrees.isQuestTreeQuest(_loc4_.id))
               {
                  _loc5_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(_loc4_.id);
                  if(_loc3_ == _loc5_)
                  {
                     return;
                  }
               }
            }
         }
         var _loc2_:QuestButtonUIItem = null;
         if(isQuestBar2())
         {
            _loc2_ = new QuestButtonUIItem(param1.id,this,this.m_quests.length,this.m_maxWindowedIcons,param1.fromInit,new QuestButtonMC());
         }
         else
         {
            _loc2_ = new QuestButtonUIItem(param1.id,this,this.m_quests.length,this.m_maxWindowedIcons,param1.fromInit);
         }
         _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.onStopSpringBackOnMouseOver,false,0,false);
         this.m_quests.push(_loc2_);
         this.m_defaultOrder.push(_loc2_);
         this.sortQuestIconsByTypeAndTimeRemaining();
         this.assignQuestsIndexes();
         if(this.m_quests.length > this.m_maxWindowedIcons)
         {
            if(QuestsUIItem.IN_INIT)
            {
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_SORTING) == ExperimentsManager.VARIANT_VALUE_QUEST_BAR_SORTING_ON)
               {
                  this.makeTopQuestVisible();
               }
            }
            else
            {
               this.focusOnQuestButtonUI(_loc2_,true,ZGlobal.gameSettings.getInt("questSpringBackToUserPosition",10000));
            }
         }
         this.updateScrollButtons();
         if(null != param1.autoOpen && param1.autoOpen == true)
         {
            Zlab.processManager.schedule(750,this,this.onShowDetails,_loc2_);
         }
         if(param1.id.toString().indexOf(RUXManager.questPrefix) == 0)
         {
            this.showTaskArrowOnQuest(param1.id.toString());
         }
      }
      
      private function onStopSpringBackOnMouseOver(param1:MouseEvent) : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function sortFavQuests() : void
      {
         this.m_quests = new Array();
         var _loc1_:QuestButtonUIItem = null;
         for each(_loc1_ in this.m_defaultOrder)
         {
            if(!ZGlobal.player.isStarredQuest(_loc1_.id))
            {
               this.m_quests.push(_loc1_);
            }
         }
         for each(_loc1_ in this.m_defaultOrder)
         {
            if(ZGlobal.player.isStarredQuest(_loc1_.id))
            {
               this.m_quests.push(_loc1_);
            }
         }
      }
      
      private function updateScrollButtons() : void
      {
         var _loc1_:uint = this.m_quests.length;
         if(_loc1_ > this.m_maxWindowedIcons)
         {
            if(null == this.m_scrollButtons)
            {
               this.m_buttonSounds = new ButtonMouseEventSoundContainer();
               this.m_scrollButtons = new Array(2);
               if(isQuestBar2())
               {
                  this.m_scrollButtons[SCROLL_BUTTON_DOWN] = this.m_questBarV2.arrowdown_bt;
                  this.m_scrollButtons[SCROLL_BUTTON_UP] = this.m_questBarV2.arrowup_bt;
               }
               else
               {
                  this.m_scrollButtons[SCROLL_BUTTON_DOWN] = new scroll_bt_dn();
                  this.m_scrollButtons[SCROLL_BUTTON_UP] = new scroll_bt_up();
               }
               this.m_buttonSounds.addButton(this.m_scrollButtons[SCROLL_BUTTON_DOWN],ButtonSound.DEFAULT);
               this.m_buttonSounds.addButton(this.m_scrollButtons[SCROLL_BUTTON_UP],ButtonSound.DEFAULT);
               this.m_scrollButtons[SCROLL_BUTTON_DOWN].addEventListener(MouseEvent.CLICK,this.onScrollDown);
               this.m_scrollButtons[SCROLL_BUTTON_UP].addEventListener(MouseEvent.CLICK,this.onScrollUp);
               addChild(this.m_scrollButtons[SCROLL_BUTTON_DOWN]);
               addChild(this.m_scrollButtons[SCROLL_BUTTON_UP]);
            }
            if(isQuestBar2())
            {
               this.m_questBarV2.visible = true;
               this.m_questBarV2.arrowdown_bt.visible = true;
               this.m_questBarV2.arrowup_bt.visible = true;
               this.m_scrollButtons[SCROLL_BUTTON_DOWN].x = this.m_scrollButtons[SCROLL_BUTTON_DOWN].width;
               this.m_scrollButtons[SCROLL_BUTTON_DOWN].y = iconSpacing * 0.98 + 20;
               this.resizeBackGround(this.m_scrollButtons[SCROLL_BUTTON_UP].y - 8,this.m_scrollButtons[SCROLL_BUTTON_DOWN].y);
               this.m_scrollButtons[SCROLL_BUTTON_UP].x = this.m_scrollButtons[SCROLL_BUTTON_DOWN].width - 30;
               this.m_scrollButtons[SCROLL_BUTTON_UP].y = this.m_scrollButtons[SCROLL_BUTTON_DOWN].y - (iconSpacing * this.m_maxWindowedIcons + this.m_scrollButtons[SCROLL_BUTTON_UP].height + 18);
            }
            else
            {
               this.m_scrollButtons[SCROLL_BUTTON_DOWN].x = this.m_scrollButtons[SCROLL_BUTTON_DOWN].width;
               this.m_scrollButtons[SCROLL_BUTTON_DOWN].y = iconSpacing * 0.95;
               this.m_scrollButtons[SCROLL_BUTTON_UP].x = this.m_scrollButtons[SCROLL_BUTTON_DOWN].x;
               this.m_scrollButtons[SCROLL_BUTTON_UP].y = this.m_scrollButtons[SCROLL_BUTTON_DOWN].y - (iconSpacing * this.m_maxWindowedIcons + this.m_scrollButtons[SCROLL_BUTTON_UP].height + 3);
            }
            this.enableScrollButtons();
         }
         else
         {
            this.disposeScrollButtons();
            if(isQuestBar2())
            {
               this.m_questBarV2.visible = false;
            }
         }
      }
      
      private function resizeBackGround(param1:Number, param2:Number) : void
      {
         this.POS_QUESTBAR_HEIGHT = param2 - param1 + 25;
         this.POS_QUESTBAR_TOP = param1 - 30;
         this.m_questBarV2.y = this.POS_QUESTBAR_TOP;
         this.m_questBarV2.background.height = this.POS_QUESTBAR_HEIGHT + 20;
      }
      
      private function disposeScrollButtons() : void
      {
         if(null != this.m_scrollButtons)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
            removeChild(this.m_scrollButtons[SCROLL_BUTTON_DOWN]);
            removeChild(this.m_scrollButtons[SCROLL_BUTTON_UP]);
            this.m_scrollButtons[SCROLL_BUTTON_DOWN].removeEventListener(MouseEvent.CLICK,this.onScrollDown);
            this.m_scrollButtons[SCROLL_BUTTON_UP].removeEventListener(MouseEvent.CLICK,this.onScrollUp);
            this.m_scrollButtons = null;
            this.m_scrollPosition = 0;
         }
      }
      
      private function onScrollDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            Zlab.processManager.removeScheduledObject(this);
         }
         this.m_scrollPosition = Math.min(0,this.m_scrollPosition + 1);
         this.assignQuestsIndexes();
         this.enableScrollButtons();
      }
      
      private function onScrollUp(param1:MouseEvent) : void
      {
         if(param1)
         {
            Zlab.processManager.removeScheduledObject(this);
         }
         this.m_scrollPosition = Math.max(this.m_maxWindowedIcons - this.m_quests.length,this.m_scrollPosition - 1);
         this.assignQuestsIndexes();
         this.enableScrollButtons();
      }
      
      private function enableScrollButtons() : void
      {
         if(this.m_scrollButtons)
         {
            ZGameUtils.setButtonEnabled(this.m_scrollButtons[SCROLL_BUTTON_DOWN],this.onScrollDown,this.m_scrollPosition < 0);
            ZGameUtils.setButtonEnabled(this.m_scrollButtons[SCROLL_BUTTON_UP],this.onScrollUp,this.m_scrollPosition > this.m_maxWindowedIcons - this.m_quests.length);
         }
      }
      
      private function setupDialogs(param1:Object, param2:String) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc7_:Object = null;
         var _loc3_:Quest = null;
         if(param1.id)
         {
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(param1.id);
         }
         else if(param1.name)
         {
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(param1.name);
         }
         var _loc4_:XML = (_loc3_ as ZGameQuest).xml;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.dialogs.dialog.length())
         {
            if(_loc4_.dialogs.dialog[_loc6_].@location.toString() == param2)
            {
               _loc7_ = {
                  "xml":_loc4_.dialogs.dialog[_loc6_],
                  "questData":param1,
                  "location":param2
               };
               this.m_dialogs.push(_loc7_);
               _loc5_ = true;
            }
            _loc6_++;
         }
         return _loc5_;
      }
      
      private function addDetailsDialog(param1:String) : void
      {
         var _loc2_:ZGamePopUp = QuestButtonUIItem.isQuestManagerActive() ? new QuestManagerPopup(param1,true) : new QuestDetailsPopup(param1);
         _loc2_.addEventListener(ZGamePopUp.CLOSED,this.onDialogClosed,false,0,true);
         PopupManager.instance.push(_loc2_);
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(Boolean(_loc3_) && Boolean(_loc3_.xml.@acceptAction.toString().length))
         {
            this.m_dialogInfo = new Object();
            this.m_dialogInfo.acceptAction = _loc3_.xml.@acceptAction.toString();
         }
      }
      
      private function addDialog() : Boolean
      {
         var _loc1_:Object = null;
         var _loc2_:XML = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         if(this.m_dialogs.length > 0)
         {
            if(!this.m_dialogInfo)
            {
               _loc1_ = this.m_dialogs.shift();
               _loc2_ = _loc1_.xml;
               _loc3_ = _loc1_.questData;
               _loc4_ = _loc1_.location;
               _loc5_ = _loc2_.@type.toString();
               _loc6_ = _loc2_.@type.toString() == "ore";
               if(!_loc6_ && (ZGlobal.player.hasSeenDialog(_loc5_,_loc2_.@id.toString()) || ZGlobal.player.hasSeenSpeech(_loc2_.@id.toString())))
               {
                  if(this.m_dialogs.length > 0)
                  {
                     return this.addDialog();
                  }
                  return false;
               }
               _loc7_ = true;
               switch(_loc2_.@type.toString())
               {
                  case "speech":
                     PopupManager.instance.push(new SpeechPopup(_loc2_.@id,this.onDialogClosed));
                     break;
                  case "letter":
                     PopupManager.instance.push(new LetterPopup(_loc2_.@id,this.onDialogClosed));
                     break;
                  case "episode":
                     PopupManager.instance.push(new EpisodePopup(_loc2_.@id,this.onDialogClosed));
                     break;
                  case "ore":
                     PopupManager.instance.push(new OreInvite(this.onOreInviteDialogClosed),0,true);
                     break;
                  case "conversation":
                     PopupManager.instance.push(new ConversationPopup(_loc2_.@id,this.onDialogClosed),0,true);
                     break;
                  default:
                     _loc7_ = false;
               }
               if(_loc7_)
               {
                  this.m_dialogInfo = new Object();
                  this.m_dialogInfo.location = _loc4_;
                  if(_loc2_.@details.toString().length)
                  {
                     this.m_dialogInfo.details = _loc2_.@details.toString();
                  }
                  if(_loc4_ == "start")
                  {
                     this.m_dialogInfo.postStartingData = _loc3_;
                  }
               }
            }
            return true;
         }
         return false;
      }
      
      private function onOreInviteDialogClosed(param1:Boolean) : void
      {
         this.onDialogClosed();
      }
      
      private function onDialogClosed(param1:Event = null) : void
      {
         var _loc2_:Object = this.m_dialogInfo;
         this.m_dialogInfo = null;
         if(Boolean(_loc2_) && Boolean(_loc2_.acceptAction))
         {
            this.handleAcceptAction(_loc2_.acceptAction);
         }
         else if(Boolean(_loc2_) && Boolean(_loc2_.details))
         {
            this.addDetailsDialog(_loc2_.details);
            this.dropDeferredQuest(_loc2_);
         }
         else if(this.m_dialogs.length > 0)
         {
            this.addDialog();
         }
         else
         {
            this.dropDeferredQuest(_loc2_);
         }
      }
      
      private function dropDeferredQuest(param1:Object) : void
      {
         if(param1)
         {
            if(param1.location == "start" && Boolean(param1.postStartingData))
            {
               this.startNewQuest(param1.postStartingData);
            }
            else if(param1.location == "end")
            {
               this.endQuest();
            }
         }
      }
      
      private function handleAcceptAction(param1:String) : void
      {
         switch(param1)
         {
            case CampaignV2DirectorScript.SCRIPT_ID:
               if(!ZGlobal.player.getSeenFlag(CampaignV2DirectorScript.SEEN_FLAG) && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED) == ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED_VARIANT_ENABLED)
               {
                  ZGlobal.player.setSeenFlag(CampaignV2DirectorScript.SEEN_FLAG);
                  UIDirector.instance.runScript(new CampaignV2DirectorScript(),this.onDialogClosed);
               }
         }
      }
      
      private function onShowDetails(param1:Object) : void
      {
         param1.showDetails();
      }
      
      private function onQuestCompletePopupClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:XML = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = ZGlobal.gameSettings.getViralXMLByName(param1.userData.id);
            if(_loc2_)
            {
               ViralsManager.instance.sendFeed(param1.userData.id,{
                  "quest_info":param1.userData.title,
                  "quest_id":param1.userData.id
               });
            }
            else
            {
               ViralsManager.instance.sendFeed("quest_complete",{
                  "quest_info":param1.userData.title,
                  "quest_id":param1.userData.id
               });
            }
         }
      }
      
      private function onPauseQuestStarts(param1:WorldEvent) : void
      {
         ++this.m_pauseQuestStart;
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onResumeQuestStarts(param1:WorldEvent) : void
      {
         --this.m_pauseQuestStart;
         if(this.m_pauseQuestStart <= 0)
         {
            this.m_pauseQuestStart = 0;
            Zlab.processManager.schedule(10,this,this.onStartPausedQuests);
         }
      }
      
      private function onStrategicMapEntered(param1:Event) : void
      {
         visible = false;
      }
      
      private function onStrategicMapExited(param1:Event) : void
      {
         visible = true;
      }
      
      private function onStartPausedQuests() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Boolean = false;
         if(this.m_pauseQuestStart == 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_pauseQuestStartData.length)
            {
               _loc2_ = this.setupDialogs(this.m_pauseQuestStartData[_loc1_],"start");
               if(!_loc2_ || !this.addDialog())
               {
                  this.startNewQuest(this.m_pauseQuestStartData[_loc1_]);
               }
               _loc1_++;
            }
            this.m_pauseQuestStartData = new Array();
         }
      }
      
      public function get visibleQuests() : Vector.<String>
      {
         var _loc2_:QuestButtonUIItem = null;
         var _loc1_:Vector.<String> = new Vector.<String>();
         for each(_loc2_ in this.m_quests)
         {
            _loc1_.push(_loc2_.id);
         }
         return _loc1_;
      }
      
      private function simulateQuestButtonUIItemClick(param1:String) : Boolean
      {
         var _loc2_:QuestButtonUIItem = null;
         for each(_loc2_ in this.m_quests)
         {
            if(_loc2_.id == param1)
            {
               _loc2_.simulateClick();
               return true;
            }
         }
         return false;
      }
   }
}

