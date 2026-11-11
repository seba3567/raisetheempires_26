package core.worlds.islandworld.factory
{
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IsoScene;
   import core.ZGlobal;
   import core.entities.components.WorldMusicComponent;
   import core.gamemode.GridPointer;
   import core.gamemode.IsoOutlineRect;
   import core.gamemode.UnitDefenseRangeRect;
   import core.gameobjects.GameItem;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.views.ViewComponent;
   import core.worlds.islandworld.components.CineCameraComponent;
   import core.worlds.islandworld.components.IslandMapComponent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import rendering.renderingIso.QuadSpatialManager;
   import rendering.renderingIso.QuadTreeLayoutRenderer;
   import rendering.renderingIso.SceneImageBlitComponent;
   import rendering.road.RoadRendererComponent;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   import zlabs.utils.quadTree.QuadTree;
   
   public class IslandViewFactory
   {
      
      public static const AREA_PAVING:String = "area1";
      
      public static const AREA_OBJECTS:String = "area2";
      
      public function IslandViewFactory()
      {
         super();
      }
      
      public static function getQuadSpatialManagerNameFromItem(param1:GameItem) : String
      {
         return param1.usePavingQuadComponent() ? AREA_PAVING : AREA_OBJECTS;
      }
      
      public function create(param1:IslandInit) : IEntity
      {
         var _loc2_:IEntity = null;
         _loc2_ = Zlab.allocateEntity();
         var _loc3_:ViewComponent = new ViewComponent();
         _loc3_.rendererPropertyReference = new PropertyReference("@IsoView.isoView");
         _loc2_.addComponent(_loc3_,"ViewData");
         var _loc4_:IsoViewComponent = new IsoViewComponent();
         var _loc5_:IsoView = new IsoView();
         _loc4_.isoView = _loc5_ as IsoView;
         _loc4_.setSize(Zlab.mainStage.stageWidth,Zlab.mainStage.stageHeight);
         var _loc6_:String = ZGlobal.gameSettings.getString("cameraStartingPosition");
         var _loc7_:Point = StringUtils.parsePoint(_loc6_);
         _loc4_.isoView.centerOnPt(MathUtils.tileToWorld(_loc7_.x,_loc7_.y,0,ZGlobal.cellSize));
         _loc2_.addComponent(_loc4_,"IsoView");
         var _loc8_:IsoScene = _loc4_.createScene("gameScene",QuadTreeLayoutRenderer);
         var _loc9_:SceneImageBlitComponent = new SceneImageBlitComponent();
         _loc9_.isoViewPropRef = new PropertyReference("@IsoView.isoView");
         _loc9_.isoViewRectPropRef = new PropertyReference("@IsoView.viewRect");
         _loc9_.blitting = false;
         _loc2_.addComponent(_loc9_,"BackgroundBlit");
         var _loc10_:IslandMapComponent = new IslandMapComponent();
         _loc2_.addComponent(_loc10_,"IslandView");
         _loc9_.addBlittedItem(_loc10_.m_displaySprite);
         var _loc11_:RoadRendererComponent = new RoadRendererComponent();
         _loc11_.loadRoadTileSet = ZGlobal.getAssetURL("assets/game/roads/roads.swf");
         _loc2_.addComponent(_loc11_,"roadRenderer");
         _loc9_.addBlittedItem(_loc11_.m_roadLayout);
         var _loc12_:Rectangle = new Rectangle();
         _loc12_.width = 128;
         _loc12_.height = 128;
         var _loc13_:QuadSpatialManager = new QuadSpatialManager();
         _loc13_.quadTree = new QuadTree(_loc12_,4);
         QuadTreeLayoutRenderer(_loc8_.layoutRenderer).addAreaComponent(_loc13_);
         _loc2_.addComponent(_loc13_,AREA_PAVING);
         _loc13_ = new QuadSpatialManager();
         _loc13_.quadTree = new QuadTree(_loc12_,4);
         QuadTreeLayoutRenderer(_loc8_.layoutRenderer).addAreaComponent(_loc13_);
         _loc2_.addComponent(_loc13_,AREA_OBJECTS);
         var _loc14_:CineCameraComponent = new CineCameraComponent();
         _loc2_.addComponent(_loc14_,"cineCamera");
         var _loc15_:WorldMusicComponent = new WorldMusicComponent("islandmusic",true);
         _loc2_.addComponent(_loc15_,"music");
         _loc2_.initialize(param1.name);
         GridPointer.instance.init(_loc5_,_loc8_);
         RewardPickupManager.instance.init(_loc5_,_loc8_);
         IsoOutlineRect.init(_loc5_);
         UnitDefenseRangeRect.init(_loc5_);
         Zlab.processManager.addTickedObject(_loc4_);
         return _loc2_;
      }
      
      public function dispose() : void
      {
      }
   }
}

