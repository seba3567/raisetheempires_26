package core.tilemap
{
   import core.ZGlobal;
   import flash.display.BitmapData;
   import flash.display.BitmapDataChannel;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class Tileset extends EventDispatcher
   {
      
      private var m_xml:XML = null;
      
      private var m_tileAnimations:Dictionary = null;
      
      private var m_buildData:Dictionary = null;
      
      private var m_resource:SWFResource = null;
      
      private var m_loader:URLLoader = null;
      
      private var m_noiseBitmapData:BitmapData = null;
      
      private var m_tileWidth:int = 0;
      
      private var m_numTiles:int = 0;
      
      private var m_numTilesLoaded:int = 0;
      
      private var m_loadFunctions:Array = null;
      
      public function Tileset()
      {
         super();
      }
      
      public function load(param1:XML) : void
      {
         var _loc2_:XML = null;
         this.m_xml = param1;
         this.m_loadFunctions = new Array();
         this.m_buildData = new Dictionary();
         this.m_tileAnimations = new Dictionary();
         for each(_loc2_ in this.m_xml.tile)
         {
            this.loadBuildData(_loc2_);
            ++this.m_numTiles;
         }
         Zlab.resourceManager.load(ZGlobal.getAssetURL(this.m_xml.@url.toString()),SWFResource,this.onSWFLoaded,this.onSWFFailed);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function dispose() : void
      {
         var _loc1_:TileAnimation = null;
         for each(_loc1_ in this.m_tileAnimations)
         {
            _loc1_.dispose();
         }
         this.m_tileAnimations = null;
         this.m_noiseBitmapData = null;
         this.m_xml = null;
      }
      
      private function onSWFLoaded(param1:SWFResource) : void
      {
         this.m_resource = param1;
         if(TilesetManager.ANIMATING_WATER)
         {
            this.m_loader = new URLLoader();
            this.m_loader.dataFormat = URLLoaderDataFormat.BINARY;
            this.m_loader.addEventListener(Event.COMPLETE,this.onPBJComplete);
            this.m_loader.load(new URLRequest(ZGlobal.getAssetURL("assets/game/terrain/OceanFilter.pbj")));
         }
         else
         {
            this.onPBJComplete(null);
         }
      }
      
      private function onPBJComplete(param1:Event) : void
      {
         var _loc2_:XML = null;
         var _loc3_:TileAnimation = null;
         var _loc4_:Class = null;
         if(TilesetManager.ANIMATING_WATER)
         {
            _loc4_ = this.m_resource.getAssetClass("Noise.png");
            if(_loc4_)
            {
               this.m_noiseBitmapData = new _loc4_(1,1) as BitmapData;
            }
         }
         for each(_loc2_ in this.m_xml.tile)
         {
            this.createTileAnimation(_loc2_);
         }
         for each(_loc3_ in this.m_tileAnimations)
         {
            _loc3_.addEventListener(Event.COMPLETE,this.tileAnimationLoaded);
            _loc3_.load(TilesetManager.ANIMATING_WATER ? param1.target.data : null);
         }
      }
      
      private function createTileAnimation(param1:XML) : void
      {
         var _loc9_:Object = null;
         var _loc2_:Class = this.m_resource.getAssetClass("terrain_mask.png");
         var _loc3_:BitmapData = new _loc2_(1,1) as BitmapData;
         var _loc4_:Class = this.m_resource.getAssetClass(param1.@type + ".png");
         var _loc5_:BitmapData = new _loc4_(1,1) as BitmapData;
         var _loc6_:BitmapData = null;
         var _loc7_:BitmapData = new BitmapData(_loc5_.width,_loc5_.height,true);
         _loc7_.copyPixels(_loc5_,_loc5_.rect,new Point(0,0));
         _loc7_.copyChannel(_loc3_,_loc3_.rect,new Point(0,0),BitmapDataChannel.ALPHA,BitmapDataChannel.ALPHA);
         _loc5_ = _loc7_;
         _loc7_ = null;
         if(TilesetManager.ANIMATING_WATER)
         {
            _loc4_ = this.m_resource.getAssetClass(param1.@type + "_Mask.jpg");
            if(_loc4_)
            {
               _loc6_ = new _loc4_(1,1) as BitmapData;
            }
         }
         this.m_tileAnimations[param1.@type.toString()] = new TileAnimation(_loc5_,_loc6_,this.m_noiseBitmapData);
         var _loc8_:* = 0;
         while(_loc8_ < this.m_loadFunctions.length)
         {
            _loc9_ = this.m_loadFunctions[_loc8_];
            if(_loc9_.type == param1.@type)
            {
               _loc9_.func(this.m_tileAnimations[_loc9_.type]);
               this.m_loadFunctions.splice(_loc8_,1);
               _loc8_--;
            }
            _loc8_++;
         }
      }
      
      private function tileAnimationLoaded(param1:Event) : void
      {
         if(param1)
         {
            param1.target.removeEventListener(Event.COMPLETE,this.tileAnimationLoaded);
         }
         ++this.m_numTilesLoaded;
         if(this.m_numTiles == this.m_numTilesLoaded)
         {
            this.m_loader = null;
            this.m_resource = null;
            this.m_noiseBitmapData = null;
         }
      }
      
      private function loadBuildData(param1:XML) : void
      {
         var _loc9_:int = 0;
         var _loc2_:String = param1.@data.toString();
         var _loc3_:Array = _loc2_.split(",");
         var _loc4_:Number = _loc3_.length;
         this.m_tileWidth = Math.sqrt(_loc4_);
         var _loc5_:Array = new Array(this.m_tileWidth);
         var _loc6_:int = 0;
         while(_loc6_ < this.m_tileWidth)
         {
            _loc5_[_loc6_] = new Array(this.m_tileWidth);
            _loc6_++;
         }
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         while(_loc8_ < this.m_tileWidth)
         {
            _loc9_ = 0;
            while(_loc9_ < this.m_tileWidth)
            {
               _loc5_[_loc9_][_loc8_] = _loc3_[_loc7_];
               _loc9_++;
               _loc7_++;
            }
            _loc8_++;
         }
         this.m_buildData[param1.@type.toString()] = _loc5_;
      }
      
      protected function onSWFFailed(param1:SWFResource) : void
      {
         Logger.error(this,"Tileset:onSWFFailed","Failed to load \'" + (param1 ? param1.filename : "(unknown)") + "\'");
      }
      
      public function loadTileAnimation(param1:String, param2:Function) : void
      {
         if(null != this.m_tileAnimations[param1])
         {
            param2(this.m_tileAnimations[param1]);
         }
         else if(null == this.m_resource)
         {
            this.m_loadFunctions.push({
               "func":param2,
               "type":param1
            });
         }
         else
         {
            Logger.error(this,"loadTileAnimation","unable to find type " + param1);
         }
      }
      
      public function getBuildData(param1:String, param2:int, param3:int) : String
      {
         return this.m_buildData[param1][param2][param3];
      }
      
      public function get tileWidth() : int
      {
         return this.m_tileWidth;
      }
   }
}

