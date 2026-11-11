package zlabs.sound
{
   import flash.media.SoundTransform;
   
   public final class SoundCategory
   {
      
      public var dirty:Boolean = false;
      
      public var muted:Boolean = false;
      
      public var transform:SoundTransform = new SoundTransform();
      
      public function SoundCategory()
      {
         super();
      }
      
      public static function applyCategoriesToTransform(param1:Boolean, param2:Number, param3:Number, ... rest) : SoundTransform
      {
         var _loc7_:SoundCategory = null;
         var _loc5_:int = 0;
         while(_loc5_ < rest.length)
         {
            _loc7_ = rest[_loc5_] as SoundCategory;
            if(_loc7_)
            {
               if(_loc7_.muted)
               {
                  param1 = true;
               }
               param3 *= _loc7_.transform.volume;
               param2 += _loc7_.transform.pan;
            }
            _loc5_++;
         }
         var _loc6_:SoundTransform = new SoundTransform();
         _loc6_.volume = param1 ? 0 : param3;
         _loc6_.pan = param2;
         return _loc6_;
      }
   }
}

