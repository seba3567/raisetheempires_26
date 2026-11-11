package displays
{
   import Engine.Managers.AssetUrlManager;
   import fl.containers.UILoader;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.ImageResource;
   
   public class ImageLoader extends Loader
   {
      
      private var m_uiLoader:UILoader = null;
      
      private var m_callback:Function = null;
      
      private var m_failCallback:Function = null;
      
      private var m_smooth:Boolean = false;
      
      private var m_reverse:Boolean = false;
      
      public function ImageLoader(param1:String, param2:UILoader = null, param3:Function = null, param4:Function = null)
      {
         this.m_uiLoader = param2;
         if(param3 != null)
         {
            this.m_callback = param3;
         }
         this.m_failCallback = param4;
         this.callLoad(param1);
         super();
      }
      
      public function set useCache(param1:Boolean) : void
      {
      }
      
      public function set smooth(param1:Boolean) : void
      {
         this.m_smooth = param1;
      }
      
      public function set reverse(param1:Boolean) : void
      {
         this.m_reverse = param1;
      }
      
      protected function callLoad(param1:String) : void
      {
         Zlab.resourceManager.load(AssetUrlManager.instance.lookUpUrl(param1),ImageResource,this.onLoadComplete,this.onLoadFailed);
      }
      
      protected function onLoadComplete(param1:ImageResource) : void
      {
         this.source = param1.bitmapData;
         this.callback(param1.filename,param1.bitmapData);
      }
      
      protected function set source(param1:BitmapData) : void
      {
         if(this.m_uiLoader)
         {
            this.m_uiLoader.source = new Bitmap(param1);
            this.m_uiLoader.load();
            if(this.m_smooth)
            {
               this.m_uiLoader.source.smoothing = true;
            }
            if(this.m_reverse)
            {
               this.m_uiLoader.source.scaleX = -1;
               this.m_uiLoader.source.x = this.m_uiLoader.source.width;
            }
         }
      }
      
      protected function callback(param1:String, param2:BitmapData) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(param1,param2);
            this.m_callback = null;
         }
      }
      
      protected function onLoadFailed(param1:ImageResource) : void
      {
         Logger.error(this,"onLoadFailed","failed to load: " + param1.filename);
         if(null != this.m_failCallback)
         {
            this.m_failCallback();
            this.m_failCallback = null;
         }
      }
      
      public function destroy() : void
      {
         if(this.m_uiLoader != null)
         {
            this.m_uiLoader.unload();
            this.m_uiLoader = null;
         }
         this.m_callback = null;
         this.m_failCallback = null;
      }
   }
}

