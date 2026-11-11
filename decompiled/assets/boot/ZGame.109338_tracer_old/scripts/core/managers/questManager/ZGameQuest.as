package core.managers.questManager
{
   import ZQuest.Classes.Quest;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.RewardHelper;
   import core.managers.tutorialManager.TutorialManager;
   import displays.popups.HudsonPopup;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class ZGameQuest extends Quest
   {
      
      private var m_startTime:Number;
      
      private var m_serverRewards:Array = new Array();
      
      private var m_startLevel:Number = 0;
      
      public function ZGameQuest(param1:XML)
      {
         var _loc3_:XML = null;
         var _loc4_:Object = null;
         super(param1);
         var _loc2_:int = 0;
         while(_loc2_ < param1.tasks.task.length())
         {
            _loc3_ = m_xml.tasks.task[_loc2_];
            this.parseActionHelperAttribs(_loc3_,m_tasks[_loc2_]);
            m_tasks[_loc2_].state = int(_loc3_.@state);
            m_tasks[_loc2_].merc = String(_loc3_.@merc);
            m_tasks[_loc2_].neighbor = String(_loc3_.@neighbor);
            m_tasks[_loc2_].code = String(_loc3_.@code);
            m_tasks[_loc2_].resource = String(_loc3_.@resource);
            m_tasks[_loc2_].dialog = String(_loc3_.@dialog);
            m_tasks[_loc2_].zoom = String(_loc3_.@zoom);
            m_tasks[_loc2_].string = String(_loc3_.@string);
            m_tasks[_loc2_].helperAction = String(_loc3_.@helperAction);
            m_tasks[_loc2_].byReferenceItem = String(_loc3_.@byReferenceItem);
            m_tasks[_loc2_].resourceType = String(_loc3_.@resourceType);
            m_tasks[_loc2_].advisorOnly = String(_loc3_.@advisorOnly);
            m_tasks[_loc2_].isUpgrade = String(_loc3_.@isUpgrade);
            m_tasks[_loc2_].decoEffect = String(_loc3_.@decoEffect);
            m_tasks[_loc2_].battleBackground = String(_loc3_.@battleBackground);
            m_tasks[_loc2_].superore = String(_loc3_.@superore);
            m_tasks[_loc2_].type = String(_loc3_.@type);
            if(_loc3_.@minMultiplier != undefined)
            {
               m_tasks[_loc2_].minMultiplier = Number(_loc3_.@minMultiplier);
            }
            if(_loc3_.unit.length() > 0)
            {
               _loc4_ = new Object();
               this.parseActionHelperAttribs(_loc3_.unit[0],_loc4_);
               m_tasks[_loc2_].unit = _loc4_;
            }
            _loc2_++;
         }
      }
      
      private function parseActionHelperAttribs(param1:XML, param2:Object) : void
      {
         param2.type = String(param1.@type);
         param2.subType = String(param1.@subtype);
         param2.item = String(param1.@item);
         param2.itemToken = String(param1.@itemTk);
         param2.unitClass = String(param1.@unitClass);
         param2.unitType = String(param1.@unitType);
         param2.resourceType = String(param1.@resourceType);
      }
      
      public function createTasks() : Array
      {
         var _loc3_:XML = null;
         var _loc4_:ZGameTask = null;
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < m_xml.tasks.task.length())
         {
            _loc3_ = m_xml.tasks.task[_loc2_];
            _loc4_ = ZGameTask.Create(_loc2_,_loc3_,name,this.startLevel);
            _loc1_.push(_loc4_);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function set startTime(param1:Number) : void
      {
         this.m_startTime = param1;
      }
      
      public function set startLevel(param1:Number) : void
      {
         this.m_startLevel = param1;
      }
      
      public function get startLevel() : Number
      {
         return this.m_startLevel;
      }
      
      public function set serverRewards(param1:Array) : void
      {
         this.m_serverRewards = param1;
      }
      
      public function get serverRewards() : Array
      {
         return this.m_serverRewards;
      }
      
      public function get xml() : XML
      {
         return m_xml;
      }
      
      public function get autoOpen() : Boolean
      {
         return m_xml.@autoOpen != null && m_xml.@autoOpen.toString() == "true";
      }
      
      public function get title() : String
      {
         return m_xml.@title == null ? null : m_xml.@title.toString();
      }
      
      public function get complete() : String
      {
         return m_xml.@complete == null ? null : m_xml.@complete.toString();
      }
      
      public function get desc() : String
      {
         return m_xml.@desc == null ? null : m_xml.@desc.toString();
      }
      
      public function get difficultyModeDesc() : String
      {
         return m_xml.reward.difficultyMode.@desc == null ? null : m_xml.reward.difficultyMode.@desc.toString();
      }
      
      public function get hint() : String
      {
         return m_xml.@hint == null ? null : m_xml.@hint.toString();
      }
      
      public function get viral() : String
      {
         return this.xml.@viral == null ? null : this.xml.@viral.toString();
      }
      
      public function get advisorId() : String
      {
         return this.xml.@advisorId == null ? null : this.xml.@advisorId.toString();
      }
      
      public function get advisorQuestPopupIconOverride() : String
      {
         return this.xml.@advisorQuestPopupIconOverride == null ? null : this.xml.@advisorQuestPopupIconOverride.toString();
      }
      
      public function get finishButtonText() : String
      {
         if(this.xml.@finishButtonText != undefined)
         {
            return this.xml.@finishButtonText;
         }
         return null;
      }
      
      public function get introIcon() : String
      {
         return !this.xml.@introIcon ? null : this.xml.@introIcon.toString();
      }
      
      public function get buttonIconType() : String
      {
         return !this.xml.@buttonIconType ? null : this.xml.@buttonIconType.toString();
      }
      
      public function get isAllianceQuest() : Boolean
      {
         return !this.xml.@allianceQuest ? false : this.xml.@allianceQuest.toString() == "true";
      }
      
      public function get introTooltip() : String
      {
         return !this.xml.@introToolTip ? null : this.xml.@introTooltip.toString();
      }
      
      public function get introSpeech() : String
      {
         return !this.xml.@introSpeech ? null : this.xml.@introSpeech.toString();
      }
      
      public function get hasDate() : Boolean
      {
         return this.xml.requiredDate != undefined;
      }
      
      public function get hasLifeTime() : Boolean
      {
         return this.xml.@lifeTime != undefined;
      }
      
      public function get showTimer() : Boolean
      {
         return this.xml.@showTimer != undefined && this.xml.@showTimer.toString() == "true";
      }
      
      public function get campaignName() : String
      {
         return !this.xml.@campaignName ? null : this.xml.@campaignName.toString();
      }
      
      public function get shouldShowTimer() : Boolean
      {
         return this.showTimer || this.hasLifeTime || ZGlobal.player.questTrees.isQuestTreeQuest(name);
      }
      
      public function get hideCompleteDialog() : Boolean
      {
         return Boolean(this.xml.@hideCompleteDialog) && this.xml.@hideCompleteDialog.toString() == "true";
      }
      
      public function get placeObjectOnQuestDialogClosed() : String
      {
         return this.xml.@placeObjectOnQuestDialogClosed != undefined ? this.xml.@placeObjectOnQuestDialogClosed.toString() : null;
      }
      
      public function get dialogAcceptButtonOverride() : String
      {
         return this.xml.@dialogAcceptButtonOverride != undefined ? this.xml.@dialogAcceptButtonOverride.toString() : null;
      }
      
      public function get onDialogClosedShowInviteTabView() : String
      {
         return this.xml.@onDialogClosedShowInviteTabView != undefined ? this.xml.@onDialogClosedShowInviteTabView.toString() : null;
      }
      
      public function get firstArmyResearchQuest() : Boolean
      {
         return this.xml.@firstArmyResearchQuest != undefined;
      }
      
      public function get firstNavyResearchQuest() : Boolean
      {
         return this.xml.@firstNavyResearchQuest != undefined;
      }
      
      public function get firstAirResearchQuest() : Boolean
      {
         return this.xml.@firstAirResearchQuest != undefined;
      }
      
      public function get grantQuestTreeReward() : Boolean
      {
         return this.xml.@grantQuestTreeReward != undefined;
      }
      
      public function get grantMSFinalReward() : Boolean
      {
         return this.xml.@type == "MS_final_reward";
      }
      
      public function get rewardType() : int
      {
         return !this.xml.@rewardType ? 1 : int(parseInt(this.xml.@rewardType));
      }
      
      public function get rewardCrateType() : String
      {
         return !this.xml.@rewardCrateType ? "S" : this.xml.@rewardCrateType.toString();
      }
      
      public function get anyParentUnlocks() : Boolean
      {
         return this.xml.@prereqCheck == "any";
      }
      
      public function get priority() : int
      {
         return this.xml.@priority == undefined ? 1000 : int(this.xml.@priority);
      }
      
      public function get hideRewards() : Boolean
      {
         return this.xml.@hideRewards == "true";
      }
      
      public function get hideCompletePopup() : Boolean
      {
         return this.xml.@hideCompletePopup == "true";
      }
      
      public function get forced() : Boolean
      {
         return this.xml.@forced == "true";
      }
      
      public function get textReplacements() : String
      {
         return this.xml.@textReplacements.toString();
      }
      
      public function get sequels() : Array
      {
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         var _loc1_:Array = [];
         if(this.xml.hasOwnProperty("sequels") && this.xml.sequels.hasOwnProperty("sequel") && Boolean(this.xml.sequels.sequel.length()))
         {
            _loc2_ = 0;
            while(_loc2_ < this.xml.sequels.sequel.length())
            {
               _loc3_ = this.xml.sequels.sequel[_loc2_];
               if(_loc3_.@name != undefined)
               {
                  _loc1_.push(_loc3_.@name.toString());
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      public function get lifeTime() : Number
      {
         if(this.xml.@lifeTime != undefined)
         {
            return ZGameTimeUtil.instance.parseTimeAsSeconds(this.xml.@lifeTime.toString(),0);
         }
         return 0;
      }
      
      public function get restartCost() : int
      {
         if(this.xml.@restartCost != undefined)
         {
            return parseInt(this.xml.@restartCost.toString());
         }
         return 0;
      }
      
      public function get startCost() : int
      {
         if(this.xml.@startCost != undefined)
         {
            return parseInt(this.xml.@startCost.toString());
         }
         return 0;
      }
      
      public function get itemCode() : String
      {
         return m_xml.@itemCode == null ? null : m_xml.@itemCode.toString();
      }
      
      public function getTimeRemaining() : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(name);
         if(_loc1_)
         {
            return ZGlobal.player.questTrees.getQuestTreeRemainingTime(_loc1_);
         }
         if(!this.lifeTime && this.hasDate && this.showTimer)
         {
            return this.getLETimeRemaining();
         }
         var _loc2_:Number = GlobalEngine.getTimer() / 1000;
         var _loc3_:int = int(_loc2_ - this.m_startTime);
         if(_loc3_ < this.lifeTime)
         {
            _loc4_ = this.lifeTime - _loc3_;
            _loc5_ = this.getLETimeRemaining();
            if(_loc5_ != 0 && _loc5_ < _loc4_)
            {
               return _loc5_;
            }
            return _loc4_;
         }
         return 0;
      }
      
      public function getLETimeRemaining() : int
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         if(this.hasDate)
         {
            _loc1_ = {"stringNotUsed":true};
            _loc2_ = ZGameTimeUtil.instance.getDateStatus(_loc1_,m_xml);
            if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
            {
               return _loc1_.delta;
            }
         }
         return 0;
      }
      
      public function getEndSeconds() : int
      {
         if(ZGameTimeUtil.instance.getEndSeconds(this.xml) > 0)
         {
            return ZGameTimeUtil.instance.getEndSeconds(this.xml);
         }
         return 0;
      }
      
      public function isExpired() : Boolean
      {
         return this.getTimeRemaining() <= 0;
      }
      
      public function popup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(m_xml.popup.length() == 1)
         {
            _loc1_ = m_xml.popup[0];
            _loc2_ = ZGameUtils.ZlocTP("Quests",_loc1_.@title.toString());
            _loc3_ = ZGameUtils.ZlocTP("Quests",_loc1_.@desc.toString());
            PopupManager.instance.push(new HudsonPopup(_loc3_,_loc2_));
         }
      }
      
      private function unlockTutorial() : void
      {
         var _loc1_:String = m_xml.@unlockTutorial.toString();
         if(_loc1_.length > 0)
         {
            TutorialManager.instance.tutorial = _loc1_;
         }
      }
      
      public function unlockTutorialOnStart() : void
      {
         var _loc1_:String = m_xml.@unlockTutorialOnStart.toString();
         if(_loc1_.length > 0)
         {
            TutorialManager.instance.unlockTutorial(_loc1_);
         }
      }
      
      public function giveRewards(param1:String = null) : void
      {
         var _loc2_:RewardHelper = null;
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:Object = null;
         this.unlockTutorial();
         if(Boolean(this.m_serverRewards) && this.m_serverRewards.length > 0)
         {
            delete m_xml.reward;
            _loc4_ = <reward/>;
            for each(_loc5_ in this.m_serverRewards)
            {
               if(_loc5_.id == "item.gift")
               {
                  _loc4_.@type = "item";
                  _loc4_.@count = _loc5_.yield ? _loc5_.yield : 1;
                  _loc4_.@item = _loc5_.code;
               }
               else if(_loc5_.id == "resource.gift")
               {
                  _loc4_.@type = _loc5_.name;
                  _loc4_.@count = _loc5_.yield;
               }
               else if(_loc5_.id == "xp.gift")
               {
                  _loc4_.@type = "xp";
                  _loc4_.@count = _loc5_.yield;
               }
               else if(_loc5_.id == "cash")
               {
                  _loc4_.@type = "cash";
                  _loc4_.@count = _loc5_.yield;
               }
               m_xml.appendChild(_loc4_);
               _loc2_ = new RewardHelper(_loc4_);
               _loc2_.execute();
            }
            return;
         }
         for each(_loc3_ in m_xml.reward)
         {
            if(_loc3_.@type.toString() != "mysteryItem")
            {
               if(!(ZGameTimeUtil.instance.getDateStatus(null,_loc3_) == ZGameTimeUtil.DATE_STATUS_LATE || ZGameTimeUtil.instance.getDateStatus(null,_loc3_) == ZGameTimeUtil.DATE_STATUS_EARLY))
               {
                  _loc2_ = new RewardHelper(_loc3_);
                  _loc2_.execute();
               }
            }
         }
      }
      
      public function getTextObject(param1:Object, param2:Array) : void
      {
         var _loc5_:ZGameTask = null;
         var _loc3_:Object = QuestManager.getInstance().getQuestProgressByName(name);
         param1.taskText = new Array();
         param1.taskIcons = new Array();
         param1.taskComplete = new Array();
         param1.taskProgress = new Array();
         param1.taskBuyable = new Array();
         param1.taskItemBuyAmountCash = new Array();
         param1.taskItemBuyAmount = new Array();
         param1.taskRequestable = new Array();
         param1.requestButtonText = new Array();
         param1.taskFeeds = new Array();
         param1.taskBattle = new Array();
         param1.taskSurvivalBattle = new Array();
         param1.taskRequestAction = new Array();
         param1.taskItemBuyable = new Array();
         param1.taskItem = new Array();
         param1.taskItemToken = new Array();
         param1.taskInvites = new Array();
         param1.taskSpendButton = new Array();
         param1.taskTotal = new Array();
         param1.taskCounterType = new Array();
         param1.taskHint = new Array();
         param1.taskPan = new Array();
         param1.panButtonText = new Array();
         param1.taskBuild = new Array();
         param1.buildButtonText = new Array();
         param1.taskShowParts = new Array();
         param1.taskShowPartsText = new Array();
         var _loc4_:Object = ZGameUtils.buildLocalizedParams();
         this.addAdditionalParams(_loc4_);
         param1.title = ZGameUtils.ZlocTP("Quests",this.title,_loc4_);
         param1.desc = ZGameUtils.ZlocTP("Quests",this.desc,_loc4_);
         param1.hint = ZGameUtils.ZlocTP("Quests",this.hint,_loc4_);
         for each(_loc5_ in param2)
         {
            if(!_loc5_.ghost)
            {
               param1.taskText.push(_loc5_.mainText);
               param1.taskIcons.push(_loc5_.icon);
               param1.taskProgress.push(_loc5_.progressText);
               param1.taskComplete.push(_loc5_.complete);
               param1.taskBuyable.push(_loc5_.buyable);
               param1.taskItemBuyAmountCash.push(_loc5_.remainingItemCash);
               param1.taskItemBuyAmount.push(_loc5_.remainingItemAmount);
               param1.taskRequestable.push(_loc5_.requestable);
               param1.requestButtonText.push(_loc5_.requestButtonText);
               param1.taskFeeds.push(_loc5_.feedData);
               param1.taskBattle.push(_loc5_.battleData);
               param1.taskSurvivalBattle.push(_loc5_.survivalBattleData);
               param1.taskRequestAction.push(_loc5_.requestButtonAction);
               param1.taskItemBuyable.push(_loc5_.itemBuyable);
               param1.taskItem.push(_loc5_.item);
               param1.taskItemToken.push(_loc5_.itemToken);
               param1.taskInvites.push(_loc5_.invite);
               param1.taskSpendButton.push(_loc5_.spendButton);
               param1.taskTotal.push(_loc5_.total);
               param1.taskCounterType.push(_loc5_.counterType);
               param1.taskHint.push(_loc5_.hint);
               param1.taskPan.push(_loc5_.taskPan);
               param1.panButtonText.push(_loc5_.panButtonText);
               param1.taskBuild.push(_loc5_.taskBuild);
               param1.buildButtonText.push(_loc5_.buildButtonText);
               param1.taskShowParts.push(_loc5_.showPartsGather);
               param1.taskShowPartsText.push(_loc5_.showPartsGatherText);
            }
         }
      }
      
      public function getRewardTextObject(param1:int = 3) : Object
      {
         var _loc4_:XML = null;
         var _loc5_:RewardHelper = null;
         var _loc2_:Object = new Object();
         _loc2_.rewardText = new Array();
         _loc2_.rewardIcons = new Array();
         _loc2_.rewardPairs = new Array();
         _loc2_.rewardBuyable = new Array();
         _loc2_.rewardItems = new Array();
         var _loc3_:Object = ZGameUtils.buildLocalizedParams();
         this.addAdditionalParams(_loc3_);
         _loc2_.title = ZGameUtils.ZlocTP("Quests",this.title,_loc3_);
         _loc2_.desc = ZGameUtils.ZlocTP("Quests",this.complete,_loc3_);
         for each(_loc4_ in m_xml.reward)
         {
            if(_loc4_.@type != "mysteryItem")
            {
               if(!(ZGameTimeUtil.instance.getDateStatus(null,_loc4_) == ZGameTimeUtil.DATE_STATUS_LATE || ZGameTimeUtil.instance.getDateStatus(null,_loc4_) == ZGameTimeUtil.DATE_STATUS_EARLY))
               {
                  _loc5_ = new RewardHelper(_loc4_);
                  _loc5_.buildUI(_loc2_,param1);
               }
            }
         }
         return _loc2_;
      }
      
      public function get rewardsArr() : Array
      {
         var _loc2_:XML = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in m_xml.reward)
         {
            if(_loc2_.@type != "mysteryItem")
            {
               _loc1_.push({
                  "type":_loc2_.@type,
                  "item":_loc2_.@item
               });
            }
         }
         return _loc1_;
      }
      
      public function get placeableReward() : String
      {
         var _loc1_:XML = null;
         for each(_loc1_ in m_xml.reward)
         {
            if(_loc1_.@placeable == "true")
            {
               return _loc1_.@item.toString();
            }
         }
         return null;
      }
      
      public function isLimitedEdition() : Boolean
      {
         return ZGameTimeUtil.instance.isLimitedEdition(m_xml);
      }
      
      override protected function calcTotal(param1:XML) : int
      {
         var _loc2_:int = super.calcTotal(param1);
         return ZGameTask.calcTotal(param1,_loc2_,this.m_startLevel,name);
      }
      
      public function recomputeTotals() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.xml.tasks.task.length())
         {
            m_tasks[_loc1_].total = this.calcTotal(m_xml.tasks.task[_loc1_]);
            _loc1_++;
         }
      }
      
      private function addAdditionalParams(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = ZGameUtils.callFunctionFromXml(this.textReplacements);
         for(_loc3_ in _loc2_)
         {
            param1[_loc3_] = _loc2_[_loc3_];
         }
      }
      
      public function get refillEnergy() : Boolean
      {
         return this.xml.@refillEnergy != undefined && this.xml.@refillEnergy.toString() == "true";
      }
      
      public function get customQuestCompletDialog() : Boolean
      {
         return this.xml.@customQuestCompletDialog != undefined && this.xml.@customQuestCompletDialog.toString() == "true";
      }
   }
}

