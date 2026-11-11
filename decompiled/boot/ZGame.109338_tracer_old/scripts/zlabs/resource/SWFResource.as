package zlabs.resource
{
   import flash.display.*;
   import flash.geom.*;
   import flash.system.ApplicationDomain;
   
   public class SWFResource extends Resource
   {
      
      private var _clip:MovieClip;
      
      private var _sprite:Sprite;
      
      private var _appDomain:ApplicationDomain;
      
      public function SWFResource()
      {
         super();
      }
      
      public function get clip() : MovieClip
      {
         return this._clip;
      }
      
      public function get sprite() : Sprite
      {
         return this._sprite;
      }
      
      public function get appDomain() : ApplicationDomain
      {
         return this._appDomain;
      }
      
      public function getExportedAsset(param1:String) : Object
      {
         if(null == this._appDomain)
         {
            throw new Error("not initialized");
         }
         var _loc2_:Class = this.getAssetClass(param1);
         if(_loc2_ != null)
         {
            return new _loc2_();
         }
         return null;
      }
      
      public function getAssetClass(param1:String) : Class
      {
         if(null == this._appDomain)
         {
            throw new Error("not initialized");
         }
         if(this._appDomain.hasDefinition(param1))
         {
            return this._appDomain.getDefinition(param1) as Class;
         }
         return null;
      }
      
      public function findMaxFrames(param1:MovieClip, param2:int) : int
      {
         var _loc4_:MovieClip = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_) as MovieClip;
            if(_loc4_)
            {
               param2 = Math.max(param2,_loc4_.totalFrames);
               this.findMaxFrames(_loc4_,param2);
            }
            _loc3_++;
         }
         return param2;
      }
      
      public function advanceChildClips(param1:MovieClip, param2:int) : void
      {
         var _loc4_:MovieClip = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_) as MovieClip;
            if(_loc4_)
            {
               if(_loc4_.totalFrames >= param2)
               {
                  _loc4_.gotoAndStop(param2);
               }
               else
               {
                  _loc4_.gotoAndStop(_loc4_.totalFrames);
               }
               this.advanceChildClips(_loc4_,param2);
            }
            _loc3_++;
         }
      }
      
      override public function initialize(param1:*) : void
      {
         if(param1 is MovieClip || param1 is Sprite)
         {
            this.onContentReady(param1);
            onLoadComplete();
            return;
         }
         super.initialize(param1);
      }
      
      override protected function onContentReady(param1:*) : Boolean
      {
         if(param1)
         {
            this._clip = param1 as MovieClip;
            if(this._clip == null)
            {
               this._sprite = param1 as Sprite;
            }
         }
         if(Boolean(resourceLoader) && Boolean(resourceLoader.contentLoaderInfo))
         {
            this._appDomain = resourceLoader.contentLoaderInfo.applicationDomain;
         }
         else if(Boolean(param1) && Boolean(param1.loaderInfo))
         {
            this._appDomain = param1.loaderInfo.applicationDomain;
         }
         return this._clip != null || this._sprite != null;
      }
   }
}

