package as3isolib.display
{
   import as3isolib.core.IsoDisplayObject;
   import as3isolib.core.as3isolib_internal;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import mx.core.IFactory;
   
   use namespace as3isolib_internal;
   
   public class IsoSprite extends IsoDisplayObject
   {
      
      protected var spritesArray:Array = [];
      
      protected var actualSpriteObjects:Array = [];
      
      as3isolib_internal var bSpritesInvalidated:Boolean = false;
      
      public function IsoSprite(param1:Object = null)
      {
         super(param1);
      }
      
      public function get sprites() : Array
      {
         return this.spritesArray;
      }
      
      public function set sprites(param1:Array) : void
      {
         if(this.spritesArray != param1)
         {
            this.spritesArray = param1;
            this.bSpritesInvalidated = true;
         }
      }
      
      public function get actualSprites() : Array
      {
         return this.actualSpriteObjects.slice();
      }
      
      public function invalidateSkins() : void
      {
         this.bSpritesInvalidated = true;
      }
      
      public function invalidateSprites() : void
      {
         this.bSpritesInvalidated = true;
      }
      
      override public function get isInvalidated() : Boolean
      {
         return bPositionInvalidated || this.bSpritesInvalidated;
      }
      
      override protected function renderLogic(param1:Boolean = true) : void
      {
         if(this.bSpritesInvalidated)
         {
            this.renderSprites();
            this.bSpritesInvalidated = false;
         }
         super.renderLogic(param1);
      }
      
      protected function renderSprites() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Bitmap = null;
         var _loc3_:DisplayObject = null;
         this.actualSpriteObjects = [];
         while(mainContainer.numChildren > 0)
         {
            mainContainer.removeChildAt(0);
         }
         for each(_loc1_ in this.spritesArray)
         {
            if(_loc1_ is BitmapData)
            {
               _loc2_ = new Bitmap(BitmapData(_loc1_));
               _loc2_.cacheAsBitmap = true;
               mainContainer.addChild(_loc2_);
               this.actualSpriteObjects.push(_loc2_);
            }
            else if(_loc1_ is DisplayObject)
            {
               mainContainer.addChild(DisplayObject(_loc1_));
               this.actualSpriteObjects.push(_loc1_);
            }
            else if(_loc1_ is Class)
            {
               _loc3_ = DisplayObject(new _loc1_());
               mainContainer.addChild(_loc3_);
               this.actualSpriteObjects.push(_loc3_);
            }
            else
            {
               if(!(_loc1_ is IFactory))
               {
                  throw new Error("skin asset is not of the following types: BitmapData, DisplayObject, ISpriteAsset, IFactory or Class cast as DisplayOject.");
               }
               _loc3_ = DisplayObject(IFactory(_loc1_).newInstance());
               mainContainer.addChild(_loc3_);
               this.actualSpriteObjects.push(_loc3_);
            }
         }
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         mainContainer = new MovieClip();
      }
   }
}

