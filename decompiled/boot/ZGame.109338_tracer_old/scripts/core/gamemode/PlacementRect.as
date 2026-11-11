package core.gamemode
{
   import as3isolib.display.primitive.IsoRectangle;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import as3isolib.graphics.SolidColorFill;
   import as3isolib.graphics.Stroke;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import core.managers.warehouseManager.WarehouseHoverManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class PlacementRect
   {
      
      public static var instance:PlacementRect = new PlacementRect();
      
      private const FILL_NONE:int = 0;
      
      private const FILL_VALID:int = 1;
      
      private const FILL_INVALID:int = 2;
      
      private const FILL_WAREHOUSE:int = 3;
      
      private const MAXWIDTH:int = 5;
      
      private var m_invalidColor:SolidColorFill = null;
      
      private var m_invalidStroke:Stroke = null;
      
      private var m_validColor:SolidColorFill = null;
      
      private var m_validStroke:Stroke = null;
      
      private var m_warehouseColor:SolidColorFill = null;
      
      private var m_warehouseStroke:Stroke = null;
      
      private var m_rectangles:Array = null;
      
      private var m_placement:Array = null;
      
      private var m_direction:int = GameItem.DIRECTION_DEFAULT;
      
      private var m_canBuildOn:String = null;
      
      private var m_xLen:Number = 0;
      
      private var m_yLen:Number = 0;
      
      private var m_xBounds:int = 0;
      
      private var m_yBounds:int = 0;
      
      private var m_invalidated:Boolean = false;
      
      public function PlacementRect()
      {
         var _loc2_:IsoRectangle = null;
         super();
         this.m_rectangles = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < this.MAXWIDTH * this.MAXWIDTH)
         {
            _loc2_ = new IsoRectangle();
            _loc2_.data = this.FILL_NONE;
            _loc2_.width = ZGlobal.cellSize;
            _loc2_.length = ZGlobal.cellSize;
            this.m_rectangles.push(_loc2_);
            _loc1_++;
         }
         this.m_invalidColor = new SolidColorFill(16711680,0.5);
         this.m_invalidStroke = new Stroke(2,16711680,1);
         this.m_validColor = new SolidColorFill(65280,0.5);
         this.m_validStroke = new Stroke(2,65280,1);
         this.m_warehouseColor = new SolidColorFill(10092441,0.5);
         this.m_warehouseStroke = new Stroke(2,10092441,1);
      }
      
      public function set placementArray(param1:Array) : void
      {
         this.m_placement = param1;
      }
      
      public function set canBuildOn(param1:String) : void
      {
         this.m_canBuildOn = param1;
      }
      
      public function set direction(param1:int) : void
      {
         this.m_direction = param1;
         this.recalculate();
      }
      
      public function set position(param1:Object) : void
      {
         this.recalculate();
      }
      
      public function set active(param1:Boolean) : void
      {
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc3_:IsoScene = IsoScene(_loc2_.getSceneByID("gameScene"));
         var _loc4_:IsoRectangle = null;
         if(param1)
         {
            for each(_loc4_ in this.m_rectangles)
            {
               _loc3_.addChild(_loc4_);
            }
         }
         else
         {
            for each(_loc4_ in this.m_rectangles)
            {
               _loc3_.removeChild(_loc4_);
            }
         }
      }
      
      public function set bounds(param1:Pt) : void
      {
         var _loc4_:IsoRectangle = null;
         this.m_xLen = param1.x / ZGlobal.cellSize;
         this.m_yLen = param1.y / ZGlobal.cellSize;
         if(this.m_direction == GameItem.DIRECTION_NW || this.m_direction == GameItem.DIRECTION_SE)
         {
            this.m_xBounds = this.m_yLen;
            this.m_yBounds = this.m_xLen;
         }
         else
         {
            this.m_xBounds = this.m_xLen;
            this.m_yBounds = this.m_yLen;
         }
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_rectangles)
         {
            if(_loc2_ < this.m_xBounds && _loc3_ < this.m_yBounds)
            {
               _loc4_.container.visible = true;
            }
            else
            {
               _loc4_.container.visible = false;
            }
            if(++_loc2_ >= this.MAXWIDTH)
            {
               _loc2_ = 0;
               _loc3_++;
            }
         }
      }
      
      public function set invalidate(param1:Boolean) : void
      {
         this.m_invalidated = param1;
      }
      
      private function invalidateRect(param1:IsoRectangle) : void
      {
         if(param1.data != this.FILL_INVALID)
         {
            param1.data = this.FILL_INVALID;
            param1.fill = this.m_invalidColor;
            param1.stroke = this.m_invalidStroke;
         }
      }
      
      private function recalculate() : void
      {
         var _loc9_:IsoRectangle = null;
         var _loc10_:Point = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Point = new Point(0,0);
         var _loc4_:Point = BuildManager.instance.rawPlacementPosition;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         var _loc8_:Matrix = new Matrix();
         _loc8_.translate(-(this.m_xBounds * 0.5) + 0.5,-(this.m_yBounds * 0.5) + 0.5);
         _loc8_.rotate(GameItem.DIRECTION_ANGLES[this.m_direction]);
         for each(_loc9_ in this.m_rectangles)
         {
            if(_loc9_.container.visible)
            {
               _loc10_ = new Point(_loc1_,_loc2_);
               _loc10_ = _loc8_.transformPoint(_loc10_);
               _loc10_.x *= ZGlobal.cellSize;
               _loc10_.y *= ZGlobal.cellSize;
               _loc10_.x += _loc4_.x;
               _loc10_.y += _loc4_.y;
               _loc9_.moveTo(_loc10_.x,_loc10_.y,0);
               _loc3_.x = _loc10_.x;
               _loc3_.y = _loc10_.y;
               if(this.m_invalidated || !BuildManager.instance.isLocationValidForBuild(_loc3_,this.m_placement ? this.m_placement[_loc6_] : this.m_canBuildOn,_loc7_))
               {
                  this.invalidateRect(_loc9_);
               }
               else if(BuildManager.instance.getBuildType(_loc3_.x,_loc3_.y,BuildManager.instance.WAREHOUSE_AIR_STR) || BuildManager.instance.getBuildType(_loc3_.x,_loc3_.y,BuildManager.instance.WAREHOUSE_NAVY_STR) || BuildManager.instance.getBuildType(_loc3_.x,_loc3_.y,BuildManager.instance.WAREHOUSE_ARMY_STR))
               {
                  if(Boolean(WarehouseHoverManager.instance.cachedState) && Boolean(WarehouseHoverManager.instance.cachedState.validWarehousePlacement))
                  {
                     if(_loc9_.data != this.FILL_WAREHOUSE)
                     {
                        _loc9_.data = this.FILL_WAREHOUSE;
                        _loc9_.fill = this.m_warehouseColor;
                        _loc9_.stroke = this.m_warehouseStroke;
                     }
                  }
                  else
                  {
                     this.invalidateRect(_loc9_);
                  }
               }
               else if(_loc9_.data != this.FILL_VALID)
               {
                  _loc9_.data = this.FILL_VALID;
                  _loc9_.fill = this.m_validColor;
                  _loc9_.stroke = this.m_validStroke;
               }
               _loc6_++;
            }
            if(++_loc1_ >= this.MAXWIDTH)
            {
               _loc1_ = 0;
               _loc2_++;
            }
         }
      }
   }
}

