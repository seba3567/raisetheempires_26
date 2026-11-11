package sound
{
   public class StateSound
   {
      
      public static const ON_CLICK:int = 0;
      
      public static const ON_ENTER:int = 1;
      
      public static const ON_EXIT:int = 2;
      
      public static const ON_HOVER:int = 3;
      
      private var m_soundEvents:Array = new Array(4);
      
      public function StateSound(param1:String, param2:String, param3:String, param4:String)
      {
         super();
         if(param1)
         {
            this.m_soundEvents[ON_CLICK] = param1;
         }
         if(param2)
         {
            this.m_soundEvents[ON_ENTER] = param2.toString();
         }
         if(param3)
         {
            this.m_soundEvents[ON_EXIT] = param3.toString();
         }
         if(param4)
         {
            this.m_soundEvents[ON_HOVER] = param4.toString();
         }
      }
      
      public static function CreateStateSound(param1:XML) : StateSound
      {
         var _loc2_:String = param1.@soundEventOnClick;
         var _loc3_:String = param1.@soundEventOnEnter;
         var _loc4_:String = param1.@soundEventOnExit;
         var _loc5_:String = param1.@soundEventOnHover;
         var _loc6_:StateSound = null;
         if(Boolean(_loc2_) || Boolean(_loc3_) || Boolean(_loc4_) || Boolean(_loc5_))
         {
            _loc6_ = new StateSound(_loc2_,_loc3_,_loc4_,_loc5_);
         }
         return _loc6_;
      }
      
      public function playSoundEvent(param1:int) : void
      {
         if(this.m_soundEvents[param1] != null && this.m_soundEvents[param1].length > 0)
         {
            SoundEvent.getSoundEvent(this.m_soundEvents[param1]).play();
         }
      }
   }
}

