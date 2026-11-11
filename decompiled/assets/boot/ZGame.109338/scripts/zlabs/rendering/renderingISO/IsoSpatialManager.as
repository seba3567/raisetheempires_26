package zlabs.rendering.renderingISO
{
   import as3isolib.bounds.IBounds;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.Zlab;
   import zlabs.core.ObjectType;
   import zlabs.rendering.rendering2D.BasicSpatialManager2D;
   
   public class IsoSpatialManager extends BasicSpatialManager2D implements ISpatialManagerISO
   {
      
      public var sortOnProps:Array = ["y","x","z"];
      
      public function IsoSpatialManager()
      {
         super();
      }
      
      public function objectsCollidesWith(param1:ISpatialObjectISO, param2:Array, param3:ObjectType, param4:ObjectType) : Boolean
      {
         var _loc7_:ISpatialObjectISO = null;
         var _loc8_:IBounds = null;
         var _loc5_:Boolean = false;
         var _loc6_:IBounds = param1.isoBounds;
         for each(_loc7_ in _objectList)
         {
            if(param1 !== _loc7_)
            {
               if(param3 != null)
               {
                  if(Zlab.objectTypeManager.doTypesOverlap(_loc7_.objectMask,param3))
                  {
                     continue;
                  }
               }
               if(param4 != null)
               {
                  if(!Zlab.objectTypeManager.doTypesOverlap(_loc7_.objectMask,param4))
                  {
                     continue;
                  }
               }
               _loc8_ = _loc7_.isoBounds;
               if(_loc8_.collide(_loc6_))
               {
                  param2.push(_loc7_);
                  _loc5_ = true;
               }
            }
         }
         return _loc5_;
      }
      
      public function getIsoObjectsUnderPoint(param1:Point, param2:Array, param3:ObjectType = null) : Boolean
      {
         var _loc6_:ISpatialObjectISO = null;
         var _loc4_:Array = new Array();
         if(!this.queryBounds(param1,64,param3,_loc4_))
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
         if(_loc5_)
         {
            this.sortSpatials(param2);
         }
         return _loc5_;
      }
      
      public function sortSpatials(param1:Array) : void
      {
         param1.sortOn(this.sortOnProps,Array.NUMERIC | Array.DESCENDING);
      }
      
      public function queryBounds(param1:Point, param2:Number, param3:ObjectType, param4:Array) : Boolean
      {
         var _loc6_:ISpatialObjectISO = null;
         var _loc7_:Rectangle = null;
         var _loc5_:Boolean = false;
         for each(_loc6_ in _objectList)
         {
            if(param3 != null)
            {
               if(!Zlab.objectTypeManager.doTypesOverlap(_loc6_.objectMask,param3))
               {
                  continue;
               }
            }
            _loc7_ = _loc6_.bounds;
            if(_loc7_.containsPoint(param1))
            {
               param4.push(_loc6_);
               _loc5_ = true;
            }
         }
         return _loc5_;
      }
   }
}

