package zlabs.displays.zflex
{
   import flash.display.Sprite;
   
   public class ZSprite extends Sprite
   {
      
      private var m_enabled:Boolean = true;
      
      public var tag:Object;
      
      private var m_name:String;
      
      public function ZSprite()
      {
         super();
      }
      
      public function setName(param1:String) : void
      {
         this.name = param1;
      }
      
      public function getName() : String
      {
         return name;
      }
      
      public function removeAllChildren() : void
      {
         while(this.numChildren)
         {
            this.removeChildAt(0);
         }
      }
      
      public function removeFromParent() : void
      {
         if(Boolean(this.parent) && this.parent is Sprite)
         {
            (this.parent as Sprite).removeChild(this);
         }
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.mouseEnabled = param1;
         this.m_enabled = param1;
      }
      
      public function get enabled() : Boolean
      {
         return this.m_enabled;
      }
      
      public function get children() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc1_.push(getChildAt(_loc2_));
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get centerX() : Number
      {
         return this.x + this.width / 2;
      }
      
      public function set centerX(param1:Number) : void
      {
         this.x = param1 - this.width / 2;
      }
      
      public function get centerY() : Number
      {
         return this.y + this.height / 2;
      }
      
      public function set centerY(param1:Number) : void
      {
         this.y = param1 - this.height / 2;
      }
      
      protected function updateDisplay() : void
      {
      }
      
      public function destroy() : void
      {
      }
   }
}

