package displays.cinema
{
   import events.CinematicsEvent;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.displays.cinema.ICinematic;
   import zlabs.displays.cinema.MoviePlayer;
   import zlabs.resource.Resource;
   import zlabs.sound.SoundManager;
   
   public class Cinematics extends Sprite implements ICinematic
   {
      
      public static var PLAY:String = "cinematicsPlayEvent";
      
      public static var INTERRUPT:String = "cinematicsInterruptEvent";
      
      public static var FAIL:String = "cinematicsFailEvent";
      
      public static var FINISH:String = "cinematicsFinishEvent";
      
      private var currentMovie:MoviePlayer;
      
      public var url:String;
      
      protected var mouseCloseEnabled:Boolean = false;
      
      public var id:String;
      
      private var musicLastState:Boolean;
      
      private var sfxLastState:Boolean;
      
      public function Cinematics(param1:String)
      {
         super();
         this.id = param1;
         this.currentMovie = new MoviePlayer();
         addChild(this.currentMovie);
      }
      
      protected function get movieUrl() : String
      {
         return "";
      }
      
      public function loadAndPlay() : void
      {
         this.musicLastState = Zlab.soundManager.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY);
         this.sfxLastState = Zlab.soundManager.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY);
         Zlab.soundManager.setCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY,true);
         Zlab.soundManager.setCategoryMuted(SoundManager.SFX_MIXER_CATEGORY,true);
         this.load(this.url);
      }
      
      public function load(param1:String) : void
      {
         this.currentMovie.addEventListener(Event.INIT,this.onMovieInit,false,0,true);
         this.currentMovie.addEventListener(Event.COMPLETE,this.onMovieLoaded,false,0,true);
         this.currentMovie.loadAndPlay(param1);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onResize);
      }
      
      private function onMovieInit(param1:Event) : void
      {
         this.currentMovie.removeEventListener(Event.INIT,this.onMovieInit);
         addEventListener(Event.ENTER_FRAME,this.onFrame,false,0,true);
         this.play();
         this.reposition();
         if(this.mouseCloseEnabled || Config.DEBUG_MODE)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         }
      }
      
      protected function onMovieLoaded(param1:Event) : void
      {
      }
      
      private function onFailed(param1:Resource) : void
      {
         Logger.warn(this,"onFailed","Failed to load cinimatic: " + param1.filename);
         dispatchEvent(new CinematicsEvent(FAIL,this.movieUrl));
         this.finished();
      }
      
      private function onResize(param1:Event) : void
      {
         this.reposition();
      }
      
      private function reposition() : void
      {
         var _loc1_:Number = Zlab.mainStage.stageHeight / 480;
         this.currentMovie.scaleX = this.currentMovie.scaleY = _loc1_;
         this.currentMovie.x = Zlab.mainStage.stageWidth / 2;
         this.currentMovie.x -= 760 * _loc1_ / 2;
         this.currentMovie.y = Zlab.mainStage.stageHeight / 2;
         this.currentMovie.y -= 640 * _loc1_ / 2;
      }
      
      public function play() : void
      {
         this.currentMovie.gotoAndPlay(1);
         dispatchEvent(new CinematicsEvent(PLAY,this.movieUrl));
      }
      
      public function stop() : void
      {
         this.finished();
      }
      
      public function onFrame(param1:Event) : void
      {
         if(this.currentMovie.currentFrame >= this.currentMovie.totalFrames - 1)
         {
            dispatchEvent(new CinematicsEvent(FINISH,this.movieUrl));
            this.finished();
         }
      }
      
      public function finished() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onFrame);
         if(hasEventListener(MouseEvent.MOUSE_DOWN))
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         }
         if(this.currentMovie)
         {
            this.currentMovie.removeEventListener(Event.INIT,this.onMovieInit);
            this.currentMovie.removeEventListener(Event.COMPLETE,this.onMovieLoaded);
            Zlab.mainStage.removeEventListener(Event.RESIZE,this.onResize);
            this.currentMovie.dispose();
            if(this.currentMovie.parent)
            {
               removeChild(this.currentMovie);
            }
            this.currentMovie = null;
         }
         Zlab.soundManager.setCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY,this.musicLastState);
         Zlab.soundManager.setCategoryMuted(SoundManager.SFX_MIXER_CATEGORY,this.sfxLastState);
         dispatchEvent(new Event(Event.COMPLETE));
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
      }
      
      public function onMouseDown(param1:Event) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         dispatchEvent(new CinematicsEvent(INTERRUPT,this.movieUrl));
         this.finished();
      }
      
      public function setBackground(param1:Number, param2:Number, param3:int = 0, param4:Number = 1) : void
      {
         var _loc5_:Graphics = this.graphics;
         _loc5_.clear();
         _loc5_.beginFill(param3,param4);
         _loc5_.drawRect(0,0,param1,param2);
         _loc5_.endFill();
      }
      
      public function dispose() : void
      {
      }
   }
}

