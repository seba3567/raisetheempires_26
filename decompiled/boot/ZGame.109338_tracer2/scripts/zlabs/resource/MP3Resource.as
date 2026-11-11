package zlabs.resource
{
   import flash.media.Sound;
   
   public class MP3Resource extends SoundResource
   {
      
      protected var _soundObject:Sound = null;
      
      public function MP3Resource()
      {
         super();
      }
      
      override public function get soundObject() : Sound
      {
         return this._soundObject;
      }
      
      override public function initialize(param1:*) : void
      {
         this._soundObject = param1;
         onLoadComplete();
      }
      
      override protected function onContentReady(param1:*) : Boolean
      {
         return this.soundObject != null;
      }
   }
}

