package zlabs.sound
{
   import flash.media.SoundTransform;
   
   public interface ISoundHandle
   {
      
      function pause() : void;
      
      function resume() : void;
      
      function stop() : void;
      
      function set transform(param1:SoundTransform) : void;
      
      function get transform() : SoundTransform;
      
      function set volume(param1:Number) : void;
      
      function get volume() : Number;
      
      function set pan(param1:Number) : void;
      
      function get pan() : Number;
      
      function get category() : String;
      
      function get isPlaying() : Boolean;
   }
}

