package core.managers.questManager
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.AllianceQuestManager;
   import core.managers.MegaseriesManager;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.ui.menuitem.QuestsUIItem;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TBuyQuestTask;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class ZGameQuestManager extends QuestManager
   {
      
      public static const NEW_QUEST_AVAILABLE:String = "questnew";
      
      public static const QUEST_COMPLETE:String = "questcomplete";
      
      public static const QUEST_EXPIRED:String = "questexpired";
      
      public static const QUEST_PROGRESS:String = "questprogress";
      
      public static const QUEST_REWARDS_GIVEN:String = "questrewardsgiven";
      
      public static const TASK_COMPLETE:String = "taskcomplete";
      
      public static const TASK_PARTIAL_COMPLETE:String = "taskpartialcomplete";
      
      public static const QUEST_RESTARTED:String = "questRestarted";
      
      public static const CLIENT_QUEST_ACTIVATED:String = "clientQuestActivated";
      
      public static const QUESTS_STARTED:String = "questsStarted";
      
      public static const QUESTS_LOADED:String = "questsLoaded";
      
      public static const QUESTS_PARTSGATHER:String = "showDialog";
      
      private static const TYPE_COMPLETE:int = 0;
      
      private static const TYPE_PROGRESS:int = 1;
      
      private var m_prereqs:Dictionary = new Dictionary();
      
      private var m_quests:Dictionary = new Dictionary();
      
      private var m_receivedInit:Boolean = false;
      
      private var m_queueQuests:Boolean = true;
      
      private var m_questQueue:Array = new Array();
      
      private var m_seenQuests:Array = new Array();
      
      private var m_purchasedQuestTasks:Dictionary = new Dictionary();
      
      private var m_questStartBatchNumbers:Dictionary = new Dictionary();
      
      private var m_completedQuests:Dictionary = new Dictionary();
      
      public function ZGameQuestManager()
      {
         super();
         addEventListener(QuestEvent.PROGRESS,this.onZQuestProgress,false,0,true);
         addEventListener(QuestEvent.COMPLETED,this.onZQuestCompleted,false,0,true);
         addEventListener(QuestEvent.EXPIRED,this.onZQuestExpired,false,0,true);
      }
      
      public static function init() : void
      {
         QuestManager.getInstance(ZGameQuestManager);
      }
      
      public static function get instance() : ZGameQuestManager
      {
         return QuestManager.getInstance() as ZGameQuestManager;
      }
      
      override public function initialize() : void
      {
         super.initialize();
         this.initDependenciesFromSettings();
      }
      
      public function clientActivateQuest(param1:String) : void
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(!this.m_quests[param1])
         {
            this.m_quests[param1] = _loc2_.createTasks();
         }
         var _loc3_:Object = getQuestProgressByName(param1);
         if(!_loc3_)
         {
            _loc5_ = new Array(_loc2_.tasks.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length)
            {
               _loc5_[_loc6_] = 0;
               _loc6_++;
            }
            _loc3_ = {
               "name":param1,
               "expired":false,
               "startTime":0,
               "progress":_loc5_
            };
            _loc7_ = ZGlobal.player.questInitAsn;
            m_activeQuests.push(_loc3_);
         }
         var _loc4_:Object = {
            "id":_loc2_.name,
            "autoOpen":_loc2_.autoOpen,
            "visible":_loc2_.visible,
            "fromInit":false
         };
         dispatchEvent(new WorldEvent(NEW_QUEST_AVAILABLE,_loc4_));
         dispatchEvent(new WorldEvent(CLIENT_QUEST_ACTIVATED,{"quest":param1}));
      }
      
      public function getQuestTasks(param1:String) : Array
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         if(null == param1)
         {
            _loc2_ = new Array();
            for each(_loc3_ in this.m_quests)
            {
               _loc2_ = _loc2_.concat(_loc3_);
            }
            return _loc2_;
         }
         return this.m_quests[param1];
      }
      
      public function getQuestTaskIndex(param1:String, param2:ZGameTask) : int
      {
         return this.m_quests[param1].indexOf(param2);
      }
      
      public function getCurrentVillain(param1:String = null) : GameItem
      {
         var _loc3_:ZGameTask = null;
         var _loc4_:GameItem = null;
         var _loc2_:Array = this.getQuestTasks(null);
         if(param1)
         {
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_.fleetname == param1)
               {
                  return this.getVillainItem(_loc3_);
               }
            }
         }
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = this.getVillainItem(_loc3_);
            if(_loc4_)
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public function getTaskInfoFromFleetName(param1:String) : Object
      {
         var _loc3_:Quest = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:ZGameTask = null;
         var _loc2_:Vector.<Quest> = getActiveQuests();
         loop0:
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = this.getQuestTasks(_loc3_.name);
            _loc5_ = 0;
            var _loc9_:int = 0;
            var _loc10_:* = _loc4_;
            loop1:
            while(true)
            {
               for each(_loc6_ in _loc10_)
               {
                  if(_loc6_.fleetName == param1)
                  {
                     break loop1;
                  }
                  _loc5_++;
               }
               continue loop0;
            }
            return {
               "id":_loc3_.name,
               "index":_loc5_,
               "villain":_loc6_.villain
            };
         }
         return null;
      }
      
      private function getVillainItem(param1:ZGameTask) : GameItem
      {
         if(param1.villain != null)
         {
            return ZGlobal.gameSettings.getItemByCode(param1.villain,GameItem) as GameItem;
         }
         if(param1.pveVillain != null)
         {
            return ZGlobal.gameSettings.getItemByCode(param1.pveVillain,GameItem) as GameItem;
         }
         return null;
      }
      
      public function get receivedInit() : Boolean
      {
         return this.m_receivedInit;
      }
      
      private function updateTaskCompletion(param1:ZGameQuest) : void
      {
         var _loc2_:Object = getQuestProgressByName(param1.name);
         var _loc3_:Vector.<Object> = param1.tasks;
         var _loc4_:Array = this.m_quests[param1.name];
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.progress.length)
         {
            if(_loc2_.progress[_loc5_] >= _loc3_[_loc5_].total)
            {
               _loc4_[_loc5_].setComplete();
               if(!isQuestTaskCompleted(_loc2_,_loc5_))
               {
                  setQuestTaskCompleted(_loc2_,_loc5_);
               }
            }
            _loc5_++;
         }
      }
      
      protected function onZQuestProgress(param1:QuestEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:ZGameQuest = param1.quest as ZGameQuest;
         if(this.m_queueQuests)
         {
            _loc3_ = this.getQuestQueueIndex(_loc2_.name);
            if(_loc3_ < 0)
            {
               this.m_questQueue.push({
                  "priority":_loc2_.priority,
                  "name":_loc2_.name
               });
            }
         }
         else
         {
            this.doProgressQuest(_loc2_.name,false);
         }
      }
      
      public function startQuests() : void
      {
         var _loc1_:Object = null;
         var _loc2_:ZGameQuest = null;
         this.m_queueQuests = false;
         this.m_questQueue.sortOn("priority",Array.NUMERIC);
         for each(_loc1_ in this.m_questQueue)
         {
            if(_loc1_.complete)
            {
               if(!this.m_quests[_loc1_.name])
               {
                  _loc2_ = QuestSettingsInit.getInstance().getItemByName(_loc1_.name) as ZGameQuest;
                  if(_loc2_)
                  {
                     this.m_quests[_loc1_.name] = _loc2_.createTasks();
                  }
               }
               this.doCompleteQuest(_loc1_.name);
            }
            else
            {
               this.doProgressQuest(_loc1_.name,true);
            }
         }
         dispatchEvent(new WorldEvent(QUESTS_LOADED));
         this.m_questQueue = null;
      }
      
      private function addNewNotifyQuests(param1:ZGameQuest) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:int = 0;
         if(!ZGlobal.player.isQuestNotificationSeen(param1.name))
         {
            if(this.isAlmostCompletedQuest(param1))
            {
               ZGlobal.player.notifyQuest(param1.name);
            }
            else
            {
               if(param1.shouldShowTimer)
               {
                  _loc2_ = param1.getTimeRemaining();
                  _loc3_ = Math.round(_loc2_ / 86400);
               }
               else if(param1.hasDate)
               {
                  _loc2_ = param1.getLETimeRemaining();
               }
               if(_loc2_ > 0)
               {
                  _loc4_ = Math.round(_loc2_ / 86400);
                  if(_loc4_ <= 2)
                  {
                     ZGlobal.player.notifyQuest(param1.name);
                  }
               }
            }
         }
      }
      
      private function isAlmostCompletedQuest(param1:ZGameQuest) : Boolean
      {
         var _loc5_:ZGameTask = null;
         var _loc2_:Array = this.m_quests[param1.name];
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         for each(_loc5_ in _loc2_)
         {
            if(_loc5_.complete)
            {
               _loc4_++;
            }
         }
         if(_loc3_ - _loc4_ <= 1)
         {
            return true;
         }
         return false;
      }
      
      private function doProgressQuest(param1:String, param2:Boolean) : void
      {
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(null == this.m_quests[param1])
         {
            this.m_quests[param1] = _loc3_.createTasks();
            _loc3_.popup();
            _loc3_.unlockTutorialOnStart();
            if(QuestsUIItem.isQuestBar2())
            {
               this.addNewNotifyQuests(_loc3_);
            }
            if(_loc3_.isAllianceQuest)
            {
               AllianceQuestManager.instance.setQuest(_loc3_.name);
               AllianceQuestManager.instance.showFlag();
            }
            dispatchEvent(new WorldEvent(NEW_QUEST_AVAILABLE,{
               "id":_loc3_.name,
               "autoOpen":_loc3_.autoOpen,
               "visible":_loc3_.visible,
               "fromInit":param2
            }));
         }
         else
         {
            this.updateTaskCompletion(_loc3_);
            dispatchEvent(new WorldEvent(QUEST_PROGRESS,_loc3_.name));
         }
      }
      
      public function getTextObject(param1:String) : Object
      {
         var _loc4_:Array = null;
         var _loc2_:Object = new Object();
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(_loc3_)
         {
            _loc4_ = this.m_quests[_loc3_.name];
            if(_loc4_)
            {
               _loc3_.getTextObject(_loc2_,_loc4_);
            }
         }
         return _loc2_;
      }
      
      protected function onZQuestCompleted(param1:QuestEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:ZGameQuest = param1.quest as ZGameQuest;
         if(_loc2_.isAllianceQuest)
         {
            AllianceQuestManager.instance.hideFlag();
         }
         if(this.m_queueQuests)
         {
            _loc3_ = this.getQuestQueueIndex(_loc2_.name);
            if(_loc3_ < 0)
            {
               this.m_questQueue.push({
                  "priority":_loc2_.priority,
                  "name":_loc2_.name,
                  "complete":true
               });
            }
            else
            {
               this.m_questQueue[_loc3_].complete = true;
            }
         }
         else
         {
            this.doCompleteQuest(_loc2_.name);
         }
      }
      
      protected function onZQuestExpired(param1:QuestEvent) : void
      {
         var _loc2_:ZGameQuest = param1.quest as ZGameQuest;
         this.doExpireQuest(_loc2_.name);
         if(_loc2_.isAllianceQuest)
         {
            AllianceQuestManager.instance.hideFlag();
         }
      }
      
      protected function doExpireQuest(param1:String) : void
      {
         var _loc4_:ZGameTask = null;
         var _loc5_:Number = NaN;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(this.m_completedQuests[_loc2_.name])
         {
            return;
         }
         this.m_completedQuests[_loc2_.name] = 1;
         var _loc3_:Array = this.m_quests[_loc2_.name];
         if(null != _loc3_)
         {
            for each(_loc4_ in _loc3_)
            {
               _loc4_.setComplete();
            }
            ZGlobal.player.addCompletedQuestName(_loc2_.name);
            _loc5_ = _loc2_.popupDelay * 1000;
            QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_EXPIRED,{"name":_loc2_.name}));
            PlayerQuestTrees.resetBranchesForCompletedQuest(_loc2_.name);
            delete this.m_quests[_loc2_.name];
         }
      }
      
      protected function doCompleteQuest(param1:String) : void
      {
         var _loc4_:ZGameTask = null;
         var _loc5_:Number = NaN;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(this.m_completedQuests[_loc2_.name])
         {
            return;
         }
         this.m_completedQuests[_loc2_.name] = 1;
         var _loc3_:Array = this.m_quests[_loc2_.name];
         if(null != _loc3_)
         {
            for each(_loc4_ in _loc3_)
            {
               _loc4_.setComplete();
            }
            ZGlobal.player.addCompletedQuestName(_loc2_.name);
            _loc5_ = _loc2_.popupDelay * 1000;
            QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_COMPLETE,{
               "name":_loc2_.name,
               "delay":_loc5_,
               "visible":_loc2_.visible,
               "hideCompleteDialog":_loc2_.hideCompleteDialog
            }));
            _loc2_.giveRewards();
            PlayerQuestTrees.resetBranchesForCompletedQuest(_loc2_.name);
            MegaseriesManager.instance.doProgressMegaseries(_loc2_.name);
            QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_REWARDS_GIVEN,{
               "name":_loc2_.name,
               "delay":_loc5_
            }));
            ViralsManager.instance.questCompleteViral(_loc2_.viral);
            delete this.m_quests[_loc2_.name];
         }
      }
      
      public function removeItemOnComplete(param1:ZGameTask) : void
      {
         var _loc2_:int = 0;
         if(param1.removeItemOnComplete)
         {
            if(param1.item)
            {
               _loc2_ = ZGlobal.player.getNumberOfInventoryItems(param1.item);
               if(_loc2_ > 0)
               {
                  ZGlobal.player.removeInventoryItem(param1.item,_loc2_);
               }
            }
         }
      }
      
      override protected function onTransactionComplete(param1:TransactionEvent) : void
      {
         this.storeNewQuests(param1);
         this.setQuestStartTimesAndServerRewards(param1);
         super.onTransactionComplete(param1);
         this.handleBatchCompletedQuests(param1);
         if(param1.transaction.rawResult.metadata.QuestComponentExistingQuests)
         {
            this.m_seenQuests = param1.transaction.rawResult.metadata.QuestComponentExistingQuests;
         }
         if(!this.m_receivedInit)
         {
            this.m_receivedInit = true;
            dispatchEvent(new Event(Event.INIT));
         }
      }
      
      public function getTooltip(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:String = _loc2_.xml.@tooltip;
         if(_loc3_.length > 0)
         {
            return ZGameUtils.ZlocTP("Quests",_loc2_.xml.@tooltip);
         }
         return ZGameUtils.ZlocTP("Quests",_loc2_.xml.@title);
      }
      
      private function getRareOrIconPath(param1:String) : String
      {
         if(param1 == "rare")
         {
            return WorldResourceManager.instance.getResourceImageURL(ZGlobal.player.rareResourceType);
         }
         return ZGlobal.getAssetURL(param1);
      }
      
      public function getIconPath(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         return this.getRareOrIconPath(_loc2_.xml.@icon.toString());
      }
      
      public function getButtonIconPath(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         return this.getRareOrIconPath(_loc2_.xml.@buttonIcon.toString());
      }
      
      public function getIntroButtonIconPath(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         return this.getRareOrIconPath(_loc2_.xml.@introIcon.toString());
      }
      
      public function getPrequisitesForQuest(param1:String) : Array
      {
         return this.m_prereqs[param1];
      }
      
      public function hasSeenQuest(param1:String) : Boolean
      {
         var _loc2_:String = null;
         for each(_loc2_ in this.m_seenQuests)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function fightTaskWinPopupUsesFirstVictory(param1:String) : Boolean
      {
         var _loc3_:ZGameTask = null;
         var _loc4_:FightItemTask = null;
         var _loc2_:Array = this.getQuestTasks(param1);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = _loc3_ as FightItemTask;
               if((Boolean(_loc4_)) && Boolean(_loc4_.isPVE) && _loc4_.winPopupUsesFirstVictory)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getEpisodeDialog(param1:String) : String
      {
         var _loc3_:ZGameTask = null;
         var _loc4_:FightItemTask = null;
         var _loc2_:Array = this.getQuestTasks(param1);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = _loc3_ as FightItemTask;
               if((Boolean(_loc4_)) && Boolean(_loc4_.episodeDialog))
               {
                  return _loc4_.episodeDialog;
               }
            }
         }
         return null;
      }
      
      public function getDefaultSelectionSlot(param1:String) : int
      {
         var _loc3_:ZGameTask = null;
         var _loc4_:FightItemTask = null;
         var _loc2_:Array = this.getQuestTasks(param1);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = _loc3_ as FightItemTask;
               if((Boolean(_loc4_)) && Boolean(_loc4_.defaultSelectSlot))
               {
                  return int(_loc4_.defaultSelectSlot);
               }
            }
         }
         return -1;
      }
      
      public function isQuestPVPBattle(param1:String) : Boolean
      {
         var _loc2_:Vector.<Quest> = getActiveQuests();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].name == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isQuestActive(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < m_activeQuests.length)
         {
            _loc4_ = m_activeQuests[_loc3_];
            if(_loc4_.name == param1)
            {
               if(!_loc4_.complete || param2)
               {
                  return true;
               }
            }
            _loc3_++;
         }
         return false;
      }
      
      public function resetQuest(param1:String) : void
      {
         var _loc2_:* = int(m_activeQuests.length);
         while(_loc2_--)
         {
            if(param1 == m_activeQuests[_loc2_].name)
            {
               m_activeQuests.splice(_loc2_,1);
            }
         }
         delete this.m_completedQuests[param1];
         delete this.m_quests[param1];
         delete this.m_purchasedQuestTasks[param1];
         ZGlobal.player.removeCompletedQuestName(param1);
      }
      
      public function questTreeReset(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc4_:Array = null;
         var _loc5_:XML = null;
         var _loc6_:* = 0;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc3_:XML = ZGlobal.gameSettings.getQuestTree(param1);
         if(Boolean(_loc3_) && Boolean(_loc3_.node))
         {
            _loc4_ = new Array();
            for each(_loc5_ in _loc3_.node)
            {
               if(_loc5_.@quest != undefined)
               {
                  _loc7_ = _loc5_.@quest.toString();
                  _loc4_.push(_loc7_);
                  if(!_loc2_)
                  {
                     _loc2_ = _loc7_;
                  }
                  delete this.m_completedQuests[_loc7_];
                  delete this.m_quests[_loc7_];
                  delete this.m_purchasedQuestTasks[_loc7_];
                  ZGlobal.player.removeCompletedQuestName(_loc7_);
               }
            }
            _loc6_ = int(m_activeQuests.length);
            while(_loc6_--)
            {
               _loc8_ = _loc4_.indexOf(m_activeQuests[_loc6_].name);
               if(_loc8_ >= 0)
               {
                  m_activeQuests.splice(_loc6_,1);
               }
            }
         }
         if(_loc2_)
         {
            this.clientActivateQuest(_loc2_);
         }
      }
      
      public function megaSeriesReset(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc4_:Array = null;
         var _loc5_:XML = null;
         var _loc6_:* = 0;
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc3_:XML = ZGlobal.gameSettings.getMegaSeries(param1);
         if(_loc3_)
         {
            _loc4_ = new Array();
            for each(_loc5_ in _loc3_.stage)
            {
               for each(_loc7_ in _loc5_.node)
               {
                  if(_loc7_.@quest != undefined)
                  {
                     _loc8_ = _loc7_.@quest.toString();
                     _loc4_.push(_loc8_);
                     if(!_loc2_)
                     {
                        _loc2_ = _loc8_;
                     }
                     delete this.m_completedQuests[_loc8_];
                     delete this.m_quests[_loc8_];
                     delete this.m_purchasedQuestTasks[_loc8_];
                     ZGlobal.player.removeCompletedQuestName(_loc8_);
                  }
               }
            }
            _loc6_ = int(m_activeQuests.length);
            while(_loc6_--)
            {
               _loc9_ = _loc4_.indexOf(m_activeQuests[_loc6_].name);
               if(_loc9_ >= 0)
               {
                  m_activeQuests.splice(_loc6_,1);
               }
            }
         }
         if(_loc2_)
         {
            this.clientActivateQuest(_loc2_);
         }
      }
      
      public function questTreeNodeReset(param1:String, param2:String) : void
      {
         var _loc5_:Array = null;
         var _loc6_:ZGameQuest = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc3_:String = param2;
         var _loc4_:XML = ZGlobal.gameSettings.getQuestTree(param1);
         if((Boolean(_loc4_)) && Boolean(_loc4_.node))
         {
            _loc5_ = new Array();
            _loc5_.push(param2);
            _loc6_ = QuestSettingsInit.getInstance().getItemByName(param2) as ZGameQuest;
            if(_loc6_)
            {
               _loc8_ = _loc6_.sequels;
               for each(_loc9_ in _loc8_)
               {
                  _loc5_.push(_loc9_);
               }
            }
            for each(_loc7_ in _loc5_)
            {
               this.resetQuest(_loc7_);
            }
         }
         if(_loc3_)
         {
            this.clientActivateQuest(_loc3_);
         }
      }
      
      override protected function mergeProgress(param1:int, param2:Quest, param3:Object) : int
      {
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc4_:int = -1;
         if(param1 >= 0)
         {
            _loc5_ = false;
            _loc6_ = false;
            _loc7_ = 0;
            while(_loc7_ < param2.tasks.length)
            {
               if(this.isQuestTaskPurchased(param2.name,_loc7_))
               {
                  param3.progress[_loc7_] = param2.tasks[_loc7_].total;
               }
               else if(this.taskSupportsPrediction(param2.tasks[_loc7_].action))
               {
                  param3.progress[_loc7_] = m_activeQuests[param1].progress[_loc7_];
               }
               else
               {
                  _loc5_ = true;
               }
               if(m_activeQuests[param1].progress[_loc7_] != param3.progress[_loc7_])
               {
                  _loc6_ = true;
               }
               _loc7_++;
            }
            _loc4_ = checkTaskCompletion(m_activeQuests[param1].progress,param3.progress,param2);
            m_activeQuests[param1] = param3;
            if(_loc5_)
            {
               _loc8_ = {
                  "progressChange":_loc6_,
                  "taskCompleted":_loc4_
               };
               performClientProgressUpdate(param2,m_activeQuests[param1],_loc8_);
            }
         }
         return _loc4_;
      }
      
      override protected function callTaskPredictionHandler(param1:Transaction, param2:Quest, param3:int) : Number
      {
         var _loc5_:Object = null;
         var _loc6_:TBuyQuestTask = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Function = null;
         var _loc4_:Object = param2.tasks[param3];
         if(param1 is TBuyQuestTask)
         {
            _loc6_ = param1 as TBuyQuestTask;
            _loc5_ = getQuestProgressByName(param2.name);
            if(param3 == _loc6_.index && param2.name == _loc6_.name)
            {
               _loc7_ = int(_loc4_.total);
               this.setQuestTaskPurchased(param2.name,param3);
               if(_loc5_ != null)
               {
                  _loc8_ = int(_loc5_.progress[param3]);
                  if(_loc7_ > _loc8_)
                  {
                     if(_loc4_.sticky)
                     {
                        return _loc7_ - _loc8_;
                     }
                     return _loc7_;
                  }
               }
            }
            if(_loc4_.sticky)
            {
               return 0;
            }
            return _loc5_.progress[param3];
         }
         if(this.taskSupportsPrediction(_loc4_.action) && (!ZGameQuest(param2).hasLifeTime || !ZGameQuest(param2).isExpired()))
         {
            _loc9_ = QuestSettingsInit.getInstance().getClientPredictionClass[_loc4_.action];
            return _loc9_.apply(null,[param1,param2.tasks[param3],param2]);
         }
         if(!_loc4_.sticky)
         {
            _loc5_ = getQuestProgressByName(param2.name);
            if((Boolean(_loc5_)) && Boolean(_loc5_.progress) && _loc5_.progress.length > param3)
            {
               return _loc5_.progress[param3];
            }
         }
         return 0;
      }
      
      private function taskSupportsPrediction(param1:String) : Boolean
      {
         return QuestSettingsInit.getInstance().getClientPredictionClass.hasOwnProperty(param1);
      }
      
      private function setQuestTaskPurchased(param1:String, param2:int) : void
      {
         if(this.m_purchasedQuestTasks[param1] == null)
         {
            this.m_purchasedQuestTasks[param1] = 0;
         }
         this.m_purchasedQuestTasks[param1] |= 1 << param2;
      }
      
      private function isQuestTaskPurchased(param1:String, param2:int) : Boolean
      {
         if(this.m_purchasedQuestTasks[param1] != null)
         {
            if(this.m_purchasedQuestTasks[param1] & 1 << param2)
            {
               return true;
            }
         }
         return false;
      }
      
      private function handleInitUserCompletedQuests(param1:TransactionEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:ZGameQuest = null;
         Logger.print(this,"handling init user completed quests");
         var _loc2_:Object = param1.transaction.rawResult.metadata.QuestComponentInitUserCompletedQuests;
         if(_loc2_)
         {
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = _loc4_.name;
               _loc6_ = QuestSettingsInit.getInstance().getItemByName(_loc5_) as ZGameQuest;
               Logger.print(this,"quest " + _loc3_ + " " + _loc6_.name);
               this.m_quests[_loc5_] = _loc6_.createTasks();
               dispatchEvent(new QuestEvent(QuestEvent.COMPLETED,_loc6_));
               _loc3_++;
            }
         }
      }
      
      private function handleBatchCompletedQuests(param1:TransactionEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:Quest = null;
         var _loc2_:Object = param1.transaction.rawResult.metadata.QuestComponent;
         if(_loc2_)
         {
            _loc3_ = TransactionManager.getBatchSequenceNumber();
            while(_loc4_ < _loc2_.length)
            {
               _loc5_ = _loc2_[_loc4_];
               if(_loc5_.complete)
               {
                  _loc6_ = int(this.m_questStartBatchNumbers[_loc5_.name]);
                  if(_loc6_ == _loc3_)
                  {
                     _loc7_ = QuestSettingsInit.getInstance().getItemByName(_loc5_.name);
                     dispatchEvent(new QuestEvent(QuestEvent.COMPLETED,_loc7_));
                  }
               }
               _loc4_++;
            }
         }
      }
      
      private function storeNewQuests(param1:TransactionEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc2_:Object = param1.transaction.rawResult.metadata.QuestComponent;
         if(_loc2_)
         {
            _loc3_ = TransactionManager.getBatchSequenceNumber();
            while(_loc4_ < _loc2_.length)
            {
               _loc5_ = _loc2_[_loc4_];
               _loc6_ = getQuestProgressIndexByName(_loc5_.name);
               if(_loc6_ < 0)
               {
                  this.m_questStartBatchNumbers[_loc5_.name] = _loc3_;
               }
               _loc4_++;
            }
         }
      }
      
      private function setQuestStartTimesAndServerRewards(param1:TransactionEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:ZGameQuest = null;
         var _loc2_:Object = param1.transaction.rawResult.metadata.QuestComponent;
         if(_loc2_)
         {
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = _loc4_.name;
               _loc6_ = QuestSettingsInit.getInstance().getItemByName(_loc5_) as ZGameQuest;
               _loc6_.startTime = _loc4_.startTime;
               if(_loc4_.rewards != undefined)
               {
                  _loc6_.serverRewards = _loc4_.rewards;
               }
               if(_loc4_.startLevel != undefined)
               {
                  _loc6_.startLevel = _loc4_.startLevel;
                  _loc6_.recomputeTotals();
               }
               _loc3_++;
            }
         }
      }
      
      private function getQuestQueueIndex(param1:String) : int
      {
         var _loc2_:int = 0;
         if(this.m_questQueue)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_questQueue.length)
            {
               if(this.m_questQueue[_loc2_].name == param1)
               {
                  return _loc2_;
               }
               _loc2_++;
            }
         }
         return -1;
      }
      
      private function initDependenciesFromSettings() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc1_:XMLList = QuestSettingsInit.getInstance().rawXML.*;
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = _loc2_.@name;
            _loc4_ = _loc2_..sequel;
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = _loc5_.@name.toString();
               if(!this.m_prereqs[_loc6_])
               {
                  this.m_prereqs[_loc6_] = [];
               }
               this.m_prereqs[_loc6_].push(_loc3_);
            }
         }
      }
      
      public function allParentQuestsComplete(param1:String) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:Array = this.m_prereqs[param1] as Array;
         if(_loc3_)
         {
            _loc4_ = _loc2_.anyParentUnlocks;
            _loc5_ = 0;
            for each(_loc6_ in _loc3_)
            {
               if(ZGlobal.player.didCompleteQuest(_loc6_))
               {
                  _loc5_++;
                  if(_loc4_)
                  {
                     return true;
                  }
               }
               else if(!_loc4_)
               {
                  return false;
               }
            }
            return _loc5_ == _loc3_.length;
         }
         return true;
      }
   }
}

