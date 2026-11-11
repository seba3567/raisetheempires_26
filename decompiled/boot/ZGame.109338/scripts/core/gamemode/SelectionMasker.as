package core.gamemode
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.helpers.RoadPlacementProxy;
   import core.gamemode.selectionMasker.EntitySelectionMasker;
   import core.gamemode.selectionMasker.GridSelectionMasker;
   import core.gamemode.selectionMasker.ISelectionMaskerTarget;
   import core.gamemode.selectionMasker.RoadSelectionMasker;
   import core.managers.BuildManager;
   import entity.GameDataComponent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import mx.core.BitmapAsset;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class SelectionMasker
   {
      
      public static var instance:SelectionMasker = new SelectionMasker();
      
      private var m_selectionMaskMedium:Class = SelectionMasker_m_selectionMaskMedium;
      
      private var m_selectionMaskLarge:Class = SelectionMasker_m_selectionMaskLarge;
      
      private const NUM_OBSCURING_TILES:int = 3;
      
      private const SIZE_MEDIUM:uint = 0;
      
      private const SIZE_LARGE:uint = 1;
      
      private var m_maskCache:Array = new Array(new Array(),new Array());
      
      private var m_maskCacheUseCounts:Array = new Array();
      
      private var m_obscurers:Array = null;
      
      private var m_obscurerMap:Dictionary = null;
      
      private var m_lastParentPosition:Point = null;
      
      private var m_target:ISelectionMaskerTarget = null;
      
      private var m_targetHeight:int = 0;
      
      private var m_targetTerrainType:String = null;
      
      private var m_locked:Boolean = false;
      
      public function SelectionMasker()
      {
         super();
      }
      
      public function setEntityTarget(param1:IEntity, param2:Boolean) : void
      {
         if(this.m_target)
         {
            if(!param2 && this.m_target.isEqual(param1))
            {
               return;
            }
         }
         this.setInternalTarget(new EntitySelectionMasker(param1),param2);
      }
      
      public function setRoadTarget(param1:RoadPlacementProxy, param2:Boolean) : void
      {
         this.setInternalTarget(new RoadSelectionMasker(param1),param2);
      }
      
      public function setGridTarget(param1:Point, param2:Boolean) : void
      {
         this.setInternalTarget(new GridSelectionMasker(param1),param2);
      }
      
      private function setInternalTarget(param1:ISelectionMaskerTarget, param2:Boolean) : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Pt = null;
         var _loc5_:Pt = null;
         if(!this.m_locked && (this.m_target != param1 || param2))
         {
            this.m_locked = param2;
            this.releaseTarget();
            this.m_target = param1;
            _loc3_ = param1.position;
            _loc4_ = param1.volume;
            _loc5_ = new Pt(_loc3_.x + _loc4_.x * 0.5,_loc3_.y + _loc4_.y * 0.5);
            this.createMasksAtTargetPosition(_loc5_);
         }
      }
      
      public function clearTarget(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_locked = false;
         }
         if(!this.m_locked)
         {
            this.releaseTarget();
            this.removeMasks();
         }
      }
      
      public function updateTargetPosition(param1:Pt) : void
      {
         this.createMasksAtTargetPosition(param1);
      }
      
      private function releaseTarget() : void
      {
         if(null != this.m_target)
         {
            this.m_target.release();
            this.m_target = null;
            this.m_lastParentPosition = null;
         }
      }
      
      private function notMoved(param1:Point) : Boolean
      {
         if(null != this.m_lastParentPosition)
         {
            if(this.m_lastParentPosition.x == param1.x && this.m_lastParentPosition.y == param1.y)
            {
               return true;
            }
         }
         this.m_lastParentPosition = new Point(param1.x,param1.y);
         return false;
      }
      
      private function createMasksAtTargetPosition(param1:Pt) : void
      {
         var _loc3_:Pt = null;
         var _loc4_:Pt = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc2_:Point = this.m_target.parentPosition;
         if(this.notMoved(_loc2_))
         {
            return;
         }
         this.removeMasks();
         this.m_maskCacheUseCounts[this.SIZE_MEDIUM] = 0;
         this.m_maskCacheUseCounts[this.SIZE_LARGE] = 0;
         this.m_obscurers = new Array();
         this.m_obscurerMap = new Dictionary();
         if(_loc2_)
         {
            _loc3_ = this.m_target.volume;
            this.m_targetHeight = _loc3_.z;
            this.m_targetTerrainType = this.m_target.terrainType;
            _loc4_ = new Pt();
            _loc5_ = 0;
            while(_loc5_ < this.NUM_OBSCURING_TILES)
            {
               _loc6_ = 0;
               while(_loc6_ < this.NUM_OBSCURING_TILES)
               {
                  _loc4_.x = param1.x + _loc6_ * ZGlobal.cellSize;
                  _loc4_.y = param1.y + _loc5_ * ZGlobal.cellSize;
                  _loc7_ = BuildManager.instance.getObjectAt(_loc4_,true);
                  if((Boolean(_loc7_)) && !this.m_target.isEqual(_loc7_))
                  {
                     if(this.m_obscurerMap[IEntity(_loc7_).name] == null)
                     {
                        this.addMask(IEntity(_loc7_),_loc2_);
                        this.m_obscurerMap[IEntity(_loc7_).name] = true;
                     }
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
      }
      
      private function allocateMask(param1:uint) : DisplayObject
      {
         var _loc4_:BitmapAsset = null;
         var _loc5_:Bitmap = null;
         var _loc2_:Array = [this.m_selectionMaskMedium,this.m_selectionMaskLarge];
         var _loc3_:Array = [this.SIZE_MEDIUM,this.SIZE_MEDIUM,this.SIZE_MEDIUM,this.SIZE_LARGE,this.SIZE_LARGE];
         param1 = uint(_loc3_[param1]);
         if(this.m_maskCacheUseCounts[param1] >= this.m_maskCache[param1].length)
         {
            _loc4_ = new _loc2_[param1]();
            _loc5_ = new Bitmap(_loc4_.bitmapData);
            _loc5_.width *= 8;
            _loc5_.height *= 8;
            _loc5_.x -= _loc5_.width / 2;
            _loc5_.y -= _loc5_.height / 2;
            _loc5_.cacheAsBitmap = true;
            this.m_maskCache[param1].push(_loc5_);
         }
         return this.m_maskCache[param1][this.m_maskCacheUseCounts[param1]++];
      }
      
      private function addMask(param1:IEntity, param2:Point) : void
      {
         var _loc4_:IsoSpriteComponent = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:DisplayObject = null;
         var _loc7_:Point = null;
         var _loc3_:BuildingSpatialComponent = BuildingSpatialComponent(param1.lookupComponentByType(BuildingSpatialComponent));
         if(_loc3_.volume.z >= this.m_targetHeight)
         {
            if(this.m_targetTerrainType == BuildManager.instance.PAVING_STR)
            {
               _loc5_ = GameDataComponent.getGameDataComponent(param1);
               if(_loc5_.gameData.terrainType == BuildManager.instance.PAVING_STR)
               {
                  return;
               }
            }
            _loc4_ = IsoSpriteComponent(param1.lookupComponentByType(IsoSpriteComponent));
            if(_loc4_)
            {
               _loc6_ = this.allocateMask(_loc3_.volume.x / ZGlobal.cellSize);
               _loc7_ = new Point(param2.x,param2.y);
               _loc7_.x -= _loc4_.isoSprite.container.x;
               _loc7_.y -= _loc4_.isoSprite.container.y;
               _loc6_.x = _loc7_.x;
               _loc6_.y = _loc7_.y;
               _loc6_.x -= _loc6_.width * 0.5;
               _loc6_.y -= _loc6_.height * 0.5;
               _loc4_.setMask(_loc6_);
               this.m_obscurers.push(_loc4_);
            }
         }
      }
      
      private function removeMasks() : void
      {
         var _loc3_:IsoSpriteComponent = null;
         var _loc4_:uint = 0;
         if(this.m_obscurers)
         {
            for each(_loc3_ in this.m_obscurers)
            {
               _loc3_.setMask(null);
            }
         }
         var _loc1_:uint = this.m_maskCacheUseCounts.length;
         var _loc2_:uint = 0;
         while(_loc2_ < _loc1_)
         {
            _loc4_ = 0;
            while(_loc4_ < this.m_maskCacheUseCounts[_loc2_])
            {
               if(this.m_maskCache[_loc2_][_loc4_].parent)
               {
                  this.m_maskCache[_loc2_][_loc4_].x = 0;
                  this.m_maskCache[_loc2_][_loc4_].y = 0;
                  this.m_maskCache[_loc2_][_loc4_].parent.removeChild(this.m_maskCache[_loc2_][_loc4_]);
               }
               _loc4_++;
            }
            this.m_maskCacheUseCounts[_loc2_] = 0;
            _loc2_++;
         }
         this.m_obscurers = null;
         this.m_obscurerMap = null;
         this.m_targetTerrainType = null;
      }
   }
}

