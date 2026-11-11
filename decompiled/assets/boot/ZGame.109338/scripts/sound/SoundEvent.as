package sound
{
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.sound.SoundManager;
   
   public class SoundEvent
   {
      
      private static var events:Dictionary = new Dictionary();
      
      private var m_sounds:Array;
      
      private var m_group:Boolean = false;
      
      public function SoundEvent(param1:Array)
      {
         super();
         this.m_sounds = param1;
      }
      
      public static function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:SoundEvent = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@name.toString();
            _loc4_ = _loc2_.@sounds.toString();
            if(events[_loc3_] != null)
            {
               Logger.error(SoundEvent,"initFromSettings","SoundEvent: duplicate name found:" + _loc3_);
            }
            _loc5_ = new SoundEvent(_loc4_.split(","));
            _loc5_.group = _loc2_.@group.toString() == "1";
            events[_loc3_] = _loc5_;
         }
      }
      
      public static function getSoundEvent(param1:String) : SoundEvent
      {
         if(events[param1] == null)
         {
            Logger.error(SoundEvent,"getSoundEvent","SoundEvent: " + param1 + " not found");
         }
         return events[param1];
      }
      
      public function set group(param1:Boolean) : void
      {
         this.m_group = param1;
      }
      
      public function get group() : Boolean
      {
         return this.m_group;
      }
      
      public function play() : void
      {
         if(!(Zlab.soundManager as SoundManager).getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY))
         {
            (Zlab.soundManager as SoundManager).chooseAndPlaySound(this.m_sounds);
         }
      }
   }
}

