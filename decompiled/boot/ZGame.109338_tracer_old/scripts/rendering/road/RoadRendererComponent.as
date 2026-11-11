package rendering.road
{
   import core.ZGlobal;
   import core.gameobjects.RoadGameItem;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import rendering.renderingIso.SceneImageBlitComponent;
   import zlabs.entity.EntityComponent;
   
   public class RoadRendererComponent extends EntityComponent
   {
      
      public static var UPDATE_ROAD:String = "updateRoads";
      
      public var roadTileManager:RoadTileSetManager;
      
      public var m_roadLayout:Sprite = new Sprite();
      
      public function RoadRendererComponent()
      {
         super();
         this.roadTileManager = new RoadTileSetManager(this.m_roadLayout);
         this.roadTileManager.addEventListener(UPDATE_ROAD,this.updateRoads,false,0,true);
         this.roadTileManager.setMapSize(112,112);
      }
      
      override protected function onReset() : void
      {
         this.roadTileManager.reset();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
      }
      
      public function getSellDataObject(param1:int, param2:int) : RoadGameItem
      {
         var _loc3_:RoadGameItem = ZGlobal.gameSettings.getItemByName("Road",RoadGameItem) as RoadGameItem;
         _loc3_.x = param1;
         _loc3_.y = param2;
         return _loc3_;
      }
      
      private function updateRoads(param1:Event = null) : void
      {
         owner.eventDispatcher.dispatchEvent(new Event(SceneImageBlitComponent.BLIT_FORCE_UPDATE));
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.roadTileManager.removeEventListener(UPDATE_ROAD,this.updateRoads);
         this.roadTileManager.dispose();
         this.roadTileManager = null;
      }
      
      public function clearRoadAt(param1:int, param2:int) : Point
      {
         var _loc3_:Point = this.roadTileManager.sellRoadAt(param1,param2);
         if(_loc3_)
         {
            this.updateRoads();
         }
         return _loc3_;
      }
      
      public function clearAllRoads() : void
      {
         if(this.roadTileManager.clearAllRoads())
         {
            this.updateRoads();
         }
      }
      
      public function buildRoadTileSet(param1:Object) : void
      {
         this.roadTileManager.buildRoadTileSet(param1 as Array);
      }
      
      public function set loadRoadTileSet(param1:String) : void
      {
         this.roadTileManager.addEventListener(Event.COMPLETE,this.onRoadBuildComplete,false,0,true);
         this.roadTileManager.init(param1);
      }
      
      protected function onRoadBuildComplete(param1:Event) : void
      {
         this.roadTileManager.removeEventListener(Event.COMPLETE,this.onRoadBuildComplete);
      }
      
      public function drawMap() : void
      {
      }
   }
}

