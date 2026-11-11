package zlabs.utils
{
   import flash.geom.ColorTransform;
   
   public class ColorsUtil
   {
      
      public function ColorsUtil()
      {
         super();
      }
      
      public static function rgbColorTransform(param1:uint, param2:ColorTransform = null) : ColorTransform
      {
         var _loc3_:uint = uint(param1 >> 16);
         var _loc4_:uint = uint(param1 >> 8 & 0xFF);
         var _loc5_:uint = uint(param1 & 0xFF);
         if(!param2)
         {
            param2 = new ColorTransform();
         }
         param2.redMultiplier = _loc3_ / 255;
         param2.greenMultiplier = _loc4_ / 255;
         param2.blueMultiplier = _loc5_ / 255;
         return param2;
      }
   }
}

