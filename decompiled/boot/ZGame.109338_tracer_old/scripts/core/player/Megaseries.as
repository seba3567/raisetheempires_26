package core.player
{
   import ZQuest.Init.QuestSettingsInit;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.QuestCompletionState;
   import core.gameobjects.GameItem;
   import core.gameobjects.IItem;
   import core.managers.BuildManager;
   import core.managers.MegaseriesManager;
   import core.managers.WorldObjectManager;
   import core.managers.questManager.ZGameQuest;
   import core.ui.UIManager;
   import core.ui.menuitem.SettingsUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import entity.GameDataComponent;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class Megaseries
   {
      
      private var m_entryPoint:IItem;
      
      private var m_entryPt:IEntity;
      
      private var m_entryPtSM:BehaviorStateMachine;
      
      private var m_id:String;
      
      private var m_entryPointName:String;
      
      private var m_currentStage:Number = 1;
      
      private var m_completedStage:Number = 0;
      
      private var m_activeQuestId:String;
      
      private var m_activeQuestNumber:Number = -1;
      
      private var m_activeQuest:ZGameQuest;
      
      private var m_stateCompletionQuests:Array = new Array();
      
      private var m_numStage:Number = 0;
      
      private var m_entryPointpos:Pt = null;
      
      private var m_finalQuest:String;
      
      private var m_msRewardQuest:String;
      
      private var m_currTabIcons:Array = new Array();
      
      private var m_displayReward:String;
      
      private var m_msStageStageMachineMap:Object = {
         1:0,
         2:2,
         3:4
      };
      
      private var m_assetPopupFile:String = null;
      
      private var m_playAgainPopupSeen:Boolean;
      
      private var m_stateMachineName:String;
      
      private var m_playAgainAssetPopup:String;
      
      private var m_playAgainText:Array;
      
      private var m_stageReward:Array;
      
      private var m_questPopup:String;
      
      public var EXPERIMENT_MEGASERIES_MASTER:String;
      
      public var EXPERIMENT_MEGASERIES_MASTER_VARIANT:int;
      
      private var flag_activeQuestCounter:Boolean = true;
      
      private var m_eventDispatcher:BehaviorStateMachine;
      
      public function Megaseries(param1:XML, param2:String)
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         super();
         this.m_id = param1.@id;
         var _loc3_:Boolean = true;
         if(MegaseriesManager.instance.didCompleteQuest(param2))
         {
            _loc3_ = false;
         }
         for each(_loc4_ in param1.stage)
         {
            for each(_loc5_ in _loc4_.node)
            {
               if(_loc5_.@type == "msreward")
               {
                  this.m_msRewardQuest = _loc5_.@quest.toString();
               }
               else
               {
                  MegaseriesManager.instance.setMSQuest(_loc5_.@quest.toString(),this.m_id);
                  if(this.flag_activeQuestCounter)
                  {
                     ++this.m_activeQuestNumber;
                  }
                  if(_loc3_)
                  {
                     if(!MegaseriesManager.instance.didCompleteQuest(_loc5_.@quest.toString()))
                     {
                        _loc3_ = false;
                        param2 = _loc5_.@quest.toString();
                     }
                  }
                  if(_loc5_.@quest == param2)
                  {
                     this.m_currentStage = this.m_numStage + 1;
                     this.m_completedStage = this.m_numStage;
                     this.flag_activeQuestCounter = false;
                  }
                  if(_loc5_.@end != undefined && _loc5_.@end != "" && _loc5_.@end != "ms")
                  {
                     this.m_stateCompletionQuests.push(_loc5_.@quest.toString());
                  }
                  this.m_currTabIcons.push(_loc5_.@icon.toString());
               }
            }
            if(this.flag_activeQuestCounter)
            {
               this.m_activeQuestNumber = -1;
            }
            ++this.m_numStage;
         }
         this.m_numStage = param1.@stageCount;
         this.m_assetPopupFile = param1.@assetPopupFile;
         this.m_displayReward = param1.@displayReward.toString();
         this.m_entryPointName = param1.@entryPoint.toString();
         this.m_finalQuest = _loc5_.@quest.toString();
         this.EXPERIMENT_MEGASERIES_MASTER = param1.requiredExperiment.@name.toString();
         this.EXPERIMENT_MEGASERIES_MASTER_VARIANT = int(param1.requiredExperiment.@variants.toString());
         this.m_playAgainPopupSeen = true;
         this.m_stateMachineName = this.getStateMachineName(param1.@entryPoint.toString());
         if(param1.@playAgainAssetPopup.toString())
         {
            this.m_playAgainAssetPopup = param1.@playAgainAssetPopup;
         }
         this.m_playAgainText = this.getMegaseriesPlayAgainText(param1.@entryPoint.toString());
         this.m_activeQuestId = param2;
         this.m_activeQuest = QuestSettingsInit.getInstance().getItemByName(this.m_activeQuestId) as ZGameQuest;
         if(Boolean(param1.@stageReward1.toString()) && Boolean(param1.@stageReward2.toString()))
         {
            this.m_stageReward = new Array();
            this.m_stageReward.push(param1.@stageReward1.toString());
            this.m_stageReward.push(param1.@stageReward2.toString());
         }
      }
      
      private function getFSMStateValue(param1:Number) : Number
      {
         if(this.m_msStageStageMachineMap[param1] != undefined)
         {
            return this.m_msStageStageMachineMap[param1];
         }
         return -1;
      }
      
      public function get displayReward() : String
      {
         return this.m_displayReward;
      }
      
      public function get tabIcons() : Array
      {
         return this.m_currTabIcons;
      }
      
      public function get currentStage() : Number
      {
         return this.m_currentStage;
      }
      
      public function get playAgainPopupSeen() : Boolean
      {
         return this.m_playAgainPopupSeen;
      }
      
      public function get stateMachineName() : String
      {
         return this.m_stateMachineName;
      }
      
      public function get playAgainText() : Array
      {
         return this.m_playAgainText;
      }
      
      public function get stageReward() : Array
      {
         return this.m_stageReward;
      }
      
      public function setBuildableEntity(param1:IEntity) : void
      {
         this.m_entryPt = param1;
         BuildManager.instance.alwaysGetObject(param1);
      }
      
      public function removeBuildableAccess() : void
      {
         BuildManager.instance.removeAlwaysGetObject(this.m_entryPt);
      }
      
      public function isMegaseriesQuestCompleted() : Boolean
      {
         return this.m_finalQuest == this.m_activeQuestId;
      }
      
      public function currentStageProgress() : Object
      {
         return {
            "completed":this.m_activeQuestNumber,
            "total":3
         };
      }
      
      public function set entryPointStateMachine(param1:BehaviorStateMachine) : void
      {
         this.m_entryPtSM = param1;
      }
      
      public function get progress() : Object
      {
         return {
            "completed":this.m_completedStage,
            "total":this.m_numStage
         };
      }
      
      public function isStageCompletionQuest(param1:String) : Number
      {
         var _loc3_:String = null;
         var _loc2_:Number = 1;
         for each(_loc3_ in this.m_stateCompletionQuests)
         {
            if(param1 == _loc3_)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function getStageCompletionQuest(param1:Number) : String
      {
         return this.m_stateCompletionQuests[param1 - 1];
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function getActiveQuest() : String
      {
         return this.m_activeQuestId;
      }
      
      public function setActiveQuest(param1:String) : void
      {
         this.m_activeQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         this.m_activeQuestId = param1;
         this.m_activeQuestNumber = 0;
         this.flag_activeQuestCounter = false;
         this.m_currentStage = 1;
         this.m_playAgainPopupSeen = true;
         this.m_completedStage = 0;
      }
      
      public function setPopupSeenFlag() : void
      {
         this.m_playAgainPopupSeen = false;
      }
      
      public function get msRewardQuest() : String
      {
         return this.m_msRewardQuest;
      }
      
      public function get msAssetPopup() : String
      {
         return this.m_assetPopupFile;
      }
      
      public function get msplayAgainAssetPopup() : String
      {
         return this.m_playAgainAssetPopup;
      }
      
      public function get questPopup() : String
      {
         return this.m_questPopup;
      }
      
      public function get activeQuestNumber() : Number
      {
         return this.m_activeQuestNumber;
      }
      
      public function doProgress() : void
      {
         var _loc1_:Array = this.m_activeQuest.sequels;
         if(this.isStageCompletionQuest(this.m_activeQuestId))
         {
            ++this.m_completedStage;
            ++this.m_currentStage;
            this.m_activeQuestNumber = 0;
            this.flag_activeQuestCounter = true;
            if(this.isMegaseriesQuestCompleted())
            {
               this.removeBuildableAccess();
            }
            this.onPanToItem(this.m_entryPointName);
         }
         else
         {
            ++this.m_activeQuestNumber;
         }
         if(_loc1_.length > 0)
         {
            this.m_activeQuest = QuestSettingsInit.getInstance().getItemByName(_loc1_[0]) as ZGameQuest;
            this.m_activeQuestId = this.m_activeQuest.name;
         }
      }
      
      private function onPanToItem(param1:String) : void
      {
         Zlab.processManager.schedule(3000,this,this.onPanToItemDelay,{"itemCode":param1});
      }
      
      private function onPanToItemDelay(param1:Object) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:GameDataComponent = null;
         var _loc7_:BuildingSpatialComponent = null;
         var _loc2_:CineCameraComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
         if(this.m_entryPointpos)
         {
            _loc2_.moveTo(this.m_entryPointpos);
         }
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode(param1.itemCode,GameItem) as GameItem;
         if(_loc3_)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType(_loc3_.type,_loc3_.subType);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc6_)) && _loc6_.gameData.code == param1.itemCode)
               {
                  _loc7_ = BuildingSpatialComponent(_loc5_.lookupComponentByType(BuildingSpatialComponent));
                  if(_loc7_)
                  {
                     this.m_entryPointpos = new Pt(_loc7_.position.x,_loc7_.position.y);
                     this.m_entryPointpos = MathUtils.worldToTile(this.m_entryPointpos,ZGlobal.cellSize);
                     _loc2_.moveTo(this.m_entryPointpos);
                     Zlab.processManager.schedule(1000,this,this.zoomToEntryPoint);
                     break;
                  }
               }
            }
         }
      }
      
      public function checkStageInSyncWithStateMachine(param1:String) : Boolean
      {
         if(Number(param1) >= this.getFSMStateValue(this.currentStage))
         {
            return true;
         }
         return false;
      }
      
      private function zoomToEntryPoint() : void
      {
         var _loc1_:SettingsUIItem = UIManager.instance.getMenuItemByName(SettingsUIItem.ITEM_ID) as SettingsUIItem;
         _loc1_.zoomInToIndex(1);
      }
      
      public function registerEntryPointEventDispatcher(param1:BehaviorStateMachine) : void
      {
         this.m_eventDispatcher = param1;
      }
      
      public function notifyStageCompletion(param1:Object) : void
      {
         this.m_eventDispatcher.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(QuestCompletionState.QUEST_COMPLETE,param1));
      }
      
      private function getStateMachineName(param1:String) : String
      {
         var _loc2_:XML = ZGlobal.gameSettings.getItemXMLByCode(param1);
         return _loc2_.stateMachineValues.@stateMachineName.toString();
      }
      
      public function getMegaseriesPlayAgainText(param1:String) : Array
      {
         var _loc2_:XML = ZGlobal.gameSettings.getItemXMLByCode(param1);
         var _loc3_:Array = new Array();
         if(Boolean(_loc2_.dialog.@paTitle.toString()) && Boolean(_loc2_.dialog.@paDesc.toString()) && Boolean(_loc2_.dialog.@paButton.toString()))
         {
            _loc3_.push(_loc2_.dialog.@paTitle.toString());
            _loc3_.push(_loc2_.dialog.@paDesc.toString());
            _loc3_.push(_loc2_.dialog.@paButton.toString());
         }
         return _loc3_;
      }
   }
}

