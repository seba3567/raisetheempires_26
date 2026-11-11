package rendering.rendering2d
{
   import flash.display.MovieClip;
   import sound.SoundEvent;
   import zlabs.components.AnimatedComponent;
   import zlabs.debug.Logger;
   import zlabs.utils.MathUtils;
   
   public class MovieController extends AnimatedComponent
   {
      
      public static const ONCE:int = 0;
      
      public static const LOOP:int = 1;
      
      private var m_animations:Array = null;
      
      private var m_sounds:Array = null;
      
      private var m_framerate:Number = 0;
      
      private var m_timeout:Number = 0;
      
      private var m_time:Number = 0;
      
      private var m_mode:int = 1;
      
      private var m_onComplete:Function = null;
      
      private var m_complete:Boolean = false;
      
      private var m_paused:Boolean = false;
      
      private var m_waitForUpdate:Boolean = false;
      
      public function MovieController(param1:MovieClip)
      {
         super();
         this.m_animations = new Array();
         this.getAnimatingMovies(param1);
         this.stop();
         this.fps = 30;
         this.m_time = this.getRandomFrameTime();
         registerForUpdates = true;
      }
      
      public function set mode(param1:int) : void
      {
         this.m_mode = param1;
         if(this.m_mode == ONCE)
         {
            this.m_time = 0;
         }
      }
      
      public function set waitForUpdate(param1:Boolean) : void
      {
         this.m_waitForUpdate = param1;
      }
      
      public function set fps(param1:Number) : void
      {
         this.m_framerate = 1 / param1;
         this.m_timeout = this.m_framerate;
      }
      
      public function set sounds(param1:Array) : void
      {
         if(null != param1)
         {
            this.m_sounds = param1.slice();
         }
      }
      
      public function set paused(param1:Boolean) : void
      {
         this.m_paused = param1;
      }
      
      private function getAnimatingMovies(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         if(param1.totalFrames > 1)
         {
            this.m_animations.push(param1);
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc2_) as MovieClip;
            if(_loc3_)
            {
               this.getAnimatingMovies(_loc3_);
            }
            _loc2_++;
         }
      }
      
      public function dispose() : void
      {
         registerForUpdates = false;
         this.m_onComplete = null;
         this.m_animations = null;
         this.m_sounds = null;
      }
      
      public function set onComplete(param1:Function) : void
      {
         this.m_onComplete = param1;
      }
      
      public function get complete() : Boolean
      {
         return this.m_complete;
      }
      
      private function stop() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.m_animations)
         {
            _loc1_.stop();
         }
      }
      
      private function getRandomFrameTime() : Number
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.m_animations)
         {
            if(Boolean(_loc1_.visible) && Boolean(_loc1_.parent) && _loc1_.parent.visible)
            {
               return MathUtils.randBetween(0,_loc1_.totalFrames - 1) * this.m_framerate;
            }
         }
         return 0;
      }
      
      private function setFrame(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         if(registerForUpdates && this.m_animations.length > 0)
         {
            _loc2_ = 0;
            for each(_loc3_ in this.m_animations)
            {
               if(null == _loc3_.parent)
               {
                  _loc2_++;
               }
               else if(_loc3_.visible && _loc3_.parent.visible)
               {
                  _loc4_ = param1;
                  if(this.m_mode == LOOP)
                  {
                     _loc4_ %= _loc3_.totalFrames;
                  }
                  else if(_loc4_ >= _loc3_.totalFrames - 1)
                  {
                     _loc2_++;
                  }
                  if(_loc3_.currentFrame != _loc4_)
                  {
                     _loc3_.gotoAndStop(_loc4_);
                  }
               }
            }
            if(!registerForUpdates || _loc2_ == this.m_animations.length)
            {
               this.m_complete = true;
               if(null != this.m_onComplete)
               {
                  this.m_onComplete();
               }
               this.stop();
               this.dispose();
            }
            else
            {
               this.playSounds(param1);
            }
         }
      }
      
      override public function onFrame(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(!this.m_paused && !this.m_waitForUpdate)
         {
            this.m_time += param1;
            _loc2_ = int(this.m_time / this.m_framerate);
            this.setFrame(_loc2_);
            if(this.m_time > 100000)
            {
               this.m_time = _loc2_ * this.m_framerate;
            }
         }
      }
      
      private function playSounds(param1:int) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Object = null;
         if(null != this.m_sounds)
         {
            if(this.m_mode == LOOP)
            {
               Logger.error(this,"playSounds","cannot add sounds to looping animations");
            }
            _loc2_ = 0;
            while(_loc2_ < this.m_sounds.length)
            {
               _loc3_ = this.m_sounds[_loc2_];
               if(param1 >= _loc3_.frame)
               {
                  SoundEvent.getSoundEvent(_loc3_.name).play();
                  this.m_sounds.splice(_loc2_,1);
                  if(this.m_sounds.length == 0)
                  {
                     this.m_sounds = null;
                     break;
                  }
                  _loc2_--;
               }
               _loc2_++;
            }
         }
      }
   }
}

