package zlabs.sound
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import zlabs.debug.Logger;
   
   internal class SoundHandle implements ISoundHandle
   {
      
      internal var manager:SoundManager;
      
      internal var dirty:Boolean = true;
      
      internal var _category:String;
      
      internal var playing:Boolean;
      
      internal var sound:Sound;
      
      internal var channel:SoundChannel;
      
      protected var pausedPosition:Number = 0;
      
      protected var loopCount:int = 0;
      
      protected var _volume:Number = 1;
      
      protected var _pan:Number = 0;
      
      private var _startTime:Number = 0;
      
      public function SoundHandle(param1:SoundManager, param2:Sound, param3:String, param4:Number, param5:int, param6:Number)
      {
         super();
         this.manager = param1;
         this.sound = param2;
         this._category = param3;
         this.pan = param4;
         this.loopCount = param5;
         this.pausedPosition = param6;
         this._startTime = GlobalEngine.serverTime / 1000;
         this.resume();
      }
      
      public function get valid() : Boolean
      {
         return null != this.channel;
      }
      
      public function get transform() : SoundTransform
      {
         return this.channel.soundTransform;
      }
      
      public function set transform(param1:SoundTransform) : void
      {
         this.dirty = true;
         this.channel.soundTransform = param1;
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set volume(param1:Number) : void
      {
         this.dirty = true;
         this._volume = param1;
      }
      
      public function get pan() : Number
      {
         return this._pan;
      }
      
      public function set pan(param1:Number) : void
      {
         this.dirty = true;
         this._pan = param1;
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function pause() : void
      {
         this.pausedPosition = this.channel.position;
         this.channel.stop();
         this.playing = false;
      }
      
      public function resume() : void
      {
         this.dirty = true;
         try
         {
            this.channel = this.sound.play(this.pausedPosition,this.loopCount);
            this.playing = true;
            this.channel.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         }
         catch(e:Error)
         {
            Logger.error(this,"resume","Error starting sound playback: " + e.toString());
         }
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         --this.loopCount;
         if(this.loopCount > 0)
         {
            this.pausedPosition = 0;
            this.resume();
         }
         else if(this.manager.isInPlayingSounds(this))
         {
            this.manager.removeSoundHandle(this);
         }
      }
      
      public function stop() : void
      {
         this.pause();
         if(this.manager.isInPlayingSounds(this))
         {
            this.manager.removeSoundHandle(this);
         }
      }
      
      public function get isPlaying() : Boolean
      {
         return this.playing;
      }
      
      public function get startTime() : Number
      {
         return this._startTime;
      }
      
      public function destroy() : void
      {
         this.sound = null;
         this.manager = null;
      }
   }
}

