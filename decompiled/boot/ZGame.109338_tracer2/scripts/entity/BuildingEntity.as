package entity
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.AreaImmuneComponent;
   import core.entities.components.AreaProtectorComponent;
   import core.entities.components.BuildFootprintComponent;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.CrewBuildingComponent;
   import core.entities.components.DecorationSourceComponent;
   import core.entities.components.DecorationTargetComponent;
   import core.entities.components.MegaUnitProgressBarComponent;
   import core.entities.components.OverlayComponent;
   import core.entities.components.PillageableComponent;
   import core.entities.components.ProgressBarComponent;
   import core.entities.components.ProtectableComponent;
   import core.entities.components.ProtectorComponent;
   import core.entities.components.TutorialArrowComponent;
   import core.entities.components.TutorialStencilComponent;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.UnitFSMComponent;
   import core.entities.components.VisitHostComponent;
   import core.entities.components.VisitHostCrewComponent;
   import core.entities.components.WorldUnitComponent;
   import core.entities.components.behaviors.BehaviorFactory;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gamemode.avatar.AvatarComponent;
   import core.gamemode.orders.OrdersComponent;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.gameobjects.UnitItem;
   import core.managers.CrewManager;
   import core.managers.CyclonePowerManager;
   import core.managers.MegaseriesManager;
   import core.managers.NuclearPowerManager;
   import core.managers.PVPManager;
   import core.managers.QuestBuildableManager;
   import core.managers.VolcanoReskin6Manager;
   import core.managers.WorldGamesManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.player.Player;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import misc.assetloading.AssetLoading_1x1;
   import misc.assetloading.AssetLoading_2x2;
   import misc.assetloading.AssetLoading_3x3;
   import rendering.rendering2d.AnimationCanvasComponent;
   import rendering.rendering2d.AnimationComponent;
   import rendering.rendering2d.GameArtComponent;
   import rendering.rendering2d.ImageModifierComponent;
   import rendering.rendering2d.loading.LoadingAnimationCanvasComponent;
   import rendering.rendering2d.loading.LoadingMovieComponent;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.rendering2D.spritesheet.SpriteContainerComponent;
   import zlabs.rendering.renderingISO.ISpatialManagerISO;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   import zlabs.utils.MathUtils;
   
   public class BuildingEntity
   {
      
      public function BuildingEntity()
      {
         super();
      }
      
      public static function createEntity(param1:EntityInit) : IEntity
      {
         var _loc24_:Array = null;
         var _loc25_:VisitHostComponent = null;
         var _loc26_:ProgressBarComponent = null;
         var _loc27_:OverlayComponent = null;
         var _loc28_:PillageableComponent = null;
         var _loc29_:ProtectableComponent = null;
         var _loc30_:AreaImmuneComponent = null;
         var _loc31_:AreaProtectorComponent = null;
         var _loc32_:Array = null;
         var _loc33_:ProtectorComponent = null;
         var _loc2_:GameItem = param1.m_item as GameItem;
         var _loc3_:String = _loc2_.subType;
         var _loc4_:String = _loc2_.name;
         var _loc5_:String = "entity_" + (param1.m_object ? param1.m_object.id : String(MathUtils.generateUniqueId()));
         var _loc6_:IEntity = param1.m_entity;
         if(!_loc6_)
         {
            _loc6_ = Zlab.allocateEntity();
         }
         var _loc7_:GameDataComponent = createGameDataComponent(_loc2_,param1,_loc6_);
         var _loc8_:GameArtComponent = createGameArtComponent(_loc2_,param1,_loc6_);
         _loc6_.addComponent(_loc8_,"Image");
         var _loc9_:IsoSpriteRenderer = new IsoSpriteRenderer();
         _loc9_.isoComponent = _loc8_ as SpriteContainerComponent;
         _loc9_.offsetReference = new PropertyReference("@Image.imageOffset");
         _loc9_.isometricVolumeReference = new PropertyReference("@IsoSpatial.volume");
         _loc9_.pickingAlphaThreshold(ZGlobal.gameSettings.getNumber("pickingAlphaThreshold"));
         _loc9_.isoSpritePropRef = new PropertyReference("@IsoSpriteRenderer.isoSprite");
         _loc6_.addComponent(_loc9_,"Renderer");
         var _loc10_:Point = new Point(param1.m_position.x,param1.m_position.y);
         var _loc11_:Pt = MathUtils.tileToWorld(_loc10_.x,_loc10_.y,0,ZGlobal.cellSize);
         if(param1.m_object)
         {
            _loc24_ = param1.m_object.position.split(",");
            _loc10_.x = _loc24_[0];
            _loc10_.y = _loc24_[1];
            _loc11_ = MathUtils.tileToWorld(_loc10_.x,_loc10_.y,0,ZGlobal.cellSize);
         }
         var _loc12_:BuildingSpatialComponent = new BuildingSpatialComponent(param1.m_spatialComponent,_loc2_);
         _loc12_.volume = MathUtils.tileToWorld(_loc2_.sizeX,_loc2_.sizeY,_loc2_.sizeZ,ZGlobal.cellSize);
         _loc12_.noRemove = true;
         _loc12_.position = MathUtils.convertPtToVector3D(_loc11_);
         _loc12_.noRemove = false;
         _loc12_.isoDisplayObjectReference = new PropertyReference("@IsoSpriteRenderer.isoSprite");
         _loc6_.addComponent(_loc12_,"IsoSpatial");
         var _loc13_:IsoSpriteComponent = new IsoSpriteComponent();
         _loc13_.isoSprite.id = _loc13_.isoSprite.id;
         _loc13_.isometricVolumeProperty = new PropertyReference("@IsoSpatial.volume");
         _loc13_.isometricDepthPropRef = new PropertyReference("@IsoSpatial.depth");
         _loc13_.isoSceneProperty = new PropertyReference("@IsoScene.isoScene");
         _loc13_.spriteLayerProperty = new PropertyReference("@Renderer.displayObject");
         _loc13_.xProperty = new PropertyReference("@IsoSpatial.x");
         _loc13_.yProperty = new PropertyReference("@IsoSpatial.y");
         _loc13_.zProperty = new PropertyReference("@IsoSpatial.z");
         _loc6_.addComponent(_loc13_,"IsoSpriteRenderer");
         createImageModifierComponent(_loc2_,_loc6_);
         var _loc14_:AnimationCanvasComponent = createAnimationComponents(_loc2_,_loc6_,_loc9_,param1);
         if(param1.m_fromLoad)
         {
            createLoadingAnim(_loc2_,_loc3_,_loc6_,_loc9_,_loc14_);
         }
         var _loc15_:Boolean = _loc2_.code == WorldGamesManager.BUILDING_CODE;
         var _loc16_:Boolean = _loc2_.code == QuestBuildableManager.DIVE_SITE;
         var _loc17_:Boolean = _loc2_.code == CyclonePowerManager.BUILDING_CODE;
         var _loc18_:Boolean = _loc2_.code == NuclearPowerManager.BUILDING_CODE;
         var _loc19_:Boolean = _loc2_.code == VolcanoReskin6Manager.BUILDING_CODE;
         var _loc20_:Boolean = _loc2_.code == DeathMatchManager.BUILDING_ITEMCODE;
         var _loc21_:UIControllerComponent = new UIControllerComponent(_loc2_.subType == "hook" || _loc2_.ignoreExpansionEffects() || _loc15_ || _loc16_ || _loc17_ || _loc18_ || _loc19_ || _loc20_);
         _loc21_.imageReference = new PropertyReference("@Renderer.displayObject");
         _loc21_.setGameData(_loc2_.name,_loc2_.defaultTooltip());
         _loc6_.addComponent(_loc21_,"controller");
         createUnitSpecificComponents(_loc2_,_loc3_,_loc6_,param1);
         var _loc22_:Boolean = CrewManager.isCrewBuilding(_loc6_) && CrewManager.hasCrewTendTemplate(_loc6_);
         if(ZGlobal.isVisiting() && PVPManager.instance.isNormalVisit())
         {
            if(_loc22_)
            {
               if(ZGlobal.hostPlayer.uid != Player.FAKE_PLAYER_ID)
               {
                  _loc25_ = new VisitHostCrewComponent(_loc7_.id);
               }
            }
            else
            {
               _loc25_ = new VisitHostComponent(_loc7_.id);
            }
            if(_loc25_)
            {
               _loc6_.addComponent(_loc25_,"VisitHostComponent");
            }
         }
         if(_loc22_)
         {
            _loc6_.addComponent(new CrewBuildingComponent(_loc7_.id),"CrewBuilding");
         }
         var _loc23_:BuildingFSMComponent = BuildingEntity.initializeBehaviors(_loc2_,_loc3_,param1.m_object);
         if(_loc23_)
         {
            if(_loc3_ != "plant" && _loc3_ != "rock")
            {
               _loc27_ = new OverlayComponent(param1);
               _loc6_.addComponent(_loc27_,"Overlay");
               _loc13_.overlayLayerProperty = new PropertyReference("@Overlay.sprite");
            }
            _loc26_ = getProgressBarComponent(param1);
            _loc26_.volumeProperty = new PropertyReference("@IsoSpatial.volume");
            _loc26_.gameDataProperty = new PropertyReference("@Data.gameData");
            _loc6_.addComponent(_loc26_,"ProgressBar");
            _loc13_.progressBarLayerProperty = new PropertyReference("@ProgressBar.sprite");
            _loc23_.currentState = new PropertyReference("@Data.state");
            _loc6_.addComponent(_loc23_,"StateMachine");
         }
         else
         {
            setInitialImage(_loc2_,_loc7_.direction,_loc8_,_loc14_);
         }
         if(_loc2_.pillageType)
         {
            _loc28_ = new PillageableComponent(param1);
            _loc6_.addComponent(_loc28_,"pillageable");
            _loc13_.pillageRewardProperty = new PropertyReference("@pillageable.sprite");
            _loc29_ = new ProtectableComponent();
            _loc6_.addComponent(_loc29_,"protectable");
            _loc13_.protectableProperty = new PropertyReference("@protectable.sprite");
            _loc30_ = new AreaImmuneComponent();
            _loc6_.addComponent(_loc30_,"area_immune");
            _loc13_.areaImmuneProperty = new PropertyReference("@area_immune.sprite");
         }
         if(_loc2_.isAreaImmunityBuilding())
         {
            _loc31_ = new AreaProtectorComponent();
            _loc6_.addComponent(_loc31_,"area_protector");
            _loc13_.areaProtectorProperty = new PropertyReference("@area_protector.sprite");
         }
         if(!ZGlobal.isVisiting())
         {
            if(DecorationsManager.instance.enabled)
            {
               if(_loc2_.isDecorationSource)
               {
                  _loc6_.addComponent(new DecorationSourceComponent(),"DecorationSourceComponent");
               }
               else
               {
                  _loc32_ = DecorationsManager.instance.getTargetTypesForGameItem(_loc2_);
                  if(_loc32_.length > 0)
                  {
                     _loc6_.addComponent(new DecorationTargetComponent(_loc32_),"DecorationTargetComponent");
                     _loc13_.decorationFeedbackSpriteProperty = new PropertyReference("@DecorationTargetComponent.sprite");
                  }
               }
            }
         }
         if(_loc3_ == UnitItem.AIR || _loc3_ == UnitItem.ARMY || _loc3_ == UnitItem.NAVY)
         {
            _loc33_ = new ProtectorComponent();
            _loc6_.addComponent(_loc33_,"protector");
            _loc13_.protectorProperty = new PropertyReference("@protector.sprite");
         }
         _loc13_.addToIsoScene(param1.m_isoScene,_loc12_.volume,_loc12_.x,_loc12_.y,_loc12_.z);
         if(null != param1.m_group)
         {
            _loc6_.owningGroup = param1.m_group;
         }
         _loc6_.initialize(_loc5_,_loc2_.name);
         if(shouldAddToSpatialManager(_loc2_))
         {
            _loc12_.spatialManager = Zlab.spatialManager as ISpatialManagerISO;
         }
         if(!ZGlobal.isVisiting() && _loc2_.megaseries != null && _loc2_.megaseries != "")
         {
            MegaseriesManager.instance.setBuildableEntity(_loc2_.megaseries,_loc6_);
         }
         return _loc6_;
      }
      
      private static function getProgressBarComponent(param1:EntityInit) : ProgressBarComponent
      {
         var _loc2_:GameItem = param1.m_item as GameItem;
         if(_loc2_.subType == GameItem.SUBTYPE_MEGA_UNIT)
         {
            return new MegaUnitProgressBarComponent();
         }
         return new ProgressBarComponent();
      }
      
      private static function shouldAddToSpatialManager(param1:GameItem) : Boolean
      {
         if(param1.type == "Avatar")
         {
            return false;
         }
         if(param1.type == "VisitorAvatar")
         {
            return false;
         }
         return true;
      }
      
      private static function createGameDataComponent(param1:GameItem, param2:EntityInit, param3:IEntity) : GameDataComponent
      {
         var _loc4_:GameDataComponent = new GameDataComponent(param2,param3);
         param3.addComponent(_loc4_,"Data");
         return _loc4_;
      }
      
      private static function createImageModifierComponent(param1:GameItem, param2:IEntity) : ImageModifierComponent
      {
         var _loc3_:ImageModifierComponent = null;
         if(param1.hasBouncyStates())
         {
            _loc3_ = new ImageModifierComponent();
            _loc3_.containerReference = new PropertyReference("@Renderer.displayObject");
            param2.addComponent(_loc3_,"imageModifier");
         }
         return _loc3_;
      }
      
      private static function createGameArtComponent(param1:GameItem, param2:EntityInit, param3:IEntity) : GameArtComponent
      {
         if(param2.m_assetLoadTracker)
         {
            param2.m_assetLoadTracker.addRef(param3.eventDispatcher as EventDispatcher);
         }
         return new GameArtComponent();
      }
      
      private static function createAnimationComponents(param1:GameItem, param2:IEntity, param3:IsoSpriteRenderer, param4:EntityInit) : AnimationCanvasComponent
      {
         var _loc6_:AnimationCanvasComponent = null;
         var _loc7_:int = 0;
         var _loc8_:AnimationComponent = null;
         var _loc5_:int = param1.maxAnimations();
         if(_loc5_ > 0)
         {
            _loc6_ = new AnimationCanvasComponent(param3.displayObject as Sprite,param4);
            param2.addComponent(_loc6_,"AnimationCanvas");
            _loc7_ = 0;
            while(_loc7_ < _loc5_)
            {
               _loc8_ = new AnimationComponent(param3);
               param2.addComponent(_loc8_,"animation" + _loc7_.toString());
               _loc6_.animations.push(_loc8_);
               _loc7_++;
            }
            return _loc6_;
         }
         return null;
      }
      
      private static function createLoadingAnim(param1:GameItem, param2:String, param3:IEntity, param4:IsoSpriteRenderer, param5:AnimationCanvasComponent) : void
      {
         var _loc6_:LoadingMovieComponent = null;
         if(param1.type == GameItem.TYPE_BUILDING || param2 == UnitItem.AIR || param2 == UnitItem.ARMY || param2 == UnitItem.NAVY)
         {
            if(null == param5)
            {
               param5 = new LoadingAnimationCanvasComponent(param4.displayObject as Sprite);
               param3.addComponent(param5,"AnimationCanvas");
            }
            _loc6_ = new LoadingMovieComponent(param4,param5);
            _loc6_.anchor = new Point(0,0);
            switch(int(param1.sizeX))
            {
               case 1:
                  _loc6_.animClass = AssetLoading_1x1;
                  break;
               case 2:
                  _loc6_.animClass = AssetLoading_2x2;
                  break;
               case 3:
                  _loc6_.animClass = AssetLoading_3x3;
                  break;
               default:
                  Logger.error(null,"createLoadingAnim","no loading asset for " + param1.code + " size: " + param1.sizeX);
            }
            param3.addComponent(_loc6_,"loadingMovie");
            param5.animations.push(_loc6_);
         }
      }
      
      private static function setInitialImage(param1:GameItem, param2:int, param3:GameArtComponent, param4:AnimationCanvasComponent) : void
      {
         var _loc6_:Array = null;
         var _loc5_:ItemImage = param1.getCachedImage(GameItem.DIRECTION_NAMES[param2]);
         param3.itemImage = _loc5_;
         if(param4)
         {
            _loc6_ = param1.getAnimations(GameItem.DIRECTION_NAMES[param2]);
            param4.animationData = _loc6_;
         }
      }
      
      private static function createUnitSpecificComponents(param1:GameItem, param2:String, param3:IEntity, param4:EntityInit) : void
      {
         var _loc5_:BuildFootprintComponent = null;
         createComponentsFromList(param1,param3,param4);
         if(param2 != "Avatar" && param2 != "VisitorAvatar" && param2 != "fleet")
         {
            if(!param1.zeroSize())
            {
               _loc5_ = new BuildFootprintComponent();
               _loc5_.volumePropertyReference = new PropertyReference("@IsoSpatial.volume");
               _loc5_.positionPropertyReference = new PropertyReference("@IsoSpatial.position");
               _loc5_.directionPropertyReference = new PropertyReference("@Data.direction");
               _loc5_.gameItemPropertyReference = new PropertyReference("@Data.gameData");
               _loc5_.fromLoad = param4.m_fromLoad;
               param3.addComponent(_loc5_,"footprint");
            }
         }
      }
      
      private static function createComponentsFromList(param1:GameItem, param2:IEntity, param3:EntityInit) : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:OrdersComponent = null;
         var _loc8_:EntityComponent = null;
         var _loc9_:TutorialArrowComponent = null;
         var _loc10_:WorldUnitComponent = null;
         var _loc11_:TutorialStencilComponent = null;
         var _loc12_:WarehouseComponent = null;
         var _loc4_:String = param1.components;
         if(_loc4_.length > 0)
         {
            _loc5_ = _loc4_.split(",");
            for each(_loc6_ in _loc5_)
            {
               if(_loc6_ == "OrdersComponent")
               {
                  _loc7_ = new OrdersComponent();
                  param2.addComponent(_loc7_,"ordersComponent");
               }
               else if(_loc6_ == "AvatarComponent")
               {
                  _loc8_ = new AvatarComponent();
                  param2.addComponent(_loc8_,"avatarComponent");
               }
               else if(_loc6_ == "TutorialArrowComponent")
               {
                  _loc9_ = new TutorialArrowComponent();
                  param2.addComponent(_loc9_,"tutorialArrow");
               }
               else if(_loc6_ == "WorldUnitComponent")
               {
                  _loc10_ = new WorldUnitComponent(param3);
                  param2.addComponent(_loc10_,"worldUnit");
               }
               else if(_loc6_ == "tutorialStencil")
               {
                  _loc11_ = new TutorialStencilComponent();
                  param2.addComponent(_loc11_,"tutorialStencil");
               }
               else if(_loc6_ == "WarehouseComponent")
               {
                  _loc12_ = new WarehouseComponent(param3);
                  param2.addComponent(_loc12_,"warehouse");
               }
            }
         }
      }
      
      public static function initializeBehaviors(param1:GameItem, param2:String, param3:Object) : BuildingFSMComponent
      {
         var _loc7_:GameItem = null;
         var _loc8_:String = null;
         var _loc9_:XML = null;
         var _loc10_:BehaviorStateInit = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:String = null;
         var _loc15_:Object = null;
         var _loc4_:BuildingFSMComponent = null;
         if(param2 == UnitItem.NAVY || param2 == UnitItem.ARMY || param2 == UnitItem.AIR || param2 == "Avatar" || param2 == "VisitorAvatar" || param2 == "fleet")
         {
            _loc4_ = new UnitFSMComponent();
         }
         else
         {
            _loc4_ = new BuildingFSMComponent();
         }
         var _loc5_:String = param1.getStateMachineName(null);
         var _loc6_:XMLList = ZGlobal.gameSettings.getStateMachine(_loc5_);
         if((Boolean(_loc6_)) && _loc6_.length() > 0)
         {
            _loc7_ = null;
            _loc8_ = null;
            if(!param1.isResearchItem())
            {
               if(Boolean(param3) && Boolean(param3.referenceItem))
               {
                  _loc7_ = ZGlobal.gameSettings.getItemByCode(param3.referenceItem,GameItem) as GameItem;
                  if(_loc7_)
                  {
                     _loc8_ = _loc7_.name;
                  }
               }
               _loc4_.stateMachine = new BehaviorStateMachine(_loc8_,_loc6_);
            }
            if(param1.isSuperOre())
            {
               _loc11_ = null;
               _loc12_ = 1;
               if(Boolean(param3) && Boolean(param3.referenceItem))
               {
                  _loc13_ = deserializeResourceString(param3.referenceItem);
                  if(_loc13_)
                  {
                     _loc11_ = _loc13_.resourceName;
                     _loc8_ = _loc13_.referenceItemName;
                     _loc12_ = int(_loc13_.multiplier);
                  }
               }
               _loc4_.stateMachine = new BehaviorStateMachine(_loc8_,_loc6_);
               BehaviorStateMachine(_loc4_.stateMachine).resourceType = _loc11_;
               BehaviorStateMachine(_loc4_.stateMachine).multiplier = _loc12_;
            }
            else
            {
               _loc14_ = null;
               if(Boolean(param3) && Boolean(param3.referenceItem))
               {
                  _loc15_ = deserializeResearchString(param3.referenceItem);
                  if(_loc15_)
                  {
                     _loc14_ = _loc15_.researchItemName;
                     _loc8_ = _loc15_.referenceItemName;
                  }
               }
               _loc4_.stateMachine = new BehaviorStateMachine(_loc8_,_loc6_,_loc14_);
            }
            _loc9_ = _loc6_[0];
            _loc10_ = new BehaviorStateInit();
            _loc10_.m_machine = _loc4_.stateMachine;
            _loc10_.m_gameItem = param1;
            _loc10_.m_behaviorData = _loc9_;
            _loc10_.m_gameObject = param3;
            BehaviorFactory.createBehavior(_loc10_);
            return _loc4_;
         }
         return null;
      }
      
      public static function deserializeResearchString(param1:String) : Object
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         if(!param1 || !param1.length)
         {
            return null;
         }
         var _loc5_:Array = param1.split(":");
         if(_loc5_.length < 2)
         {
            return null;
         }
         if(_loc5_.length > 1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc5_[1],GameItem) as GameItem;
            if(_loc4_)
            {
               _loc3_ = _loc4_.name;
            }
         }
         _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc5_[0],GameItem) as GameItem;
         if(_loc4_)
         {
            _loc2_ = _loc4_.name;
         }
         return {
            "referenceItemName":_loc2_,
            "researchItemName":_loc3_
         };
      }
      
      public static function deserializeResourceString(param1:String) : Object
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:int = 1;
         if(!param1 || !param1.length)
         {
            return null;
         }
         var _loc6_:Array = param1.split(":");
         if(_loc6_.length < 3)
         {
            return null;
         }
         if(_loc6_.length > 2)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc6_[0],GameItem) as GameItem;
            if(_loc4_)
            {
               _loc2_ = _loc4_.name;
            }
         }
         _loc3_ = _loc6_[1];
         _loc5_ = parseInt(_loc6_[2]);
         return {
            "referenceItemName":_loc2_,
            "resourceName":_loc3_,
            "multiplier":_loc5_
         };
      }
   }
}

