package zlabs.core
{
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ObjectPool
   {
      
      private static var m_instance:ObjectPool;
      
      private var pools:Dictionary = new Dictionary();
      
      private var count:Number = 0;
      
      public function ObjectPool()
      {
         super();
      }
      
      public static function get instance() : ObjectPool
      {
         if(m_instance == null)
         {
            m_instance = new ObjectPool();
         }
         return m_instance;
      }
      
      private function getPool(param1:Class) : Array
      {
         return param1 in this.pools ? this.pools[param1] : (this.pools[param1] = new Array());
      }
      
      public function getObject(param1:Class, ... rest) : *
      {
         var _loc3_:Array = this.getPool(param1);
         if(_loc3_.length > 0)
         {
            return _loc3_.pop();
         }
         return this.construct(param1,rest);
      }
      
      public function disposeObject(param1:*, param2:Class = null) : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:Sprite = null;
         var _loc6_:Shape = null;
         var _loc7_:DisplayObject = null;
         var _loc8_:String = null;
         if(!param1)
         {
            return;
         }
         if(param1 is MovieClip)
         {
            _loc4_ = param1 as MovieClip;
            _loc4_.gotoAndStop(1);
         }
         if(param1 is Sprite)
         {
            _loc5_ = param1 as Sprite;
            _loc5_.graphics.clear();
         }
         if(param1 is Shape)
         {
            _loc6_ = param1 as Shape;
            _loc6_.graphics.clear();
         }
         if(param1 is DisplayObject)
         {
            _loc7_ = param1 as DisplayObject;
            _loc7_.x = 0;
            _loc7_.y = 0;
            _loc7_.alpha = 1;
            _loc7_.blendMode = BlendMode.NORMAL;
            _loc7_.cacheAsBitmap = false;
            _loc7_.filters = [];
            _loc7_.mask = null;
            _loc7_.rotation = 0;
            _loc7_.scaleX = 1;
            _loc7_.scaleY = 1;
            _loc7_.scrollRect = null;
            _loc7_.visible = true;
            _loc7_.transform.matrix = new Matrix();
            _loc7_.transform.colorTransform = new ColorTransform();
         }
         if(!param2)
         {
            _loc8_ = getQualifiedClassName(param1);
            param2 = getDefinitionByName(_loc8_) as Class;
         }
         var _loc3_:Array = this.getPool(param2);
         _loc3_.push(param1);
      }
      
      private function construct(param1:Class, param2:Array) : *
      {
         switch(param2.length)
         {
            case 0:
               return new param1();
            case 1:
               return new param1(param2[0]);
            case 2:
               return new param1(param2[0],param2[1]);
            case 3:
               return new param1(param2[0],param2[1],param2[2]);
            case 4:
               return new param1(param2[0],param2[1],param2[2],param2[3]);
            case 5:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4]);
            case 6:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5]);
            case 7:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6]);
            case 8:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7]);
            case 9:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8]);
            case 10:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9]);
            default:
               return null;
         }
      }
   }
}

