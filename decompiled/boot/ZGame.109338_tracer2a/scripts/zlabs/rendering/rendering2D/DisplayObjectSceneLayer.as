package zlabs.rendering.rendering2D
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class DisplayObjectSceneLayer extends Sprite
   {
      
      public var drawOrderFunction:Function;
      
      public var rendererList:Array = new Array();
      
      internal var needSort:Boolean = false;
      
      public function DisplayObjectSceneLayer()
      {
         super();
         this.drawOrderFunction = defaultSortFunction;
      }
      
      public static function defaultSortFunction(param1:DisplayObjectRenderer, param2:DisplayObjectRenderer) : int
      {
         return param1.zIndex - param2.zIndex;
      }
      
      public function markDirty() : void
      {
         this.needSort = true;
      }
      
      public function onRender() : void
      {
         if(this.needSort)
         {
            this.updateOrder();
            this.needSort = false;
         }
      }
      
      public function updateOrder() : void
      {
         var _loc3_:DisplayObject = null;
         this.rendererList.sort(this.drawOrderFunction);
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.rendererList.length)
         {
            _loc3_ = this.rendererList[_loc2_].displayObject;
            if(getChildAt(_loc2_) != _loc3_)
            {
               _loc1_++;
               setChildIndex(_loc3_,_loc2_);
            }
            _loc2_++;
         }
      }
      
      public function add(param1:DisplayObjectRenderer) : void
      {
         var _loc2_:int = this.rendererList.indexOf(param1);
         if(_loc2_ != -1)
         {
            throw new Error("Already added!");
         }
         this.rendererList.push(param1);
         addChild(param1.displayObject);
         this.markDirty();
      }
      
      public function remove(param1:DisplayObjectRenderer) : void
      {
         var _loc2_:int = this.rendererList.indexOf(param1);
         if(_loc2_ == -1)
         {
            return;
         }
         this.rendererList.splice(_loc2_,1);
         removeChild(param1.displayObject);
      }
   }
}

