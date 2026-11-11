package displays.popups.battlewon
{
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import displays.popups.battlebase.BattleBasePopup;
   import displays.screens.dominationMode.DominationModeChatInput;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.resource.SWFResource;
   
   public class BattleDominationWonPopup extends BattleWonPopup
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      private var m_enemyID:String;
      
      private var m_domInfo:Object;
      
      private var m_chatButton:ZGameButton;
      
      public function BattleDominationWonPopup(param1:String, param2:Object, param3:Array, param4:Dictionary, param5:Function)
      {
         this.m_enemyID = param1;
         this.m_domInfo = param2;
         super(param3,param4,param5);
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("dialog_mc");
         return new _loc2_();
      }
      
      override protected function assetStr() : String
      {
         return "assets/displays/dialogs/PU_Pvp_Victory3.swf";
      }
      
      protected function get enemyPlayer() : IPVPPlayer
      {
         return DominationModeManager.instance.getDominationPlayer(this.m_enemyID);
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         var _loc1_:IPVPPlayer = this.enemyPlayer;
         this.initPlayerCards(ZGlobal.player,_loc1_);
         mainButton.text = ZGameUtils.ZlocT("Dialogs","PostTaunt");
         this.m_chatButton = new ZGameButton(this.screen.orangeButton_02,this.onChatButtonClicked);
         m_buttonSounds.addButton(this.m_chatButton.m_overlay,ButtonSound.DEFAULT);
         this.m_chatButton.text = ZGameUtils.ZlocT("Dialogs","PostTauntPrivate");
         this.screen.popupBox_tf.visible = false;
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","VillainDefeatedTitle"));
         TextFieldUtil.processTextField(this.screen.vs_tf,ZGameUtils.ZlocT("Combat","Versus"));
         TextFieldUtil.processTextField(this.screen.winner_tf,ZGameUtils.ZlocT("Dialogs","DominationWinner"));
         TextFieldUtil.processTextField(this.screen.loser_tf,ZGameUtils.ZlocT("Dialogs","DominationLoser"));
         DominationModeManager.instance.handleTauntDisclaimer(this.screen.initialOverlay_mc);
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_chatButton)
         {
            this.m_chatButton.dispose();
            this.m_chatButton = null;
         }
         DominationModeManager.instance.unregisterTauntDisclaimer();
         super.deinitDialog();
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window;
      }
      
      override protected function onButtonClicked(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,this.buttonType,null));
         this.close();
      }
      
      private function get buttonType() : int
      {
         if(this.m_domInfo.int)
         {
            return BattleBasePopup.DOMINATION_WIN_REVENGE;
         }
         return BattleBasePopup.DOMINATION_WIN_NEW;
      }
      
      private function initPlayerCards(param1:IPVPPlayer, param2:IPVPPlayer) : void
      {
         var _loc3_:int = DominationModeManager.instance.getWinnerWinAmount(this.m_domInfo);
         loadImage(param1.portraitURL,this.screen.player_01.icon);
         TextFieldUtil.compactTextField(this.screen.name_tf_01,param1.firstName);
         TextFieldUtil.compactTextField(this.screen.points_tf_01,"+" + String(_loc3_));
         loadImage(param2.portraitURL,this.screen.player_02.icon);
         TextFieldUtil.compactTextField(this.screen.name_tf_02,param2.firstName);
         TextFieldUtil.compactTextField(this.screen.points_tf_02,"-" + String(this.m_domInfo.scDec));
      }
      
      private function onChatButtonClicked(param1:MouseEvent) : void
      {
         DominationModeChatInput.show(this.m_enemyID,"won");
      }
      
      override protected function allowUnitBuyBack() : Boolean
      {
         return isVictory || numLostUnits > 0;
      }
      
      override protected function getCardBuybackButtonText(param1:int) : String
      {
         return String(param1);
      }
      
      override protected function close(param1:Event = null) : void
      {
         DominationModeManager.instance.launchDominationScreen();
         super.close();
      }
      
      override protected function get usesSecondActionButton() : Boolean
      {
         return this.screen.hasOwnProperty("orangeButton_02");
      }
   }
}

