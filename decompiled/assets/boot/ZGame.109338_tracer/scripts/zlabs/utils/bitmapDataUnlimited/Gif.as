package zlabs.utils.bitmapDataUnlimited
{
   import flash.utils.ByteArray;
   
   public class Gif
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _colorTable:ByteArray;
      
      private var _colorTableSize:int = 7;
      
      private var _transparent:Boolean;
      
      private var _transparentIndex:int = 0;
      
      private var _fillColor:uint;
      
      private var _binaryGif:ByteArray;
      
      public function Gif(param1:int, param2:int, param3:Boolean = false, param4:uint = 4294967295)
      {
         super();
         this._width = param1;
         this._height = param2;
         this._transparent = param3;
         this._fillColor = param4;
         this.initialize();
      }
      
      public function get bytes() : ByteArray
      {
         return this._binaryGif;
      }
      
      private function initialize() : void
      {
         this._binaryGif = new ByteArray();
         this.writeHeader();
         this.writeLogicalScreenDescriptor();
         this.writeColorTable();
         this.writeGraphicControlExtensionBlock();
         this.writeImageBlock();
         this.writeTrailer();
      }
      
      private function writeHeader() : void
      {
         this._binaryGif.writeUTFBytes("GIF89a");
      }
      
      private function writeLogicalScreenDescriptor() : void
      {
         this.writeShort(this._width);
         this.writeShort(this._height);
         this._binaryGif.writeByte(0x80 | 0x70 | 0 | this._colorTableSize);
         this._binaryGif.writeByte(0);
         this._binaryGif.writeByte(0);
      }
      
      private function writeColorTable() : void
      {
         this._colorTable = new ByteArray();
         this._colorTable[0] = this._fillColor >> 16 & 0xFF;
         this._colorTable[1] = this._fillColor >> 8 & 0xFF;
         this._colorTable[2] = this._fillColor & 0xFF;
         this._binaryGif.writeBytes(this._colorTable,0,this._colorTable.length);
         var _loc1_:int = 0;
         var _loc2_:int = 3 * 256 - this._colorTable.length;
         while(_loc1_ < _loc2_)
         {
            this._binaryGif.writeByte(0);
            _loc1_++;
         }
      }
      
      private function writeGraphicControlExtensionBlock() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         this._binaryGif.writeByte(33);
         this._binaryGif.writeByte(249);
         this._binaryGif.writeByte(4);
         if(this._transparent)
         {
            _loc1_ = 1;
            _loc2_ = 2;
         }
         else
         {
            _loc1_ = 0;
            _loc2_ = 0;
         }
         _loc2_ <<= 2;
         this._binaryGif.writeByte(0 | _loc2_ | 0 | _loc1_);
         this.writeShort(0);
         this._binaryGif.writeByte(this._transparentIndex);
         this._binaryGif.writeByte(0);
      }
      
      private function writeImageBlock() : void
      {
         this._binaryGif.writeByte(44);
         this.writeShort(0);
         this.writeShort(0);
         this.writeShort(this._width);
         this.writeShort(this._height);
         this._binaryGif.writeByte(0);
      }
      
      private function writeTrailer() : void
      {
         this._binaryGif.writeByte(59);
      }
      
      private function writeShort(param1:int) : void
      {
         this._binaryGif.writeByte(param1 & 0xFF);
         this._binaryGif.writeByte(param1 >> 8 & 0xFF);
      }
      
      public function dispose() : void
      {
         this._binaryGif.length = 0;
         this._binaryGif = null;
      }
   }
}

