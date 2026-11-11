package displays.popups.battlelost
{
   import core.ZGlobal;
   import core.player.IPVPPlayer;
   import flash.utils.Dictionary;
   
   public class BattleMechlabLostPopup extends BattleChallengeLostPopup implements IPVPPlayer
   {
      
      public function BattleMechlabLostPopup(param1:Array, param2:Dictionary, param3:Function = null)
      {
         super(param1,param2,param3);
      }
      
      override protected function getPVPPlayer(param1:String) : IPVPPlayer
      {
         return this;
      }
      
      public function get firstName() : String
      {
         return null;
      }
      
      override public function get name() : String
      {
         return null;
      }
      
      public function get portraitURL() : String
      {
         return ZGlobal.getAssetURL("assets/game/units/Units_Land_Mega.swf/Unit_Land_MegaUnit_02_icon.png");
      }
      
      public function get uid() : String
      {
         return null;
      }
      
      public function get genderTag() : String
      {
         return null;
      }
      
      public function get empireName() : String
      {
         return null;
      }
   }
}

