package core.managers.animationManager
{
   import core.ZGlobal;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import rendering.rendering2d.ZGameSpriteSheetComponent;
   import zlabs.rendering.rendering2D.spritesheet.FixedSizeDivider;
   import zlabs.utils.StringUtils;
   
   public class Animation
   {
      
      private var m_spriteSheetComponent:ZGameSpriteSheetComponent = null;
      
      private var m_data:XML = null;
      
      private var m_frameRate:Number = 0;
      
      private var m_numFrames:int = 0;
      
      private var m_root:Point = null;
      
      private var m_sounds:Array = null;
      
      private var m_loopCount:int = -1;
      
      private var m_looping:Boolean = true;
      
      private var m_useLastOffset:Boolean = false;
      
      private var m_randomStart:Boolean = true;
      
      private var m_selectable:Boolean = true;
      
      private var m_pausable:Boolean = false;
      
      public function Animation(param1:XML)
      {
         var _loc3_:XML = null;
         super();
         this.m_data = param1;
         this.m_frameRate = parseFloat(this.m_data.@fps);
         this.m_numFrames = parseInt(this.m_data.@numFrames);
         this.m_root = StringUtils.parsePoint(this.m_data.root.@position.toString());
         this.m_useLastOffset = this.m_data.@useLastOffset.toString().length > 0;
         this.m_randomStart = this.m_data.@randomStart == undefined || this.m_data.@randomStart == "true";
         this.m_selectable = this.m_data.@selectable == undefined || this.m_data.@selectable == "true";
         this.m_pausable = this.m_data.@pausable == "true";
         var _loc2_:String = this.m_data.@loopCount;
         if(_loc2_.toString().length > 0)
         {
            this.m_loopCount = int(_loc2_);
         }
         if(this.m_data.@doNotLoop.toString() == "true")
         {
            this.m_looping = false;
         }
         if(this.m_data.sound.length() > 0)
         {
            this.m_sounds = new Array();
            for each(_loc3_ in this.m_data.sound)
            {
               this.m_sounds.push({
                  "name":_loc3_.@name.toString(),
                  "frame":parseInt(_loc3_.@frame.toString())
               });
            }
         }
      }
      
      public function loadImageData() : void
      {
         this.m_spriteSheetComponent = new ZGameSpriteSheetComponent();
         this.m_spriteSheetComponent.imageFilename = ZGlobal.getAssetURL(this.url);
         var _loc1_:FixedSizeDivider = new FixedSizeDivider();
         _loc1_.width = parseFloat(this.m_data.@frameWidth);
         _loc1_.height = parseFloat(this.m_data.@frameHeight);
         this.m_spriteSheetComponent.divider = _loc1_;
      }
      
      public function get loopCount() : int
      {
         return this.m_loopCount;
      }
      
      public function get looping() : Boolean
      {
         return this.m_looping;
      }
      
      public function get frameTime() : Number
      {
         return 1 / this.m_frameRate;
      }
      
      public function get randomStart() : Boolean
      {
         return this.m_randomStart;
      }
      
      public function get selectable() : Boolean
      {
         return this.m_selectable;
      }
      
      public function get url() : String
      {
         return this.m_data.asset.@url.toString();
      }
      
      public function get numFrames() : int
      {
         return this.m_numFrames;
      }
      
      public function get rootPoint() : Point
      {
         return this.m_root;
      }
      
      public function get sounds() : Array
      {
         return this.m_sounds;
      }
      
      public function get useLastOffset() : Boolean
      {
         return this.m_useLastOffset;
      }
      
      public function get movie() : Boolean
      {
         var _loc1_:String = null;
         if(this.m_data)
         {
            _loc1_ = this.m_data.@movie.toString();
            return _loc1_.length > 0;
         }
         return false;
      }
      
      public function get pausable() : Boolean
      {
         return this.m_pausable;
      }
      
      public function getData(param1:int) : BitmapData
      {
         if(this.m_data != null)
         {
            this.loadImageData();
            this.m_data = null;
         }
         return this.m_spriteSheetComponent.getFrame(param1);
      }
   }
}

