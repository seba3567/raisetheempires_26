package core.player.questTrees
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.island.GMIsland;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.UIManager;
   import core.ui.menuitem.QuestsUIItem;
   import dispatchers.UIDispatcher;
   import displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward;
   import displays.popups.miniSeriesFinalReward.MysteryCrateFinalReward;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import transactions.TQuestTreeReset;
   import transactions.TQuestTreeSetMode;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class PlayerQuestTrees
   {
      
      public static var FINAL_REWARD_PLACE:String = "finalRewardPlace";
      
      public static var FINAL_REWARD_CLOSE:String = "finalRewardClose";
      
      private static var m_endQuests:Array = new Array();
      
      private static var m_questTreeNames:Dictionary = new Dictionary();
      
      private static var m_questRewardQueue:Array = new Array();
      
      private static var dialogTypes:Array = [MysteryCrateFinalReward,MiniSeriesFinalReward];
      
      private var m_trees:Dictionary = null;
      
      private var m_unlockedTrees:Dictionary = null;
      
      private var m_questTreeData:Dictionary = null;
      
      public var m_isQuestTreeDialogActive:Boolean = false;
      
      public function PlayerQuestTrees(param1:Object)
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         super();
         this.m_trees = new Dictionary();
         this.m_unlockedTrees = new Dictionary();
         this.m_questTreeData = new Dictionary();
         for(_loc2_ in param1.questTrees)
         {
            this.m_trees[_loc2_] = new QuestTree(_loc2_,param1);
         }
         for(_loc2_ in param1.questTreeUnlocks)
         {
            if(!this.m_unlockedTrees[_loc2_])
            {
               this.m_unlockedTrees[_loc2_] = new Array();
            }
            for each(_loc3_ in param1.questTreeUnlocks[_loc2_])
            {
               this.m_unlockedTrees[_loc2_].push(_loc3_);
            }
         }
         for(_loc2_ in param1.questTreeData)
         {
            this.m_questTreeData[_loc2_] = param1.questTreeData[_loc2_];
         }
      }
      
      public static function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@id.toString();
            for each(_loc4_ in _loc2_.node)
            {
               _loc5_ = _loc4_.@quest.toString();
               _loc6_ = _loc4_.@end == "true";
               if(_loc6_)
               {
                  m_endQuests.push(_loc5_);
               }
               m_questTreeNames[_loc5_] = _loc3_;
            }
         }
      }
      
      public static function triggerDialog(param1:String) : void
      {
         if(isOnHomeIslandWorld())
         {
            PlayerQuestTrees.showDialog(param1);
         }
         else
         {
            PlayerQuestTrees.addToQuestRewardQueue(param1);
            UIDispatcher.instance.addEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,onIslandModeActive,false,0,true);
         }
      }
      
      private static function isOnHomeIslandWorld() : Boolean
      {
         if(!ZGlobal.isHome())
         {
            return false;
         }
         var _loc1_:GameMode = GameModeManager.instance.getTopGameMode();
         if(!_loc1_ || !(_loc1_ is GMIsland))
         {
            return false;
         }
         return true;
      }
      
      public static function addToQuestRewardQueue(param1:String) : void
      {
         m_questRewardQueue.push(param1);
      }
      
      private static function onIslandModeActive(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         if(isOnHomeIslandWorld())
         {
            UIDispatcher.instance.removeEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,onIslandModeActive);
            for each(_loc2_ in m_questRewardQueue)
            {
               PlayerQuestTrees.showDialog(_loc2_);
            }
            m_questRewardQueue = new Array();
         }
      }
      
      private static function showDialog(param1:String) : void
      {
         var _loc2_:Class = null;
         var _loc3_:ZGamePopUp = null;
         var _loc4_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param1);
         var _loc5_:QuestTree = ZGlobal.player.questTrees.getQuestTree(_loc4_);
         if(_loc5_.xml.ui.finalReward.@popupDecider == undefined)
         {
            if(_loc5_.xml.ui.finalReward.@className != undefined)
            {
               _loc2_ = getDefinitionByName("displays.popups.miniSeriesFinalReward." + _loc5_.xml.ui.finalReward.@className) as Class;
               _loc3_ = new _loc2_(param1);
            }
            else
            {
               _loc3_ = new MiniSeriesFinalReward(param1);
            }
         }
         else
         {
            _loc3_ = ZGameUtils.callFunctionFromXml(_loc5_.xml.ui.finalReward.@popupDecider,[param1]);
         }
         PopupManager.instance.push(_loc3_,1000);
      }
      
      public static function checkFinalReward(param1:String) : void
      {
         var _loc2_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param1);
         var _loc3_:QuestTree = ZGlobal.player.questTrees.getQuestTree(_loc2_);
         if(_loc3_.hasEndTask())
         {
            if(ZGlobal.player.questTrees.isEndQuest(param1))
            {
               PlayerQuestTrees.triggerDialog(param1);
            }
         }
      }
      
      public static function resetBranchesForCompletedQuest(param1:String) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param1);
         var _loc3_:QuestTree = ZGlobal.player.questTrees.getQuestTree(_loc2_);
         if(Boolean(_loc3_) && _loc3_.shouldAutoReset())
         {
            _loc4_ = isMiniseriesEnd(param1);
            if(_loc4_)
            {
               clearCurrentBranch(param1);
            }
         }
      }
      
      private static function clearCurrentBranch(param1:String) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:QuestTree = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:Boolean = false;
         var _loc11_:ZGameQuest = null;
         var _loc12_:Array = null;
         var _loc13_:String = null;
         var _loc14_:Array = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         getPrereqTree(param1,_loc2_,_loc3_);
         var _loc4_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         for each(_loc5_ in _loc3_)
         {
            _loc9_ = null;
            _loc10_ = true;
            _loc11_ = QuestSettingsInit.getInstance().getItemByName(_loc5_) as ZGameQuest;
            _loc12_ = _loc11_.sequels;
            for each(_loc13_ in _loc12_)
            {
               _loc14_ = new Array();
               getSequelTree(_loc13_,_loc14_);
               if(_loc14_.indexOf(param1) >= 0)
               {
                  _loc9_ = _loc13_;
               }
            }
            if(_loc9_ != null)
            {
               clearTree(_loc9_,param1);
            }
         }
         _loc6_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param1);
         _loc7_ = ZGlobal.player.questTrees.getQuestTree(_loc6_);
         _loc8_ = _loc7_.firstQuest;
         if(_loc8_)
         {
            _loc4_.clientActivateQuest(_loc8_);
         }
         _loc7_.reset();
      }
      
      private static function clearCurrentBranchSiblings(param1:String) : void
      {
         var _loc3_:ZGameQuest = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc2_:String = getBranchQuest(param1);
         if(_loc2_)
         {
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(_loc2_) as ZGameQuest;
            _loc4_ = _loc3_.sequels;
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = new Array();
               getSequelTree(_loc5_,_loc6_);
               if(_loc6_.indexOf(param1) < 0)
               {
                  clearTree(_loc5_,param1);
               }
            }
         }
      }
      
      public static function clearTree(param1:String, param2:String) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:QuestTree = null;
         var _loc9_:QuestsUIItem = null;
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         getSequelTree(param1,_loc4_);
         for each(_loc5_ in _loc4_)
         {
            _loc3_.push(_loc5_);
         }
         if(_loc3_.length > 0)
         {
            for each(_loc6_ in _loc3_)
            {
               _loc9_ = UIManager.instance.getMenuItemByName(QuestsUIItem.ITEM_ID) as QuestsUIItem;
               if(ZGameQuestManager.instance.isQuestActive(_loc6_,false))
               {
                  _loc9_.removeActiveQuestIcon(_loc6_);
               }
               ZGameQuestManager.instance.resetQuest(_loc6_);
            }
            _loc7_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param2);
            _loc8_ = ZGlobal.player.questTrees.getQuestTree(_loc7_);
            _loc8_.resetQuests(_loc3_);
         }
      }
      
      private static function getBranchQuest(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc4_:ZGameQuest = null;
         var _loc5_:Array = null;
         var _loc2_:Array = ZGameQuestManager.instance.getPrequisitesForQuest(param1);
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = QuestSettingsInit.getInstance().getItemByName(_loc3_) as ZGameQuest;
            if(_loc4_)
            {
               _loc5_ = _loc4_.sequels;
               if((Boolean(_loc5_)) && _loc5_.length > 1)
               {
                  return _loc3_;
               }
               return getBranchQuest(_loc3_);
            }
         }
         return null;
      }
      
      public static function isBranchEnd(param1:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:Array = _loc2_.sequels;
         if(_loc3_)
         {
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = ZGameQuestManager.instance.getPrequisitesForQuest(_loc4_);
               if((Boolean(_loc5_)) && _loc5_.length > 1)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private static function isMiniseriesEnd(param1:String) : Boolean
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:Array = _loc2_.sequels;
         if(!_loc3_ || _loc3_.length == 0)
         {
            return true;
         }
         return false;
      }
      
      private static function isMiniseriesStart(param1:String) : Boolean
      {
         var _loc2_:Array = ZGameQuestManager.instance.getPrequisitesForQuest(param1);
         if(!_loc2_ || _loc2_.length == 0)
         {
            return true;
         }
         return false;
      }
      
      private static function getSequelTree(param1:String, param2:Array, param3:Array = null) : void
      {
         var _loc4_:ZGameQuest = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         if(param2)
         {
            if(isMiniseriesEnd(param1))
            {
               if(param2.indexOf(param1) < 0)
               {
                  param2.push(param1);
               }
               if(Boolean(param3) && param3.indexOf(param1) < 0)
               {
                  param3.push(param1);
               }
               return;
            }
            _loc4_ = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
            _loc5_ = _loc4_.sequels;
            for each(_loc6_ in _loc5_)
            {
               getSequelTree(_loc6_,param2,param3);
            }
            if(param2.indexOf(param1) < 0)
            {
               param2.push(param1);
            }
         }
      }
      
      private static function getPrereqTree(param1:String, param2:Array, param3:Array = null) : void
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(param2)
         {
            if(isMiniseriesStart(param1))
            {
               if(param2.indexOf(param1) < 0)
               {
                  param2.push(param1);
               }
               if(Boolean(param3) && param3.indexOf(param1) < 0)
               {
                  param3.push(param1);
               }
               return;
            }
            _loc4_ = ZGameQuestManager.instance.getPrequisitesForQuest(param1);
            for each(_loc5_ in _loc4_)
            {
               getPrereqTree(_loc5_,param2,param3);
            }
            if(param2.indexOf(param1) < 0)
            {
               param2.push(param1);
            }
         }
      }
      
      public function getQuestTree(param1:String) : QuestTree
      {
         return this.m_trees[param1];
      }
      
      public function getQuestTreeDataForQuestTree(param1:String) : Object
      {
         return this.m_questTreeData[param1];
      }
      
      public function loadWorldObjects() : void
      {
         var _loc1_:QuestTree = null;
         for each(_loc1_ in this.m_trees)
         {
            _loc1_.loadWorldObjects();
         }
      }
      
      public function getFirstActiveQuest(param1:String) : String
      {
         var _loc2_:String = this.getQuestTreeNameForQuest(param1);
         var _loc3_:QuestTree = this.getQuestTree(_loc2_);
         if(_loc3_)
         {
            return _loc3_.getFirstActiveQuest();
         }
         return null;
      }
      
      public function isUnlocked(param1:String, param2:String) : Boolean
      {
         var _loc3_:int = 0;
         if(this.m_unlockedTrees[param1])
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_unlockedTrees[param1].length)
            {
               if(this.m_unlockedTrees[param1][_loc3_] == param2)
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      public function anyActive(param1:Array) : Boolean
      {
         var _loc2_:String = null;
         for each(_loc2_ in param1)
         {
            if(this.m_trees[_loc2_])
            {
               return true;
            }
         }
         return false;
      }
      
      public function isQuestTreeQuest(param1:String) : Boolean
      {
         return this.getQuestTreeNameForQuest(param1) != null;
      }
      
      public function getQuestTreeNameForQuest(param1:String) : String
      {
         if(m_questTreeNames[param1])
         {
            return m_questTreeNames[param1];
         }
         return null;
      }
      
      public function isEndQuest(param1:String) : Boolean
      {
         var _loc2_:int = m_endQuests.indexOf(param1);
         return _loc2_ >= 0;
      }
      
      public function startQuest(param1:String) : void
      {
         var _loc2_:String = this.getQuestTreeNameForQuest(param1);
         if(Boolean(this.m_trees) && Boolean(this.m_trees[_loc2_]))
         {
            this.m_trees[_loc2_].startQuest(param1);
         }
      }
      
      public function unlockQuest(param1:String) : void
      {
         var _loc2_:String = this.getQuestTreeNameForQuest(param1);
         if(Boolean(this.m_trees) && Boolean(this.m_trees[_loc2_]))
         {
            this.m_trees[_loc2_].unlockQuest(param1);
            if(!this.m_unlockedTrees[_loc2_])
            {
               this.m_unlockedTrees[_loc2_] = new Array();
            }
            this.m_unlockedTrees[_loc2_].push(param1);
         }
      }
      
      public function validForRestarting(param1:String) : Boolean
      {
         var _loc2_:String = this.getQuestTreeNameForQuest(param1);
         return Boolean(this.m_trees) && Boolean(this.m_trees[_loc2_]) && Boolean(this.m_trees[_loc2_].validForRestarting());
      }
      
      public function resetQuestTree(param1:String) : void
      {
         var _loc2_:TQuestTreeReset = new TQuestTreeReset(param1);
         TransactionManager.addTransaction(_loc2_);
         this.m_trees[param1].reset();
         ZGameQuestManager.instance.questTreeReset(param1);
      }
      
      public function setMsDifficultyMode(param1:String, param2:String) : void
      {
         if(this.m_questTreeData[param1])
         {
            this.m_questTreeData[param1]["difficultyMode"] = param2;
         }
         ZGameQuestManager.instance.questTreeReset(param1);
         var _loc3_:TQuestTreeSetMode = new TQuestTreeSetMode(param1,param2);
         TransactionManager.addTransaction(_loc3_);
      }
      
      public function resetDifficultyMode(param1:String) : void
      {
         if(this.m_questTreeData[param1]["difficultyMode"])
         {
            delete this.m_questTreeData[param1]["difficultyMode"];
         }
      }
      
      public function resetUnlockedNodes(param1:String) : void
      {
         if(!this.m_trees[param1].unlockAllNodesAtStart)
         {
            this.m_unlockedTrees[param1] = new Array();
         }
      }
      
      public function resetQuestTreeNode(param1:String, param2:String) : void
      {
         var _loc3_:TQuestTreeReset = new TQuestTreeReset(param1,param2);
         TransactionManager.addTransaction(_loc3_);
         this.m_trees[param1].resetNode(param2);
         ZGameQuestManager.instance.questTreeNodeReset(param1,param2);
      }
      
      public function getTreeIconURL(param1:String) : String
      {
         if(this.m_trees[param1])
         {
            return this.m_trees[param1].iconURL;
         }
         return "";
      }
      
      public function getQuestTreeRemainingTime(param1:String) : int
      {
         if(this.m_trees[param1])
         {
            return this.m_trees[param1].remainingTime;
         }
         return 0;
      }
      
      public function get isQuestTreeDialogActive() : Boolean
      {
         return this.m_isQuestTreeDialogActive;
      }
      
      public function setquestTreeDialogActive(param1:Boolean) : void
      {
         this.m_isQuestTreeDialogActive = param1;
      }
   }
}

