package zlabs.displays.cinema
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   
   public class MoviePlayer extends Loader
   {
      
      public var url:String;
      
      private var clip:MovieClip;
      
      public function MoviePlayer()
      {
         super();
      }
      
      public function loadAndPlay(param1:String) : void
      {
         this.url = param1;
         var _loc2_:URLRequest = new URLRequest(param1);
         contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete,false,0,true);
         contentLoaderInfo.addEventListener(Event.INIT,this.onInit,false,0,true);
         contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress,false,0,true);
         Security.allowDomain("*");
         var _loc3_:SecurityDomain = null;
         if(Security.sandboxType == Security.REMOTE)
         {
            _loc3_ = SecurityDomain.currentDomain;
         }
         load(_loc2_,new LoaderContext(false,ApplicationDomain.currentDomain,_loc3_));
      }
      
      private function onComplete(param1:Event) : void
      {
         contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
         contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         dispatchEvent(param1);
      }
      
      private function onInit(param1:Event) : void
      {
         contentLoaderInfo.removeEventListener(Event.INIT,this.onInit);
         this.clip = content as MovieClip;
         dispatchEvent(param1);
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
      
      public function gotoAndPlay(param1:int) : void
      {
         this.clip.gotoAndPlay(param1);
      }
      
      public function get currentFrame() : int
      {
         return this.clip.currentFrame;
      }
      
      public function get totalFrames() : int
      {
         return this.clip.totalFrames;
      }
      
      public function play() : void
      {
         this.clip.play();
      }
      
      public function stop() : void
      {
         if(this.clip)
         {
            this.clip.stop();
         }
      }
      
      public function fastForward() : void
      {
      }
      
      public function rewind() : void
      {
      }
      
      public function dispose() : void
      {
         if(contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS))
         {
            contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         }
         if(contentLoaderInfo.hasEventListener(Event.COMPLETE))
         {
            contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
         }
         if(contentLoaderInfo.hasEventListener(Event.INIT))
         {
            contentLoaderInfo.removeEventListener(Event.INIT,this.onInit);
         }
         this.stop();
         this.clip = null;
         unload();
      }
   }
}

