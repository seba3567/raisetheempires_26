package events
{
   import flash.events.Event;
   
   public class RepositionEvent extends Event
   {
      
      public static const REPOSITION_HUD:String = "Reposition_Hud";
      
      public static const REPOSITION_FRIENDBAR:String = "Reposition_FriendBar";
      
      public static const REPOSITION_FRIENDBAR_RESIZE:String = "Reposition_FriendBar_Resize";
      
      public static const REPOSITION_COMBAT_ALLY_OVERLAY:String = "Reposition_CombatAllyOverlay";
      
      public var x:Number;
      
      public var y:Number;
      
      public var width:Number;
      
      public var height:Number;
      
      public function RepositionEvent(param1:String, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:Number = 0)
      {
         this.x = param2;
         this.y = param3;
         this.width = param4;
         this.height = param5;
         super(param1);
      }
   }
}

