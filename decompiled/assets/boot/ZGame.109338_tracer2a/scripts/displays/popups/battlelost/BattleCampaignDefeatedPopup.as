package displays.popups.battlelost
{
   import flash.utils.Dictionary;
   
   public class BattleCampaignDefeatedPopup extends BattleDefeatedPopup
   {
      
      public function BattleCampaignDefeatedPopup(param1:Array, param2:Dictionary, param3:Function)
      {
         super(param1,param2,param3);
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         loadVillain();
      }
   }
}

