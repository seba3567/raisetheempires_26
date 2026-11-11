package displays.popups.battlelost
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleHost;
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
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.resource.SWFResource;
   
   public class BattleDominationLostPopup extends BattleDefeatedPopup
   {
      
      private var m_enemyID:String;
      
      private var m_domInfo:Object;
      
      private var m_battle:BattleHost;
      
      private var m_chatButton:ZGameButton;
      
      public function BattleDominationLostPopup(param1:String, param2:Object, param3:Array, param4:Dictionary, param5:Function, param6:BattleHost)
      {
         this.m_enemyID = param1;
         this.m_domInfo = param2;
         this.m_battle = param6;
         super(param3,param4,param5);
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window;
      }
      
      override protected function assetStr() : String
      {
         return "assets/displays/dialogs/PU_Pvp_Defeat3.swf";
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("dialog_mc");
         return new _loc2_();
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
         var _loc2_:Object = {
            "user":ZLoc.tn(_loc1_.firstName,_loc1_.genderTag),
            "empirename":_loc1_.empireName
         };
         var _loc3_:Boolean = DominationModeManager.instance.isNewBattle(this.m_enemyID);
         var _loc4_:String = _loc3_ ? "DominationLossInitial" : "DominationLossRetaliation";
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","DominationLostTitle"));
         TextFieldUtil.processTextField(this.screen.winner_tf,ZGameUtils.ZlocT("Dialogs","DominationWinner"));
         TextFieldUtil.processTextField(this.screen.loser_tf,ZGameUtils.ZlocT("Dialogs","DominationLoser"));
         TextFieldUtil.processTextField(this.screen.vs_tf,ZGameUtils.ZlocT("Combat","Versus"));
         TextFieldUtil.processTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs",_loc4_,_loc2_));
         contentWidth = this.screen.background_mc.width;
         contentHeight = this.screen.background_mc.height;
         centerWithinStage(Zlab.mainStage);
         ZGameUtils.hideIfExists(this.screen.background_mc);
         this.m_chatButton = new ZGameButton(this.screen.orangeButton_02,this.onChatButtonClicked,1.1,true);
         m_buttonSounds.addButton(this.m_chatButton.m_overlay,ButtonSound.DEFAULT);
         this.m_chatButton.text = ZGameUtils.ZlocT("Dialogs","PostTauntPrivate");
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
      
      override protected function dispatchPopupEvent() : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.INVITE));
      }
      
      override protected function allowUnitBuyBack() : Boolean
      {
         return isVictory || numLostUnits > 0;
      }
      
      private function get losePenalty() : int
      {
         return DominationModeManager.instance.getBattleLostPenalty(this.m_domInfo,this.m_battle);
      }
      
      private function initPlayerCards(param1:IPVPPlayer, param2:IPVPPlayer) : void
      {
         loadImage(param1.portraitURL,this.screen.player_01.icon);
         TextFieldUtil.compactTextField(this.screen.name_tf_01,param1.firstName);
         TextFieldUtil.compactTextField(this.screen.points_tf_01,"-" + String(this.losePenalty));
         loadImage(param2.portraitURL,this.screen.player_02.icon);
         TextFieldUtil.compactTextField(this.screen.name_tf_02,param2.firstName);
         TextFieldUtil.compactTextField(this.screen.points_tf_02,"+0");
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
      
      private function onChatButtonClicked(param1:MouseEvent) : void
      {
         DominationModeChatInput.show(this.m_enemyID,"lost");
      }
      
      override protected function onButton1Clicked(param1:MouseEvent) : void
      {
         DominationModeManager.instance.sendHitListRequest(this.m_enemyID);
      }
      
      override protected function get button1TextOverride() : String
      {
         return ZGameUtils.ZlocT("Dialogs","DominationLoseHitlistButton");
      }
   }
}

