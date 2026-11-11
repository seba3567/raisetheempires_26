package zlabs.utils.quadTree
{
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   import zlabs.managers.IPositionItem;
   
   public class QuadTreePositionItem extends Vector3D implements IPositionItem
   {
      
      private var _parent:Object;
      
      private var _depth:int = -1;
      
      private var _footprint:Number = 1;
      
      public var inserted:Boolean = false;
      
      public function QuadTreePositionItem(param1:Object, param2:Number)
      {
         super();
         this._parent = param1;
         this._footprint = param2;
      }
      
      public function isoSpriteIndex() : int
      {
         var _loc1_:Sprite = this._parent.getIsoSprite().container;
         return _loc1_.parent.getChildIndex(_loc1_);
      }
      
      public function get distance() : Number
      {
         return length + this._footprint;
      }
      
      public function get screenY() : Number
      {
         if(this._parent)
         {
            return this._parent.screenY;
         }
         return 0;
      }
      
      public function get position() : Vector3D
      {
         return this;
      }
      
      public function get depth() : int
      {
         return this._depth;
      }
      
      public function set depth(param1:int) : void
      {
         this._depth = param1;
      }
      
      public function set position(param1:Vector3D) : void
      {
         x = param1.x;
         y = param1.y;
         z = param1.z;
      }
      
      public function destroy() : void
      {
         this._parent = null;
      }
      
      public function get parent() : Object
      {
         return this._parent;
      }
   }
}

