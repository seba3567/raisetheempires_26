package zlabs.rendering.rendering2D
{
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.Zlab;
   import zlabs.core.ObjectType;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   
   public class BasicSpatialManager2D extends EntityComponent implements ISpatialManager2D
   {
      
      public static const EntitiesDirtyEvent:String = "BasicSpatialManager2D.EntitiesDirty";
      
      protected var _objectList:Array = new Array();
      
      public function BasicSpatialManager2D()
      {
         super();
      }
      
      public function addSpatialObject(param1:ISpatialObject2D) : void
      {
         this._objectList.push(param1);
         if(Boolean(owner) && Boolean(owner.eventDispatcher))
         {
            owner.eventDispatcher.dispatchEvent(new Event(EntitiesDirtyEvent));
         }
      }
      
      public function removeSpatialObject(param1:ISpatialObject2D) : void
      {
         var _loc2_:int = this._objectList.indexOf(param1);
         if(_loc2_ == -1)
         {
            Logger.warn(this,"removeSpatialObject","The object was not found in this spatial manager.");
            return;
         }
         this._objectList.splice(_loc2_,1);
         if(Boolean(owner) && Boolean(owner.eventDispatcher))
         {
            owner.eventDispatcher.dispatchEvent(new Event(EntitiesDirtyEvent));
         }
      }
      
      public function boxVsBox(param1:Rectangle, param2:Rectangle) : Boolean
      {
         return param1.intersects(param2);
      }
      
      public function queryRectangle(param1:Rectangle, param2:ObjectType, param3:Array) : Boolean
      {
         var _loc5_:ISpatialObject2D = null;
         var _loc4_:Boolean = false;
         for each(_loc5_ in this._objectList)
         {
            if(param2 != null)
            {
               if(!Zlab.objectTypeManager.doTypesOverlap(_loc5_.objectMask,param2))
               {
                  continue;
               }
            }
            if(this.boxVsBox(_loc5_.worldExtents,param1))
            {
               param3.push(_loc5_);
               _loc4_ = true;
            }
         }
         return _loc4_;
      }
      
      public function queryCircle(param1:Point, param2:Number, param3:ObjectType, param4:Array) : Boolean
      {
         var _loc8_:ISpatialObject2D = null;
         var _loc5_:Boolean = false;
         var _loc6_:Rectangle = new Rectangle();
         var _loc7_:Rectangle = new Rectangle();
         for each(_loc8_ in this._objectList)
         {
            if(param3 != null)
            {
               if(!Zlab.objectTypeManager.doTypesOverlap(_loc8_.objectMask,param3))
               {
                  continue;
               }
            }
            _loc7_ = _loc8_.worldExtents;
            _loc6_.x = _loc7_.x;
            _loc6_.y = _loc7_.y;
            _loc6_.width = _loc7_.width;
            _loc6_.height = _loc7_.height;
            _loc6_.inflate(param2,param2);
            if(_loc6_.containsPoint(param1))
            {
               param4.push(_loc8_);
               _loc5_ = true;
            }
         }
         return _loc5_;
      }
      
      public function getObjectsUnderPoint(param1:Point, param2:Array, param3:ObjectType = null) : Boolean
      {
         var _loc6_:ISpatialObject2D = null;
         var _loc4_:Array = new Array();
         if(!this.queryCircle(param1,64,param3,_loc4_))
         {
            return false;
         }
         var _loc5_:Boolean = false;
         for each(_loc6_ in _loc4_)
         {
            if(_loc6_.pointOccupied(param1,param3,Zlab.scene))
            {
               param2.push(_loc6_);
               _loc5_ = true;
            }
         }
         if(Zlab.scene)
         {
            Zlab.scene.sortSpatials(param2);
         }
         return _loc5_;
      }
      
      public function castRay(param1:Point, param2:Point, param3:ObjectType, param4:RayHitInfo) : Boolean
      {
         var _loc9_:ISpatialObject2D = null;
         var _loc5_:Array = new Array();
         var _loc6_:Rectangle = new Rectangle(Math.min(param1.x,param2.x) - 0.5,Math.min(param1.y,param2.y) - 0.5,Math.abs(param2.x - param1.x) + 1,Math.abs(param2.y - param1.y) + 1);
         if(!this.queryRectangle(_loc6_,param3,_loc5_))
         {
            return false;
         }
         var _loc7_:RayHitInfo = null;
         var _loc8_:RayHitInfo = new RayHitInfo();
         for each(_loc9_ in _loc5_)
         {
            if(_loc9_.castRay(param1,param2,param3,_loc8_))
            {
               if(!_loc7_)
               {
                  _loc7_ = new RayHitInfo();
                  _loc7_.copyFrom(_loc8_);
               }
               else if(_loc8_.time < _loc7_.time)
               {
                  _loc7_.copyFrom(_loc8_);
               }
            }
         }
         if(_loc7_)
         {
            if(param4)
            {
               param4.copyFrom(_loc7_);
            }
            return true;
         }
         return false;
      }
   }
}

