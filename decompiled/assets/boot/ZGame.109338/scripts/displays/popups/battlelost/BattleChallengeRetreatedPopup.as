package displays.popups.battlelost
{
   import displays.popups.battlebase.BattleBasePopup;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class BattleChallengeRetreatedPopup extends BattleChallengeLostPopup
   {
      
      public function BattleChallengeRetreatedPopup(param1:Array, param2:Dictionary, param3:Function = null)
      {
         super(param1,param2,param3);
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         TextFieldUtil.processTextField(screen.title_tf,ZGameUtils.ZlocT("Dialogs","RetreatTitle"));
         TextFieldUtil.processTextField(screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs","RetreatText"));
      }
      
      override protected function dispatchPopupEvent() : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.AUTOSHARE_COMMENT));
      }
   }
}

