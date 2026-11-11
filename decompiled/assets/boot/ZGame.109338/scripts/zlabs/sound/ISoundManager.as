package zlabs.sound
{
   import flash.media.SoundTransform;
   
   public interface ISoundManager
   {
      
      function play(param1:*, param2:Function = null, param3:String = "sfx", param4:Number = 0, param5:int = 1, param6:Number = 0, param7:Class = null) : SoundHandle;
      
      function stream(param1:String, param2:String = "sfx", param3:Number = 0, param4:int = 1, param5:Number = 0) : SoundHandle;
      
      function set muted(param1:Boolean) : void;
      
      function get muted() : Boolean;
      
      function set volume(param1:Number) : void;
      
      function get volume() : Number;
      
      function createCategory(param1:String) : void;
      
      function removeCategory(param1:String) : void;
      
      function setCategoryMuted(param1:String, param2:Boolean) : void;
      
      function getCategoryMuted(param1:String) : Boolean;
      
      function setCategoryVolume(param1:String, param2:Number) : void;
      
      function getCategoryVolume(param1:String) : Number;
      
      function setCategoryTransform(param1:String, param2:SoundTransform) : void;
      
      function getCategoryTransform(param1:String) : SoundTransform;
      
      function stopCategorySounds(param1:String) : void;
      
      function stopAll() : void;
      
      function toggleMusic() : Boolean;
      
      function toggleSFX() : Boolean;
      
      function chooseAndPlaySound(param1:Array) : void;
      
      function initFromSettings(param1:XMLList, param2:String) : void;
      
      function getSoundHandlesInCategory(param1:String, param2:Array) : void;
   }
}

