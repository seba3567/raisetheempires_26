package core.gamemode.helpers
{
   import as3isolib.display.primitive.IsoRectangle;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import as3isolib.graphics.BitmapFill;
   import as3isolib.graphics.SolidColorFill;
   import as3isolib.graphics.Stroke;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import rendering.road.RoadRendererComponent;
   import rendering.road.RoadTileSetManager;
   import utils.ZGameConfig;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class RoadPlacementProxy
   {
      
      private static var MOVE:int = 0;
      
      private static var PLACE:int = 1;
      
      private var m_invalidColor:SolidColorFill = null;
      
      private var m_invalidStroke:Stroke = null;
      
      private var m_validColor:SolidColorFill = null;
      
      private var m_validStroke:Stroke = null;
      
      private var m_rectangles:Array = null;
      
      private var m_usedRectangles:Array = null;
      
      private var m_scene:String = "";
      
      private var m_invalidated:Boolean = false;
      
      private var m_lastLength:Number = -1;
      
      private var m_placementArray:Array = null;
      
      private var m_validBitmapFill:BitmapFill;
      
      private var m_inValidBitmapFill:BitmapFill;
      
      private var m_roadCost:Number = 1;
      
      private var m_isValid:Boolean = false;
      
      private var m_existingRoadPos:Pt;
      
      private var m_movingRoad:Boolean = false;
      
      private var m_type:int;
      
      public function RoadPlacementProxy(param1:String, param2:Pt = null, param3:Boolean = false)
      {
         var _loc7_:IsoRectangle = null;
         super();
         this.m_existingRoadPos = param2;
         this.m_type = param2 ? MOVE : PLACE;
         this.m_scene = param1;
         this.m_movingRoad = param3;
         this.m_invalidColor = new SolidColorFill(ZGameConfig.INVALID_COLOR,0.5);
         this.m_invalidStroke = new Stroke(2,ZGameConfig.INVALID_COLOR,1);
         this.m_validColor = new SolidColorFill(ZGameConfig.VALID_COLOR,0.5);
         this.m_validStroke = new Stroke(2,ZGameConfig.VALID_COLOR,1);
         var _loc4_:ColorTransform = new ColorTransform(0.671875,0.671875,0.671875,1,84,0,0,0);
         var _loc5_:ColorTransform = new ColorTransform(0.671875,0.671875,0.671875,1,0,84,0,0);
         this.m_rectangles = new Array();
         this.m_usedRectangles = new Array();
         this.m_placementArray = new Array();
         var _loc6_:int = 0;
         while(_loc6_ < 50)
         {
            _loc7_ = new IsoRectangle();
            _loc7_.width = ZGlobal.cellSize;
            _loc7_.length = ZGlobal.cellSize;
            _loc7_.fill = this.m_invalidColor;
            _loc7_.stroke = this.m_invalidStroke;
            this.m_rectangles.push(_loc7_);
            _loc6_++;
         }
      }
      
      public static function isLocationValidForBuild(param1:Point, param2:IslandMapComponent) : Boolean
      {
         return BuildManager.instance.isLocationValidForBuild(param1.clone(),BuildManager.instance.LAND_OR_ROAD_STR,param2);
      }
      
      public function set invalidate(param1:Boolean) : void
      {
         this.m_invalidated = param1;
      }
      
      public function isPositionValid(param1:Point) : Boolean
      {
         var _loc2_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         if(!isLocationValidForBuild(param1,_loc2_))
         {
            return false;
         }
         return true;
      }
      
      public function get isValid() : Boolean
      {
         return this.m_isValid;
      }
      
      private function getRect() : IsoRectangle
      {
         var _loc1_:IsoRectangle = null;
         if(this.m_rectangles.length == 0)
         {
            this.m_rectangles.push(new IsoRectangle());
         }
         _loc1_ = this.m_rectangles.pop();
         this.m_usedRectangles.push(_loc1_);
         return _loc1_;
      }
      
      public function removeAllRectFromScene() : void
      {
         var _loc2_:IsoRectangle = null;
         var _loc1_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         for each(_loc2_ in this.m_usedRectangles)
         {
            this.m_rectangles.push(_loc1_.removeGameChild(_loc2_));
         }
         this.m_usedRectangles.length = 0;
      }
      
      public function drawLine(param1:Point, param2:Point, param3:Boolean = false) : int
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = param1.add(param2).length;
         if(_loc5_ != this.m_lastLength || param3 == true)
         {
            this.m_isValid = false;
            this.removeAllRectFromScene();
            this.m_placementArray.length = 0;
            this.m_placementArray = new Array();
            _loc6_ = RoadTileSetManager.drawStraightLine(param1,param2,this.m_placementArray,ZGlobal.cellSize);
            this.m_isValid = this.validateLine(_loc6_);
            _loc7_ = 0;
            while(_loc7_ < this.m_placementArray.length)
            {
               this.createObjectAtPosition(this.m_placementArray[_loc7_],this.m_isValid);
               _loc7_++;
            }
            if(Boolean(this.m_isValid == true) && Boolean(_loc6_) && _loc4_ == 0)
            {
               _loc4_ = this.priceLine(_loc6_);
            }
            this.m_lastLength = _loc5_;
         }
         return _loc4_;
      }
      
      private function validateLine(param1:Array) : Boolean
      {
         var _loc6_:Point = null;
         if(ZGlobal.player.coins <= 0)
         {
            return false;
         }
         var _loc2_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(!isLocationValidForBuild(param1[_loc3_],_loc2_))
            {
               return false;
            }
            _loc3_++;
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc6_ = BuildManager.instance.convertToCell(param1[_loc5_].clone());
            if(BuildManager.instance.getBuildType(_loc6_.x,_loc6_.y,BuildManager.instance.ROAD_STR))
            {
               if(this.m_type == PLACE)
               {
                  return false;
               }
            }
            else
            {
               _loc4_++;
            }
            _loc5_++;
         }
         if(!this.validateTotal(_loc4_))
         {
            return false;
         }
         return true;
      }
      
      public function priceLine(param1:Array) : int
      {
         var _loc4_:Point = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = BuildManager.instance.convertToCell(param1[_loc3_].clone());
            if(!BuildManager.instance.getBuildType(_loc4_.x,_loc4_.y,BuildManager.instance.ROAD_STR))
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function validateTotal(param1:int) : Boolean
      {
         var _loc2_:Number = param1 * this.m_roadCost;
         if(_loc2_ > ZGlobal.player.coins)
         {
            return false;
         }
         return true;
      }
      
      private function createObjectAtPosition(param1:Point, param2:Boolean = true) : Boolean
      {
         var _loc3_:IsoRectangle = this.getRect();
         if(this.m_invalidated || !param2)
         {
            _loc3_.fill = this.m_invalidColor;
            _loc3_.stroke = this.m_invalidStroke;
            param2 = false;
         }
         else
         {
            _loc3_.fill = this.m_validColor;
            _loc3_.stroke = this.m_validStroke;
         }
         _loc3_.moveTo(param1.x,param1.y,0);
         var _loc4_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc5_:IsoScene = IsoScene(_loc4_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
         if(_loc3_.parent == null)
         {
            _loc5_.addChild(_loc3_);
         }
         return param2;
      }
      
      public function get placementList() : Array
      {
         return this.m_placementArray;
      }
      
      public function onMouseMove(param1:Point) : void
      {
         this.drawLine(param1,param1);
         var _loc2_:RoadRendererComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
         var _loc3_:Pt = MathUtils.worldToTile(Pt(param1.clone()),ZGlobal.cellSize);
         _loc2_.roadTileManager.updateCursor(_loc3_,this.m_existingRoadPos);
      }
      
      public function onMouseClick() : Boolean
      {
         var _loc2_:Point = null;
         var _loc3_:Pt = null;
         var _loc4_:RoadRendererComponent = null;
         var _loc5_:Pt = null;
         var _loc6_:Boolean = false;
         var _loc1_:Array = this.placementList;
         if(_loc1_.length > 0)
         {
            _loc2_ = _loc1_[0];
            _loc3_ = new Pt(_loc2_.x,_loc2_.y);
            if(this.isPositionValid(_loc3_) && this.canAfford())
            {
               _loc4_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
               _loc5_ = MathUtils.worldToTile(Pt(_loc3_.clone()),ZGlobal.cellSize);
               _loc6_ = BuildManager.instance.getBuildType(_loc5_.x,_loc5_.y,BuildManager.instance.ROAD_STR);
               if(this.m_existingRoadPos)
               {
                  if(_loc5_.x == this.m_existingRoadPos.x && _loc5_.y == this.m_existingRoadPos.y)
                  {
                     return true;
                  }
                  if(!_loc6_)
                  {
                     _loc4_.roadTileManager.moveSegment(this.m_existingRoadPos,_loc5_);
                     return true;
                  }
               }
               else if(!_loc6_)
               {
                  _loc4_.roadTileManager.addSegment(_loc5_);
                  return true;
               }
            }
         }
         return false;
      }
      
      private function canAfford() : Boolean
      {
         if(this.m_movingRoad)
         {
            return true;
         }
         var _loc1_:GameItem = ZGlobal.gameSettings.getRoadItem();
         if(_loc1_)
         {
            return ZGlobal.player.canBuy(_loc1_,true);
         }
         return false;
      }
      
      public function dispose() : void
      {
         this.m_invalidColor = null;
         this.m_invalidStroke = null;
         this.m_validColor = null;
         this.m_validStroke = null;
         this.m_validBitmapFill = null;
         this.m_inValidBitmapFill = null;
         this.removeAllRectFromScene();
         this.m_rectangles.length = 0;
         this.m_rectangles = null;
         this.m_usedRectangles.length = 0;
         this.m_usedRectangles = null;
         var _loc1_:RoadRendererComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
         _loc1_.roadTileManager.drawRoads();
      }
   }
}

