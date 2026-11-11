package core.managers.visitorManager
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import as3isolib.display.scene.IsoScene;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gamemode.GMSell;
   import core.gamemode.avatar.RetainedVisitorAvatarComponent;
   import core.gamemode.avatar.VisitorAvatarComponent;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.actionfeedback.CrewActionFeedback;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import dispatchers.MessageDispatcher;
   import displays.popups.visit.VisitPopup;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TVisitorDecline;
   import transactions.TVisitorHelpInvalid;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class VisitorManager extends EventDispatcher
   {
      
      public static var instance:VisitorManager;
      
      private static var SENDER_NEIGHBOR_ID_PREFIX:String = "i";
      
      private static var SENDER_ADVISOR_ID:String = "advisor";
      
      public static var VISITOR_HELPER_DONE:String = "visitorHelperDone";
      
      public static var WORLD_LOADED:String = "worldLoaded";
      
      public static var VISITOR_ENERGY_SPENT:String = "visitorEnergySpent";
      
      public static var VISITOR_TARGET_HIGHLIGHT:String = "visitorTargetHighlight";
      
      public static var VISITOR_TARGET_HELPED:String = "visitorTargetHelped";
      
      public static var RETAIN_VISITS_DONE:String = "retainVisitDone";
      
      public static var VISITOR_HELP_CLEAR:String = "clear";
      
      public static var VISITOR_HELP_HARVEST:String = "harvest";
      
      public static var VISITOR_HELP_SPEEDUP:String = "speedup";
      
      public static var VISITOR_HELP_REVIVE:String = "revive";
      
      public static var VISITOR_HELP_MINE:String = "mine";
      
      public static var VISITOR_HELP_BUILD:String = "build";
      
      public static var VISITOR_HELP_TAX:String = "tax";
      
      public static var VISITOR_HELP_CAPSULE_TAX:String = "capsuletax";
      
      public static var VISITOR_HELP_CREW_TAX:String = "crewTax";
      
      public static var VISITOR_HELP_CREW_TAX_MATURING:String = "crewTaxMaturing";
      
      private static const m_helpTypes:Array = new Array(VISITOR_HELP_BUILD,VISITOR_HELP_CLEAR,VISITOR_HELP_HARVEST,VISITOR_HELP_SPEEDUP,VISITOR_HELP_REVIVE,VISITOR_HELP_MINE,VISITOR_HELP_TAX,VISITOR_HELP_CAPSULE_TAX,VISITOR_HELP_CREW_TAX,VISITOR_HELP_CREW_TAX_MATURING);
      
      private static const m_cursors:Array = new Array(new Cursor_Hammer(1,1),new Cursor_Shovel(1,1),new Cursor_Hoe(1,1),new Cursor_FastForward(1,1),new Cursor_WaterCan(1,1),new Cursor_Ingots(1,1),new Cursor_Coins_49(1,1),new Cursor_Coins_49(1,1),new Cursor_Coins_49(1,1),new Cursor_Coins_49(1,1));
      
      private static const m_overlayIcons:Array = new Array("assets/game/GeneralAssetGroup_UI.swf/Hammer_48.png","assets/game/GeneralAssetGroup_UI.swf/Shovel_48.png","assets/game/GeneralAssetGroup_UI.swf/Hoe_48.png","assets/game/GeneralAssetGroup_UI.swf/FastForward_48.png","assets/game/GeneralAssetGroup_UI.swf/WaterCan_48.png","assets/game/GeneralAssetGroup_UI.swf/Ingots_48.png","assets/game/GeneralAssetGroup_UI.swf/Coins_42.png","assets/game/GeneralAssetGroup_UI.swf/Coins_42.png","assets/game/GeneralAssetGroup_UI.swf/Coins_42.png","assets/game/GeneralAssetGroup_UI.swf/Coins_42.png");
      
      private static var NEIGHBOR_ACTION_SPEND_ALL_TEND:String = "spendAllTendEnergy";
      
      public static var Order:Dictionary = new Dictionary();
      
      private var m_cursorTypes:Array = [Cursor_FastForward];
      
      private var m_avatars:Dictionary = new Dictionary();
      
      private var m_retVisitAvatars:Dictionary = new Dictionary();
      
      private var m_requests:Dictionary = new Dictionary();
      
      private var m_retrequests:Dictionary = new Dictionary();
      
      private var m_initpos:Dictionary = new Dictionary();
      
      private var m_nonHomeIslandHelpUpdates:Dictionary;
      
      private var m_crewAutoFilledBuildings:Array = new Array();
      
      private var m_untendableObjIDs:Array;
      
      public function VisitorManager()
      {
         super();
         addEventListener(VISITOR_HELPER_DONE,this.onVisitorActionsDone,false,0,true);
         addEventListener(WORLD_LOADED,this.onWorldLoaded,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.VISITOR_HELP_UPDATE,this.onVisitorHelpUpdate,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.ITEM_SET_STATE,this.onItemSetState,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.ITEM_REMOVED,this.onItemRemoved,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete,false,0,true);
         addEventListener(RETAIN_VISITS_DONE,this.onRetainVisitDone,false,0,true);
      }
      
      public static function initialize() : void
      {
         instance = new VisitorManager();
      }
      
      public static function isValidHelpType(param1:String) : Boolean
      {
         if(m_helpTypes.indexOf(param1) >= 0)
         {
            return true;
         }
         return false;
      }
      
      public static function getCursor(param1:IEntity, param2:String) : Object
      {
         var _loc3_:GameDataComponent = param1 ? GameDataComponent.getGameDataComponent(param1) : null;
         if(Boolean(_loc3_) && CrewManager.isCrewBuilding(param1,_loc3_))
         {
            if(!CrewManager.isPlayerInCrew(param1,ZGlobal.player.uid,_loc3_) || ZGlobal.hostPlayer.uid == Player.FAKE_PLAYER_ID)
            {
               return null;
            }
         }
         var _loc4_:int = m_helpTypes.indexOf(param2);
         if(_loc4_ >= 0)
         {
            return m_cursors[_loc4_];
         }
         return null;
      }
      
      public static function getOverlayIcon(param1:String) : String
      {
         var _loc2_:int = m_helpTypes.indexOf(param1);
         if(_loc2_ >= 0)
         {
            return m_overlayIcons[_loc2_];
         }
         return null;
      }
      
      public static function getVisitorRewardLabel(param1:IEntity, param2:GameItem, param3:String, param4:Boolean) : String
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:CrewActionFeedback = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         if(!param4 && param3 == VISITOR_HELP_CREW_TAX)
         {
            _loc7_ = CrewManager.getCrewRewardLabel(param1);
            if(_loc7_)
            {
               _loc8_ = ZGameUtils.ZlocT("Main","FeedbackCrewTendBonus");
               PlayerFeedbackManager.instance.displayFeedback(_loc8_);
               _loc9_ = new CrewActionFeedback(param1,_loc8_);
            }
            return _loc7_;
         }
         var _loc5_:PropertyReference = new PropertyReference("@Data.gameData");
         var _loc6_:String = param3;
         switch(param3)
         {
            case VisitorManager.VISITOR_HELP_CLEAR:
               if(param2)
               {
                  _loc6_ += param2.subType;
               }
               break;
            case VisitorManager.VISITOR_HELP_MINE:
               _loc10_ = ZGlobal.hostPlayer.rareResourceType;
               _loc11_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc10_);
               if(_loc11_)
               {
                  _loc6_ += _loc11_;
               }
               break;
            case VisitorManager.VISITOR_HELP_HARVEST:
               if(param2)
               {
                  if(param2.referenceType.length > 0)
                  {
                     _loc6_ += "_" + param2.referenceType;
                     if(param2.referenceSubtype.length > 0)
                     {
                        _loc6_ += "_" + param2.referenceSubtype;
                     }
                  }
               }
         }
         if(param4)
         {
            return _loc6_ + "_accepting";
         }
         return _loc6_;
      }
      
      public static function getRewardXML(param1:String) : XML
      {
         var _loc2_:XMLList = null;
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         if(param1 != null)
         {
            _loc2_ = ZGlobal.gameSettings.getXML().visitorRewards.reward;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length())
            {
               _loc4_ = _loc2_[_loc3_];
               if(_loc4_.@name == param1)
               {
                  return _loc4_;
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      public function storeVisitorRequests(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         if(param1)
         {
            for(_loc2_ in param1)
            {
               if(_loc2_ != SENDER_ADVISOR_ID)
               {
                  _loc3_ = _loc2_;
                  if(_loc2_.charAt(0) == SENDER_NEIGHBOR_ID_PREFIX)
                  {
                     _loc3_ = _loc2_.slice(1);
                  }
                  if(!ZGlobal.player.findFriendById(_loc3_))
                  {
                     Logger.warn(this,"storeVisitorRequests","Neighbor id " + _loc3_ + " not found");
                  }
                  else
                  {
                     _loc4_ = param1[_loc2_] as String;
                     if((Boolean(_loc4_)) && _loc4_.length > 0)
                     {
                        this.m_requests[_loc3_] = new Array();
                        this.m_retrequests[_loc3_] = new Array();
                        _loc5_ = _loc4_.split(",");
                        for each(_loc6_ in _loc5_)
                        {
                           this.m_requests[_loc3_].push(int(_loc6_));
                           this.m_retrequests[_loc3_].push(int(_loc6_));
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function storeCrewAutoFilledBuildings(param1:Array) : void
      {
         if(param1)
         {
            this.m_crewAutoFilledBuildings = param1;
         }
      }
      
      public function wasBuildingAutoFilled(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = null;
         if(param1)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(param1);
            if(Boolean(_loc2_) && this.m_crewAutoFilledBuildings.indexOf(_loc2_.id) >= 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function removeBuildingAutoFillSeen(param1:IEntity) : void
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(param1);
            if(_loc2_)
            {
               _loc3_ = this.m_crewAutoFilledBuildings.indexOf(_loc2_.id);
               if(_loc3_ >= 0)
               {
                  this.m_crewAutoFilledBuildings.splice(_loc3_,1);
               }
            }
         }
      }
      
      public function helpRedeemed(param1:String, param2:int) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         if(this.m_requests[param1])
         {
            _loc3_ = this.m_requests[param1] as Array;
            if(_loc3_)
            {
               _loc4_ = _loc3_.indexOf(param2);
               if(_loc4_ >= 0)
               {
                  _loc3_.splice(_loc4_,1);
                  if(!_loc3_.length)
                  {
                     if(!this.m_retrequests[param1])
                     {
                        this.m_retrequests[param1] = new Array();
                        this.m_retrequests[param1].push(param2);
                     }
                     delete this.m_requests[param1];
                  }
               }
            }
         }
      }
      
      public function helpedInvalidTendTarget(param1:String, param2:int) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         if(this.m_requests[param1])
         {
            _loc3_ = this.m_requests[param1] as Array;
            if(_loc3_)
            {
               _loc4_ = _loc3_.indexOf(param2);
               if(_loc4_ >= 0)
               {
                  _loc3_.splice(_loc4_,1);
                  TransactionManager.addTransaction(new TVisitorHelpInvalid(param1,param2));
               }
            }
         }
      }
      
      public function spawnAvatarsInstant(param1:Dictionary) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            this.createNeighborAvatar(_loc2_,_loc3_);
            if(!this.m_requests[_loc2_])
            {
               this.m_requests[_loc2_] = new Array();
               this.m_retrequests[_loc2_] = new Array();
            }
            this.m_requests[_loc2_] = this.m_requests[_loc2_].concat(_loc3_);
            this.m_retrequests[_loc2_] = this.m_requests[_loc2_].concat(_loc3_);
         }
      }
      
      public function storeNonHomeIslandHelpUpdates(param1:Dictionary) : void
      {
         this.m_nonHomeIslandHelpUpdates = param1;
      }
      
      public function addHelpedObject(param1:String, param2:int) : void
      {
         if(!this.m_requests[param1])
         {
            this.m_requests[param1] = new Array();
            this.m_retrequests[param1] = new Array();
         }
         this.m_requests[param1].push(param2);
         this.m_retrequests[param1].push(param2);
      }
      
      public function newTendActionFeedback(param1:String, param2:int) : void
      {
         var _loc5_:String = null;
         var _loc3_:IEntity = ZGlobal.game.getObjectByID(param2);
         var _loc4_:Player = ZGlobal.player.findFriendById(param1);
         if(Boolean(_loc3_) && Boolean(_loc4_))
         {
            _loc5_ = ZGameUtils.ZlocT("Main","FeedbackHostHelpRequested",{"user":_loc4_.localizationName});
            PlayerFeedbackManager.instance.displayFeedback(_loc5_,_loc3_,null,_loc4_.uid);
         }
      }
      
      private function createNeighborAvatar(param1:String, param2:Array) : void
      {
         var _loc4_:VisitorManagerOrder = null;
         var _loc3_:Player = ZGlobal.player.findFriendById(param1);
         if(_loc3_)
         {
            _loc4_ = new VisitorManagerOrder(param2);
            if(_loc4_.initialPosValid())
            {
               Order[param1] = _loc4_;
               this.m_avatars[param1] = this.createNeighborAvatarFromOrder(_loc3_,_loc4_);
            }
         }
      }
      
      private function createNeighborAvatarFromOrder(param1:Player, param2:VisitorManagerOrder) : IEntity
      {
         var _loc11_:IEntityComponent = null;
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode("NA1",GameItem) as GameItem;
         var _loc4_:PBGroup = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         var _loc5_:QuadSpatialManager = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
         var _loc6_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc7_:IsoScene = IsoScene(_loc6_.getSceneByID("gameScene"));
         var _loc8_:EntityInit = new EntityInit();
         _loc8_.m_isoScene = _loc7_;
         _loc8_.m_spatialComponent = _loc5_;
         _loc8_.m_item = _loc3_;
         _loc8_.m_position = param2.initialPos;
         _loc8_.m_group = _loc4_;
         var _loc9_:IEntity = BuildingEntity.createEntity(_loc8_);
         var _loc10_:VisitorAvatarComponent = new VisitorAvatarComponent(param1,_loc3_,_loc6_.isoView,param2);
         if(Boolean(this.m_retVisitAvatars[param1.uid]) && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RETAINNEIGHBOR_MASTER) == ExperimentsManager.VARIANT_RETAINNEIGHBOR_ENABLED)
         {
            if(this.m_retVisitAvatars[param1.uid].lookupComponentByName("RetainedVisitorAvatarComponent"))
            {
               _loc11_ = this.m_retVisitAvatars[param1.uid].lookupComponentByName("RetainedVisitorAvatarComponent");
               this.m_retVisitAvatars[param1.uid].removeComponent(_loc11_);
               delete this.m_retrequests[param1.uid];
            }
         }
         _loc9_.addComponent(_loc10_,"VisitorAvatarCompnent");
         return _loc9_;
      }
      
      private function onVisitorActionsDone(param1:WorldEvent) : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:PBGroup = null;
         var _loc6_:QuadSpatialManager = null;
         var _loc7_:IsoViewComponent = null;
         var _loc8_:IsoScene = null;
         var _loc9_:EntityInit = null;
         var _loc10_:IEntity = null;
         var _loc11_:Player = null;
         var _loc12_:RetainedVisitorAvatarComponent = null;
         var _loc13_:Array = null;
         var _loc2_:IEntity = this.m_avatars[param1.eventData.id];
         if(_loc2_)
         {
            _loc2_.destroy();
            delete this.m_avatars[param1.eventData.id];
         }
         if((Boolean(this.m_retrequests[param1.eventData.id]) || Boolean(this.m_requests[param1.eventData.id])) && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RETAINNEIGHBOR_MASTER) == ExperimentsManager.VARIANT_RETAINNEIGHBOR_ENABLED)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode("NA1",GameItem) as GameItem;
            _loc5_ = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
            _loc6_ = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
            _loc7_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc8_ = IsoScene(_loc7_.getSceneByID("gameScene"));
            _loc9_ = new EntityInit();
            _loc9_.m_isoScene = _loc8_;
            _loc9_.m_spatialComponent = _loc6_;
            _loc9_.m_item = _loc4_;
            _loc9_.m_position = Order[param1.eventData.id].initialPos;
            this.m_initpos[param1.eventData.id] = Order[param1.eventData.id].initialPos;
            _loc9_.m_group = _loc5_;
            _loc10_ = BuildingEntity.createEntity(_loc9_);
            _loc11_ = ZGlobal.player.findFriendById(param1.eventData.id);
            _loc12_ = new RetainedVisitorAvatarComponent(_loc11_,_loc4_,_loc7_.isoView);
            _loc10_.addComponent(_loc12_,"RetainedVisitorAvatarComponent");
            this.m_retVisitAvatars[param1.eventData.id] = _loc10_;
         }
         var _loc3_:Array = param1.eventData.blockedTargets;
         if(_loc3_.length)
         {
            _loc13_ = Utilities.clone(_loc3_) as Array;
            if(_loc13_)
            {
               this.createNeighborAvatar(param1.eventData.id,_loc13_);
            }
         }
      }
      
      private function onRetainVisitDone(param1:WorldEvent) : void
      {
         var _loc2_:IEntity = this.m_retVisitAvatars[param1.eventData.id];
         if(_loc2_)
         {
            if(param1.eventData.mflag)
            {
               _loc2_.destroy();
               delete this.m_retVisitAvatars[param1.eventData.id];
               delete this.m_retrequests[param1.eventData.id];
            }
            else
            {
               _loc2_.destroy();
               delete this.m_retVisitAvatars[param1.eventData.id];
               this.createretAvatarsonrefresh();
            }
         }
      }
      
      private function mergeNonHomeIslandViewHelpUpdates() : void
      {
         var _loc1_:String = null;
         if(this.m_nonHomeIslandHelpUpdates)
         {
            for(_loc1_ in this.m_nonHomeIslandHelpUpdates)
            {
               if(!this.m_requests[_loc1_])
               {
                  this.m_requests[_loc1_] = new Array();
                  this.m_retrequests[_loc1_] = new Array();
               }
               this.m_requests[_loc1_] = this.m_requests[_loc1_].concat(this.m_nonHomeIslandHelpUpdates[_loc1_]);
               this.m_retrequests[_loc1_] = this.m_requests[_loc1_].concat(this.m_nonHomeIslandHelpUpdates[_loc1_]);
            }
            this.m_nonHomeIslandHelpUpdates = null;
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(ZGlobal.isHome())
         {
            this.mergeNonHomeIslandViewHelpUpdates();
            this.createAvatars();
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RETAINNEIGHBOR_MASTER) == ExperimentsManager.VARIANT_RETAINNEIGHBOR_ENABLED)
            {
               this.createretAvatarsonrefresh();
            }
         }
      }
      
      public function createretAvatarsonrefresh() : void
      {
         var _loc1_:String = null;
         var _loc2_:GameItem = null;
         var _loc3_:PBGroup = null;
         var _loc4_:QuadSpatialManager = null;
         var _loc5_:IsoViewComponent = null;
         var _loc6_:IsoScene = null;
         var _loc7_:EntityInit = null;
         var _loc8_:IEntity = null;
         var _loc9_:Player = null;
         var _loc10_:RetainedVisitorAvatarComponent = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RETAINNEIGHBOR_MASTER) == ExperimentsManager.VARIANT_RETAINNEIGHBOR_ENABLED)
         {
            for(_loc1_ in this.m_retrequests)
            {
               if(Boolean(!this.m_avatars[_loc1_]) && Boolean(this.m_retrequests[_loc1_]) && Boolean(this.m_initpos[_loc1_]))
               {
                  _loc2_ = ZGlobal.gameSettings.getItemByCode("NA1",GameItem) as GameItem;
                  _loc3_ = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
                  _loc4_ = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
                  _loc5_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
                  _loc6_ = IsoScene(_loc5_.getSceneByID("gameScene"));
                  _loc7_ = new EntityInit();
                  _loc7_.m_isoScene = _loc6_;
                  _loc7_.m_spatialComponent = _loc4_;
                  _loc7_.m_item = _loc2_;
                  _loc7_.m_position = this.m_initpos[_loc1_];
                  _loc7_.m_group = _loc3_;
                  _loc8_ = BuildingEntity.createEntity(_loc7_);
                  _loc9_ = ZGlobal.player.findFriendById(_loc1_);
                  _loc10_ = new RetainedVisitorAvatarComponent(_loc9_,_loc2_,_loc5_.isoView);
                  _loc8_.addComponent(_loc10_,"RetainedVisitorAvatarComponent");
                  this.m_retVisitAvatars[_loc1_] = _loc8_;
               }
            }
         }
      }
      
      public function createAvatars() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         for(_loc1_ in this.m_requests)
         {
            _loc2_ = this.m_requests[_loc1_];
            this.createNeighborAvatar(_loc1_,_loc2_);
         }
      }
      
      public function spawnAvatarInstant(param1:String, param2:int) : void
      {
         var _loc3_:Dictionary = new Dictionary();
         _loc3_[param1] = [param2];
         this.spawnAvatarsInstant(_loc3_);
      }
      
      public function rejectTending(param1:String, param2:Array) : void
      {
         TransactionManager.addTransaction(new TVisitorDecline(param1));
         delete this.m_requests[param1];
         delete this.m_retrequests[param1];
         if(this.m_nonHomeIslandHelpUpdates)
         {
            delete this.m_nonHomeIslandHelpUpdates[param1];
         }
      }
      
      public function worldVisited(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         this.m_untendableObjIDs = null;
         if(param1)
         {
            _loc2_ = param1.split(",");
            this.m_untendableObjIDs = new Array();
            for each(_loc3_ in _loc2_)
            {
               this.m_untendableObjIDs.push(int(_loc3_));
            }
         }
      }
      
      public function isObjectIDTendable(param1:int) : Boolean
      {
         if(this.m_untendableObjIDs)
         {
            return this.m_untendableObjIDs.indexOf(param1) < 0;
         }
         return true;
      }
      
      private function onVisitorHelpUpdate(param1:WorldEvent) : void
      {
         var _loc2_:String = param1.eventData.helper;
         var _loc3_:int = int(param1.eventData.objid);
         if(ZGlobal.isHome())
         {
            this.spawnAvatarInstant(_loc2_,_loc3_);
         }
         else
         {
            if(!this.m_nonHomeIslandHelpUpdates)
            {
               this.m_nonHomeIslandHelpUpdates = new Dictionary();
            }
            if(!this.m_nonHomeIslandHelpUpdates[_loc2_])
            {
               this.m_nonHomeIslandHelpUpdates[_loc2_] = new Array();
            }
            this.m_nonHomeIslandHelpUpdates[_loc2_].push(_loc3_);
         }
      }
      
      private function onItemSetState(param1:WorldEvent) : void
      {
         var _loc5_:BuildingFSMComponent = null;
         var _loc6_:BehaviorStateMachine = null;
         var _loc7_:GameDataComponent = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:Object = null;
         var _loc13_:GameItem = null;
         var _loc2_:int = int(param1.eventData.target);
         var _loc3_:String = param1.eventData.world;
         var _loc4_:IEntity = ZGlobal.game.getObjectByID(_loc2_);
         if((Boolean(_loc4_)) && Boolean(ZGlobal.isVisiting()) && _loc3_ == ZGlobal.hostPlayer.uid)
         {
            _loc5_ = BuildingFSMComponent(_loc4_.lookupComponentByType(BuildingFSMComponent));
            if(_loc5_)
            {
               _loc6_ = _loc5_.stateMachine as BehaviorStateMachine;
               if(_loc6_)
               {
                  _loc7_ = GameDataComponent.getGameDataComponent(_loc4_);
                  if(_loc7_)
                  {
                     if(_loc7_.gameData)
                     {
                        _loc10_ = param1.eventData.referenceItemCode;
                        if(_loc7_.gameData.isResearchItem())
                        {
                           _loc12_ = BuildingEntity.deserializeResearchString(_loc10_);
                           if(_loc12_)
                           {
                              _loc8_ = _loc12_.referenceItemName;
                              _loc9_ = _loc12_.researchItemName;
                           }
                        }
                        else
                        {
                           _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc10_,GameItem) as GameItem;
                           if(_loc13_)
                           {
                              _loc8_ = _loc13_.name;
                           }
                        }
                        _loc6_.storeReferenceData(_loc8_,_loc9_);
                        _loc6_.updateStateFromRemote(param1.eventData.state);
                        _loc11_ = ZGameUtils.ZlocT("Main","FeedbackHostWorkDone",{"user":ZGlobal.hostPlayer.localizationName});
                        PlayerFeedbackManager.instance.displayFeedback(_loc11_,_loc4_,null,ZGlobal.hostPlayer.uid);
                     }
                  }
               }
            }
         }
      }
      
      private function onItemRemoved(param1:WorldEvent) : void
      {
         var _loc5_:String = null;
         var _loc2_:int = int(param1.eventData.target);
         var _loc3_:String = param1.eventData.world;
         var _loc4_:IEntity = ZGlobal.game.getObjectByID(_loc2_);
         if((Boolean(_loc4_)) && Boolean(ZGlobal.isVisiting()) && _loc3_ == ZGlobal.hostPlayer.uid)
         {
            _loc5_ = ZGameUtils.ZlocT("Main","FeedbackHostCleared",{"user":ZGlobal.hostPlayer.localizationName});
            PlayerFeedbackManager.instance.displayFeedback(_loc5_,_loc4_,null,ZGlobal.hostPlayer.uid);
            GMSell.clearObject(_loc4_,true);
         }
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(param1.transaction.rawResult.metadata.NeighborActions)
         {
            _loc2_ = param1.transaction.rawResult.metadata.NeighborActions;
            for each(_loc3_ in _loc2_)
            {
               switch(_loc3_)
               {
                  case NEIGHBOR_ACTION_SPEND_ALL_TEND:
                     this.doNeighborSpendAllTend();
               }
            }
         }
      }
      
      private function doNeighborSpendAllTend() : void
      {
         var _loc1_:Object = ZGlobal.gameSettings.neighborVisitReward;
         if(Boolean(_loc1_.energy) && ZGlobal.player.m_energy.canAcceptEnergy(_loc1_.energy))
         {
            ZGlobal.player.m_energy.energy += _loc1_.energy;
            if(ZGlobal.isVisiting())
            {
               PopupManager.instance.push(new VisitPopup(ZGlobal.hostPlayer,_loc1_),0,true,false);
            }
         }
      }
   }
}

