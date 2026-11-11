package zlabs.rendering.rendering2D
{
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import zlabs.serialization.Enumerable;
   import zlabs.serialization.ISerializable;
   
   public final class SceneAlignment extends Enumerable implements ISerializable
   {
      
      private static var _typeMap:Dictionary = null;
      
      public static const TOP_LEFT:SceneAlignment = new SceneAlignment();
      
      public static const TOP_RIGHT:SceneAlignment = new SceneAlignment();
      
      public static const BOTTOM_LEFT:SceneAlignment = new SceneAlignment();
      
      public static const BOTTOM_RIGHT:SceneAlignment = new SceneAlignment();
      
      public static const CENTER:SceneAlignment = new SceneAlignment();
      
      public static const DEFAULT_ALIGNMENT:SceneAlignment = CENTER;
      
      public function SceneAlignment()
      {
         super();
      }
      
      public static function calculate(param1:Point, param2:SceneAlignment, param3:int, param4:int) : void
      {
         switch(param2)
         {
            case CENTER:
               param1.x = param3 * 0.5;
               param1.y = param4 * 0.5;
               break;
            case TOP_LEFT:
               param1.x = param1.y = 0;
               break;
            case TOP_RIGHT:
               param1.x = param3;
               param1.y = 0;
               break;
            case BOTTOM_LEFT:
               param1.x = 0;
               param1.y = param4;
               break;
            case BOTTOM_RIGHT:
               param1.x = param3;
               param1.y = param4;
         }
      }
      
      override public function get typeMap() : Dictionary
      {
         if(!_typeMap)
         {
            _typeMap = new Dictionary();
            _typeMap["TOP_LEFT"] = TOP_LEFT;
            _typeMap["TOP_RIGHT"] = TOP_RIGHT;
            _typeMap["BOTTOM_LEFT"] = BOTTOM_LEFT;
            _typeMap["BOTTOM_RIGHT"] = BOTTOM_RIGHT;
            _typeMap["CENTER"] = CENTER;
         }
         return _typeMap;
      }
      
      override public function get defaultType() : Enumerable
      {
         return CENTER;
      }
   }
}

