package displays.popups.battlelost
{
   import core.managers.domination.DominationModeManager;
   import core.managers.viralsManager.ViralsManager;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class BattleRetreatedPopup extends BattleLostPopup
   {
      
      private var m_dominationRetreat:Boolean = false;
      
      public function BattleRetreatedPopup(param1:Array, param2:Dictionary, param3:Function)
      {
         super(param1,param2,param3);
         if(DominationModeManager.instance.isInDominationBattle())
         {
            this.m_dominationRetreat = true;
         }
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.Retreat;
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         if(allowUnitBuyBack())
         {
            buttons[0].text = ZGameUtils.ZlocT("Dialogs","InviteIdleButton");
         }
         else
         {
            buttons[0].text = ZGameUtils.ZlocT("Dialogs","LoseInviteButton");
         }
         var _loc1_:int = int(numLostUnits);
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","RetreatTitle"));
         TextFieldUtil.processTextField(this.screen.details_tf,ZGameUtils.ZlocT("Dialogs","WinUnitsLostText",{
            "lost":_loc1_,
            "total":_loc1_ + numRemainingUnits
         }));
         TextFieldUtil.processTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs","RetreatText"));
         setupRewards();
      }
      
      override protected function onButton1Clicked(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.INVITE_RETREAT));
         super.onButton1Clicked(param1);
         ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_BATTLE_RETREAT,null,"retreat",null);
      }
      
      override protected function setContentDimentions() : void
      {
         if(allowUnitBuyBack())
         {
            this.contentWidth = 595;
            this.contentHeight = 400;
         }
         else
         {
            super.setContentDimentions();
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(this.m_dominationRetreat)
         {
            DominationModeManager.instance.launchDominationScreen();
         }
         super.close();
      }
   }
}

