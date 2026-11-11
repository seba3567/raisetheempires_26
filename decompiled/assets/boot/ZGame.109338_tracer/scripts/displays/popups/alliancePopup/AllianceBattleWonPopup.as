package displays.popups.alliancePopup
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import displays.popups.battlewon.BattleWonPopup;
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
   
   public class AllianceBattleWonPopup extends BattleWonPopup
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      private var m_enemyID:String;
      
      private var m_domInfo:Object;
      
      private var m_chatButton:ZGameButton;
      
      private var m_loaders:Array;
      
      public function AllianceBattleWonPopup(param1:String, param2:Object, param3:Array, param4:Dictionary, param5:Function)
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
      
      private function get mc() : MovieClip
      {
         return m_window;
      }
      
      override protected function assetStr() : String
      {
         return "assets/displays/dialogs/PU_AllianceVictory.swf";
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
         var _loc2_:Object = DominationModeManager.instance.getAllianceInfo(AlliancesManager.instance.battleAllianceName);
         var _loc3_:String = _loc2_.name;
         var _loc4_:String = AlliancesManager.instance.clanName;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,this.buttonType,{
            "winAlliance":_loc4_,
            "lostAlliance":_loc3_
         }));
         this.close();
      }
      
      private function get buttonType() : int
      {
         if(this.m_domInfo.int)
         {
            return BattleBasePopup.ALLIANCE_WIN_REVENGE;
         }
         return BattleBasePopup.ALLIANCE_WIN_NEW;
      }
      
      private function initPlayerCards(param1:IPVPPlayer, param2:IPVPPlayer) : void
      {
         this.m_loaders = new Array();
         var _loc3_:Object = DominationModeManager.instance.getAllianceInfo(AlliancesManager.instance.battleAllianceName);
         var _loc4_:Object = DominationModeManager.instance.getDominationInfo(AlliancesManager.instance.allianceBattleMember,true);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":_loc3_.name});
         TextFieldUtil.compactTextField(this.mc.name_tf_02,_loc5_);
         TextFieldUtil.compactTextField(this.mc.loser_tf,ZGameUtils.ZlocT("Dialogs","DominationLoser"));
         var _loc6_:String = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(_loc3_.crestId,96));
         var _loc7_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc6_,this.mc.icon2);
         var _loc8_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc4_.u_info.image,this.mc.player_02.icon);
         this.m_loaders.push(_loc7_);
         this.m_loaders.push(_loc8_);
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":AlliancesManager.instance.clanName});
         TextFieldUtil.compactTextField(this.mc.name_tf_01,_loc9_);
         TextFieldUtil.compactTextField(this.mc.winner_tf,ZGameUtils.ZlocT("Dialogs","DominationWinner"));
         var _loc10_:String = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(AlliancesManager.instance.crestId,96));
         var _loc11_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc10_,this.mc.icon1);
         var _loc12_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.mc.player_01.icon);
         this.m_loaders.push(_loc11_);
         this.m_loaders.push(_loc12_);
         var _loc13_:String = "0";
         if(Boolean(_loc3_) && Boolean(_loc3_.totalBonus) && Boolean(_loc3_.totalBonus.totalBonus))
         {
            _loc13_ = "+" + _loc3_.totalBonus.totalBonus.toString();
         }
         TextFieldUtil.compactTextField(this.mc.victoryReward_tf,_loc13_);
         this.updateRewardPoints(_loc3_);
      }
      
      private function updateRewardPoints(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = AlliancesManager.instance.battleScores;
         TextFieldUtil.compactTextField(this.mc.points_tf_01,"+" + _loc2_.winner.health);
         TextFieldUtil.compactTextField(this.mc.points_tf_02,"" + _loc2_.loser.health);
         var _loc4_:int = 0;
         if(_loc2_.winner.domPoints)
         {
            _loc4_ += _loc2_.winner.domPoints;
         }
         if(_loc2_.winner.attackBonus)
         {
            _loc4_ += _loc2_.winner.attackBonus;
         }
         if(Boolean(param1) && Boolean(param1.int) && Boolean(_loc2_.winner.revengeBonus))
         {
            _loc4_ += _loc2_.winner.revengeBonus;
         }
         _loc3_ = "0";
         if(_loc4_ > 0)
         {
            _loc3_ = _loc4_.toString();
         }
         TextFieldUtil.compactTextField(this.mc.playerpoints_tf_01,"+" + _loc3_);
         TextFieldUtil.compactTextField(this.mc.playerpoints_tf_02,_loc2_.loser.domPoints);
         var _loc5_:int = AlliancesManager.instance.currentHealth;
         var _loc6_:int = int(param1.health);
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         else if(_loc6_ > param1.max_health)
         {
            _loc6_ = int(param1.max_health);
         }
         this.setHealthBarVisual(this.mc.strength1_mc,_loc5_,AlliancesManager.instance.maxHealth);
         TextFieldUtil.compactTextField(this.mc.strength1_mc.strength_tf,_loc5_.toString());
         this.setHealthBarVisual(this.mc.strength2_mc,_loc6_,param1.max_health);
         TextFieldUtil.compactTextField(this.mc.strength2_mc.strength_tf,_loc6_.toString());
      }
      
      private function setHealthBarVisual(param1:MovieClip, param2:int, param3:int) : void
      {
         var _loc4_:Number = param1.width * (1 * param2 / param3);
         _loc4_ = _loc4_ > 5 ? _loc4_ : 5;
         TweenLite.to(param1.mask_mc,0,{"width":_loc4_});
      }
      
      private function onChatButtonClicked(param1:MouseEvent) : void
      {
         DominationModeChatInput.show(AlliancesManager.instance.battleAllianceName,"won",true);
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

