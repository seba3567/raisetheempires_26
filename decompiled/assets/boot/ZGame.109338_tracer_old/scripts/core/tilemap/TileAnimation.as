package core.tilemap
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shader;
   import flash.display.ShaderJob;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class TileAnimation extends EventDispatcher
   {
      
      private var m_bitmapDatas:Array = null;
      
      private var m_numFrames:Number = 0;
      
      public function TileAnimation(param1:BitmapData, param2:BitmapData, param3:BitmapData)
      {
         super();
         this.m_bitmapDatas = [param1,param2,param3];
      }
      
      public function get rgbBitmapData() : BitmapData
      {
         return this.m_bitmapDatas[0];
      }
      
      public function get maskBitmapData() : BitmapData
      {
         return this.m_bitmapDatas[1];
      }
      
      public function get noiseBitmapData() : BitmapData
      {
         return this.m_bitmapDatas[2];
      }
      
      private function generateShaderAnimation(param1:ByteArray) : void
      {
         var _loc11_:Bitmap = null;
         var _loc12_:ShaderJob = null;
         var _loc2_:Rectangle = new Rectangle(0,0,this.maskBitmapData.width,this.maskBitmapData.height);
         var _loc3_:BitmapData = new BitmapData(_loc2_.width,_loc2_.height,false,0);
         _loc3_.lock();
         _loc3_.copyChannel(this.noiseBitmapData,_loc2_,new Point(0,0),1,2);
         _loc3_.copyChannel(this.maskBitmapData,_loc2_,new Point(0,0),1,1);
         _loc3_.unlock();
         var _loc4_:Number = this.rgbBitmapData.width;
         var _loc5_:Number = this.rgbBitmapData.height;
         var _loc6_:Shader = new Shader(param1);
         _loc6_.data.srcImage.input = this.rgbBitmapData;
         _loc6_.data.srcHelperImage.input = _loc3_;
         var _loc7_:Number = 0;
         var _loc8_:Number = 1 / this.m_numFrames;
         this.m_bitmapDatas = new Array();
         var _loc9_:int = int(this.m_numFrames);
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc11_ = new Bitmap(new BitmapData(_loc4_,_loc5_));
            _loc6_.data.phase.value = [_loc7_];
            _loc12_ = new ShaderJob();
            _loc12_.target = _loc11_.bitmapData;
            _loc12_.shader = _loc6_;
            _loc12_.start(true);
            this.m_bitmapDatas.push(_loc11_.bitmapData);
            _loc10_++;
            _loc7_ += _loc8_;
         }
         _loc3_ = null;
      }
      
      public function load(param1:ByteArray) : void
      {
         if(Boolean(TilesetManager.ANIMATING_WATER) && Boolean(this.maskBitmapData) && Boolean(this.noiseBitmapData))
         {
            this.m_numFrames = 35;
            this.generateShaderAnimation(param1);
         }
         else
         {
            this.m_numFrames = 1;
            this.m_bitmapDatas[1] = null;
            this.m_bitmapDatas[2] = null;
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function getFrame(param1:int) : BitmapData
      {
         return this.m_bitmapDatas[param1];
      }
      
      public function get frames() : int
      {
         return this.m_numFrames;
      }
      
      public function dispose() : void
      {
         this.m_bitmapDatas = null;
      }
   }
}

