package sound
{
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class ButtonSound
   {
      
      private static var buttonSounds:Dictionary = new Dictionary();
      
      public static var DEFAULT:String = "defaultButtonSounds";
      
      public static var PANEL:String = "panelButtonSounds";
      
      public static var CLICK_ONLY:String = "clickOnly";
      
      public static var ROLLOVER_ONLY:String = "rolloverOnly";
      
      public static var ON_CLICK:int = 0;
      
      public static var ON_ROLLOVER:int = 1;
      
      private var m_events:Array;
      
      public function ButtonSound(param1:String, param2:String)
      {
         super();
         this.m_events = new Array(2);
         if(Boolean(param1) && Boolean(param1.length))
         {
            this.m_events[ON_CLICK] = param1;
         }
         if(Boolean(param2) && Boolean(param2.length))
         {
            this.m_events[ON_ROLLOVER] = param2;
         }
      }
      
      public static function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:ButtonSound = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@name.toString();
            if(buttonSounds[_loc3_] != null)
            {
               Logger.error(ButtonSound,"initFromSettings","SoundEvent: duplicate name found:" + _loc3_);
            }
            _loc4_ = _loc2_.@onClickSoundEvent.toString();
            _loc5_ = _loc2_.@onRolloverSoundEvent.toString();
            _loc6_ = new ButtonSound(_loc4_,_loc5_);
            buttonSounds[_loc3_] = _loc6_;
         }
      }
      
      public static function getButtonSound(param1:String) : ButtonSound
      {
         if(buttonSounds[param1] == null)
         {
            Logger.error(ButtonSound,"GetButtonSound","ButtonSound: " + param1 + " not found");
         }
         return buttonSounds[param1];
      }
      
      public function play(param1:int) : void
      {
         if(this.m_events[param1] != null)
         {
            SoundEvent.getSoundEvent(this.m_events[param1]).play();
         }
      }
   }
}

