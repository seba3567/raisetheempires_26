package zlabs.rendering.rendering2D
{
   import flash.geom.Point;
   
   public final class RayHitInfo
   {
      
      public var time:Number;
      
      public var position:Point;
      
      public var normal:Point;
      
      public var hitObject:ISpatialObject2D;
      
      public function RayHitInfo()
      {
         super();
      }
      
      public function copyFrom(param1:RayHitInfo) : void
      {
         this.time = param1.time;
         if(param1.position)
         {
            this.position = param1.position.clone();
         }
         else
         {
            this.position = null;
         }
         if(param1.normal)
         {
            this.normal = param1.normal.clone();
         }
         else
         {
            this.normal = null;
         }
         this.hitObject = param1.hitObject;
      }
   }
}

