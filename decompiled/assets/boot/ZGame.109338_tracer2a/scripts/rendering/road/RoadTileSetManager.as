package rendering.road
{
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import transactions.TRoadBuy;
   import transactions.TRoadMove;
   import transactions.TRoadSell;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.resource.Resource;
   import zlabs.resource.SWFResource;
   
   public class RoadTileSetManager extends EventDispatcher
   {
      
      private var m_roadList:Array = null;
      
      private var m_roadAnimations:Array = null;
      
      private var m_roadBitmapDataList:Object;
      
      private var m_roadLayout:Sprite;
      
      private var m_tempPt:Point = new Point();
      
      private var m_buildMap:Array;
      
      private var m_mapSize:Point;
      
      private var intialized:Boolean = false;
      
      private var isDirty:Boolean = false;
      
      private var m_intervalTimer:int = -1;
      
      private var m_prevMousePoint:Pt = null;
      
      public function RoadTileSetManager(param1:Sprite)
      {
         super();
         this.m_roadList = new Array();
         this.m_roadAnimations = new Array();
         this.m_roadLayout = param1;
      }
      
      public static function drawStraightLine(param1:Point, param2:Point, param3:Array, param4:int = 1) : Array
      {
         var _loc9_:int = 0;
         var _loc12_:Point = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc5_:int = int(param1.x);
         var _loc6_:int = int(param2.x);
         var _loc7_:int = int(param1.y);
         var _loc8_:int = int(param2.y);
         var _loc10_:int = Math.abs(int(_loc5_ - _loc6_));
         var _loc11_:int = Math.abs(int(_loc7_ - _loc8_));
         if(_loc10_ > _loc11_)
         {
            if(_loc6_ < _loc5_)
            {
               _loc9_ = _loc5_;
               _loc5_ = _loc6_;
               _loc6_ = _loc9_;
            }
            _loc13_ = _loc5_;
            while(_loc13_ <= _loc6_)
            {
               param3.push(new Point(_loc13_,Math.floor(param1.y)));
               _loc13_ += param4;
            }
         }
         else
         {
            if(_loc8_ < _loc7_)
            {
               _loc9_ = _loc7_;
               _loc7_ = _loc8_;
               _loc8_ = _loc9_;
            }
            _loc14_ = _loc7_;
            while(_loc14_ <= _loc8_)
            {
               param3.push(new Point(Math.floor(param1.x),_loc14_));
               _loc14_ += param4;
            }
         }
         return param3;
      }
      
      public static function intersection(param1:Point, param2:Point, param3:Point, param4:Point, param5:Point = null) : Point
      {
         var _loc6_:int = param1.x;
         var _loc7_:int = param2.x;
         var _loc8_:int = param3.x;
         var _loc9_:int = param4.x;
         var _loc10_:int = param1.y;
         var _loc11_:int = param2.y;
         var _loc12_:int = param3.y;
         var _loc13_:int = param4.y;
         var _loc14_:int = _loc6_ - _loc7_;
         var _loc15_:int = _loc8_ - _loc9_;
         var _loc16_:int = _loc10_ - _loc11_;
         var _loc17_:int = _loc12_ - _loc13_;
         var _loc18_:int = _loc14_ * _loc17_ - _loc16_ * _loc15_;
         if(_loc18_ == 0)
         {
            return null;
         }
         var _loc19_:int = _loc6_ * _loc11_ - _loc10_ * _loc7_;
         var _loc20_:int = _loc8_ * _loc13_ - _loc12_ * _loc9_;
         var _loc21_:int = (_loc19_ * _loc15_ - _loc14_ * _loc20_) / _loc18_;
         var _loc22_:int = (_loc19_ * _loc17_ - _loc16_ * _loc20_) / _loc18_;
         if(_loc21_ < Math.min(_loc6_,_loc7_) || _loc21_ > Math.max(_loc6_,_loc7_) || _loc21_ < Math.min(_loc8_,_loc9_) || _loc21_ > Math.max(_loc8_,_loc9_))
         {
            return null;
         }
         if(_loc22_ < Math.min(_loc10_,_loc11_) || _loc22_ > Math.max(_loc10_,_loc11_) || _loc22_ < Math.min(_loc12_,_loc13_) || _loc22_ > Math.max(_loc12_,_loc13_))
         {
            return null;
         }
         if(!param5)
         {
            param5 = new Point();
         }
         param5.x = _loc21_;
         param5.y = _loc22_;
         return param5;
      }
      
      public function setMapSize(param1:int, param2:int) : void
      {
         this.m_mapSize = new Point();
         this.m_mapSize.x = param1;
         this.m_mapSize.y = param2;
         this.m_buildMap = new Array(param2);
         var _loc3_:int = 0;
         while(_loc3_ < param2)
         {
            this.m_buildMap[_loc3_] = new Array(param1);
            _loc3_++;
         }
      }
      
      public function init(param1:String) : void
      {
         Zlab.resourceManager.load(param1,SWFResource,this.onRoadLoaded,this.onFailedRoadLoaded);
      }
      
      public function onRoadLoaded(param1:SWFResource) : void
      {
         this.m_roadBitmapDataList = new Object();
         var _loc2_:Class = param1.getAssetClass("road_X_SW.png");
         var _loc3_:BitmapData = new _loc2_(1,1);
         this.m_roadBitmapDataList["basic"] = _loc3_;
         this.m_roadBitmapDataList[0] = _loc3_;
         this.m_roadBitmapDataList[9] = _loc3_;
         _loc2_ = param1.getAssetClass("road_corner_N.png");
         this.m_roadBitmapDataList[1] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_corner_W.png");
         this.m_roadBitmapDataList[2] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_corner_S.png");
         this.m_roadBitmapDataList[3] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_corner_E.png");
         this.m_roadBitmapDataList[4] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_t_NE.png");
         this.m_roadBitmapDataList[5] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_t_SE.png");
         this.m_roadBitmapDataList[6] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_t_SW.png");
         this.m_roadBitmapDataList[7] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_t_NW.png");
         this.m_roadBitmapDataList[8] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_straight_SW.png");
         this.m_roadBitmapDataList[10] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_straight_SE.png");
         this.m_roadBitmapDataList[11] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_end_SW.png");
         this.m_roadBitmapDataList[12] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_end_NW.png");
         this.m_roadBitmapDataList[13] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_end_NE.png");
         this.m_roadBitmapDataList[14] = new _loc2_(1,1);
         _loc2_ = param1.getAssetClass("road_end_SE.png");
         this.m_roadBitmapDataList[15] = new _loc2_(1,1);
         this.intialized = true;
         if(this.isDirty == true)
         {
            this.drawRoads();
         }
         else
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function onFailedRoadLoaded(param1:Resource) : void
      {
         Logger.warn(this,"onFailedRoadLoaded","failed to load resource: " + param1.filename);
      }
      
      public function buildRoadTileSet(param1:Array) : void
      {
         var _loc2_:Object = null;
         this.m_roadList = new Array();
         for each(_loc2_ in param1)
         {
            this.m_roadList.push(this.createRoadFromData(_loc2_));
         }
         this.isDirty = true;
         if(this.intialized == true)
         {
            this.drawRoads();
         }
      }
      
      public function createRoadFromData(param1:Object) : Road
      {
         var _loc2_:Road = new Road(null,null);
         _loc2_.deSerialize(param1 as String);
         return _loc2_;
      }
      
      public function createRoad(param1:Point, param2:Point) : Road
      {
         return new Road(param1,param2);
      }
      
      public function buildRoads(param1:Road) : int
      {
         var _loc2_:int = 0;
         this.isDirty = true;
         if(this.intialized == true)
         {
            _loc2_ = this.drawRoads(param1,true);
         }
         return _loc2_;
      }
      
      public function moveSegment(param1:Point, param2:Point) : void
      {
         var _loc3_:RoadRendererComponent = null;
         if(this.positionHasRoad(param1))
         {
            this.sellRoadAtHelper(param1.x,param1.y,true);
            this.addSegmentHelper(param2,true);
            _loc3_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
            TransactionManager.addTransaction(new TRoadMove(_loc3_.roadTileManager.serialize()));
         }
      }
      
      public function addSegment(param1:Point) : void
      {
         this.addSegmentHelper(param1,false);
      }
      
      public function addSegmentHelper(param1:Point, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Road = null;
         var _loc6_:Road = null;
         var _loc7_:RoadRendererComponent = null;
         var _loc3_:GameItem = ZGlobal.gameSettings.getRoadItem();
         if(_loc3_)
         {
            _loc4_ = 0;
            _loc5_ = this.getFirstAdjacentRoad(param1);
            if(_loc5_)
            {
               if(this.adjacent(param1,_loc5_.startCell))
               {
                  _loc5_.startCell = param1;
               }
               else
               {
                  _loc5_.endCell = param1;
               }
               _loc5_.endpointsUpdated();
               this.drawRoads();
               _loc4_ = 1;
            }
            else
            {
               _loc6_ = new Road(param1,param1);
               _loc4_ = this.buildRoads(_loc6_);
            }
            if(_loc4_)
            {
               if(!param2)
               {
                  _loc7_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
                  TransactionManager.addTransaction(new TRoadBuy(_loc7_.roadTileManager.serialize(),_loc4_));
                  ZGlobal.player.buyItem(_loc3_,false);
               }
            }
         }
      }
      
      public function drawRoads(param1:Road = null, param2:Boolean = false) : int
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:Road = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         this.isDirty = false;
         var _loc3_:int = 0;
         var _loc4_:BitmapData = this.m_roadBitmapDataList["basic"];
         this.clearRoadLayout();
         var _loc8_:int = 0;
         while(_loc8_ < this.m_roadList.length)
         {
            _loc9_ = Road(this.m_roadList[_loc8_]);
            _loc5_ = _loc9_.getLine();
            _loc10_ = 0;
            while(_loc10_ < _loc5_.length)
            {
               _loc6_ = int(_loc5_[_loc10_].x);
               _loc7_ = int(_loc5_[_loc10_].y);
               if(!BuildManager.instance.getBuildType(_loc6_,_loc7_,BuildManager.instance.ROAD_STR))
               {
                  BuildManager.instance.addBuildType(_loc6_,_loc7_,BuildManager.instance.ROAD_STR);
               }
               _loc10_++;
            }
            _loc8_++;
         }
         this.placeRoadBitmap();
         if(param1)
         {
            _loc5_ = param1.getLine();
            _loc11_ = 0;
            while(_loc11_ < _loc5_.length)
            {
               _loc6_ = int(_loc5_[_loc11_].x);
               _loc7_ = int(_loc5_[_loc11_].y);
               if(!BuildManager.instance.getBuildType(_loc6_,_loc7_,BuildManager.instance.ROAD_STR))
               {
                  BuildManager.instance.addBuildType(_loc6_,_loc7_,BuildManager.instance.ROAD_STR);
                  _loc3_++;
               }
               _loc11_++;
            }
            if(_loc3_ > 0)
            {
               this.m_roadList.push(param1);
            }
            this.placeRoadBitmap(_loc5_,param2);
         }
         dispatchEvent(new Event("ROAD_COMPLETE"));
         return _loc3_;
      }
      
      private function positionHasRoad(param1:Point) : Boolean
      {
         var _loc2_:Road = null;
         for each(_loc2_ in this.m_roadList)
         {
            if(_loc2_.containsPoint(param1.x,param1.y))
            {
               return true;
            }
         }
         return false;
      }
      
      private function getFirstAdjacentRoad(param1:Point) : Road
      {
         var _loc2_:Road = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         for each(_loc2_ in this.m_roadList)
         {
            _loc3_ = this.adjacent(param1,_loc2_.startCell);
            _loc4_ = this.adjacent(param1,_loc2_.endCell);
            if(_loc3_ || _loc4_)
            {
               if(_loc2_.isPointColinear(param1))
               {
                  if(!_loc2_.containsPoint(param1.x,param1.y))
                  {
                     return _loc2_;
                  }
               }
            }
         }
         return null;
      }
      
      private function placeRoadBitmap(param1:Array = null, param2:Boolean = false) : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:BitmapData = null;
         var _loc9_:Bitmap = null;
         var _loc3_:Object = new Object();
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < this.m_buildMap.length)
         {
            _loc6_ = 0;
            while(_loc6_ < this.m_buildMap[_loc5_].length)
            {
               if(BuildManager.instance.getBuildType(_loc5_,_loc6_,BuildManager.instance.ROAD_STR))
               {
                  _loc7_ = this.junctionCheck(_loc5_,_loc6_);
                  _loc8_ = this.getRoadJointBitmapData(_loc7_);
                  if(this.m_buildMap[_loc5_][_loc6_] is Bitmap)
                  {
                     this.m_buildMap[_loc5_][_loc6_].bitmapData = _loc8_;
                  }
                  else
                  {
                     _loc9_ = this.newBitmap(_loc5_,_loc6_,_loc8_);
                     this.m_buildMap[_loc5_][_loc6_] = _loc9_;
                     if(param1)
                     {
                        _loc4_.push(_loc9_);
                     }
                     else
                     {
                        this.m_roadLayout.addChild(_loc9_);
                     }
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
         if(_loc4_.length > 0)
         {
            _loc3_.roadAnim = _loc4_;
            _loc3_.aniCount = 0;
            this.m_roadAnimations.push(_loc3_);
            this.roadAnimation();
         }
         return true;
      }
      
      public function roadAnimation() : void
      {
         if(this.m_intervalTimer == -1)
         {
            this.m_intervalTimer = setInterval(this.onAnimate,100);
         }
         this.onAnimate();
      }
      
      public function onAnimate() : void
      {
         var _loc1_:int = int(this.m_roadAnimations.length);
         var _loc2_:* = 0;
         while(_loc2_ < _loc1_)
         {
            this.m_roadLayout.addChild(this.m_roadAnimations[_loc2_].roadAnim[this.m_roadAnimations[_loc2_].aniCount]);
            ++this.m_roadAnimations[_loc2_].aniCount;
            if(this.m_roadAnimations[_loc2_].aniCount >= this.m_roadAnimations[_loc2_].roadAnim.length)
            {
               this.m_roadAnimations.splice(_loc2_,1);
               _loc2_--;
               _loc1_ = int(this.m_roadAnimations.length);
               dispatchEvent(new Event(RoadRendererComponent.UPDATE_ROAD));
               dispatchEvent(new Event(Event.COMPLETE));
            }
            _loc2_++;
         }
         if(this.m_roadAnimations.length == 0)
         {
            clearInterval(this.m_intervalTimer);
            this.m_intervalTimer = -1;
         }
      }
      
      public function findIntersections(param1:Array) : int
      {
         var _loc4_:Bitmap = null;
         var _loc5_:BitmapData = null;
         var _loc7_:Point = null;
         var _loc8_:Point = null;
         var _loc9_:int = 0;
         var _loc10_:Point = null;
         var _loc11_:Point = null;
         var _loc12_:Point = null;
         var _loc13_:int = 0;
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc3_:Array = param1.slice();
         var _loc6_:int = 0;
         while(_loc3_.length > 1)
         {
            _loc7_ = Road(_loc3_[0]).startCell;
            _loc8_ = Road(_loc3_[0]).endCell;
            _loc9_ = 1;
            while(_loc9_ < _loc3_.length)
            {
               _loc10_ = Road(_loc3_[_loc9_]).startCell;
               _loc11_ = Road(_loc3_[_loc9_]).endCell;
               _loc12_ = intersection(_loc7_,_loc8_,_loc10_,_loc11_);
               if(_loc12_)
               {
                  _loc13_ = this.junctionCheck(_loc12_.x,_loc12_.y);
                  _loc5_ = this.getRoadJointBitmapData(_loc13_);
                  if(this.m_buildMap[_loc12_.x][_loc12_.y] is Bitmap)
                  {
                     this.m_buildMap[_loc12_.x][_loc12_.y].bitmapData = _loc5_;
                  }
                  else
                  {
                     _loc4_ = this.newBitmap(_loc12_.x,_loc12_.y,_loc5_);
                     this.m_buildMap[_loc12_.x][_loc12_.y] = _loc4_;
                     this.m_roadLayout.addChild(_loc4_);
                  }
               }
               _loc9_++;
            }
            _loc3_.shift();
         }
         _loc3_ = null;
         return _loc6_;
      }
      
      private function junctionDirectionCheck(param1:int, param2:int, param3:Pt = null, param4:Pt = null) : Boolean
      {
         if(Boolean(param3) && Boolean(param3.x == param1) && param3.y == param2)
         {
            return true;
         }
         if(Boolean(param4) && Boolean(param4.x == param1) && param4.y == param2)
         {
            return false;
         }
         return BuildManager.instance.getBuildType(param1,param2,BuildManager.instance.ROAD_STR);
      }
      
      private function junctionCheck(param1:int, param2:int, param3:Pt = null, param4:Pt = null) : int
      {
         var _loc5_:String = "";
         _loc5_ = _loc5_ + String(int(this.junctionDirectionCheck(param1,param2 - 1,param3,param4)));
         _loc5_ = _loc5_ + String(int(this.junctionDirectionCheck(param1 + 1,param2,param3,param4)));
         _loc5_ = _loc5_ + String(int(this.junctionDirectionCheck(param1,param2 + 1,param3,param4)));
         _loc5_ = _loc5_ + String(int(this.junctionDirectionCheck(param1 - 1,param2,param3,param4)));
         switch(_loc5_)
         {
            case "0000":
               return 0;
            case "1111":
               return 9;
            case "0110":
               return 1;
            case "0011":
               return 2;
            case "1001":
               return 3;
            case "1100":
               return 4;
            case "1101":
               return 5;
            case "1110":
               return 6;
            case "0111":
               return 7;
            case "1011":
               return 8;
            case "1010":
               return 10;
            case "0101":
               return 11;
            case "0010":
               return 12;
            case "0001":
               return 13;
            case "1000":
               return 14;
            case "0100":
               return 15;
            default:
               return 0;
         }
      }
      
      private function getRoadJointBitmapData(param1:int) : BitmapData
      {
         return this.m_roadBitmapDataList[param1];
      }
      
      public function clearBitmapDataList() : void
      {
         var _loc1_:BitmapData = null;
         for each(_loc1_ in this.m_roadBitmapDataList)
         {
            _loc1_.dispose();
         }
         this.m_roadBitmapDataList = null;
      }
      
      public function clearRoadAt(param1:int, param2:int) : Boolean
      {
         var _loc6_:Road = null;
         var _loc7_:Array = null;
         var _loc3_:int = int(this.m_roadList.length);
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc6_ = Road(this.m_roadList[_loc5_]);
            if(_loc6_.containsPoint(param1,param2))
            {
               _loc7_ = _loc6_.breakLineAtPoint(param1,param2);
               _loc4_ = _loc4_.concat(_loc7_);
               _loc6_.dispose();
            }
            else
            {
               _loc4_.push(_loc6_);
            }
            _loc5_++;
         }
         this.m_roadList.length = 0;
         this.m_roadList = _loc4_.slice();
         BuildManager.instance.removeBuildType(param1,param2,BuildManager.instance.ROAD_STR);
         this.drawRoads();
         return true;
      }
      
      private function clearRoadLayout() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_buildMap.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_buildMap[_loc1_].length)
            {
               this.m_buildMap[_loc1_][_loc2_] = null;
               BuildManager.instance.removeBuildType(_loc1_,_loc2_,BuildManager.instance.ROAD_STR);
               _loc2_++;
            }
            _loc1_++;
         }
         while(this.m_roadLayout.numChildren > 0)
         {
            this.m_roadLayout.removeChildAt(0);
         }
      }
      
      private function getTileBoundsForMouseMove(param1:Pt) : Object
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         if(this.m_prevMousePoint)
         {
            _loc2_ = Math.min(param1.x,this.m_prevMousePoint.x);
            _loc3_ = Math.min(param1.y,this.m_prevMousePoint.y);
            _loc4_ = Math.max(param1.x,this.m_prevMousePoint.x);
            _loc5_ = Math.max(param1.y,this.m_prevMousePoint.y);
         }
         else
         {
            _loc2_ = _loc4_ = param1.x;
            _loc3_ = _loc5_ = param1.y;
         }
         this.m_prevMousePoint = new Pt(param1.x,param1.y,param1.z);
         _loc2_--;
         _loc3_--;
         _loc4_ += 1;
         _loc5_ += 1;
         return {
            "minx":_loc2_,
            "miny":_loc3_,
            "maxx":_loc4_,
            "maxy":_loc5_
         };
      }
      
      public function sellRoadAtHelper(param1:int, param2:int, param3:Boolean) : Point
      {
         this.clearRoadAt(param1,param2);
         var _loc4_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc5_:Point = new Point();
         _loc5_.x = param1 * ZGlobal.cellSize;
         _loc5_.y = param2 * ZGlobal.cellSize;
         _loc4_.isoToLocalPoint(this.m_tempPt);
         if(!param3)
         {
            TransactionManager.addTransaction(new TRoadSell(this.serialize()));
         }
         return _loc5_;
      }
      
      public function sellRoadAt(param1:int, param2:int) : Point
      {
         return this.sellRoadAtHelper(param1,param2,false);
      }
      
      public function clearAllRoads() : Boolean
      {
         this.clearRoadLayout();
         this.m_roadList = new Array();
         TransactionManager.addTransaction(new TRoadBuy([],0));
         return true;
      }
      
      public function reset() : void
      {
         this.clearRoadLayout();
      }
      
      public function dispose() : void
      {
         this.m_tempPt = null;
         this.clearRoadLayout();
         this.m_roadLayout = null;
         this.clearBitmapDataList();
      }
      
      public function serialize() : Array
      {
         var _loc2_:Road = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_roadList)
         {
            _loc1_.push(_loc2_.serialize());
         }
         return _loc1_;
      }
      
      public function adjacent(param1:Point, param2:Point) : Boolean
      {
         var _loc3_:int = Math.abs(param1.x - param2.x);
         var _loc4_:int = Math.abs(param1.y - param2.y);
         var _loc5_:int = _loc3_ + _loc4_;
         return _loc5_ == 1;
      }
      
      public function updateCursor(param1:Pt, param2:Pt = null) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:BitmapData = null;
         var _loc13_:Bitmap = null;
         var _loc3_:Boolean = this.mouseChangedTilePosition(param1);
         if(_loc3_)
         {
            _loc4_ = this.getTileBoundsForMouseMove(param1);
            _loc5_ = int(_loc4_.minx);
            while(_loc5_ <= _loc4_.maxx)
            {
               _loc6_ = int(_loc4_.miny);
               while(_loc6_ <= _loc4_.maxy)
               {
                  _loc7_ = param1.x == _loc5_ && param1.y == _loc6_;
                  _loc8_ = BuildManager.instance.getBuildType(_loc5_,_loc6_,BuildManager.instance.ROAD_STR);
                  _loc9_ = Boolean(param2) && _loc5_ == param2.x && _loc6_ == param2.y;
                  _loc10_ = !_loc9_ && (_loc7_ || _loc8_);
                  if(!_loc10_)
                  {
                     if(this.m_buildMap[_loc5_][_loc6_] is Bitmap)
                     {
                        if(this.m_buildMap[_loc5_][_loc6_].parent)
                        {
                           this.m_buildMap[_loc5_][_loc6_].parent.removeChild(this.m_buildMap[_loc5_][_loc6_]);
                        }
                        delete this.m_buildMap[_loc5_][_loc6_];
                        this.m_buildMap[_loc5_][_loc6_] = null;
                     }
                  }
                  else
                  {
                     _loc11_ = this.junctionCheck(_loc5_,_loc6_,param1,param2);
                     _loc12_ = this.getRoadJointBitmapData(_loc11_);
                     if(this.m_buildMap[_loc5_][_loc6_] is Bitmap)
                     {
                        this.m_buildMap[_loc5_][_loc6_].bitmapData = _loc12_;
                     }
                     else
                     {
                        _loc13_ = this.newBitmap(_loc5_,_loc6_,_loc12_);
                        this.m_buildMap[_loc5_][_loc6_] = _loc13_;
                        this.m_roadLayout.addChild(_loc13_);
                     }
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
            dispatchEvent(new Event(RoadRendererComponent.UPDATE_ROAD));
            dispatchEvent(new Event("ROAD_COMPLETE"));
         }
      }
      
      private function mouseChangedTilePosition(param1:Pt) : Boolean
      {
         if(!this.m_prevMousePoint)
         {
            return true;
         }
         return this.m_prevMousePoint.x != param1.x || this.m_prevMousePoint.y != param1.y;
      }
      
      private function newBitmap(param1:int, param2:int, param3:BitmapData) : Bitmap
      {
         var _loc4_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc5_:Bitmap = new Bitmap(param3);
         var _loc6_:Point = new Point(param1 * ZGlobal.cellSize,param2 * ZGlobal.cellSize);
         _loc6_ = _loc4_.isoToLocalPoint(_loc6_);
         _loc5_.x = _loc6_.x - ZGlobal.cellSize * 2 * 0.5;
         _loc5_.y = _loc6_.y;
         return _loc5_;
      }
   }
}

