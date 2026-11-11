package rendering.rendering2d
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class SpriteClock extends Sprite
   {
      
      private var m_parent:Sprite = null;
      
      private var m_mask:Bitmap = null;
      
      private var m_segments:Array = null;
      
      private var m_percent:Number = 0;
      
      public function SpriteClock(param1:Sprite)
      {
         super();
         this.m_parent = param1;
         this.m_mask = new Bitmap(new BitmapData(this.m_parent.width,this.m_parent.height));
         var _loc2_:Number = this.m_parent.width * 0.5;
         var _loc3_:Number = this.m_parent.height * 0.5;
         var _loc4_:Array = [new Point(_loc2_,_loc3_),new Point(_loc2_,-_loc3_),new Point(_loc2_ * 3,_loc3_),new Point(_loc2_,_loc3_ * 3),new Point(-_loc2_,_loc3_)];
         this.m_segments = [[_loc4_[0],_loc4_[1],_loc4_[2]],[_loc4_[0],_loc4_[2],_loc4_[3]],[_loc4_[0],_loc4_[3],_loc4_[4]],[_loc4_[0],_loc4_[4],_loc4_[1]]];
         this.m_parent.addChild(this.m_mask);
         this.m_parent.addChild(this);
         mask = this.m_mask;
      }
      
      public function dispose() : void
      {
         this.m_parent.removeChild(this);
         this.m_parent.removeChild(this.m_mask);
         this.m_parent = null;
         this.m_mask = null;
      }
      
      public function set percent(param1:Number) : void
      {
         this.m_percent = param1;
         this.createClock();
      }
      
      private function createClock() : void
      {
         var _loc8_:Array = null;
         var _loc1_:Number = this.m_parent.width * 0.5;
         var _loc2_:Number = this.m_parent.height * 0.5;
         var _loc3_:Number = this.m_percent * (Math.PI * 2) - Math.PI * 0.5;
         var _loc4_:Number = _loc1_ + Math.cos(_loc3_) * this.m_parent.width;
         var _loc5_:Number = _loc2_ + Math.sin(_loc3_) * this.m_parent.height;
         graphics.clear();
         graphics.beginFill(0,0.5);
         var _loc6_:int = int(this.m_percent * 4);
         var _loc7_:int = 0;
         for each(_loc8_ in this.m_segments)
         {
            if(_loc7_ >= _loc6_)
            {
               graphics.moveTo(_loc8_[0].x,_loc8_[0].y);
               if(_loc7_ == _loc6_)
               {
                  graphics.lineTo(_loc4_,_loc5_);
               }
               else
               {
                  graphics.lineTo(_loc8_[1].x,_loc8_[1].y);
               }
               graphics.lineTo(_loc8_[2].x,_loc8_[2].y);
            }
            _loc7_++;
         }
         graphics.endFill();
      }
   }
}

