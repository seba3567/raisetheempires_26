package core.worlds.islandworld
{
   import Engine.Managers.TransactionManager;
   import as3isolib.display.scene.IsoScene;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.gamemode.GameModeManager;
   import core.gamemode.GridPointer;
   import core.gameobjects.GameItem;
   import core.managers.BountyCenterManager;
   import core.managers.BuildManager;
   import core.managers.CommandoManager;
   import core.managers.CyclonePowerManager;
   import core.managers.ExperimentsManager;
   import core.managers.MatchMakingManager;
   import core.managers.MeteoriteMiningManager;
   import core.managers.NuclearPowerManager;
   import core.managers.PopulationManager;
   import core.managers.QuestBuildableManager;
   import core.managers.UnitDropManager;
   import core.managers.VolcanoPowerManager;
   import core.managers.VolcanoReskin6Manager;
   import core.managers.WorldGamesManager;
   import core.managers.WorldObjectManager;
   import core.managers.assetLoadTracker.AssetLoadTracker;
   import core.managers.mayhemManager.MayhemClock;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.views.ViewManager;
   import core.worlds.AbstractWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import core.worlds.islandworld.factory.IslandInit;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.geom.Point;
   import rendering.renderingIso.QuadSpatialManager;
   import rendering.renderingIso.SceneImageBlitComponent;
   import rendering.road.RoadRendererComponent;
   import transactions.TRemoveExtraWorldBuilding;
   import utils.ZGameRandom;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class IslandWorld extends AbstractWorld
   {
      
      public static const ID:String = "IslandWorld";
      
      protected var m_size:Point = new Point(200,200);
      
      private var m_globalId:int = 0;
      
      public function IslandWorld()
      {
         super(ID);
      }
      
      override public function initialize() : void
      {
         var _loc1_:IslandInit = new IslandInit();
         _loc1_.name = IslandWorld.ID;
         var _loc2_:PBGroup = Zlab.nameManager.lookup(ViewManager.VIEW_GROUP_NAME);
         var _loc3_:IslandViewFactory = new IslandViewFactory();
         var _loc4_:IEntity = _loc3_.create(_loc1_);
         _loc4_.owningGroup = _loc2_;
         ViewManager.instance.addView(_loc4_);
      }
      
      override public function loadObjects(param1:Object) : void
      {
         var _loc14_:IEntity = null;
         var _loc15_:Object = null;
         var _loc16_:GameItem = null;
         var _loc17_:EntityInit = null;
         var _loc18_:BuildingFSMComponent = null;
         var _loc19_:int = 0;
         var _loc20_:GameDataComponent = null;
         this.m_globalId = param1.globalObjectId;
         WorldObjectManager.instance.resetTypeDictionary();
         GridPointer.instance.addToWorld();
         PopulationManager.visitInstance.reset();
         GameModeManager.instance.setDefaultGameMode();
         if(Boolean(param1.sizeX) && Boolean(param1.sizeY))
         {
            this.m_size.x = param1.sizeX;
            this.m_size.y = param1.sizeY;
         }
         if(param1.ownerId == ZGlobal.player.uid)
         {
            WarehouseUnitManager.instance.clearAllUnits();
            ZGameRandom.instance.init(param1.randSeedW,param1.randSeedZ);
            UnitDropManager.instance.setWorldData(param1.unitDropData);
         }
         var _loc2_:IEntity = ViewManager.instance.getView(ID);
         var _loc3_:QuadSpatialManager = _loc2_.lookupComponentByName(IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
         var _loc4_:QuadSpatialManager = _loc2_.lookupComponentByName(IslandViewFactory.AREA_PAVING) as QuadSpatialManager;
         var _loc5_:IsoViewComponent = _loc2_.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         var _loc6_:IsoScene = IsoScene(_loc5_.getSceneByID("gameScene"));
         _loc3_.reset();
         _loc4_.reset();
         var _loc7_:SceneImageBlitComponent = _loc2_.lookupComponentByType(SceneImageBlitComponent) as SceneImageBlitComponent;
         if(_loc7_)
         {
            _loc7_.reset();
         }
         var _loc8_:AssetLoadTracker = new AssetLoadTracker();
         var _loc9_:IslandMapComponent = _loc2_.lookupComponentByType(IslandMapComponent) as IslandMapComponent;
         _loc9_.reset();
         if(param1["islands"] != null)
         {
            if(_loc9_)
            {
               _loc9_.create(param1.sizeX,param1.sizeY,param1.islands);
            }
         }
         var _loc10_:RoadRendererComponent = _loc2_.lookupComponentByType(RoadRendererComponent) as RoadRendererComponent;
         _loc10_.reset();
         if(param1["roadData"] != null)
         {
            if(_loc10_)
            {
               _loc10_.buildRoadTileSet(param1.roadData);
            }
         }
         WorldUnitManager.instance.init();
         var _loc11_:PBGroup = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         if(_loc11_ == null)
         {
            _loc11_ = new PBGroup();
            _loc11_.initialize(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         }
         ZGlobal.loadingStage = ZGlobal.LOADING_STAGE_OBJECTS;
         var _loc12_:uint = uint(param1.objects.length);
         var _loc13_:int = 0;
         for(; _loc13_ < _loc12_; _loc13_++)
         {
            _loc15_ = param1.objects[_loc13_];
            _loc16_ = ZGlobal.gameSettings.getItemByName(_loc15_.itemName,GameItem) as GameItem;
            if(null != _loc16_)
            {
               if(ZGlobal.isHome())
               {
                  if(ExperimentsManager.instance.getExperimentVariant("empire_remove_extra_building") == 3 || ExperimentsManager.instance.getExperimentVariant("empire_remove_extra_building") == 4)
                  {
                     if(Boolean(_loc16_.limit) && _loc16_.limit > 0)
                     {
                        _loc19_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc16_.code);
                        if(_loc19_ >= _loc16_.limit)
                        {
                           TransactionManager.addTransaction(new TRemoveExtraWorldBuilding(_loc15_.id));
                           continue;
                        }
                     }
                  }
               }
               _loc17_ = new EntityInit();
               _loc17_.m_isoScene = _loc6_;
               _loc17_.m_spatialComponent = _loc16_.usePavingQuadComponent() ? _loc4_ : _loc3_;
               _loc17_.m_item = _loc16_;
               _loc17_.m_object = _loc15_;
               _loc17_.m_group = _loc11_;
               _loc17_.m_assetLoadTracker = _loc8_;
               _loc14_ = BuildingEntity.createEntity(_loc17_);
               if(_loc15_.itemName == CommandoManager.NAME)
               {
                  _loc20_ = _loc14_.lookupComponentByType(GameDataComponent) as GameDataComponent;
                  CommandoManager.instance.init(_loc20_,_loc14_);
               }
               if(_loc16_.code == VolcanoPowerManager.BUILDING_CODE || _loc16_.code == WorldGamesManager.BUILDING_CODE || _loc16_.code == QuestBuildableManager.DIVE_SITE)
               {
                  BuildManager.instance.alwaysGetObject(_loc14_);
               }
               if(_loc16_.code == MeteoriteMiningManager.BUILDING_CODE)
               {
                  BuildManager.instance.alwaysGetObject(_loc14_);
               }
               if(_loc16_.ignoreExpansionEffects())
               {
                  BuildManager.instance.alwaysGetObject(_loc14_);
               }
               if(_loc16_.code == CyclonePowerManager.BUILDING_CODE)
               {
                  BuildManager.instance.alwaysGetObject(_loc14_);
               }
               if(_loc16_.code == NuclearPowerManager.BUILDING_CODE)
               {
                  BuildManager.instance.alwaysGetObject(_loc14_);
               }
               if(_loc16_.code == VolcanoReskin6Manager.BUILDING_CODE)
               {
                  BuildManager.instance.alwaysGetObject(_loc14_);
               }
               WorldObjectManager.instance.addObjectToCodeDictionary(_loc16_.code);
               WorldObjectManager.instance.addObjectToTypeDictionary(_loc16_.type,_loc16_.subType,_loc14_.name,_loc14_);
               WorldObjectManager.instance.addObjectToCategoryDictionary(_loc16_.categoryLimitName);
               _loc18_ = IEntity(_loc14_).lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
               if((Boolean(_loc18_)) && _loc18_.isBuilt)
               {
                  WorldObjectManager.instance.addObjectToBuiltDictionary(_loc16_.code);
               }
            }
            else
            {
               Logger.error(this,"loadObjects","can\'t find item named \'" + _loc15_.itemName + "\' in gameSettings, ignoring");
            }
         }
         ZGlobal.player.questTrees.loadWorldObjects();
         ZGlobal.loadingStage = ZGlobal.LOADING_STAGE_NONE;
         if(_loc9_)
         {
            _loc9_.setInitialViewParams();
         }
         _loc3_.onCullScene();
         _loc4_.onCullScene();
         _loc7_.onScrollStage(true);
         super.loadObjects(param1);
         if(param1.ownerId == ZGlobal.player.uid)
         {
            UnitDropManager.instance.updatePicks();
            MayhemClock.instance.show();
            BountyCenterManager.instance.refreshPicks();
            if(MatchMakingManager.instance.initialized)
            {
               MatchMakingManager.instance.showPick();
            }
         }
      }
      
      override public function releaseObjects() : void
      {
         GameModeManager.instance.setDefaultGameMode();
         GridPointer.instance.removeFromWorld();
         RewardPickupManager.instance.clear();
         this.prepareForObjectRelease();
         WorldUnitManager.instance.preInit();
         var _loc1_:PBGroup = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         if(_loc1_ != null)
         {
            _loc1_.destroy();
         }
      }
      
      private function prepareForObjectRelease() : void
      {
         BuildManager.instance.ignoreRemoves = true;
         var _loc1_:IEntity = ViewManager.instance.getView(ID);
         var _loc2_:QuadSpatialManager = _loc1_.lookupComponentByName(IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
         var _loc3_:QuadSpatialManager = _loc1_.lookupComponentByName(IslandViewFactory.AREA_PAVING) as QuadSpatialManager;
         _loc2_.ignoreRemoves = true;
         _loc3_.ignoreRemoves = true;
         AssetLoadTracker.GlobalDispatcher.dispatchEvent(new Event(AssetLoadTracker.RELEASE_OBJECTS));
      }
      
      public function getUniqueID() : int
      {
         ++this.m_globalId;
         return this.m_globalId;
      }
   }
}

