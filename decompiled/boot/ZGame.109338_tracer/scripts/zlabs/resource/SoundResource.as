package zlabs.resource
{
   import flash.media.Sound;
   
   public class SoundResource extends Resource
   {
      
      public function SoundResource()
      {
         super();
      }
      
      public function get soundObject() : Sound
      {
         throw new Error("You should only use subclasses of SoundResource.");
      }
   }
}

