package core.managers
{
   import Engine.MathUtil;
   import as3isolib.display.primitive.IsoRectangle;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import as3isolib.graphics.SolidColorFill;
   import as3isolib.graphics.Stroke;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class BuildManager
   {
      
      public static var instance:BuildManager = new BuildManager();
      
      public const LAND_STR:String = "L";
      
      public const WATER_STR:String = "W";
      
      public const NOBUILD_STR:String = "N";
      
      public const LOCKED_STR:String = "K";
      
      public const ROAD_STR:String = "R";
      
      public const BUILDING_STR:String = "B";
      
      public const PAVING_STR:String = "P";
      
      public const WAREHOUSE_AIR_STR:String = "A";
      
      public const WAREHOUSE_NAVY_STR:String = "V";
      
      public const WAREHOUSE_ARMY_STR:String = "M";
      
      public const LAND_OR_COAST_STR:String = "LN";
      
      public const WATER_OR_COAST_STR:String = "WN";
      
      public const LAND_OR_ROAD_STR:String = "LR";
      
      public const LAND_OR_WATER_OR_COAST_STR:String = "LWN";
      
      public const LAND_OR_PAVING_STR:String = "LP";
      
      public const LAND_OR_PAVING_OR_ROAD_STR:String = "LPR";
      
      public const LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_AIR_STR:String = "LPRA";
      
      public const WATER_OR_WAREHOUSE_NAVY_STR:String = "WV";
      
      public const LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_ARMY_STR:String = "LPRM";
      
      public const LAND_VAL:int = 1 << 0;
      
      public const WATER_VAL:int = 1 << 1;
      
      public const NOBUILD_VAL:int = 1 << 2;
      
      public const LOCKED_VAL:int = 1 << 3;
      
      public const ROAD_VAL:int = 1 << 4;
      
      public const BUILDING_VAL:int = 1 << 5;
      
      public const PAVING_VAL:int = 1 << 6;
      
      public const WAREHOUSE_AIR_VAL:int = 1 << 7;
      
      public const WAREHOUSE_NAVY_VAL:int = 1 << 8;
      
      public const WAREHOUSE_ARMY_VAL:int = 1 << 9;
      
      public const LAND_OR_COAST_VAL:int = this.LAND_VAL | this.NOBUILD_VAL;
      
      public const WATER_OR_COAST_VAL:int = this.WATER_VAL | this.NOBUILD_VAL;
      
      public const LAND_OR_WATER_OR_COAST_VAL:int = this.LAND_VAL | this.WATER_VAL | this.NOBUILD_VAL;
      
      public const LAND_OR_ROAD_VAL:int = this.LAND_VAL | this.ROAD_VAL;
      
      public const LAND_OR_PAVING_VAL:int = this.LAND_VAL | this.PAVING_VAL;
      
      public const LAND_OR_PAVING_OR_ROAD_VAL:int = this.LAND_VAL | this.PAVING_VAL | this.ROAD_VAL;
      
      public const LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_AIR_VAL:int = this.LAND_VAL | this.PAVING_VAL | this.ROAD_VAL | this.WAREHOUSE_AIR_VAL;
      
      public const WATER_OR_WAREHOUSE_NAVY_VAL:int = this.WATER_VAL | this.WAREHOUSE_NAVY_VAL;
      
      public const LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_ARMY_VAL:int = this.LAND_VAL | this.PAVING_VAL | this.ROAD_VAL | this.WAREHOUSE_ARMY_VAL;
      
      public const STANDARD_VALID_WATER_PLACEMENT:int = this.WATER_VAL | this.WAREHOUSE_NAVY_VAL;
      
      public const STANDARD_INVALID_WATER_PLACEMENT:int = this.LAND_VAL | this.NOBUILD_VAL | this.LOCKED_VAL | this.BUILDING_VAL | this.WAREHOUSE_AIR_VAL | this.WAREHOUSE_NAVY_VAL | this.WAREHOUSE_ARMY_VAL;
      
      public const STANDARD_VALID_BUILD:int = this.LAND_VAL;
      
      public const STANDARD_INVALID_BUILD:int = this.WATER_VAL | this.NOBUILD_VAL | this.LOCKED_VAL | this.ROAD_VAL | this.BUILDING_VAL | this.PAVING_VAL | this.WAREHOUSE_AIR_VAL | this.WAREHOUSE_NAVY_VAL | this.WAREHOUSE_ARMY_VAL;
      
      private var m_buildMap:Array = null;
      
      private var m_objectMap:Array = null;
      
      private var m_islandMap:Array = null;
      
      private var m_buildTypes:Dictionary = new Dictionary();
      
      private var m_placementArray:Array = null;
      
      private var m_canBuildOn:String = null;
      
      private var m_footprintType:String = null;
      
      private var m_currentId:Object = 0;
      
      private var m_rawPlacementPosition:Point = new Point();
      
      private var m_islandMapComponent:IslandMapComponent = null;
      
      private var m_dimensionX:Number = 0;
      
      private var m_dimensionY:Number = 0;
      
      private var m_ignoreRemoves:Boolean = false;
      
      private var m_alwaysPickedItems:Array = null;
      
      private var m_questTreeHooks:Object = new Dictionary();
      
      private var m_dirProperty:PropertyReference = new PropertyReference("@Data.direction");
      
      private var m_volProperty:PropertyReference = new PropertyReference("@IsoSpatial.volume");
      
      private var m_debugRectangles:Array = null;
      
      public function BuildManager()
      {
         super();
         this.m_buildTypes[this.LAND_STR] = this.LAND_VAL;
         this.m_buildTypes[this.WATER_STR] = this.WATER_VAL;
         this.m_buildTypes[this.NOBUILD_STR] = this.NOBUILD_VAL;
         this.m_buildTypes[this.LOCKED_STR] = this.LOCKED_VAL;
         this.m_buildTypes[this.ROAD_STR] = this.ROAD_VAL;
         this.m_buildTypes[this.BUILDING_STR] = this.BUILDING_VAL;
         this.m_buildTypes[this.PAVING_STR] = this.PAVING_VAL;
         this.m_buildTypes[this.WAREHOUSE_AIR_STR] = this.WAREHOUSE_AIR_VAL;
         this.m_buildTypes[this.WAREHOUSE_NAVY_STR] = this.WAREHOUSE_NAVY_VAL;
         this.m_buildTypes[this.WAREHOUSE_ARMY_STR] = this.WAREHOUSE_ARMY_VAL;
         this.m_buildTypes[this.LAND_OR_COAST_STR] = this.LAND_OR_COAST_VAL;
         this.m_buildTypes[this.WATER_OR_COAST_STR] = this.WATER_OR_COAST_VAL;
         this.m_buildTypes[this.LAND_OR_WATER_OR_COAST_STR] = this.LAND_OR_WATER_OR_COAST_VAL;
         this.m_buildTypes[this.LAND_OR_ROAD_STR] = this.LAND_OR_ROAD_VAL;
         this.m_buildTypes[this.LAND_OR_PAVING_STR] = this.LAND_OR_PAVING_VAL;
         this.m_buildTypes[this.LAND_OR_PAVING_OR_ROAD_STR] = this.LAND_OR_PAVING_OR_ROAD_VAL;
         this.m_buildTypes[this.LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_AIR_STR] = this.LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_AIR_VAL;
         this.m_buildTypes[this.WATER_OR_WAREHOUSE_NAVY_STR] = this.WATER_OR_WAREHOUSE_NAVY_VAL;
         this.m_buildTypes[this.LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_ARMY_STR] = this.LAND_OR_PAVING_OR_ROAD_OR_WAREHOUSE_ARMY_VAL;
         UIDispatcher.instance.addEventListener("cycleBuildIcons",this.onDebugBuild);
      }
      
      private function onDebugBuild(param1:WorldEvent) : void
      {
         this.debugClearIcons();
         var _loc2_:int = int(param1.eventData);
         if(_loc2_ < 6)
         {
            this.debugAddIcons(_loc2_);
         }
      }
      
      public function setMapSize(param1:int, param2:int) : void
      {
         this.m_dimensionX = param1;
         this.m_dimensionY = param2;
         this.m_buildMap = new Array(param2);
         this.m_objectMap = new Array(param2);
         this.m_islandMap = new Array(param2);
         var _loc3_:int = 0;
         while(_loc3_ < param2)
         {
            this.m_buildMap[_loc3_] = new Array(param1);
            this.m_objectMap[_loc3_] = new Array(param1);
            this.m_islandMap[_loc3_] = new Array(param1);
            _loc3_++;
         }
      }
      
      public function set ignoreRemoves(param1:Boolean) : void
      {
         this.m_ignoreRemoves = param1;
      }
      
      public function get ignoringRemoves() : Boolean
      {
         return this.m_ignoreRemoves;
      }
      
      private function debugClearIcons() : void
      {
         var _loc1_:IsoRectangle = null;
         if(this.m_debugRectangles)
         {
            for each(_loc1_ in this.m_debugRectangles)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
            this.m_debugRectangles = null;
         }
      }
      
      private function debugAddIcons(param1:int) : void
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:IEntity = ViewManager.instance.getView(IslandWorld.ID);
         var _loc3_:IsoViewComponent = _loc2_.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         var _loc4_:IsoScene = _loc3_.getSceneByID("gameScene") as IsoScene;
         var _loc5_:int = 0;
         for each(_loc6_ in this.m_buildMap)
         {
            _loc7_ = 0;
            for each(_loc8_ in _loc6_)
            {
               if((this.m_buildMap[_loc7_][_loc5_] & 1 << param1) != 0)
               {
                  this.addIcon(_loc7_,_loc5_,_loc4_);
               }
               _loc7_++;
            }
            _loc5_++;
         }
      }
      
      private function addIcon(param1:Number, param2:Number, param3:IsoScene) : void
      {
         if(this.m_debugRectangles == null)
         {
            this.m_debugRectangles = new Array();
         }
         var _loc4_:IsoRectangle = new IsoRectangle();
         _loc4_.moveTo(param1 * ZGlobal.cellSize,param2 * ZGlobal.cellSize,2);
         _loc4_.fill = new SolidColorFill(65280,0.5);
         _loc4_.stroke = new Stroke(2,65280,1);
         _loc4_.width = 20;
         _loc4_.length = 20;
         param3.addChild(_loc4_);
         this.m_debugRectangles.push(_loc4_);
      }
      
      private function validIndex(param1:int, param2:int) : Boolean
      {
         if(param1 < 0 || param2 < 0 || this.m_buildMap == null)
         {
            return false;
         }
         if(param1 < this.m_dimensionX && param2 < this.m_dimensionY)
         {
            return true;
         }
         return false;
      }
      
      public function setIslandCode(param1:int, param2:int, param3:String) : Boolean
      {
         if(this.validIndex(param1,param2))
         {
            this.m_islandMap[param1][param2] = param3;
            return true;
         }
         return false;
      }
      
      public function getIslandCode(param1:int, param2:int) : String
      {
         return this.m_islandMap[param1][param2];
      }
      
      public function setBuildType(param1:int, param2:int, param3:String) : Boolean
      {
         if(this.validIndex(param1,param2))
         {
            this.m_buildMap[param1][param2] = this.m_buildTypes[param3];
            return true;
         }
         return false;
      }
      
      public function addBuildType(param1:int, param2:int, param3:String) : Boolean
      {
         if(this.validIndex(param1,param2))
         {
            this.m_buildMap[param1][param2] |= this.m_buildTypes[param3];
            return true;
         }
         return false;
      }
      
      public function removeBuildType(param1:int, param2:int, param3:String) : void
      {
         if(this.validIndex(param1,param2))
         {
            this.m_buildMap[param1][param2] &= ~this.m_buildTypes[param3];
         }
      }
      
      private function addFootprint(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:IsoSpatialComponent = null;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:IEntity = null;
         var _loc9_:IsoSpatialComponent = null;
         var _loc10_:Number = NaN;
         this.m_buildMap[param1][param2] |= this.m_buildTypes[this.m_footprintType];
         if(this.m_objectMap[param1][param2] == null)
         {
            this.m_objectMap[param1][param2] = new Array();
            this.m_objectMap[param1][param2].push(this.m_currentId);
         }
         else
         {
            _loc5_ = this.m_currentId.lookupComponentByType(IsoSpatialComponent) as IsoSpatialComponent;
            _loc6_ = _loc5_.volume.z;
            param4 = 0;
            _loc7_ = this.m_objectMap[param1][param2];
            for each(_loc8_ in _loc7_)
            {
               _loc9_ = _loc8_.lookupComponentByType(IsoSpatialComponent) as IsoSpatialComponent;
               _loc10_ = _loc9_.volume.z;
               if(_loc6_ < _loc10_)
               {
                  break;
               }
               param4++;
            }
            this.m_objectMap[param1][param2].splice(param4,0,this.m_currentId);
         }
         return true;
      }
      
      private function removeFootprint(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         this.m_buildMap[param1][param2] &= ~this.m_buildTypes[this.m_footprintType];
         var _loc5_:int = int(this.m_objectMap[param1][param2].indexOf(this.m_currentId));
         if(_loc5_ < 0)
         {
            Logger.error(this,"removeFootprint","trying to remove an unregistered object.");
         }
         else
         {
            this.m_objectMap[param1][param2].splice(_loc5_,1);
            if(this.m_objectMap[param1][param2].length == 0)
            {
               this.m_objectMap[param1][param2] = null;
            }
         }
         return true;
      }
      
      public function addFootprintBuildType(param1:Pt, param2:Pt, param3:int, param4:Object, param5:String) : void
      {
         this.modifyFootprintBuildType(param1,param2,param3,param4,param5,true);
      }
      
      public function removeFootprintBuildType(param1:Pt, param2:Pt, param3:int, param4:Object, param5:String) : void
      {
         if(!this.m_ignoreRemoves)
         {
            this.modifyFootprintBuildType(param1,param2,param3,param4,param5,false);
         }
      }
      
      private function modifyFootprintBuildType(param1:Pt, param2:Pt, param3:int, param4:Object, param5:String, param6:Boolean) : void
      {
         var _loc7_:Pt = MathUtils.worldToTile(param1,ZGlobal.cellSize);
         var _loc8_:Pt = MathUtils.worldToTile(param2,ZGlobal.cellSize);
         this.m_footprintType = param5;
         this.m_currentId = param4;
         if(param6)
         {
            this.iterateBounds(_loc7_,param3,_loc8_.x,_loc8_.y,this.addFootprint);
         }
         else
         {
            this.iterateBounds(_loc7_,param3,_loc8_.x,_loc8_.y,this.removeFootprint);
         }
         this.m_footprintType = null;
         this.m_currentId = null;
      }
      
      public function getBuildType(param1:int, param2:int, param3:String) : Boolean
      {
         if(this.validIndex(param1,param2))
         {
            return (this.m_buildMap[param1][param2] & this.m_buildTypes[param3]) != 0;
         }
         return false;
      }
      
      public function isCellValidForBuild(param1:Point, param2:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = int(param1.x);
         var _loc4_:int = int(param1.y);
         if(this.validIndex(_loc3_,_loc4_))
         {
            if(null != this.m_islandMapComponent && !this.isIslandValid(_loc3_,_loc4_))
            {
               return false;
            }
            _loc5_ = int(this.m_buildMap[_loc3_][_loc4_]);
            _loc6_ = int(this.m_buildTypes[param2 ? param2 : this.LAND_STR]);
            if(_loc6_ == this.WATER_VAL)
            {
               return _loc5_ == this.WATER_VAL;
            }
            if(_loc6_ == this.WATER_OR_WAREHOUSE_NAVY_VAL)
            {
               return this.isCellValidForPlaceNavyUnit(_loc5_);
            }
            if((_loc5_ & _loc6_) == 0)
            {
               return false;
            }
            _loc7_ = this.STANDARD_INVALID_BUILD;
            if(_loc6_ != 0)
            {
               _loc7_ &= ~_loc6_;
            }
            if((_loc5_ & _loc7_) == 0)
            {
               return true;
            }
         }
         return false;
      }
      
      private function isCellValidForPlaceNavyUnit(param1:int) : Boolean
      {
         var _loc2_:int = this.WATER_OR_WAREHOUSE_NAVY_VAL;
         if(param1 == (this.WAREHOUSE_NAVY_VAL | this.LAND_VAL))
         {
            return true;
         }
         if((param1 & _loc2_) == 0)
         {
            return false;
         }
         var _loc3_:int = this.STANDARD_INVALID_WATER_PLACEMENT;
         if(_loc2_ != 0)
         {
            _loc3_ &= ~_loc2_;
         }
         if((param1 & _loc3_) == 0)
         {
            return true;
         }
         return false;
      }
      
      public function isLocationValidForBuild(param1:Point, param2:String, param3:IslandMapComponent) : Boolean
      {
         this.m_islandMapComponent = param3;
         var _loc4_:Boolean = this.isCellValidForBuild(this.convertToCell(param1),param2);
         this.m_islandMapComponent = null;
         return _loc4_;
      }
      
      public function convertToCell(param1:Point) : Point
      {
         param1.x /= ZGlobal.cellSize;
         param1.y /= ZGlobal.cellSize;
         return param1;
      }
      
      public function iterateEntityBounds(param1:Point, param2:IEntity, param3:Function) : void
      {
         var _loc4_:int = int(param2.getProperty(this.m_dirProperty));
         var _loc5_:Pt = param2.getProperty(this.m_volProperty).clone();
         _loc5_.x /= ZGlobal.cellSize;
         _loc5_.y /= ZGlobal.cellSize;
         this.iterateBounds(param1,_loc4_,_loc5_.x,_loc5_.y,param3);
      }
      
      private function validatePlacement(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = int(this.m_buildTypes[this.m_placementArray[param4]]);
         if((param3 & _loc5_) == 0)
         {
            return false;
         }
         var _loc6_:int = this.STANDARD_INVALID_BUILD;
         _loc6_ = _loc6_ & ~_loc5_;
         if((param3 & _loc6_) != 0)
         {
            return false;
         }
         return true;
      }
      
      private function validateStandardBuild(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.m_canBuildOn == this.WATER_STR)
         {
            return param3 == this.WATER_VAL;
         }
         if(this.m_canBuildOn == this.WATER_OR_WAREHOUSE_NAVY_STR)
         {
            return this.validateNavalUnitPlacement(param3);
         }
         if((param3 & this.STANDARD_VALID_BUILD) == 0)
         {
            return false;
         }
         var _loc5_:int = this.STANDARD_INVALID_BUILD;
         var _loc6_:int = int(this.m_buildTypes[this.m_canBuildOn]);
         if(_loc6_ != 0)
         {
            _loc5_ &= ~_loc6_;
         }
         if((param3 & _loc5_) != 0)
         {
            return false;
         }
         return true;
      }
      
      private function validateNavalUnitPlacement(param1:int) : Boolean
      {
         if(param1 == (this.WAREHOUSE_NAVY_VAL | this.LAND_VAL))
         {
            return true;
         }
         if((param1 & this.STANDARD_VALID_WATER_PLACEMENT) == 0)
         {
            return false;
         }
         var _loc2_:int = this.STANDARD_INVALID_WATER_PLACEMENT;
         var _loc3_:int = int(this.m_buildTypes[this.m_canBuildOn]);
         if(_loc3_ != 0)
         {
            _loc2_ &= ~_loc3_;
         }
         if((param1 & _loc2_) != 0)
         {
            return false;
         }
         return true;
      }
      
      private function iterateBounds(param1:Point, param2:int, param3:int, param4:int, param5:Function) : Boolean
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Point = null;
         var _loc6_:Matrix = new Matrix();
         _loc6_.translate(-(param3 * 0.5) + 0.5,-(param4 * 0.5) + 0.5);
         _loc6_.rotate(GameItem.DIRECTION_ANGLES[param2]);
         var _loc7_:Boolean = this.oddBounds(param3,param4);
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         while(_loc9_ < param4)
         {
            _loc10_ = 0;
            while(_loc10_ < param3)
            {
               _loc11_ = _loc10_;
               _loc12_ = _loc9_;
               if(_loc7_ || param2 != GameItem.DIRECTION_SW)
               {
                  _loc14_ = new Point(_loc11_,_loc12_);
                  _loc14_ = _loc6_.transformPoint(_loc14_);
                  _loc11_ = int(param1.x + _loc14_.x);
                  _loc12_ = int(param1.y + _loc14_.y);
               }
               else
               {
                  _loc11_ += int(param1.x);
                  _loc12_ += int(param1.y);
               }
               if(!this.validIndex(_loc11_,_loc12_))
               {
                  return false;
               }
               _loc13_ = int(this.m_buildMap[_loc11_][_loc12_]);
               if(!param5(_loc11_,_loc12_,_loc13_,_loc8_))
               {
                  return false;
               }
               if(null != this.m_islandMapComponent && !this.isIslandValid(_loc11_,_loc12_))
               {
                  return false;
               }
               _loc10_++;
               _loc8_++;
            }
            _loc9_++;
         }
         return true;
      }
      
      private function isIslandValid(param1:int, param2:int) : Boolean
      {
         var _loc3_:uint = MathUtils.gridToExpansionIndex(param1 / 4,param2 / 4,this.width);
         if(!ZGlobal.hostPlayer.expansions.isBitSet(_loc3_))
         {
            return false;
         }
         return true;
      }
      
      public function modifyPosForPlacement(param1:int, param2:Pt, param3:Pt) : void
      {
         var _loc4_:Number = param2.x / ZGlobal.cellSize;
         var _loc5_:Number = param2.y / ZGlobal.cellSize;
         if(this.oddBounds(_loc4_,_loc5_))
         {
            param3.x += ZGlobal.cellSize;
            param3.y += ZGlobal.cellSize;
         }
      }
      
      private function oddBounds(param1:int, param2:int) : Boolean
      {
         return param1 > 1 && param1 % 2 != 0 && (param2 > 1 && param2 % 2 != 0);
      }
      
      public function isValidForBuild(param1:Point, param2:int, param3:int, param4:int, param5:Array, param6:String, param7:IslandMapComponent) : Boolean
      {
         param1.x /= ZGlobal.cellSize;
         param1.y /= ZGlobal.cellSize;
         param3 /= ZGlobal.cellSize;
         param4 /= ZGlobal.cellSize;
         this.m_placementArray = param5;
         this.m_canBuildOn = param6;
         this.m_islandMapComponent = param7;
         var _loc8_:Boolean = false;
         if(param5 != null)
         {
            _loc8_ = this.iterateBounds(param1,param2,param3,param4,this.validatePlacement);
         }
         else
         {
            _loc8_ = this.iterateBounds(param1,param2,param3,param4,this.validateStandardBuild);
         }
         this.m_islandMapComponent = null;
         return _loc8_;
      }
      
      public function set rawPlacementPosition(param1:Point) : void
      {
         this.m_rawPlacementPosition = param1;
      }
      
      public function get rawPlacementPosition() : Point
      {
         return this.m_rawPlacementPosition.clone();
      }
      
      public function doesObjectOverlap(param1:Point, param2:Point, param3:IEntity) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:IEntity = null;
         if(this.m_objectMap)
         {
            _loc4_ = 0;
            loop0:
            while(_loc4_ < param2.x)
            {
               _loc5_ = 0;
               loop1:
               while(true)
               {
                  if(_loc5_ >= param2.y)
                  {
                     _loc4_++;
                     continue loop0;
                  }
                  _loc6_ = param1.x + _loc4_;
                  _loc7_ = param1.y + _loc5_;
                  if(this.validIndex(_loc6_,_loc7_))
                  {
                     _loc8_ = this.m_objectMap[_loc6_][_loc7_];
                     for each(_loc9_ in _loc8_)
                     {
                        if(_loc9_.name == param3.name)
                        {
                           break loop1;
                        }
                     }
                  }
                  _loc5_++;
               }
               return true;
            }
         }
         return false;
      }
      
      public function getObjectsOverlappingVolume(param1:Point, param2:Point) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:IEntity = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc3_:Array = new Array();
         if(this.m_objectMap)
         {
            _loc4_ = 0;
            while(_loc4_ < param2.x)
            {
               _loc5_ = 0;
               while(_loc5_ < param2.y)
               {
                  _loc6_ = param1.x + _loc4_;
                  _loc7_ = param1.y + _loc5_;
                  if(this.validIndex(_loc6_,_loc7_))
                  {
                     _loc8_ = this.m_objectMap[_loc6_][_loc7_];
                     for each(_loc9_ in _loc8_)
                     {
                        _loc10_ = _loc9_.name;
                        _loc11_ = _loc3_.indexOf(_loc10_);
                        if(_loc11_ < 0)
                        {
                           _loc3_.push(_loc10_);
                        }
                     }
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      public function getObjectIDsOverlappingVolume(param1:Point, param2:Point, param3:Array = null) : Dictionary
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:IEntity = null;
         var _loc11_:String = null;
         var _loc12_:GameDataComponent = null;
         var _loc4_:Dictionary = new Dictionary();
         if(this.m_objectMap)
         {
            _loc5_ = 0;
            while(_loc5_ < param2.x)
            {
               _loc6_ = 0;
               while(_loc6_ < param2.y)
               {
                  _loc7_ = param1.x + _loc5_;
                  _loc8_ = param1.y + _loc6_;
                  if(this.validIndex(_loc7_,_loc8_))
                  {
                     _loc9_ = this.m_objectMap[_loc7_][_loc8_];
                     for each(_loc10_ in _loc9_)
                     {
                        _loc11_ = _loc10_.name;
                        _loc12_ = GameDataComponent.getGameDataComponent(_loc10_);
                        if(_loc12_)
                        {
                           if(!_loc4_[_loc12_.id])
                           {
                              if(param3)
                              {
                                 param3.push(_loc10_);
                              }
                           }
                           _loc4_[_loc12_.id] = true;
                        }
                     }
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      public function alwaysGetObject(param1:Object) : void
      {
         if(!this.m_alwaysPickedItems)
         {
            this.m_alwaysPickedItems = [];
         }
         if(this.m_alwaysPickedItems.indexOf(param1) == -1)
         {
            this.m_alwaysPickedItems.push(param1);
         }
      }
      
      public function removeAlwaysGetObject(param1:Object) : void
      {
         var _loc2_:int = this.m_alwaysPickedItems.indexOf(param1);
         if(_loc2_ != -1)
         {
            this.m_alwaysPickedItems.splice(_loc2_,1);
         }
      }
      
      public function getObjectsAt(param1:Point, param2:Boolean = false) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         var _loc6_:Object = null;
         if(this.m_objectMap)
         {
            _loc3_ = param1.x / ZGlobal.cellSize;
            _loc4_ = param1.y / ZGlobal.cellSize;
            if(this.validIndex(_loc3_,_loc4_))
            {
               _loc5_ = param2 ? 0 : MathUtils.gridToExpansionIndex(_loc3_ / 4,_loc4_ / 4,this.width);
               if(param2 || ZGlobal.hostPlayer.expansions.isBitSet(_loc5_))
               {
                  if(this.m_objectMap[_loc3_][_loc4_] != null)
                  {
                     return this.m_objectMap[_loc3_][_loc4_];
                  }
               }
               else if(this.m_alwaysPickedItems)
               {
                  if(this.m_objectMap[_loc3_][_loc4_] != null)
                  {
                     for each(_loc6_ in this.m_alwaysPickedItems)
                     {
                        if(this.m_objectMap[_loc3_][_loc4_].indexOf(_loc6_) >= 0)
                        {
                           return [_loc6_];
                        }
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public function getObjectAt(param1:Point, param2:Boolean = false) : Object
      {
         var _loc3_:Array = this.getObjectsAt(param1,param2);
         if(_loc3_)
         {
            return _loc3_[_loc3_.length - 1];
         }
         return null;
      }
      
      public function get width() : int
      {
         return this.m_dimensionX;
      }
      
      public function get length() : int
      {
         return this.m_dimensionY;
      }
      
      public function clamp(param1:Pt, param2:Number = 0) : void
      {
         var _loc3_:int = (this.width - 1) * ZGlobal.cellSize;
         param1.x = MathUtil.clamp(param1.x,0,_loc3_ - param2);
         param1.y = MathUtil.clamp(param1.y,0,_loc3_ - param2);
      }
      
      public function validForMovement(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc4_:int = 0;
         if(this.validIndex(param1,param2))
         {
            _loc4_ = int(this.m_buildMap[param1][param2]);
            return (_loc4_ & param3) != 0;
         }
         return false;
      }
      
      public function checkFreeForPlacement(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         this.iterateBounds(new Point(param1,param2),GameItem.DIRECTION_SW,param3,param4,param5);
      }
      
      public function checkFreeForMSHookPlacement(param1:int, param2:int) : Boolean
      {
         if(this.m_questTreeHooks.hasOwnProperty(param1.toString() + "," + param2.toString()))
         {
            return false;
         }
         return true;
      }
      
      public function setHookPositionData(param1:int, param2:int) : void
      {
         this.m_questTreeHooks[param1.toString() + "," + param2.toString()] = true;
      }
      
      public function getNearestFreeLocation(param1:int, param2:int) : Point
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc3_:Point = new Point(param1,param2);
         if(null == this.getObjectAt(_loc3_))
         {
            return _loc3_;
         }
         var _loc4_:int = ZGlobal.cellSize;
         var _loc5_:Array = [new Point(_loc4_,0),new Point(0,_loc4_),new Point(-_loc4_,0),new Point(0,-_loc4_)];
         var _loc6_:int = 1;
         var _loc7_:int = 2;
         var _loc8_:int = 8;
         var _loc9_:Boolean = false;
         loop0:
         while(_loc6_ < 6)
         {
            _loc3_.x = param1 - _loc6_ * _loc4_;
            _loc3_.y = param2 - _loc6_ * _loc4_;
            _loc10_ = 0;
            _loc11_ = 0;
            _loc12_ = 0;
            while(true)
            {
               if(_loc12_ >= _loc8_)
               {
                  _loc8_ += 8;
                  _loc7_ += 2;
                  _loc6_++;
                  continue loop0;
               }
               _loc3_.x += _loc5_[_loc11_].x;
               _loc3_.y += _loc5_[_loc11_].y;
               if(null == this.getObjectAt(_loc3_))
               {
                  break;
               }
               if(++_loc10_ >= _loc7_)
               {
                  _loc11_++;
                  _loc10_ = 0;
               }
               _loc12_++;
            }
            return _loc3_;
         }
         return new Point(param1,param2);
      }
   }
}

