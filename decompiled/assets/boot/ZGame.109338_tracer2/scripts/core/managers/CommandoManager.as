package core.managers
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.CommandoKillActivateDialogState;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleHost;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionCallFunction;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionPlayAnimationAtEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import core.ui.PlayerFeedbackManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import dispatchers.UIDispatcher;
   import displays.popups.quest.QuestCompletePopup;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TSetCommandoStarted;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class CommandoManager extends EventDispatcher
   {
      
      public static const STATE_DOESNT_EXIST:int = 0;
      
      public static const STATE_READY:int = 22;
      
      public static const STATE_ACTIVE:int = 23;
      
      public static const STATE_COOLING:int = 24;
      
      public static const STATE_ACCUMULATING:int = 25;
      
      public static const STATE_DURATION:int = 900;
      
      public static const COOLING_DURATION:int = 86400;
      
      public static const COMMANDO_YARD_BUILDABLE:String = "CAY";
      
      public static const COMMANDO_ANIMATION_BUILDABLE:String = "CAY2";
      
      public static const COMMANDO_QUEST_COMPLETE:String = "commando_quest_complete";
      
      public static const NAME:String = "Commando_Assault_Yard";
      
      public static const LEVEL_DIFF_THRESHOLD:int = 10;
      
      private static var m_instance:CommandoManager = null;
      
      protected var m_popup:QuestCompletePopup = null;
      
      private var m_pointsAccumulated:int = 0;
      
      private var m_activatedAgain:Boolean = false;
      
      private var gameEntity:IEntity = null;
      
      protected var m_position:Array;
      
      private var validHookPos:Boolean = false;
      
      public var isInited:Boolean = false;
      
      public var m_animationDone:Boolean = false;
      
      private var m_pointsRequiredPerLevel:Object = {};
      
      private var m_currentState:int = 0;
      
      private var m_currentStateStart:int = 0;
      
      public function CommandoManager(param1:IEventDispatcher = null)
      {
         UIDispatcher.instance.addEventListener(COMMANDO_QUEST_COMPLETE,this.onQuestComplete);
         super(param1);
         this.initPointsPerLevel();
      }
      
      public static function get instance() : CommandoManager
      {
         if(!m_instance)
         {
            m_instance = new CommandoManager();
         }
         return m_instance;
      }
      
      public function init(param1:GameDataComponent, param2:IEntity) : void
      {
         if(param1.userData.pointsAccumulated != null)
         {
            this.m_pointsAccumulated = int(param1.userData.pointsAccumulated);
         }
         if(param1.userData.activatedAgain != null)
         {
            this.m_activatedAgain = Boolean(param1.userData.activatedAgain);
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         this.isInited = true;
      }
      
      public function setCurrentState(param1:int, param2:int = 0) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         if(param1 == STATE_ACTIVE)
         {
            if(this.getpointsAccumulated() > 0 && !this.m_activatedAgain)
            {
               this.m_activatedAgain = true;
            }
            this.resetPointsAccumulated();
         }
         if(param1 == STATE_READY)
         {
            _loc3_ = "15";
            _loc4_ = {"total":_loc3_};
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Toaster_1",_loc4_));
         }
         if(!param2)
         {
            param2 = GlobalEngine.serverTime / 1000;
         }
         this.m_currentState = param1;
         this.m_currentStateStart = param2;
      }
      
      public function getDamageModifier() : int
      {
         return ZGlobal.gameSettings.getInt("commandoAssaultBonusDamage",30);
      }
      
      public function getpointsAccumulated() : Number
      {
         return this.m_pointsAccumulated;
      }
      
      public function resetPointsAccumulated() : void
      {
         this.m_pointsAccumulated = 0;
      }
      
      public function isActivatedAgain() : Boolean
      {
         return this.m_activatedAgain;
      }
      
      protected function onBattleComplete(param1:WorldEvent) : void
      {
         this.incrementPoints(param1.eventData.enemyUID,param1.eventData.battle);
      }
      
      public function incrementPoints(param1:String, param2:BattleHost) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(param2.isDominationMode || param2.isChallenge || param2.isGlobalPVP)
         {
            if(param2.isChallenge && !param2.isGlobalPVP)
            {
               _loc3_ = PVPManager.instance.getPVPPlayer(param1);
               if(_loc3_ == null || _loc3_.level == 0)
               {
                  _loc3_ = ZGlobal.player.neighbors[param1];
               }
               _loc4_ = int(_loc3_.level);
               if(_loc4_ != 0 && this.isLevelEligible(_loc4_) == false)
               {
                  return;
               }
            }
            if(this.m_pointsAccumulated >= this.getPointsRequiredByLevel(ZGlobal.player.level))
            {
               return;
            }
            if(!this.isAccumulating())
            {
               return;
            }
            this.m_pointsAccumulated += 1;
            if(this.m_pointsAccumulated >= this.getPointsRequiredByLevel(ZGlobal.player.level))
            {
               this.setCurrentState(STATE_READY);
            }
         }
      }
      
      public function getPointsRequiredByLevel(param1:int) : Number
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(this.m_pointsRequiredPerLevel)
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_pointsRequiredPerLevel.levels.length && param1 >= this.m_pointsRequiredPerLevel.levels[_loc3_])
            {
               _loc3_++;
            }
            if(_loc3_ > 0)
            {
               _loc2_ = int(this.m_pointsRequiredPerLevel.points[_loc3_ - 1]);
            }
         }
         return _loc2_;
      }
      
      public function isActive() : Boolean
      {
         if(this.m_currentState == STATE_ACTIVE && GlobalEngine.serverTime / 1000 - this.m_currentStateStart < STATE_DURATION)
         {
            return true;
         }
         return false;
      }
      
      public function isAccumulating() : Boolean
      {
         if(this.m_currentState == STATE_ACCUMULATING && this.getpointsAccumulated() < this.getPointsRequiredByLevel(ZGlobal.player.level) || this.m_currentState == STATE_COOLING && GlobalEngine.serverTime / 1000 - this.m_currentStateStart >= COOLING_DURATION)
         {
            return true;
         }
         return false;
      }
      
      public function isLevelEligible(param1:int) : Boolean
      {
         return ZGlobal.player.level - param1 <= LEVEL_DIFF_THRESHOLD;
      }
      
      public function initEvents() : void
      {
         var _loc1_:AutoActionPanToEntity = null;
         var _loc2_:AutoActionPlayAnimationAtEntity = null;
         var _loc3_:AutoActionCallFunction = null;
         var _loc4_:AutoActionCallFunction = null;
         _loc1_ = new AutoActionPanToEntity();
         _loc1_.data = {"target":this.placeTransmitter()};
         _loc3_ = new AutoActionCallFunction();
         _loc3_.data = {"func":this.showFirstDialog};
         _loc4_ = new AutoActionCallFunction();
         _loc4_.data = {"func":this.fireTransaction};
         _loc1_.setNextAction(_loc4_);
         _loc1_.startAction();
      }
      
      private function placeTransmitter() : IEntity
      {
         var _loc2_:QuadSpatialManager = null;
         var _loc3_:IsoViewComponent = null;
         var _loc4_:IsoScene = null;
         var _loc5_:IslandWorld = null;
         var _loc6_:EntityInit = null;
         var _loc7_:GameDataComponent = null;
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(COMMANDO_ANIMATION_BUILDABLE,GameItem) as GameItem;
         if(_loc1_)
         {
            _loc2_ = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
            _loc3_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc4_ = IsoScene(_loc3_.getSceneByID("gameScene"));
            _loc5_ = ZGlobal.game.getWorld(IslandWorld.ID) as IslandWorld;
            _loc6_ = new EntityInit();
            _loc6_.m_isoScene = _loc4_;
            _loc6_.m_spatialComponent = _loc2_;
            _loc6_.m_item = _loc1_;
            _loc6_.m_position = this.getPosition(_loc1_);
            _loc6_.m_object = {
               "position":this.m_position[0] + "," + this.m_position[1],
               "state":(this.animationDone ? 2 : 0)
            };
            _loc6_.m_group = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
            this.gameEntity = BuildingEntity.createEntity(_loc6_);
            WorldObjectManager.instance.addObjectToCodeDictionary(_loc1_.code);
            WorldObjectManager.instance.addObjectToTypeDictionary(_loc1_.type,_loc1_.subType,this.gameEntity.name,this.gameEntity);
            WorldObjectManager.instance.addObjectToCategoryDictionary(_loc1_.categoryLimitName);
            _loc7_ = GameDataComponent(this.gameEntity.lookupComponentByType(GameDataComponent));
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED_CLIENT,_loc7_.gameData.code));
            BuildManager.instance.alwaysGetObject(this.gameEntity);
         }
         return this.gameEntity;
      }
      
      public function showFirstDialog() : void
      {
         var _loc1_:AutoActionShowSpeechPopup = null;
         _loc1_ = new AutoActionShowSpeechPopup();
         _loc1_.data = {"speechId":"Speech_Commando_Assault_Yard_01"};
         _loc1_.startAction();
      }
      
      private function getPosition(param1:GameItem) : Pt
      {
         var _loc3_:Array = null;
         var _loc2_:XML = null;
         var _loc4_:XMLList = param1.xml.positions[0].pos;
         for each(_loc2_ in _loc4_)
         {
            _loc3_ = _loc2_.toString().split(",");
            BuildManager.instance.checkFreeForPlacement(_loc3_[0],_loc3_[1],param1.sizeX,param1.sizeY,this.checkPlacement);
            if(this.validHookPos)
            {
               this.m_position = _loc3_;
               return new Pt(_loc3_[0],_loc3_[1]);
            }
         }
         _loc2_ = _loc4_[0];
         _loc3_ = _loc2_.toString().split(",");
         this.m_position = _loc3_;
         return new Pt(_loc3_[0],_loc3_[1]);
      }
      
      private function checkPlacement(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:Pt = MathUtils.tileToWorld(param1,param2,0,ZGlobal.cellSize);
         if(BuildManager.instance.getObjectsAt(new Point(_loc5_.x,_loc5_.y)) != null)
         {
            return false;
         }
         this.validHookPos = true;
         return true;
      }
      
      private function get animationDone() : Boolean
      {
         return this.m_animationDone;
      }
      
      private function set animationDone(param1:Boolean) : void
      {
         this.m_animationDone = param1;
      }
      
      public function fireTransaction() : void
      {
         var _loc1_:Transaction = new TSetCommandoStarted(COMMANDO_ANIMATION_BUILDABLE,this.m_position);
         TransactionManager.addTransaction(_loc1_);
         this.animationDone = true;
      }
      
      public function onQuestComplete(param1:WorldEvent) : void
      {
         UIDispatcher.instance.removeEventListener(COMMANDO_QUEST_COMPLETE,this.onQuestComplete,true);
         QuestCompletePopup(param1.eventData);
         var _loc2_:AutoActionCallFunction = new AutoActionCallFunction();
         _loc2_.data = {"func":this.showNotification};
         _loc2_.startAction();
      }
      
      public function showNotification() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(CommandoKillActivateDialogState.SHOW_COMMANDO_DIALOG));
      }
      
      public function start() : void
      {
      }
      
      private function initPointsPerLevel() : void
      {
         var _loc4_:XML = null;
         var _loc1_:XMLList = ZGlobal.gameSettings.getXML().commandoAssaultPoints.level;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         if(_loc1_)
         {
            for each(_loc4_ in _loc1_)
            {
               _loc2_.push(int(_loc4_.@minLevel));
               _loc3_.push(int(_loc4_.@requirement));
            }
         }
         this.m_pointsRequiredPerLevel = {
            "levels":_loc2_,
            "points":_loc3_
         };
      }
      
      public function getBuildingByCode(param1:String) : IEntity
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:GameDataComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:IEntity = null;
         if(_loc2_)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc6_)) && _loc6_.gameData.code == param1)
               {
                  _loc3_ = _loc6_.owner;
                  break;
               }
            }
         }
         return _loc3_;
      }
   }
}

