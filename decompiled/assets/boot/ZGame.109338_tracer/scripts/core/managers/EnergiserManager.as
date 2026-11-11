package core.managers
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionCallFunction;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionPlaceItem;
   import core.managers.autoActionsManager.AutoActionPlayAnimationAtEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UI;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericCountdownClock;
   import displays.popups.quest.QuestCompletePopup;
   import displays.screens.EnergizerNotificationScreen;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import events.EnergyMarketEvent;
   import events.MarketEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TEnergizerSetup;
   import transactions.TSetEnergiserStarted;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class EnergiserManager extends EventDispatcher
   {
      
      private static var m_instance:EnergiserManager = new EnergiserManager();
      
      private static const ENERGISER:String = "EZ01";
      
      private static const TRANSMITTER:String = "EZ02";
      
      private static const SUBTYPE:String = "Energy_booster";
      
      public static const QUEST_COMPLETE:String = "quest_complete";
      
      public static const LOW_ENERGY:String = "low_energy";
      
      public static const DEDUCT_ENERGY_TOASTER:String = "deduct_energy";
      
      public static const ENERGY_MAX:int = 60;
      
      private static const DURATION:Number = 14 * 24 * 60 * 60 * 1000;
      
      private static const TIME_OVER:String = "time_over";
      
      private static const UPDATE_FREQUENCY:int = 1000;
      
      private static const VARIANT_ON:uint = 3;
      
      protected var m_popup:QuestCompletePopup = null;
      
      private var m_initTime:Number = 0;
      
      private var validHookPos:Boolean = false;
      
      public var m_animationDone:Boolean = false;
      
      private var gameEntity:IEntity = null;
      
      public var m_entity:IEntity;
      
      protected var m_position:Array;
      
      private var m_clock:GenericCountdownClock;
      
      private var m_lowenergyPopupcounter:uint = 0;
      
      public var m_energyRefill:uint = 0;
      
      public function EnergiserManager(param1:IEventDispatcher = null)
      {
         UIDispatcher.instance.addEventListener(QUEST_COMPLETE,this.onQuestComplete);
         UIDispatcher.instance.addEventListener(LOW_ENERGY,this.displayEnergizerToaster);
         UIDispatcher.instance.addEventListener(DEDUCT_ENERGY_TOASTER,this.displayEnergizerDeductToaster);
         super(param1);
      }
      
      public static function get instance() : EnergiserManager
      {
         return m_instance;
      }
      
      public function start() : void
      {
      }
      
      private function durationLeft() : Number
      {
         return GlobalEngine.serverTime - this.initTime - ZGlobal.player.timeWarpSeconds * 1000;
      }
      
      public function init(param1:Number) : void
      {
         this.initTime = param1;
         this.animationDone = this.initTime != 0;
         if(this.initTime != 0)
         {
            if(this.durationLeft() < DURATION && !this.m_energyRefill)
            {
               Zlab.processManager.schedule(UPDATE_FREQUENCY,this,this.onTimeOver);
               this.placeTransmitter();
            }
         }
      }
      
      private function onTimeOver() : void
      {
         if(this.durationLeft() >= DURATION)
         {
            this.removeEnergiserTransmitter();
         }
         else
         {
            Zlab.processManager.schedule(UPDATE_FREQUENCY,this,this.onTimeOver);
         }
      }
      
      private function get initTime() : Number
      {
         return this.m_initTime;
      }
      
      private function set initTime(param1:Number) : void
      {
         this.m_initTime = param1;
      }
      
      public function isActive() : Boolean
      {
         var _loc2_:BuildingFSMComponent = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_ENERGYBOOSTER__LOWENERGY_POPUP) != ExperimentsManager.VARIANT_BUILDABLE_ENERGYBOOSTER__LOWENERGY_POPUP_ON)
         {
            return false;
         }
         var _loc1_:Boolean = false;
         this.gameEntity = ZGameUtils.getBuildingByCode(ENERGISER);
         if(this.gameEntity)
         {
            _loc2_ = BuildingFSMComponent(this.gameEntity.lookupComponentByType(BuildingFSMComponent));
            if(_loc2_.isBuilt)
            {
               _loc1_ = true;
            }
         }
         return _loc1_;
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
      
      public function showFirstDialog() : void
      {
         var _loc1_:AutoActionShowSpeechPopup = null;
         var _loc2_:AutoActionPlaceItem = null;
         _loc1_ = new AutoActionShowSpeechPopup();
         _loc1_.data = {"speechId":"Speech_Seabolt_Energiser_01"};
         _loc2_ = new AutoActionPlaceItem();
         _loc2_.data = {"item":ENERGISER};
         _loc1_.setNextAction(_loc2_);
         _loc1_.startAction();
      }
      
      public function fireTransaction() : void
      {
         var _loc1_:Transaction = new TSetEnergiserStarted(TRANSMITTER,this.m_position);
         TransactionManager.addTransaction(_loc1_);
         this.animationDone = true;
      }
      
      private function get animationDone() : Boolean
      {
         return this.m_animationDone;
      }
      
      private function set animationDone(param1:Boolean) : void
      {
         this.m_animationDone = param1;
      }
      
      private function placeTransmitter() : IEntity
      {
         var _loc2_:QuadSpatialManager = null;
         var _loc3_:IsoViewComponent = null;
         var _loc4_:IsoScene = null;
         var _loc5_:IslandWorld = null;
         var _loc6_:EntityInit = null;
         var _loc7_:GameDataComponent = null;
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(TRANSMITTER,GameItem) as GameItem;
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
      
      public function onQuestComplete(param1:WorldEvent) : void
      {
         UIDispatcher.instance.removeEventListener(QUEST_COMPLETE,this.onQuestComplete,true);
         this.m_popup = QuestCompletePopup(param1.eventData);
         if(this.m_popup)
         {
         }
         TransactionManager.addTransaction(new TEnergizerSetup(1));
         var _loc2_:AutoActionCallFunction = new AutoActionCallFunction();
         _loc2_.data = {"func":this.deInit};
         _loc2_.startAction();
      }
      
      public function showQuestCompleteDialog() : void
      {
         PopupManager.instance.push(this.m_popup);
      }
      
      public function onSpeechSeen() : void
      {
         var _loc2_:BehaviorStateMachine = null;
         var _loc3_:BehaviorState = null;
         var _loc4_:EnergyRefillItem = null;
         this.m_entity = ZGameUtils.getBuildingByCode(ENERGISER);
         var _loc1_:BuildingFSMComponent = BuildingFSMComponent(this.m_entity.lookupComponentByType(BuildingFSMComponent));
         if(_loc1_.isBuilt && Boolean(_loc1_.stateMachine))
         {
            _loc2_ = BehaviorStateMachine(_loc1_.stateMachine);
            _loc3_ = BehaviorState(_loc1_.stateMachine.currentState);
            if(Boolean(_loc2_.activatedState) && parseInt(_loc2_.activatedState) != parseInt(_loc3_.name))
            {
               _loc3_.clickNextState();
            }
            ZGlobal.player.m_energy.energizerMax = ENERGY_MAX;
            ZGlobal.player.m_energy.energyMax = ENERGY_MAX;
            _loc4_ = ZGlobal.gameSettings.getItemByCode(EnergyRefillItem.ITEM_CODE,EnergyRefillItem) as EnergyRefillItem;
            _loc4_.refillAmount = ZGlobal.player.m_energy.energyMax - ZGlobal.player.m_energy.energy;
            UI.instance.setupForItemPurchase();
            UIDispatcher.instance.dispatchEvent(new EnergyMarketEvent(MarketEvent.MARKET_BUY,MarketEvent.BOOSTER,"",MarketEvent.SOURCE_NONE,null,_loc4_));
            this.energyRefill = 1;
         }
      }
      
      public function showNotification() : void
      {
         EnergizerNotificationScreen.display();
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
      
      public function getResourceItem() : GameItem
      {
         var _loc3_:XML = null;
         var _loc4_:GameItem = null;
         var _loc1_:XMLList = ZGlobal.gameSettings.getItemsByType("energizer","supplies");
         var _loc2_:GameItem = null;
         for each(_loc3_ in _loc1_)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByName(_loc3_.@name,GameItem) as GameItem;
            if(ZGlobal.player.level >= _loc3_.requiredLevel[0])
            {
               if(ZGlobal.player.level <= _loc3_.maxLevel[0])
               {
                  _loc2_ = _loc4_;
               }
            }
         }
         return _loc2_;
      }
      
      public function deInit() : void
      {
         var _loc1_:AutoActionPanToEntity = null;
         var _loc2_:AutoActionShowSpeechPopup = null;
         var _loc3_:AutoActionPlayAnimationAtEntity = null;
         var _loc4_:AutoActionCallFunction = null;
         var _loc5_:AutoActionPanToEntity = null;
         _loc1_ = new AutoActionPanToEntity();
         _loc1_.data = {"target":ZGameUtils.getBuildingByCode(TRANSMITTER)};
         _loc2_ = new AutoActionShowSpeechPopup();
         _loc2_.data = {"speechId":"Speech_Seabolt_Energiser_02"};
         _loc4_ = new AutoActionCallFunction();
         _loc4_.data = {"func":this.removeEnergiserTransmitter};
         _loc5_ = new AutoActionPanToEntity();
         _loc5_.data = {"target":ZGameUtils.getBuildingByCode(ENERGISER)};
         var _loc6_:AutoActionCallFunction = new AutoActionCallFunction();
         _loc6_.data = {"func":this.onSpeechSeen};
         var _loc7_:AutoActionCallFunction = new AutoActionCallFunction();
         _loc7_.data = {"func":this.showNotification};
         _loc1_.setNextAction(_loc2_);
         _loc2_.setNextAction(_loc4_);
         _loc4_.setNextAction(_loc5_);
         _loc5_.setNextAction(_loc6_);
         _loc6_.setNextAction(_loc7_);
         _loc1_.startAction();
      }
      
      private function removeEnergiserTransmitter() : void
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(TRANSMITTER,GameItem) as GameItem;
         if(_loc1_)
         {
            this.gameEntity = ZGameUtils.getBuildingByCode(TRANSMITTER);
            WorldObjectManager.instance.removeObject(_loc1_.type,_loc1_.subType,this.gameEntity.name,TRANSMITTER,_loc1_.xml.@category);
            this.gameEntity.destroy();
            this.gameEntity = null;
         }
      }
      
      public function displayEnergizerToaster(param1:WorldEvent) : void
      {
         if(this.m_lowenergyPopupcounter > 2)
         {
            return;
         }
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Toaster_02");
         PlayerFeedbackManager.instance.displayFeedback(_loc2_);
         ++this.m_lowenergyPopupcounter;
      }
      
      public function displayEnergizerDeductToaster(param1:WorldEvent) : void
      {
         if(!this.isActive())
         {
            return;
         }
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Toaster_01");
         PlayerFeedbackManager.instance.displayFeedback(_loc2_);
      }
      
      public function deductEnergy(param1:int) : void
      {
         var _loc2_:int = ZGlobal.player.m_energy.energyMax - param1;
         if(param1 > 0 && _loc2_ >= ZGlobal.gameSettings.getInt("maxEnergy",100))
         {
            if(ZGlobal.player.m_energy.energy > _loc2_)
            {
               ZGlobal.player.m_energy.energy = _loc2_;
            }
            ZGlobal.player.m_energy.energizerMax = _loc2_;
            ZGlobal.player.m_energy.energyMax = _loc2_;
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DEDUCT_ENERGY_TOASTER));
         }
      }
      
      public function get energyRefill() : uint
      {
         return this.m_energyRefill;
      }
      
      public function set energyRefill(param1:uint) : void
      {
         this.m_energyRefill = param1;
      }
   }
}

