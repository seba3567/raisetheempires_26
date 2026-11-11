package core.managers
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.behaviors.states.CrewDialogState;
   import core.entities.components.utils.YieldHelper;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.actionfeedback.CrewActionFeedback;
   import core.ui.feedbacktext.ExperienceFeedbackText;
   import core.ui.feedbacktext.ResourceFeedbackText;
   import core.ui.feedbacktext.SocialExperienceBadFeedbackText;
   import core.ui.feedbacktext.SocialExperienceGoodFeedbackText;
   import displays.popups.genericPopup.GenericPopup1B;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import init.ActionQueue;
   import transactions.TCrewNeighborPoll;
   import transactions.TStaffPosition;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class CrewManager extends EventDispatcher
   {
      
      public static const CREW_TEND_UPDATED:String = "crewtendupdated";
      
      public static const PURCHASED_CREW_SLOT_FULL:String = "purchasedCrewSlotFull";
      
      public static const CREW_NEIGHBORS_JOINED:String = "crewNeighborsJoined";
      
      public static const CREW_NEIGHBORS_REMOVED:String = "crewNeighborsRemoved";
      
      public static const CREW_NEIGHBORS_UPDATED:String = "crewNeighborsUpdated";
      
      public static const CREW_REPLACED:String = "crewReplaced";
      
      public static const CREW_UPDATED:String = "crewUpdated";
      
      public static const EXPERIMENT_CREW_SLOTS:String = "empire_crew_slots";
      
      private static const CREW_NEIGHBOR_UPDATE_RATE:int = 5000;
      
      public static var instance:CrewManager = new CrewManager();
      
      private static var EXPERIMENT_NO_SLOT_PURCHASE_VARIANT:int = 2;
      
      private var m_crewNeighborInfo:Dictionary = new Dictionary();
      
      private var m_numDirtyCrewNeighbors:int;
      
      public function CrewManager()
      {
         super();
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete);
         addEventListener(PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull,false,0,true);
         addEventListener(CREW_NEIGHBORS_JOINED,this.onCrewNeighborsJoined,false,0,true);
         addEventListener(CREW_NEIGHBORS_REMOVED,this.onCrewNeighborsRemoved,false,0,true);
         ActionQueue.instance.addEventListener(Event.COMPLETE,this.startCrewNeighborsPoll,false,0,true);
      }
      
      private static function getCrewTendTemplateXML(param1:String) : XML
      {
         var _loc2_:XMLList = ZGlobal.gameSettings.getXML().CrewTendTemplates.CrewTendTemplate;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length())
         {
            if(_loc2_[_loc3_].@name == param1)
            {
               return _loc2_[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      private static function getCrewOwnerTendRewardLabel(param1:String, param2:int) : Object
      {
         var _loc5_:XMLList = null;
         var _loc6_:uint = 0;
         var _loc7_:int = 0;
         var _loc8_:XML = null;
         var _loc3_:XML = getCrewTendTemplateXML(param1);
         var _loc4_:int = -1;
         if(_loc3_)
         {
            _loc5_ = _loc3_.OwnerReward;
            if(_loc5_)
            {
               _loc6_ = uint(_loc5_.length());
               _loc7_ = 0;
               while(_loc7_ < _loc5_.length())
               {
                  _loc8_ = _loc5_[_loc7_];
                  if(param2 >= _loc8_.@minTends)
                  {
                     return {
                        "currentTemplate":_loc8_.@rewardTemplate,
                        "currMinTends":uint(_loc8_.@minTends),
                        "nextMinTends":_loc4_,
                        "tendLevel":_loc6_
                     };
                  }
                  _loc4_ = int(_loc8_.@minTends);
                  _loc6_--;
                  _loc7_++;
               }
            }
         }
         return {
            "nextMinTends":_loc4_,
            "currMinTends":0,
            "tendLevel":1
         };
      }
      
      private static function getCrewRewardLabelByTendRank(param1:String, param2:int) : String
      {
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         param2++;
         var _loc3_:XML = getCrewTendTemplateXML(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_.VisitorReward;
            if(_loc4_)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.length())
               {
                  _loc6_ = _loc4_[_loc5_];
                  if(_loc6_.@rank == param2)
                  {
                     return _loc6_.@rewardTemplate;
                  }
                  _loc5_++;
               }
            }
         }
         return null;
      }
      
      public static function getCrewRewardLabel(param1:IEntity) : String
      {
         var _loc3_:GameItem = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(_loc2_)
         {
            _loc3_ = _loc2_.gameData;
            _loc4_ = _loc3_.crewTendTemplate;
            if(_loc4_)
            {
               _loc5_ = getPlayerCrewIndex(param1,ZGlobal.player.uid,_loc2_);
               return getCrewRewardLabelByTendRank(_loc4_,_loc5_);
            }
         }
         return null;
      }
      
      public static function getCrewInfo(param1:IEntity, param2:GameDataComponent = null, param3:Boolean = false) : Object
      {
         if(!param2 && Boolean(param1))
         {
            param2 = GameDataComponent.getGameDataComponent(param1);
         }
         if(Boolean(param2) && Boolean(param2.userData))
         {
            if(!param2.userData.crewInfo && param3)
            {
               param2.userData.crewInfo = new Array();
               param2.userData.crewTendInfo = new Array();
            }
            return {
               "crew":param2.userData.crewInfo,
               "tends":param2.userData.crewTendInfo,
               "replaceCount":param2.userData.crewReplaceCount
            };
         }
         return null;
      }
      
      public static function getOldCrewInfo(param1:IEntity) : Object
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.userData) && Boolean(_loc2_.userData.oldCrewInfo))
         {
            return _loc2_.userData.oldCrewInfo;
         }
         return null;
      }
      
      public static function setCrewInfo(param1:IEntity, param2:Array) : void
      {
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(Boolean(_loc3_) && Boolean(_loc3_.userData) && !_loc3_.userData.crewInfo)
         {
            _loc3_.userData.crewInfo = param2;
         }
      }
      
      public static function restoreOldCrewInfo(param1:IEntity) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.userData) && Boolean(_loc2_.userData.oldCrewInfo))
         {
            _loc2_.userData.crewInfo = _loc2_.userData.oldCrewInfo;
            _loc2_.userData.oldCrewInfo = null;
         }
      }
      
      public static function clearCrewInfo(param1:IEntity) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.userData))
         {
            _loc2_.userData.crewInfo = null;
         }
      }
      
      public static function setCrewInfoReplace(param1:IEntity, param2:String) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         var _loc8_:int = -1;
         if(Boolean(_loc3_) && Boolean(_loc3_.userData) && Boolean(_loc3_.userData.crewInfo))
         {
            _loc4_ = _loc3_.userData.crewInfo;
            _loc6_ = int(_loc4_.length);
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               _loc7_ = _loc4_[_loc5_];
               if(_loc7_ == param2)
               {
                  _loc8_ = _loc5_;
                  break;
               }
               _loc5_++;
            }
            if(_loc8_ != -1)
            {
               _loc4_.splice(_loc8_,1);
               _loc4_.push(param2);
               if(!_loc3_.userData.crewReplaceCount || _loc8_ < _loc6_ - _loc3_.userData.crewReplaceCount)
               {
                  _loc3_.userData.crewReplaceCount = _loc3_.userData.crewReplaceCount != null ? _loc3_.userData.crewReplaceCount + 1 : 1;
               }
            }
         }
      }
      
      public static function getPlayerCrewIndex(param1:IEntity, param2:String, param3:GameDataComponent = null) : int
      {
         var _loc5_:int = 0;
         if(!param3 && Boolean(param1))
         {
            param3 = GameDataComponent.getGameDataComponent(param1);
         }
         var _loc4_:Object = getCrewInfo(param1,param3);
         if((Boolean(_loc4_)) && Boolean(_loc4_.crew))
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.crew.length)
            {
               if(String(_loc4_.crew[_loc5_]) == param2)
               {
                  return _loc5_;
               }
               _loc5_++;
            }
         }
         return -1;
      }
      
      private static function countTends(param1:Array) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc3_ in param1)
         {
            _loc2_ += _loc3_;
         }
         return _loc2_;
      }
      
      public static function canSlotBeBought(param1:IEntity, param2:uint, param3:CrewTemplateWrapper) : Boolean
      {
         if(!gateByUnbuyableSlots())
         {
            return true;
         }
         var _loc4_:uint = Math.min(param3.numUnbuyableSlots,param3.numPositions);
         var _loc5_:uint = param3.numPositions - _loc4_;
         if(param2 < _loc5_)
         {
            return true;
         }
         return false;
      }
      
      public static function isPlayerInCrew(param1:IEntity, param2:String, param3:GameDataComponent = null) : Boolean
      {
         var _loc4_:int = getPlayerCrewIndex(param1,param2,param3);
         return _loc4_ >= 0;
      }
      
      public static function getPlayerIDByCrewIndex(param1:IEntity, param2:int, param3:GameDataComponent = null) : Object
      {
         if(!param3 && Boolean(param1))
         {
            param3 = GameDataComponent.getGameDataComponent(param1);
         }
         var _loc4_:Object = getCrewInfo(param1,param3);
         if(Boolean((_loc4_) && _loc4_.crew) && Boolean(_loc4_.crew.length > param2) && _loc4_.crew[param2] != null)
         {
            return {
               "success":true,
               "id":_loc4_.crew[param2]
            };
         }
         return {"success":false};
      }
      
      public static function getNumPlayerTendsByCrewIndex(param1:IEntity, param2:int) : int
      {
         var _loc3_:Object = getCrewInfo(param1);
         if(Boolean(_loc3_) && Boolean(_loc3_.tends) && _loc3_.tends.length >= param2)
         {
            return _loc3_.tends[param2];
         }
         return 0;
      }
      
      public static function getCrewTemplateName(param1:IEntity, param2:GameDataComponent = null) : String
      {
         var _loc3_:String = null;
         if(!param2 && Boolean(param1))
         {
            param2 = GameDataComponent.getGameDataComponent(param1);
         }
         if(Boolean(param2) && Boolean(param2.gameData))
         {
            _loc3_ = param2.gameData.getCrewTemplateName();
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public static function hasCrewTendTemplate(param1:IEntity) : Boolean
      {
         var _loc3_:GameItem = null;
         var _loc4_:String = null;
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(_loc2_)
         {
            _loc3_ = _loc2_.gameData;
            _loc4_ = _loc3_.crewTendTemplate;
            if(_loc4_)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function isCrewBuilding(param1:IEntity, param2:GameDataComponent = null) : Boolean
      {
         if(!param2 && Boolean(param1))
         {
            param2 = GameDataComponent.getGameDataComponent(param1);
         }
         if(getCrewTemplateName(param1,param2))
         {
            return true;
         }
         return false;
      }
      
      public static function isCrewFull(param1:Array, param2:CrewTemplateWrapper) : Boolean
      {
         var _loc3_:String = null;
         if(!param1)
         {
            return false;
         }
         if(param1.length < param2.numPositions)
         {
            return false;
         }
         for each(_loc3_ in param1)
         {
            if(_loc3_ == null)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function isCrewBuildingFull(param1:IEntity, param2:Array = null, param3:GameDataComponent = null) : Boolean
      {
         var _loc6_:Object = null;
         if(!param3 && Boolean(param1))
         {
            param3 = GameDataComponent.getGameDataComponent(param1);
         }
         var _loc4_:String = getCrewTemplateName(param1,param3);
         if(!_loc4_)
         {
            return false;
         }
         var _loc5_:CrewTemplateWrapper = ZGlobal.gameSettings.getCrewTemplateWrapper(_loc4_);
         if(!_loc5_)
         {
            return false;
         }
         if(!param2)
         {
            _loc6_ = getCrewInfo(param1,param3);
            if((Boolean(_loc6_)) && Boolean(_loc6_.crew))
            {
               param2 = _loc6_.crew;
            }
         }
         if(!param2 || !isCrewFull(param2,_loc5_))
         {
            return false;
         }
         return true;
      }
      
      public static function canPlayerJoinCrew(param1:IEntity, param2:String, param3:GameDataComponent = null) : Boolean
      {
         if(!param3 && Boolean(param1))
         {
            param3 = GameDataComponent.getGameDataComponent(param1);
         }
         if(isPlayerInCrew(param1,param2,param3))
         {
            return false;
         }
         if(isCrewBuildingFull(param1,null,param3))
         {
            return false;
         }
         return true;
      }
      
      public static function canBeClicked(param1:IEntity, param2:Boolean, param3:BehaviorState) : Boolean
      {
         if(isCrewBuilding(param1))
         {
            if(param2)
            {
               return true;
            }
            if(param3 as CrewDialogState)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getOwnerTendProgressBarInfo(param1:IEntity) : Object
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         var _loc3_:Object = getCrewInfo(param1,_loc2_);
         if(!_loc3_)
         {
            return null;
         }
         var _loc4_:uint = _loc3_.tends ? uint(countTends(_loc3_.tends)) : 0;
         var _loc5_:Object = getCrewOwnerTendRewardLabel(_loc2_.gameData.crewTendTemplate,_loc4_);
         if(!_loc5_)
         {
            return null;
         }
         return {
            "tends":_loc4_,
            "currMinTends":_loc5_.currMinTends,
            "nextMinTends":_loc5_.nextMinTends,
            "tendLevel":_loc5_.tendLevel
         };
      }
      
      private static function getSM(param1:IEntity) : BehaviorStateMachine
      {
         var _loc2_:BuildingFSMComponent = param1.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
         if(_loc2_)
         {
            return _loc2_.stateMachine as BehaviorStateMachine;
         }
         return null;
      }
      
      public static function doOwnerTendReward(param1:IEntity, param2:int) : void
      {
         var _loc3_:BehaviorStateMachine = getSM(param1);
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:String = _loc4_.gameData.crewTendTemplate;
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:Object = getCrewInfo(param1,_loc4_);
         if(!_loc6_ || !_loc6_.tends)
         {
            return;
         }
         var _loc7_:int = countTends(_loc6_.tends) + param2;
         var _loc8_:Object = getCrewOwnerTendRewardLabel(_loc5_,_loc7_);
         var _loc9_:String = (Boolean(_loc8_)) && Boolean(_loc8_.currentTemplate) ? _loc8_.currentTemplate : null;
         if(!_loc9_ || _loc9_ == "none")
         {
            return;
         }
         var _loc10_:XML = VisitorManager.getRewardXML(_loc9_);
         if(!_loc10_)
         {
            return;
         }
         var _loc11_:YieldHelper = new YieldHelper();
         _loc11_.initFromData(_loc10_);
         _loc11_.execute(_loc3_,_loc10_);
         var _loc12_:String = ZGameUtils.ZlocT("Main","FeedbackCrewHarvestBonus",{"tends":_loc7_});
         PlayerFeedbackManager.instance.displayFeedback(_loc12_);
         var _loc13_:CrewActionFeedback = new CrewActionFeedback(param1,_loc12_);
      }
      
      public static function getVisitorRewardTooltip(param1:IEntity, param2:int) : String
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:XML = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:ExperienceFeedbackText = null;
         var _loc12_:SocialExperienceGoodFeedbackText = null;
         var _loc13_:SocialExperienceBadFeedbackText = null;
         var _loc14_:String = null;
         var _loc15_:ResourceFeedbackText = null;
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_.gameData.crewTendTemplate;
            if(_loc4_)
            {
               _loc5_ = getCrewRewardLabelByTendRank(_loc4_,param2);
               if(_loc5_)
               {
                  _loc6_ = VisitorManager.getRewardXML(_loc5_);
                  if(_loc6_)
                  {
                     _loc7_ = ZGameUtils.ZlocT("Dialogs","CrewVisitTooltipHeader");
                     for each(_loc8_ in _loc6_.attributes())
                     {
                        _loc9_ = _loc8_.name().toString();
                        _loc10_ = parseInt(_loc8_);
                        switch(_loc9_)
                        {
                           case "name":
                              break;
                           case "xp":
                              _loc11_ = new ExperienceFeedbackText(_loc10_);
                              _loc7_ += "\n  " + _loc11_.friendlyName;
                              break;
                           case "socialXpGood":
                              _loc12_ = new SocialExperienceGoodFeedbackText(_loc10_);
                              _loc7_ += "\n  " + _loc12_.friendlyName;
                              break;
                           case "socialXpGood":
                              _loc13_ = new SocialExperienceBadFeedbackText(_loc10_);
                              _loc7_ += "\n  " + _loc13_.friendlyName;
                              break;
                           default:
                              _loc14_ = WorldResourceManager.instance.resourceFromRareResource(_loc9_,ZGlobal.hostPlayer.rareResourceType);
                              if(WorldResourceManager.instance.getResourceInfoByType(_loc14_))
                              {
                                 _loc15_ = new ResourceFeedbackText(_loc14_,_loc10_);
                                 _loc7_ += "\n  " + _loc15_.friendlyName;
                              }
                        }
                     }
                     return _loc7_;
                  }
               }
            }
         }
         return null;
      }
      
      public static function shouldShowVisitOverlay(param1:IEntity, param2:BehaviorState, param3:Boolean, param4:GameDataComponent = null) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!param4 && Boolean(param1))
         {
            param4 = GameDataComponent.getGameDataComponent(param1);
         }
         if(param3 && isCrewBuilding(param1))
         {
            if(ZGlobal.hostPlayer.uid != Player.FAKE_PLAYER_ID)
            {
               _loc5_ = parseInt(param2.name);
               _loc6_ = ZGlobal.gameSettings.getInt("CivicBuildingCrewGatherState");
               if(_loc5_ >= _loc6_)
               {
                  if(canPlayerJoinCrew(param1,ZGlobal.player.uid,param4))
                  {
                     return {
                        "show":true,
                        "data":getVisitJoinCrewOverlayData()
                     };
                  }
                  if(isPlayerInCrew(param1,ZGlobal.player.uid,param4) && param2.canVisitorHelp() && !param2.isVisitHelpLimitReached())
                  {
                     return {
                        "show":true,
                        "data":getVisitTendOverlayData()
                     };
                  }
               }
            }
         }
         else if(param2.canVisitorHelp() && !param2.isVisitHelpLimitReached())
         {
            return {
               "show":true,
               "data":param2.data
            };
         }
         return {"show":false};
      }
      
      private static function gateByUnbuyableSlots() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_crew_slot_no_purchase");
         if(_loc1_ == EXPERIMENT_NO_SLOT_PURCHASE_VARIANT)
         {
            return true;
         }
         return false;
      }
      
      private static function getVisitTendOverlayData() : XML
      {
         return getVisitOverlayData("CivicBuildingVisitTendIcon");
      }
      
      private static function getVisitJoinCrewOverlayData() : XML
      {
         return getVisitOverlayData("CivicBuildingVisitJoinCrewIcon");
      }
      
      private static function getVisitOverlayData(param1:String) : XML
      {
         var _loc2_:String = ZGlobal.gameSettings.getString(param1);
         var _loc3_:String = ZGlobal.gameSettings.getString("CivicBuildingVisitJoinCrewIconBackground");
         return <data icon={_loc2_} background={_loc3_} backgroundOffset="-25,-100" iconOffset="1,1" noScaleIcon="true" visitIconAlwaysVisible="true"/>;
      }
      
      public function buyCrewSlot(param1:IEntity, param2:int, param3:int) : void
      {
         var _loc5_:TStaffPosition = null;
         var _loc4_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         if(_loc4_)
         {
            _loc4_.buyCrewSlot(param2,param3);
            _loc5_ = new TStaffPosition(param1,param3,param2);
            TransactionManager.addTransaction(_loc5_);
            ZGlobal.player.cash -= param2;
         }
      }
      
      public function getCrewRemoveDuration(param1:GameItem) : int
      {
         if(param1.subType == "decoration")
         {
            return DecorationsManager.instance.crewRemoveDuration;
         }
         return 0;
      }
      
      public function initUser(param1:Object) : void
      {
         this.m_numDirtyCrewNeighbors = param1.numCrewNeighborsDirty;
         var _loc2_:Object = param1.userInfo.player.crewNeighbors;
         this.initCrewNeighborInfo(_loc2_);
      }
      
      public function isCrewMemberOf(param1:String) : Boolean
      {
         var _loc2_:Array = this.m_crewNeighborInfo[param1] as Array;
         return Boolean(_loc2_) && Boolean(_loc2_.length);
      }
      
      public function isCrewBuildingEmpty(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         var _loc3_:Object = getCrewInfo(param1,_loc2_);
         if(Boolean(_loc3_) && Boolean(_loc3_.crew) && Boolean(_loc3_.crew.length))
         {
            return false;
         }
         return true;
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:WorldEvent = null;
         var _loc2_:Object = param1.transaction.rawResult.metadata.tendInfo;
         if(_loc2_)
         {
            dispatchEvent(new WorldEvent(CREW_TEND_UPDATED,_loc2_));
         }
         if(param1.transaction is TCrewNeighborPoll)
         {
            _loc3_ = param1.transaction.rawResult.data;
            this.m_numDirtyCrewNeighbors = _loc3_.remaining;
            _loc4_ = this.initCrewNeighborInfo(_loc3_.info);
            if(_loc4_)
            {
               _loc5_ = new WorldEvent(CrewManager.CREW_NEIGHBORS_UPDATED);
               dispatchEvent(_loc5_);
            }
            this.startCrewNeighborsPoll();
         }
      }
      
      private function onPurchasedSlotFull(param1:WorldEvent) : void
      {
         ZGlobal.player.cash += param1.eventData.cost;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","CrewSlotFullError");
         var _loc3_:GenericPopup1B = GenericPopup1B.NewOk(_loc2_,null);
         PopupManager.instance.push(_loc3_);
      }
      
      private function onCrewNeighborsJoined(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = param1.eventData.owner;
         if(!this.m_crewNeighborInfo[_loc3_])
         {
            this.m_crewNeighborInfo[_loc3_] = new Array();
            _loc2_ = true;
         }
         this.m_crewNeighborInfo[_loc3_].push(param1.eventData.objid);
         if(_loc2_)
         {
            this.doCrewNeighborsFeedback(_loc3_,"CrewNeighborJoined");
         }
      }
      
      private function onCrewNeighborsRemoved(param1:WorldEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:String = param1.eventData.owner;
         if(this.m_crewNeighborInfo[_loc2_])
         {
            _loc3_ = int(this.m_crewNeighborInfo[_loc2_].indexOf(param1.eventData.objid));
            if(_loc3_ >= 0)
            {
               this.m_crewNeighborInfo[_loc2_].splice(_loc3_,1);
               if(!this.m_crewNeighborInfo[_loc2_].length)
               {
                  delete this.m_crewNeighborInfo[_loc2_];
                  this.doCrewNeighborsFeedback(_loc2_,"CrewNeighborRemoved");
               }
            }
         }
      }
      
      private function startCrewNeighborsPoll(param1:Event = null) : void
      {
         if(this.m_numDirtyCrewNeighbors > 0)
         {
            Zlab.processManager.schedule(CREW_NEIGHBOR_UPDATE_RATE,this,this.doCrewNeighborUpdate);
         }
      }
      
      public function doCrewNeighborUpdate() : void
      {
         TransactionManager.addTransaction(new TCrewNeighborPoll());
      }
      
      private function doCrewNeighborsFeedback(param1:String, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc3_:Player = ZGlobal.player.findFriendById(param1);
         if(_loc3_)
         {
            _loc3_.empireName;
            _loc4_ = ZGameUtils.ZlocT("Dialogs",param2,{"empirename":_loc3_.empireName});
            PlayerFeedbackManager.instance.displayFeedback(_loc4_);
         }
      }
      
      private function initCrewNeighborInfo(param1:Object) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         if(!(param1 is Array))
         {
            for(_loc2_ in param1)
            {
               _loc3_ = param1[_loc2_] as Array;
               if(Boolean(_loc3_) && Boolean(_loc3_.length))
               {
                  _loc4_ = _loc2_.slice(1);
                  this.m_crewNeighborInfo[_loc4_] = param1[_loc2_];
               }
            }
            return true;
         }
         return false;
      }
   }
}

