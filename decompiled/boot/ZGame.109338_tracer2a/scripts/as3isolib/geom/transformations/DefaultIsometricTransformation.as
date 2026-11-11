package as3isolib.geom.transformations
{
   import as3isolib.geom.Pt;
   
   public class DefaultIsometricTransformation implements IAxonometricTransformation
   {
      
      private var radians:Number;
      
      private var ratio:Number = 2;
      
      private var bAxonometricAxesProjection:Boolean;
      
      private var bMaintainZAxisRatio:Boolean;
      
      private var axialProjection:Number = Math.cos(Math.atan(0.5));
      
      public function DefaultIsometricTransformation(param1:Boolean = false, param2:Boolean = false)
      {
         super();
         this.bAxonometricAxesProjection = param1;
         this.bMaintainZAxisRatio = param2;
      }
      
      public function screenToSpace(param1:Pt, param2:Pt = null) : Pt
      {
         var _loc3_:Number = param1.z;
         var _loc4_:Number = param1.y - param1.x / this.ratio + param1.z;
         var _loc5_:Number = param1.x / this.ratio + param1.y + param1.z;
         if(!this.bAxonometricAxesProjection && this.bMaintainZAxisRatio)
         {
            _loc3_ *= this.axialProjection;
         }
         if(this.bAxonometricAxesProjection)
         {
            _loc5_ /= this.axialProjection;
            _loc4_ /= this.axialProjection;
         }
         if(null == param2)
         {
            return new Pt(_loc5_,_loc4_,_loc3_);
         }
         param2.x = _loc5_;
         param2.y = _loc4_;
         param2.z = _loc3_;
         return param2;
      }
      
      public function spaceToScreen(param1:Pt) : Pt
      {
         if(!this.bAxonometricAxesProjection && this.bMaintainZAxisRatio)
         {
            param1.z /= this.axialProjection;
         }
         if(this.bAxonometricAxesProjection)
         {
            param1.x *= this.axialProjection;
            param1.y *= this.axialProjection;
         }
         var _loc2_:Number = param1.z;
         var _loc3_:Number = (param1.x + param1.y) / this.ratio - param1.z;
         var _loc4_:Number = param1.x - param1.y;
         return new Pt(_loc4_,_loc3_,_loc2_);
      }
   }
}

