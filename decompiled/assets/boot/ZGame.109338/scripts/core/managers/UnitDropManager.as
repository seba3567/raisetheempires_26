package core.managers
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.MysteryUnitMarkerComponent;
   import core.entities.components.UnitDropRevealComponent;
   import core.entities.components.WorldUnitComponent;
   import core.gameobjects.GameItem;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import dispatchers.StrategicDispatcher;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.SurveillanceScanResultPopup;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Vector3D;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TUnitDropRevealAll;
   import transactions.TUnitDropSwitchUnit;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class UnitDropManager extends EventDispatcher
   {
      
      public static var instance:UnitDropManager;
      
      public static const REMOVE_ALL_UNITS:String = "remove_all_units";
      
      public static const SWITCH_UNIT_COST:int = 12;
      
      private var m_worldData:Object;
      
      private var m_unitPlaceholders:Object = {
         "air":"PU10",
         "army":"PU11",
         "navy":"PU12"
      };
      
      private const INVALID_OBJID:int = -1;
      
      public const UNIT_RARITY_STANDARD:String = "standard";
      
      public const UNIT_RARITY_RARE:String = "rare";
      
      public function UnitDropManager()
      {
         super();
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete,false,0,true);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.EXPANSION_PURCHASED,this.onExpansionPurchased);
      }
      
      public static function initialize() : void
      {
         instance = new UnitDropManager();
         instance.addEventListener(REMOVE_ALL_UNITS,instance.removeAllUnits);
      }
      
      public function setWorldData(param1:Object) : void
      {
         this.m_worldData = param1;
      }
      
      public function get worldData() : Object
      {
         return this.m_worldData;
      }
      
      private function getUnclaimedUnit(param1:int) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_worldData.unclaimedUnits)
         {
            if(_loc2_.objID == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function removeAllUnits(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:IEntity = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:BuildingSpatialComponent = null;
         var _loc7_:Vector3D = null;
         var _loc8_:GameItem = null;
         for each(_loc2_ in this.m_worldData.unclaimedUnits)
         {
            _loc3_ = int(_loc2_.objID);
            _loc4_ = ZGlobal.game.getObjectByID(_loc3_);
            _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
            _loc6_ = BuildingSpatialComponent(_loc4_.lookupComponentByType(BuildingSpatialComponent));
            _loc7_ = TileUtil.worldToTile(_loc6_.position);
            _loc8_ = _loc5_.gameData;
            WorldObjectManager.instance.removeObject(_loc8_.type,_loc8_.subType,_loc4_.name,_loc8_.code,_loc8_.categoryLimitName);
            _loc4_.destroy();
         }
         this.m_worldData.unclaimedUnits = new Array();
      }
      
      private function replaceObject(param1:int, param2:String) : int
      {
         var _loc3_:IEntity = ZGlobal.game.getObjectByID(param1);
         var _loc4_:GameDataComponent = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
         var _loc5_:BuildingSpatialComponent = BuildingSpatialComponent(_loc3_.lookupComponentByType(BuildingSpatialComponent));
         var _loc6_:Vector3D = TileUtil.worldToTile(_loc5_.position);
         var _loc7_:GameItem = _loc4_.gameData;
         WorldObjectManager.instance.removeObject(_loc7_.type,_loc7_.subType,_loc3_.name,_loc7_.code,_loc7_.categoryLimitName);
         _loc3_.destroy();
         var _loc8_:IslandWorld = ZGlobal.game.getWorld(IslandWorld.ID) as IslandWorld;
         var _loc9_:int = _loc8_.getUniqueID();
         var _loc10_:GameItem = ZGlobal.gameSettings.getItemByCode(param2,GameItem) as GameItem;
         var _loc11_:IEntity = ViewManager.instance.getView(IslandWorld.ID);
         var _loc12_:IsoViewComponent = _loc11_.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         var _loc13_:IsoScene = IsoScene(_loc12_.getSceneByID("gameScene"));
         var _loc14_:QuadSpatialManager = _loc11_.lookupComponentByName(IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
         var _loc15_:PBGroup = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         var _loc16_:EntityInit = new EntityInit();
         _loc16_.m_isoScene = _loc13_;
         _loc16_.m_spatialComponent = _loc14_;
         _loc16_.m_item = _loc10_;
         _loc16_.m_group = _loc15_;
         _loc16_.m_object = {
            "id":_loc9_,
            "position":_loc6_.x + "," + _loc6_.y
         };
         _loc16_.m_position = new Pt(_loc6_.x,_loc6_.y);
         var _loc17_:IEntity = BuildingEntity.createEntity(_loc16_);
         WorldObjectManager.instance.addObjectToCodeDictionary(_loc10_.code);
         WorldObjectManager.instance.addObjectToTypeDictionary(_loc10_.type,_loc10_.subType,_loc17_.name,_loc17_);
         WorldObjectManager.instance.addObjectToCategoryDictionary(_loc10_.categoryLimitName);
         return _loc9_;
      }
      
      private function revealUnit(param1:int) : int
      {
         var _loc2_:Object = this.getUnclaimedUnit(param1);
         if(!_loc2_)
         {
            return this.INVALID_OBJID;
         }
         if(_loc2_.revealed)
         {
            return this.INVALID_OBJID;
         }
         var _loc3_:String = _loc2_.unitCodes[0];
         _loc2_.objID = this.replaceObject(param1,_loc3_);
         _loc2_.revealed = true;
         var _loc4_:IEntity = ZGlobal.game.getObjectByID(_loc2_.objID);
         _loc4_.addComponent(new UnitDropRevealComponent(),"UnitDropRevealComponent");
         var _loc5_:WorldUnitComponent = _loc4_.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
         var _loc6_:GameDataComponent = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
         WorldUnitManager.instance.holdUnitByComponent(_loc5_,_loc6_.gameData.code,WorldUnitManager.UNIT_UNCLAIMED);
         return _loc2_.objID;
      }
      
      private function onExpansionPurchased(param1:WorldEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:Object = null;
         var _loc7_:IEntity = null;
         var _loc8_:WorldUnitComponent = null;
         var _loc9_:GameDataComponent = null;
         var _loc10_:IEntityComponent = null;
         var _loc11_:String = null;
         var _loc12_:Object = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:ExpansionItem = null;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         if(this.m_worldData.unclaimedUnits != undefined)
         {
            _loc4_ = int(param1.eventData.expansionIndex);
            _loc5_ = 0;
            while(_loc5_ < this.m_worldData.unclaimedUnits.length)
            {
               _loc6_ = this.m_worldData.unclaimedUnits[_loc5_];
               if(_loc6_.expIdx == _loc4_)
               {
                  if(!_loc6_.revealed)
                  {
                     this.revealUnit(_loc6_.objID);
                  }
                  _loc7_ = ZGlobal.game.getObjectByID(_loc6_.objID);
                  _loc8_ = _loc7_.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
                  _loc9_ = GameDataComponent(_loc7_.lookupComponentByType(GameDataComponent));
                  WorldUnitManager.instance.releaseUnitByComponent(_loc8_,_loc9_.gameData.code);
                  _loc3_ = _loc9_.gameData.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
                  this.m_worldData.unclaimedUnits.splice(_loc5_--,1);
                  _loc10_ = _loc7_.lookupComponentByName("MysteryPick");
                  if(_loc10_)
                  {
                     _loc7_.removeComponent(_loc10_);
                  }
               }
               _loc5_++;
            }
         }
         if(_loc3_ != null)
         {
            _loc11_ = ZGameUtils.ZlocT("Dialogs","Capture_unit_Title");
            _loc12_ = new Object();
            _loc12_["Unit Name"] = _loc3_;
            _loc13_ = ZGameUtils.ZlocT("Dialogs","Capture_unit_Desc",_loc12_);
            _loc14_ = ZGameUtils.ZlocT("Dialogs","Found_unit_Button");
            PopupManager.instance.push(new SurveillanceScanResultPopup(_loc11_,_loc13_,_loc14_));
         }
         else if(param1.eventData.expansionItemCode)
         {
            _loc15_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.expansionItemCode,ExpansionItem) as ExpansionItem;
            if(_loc15_)
            {
               _loc16_ = ZGameUtils.ZlocT("Dialogs","Expansion_Message");
               _loc17_ = ZGameUtils.ZlocT("Dialogs","Expansion_Title");
               _loc18_ = ZGameUtils.ZlocT("Dialogs","OkButton");
               PopupManager.instance.push(new FeedPopup(_loc16_,_loc17_,_loc18_,GenericPopup.TYPE_OK,null,_loc15_.getCachedImage("icon").url));
            }
         }
      }
      
      public function revealAll() : Array
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         TransactionManager.addTransaction(new TUnitDropRevealAll());
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         if(this.m_worldData.unclaimedUnits != undefined)
         {
            for each(_loc3_ in this.m_worldData.unclaimedUnits)
            {
               if(!_loc3_.revealed)
               {
                  _loc4_ = this.revealUnit(_loc3_.objID);
                  if(_loc4_ != this.INVALID_OBJID)
                  {
                     _loc1_.push(_loc4_);
                  }
               }
            }
         }
         this.updatePicks();
         return _loc1_;
      }
      
      public function switchUnit(param1:int) : int
      {
         var _loc3_:String = null;
         var _loc4_:IEntity = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:GameItem = null;
         var _loc7_:String = null;
         var _loc2_:Object = this.getUnclaimedUnit(param1);
         if(!_loc2_)
         {
            return this.INVALID_OBJID;
         }
         if(!_loc2_.revealed)
         {
            return this.INVALID_OBJID;
         }
         if(this.switchFreeEnabled || ZGlobal.player.canBuyCash(SWITCH_UNIT_COST))
         {
            TransactionManager.addTransaction(new TUnitDropSwitchUnit(param1));
            _loc3_ = _loc2_.unitCodes[0];
            _loc2_.unitCodes.splice(0,1);
            _loc2_.unitCodes.push(_loc3_);
            _loc4_ = ZGlobal.game.getObjectByID(param1);
            _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
            _loc6_ = _loc5_.gameData;
            _loc7_ = this.m_unitPlaceholders[_loc6_.subType];
            _loc2_.objID = this.replaceObject(param1,_loc7_);
            _loc2_.revealed = false;
            if(!this.switchFreeEnabled)
            {
               ZGlobal.player.cash -= SWITCH_UNIT_COST;
            }
            this.updatePicks();
            return _loc2_.objID;
         }
         return this.INVALID_OBJID;
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
      }
      
      public function updatePicks() : void
      {
         var _loc1_:Object = null;
         var _loc2_:IEntityComponent = null;
         var _loc3_:IEntity = null;
         var _loc4_:Boolean = false;
         var _loc5_:GameDataComponent = null;
         if(this.worldData)
         {
            for each(_loc1_ in this.worldData.unclaimedUnits)
            {
               if(!(_loc1_.objID == undefined || _loc1_.revealed == undefined || _loc1_.rarity == undefined))
               {
                  _loc3_ = ZGlobal.game.getObjectByID(_loc1_.objID);
                  if(_loc3_)
                  {
                     _loc4_ = _loc1_.rarity == this.UNIT_RARITY_RARE;
                     if(_loc1_.revealed)
                     {
                        _loc2_ = _loc3_.lookupComponentByName("MysteryPick");
                        if(_loc2_)
                        {
                           _loc3_.removeComponent(_loc2_);
                        }
                        _loc5_ = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
                        if(_loc5_)
                        {
                           _loc3_.addComponent(new MysteryUnitMarkerComponent(_loc5_,_loc4_),"MysteryPick");
                        }
                     }
                     else
                     {
                        _loc2_ = _loc3_.lookupComponentByName("MysteryPick");
                        if(!_loc2_)
                        {
                           _loc3_.addComponent(new MysteryUnitMarkerComponent(null,_loc4_),"MysteryPick");
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function get numUnrevealedUnits() : uint
      {
         var _loc2_:Object = null;
         var _loc1_:uint = 0;
         for each(_loc2_ in this.worldData.unclaimedUnits)
         {
            if(!_loc2_.revealed)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get switchFreeEnabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MYSTERYUNIT_SWITCH_FREE);
         return _loc1_ == ExperimentsManager.EXPERIMENT_MYSTERYUNIT_SWITCH_FREE_ENABLED;
      }
   }
}

