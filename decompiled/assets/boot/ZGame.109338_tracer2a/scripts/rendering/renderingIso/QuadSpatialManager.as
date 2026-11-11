package rendering.renderingIso
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import eDpLib.events.ProxyEvent;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.managers.IAreaMapManager;
   import zlabs.managers.IPositionItem;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.geom.Polygon2D;
   import zlabs.utils.quadTree.QuadTree;
   import zlabs.utils.quadTree.QuadTreePositionItem;
   
   public class QuadSpatialManager extends EntityComponent implements IAreaMapManager
   {
      
      public var isoViewRect:PropertyReference = null;
      
      public var quadTree:QuadTree;
      
      private var inSceneList:Array;
      
      private var inserted:int = 0;
      
      private var isoViewComp:IsoViewComponent;
      
      private var cullPoly:Polygon2D = new Polygon2D();
      
      public var gridScale:Number;
      
      public var ignoreRemoves:Boolean;
      
      public function QuadSpatialManager()
      {
         super();
         this.gridScale = ZGlobal.cellSizeM;
         this.inSceneList = new Array();
      }
      
      public static function getQuadSpatialManagerFromWorld(param1:String, param2:GameItem) : QuadSpatialManager
      {
         return ViewManager.instance.getComponentFromName(param1,IslandViewFactory.getQuadSpatialManagerNameFromItem(param2)) as QuadSpatialManager;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(FullScreenEvent.FULL_SCREEN,this.onCullScene,false,0,true);
         owner.eventDispatcher.addEventListener(IsoViewComponent.UPDATE_VIEW,this.onCullScene,false,0,true);
         owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onCullScene,false,0,true);
         owner.eventDispatcher.addEventListener(ViewManager.DEACTIVATE,this.onDeactivate,false,0,true);
         this.isoViewComp = owner.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
      }
      
      override protected function onReset() : void
      {
         super.onReset();
         this.quadTree.reset();
         this.inSceneList.length = 0;
         this.ignoreRemoves = false;
      }
      
      override protected function onRemove() : void
      {
         owner.eventDispatcher.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onCullScene);
         owner.eventDispatcher.removeEventListener(IsoViewComponent.UPDATE_VIEW,this.onCullScene);
         owner.eventDispatcher.removeEventListener(ViewManager.ACTIVATE,this.onCullScene);
         owner.eventDispatcher.removeEventListener(ViewManager.DEACTIVATE,this.onDeactivate);
         this.quadTree.destroy();
         this.quadTree = null;
         this.isoViewComp = null;
         this.inSceneList.length = 0;
         this.inSceneList = null;
      }
      
      public function getScreenTileRect(param1:Pt = null) : Rectangle
      {
         var _loc2_:IsoViewComponent = owner.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         var _loc3_:Rectangle = _loc2_.screenRectToIso(param1);
         return this.convertScreenRectToTileSpace(_loc3_,ZGlobal.cellSize);
      }
      
      public function getScreenTilePoly(param1:Pt = null) : Polygon2D
      {
         this.cullPoly.clear();
         var _loc2_:Polygon2D = this.isoViewComp.screenRectToPoly(this.cullPoly);
         _loc2_.scale(ZGlobal.cellSizeM);
         return _loc2_;
      }
      
      public function getUnCulledItems() : Array
      {
         return this.inSceneList;
      }
      
      private function onDeactivate(param1:Event) : void
      {
         var _loc2_:Vector3D = new Vector3D(0,0,0);
         this.cullPoly.clear();
         this.cullPoly.addPoint(_loc2_);
         this.cullPoly.addPoint(_loc2_);
         this.cullPoly.addPoint(_loc2_);
         this.cullPoly.addPoint(_loc2_);
         this.inSceneList.length = 0;
         this.quadTree.setItemState(this.cullPoly,this.inSceneList);
      }
      
      public function onCullScene(param1:Event = null) : void
      {
         if(param1 is ProxyEvent || this.inserted == 0)
         {
            return;
         }
         this.cullPoly.clear();
         this.isoViewComp.screenRectToPoly(this.cullPoly);
         this.cullPoly.scale(ZGlobal.cellSizeM);
         this.inSceneList.length = 0;
         this.quadTree.setItemState(this.cullPoly,this.inSceneList);
      }
      
      private function convertScreenRectToTileSpace(param1:Rectangle, param2:int) : Rectangle
      {
         var _loc3_:Rectangle = new Rectangle();
         _loc3_.x = int(param1.x / param2);
         _loc3_.y = int(param1.y / param2);
         _loc3_.width = int(param1.width / param2);
         _loc3_.height = int(param1.height / param2);
         return _loc3_;
      }
      
      public function insert(param1:IPositionItem, param2:Boolean = false) : void
      {
         this.inserted |= 1;
         this.quadTree.insert(param1 as QuadTreePositionItem);
         if(param2)
         {
            this.inSceneList.push(param1);
         }
      }
      
      public function removeItem(param1:IPositionItem) : Boolean
      {
         if(!this.ignoreRemoves)
         {
            return this.quadTree.removeFromQuadTree(param1 as QuadTreePositionItem);
         }
         return false;
      }
      
      public function getItemsUnderRect(param1:Rectangle, param2:Array, param3:Array) : void
      {
         this.quadTree.getItems(param1,param2);
      }
      
      public function getAllItems(param1:Array) : void
      {
         this.quadTree.getAllItems(param1);
      }
      
      public function scalar(param1:Number) : int
      {
         return int(this.gridScale * param1);
      }
   }
}

