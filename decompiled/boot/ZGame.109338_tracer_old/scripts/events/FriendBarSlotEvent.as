package events
{
   import displays.screens.neighborScreen.IPlayerSlot;
   import flash.events.Event;
   
   public class FriendBarSlotEvent extends Event
   {
      
      public static const FRIEND_BAR_SLOT_CLICK:String = "friendBarSlotClick";
      
      public static const FRIEND_BAR_SLOT_TOGGLE:String = "friendBarSlotToggle";
      
      public static const BUTTON_VISIT:String = "visitClick";
      
      public static const BUTTON_ATTACK:String = "attackClick";
      
      public static const BUTTON_CONTINUE_ATTACK:String = "continueAttackClick";
      
      public static const BUTTON_PILLAGE:String = "pillageClick";
      
      public static const BUTTON_GIFT:String = "giftClick";
      
      public static const BUTTON_MARKET:String = "marketClick";
      
      public static const BUTTON_CHALLENGE:String = "challengeClick";
      
      public static const BUTTON_REQ_RESOURCE:String = "requestResourceClick";
      
      public static const BUTTON_ALLIANCE:String = "allianceClick";
      
      public static const BUTTON_JOIN_ALLIANCE:String = "allianceJoinClick";
      
      public var slot:IPlayerSlot;
      
      public var buttonType:String = null;
      
      public var debugContext:String = null;
      
      public function FriendBarSlotEvent(param1:String, param2:String, param3:IPlayerSlot, param4:Boolean = false, param5:Boolean = false, param6:String = null)
      {
         this.slot = param3;
         this.buttonType = param2;
         this.debugContext = param6;
         super(param1,param4,param5);
      }
   }
}

