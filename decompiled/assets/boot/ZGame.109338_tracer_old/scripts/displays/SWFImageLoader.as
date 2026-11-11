package displays
{
   import Engine.Managers.AssetUrlManager;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class SWFImageLoader extends ImageLoader
   {
      
      private static var m_imageCache:Dictionary = new Dictionary();
      
      private var m_imageName:String = null;
      
      private var m_swfPath:String = null;
      
      private var m_cacheName:String = null;
      
      private var m_failedCallback:Function = null;
      
      private var m_useCache:Boolean = true;
      
      public function SWFImageLoader(param1:String, param2:UILoader = null, param3:Function = null, param4:Function = null)
      {
         this.m_failedCallback = param4;
         super(param1,param2,param3);
      }
      
      override public function set useCache(param1:Boolean) : void
      {
         this.m_useCache = param1;
      }
      
      override protected function callLoad(param1:String) : void
      {
         var _loc2_:int = param1.indexOf(".swf");
         this.m_swfPath = param1.substr(0,_loc2_ + 4);
         this.m_imageName = param1.substr(_loc2_ + 5);
         var _loc3_:RegExp = /[a-z0-9_]+\.swf/i;
         var _loc4_:Array = param1.match(_loc3_);
         if(_loc4_.length == 1)
         {
            this.m_cacheName = _loc4_[0] + "/" + this.m_imageName;
         }
         else
         {
            this.m_cacheName = this.m_imageName;
         }
         Zlab.resourceManager.load(AssetUrlManager.instance.lookUpUrl(this.m_swfPath),SWFResource,this.onSWFLoadComplete,this.onSWFLoadFailed);
      }
      
      protected function onSWFLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:BitmapData = null;
         var _loc2_:Class = param1.getAssetClass(this.m_imageName);
         if(_loc2_)
         {
            _loc3_ = null;
            if(this.m_useCache)
            {
               if(null == m_imageCache[this.m_cacheName])
               {
                  m_imageCache[this.m_cacheName] = new _loc2_(1,1) as BitmapData;
               }
               _loc3_ = m_imageCache[this.m_cacheName];
            }
            else
            {
               _loc3_ = new _loc2_(1,1) as BitmapData;
            }
            source = _loc3_;
            callback(this.m_swfPath + "/" + this.m_imageName,_loc3_);
            _loc3_ = null;
         }
         else
         {
            Logger.error(this,"onSWFLoadComplete ","could not find icon: resource:" + param1.filename + ", image: " + this.m_imageName);
            if(null != this.m_failedCallback)
            {
               this.m_failedCallback();
            }
         }
      }
      
      protected function onSWFLoadFailed(param1:SWFResource) : void
      {
         Logger.error(this,"onSWFLoadFailed ","failed to load: " + param1.filename);
      }
   }
}

