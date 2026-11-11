package displays.popups.alliancePopup
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gamemode.battle.BattleHost;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.domination.DominationModeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import displays.screens.dominationMode.DominationModeChatInput;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.resource.SWFResource;
   
   public class AllianceBattleContinuePopup extends BattleBasePopup
   {
      
      public static const ALLIANCEMODE_END_GAMEOVER:int = 0;
      
      public static const ALLIANCEMODE_END_CONTINUE:int = 1;
      
      private static const CONTINUE_TIMER:int = 30;
      
      private var m_closeCallback:Function = null;
      
      private var m_shareButton:ZGameButton = null;
      
      private var m_continueButton:ZGameButton = null;
      
      private var m_counter:int = 0;
      
      private var m_timer:Timer;
      
      private var m_loaders:Array = null;
      
      private var m_round:int = 0;
      
      private var m_battle:BattleHost;
      
      public function AllianceBattleContinuePopup(param1:Array, param2:Dictionary, param3:BattleHost, param4:Function)
      {
         super(param1,param2);
         this.m_closeCallback = param4;
         this.m_battle = param3;
      }
      
      override protected function assetStr() : String
      {
         return "assets/displays/dialogs/PU_AllianceDefeat.swf";
      }
      
      private function get mc() : MovieClip
      {
         return m_window.defeatCombo_mc;
      }
      
      override protected function get screen() : MovieClip
      {
         return this.mc;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initDialog();
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_loaders = new Array();
         this.m_counter = CONTINUE_TIMER;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onCountdownUpdated);
         this.m_timer.start();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance4FightsLosing_Title"));
         TextFieldUtil.processTextField(this.mc.continue_tf,ZGameUtils.ZlocT("Dialogs","Alliance4FightsLosing_TimerLabel"));
         TextFieldUtil.processTextField(this.mc.countdown_mc.seconds_mc.countdown_tf,this.m_counter.toString());
         var _loc1_:int = AlliancesManager.instance.continuePurchaseCost;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Alliance4FightsLosing_Button",{"amount":_loc1_});
         this.m_continueButton = new ZGameButton(this.mc.continue_bt,this.onContinueClicked,1.1,true);
         this.m_continueButton.compactText(_loc2_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_continueButton.show();
         this.m_continueButton.enable();
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":AlliancesManager.instance.clanName});
         TextFieldUtil.compactTextField(this.mc.name_tf_01,_loc3_);
         TextFieldUtil.compactTextField(this.mc.loser_tf,ZGameUtils.ZlocT("Dialogs","DominationLoser"));
         var _loc4_:String = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(AlliancesManager.instance.crestId,96));
         var _loc5_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.mc.icon1);
         var _loc6_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.mc.player_01.icon);
         this.m_loaders.push(_loc5_);
         this.m_loaders.push(_loc6_);
         var _loc7_:Object = DominationModeManager.instance.getAllianceInfo(AlliancesManager.instance.battleAllianceName);
         var _loc8_:Object = DominationModeManager.instance.getDominationInfo(AlliancesManager.instance.allianceBattleMember,true);
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":_loc7_.name});
         TextFieldUtil.compactTextField(this.mc.name_tf_02,_loc9_);
         TextFieldUtil.compactTextField(this.mc.winner_tf,ZGameUtils.ZlocT("Dialogs","DominationWinner"));
         var _loc10_:String = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(_loc7_.crestId,96));
         var _loc11_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.mc.icon2);
         var _loc12_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc8_.u_info.image,this.mc.player_02.icon);
         this.m_loaders.push(_loc11_);
         this.m_loaders.push(_loc12_);
         this.enableTauntButton();
         this.updateRewardPoints(_loc7_);
         DominationModeManager.instance.handleTauntDisclaimer(this.screen.initialOverlay_mc);
         if(null != this.m_closeCallback)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback,false,0,true);
         }
         addChild(m_window);
      }
      
      private function get losePenalty() : int
      {
         var _loc1_:String = AlliancesManager.instance.allianceBattleMember;
         var _loc2_:Object = DominationModeManager.instance.getDominationInfo(_loc1_);
         return DominationModeManager.instance.getBattleLostPenalty(_loc2_,this.m_battle);
      }
      
      private function updateRewardPoints(param1:Object) : void
      {
         var _loc2_:Object = AlliancesManager.instance.battleScores;
         this.mc.points_tf_01.visible = false;
         this.mc.points_tf_02.visible = false;
         TextFieldUtil.compactTextField(this.mc.playerpoints_tf_01,"-" + String(this.losePenalty));
         TextFieldUtil.compactTextField(this.mc.playerpoints_tf_02,"+0");
         var _loc3_:String = String(AlliancesManager.instance.currentHealth);
         var _loc4_:String = String(param1.health);
         this.setHealthBarVisual(this.mc.strength1_mc,AlliancesManager.instance.currentHealth,AlliancesManager.instance.maxHealth);
         this.setHealthBarVisual(this.mc.strength2_mc,param1.health,param1.max_health);
         TextFieldUtil.compactTextField(this.mc.strength1_mc.strength_tf,_loc3_);
         TextFieldUtil.compactTextField(this.mc.strength2_mc.strength_tf,_loc4_);
      }
      
      private function setHealthBarVisual(param1:MovieClip, param2:int, param3:int) : void
      {
         var _loc4_:Number = param1.width * (1 * param2 / param3);
         _loc4_ = _loc4_ > 5 ? _loc4_ : 5;
         TweenLite.to(param1.mask_mc,0,{"width":_loc4_});
      }
      
      private function enableTauntButton() : void
      {
         this.m_shareButton = new ZGameButton(this.screen.orangeButton_02,this.onButtonClicked,1.1,true);
         this.m_shareButton.text = ZGameUtils.ZlocT("Dialogs","PostTauntPrivate");
      }
      
      protected function onButtonClicked(param1:MouseEvent) : void
      {
         DominationModeChatInput.show(AlliancesManager.instance.battleAllianceName,"lost",true);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         if(this.m_shareButton)
         {
            this.m_shareButton.dispose();
            this.m_shareButton = null;
         }
         if(this.m_continueButton)
         {
            this.m_continueButton.dispose();
            this.m_continueButton = null;
         }
         if(null != this.m_closeCallback)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
            this.m_closeCallback = null;
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         this.stopCountdownTimer();
         super.deinitDialog();
      }
      
      private function stopCountdownTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onCountdownUpdated);
         }
      }
      
      private function onCountdownUpdated(param1:Event = null) : void
      {
         --this.m_counter;
         TextFieldUtil.processTextField(this.mc.countdown_mc.seconds_mc.countdown_tf,this.m_counter.toString());
         if(this.m_counter == 0)
         {
            this.stopCountdownTimer();
            this.m_continueButton.disable_visual();
            TextFieldUtil.processTextField(this.mc.continue_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeEndGameOver"));
         }
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,ALLIANCEMODE_END_GAMEOVER));
      }
      
      private function onContinueClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = AlliancesManager.instance.continuePurchaseCost;
         if(!ZGlobal.player.canBuyCash(_loc2_))
         {
            return;
         }
         close();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,ALLIANCEMODE_END_CONTINUE));
      }
      
      override protected function allowUnitBuyBack() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant("empire_pricetest_unitbuyback") > 2;
      }
   }
}

