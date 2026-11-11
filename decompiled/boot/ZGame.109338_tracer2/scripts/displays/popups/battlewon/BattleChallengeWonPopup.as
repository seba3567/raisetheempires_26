package displays.popups.battlewon
{
   import core.ZGlobal;
   import core.gamemode.battle.GMBattle;
   import core.managers.ChallengeModeManager;
   import core.managers.MatchMakingManager;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.WindowManager;
   
   public class BattleChallengeWonPopup extends BattleWonPopup
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      private var m_challengeID:String = null;
      
      private var m_textfield:TextField = null;
      
      protected var m_maxChars:int = 70;
      
      private var uidW2WPlayer:String = "";
      
      public function BattleChallengeWonPopup(param1:String, param2:Array, param3:Dictionary, param4:Function)
      {
         this.m_challengeID = param1;
         super(param2,param3,param4);
      }
      
      override protected function assetStr() : String
      {
         if(allowUnitBuyBack())
         {
            return "assets/displays/dialogs/PU_Pvp_Victory2.swf";
         }
         return "assets/displays/dialogs/PU_Pvp_Victory.swf";
      }
      
      protected function get enemyPlayer() : IPVPPlayer
      {
         var _loc1_:String = ChallengeModeManager.instance.currentChallengerID();
         return PVPManager.instance.getPVPPlayer(_loc1_);
      }
      
      override protected function setUpPopupUI() : void
      {
         var _loc3_:ImageLoader = null;
         var _loc4_:String = null;
         WindowManager.setFullScreen(false);
         super.setUpPopupUI();
         if(!allowUnitBuyBack())
         {
            m_window.victory_invasion_mc.visible = false;
            m_window.victory_defend_mc.visible = false;
            m_window.victory_kick_mc.visible = false;
            m_window.victory_pve_mc.visible = false;
         }
         m_window.victoryCombo_mc.visible = true;
         this.uidW2WPlayer = ChallengeModeManager.instance.isNeighborAssist() ? ZGlobal.hostPlayer.uid : this.enemyPlayer.uid;
         if(MatchMakingManager.MMNeighborCodeFlow(this.uidW2WPlayer))
         {
            if(MatchMakingManager.IsAddFBButtonExpON())
            {
               mainButton.text = ZGameUtils.ZlocT("Dialogs","MM_AddFBFriendButton");
            }
            else
            {
               mainButton.text = ZGameUtils.ZlocT("Dialogs","Okay");
            }
         }
         else if(ChallengeModeManager.instance.isNeighborAssist())
         {
            mainButton.text = ZGameUtils.ZlocT("Dialogs","PostRescue");
         }
         else
         {
            mainButton.text = ZGameUtils.ZlocT("Dialogs","PostTaunt");
         }
         var _loc1_:String = ChallengeModeManager.instance.currentChallengerID();
         var _loc2_:IPVPPlayer = this.enemyPlayer;
         _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.screen.player_01.icon);
         if(_loc3_)
         {
            _loc3_.smooth = true;
            loaders.push(_loc3_);
         }
         _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc2_.portraitURL,this.screen.player_02.icon);
         if(_loc3_)
         {
            _loc3_.smooth = true;
            loaders.push(_loc3_);
         }
         var _loc5_:Object = {
            "user":ZLoc.tn(_loc2_.firstName,_loc2_.genderTag),
            "empirename":_loc2_.empireName
         };
         if(ChallengeModeManager.instance.isPVEChallenge())
         {
            _loc4_ = "PVPVictoryPVERepel";
         }
         else if(ChallengeModeManager.instance.isRandomFleetChallenge())
         {
            _loc4_ = "PVPVictoryInvasionDesc";
         }
         else if(ChallengeModeManager.instance.isNeighborAssist())
         {
            _loc4_ = "PVPVictoryFriendRepelDesc";
            _loc5_.host = ZLoc.tn(ZGlobal.hostPlayer.firstName,ZGlobal.hostPlayer.genderTag);
         }
         else
         {
            _loc4_ = "PVPVictoryRepelDesc";
         }
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","VillainDefeatedTitle"));
         TextFieldUtil.processTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs",_loc4_,_loc5_));
         TextFieldUtil.processTextField(this.screen.vs_tf,ZGameUtils.ZlocT("Combat","Versus"));
         TextFieldUtil.processTextField(this.screen.win_tf,ZGameUtils.ZlocT("Dialogs","ChallengeWinWinner"));
         var _loc6_:String = "CommentTitle";
         var _loc7_:String = "CommentDesc";
         if(ZGlobal.isHome())
         {
            if(ChallengeModeManager.instance.isInChallengeBattle())
            {
               _loc6_ += "Win";
               _loc7_ += "Win";
            }
         }
         else if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            if(ChallengeModeManager.instance.isNeighborAssist())
            {
               _loc6_ += "WhiteKnightWin";
               _loc7_ += "WhiteKnightWin";
            }
            else
            {
               _loc6_ += "Win";
               _loc7_ += "Win";
            }
         }
         this.m_maxChars = ZGlobal.gameSettings.getInt("maxCommentLength",MAX_INPUT_LENGTH);
         TextFieldUtil.processTextField(this.screen.title01_tf,ZGameUtils.ZlocT("Dialogs",_loc6_));
         this.m_textfield = this.screen.input_tf;
         if(stage != null)
         {
            stage.focus = this.m_textfield;
         }
         if(MatchMakingManager.MMNeighborCodeFlow(this.uidW2WPlayer))
         {
            TextFieldUtil.compactTextField(this.screen.popupBox02_tf,ZGameUtils.ZlocT("Dialogs","MM_BattlePopupDesc",{"player":ZGlobal.hostPlayer.name}));
            this.m_textfield.type = TextFieldType.DYNAMIC;
         }
         else
         {
            TextFieldUtil.processTextField(this.screen.popupBox02_tf,ZGameUtils.ZlocT("Dialogs",_loc7_,{"num":this.m_maxChars}));
            this.m_textfield.selectable = true;
            this.m_textfield.setSelection(0,this.m_textfield.text.length);
            this.m_textfield.maxChars = this.m_maxChars;
            this.m_textfield.wordWrap = true;
            this.m_textfield.addEventListener(TextEvent.TEXT_INPUT,this.textInput);
         }
         TextFieldUtil.processTextField(this.m_textfield,"");
         if(this.screen.socialXP_mc)
         {
            this.screen.socialXP_mc.visible = false;
         }
         if(this.screen.rewardCard_01)
         {
            this.screen.rewardCard_01.visible = false;
         }
         if(this.screen.rewardCard_02)
         {
            this.screen.rewardCard_02.visible = false;
         }
         if(this.screen.rewardCard_03)
         {
            this.screen.rewardCard_03.visible = false;
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_textfield.removeEventListener(TextEvent.TEXT_INPUT,this.textInput);
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.victoryCombo_mc;
      }
      
      override protected function onButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(MatchMakingManager.MMNeighborCodeFlow(this.uidW2WPlayer))
         {
            if(MatchMakingManager.IsAddFBButtonExpON())
            {
               MatchMakingManager.ShowFBFriendRequestDialog(this.uidW2WPlayer);
            }
            GMBattle.QuitBattleMode();
         }
         else
         {
            _loc2_ = new Object();
            _loc2_.comment = this.m_textfield.text;
            dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.AUTOSHARE_DIRECT,_loc2_));
         }
         super.onButtonClicked(param1);
      }
      
      protected function textInput(param1:TextEvent) : void
      {
         var _loc2_:String = ZGlobal.gameSettings.getString("invalidNameCharacters");
         var _loc3_:String = param1.text;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc3_ == _loc2_.substr(_loc4_,1))
            {
               param1.preventDefault();
            }
            _loc4_++;
         }
      }
   }
}

