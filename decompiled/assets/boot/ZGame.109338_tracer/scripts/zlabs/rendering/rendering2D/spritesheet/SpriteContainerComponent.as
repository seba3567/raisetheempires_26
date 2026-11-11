package zlabs.rendering.rendering2D.spritesheet
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import zlabs.entity.EntityComponent;
   
   public class SpriteContainerComponent extends EntityComponent
   {
      
      public var directionsPerFrame:Number = 1;
      
      private var frameNotes:Array;
      
      private var frames:Array = null;
      
      private var numFrames:int = 0;
      
      private var _center:Point = new Point(0,0);
      
      private var _defaultCenter:Boolean = true;
      
      public function SpriteContainerComponent()
      {
         super();
      }
      
      protected function getSourceFrames() : Array
      {
         throw new Error("Not Implemented");
      }
      
      protected function deleteFrames() : void
      {
         this.frames = null;
      }
      
      public function get isLoaded() : Boolean
      {
         return this.frames != null;
      }
      
      public function get center() : Point
      {
         if(!this._center)
         {
            return new Point();
         }
         return this._center;
      }
      
      public function set center(param1:Point) : void
      {
         this._center = param1;
         this._defaultCenter = false;
      }
      
      public function get degreesPerDirection() : Number
      {
         return 360 / this.directionsPerFrame;
      }
      
      public function get rawFrameCount() : int
      {
         if(!this.frames)
         {
            this.buildFrames();
         }
         return this.numFrames;
      }
      
      public function get frameCount() : int
      {
         return this.rawFrameCount / this.directionsPerFrame;
      }
      
      public function getFrame(param1:int, param2:Number = 0) : BitmapData
      {
         var _loc6_:FrameNote = null;
         if(!this.isLoaded)
         {
            return null;
         }
         while(param2 < 0)
         {
            param2 += 360;
         }
         while(param2 > 360)
         {
            param2 -= 360;
         }
         if(this.directionsPerFrame == 1)
         {
            return this.getRawFrame(param1);
         }
         if(this.frameNotes == null)
         {
            this.generateFrameNotes();
         }
         var _loc3_:int = -1;
         var _loc4_:Number = Number.POSITIVE_INFINITY;
         var _loc5_:int = 0;
         while(_loc5_ < this.frameNotes.length)
         {
            _loc6_ = this.frameNotes[_loc5_];
            if(_loc6_.Frame == param1)
            {
               if(Math.abs(_loc6_.Direction - param2) < _loc4_)
               {
                  _loc4_ = Math.abs(_loc6_.Direction - param2);
                  _loc3_ = _loc6_.RawFrame;
               }
            }
            _loc5_++;
         }
         if(_loc3_ >= 0)
         {
            return this.getRawFrame(_loc3_);
         }
         return null;
      }
      
      protected function buildFrames() : void
      {
         this.frames = this.getSourceFrames();
         if(this.frames == null)
         {
            return;
         }
         this.numFrames = this.frames.length;
         if(this.numFrames == 0)
         {
            throw new Error("No frames loaded");
         }
         if(this._defaultCenter)
         {
            this._center = new Point(BitmapData(this.frames[0]).width * 0.5,BitmapData(this.frames[0]).height * 0.5);
         }
      }
      
      protected function getRawFrame(param1:int) : BitmapData
      {
         if(this.frames == null)
         {
            this.buildFrames();
         }
         if(this.frames == null)
         {
            return null;
         }
         if(param1 < 0 || param1 >= this.rawFrameCount)
         {
            return null;
         }
         return this.frames[param1];
      }
      
      private function generateFrameNotes() : void
      {
         var _loc3_:int = 0;
         var _loc4_:FrameNote = null;
         this.frameNotes = new Array();
         var _loc1_:int = this.frameCount / this.degreesPerDirection;
         var _loc2_:int = 0;
         while(_loc2_ < this.directionsPerFrame)
         {
            _loc3_ = 0;
            while(_loc3_ < this.frameCount)
            {
               _loc4_ = new FrameNote();
               _loc4_.Frame = _loc3_;
               _loc4_.Direction = _loc2_ * this.degreesPerDirection;
               _loc4_.RawFrame = _loc2_ * this.frameCount + _loc3_;
               this.frameNotes.push(_loc4_);
               _loc3_++;
            }
            _loc2_++;
         }
      }
   }
}

final class FrameNote
{
   
   public var Frame:int;
   
   public var Direction:Number;
   
   public var RawFrame:int;
   
   public function FrameNote()
   {
      super();
   }
}
