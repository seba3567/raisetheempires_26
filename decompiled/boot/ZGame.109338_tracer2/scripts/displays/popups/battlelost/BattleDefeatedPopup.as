package displays.popups.battlelost
{
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class BattleDefeatedPopup extends BattleLostPopup
   {
      
      public function BattleDefeatedPopup(param1:Array, param2:Dictionary, param3:Function)
      {
         super(param1,param2,param3);
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.Defeat;
      }
      
      protected function get loseTextLabel() : String
      {
         return "LoseDesc";
      }
      
      protected function get button1TextOverride() : String
      {
         return null;
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         var _loc1_:String = this.button1TextOverride;
         if(_loc1_)
         {
            buttons[0].text = _loc1_;
         }
         else if(allowUnitBuyBack())
         {
            buttons[0].text = ZGameUtils.ZlocT("Dialogs","InviteIdleButton");
         }
         else
         {
            buttons[0].text = ZGameUtils.ZlocT("Dialogs","LoseInviteButton");
         }
         var _loc2_:int = int(numLostUnits);
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","LoseTitle"));
         TextFieldUtil.processTextField(this.screen.details_tf,ZGameUtils.ZlocT("Dialogs","WinUnitsLostText",{
            "lost":_loc2_,
            "total":_loc2_ + numRemainingUnits
         }));
         TextFieldUtil.processTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs",this.loseTextLabel));
         setupRewards();
      }
      
      override protected function onButton1Clicked(param1:MouseEvent) : void
      {
         this.dispatchPopupEvent();
         super.onButton1Clicked(param1);
      }
      
      protected function dispatchPopupEvent() : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.INVITE));
      }
      
      override protected function setContentDimentions() : void
      {
         if(allowUnitBuyBack())
         {
            this.contentWidth = 677;
            this.contentHeight = 420;
         }
         else
         {
            super.setContentDimentions();
         }
      }
   }
}

