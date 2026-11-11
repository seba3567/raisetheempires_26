package core.ui.menuitem
{
   import Engine.Init.InitializationManager;
   import Engine.Managers.StatsManager;
   import com.greensock.TweenLite;
   import core.*;
   import core.gameobjects.GameItem;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.FightMeterManager;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.WorldResourceManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.promoManager.LowEPPromotion;
   import core.managers.promoManager.PromoManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.player.PlayerEnergy;
   import core.resource.WorldResource;
   import core.ui.GenericButton;
   import core.ui.PlayerFeedbackManager;
   import core.ui.TextTweener;
   import core.ui.Tooltip;
   import core.ui.UIManager;
   import core.ui.menuitem.playerstats.TransactionTracker;
   import dispatchers.EnergyDispatcher;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.ManaDispatcher;
   import dispatchers.MessageDispatcher;
   import dispatchers.ResourceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.StreakBonus;
   import displays.popups.GenericCountdownClock;
   import displays.popups.GenericPopup;
   import displays.popups.RequirementsPopup;
   import displays.popups.RequirementsPopupInfoResources;
   import displays.popups.alliancePopup.AllianceModeRewardUI;
   import displays.popups.buyAmmo.BuyAmmoPopup;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import displays.popups.buyMana.BuyManaPopup;
   import displays.popups.survivalMode.SurvivalModeRewardUI;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.Store;
   import displays.screens.oreInviteScreen.OreInvite;
   import events.EnergyUpdatedEvent;
   import events.ExperienceUpdatedEvent;
   import events.RepositionEvent;
   import events.ResourceRewardEvent;
   import events.ResourceUpdatedEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TInitUser;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.PlayerStats.PlayerStats;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class PlayerStatsUIItem extends MenuItem
   {
      
      private static var m_transactionTracker:TransactionTracker;
      
      public static const ITEM_ID:String = "playerStatsUI";
      
      public static const SLIDING_RESOURCE_NAMES:Array = ["wood","oil","rare"];
      
      public static const HIDE_ELEMENTS_FOR_BATTLE:String = "hidenoness";
      
      public static const HIDE_ELEMENTS_FOR_CAMPAIGN:String = "hideincamp";
      
      private var m_displayObject:PlayerStats;
      
      protected var m_clock:GenericCountdownClock;
      
      private var m_resource:SWFResource = null;
      
      private var m_displayObjectEffectiveWidth:Number = 0;
      
      private var m_UIIndex:int = 0;
      
      private var m_coinsStatsIcon:PlayerStatsIcon = null;
      
      private var m_woodStatsIcon:PlayerStatsIcon = null;
      
      private var m_oilStatsIcon:PlayerStatsIcon = null;
      
      private var m_rareStatsIcon:PlayerStatsIcon = null;
      
      private var m_xpStatsIcon:PlayerStatsIconXP = null;
      
      private var m_rareStatsIcons:Array = null;
      
      private var m_woodQuestGatedIcon:PlayerStatsQuestGatedUIItem = null;
      
      private var m_oilQuestGatedIcon:PlayerStatsQuestGatedUIItem = null;
      
      private var m_oreQuestGatedIcon:PlayerStatsQuestGatedUIItem = null;
      
      private var m_cashQuestGatedIcon:PlayerStatsQuestGatedUIItem = null;
      
      private var m_immunityQuestGatedIcon:PlayerStatsQuestGatedUIItem = null;
      
      private var m_cashTextTweener:TextTweener = null;
      
      private var m_energyTextTweener:TextTweener = null;
      
      private var m_energyClock:PlayerStatsEnergyClock = null;
      
      private var m_ammoTextTweener:TextTweener = null;
      
      private var m_immunity:PlayerStatsImmunity = null;
      
      private var m_getMoreCoinAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreWoodAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreOilAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreRareAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreAllRareAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreCashAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreEnergyAlert:PlayerStatsAlertToaster = null;
      
      private var m_getMoreCashBtn:GenericButton = null;
      
      private var m_rareBtn:GenericButton = null;
      
      private var m_manaBtn:GenericButton = null;
      
      private var m_getMoreManaAlert:PlayerStatsAlertToaster = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_rareResource:int = 0;
      
      private var m_rareIconLoader:ImageLoader = null;
      
      private var m_rarePanelAlreadyVisible:Boolean = false;
      
      private var m_manaBarVisible:Boolean = false;
      
      private var m_purchaseResourceButtons:Array = null;
      
      private var m_unlimitedEnergyTimer:Timer;
      
      private var m_unlimitedEnergyLoader:ImageLoader;
      
      private var m_survivalRewardUI:SurvivalModeRewardUI = null;
      
      private var m_survivalEliteRewardUI:SurvivalModeRewardUI = null;
      
      private var m_allianceLegionUI:AllianceModeRewardUI = null;
      
      protected var m_streakBonus:StreakBonus;
      
      private var m_UIWidthOffset:Number = 0;
      
      private var m_UIHeightOffset:Number = 0;
      
      protected var m_fightMeterIconLoader:ImageLoader;
      
      private var m_fightmeterScheduleInited:Boolean = false;
      
      public function PlayerStatsUIItem()
      {
         super(ITEM_ID);
         this.m_displayObject = new PlayerStats();
         addChild(this.m_displayObject);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         var _loc1_:Rectangle = this.m_displayObject.getBounds(this.m_displayObject);
         this.m_displayObjectEffectiveWidth = _loc1_.left < 0 ? this.m_displayObject.width - Math.abs(_loc1_.left) : this.m_displayObject.width;
         InitializationManager.getInstance().addEventListener(Event.COMPLETE,this.onGameInitComplete,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.CASH,this.onPlayerCashUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.COINS,this.onPlayerCoinsUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.COINS_PICKUP,this.onPlayerCoinsPickup,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.OIL,this.onPlayerOilUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.OIL_PICKUP,this.onPlayerOilPickup,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.WOOD,this.onPlayerWoodUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.WOOD_PICKUP,this.onPlayerWoodPickup,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.ITEM_PICKUP,this.onPlayerItemPickup,false,0,true);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.EXPERIENCE,this.onPlayerExperienceUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.EXPERIENCE_PICKUP,this.onPlayerXpPickup,false,0,true);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerLevelUpdated,false,0,true);
         EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.ENERGY,this.onPlayerEnergyUpdated,false,0,true);
         EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.MAX_ENERGY,this.onPlayerMaxEnergyUpdated,false,0,true);
         this.activateEnergyBar(true);
         this.activateUnlimitedEnergyBar(false);
         this.updateDominanceBar();
         this.m_displayObject.stats_r.experience_mc.addEventListener(MouseEvent.ROLL_OVER,this.onExperienceRollOver,false,0,true);
         this.m_displayObject.stats_r.experience_mc.addEventListener(MouseEvent.ROLL_OUT,this.onExperienceRollOut,false,0,true);
         this.m_displayObject.stats_r.fightMeter_mc.addEventListener(MouseEvent.ROLL_OVER,this.onFightMeterRollOver,false,0,true);
         this.m_displayObject.stats_r.fightMeter_mc.addEventListener(MouseEvent.ROLL_OUT,this.onFightMeterRollOut,false,0,true);
         this.m_displayObject.stats_r.pending_mc.visible = false;
         this.m_displayObject.resources_mc.visible = false;
         this.m_displayObject.elementZ_mc.visible = false;
         this.m_displayObject.elementZ_mc.glowAnim_mc.gotoAndStop(1);
         this.m_displayObject.wave_tf.visible = false;
         this.m_displayObject.elitewave_tf.visible = false;
         Tooltip.subscribe(this.m_displayObject.cash_mc,ZGameUtils.ZlocT("Main","Cash_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.coin_mc,ZGameUtils.ZlocT("Main","Coins_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.wood_mc,ZGameUtils.ZlocT("Main","Wood_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.oil_mc,ZGameUtils.ZlocT("Main","Oil_ToolTip"));
         TutorialManager.instance.registerUIItem(this.m_displayObject.stats_r.energy_mc,"EnergyBar");
         RewardPickupManager.instance.registerUIElement(this.m_displayObject.stats_r.experience_mc,118,"xp");
         RewardPickupManager.instance.registerUIElement(this.m_displayObject.wood_mc.icon_mc,0,"wood");
         RewardPickupManager.instance.registerUIElement(this.m_displayObject.oil_mc.icon_mc,0,"oil");
         RewardPickupManager.instance.registerUIElement(this.m_displayObject.coin_mc.icon_mc,0,"coins");
         RewardPickupManager.instance.registerUIElement(this.m_displayObject.stats_r.energy_mc,0,"energy");
         this.m_cashTextTweener = new TextTweener(this.m_displayObject.cash_mc.label_tf,{
            "maxLines":1,
            "minScale":0.5
         });
         this.m_energyTextTweener = new TextTweener(this.m_displayObject.stats_r.energy_mc.label_tf);
         this.m_energyClock = new PlayerStatsEnergyClock(this.m_displayObject.stats_r.energy_mc);
         this.m_ammoTextTweener = new TextTweener(this.m_displayObject.stats_r.ammo_mc.label_tf);
         this.m_immunity = new PlayerStatsImmunity(this.m_displayObject.immunity_mc);
         this.m_coinsStatsIcon = new PlayerStatsIcon(this.m_displayObject.coin_mc,this.m_displayObject.coin_mc.icon_mc.x,this.m_displayObject.coin_mc.icon_mc.y,this.m_displayObject.coin_mc.icon_mc.width,this.m_displayObject.coin_mc.icon_mc.height);
         this.m_xpStatsIcon = new PlayerStatsIconXP(this.m_displayObject.stats_r.experience_mc,this.m_displayObject.stats_r.experience_mc.icon_mc.x,this.m_displayObject.stats_r.experience_mc.icon_mc.y,this.m_displayObject.stats_r.experience_mc.icon_mc.width,this.m_displayObject.stats_r.experience_mc.icon_mc.height);
         this.m_displayObject.stats_r.experience_mc.icon_mc2.visible = false;
         this.m_displayObject.stats_r.experience_mc.icon_mc3.visible = false;
         this.m_woodStatsIcon = new PlayerStatsIcon(this.m_displayObject.wood_mc,this.m_displayObject.wood_mc.icon_mc.x,this.m_displayObject.wood_mc.icon_mc.y,this.m_displayObject.wood_mc.icon_mc.width,this.m_displayObject.wood_mc.icon_mc.height);
         this.m_oilStatsIcon = new PlayerStatsIcon(this.m_displayObject.oil_mc,this.m_displayObject.oil_mc.icon_mc.x,this.m_displayObject.oil_mc.icon_mc.y,this.m_displayObject.oil_mc.icon_mc.width,this.m_displayObject.oil_mc.icon_mc.height);
         this.m_getMoreCashBtn = new GenericButton(this.m_displayObject.cash_mc.getmore_bt,this.onGetMoreCash);
         this.m_rareBtn = new GenericButton(this.m_displayObject.rare_mc.rareButton_mc,this.onRareButton);
         this.m_manaBtn = new GenericButton(this.m_displayObject.elementZ_mc.add_bt,this.onManaButton);
         this.m_buttonSounds.addButton(this.m_getMoreCashBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_rareBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_getMoreEnergyAlert = new PlayerStatsAlertToaster(this.m_displayObject.stats_r.energy_mc.alert_mc,this.onGetMoreEnergy,["indicator","energy"]);
         this.m_getMoreEnergyAlert.threshold = ZGlobal.gameSettings.getNumber("lowEnergyPromptThreshold");
         this.m_getMoreEnergyAlert.questGate = ZGlobal.gameSettings.getString("lowEnergyPromptQuestRequirement");
         MessageDispatcher.instance.addEventListener(PlayerEnergy.UNLIMITED_ENERGY_CHANGED,this.onUnlimitedEnergyChanged,false,0,true);
         this.m_getMoreCoinAlert = new PlayerStatsAlertToaster(this.m_displayObject.coin_mc.alert_mc,this.onGetMoreCoin,["indicator","coins"]);
         this.m_getMoreCoinAlert.threshold = ZGlobal.gameSettings.getNumber("lowCoinPromptThreshold");
         this.m_getMoreCoinAlert.questGate = ZGlobal.gameSettings.getString("lowCoinPromptQuestRequirement");
         this.m_getMoreWoodAlert = new PlayerStatsAlertToaster(this.m_displayObject.wood_mc.alert_mc,this.onGetMoreWood,["indicator","wood"]);
         this.m_getMoreWoodAlert.threshold = ZGlobal.gameSettings.getNumber("lowWoodPromptThreshold");
         this.m_getMoreWoodAlert.questGate = ZGlobal.gameSettings.getString("lowWoodPromptQuestRequirement");
         this.m_getMoreOilAlert = new PlayerStatsAlertToaster(this.m_displayObject.oil_mc.alert_mc,this.onGetMoreOil,["indicator","oil"]);
         this.m_getMoreOilAlert.threshold = ZGlobal.gameSettings.getNumber("lowOilPromptThreshold");
         this.m_getMoreOilAlert.questGate = ZGlobal.gameSettings.getString("lowOilPromptQuestRequirement");
         this.m_getMoreRareAlert = new PlayerStatsAlertToaster(this.m_displayObject.rare_mc.alert_mc,this.onGetMoreRare,["indicator","rare_ore"]);
         this.m_getMoreRareAlert.threshold = ZGlobal.gameSettings.getNumber("lowRarePromptThreshold");
         this.m_getMoreRareAlert.questGate = ZGlobal.gameSettings.getString("lowRarePromptQuestRequirement");
         this.m_getMoreAllRareAlert = new PlayerStatsAlertToaster(this.m_displayObject.resources_mc.alert_mc,this.onGetAllMoreRare,["indicator","all_ores"]);
         this.m_getMoreAllRareAlert.threshold = ZGlobal.gameSettings.getNumber("lowAllRarePromptThreshold");
         this.m_getMoreAllRareAlert.questGate = ZGlobal.gameSettings.getString("lowAllRarePromptQuestRequirement");
         this.m_getMoreCashAlert = new PlayerStatsAlertToaster(this.m_displayObject.cash_mc.alert_mc,this.onGetMoreCash,["indicator","cash"]);
         this.m_getMoreCashAlert.enabled = false;
         UIDispatcher.instance.addEventListener(LowEPPromotion.EVENT_LOW_EP_PROMO_READY,this.onLowEPPromoReady);
         UIDispatcher.instance.addEventListener(Player.QUEST_LABELS_UPDATED,this.onQuestsUpdated);
         this.m_purchaseResourceButtons = new Array();
         this.m_purchaseResourceButtons.push(new PlayerStatsPurchaseResourceButton(this.m_displayObject.coin_mc.add_bt,"coins"));
         this.m_purchaseResourceButtons.push(new PlayerStatsPurchaseResourceButton(this.m_displayObject.wood_mc.add_bt,"wood"));
         this.m_purchaseResourceButtons.push(new PlayerStatsPurchaseResourceButton(this.m_displayObject.oil_mc.add_bt,"oil"));
         this.m_purchaseResourceButtons.push(new PlayerStatsPurchaseResourceButton(this.m_displayObject.rare_mc.add_bt,"rare"));
         var _loc2_:XML = ZGlobal.gameSettings.getXML().dooberStreak[0];
         this.m_streakBonus = new StreakBonus(_loc2_);
         this.m_streakBonus.mouseEnabled = false;
         addChild(this.m_streakBonus);
         this.m_survivalRewardUI = new SurvivalModeRewardUI(this.m_displayObject.rewardInfo_mc);
         this.m_survivalEliteRewardUI = new SurvivalModeRewardUI(this.m_displayObject.eliterewardInfo_mc);
         this.m_survivalEliteRewardUI.visible = false;
         this.m_allianceLegionUI = new AllianceModeRewardUI(this.m_displayObject.legion_mc);
         addEventListener(HIDE_ELEMENTS_FOR_BATTLE,this.onHideNonEssentialElements);
         addEventListener(HIDE_ELEMENTS_FOR_CAMPAIGN,this.onHideNonEssentialElements);
         m_transactionTracker.addEventListener(Event.RESIZE,this.onTransactionsUpdated);
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_WIDTH_OFFSET,this.onUIWidthOffset);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_HEIGHT_OFFSET,this.onUIHeightOffset);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_FIGHTMETER_RELOADED,this.onReloadFightMeter);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_BATTLEWINLOSE,this.onUpdateRemainingFights);
         this.reposition(Zlab.mainStage);
         UIDispatcher.instance.addEventListener(TInitUser.EVENT_COMPLETE,this.onInitUserComplete,false,0,true);
         this.hideZRegenerator();
      }
      
      public static function initTransactionTracker() : void
      {
         m_transactionTracker = new TransactionTracker();
      }
      
      public static function getPlayerStats() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(ITEM_ID);
      }
      
      private function onInitUserComplete(param1:Event) : void
      {
         UIDispatcher.instance.removeEventListener(TInitUser.EVENT_COMPLETE,this.onInitUserComplete);
         this.initDominanceBar();
         if(ExperimentsManager.instance.getExperimentVariant("empire_fightmeter") != ExperimentsManager.VARIANT_FIGHTMETER_ON)
         {
            this.m_displayObject.stats_r.fightMeter_mc.visible = false;
         }
         else
         {
            this.initFightMeter();
         }
      }
      
      private function initDominanceBar() : void
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_domination_master");
         if(_loc1_ == ExperimentsManager.VARIANT_DOMINATION_MASTER_ENABLED)
         {
            DominationModeManager.instance.addEventListener(DominationModeManager.UPDATED_DOMINANCE_RANK,this.onDominanceRankUpdated,false,0,true);
            DominationModeManager.instance.addEventListener(DominationModeManager.UPDATED_DOMINANCE_SCORE,this.onDominanceScoreUpdated,false,0,true);
         }
      }
      
      private function initFightMeter() : void
      {
         var _loc1_:int = FightMeterManager.instance.getfightsPerDayCount();
         var _loc2_:int = FightMeterManager.instance.levelTarget;
         var _loc3_:int = _loc2_ - _loc1_;
         this.updateFightMeterProgressBar(_loc1_,_loc2_,false);
         this.updateFightMeterTimer();
         TextFieldUtil.compactTextField(this.m_displayObject.stats_r.fightMeter_mc.title_tf,ZGameUtils.ZlocT("Dialogs","FightMeter"));
         if(this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc)
         {
            if(_loc3_ > 0)
            {
               TextFieldUtil.compactTextField(this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","FightMeterText",{"x":_loc3_.toString()}));
            }
            else
            {
               TextFieldUtil.compactTextField(this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","GoalCompletion"));
            }
         }
      }
      
      private function onReloadFightMeter(param1:Event) : void
      {
         this.updateFightMeterProgressBar(0,FightMeterManager.instance.levelTarget,true);
         this.updateFightMeterTimer();
      }
      
      public function updateFightMeterProgressBar(param1:int, param2:int, param3:Boolean = true) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = param1;
         if(this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc)
         {
            _loc5_ = this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc.mask_mc.width * Number(_loc4_ / param2);
            if(param3)
            {
               TweenLite.to(this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc.mask_mc,0.5,{"width":_loc5_});
            }
            else
            {
               this.m_displayObject.stats_r.fightMeter_mc.progressbar_mc.mask_mc.width = _loc5_;
            }
         }
      }
      
      public function onUpdateRemainingFights(param1:Event) : void
      {
         this.initFightMeter();
      }
      
      public function updateFightMeterTimer() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds;
         var _loc2_:int = FightMeterManager.instance.endTime;
         if(_loc1_ >= _loc2_)
         {
            FightMeterManager.instance.updateLastActivatedTime(_loc1_);
         }
         else
         {
            if(this.m_clock)
            {
               this.m_clock.dispose();
               this.m_clock = null;
            }
            _loc3_ = FightMeterManager.instance.endTime - ZGlobal.player.timeWarpSeconds;
            if(_loc3_ <= 0)
            {
               this.m_clock = new GenericCountdownClock(this.m_displayObject.stats_r.fightMeter_mc.clock_mc,FightMeterManager.instance.endTime);
            }
            else
            {
               this.m_clock = new GenericCountdownClock(this.m_displayObject.stats_r.fightMeter_mc.clock_mc,FightMeterManager.instance.endTime - ZGlobal.player.timeWarpSeconds);
            }
         }
         if(!this.m_fightmeterScheduleInited && _loc2_ > _loc1_)
         {
            Zlab.processManager.schedule((_loc2_ - _loc1_ + 1) * 1000,this,this.onDateTimer);
            this.m_fightmeterScheduleInited = true;
         }
      }
      
      private function startDateTimer() : void
      {
         this.stopDateTimer();
         Zlab.processManager.schedule(1000,this,this.onDateTimer);
      }
      
      private function stopDateTimer() : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onDateTimer() : void
      {
         this.updateFightMeterTimer();
      }
      
      public function get displayObject() : DisplayObject
      {
         return this.m_displayObject;
      }
      
      public function get streakBonus() : StreakBonus
      {
         return this.m_streakBonus;
      }
      
      public function setRareStatsItem() : void
      {
         var _loc5_:MovieClip = null;
         var _loc6_:WorldResource = null;
         this.clearRareStatsItem();
         this.m_rareResource = ZGlobal.player.rareResourceType;
         var _loc1_:String = WorldResourceManager.instance.resourceInfo[this.m_rareResource].type;
         ResourceDispatcher.instance.addEventListener(_loc1_,this.onPlayerRareUpdated,false,0,true);
         this.enableRareResourceListeners(true);
         ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.RARE_PICKUP,this.onPlayerRarePickup,false,0,true);
         var _loc2_:Boolean = false;
         this.loadRareIcon(_loc2_);
         RewardPickupManager.instance.registerUIElement(this.m_displayObject.rare_mc,0,_loc1_);
         Tooltip.subscribe(this.m_displayObject.rare_mc,WorldResourceManager.instance.getResourceFriendlyNameFromType(_loc1_,GameItem.MENU_FRIENDLYNAME));
         this.m_rareStatsIcons = new Array();
         var _loc3_:Array = this.rareResourceMovieClips;
         var _loc4_:int = 1;
         for each(_loc5_ in _loc3_)
         {
            _loc6_ = WorldResourceManager.instance.createResource("nrare" + _loc4_,1);
            this.m_rareStatsIcons.push(new PlayerStatsIcon(_loc5_,_loc5_.icon_mc.x,_loc5_.icon_mc.y,_loc5_.icon_mc.width,_loc5_.icon_mc.height,ZGlobal.getAssetURL(_loc6_.mediumIcon)));
            Tooltip.subscribe(_loc5_,WorldResourceManager.instance.getResourceFriendlyNameFromType(_loc6_.type,GameItem.MENU_FRIENDLYNAME));
            RewardPickupManager.instance.registerUIElement(_loc5_,0,_loc6_.type);
            ResourceDispatcher.instance.addEventListener(_loc6_.type,this["onPlayerRare" + _loc4_ + "Updated"],false,0,true);
            ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.RARE_PICKUP,this["onPlayerRare" + _loc4_ + "Pickup"],false,0,true);
            ZGlobal.player.resources.updateResourceAmount(_loc6_.type,0);
            _loc4_++;
         }
      }
      
      private function onLowEPPromoReady(param1:Event) : void
      {
         if(LowEPPromotion.instance.canRunPromotion)
         {
            this.m_getMoreCashAlert.threshold = LowEPPromotion.instance.walletThreshold;
            this.m_getMoreCashAlert.enabled = true;
         }
      }
      
      private function onQuestsUpdated(param1:Event) : void
      {
         UIDispatcher.instance.removeEventListener(Player.QUEST_LABELS_UPDATED,this.onQuestsUpdated);
         this.m_woodQuestGatedIcon = new PlayerStatsQuestGatedUIItem(this.m_displayObject.wood_mc,"Q0591",this.m_displayObject.woodAnchorHome_mc,this.m_displayObject.woodAnchorAlt_mc);
         this.m_oilQuestGatedIcon = new PlayerStatsQuestGatedUIItem(this.m_displayObject.oil_mc,"Q1071",this.m_displayObject.oilAnchorHome_mc,this.m_displayObject.oilAnchorAlt_mc);
         this.m_oreQuestGatedIcon = new PlayerStatsQuestGatedUIItem(this.m_displayObject.rare_mc,"Q1120",this.m_displayObject.rareAnchorHome_mc,this.m_displayObject.rareAnchorAlt_mc);
         this.m_cashQuestGatedIcon = new PlayerStatsQuestGatedUIItem(this.m_displayObject.cash_mc,"Q1120",this.m_displayObject.cashAnchorHome_mc,this.m_displayObject.cashAnchorAlt2_mc);
         this.m_immunityQuestGatedIcon = new PlayerStatsQuestGatedUIItem(this.m_displayObject.immunity_mc,"Q1120",this.m_displayObject.immunityAnchorHome_mc,this.m_displayObject.immunityAnchorAlt_mc);
      }
      
      private function get rareResourceMovieClips() : Array
      {
         return [this.m_displayObject.resources_mc.card_01,this.m_displayObject.resources_mc.card_02,this.m_displayObject.resources_mc.card_03,this.m_displayObject.resources_mc.card_04];
      }
      
      private function clearRareStatsItem() : void
      {
         var _loc1_:String = null;
         if(this.m_rareResource)
         {
            if(this.m_rareIconLoader)
            {
               this.m_rareIconLoader.destroy();
            }
            this.m_rareStatsIcon = null;
            _loc1_ = WorldResourceManager.instance.resourceInfo[this.m_rareResource].type;
            ResourceDispatcher.instance.removeEventListener(_loc1_,this.onPlayerRareUpdated);
            this.enableRareResourceListeners(false);
            ResourceDispatcher.instance.removeEventListener(ResourceRewardEvent.RARE_PICKUP,this.onPlayerRarePickup);
            RewardPickupManager.instance.unregisterUIElement(_loc1_);
            Tooltip.unsubscribe(this.m_displayObject.rare_mc);
         }
      }
      
      private function loadRareIcon(param1:Boolean) : void
      {
         var _loc2_:String = WorldResourceManager.instance.resourceInfo[this.m_rareResource].type;
         var _loc3_:String = WorldResourceManager.instance.getResourceImageURL(this.m_rareResource);
         this.m_rareStatsIcon = new PlayerStatsIcon(this.m_displayObject.rare_mc,this.m_displayObject.rare_mc.icon_mc.x,this.m_displayObject.rare_mc.icon_mc.y,this.m_displayObject.rare_mc.icon_mc.width,this.m_displayObject.rare_mc.icon_mc.height,_loc3_);
         ZGlobal.player.resources.updateResourceAmount(_loc2_,0);
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.reposition(param1.target as Stage);
      }
      
      private function onReposition(param1:Event) : void
      {
         if(param1.target is Stage)
         {
            this.reposition(param1.target as Stage);
         }
      }
      
      private function onUIWidthOffset(param1:RepositionEvent) : void
      {
         this.m_UIWidthOffset = param1.x;
         this.reposition(Zlab.mainStage,false);
      }
      
      private function onUIHeightOffset(param1:RepositionEvent) : void
      {
         this.m_UIHeightOffset = param1.y;
         this.reposition(Zlab.mainStage,true);
      }
      
      private function reposition(param1:Stage, param2:Boolean = true) : void
      {
         var _loc3_:Number = param1.stageWidth;
         var _loc4_:Number = _loc3_ + this.m_UIWidthOffset * 2;
         this.m_displayObject.x = 0 - this.m_UIWidthOffset;
         this.m_displayObject.y = this.m_UIHeightOffset;
         this.m_displayObject.stats_r.x = _loc4_;
         if(param2)
         {
            UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_HUD,this.m_displayObject.x,this.m_displayObject.y,_loc3_,this.m_displayObject.height));
         }
         this.m_streakBonus.x = _loc3_ + this.m_UIWidthOffset - StreakBonus.STREAKBONUS_XINSET;
         this.m_streakBonus.y = this.m_displayObject.y + this.m_UIHeightOffset + StreakBonus.STREAKBONUS_YOFFSET;
      }
      
      private function onGameInitComplete(param1:Event) : void
      {
         this.setRareStatsItem();
         if(ExperimentsManager.instance.getExperimentVariant(ZGlobal.EXPERIMENT_SUPPORT_UNITS) >= ZGlobal.EXPERIMENT_SUPPORT_UNITS_ACTIVE)
         {
            ManaDispatcher.instance.addEventListener(ManaDispatcher.VALUE_UPDATED,this.onPlayerManaUpdated,false,0,true);
            this.m_getMoreManaAlert = new PlayerStatsAlertToaster(this.m_displayObject.elementZ_mc.alert_mc,this.onGetMoreMana,["indicator","mana"]);
            this.m_getMoreManaAlert.threshold = ZGlobal.gameSettings.getNumber("lowManaPromptThreshold");
         }
         this.updateDominanceBar();
      }
      
      private function onRareButton(param1:MouseEvent) : void
      {
         this.m_displayObject.resources_mc.visible = !this.m_displayObject.resources_mc.visible;
         if(this.m_displayObject.resources_mc.visible)
         {
            this.m_rarePanelAlreadyVisible = true;
         }
         else
         {
            this.m_rarePanelAlreadyVisible = false;
         }
      }
      
      private function onManaButton(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(ZGlobal.player.mana.percent < 1)
         {
            PopupManager.instance.push(new BuyManaPopup(null,true));
         }
         else
         {
            _loc2_ = {
               "tab":"Resources",
               "focusGameItemCode":"MA4"
            };
            PopupManager.instance.push(new Store(_loc2_));
         }
      }
      
      public function toggleRarePanel(param1:Boolean = true) : void
      {
         if(param1)
         {
            this.m_displayObject.resources_mc.visible = this.m_oreQuestGatedIcon ? !this.m_oreQuestGatedIcon.isHidden : true;
         }
         else if(!this.m_rarePanelAlreadyVisible)
         {
            this.m_displayObject.resources_mc.visible = false;
         }
      }
      
      private function onGetMoreCash(param1:MouseEvent) : void
      {
         if(PromoManager.instance.meetsCriteriaStarterPack() && ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_CLICKED_BUY_EP) == false && ZGlobal.player.enableOnetimePopup)
         {
            PromoManager.instance.openStarterPackPopup();
            ZGlobal.player.setSeenFlag(PromoManager.FLAG_STARTER_PACK_CLICKED_BUY_EP);
         }
         else
         {
            ZGlobal.switchToTab("money");
         }
      }
      
      private function onGetMoreEnergy(param1:MouseEvent) : void
      {
         BuyEnergyPopup.enableWatchToEarn();
         BuyEnergyPopup.show(null,true);
      }
      
      private function onGetMoreMana(param1:MouseEvent) : void
      {
         PopupManager.instance.push(new BuyManaPopup(null,true));
      }
      
      private function onGetMoreAmmo(param1:MouseEvent) : void
      {
         PopupManager.instance.push(new BuyAmmoPopup(null,true));
      }
      
      private function onGetMoreCoin(param1:MouseEvent) : void
      {
         var _loc2_:RequirementsPopupInfoResources = new RequirementsPopupInfoResources(["coins"]);
         PopupManager.instance.push(new RequirementsPopup(_loc2_));
      }
      
      private function onGetMoreWood(param1:MouseEvent) : void
      {
         var _loc2_:RequirementsPopupInfoResources = new RequirementsPopupInfoResources(["wood"]);
         PopupManager.instance.push(new RequirementsPopup(_loc2_));
      }
      
      private function onGetMoreOil(param1:MouseEvent) : void
      {
         var _loc2_:RequirementsPopupInfoResources = new RequirementsPopupInfoResources(["oil"]);
         PopupManager.instance.push(new RequirementsPopup(_loc2_));
      }
      
      private function onGetMoreRare(param1:MouseEvent) : void
      {
         var _loc2_:String = WorldResourceManager.instance.resourceInfo[this.m_rareResource].type;
         var _loc3_:RequirementsPopupInfoResources = new RequirementsPopupInfoResources([_loc2_]);
         PopupManager.instance.push(new RequirementsPopup(_loc3_));
      }
      
      private function onGetAllMoreRare(param1:MouseEvent) : void
      {
         var _loc2_:ZGamePopUp = new OreInvite();
         PopupManager.instance.push(_loc2_,0,true);
      }
      
      private function onGetMoreResourcesDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "out_of_" + param1.userData.name;
            ViralsManager.instance.sendFeed(_loc2_,{"resource":ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",param1.userData.name + "_sentenceName","plural"))});
         }
      }
      
      private function onPlayerCashUpdated(param1:ResourceUpdatedEvent) : void
      {
         this.m_cashTextTweener.tweenTo(param1.newAmount,0.5);
         this.m_getMoreCashAlert.updateStateForValue(param1.newAmount);
         if(param1.newAmount <= 0)
         {
            if(PromoManager.instance.meetsCriteriaStarterPack() && ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_OUT_OF_CASH) == false)
            {
               PromoManager.instance.openStarterPackPopup();
               ZGlobal.player.setSeenFlag(PromoManager.FLAG_STARTER_PACK_OUT_OF_CASH);
            }
         }
      }
      
      private function onPlayerCoinsUpdated(param1:ResourceUpdatedEvent) : void
      {
         this.m_getMoreCoinAlert.updateStateForValue(param1.newAmount);
         this.m_coinsStatsIcon.updateText(param1.newAmount);
      }
      
      private function onPlayerCoinsPickup(param1:ResourceRewardEvent) : void
      {
         this.m_coinsStatsIcon.bloop();
      }
      
      private function onPlayerWoodUpdated(param1:ResourceUpdatedEvent) : void
      {
         this.m_getMoreWoodAlert.updateStateForValue(param1.newAmount);
         this.m_woodStatsIcon.updateText(param1.newAmount);
      }
      
      private function onPlayerWoodPickup(param1:ResourceRewardEvent) : void
      {
         this.m_woodStatsIcon.bloop();
      }
      
      private function onPlayerItemPickup(param1:ResourceRewardEvent) : void
      {
         this.m_woodStatsIcon.bloop();
      }
      
      private function onPlayerOilUpdated(param1:ResourceUpdatedEvent) : void
      {
         this.m_getMoreOilAlert.updateStateForValue(param1.newAmount);
         this.m_oilStatsIcon.updateText(param1.newAmount);
      }
      
      private function onPlayerOilPickup(param1:ResourceRewardEvent) : void
      {
         this.m_oilStatsIcon.bloop();
      }
      
      private function onPlayerRareUpdated(param1:ResourceUpdatedEvent) : void
      {
         this.m_getMoreRareAlert.updateStateForValue(param1.newAmount);
         this.m_rareStatsIcon.updateText(param1.newAmount);
      }
      
      private function onPlayerRarePickup(param1:ResourceRewardEvent) : void
      {
         this.m_rareStatsIcon.bloop();
      }
      
      private function onPlayerRare1Updated(param1:ResourceUpdatedEvent) : void
      {
         this.m_rareStatsIcons[0].updateText(param1.newAmount);
      }
      
      private function onPlayerRare1Pickup(param1:ResourceRewardEvent) : void
      {
         this.m_rareStatsIcons[0].bloop();
      }
      
      private function onPlayerRare2Updated(param1:ResourceUpdatedEvent) : void
      {
         this.m_rareStatsIcons[1].updateText(param1.newAmount);
      }
      
      private function onPlayerRare2Pickup(param1:ResourceRewardEvent) : void
      {
         this.m_rareStatsIcons[1].bloop();
      }
      
      private function onPlayerRare3Updated(param1:ResourceUpdatedEvent) : void
      {
         this.m_rareStatsIcons[2].updateText(param1.newAmount);
      }
      
      private function onPlayerRare3Pickup(param1:ResourceRewardEvent) : void
      {
         this.m_rareStatsIcons[2].bloop();
      }
      
      private function onPlayerRare4Updated(param1:ResourceUpdatedEvent) : void
      {
         this.m_rareStatsIcons[3].updateText(param1.newAmount);
      }
      
      private function onPlayerRare4Pickup(param1:ResourceRewardEvent) : void
      {
         this.m_rareStatsIcons[3].bloop();
      }
      
      private function onRareResourceUpdated(param1:ResourceUpdatedEvent) : void
      {
         var _loc6_:String = null;
         var _loc2_:Dictionary = ZGlobal.player.resources.resourceAmounts;
         var _loc3_:int = int.MAX_VALUE;
         var _loc4_:int;
         var _loc5_:int = _loc4_ = WorldResourceManager.instance.firstRareResourceIndex;
         while(_loc5_ < WorldResourceManager.instance.numResources)
         {
            _loc6_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc5_);
            if(_loc2_[_loc6_] != null)
            {
               _loc3_ = Math.min(_loc3_,_loc2_[_loc6_]);
            }
            _loc5_++;
         }
         this.m_getMoreAllRareAlert.updateStateForValue(_loc3_);
      }
      
      private function onPlayerExperienceUpdated(param1:ExperienceUpdatedEvent) : void
      {
         var levels:XMLList = null;
         var currentLevelXml:XMLList = null;
         var nextLevelXml:XMLList = null;
         var currentRequiredXP:int = 0;
         var nextRequiredXP:int = 0;
         var newWidth:int = 0;
         var event:ExperienceUpdatedEvent = param1;
         this.m_xpStatsIcon.updateText(event.newAmount);
         levels = ZGlobal.gameSettings.getXML().levels.level;
         currentLevelXml = levels.(@num == ZGlobal.player.level);
         nextLevelXml = levels.(@num == ZGlobal.player.level + 1);
         if(Boolean(currentLevelXml) && Boolean(nextLevelXml))
         {
            currentRequiredXP = parseInt(currentLevelXml.@requiredXP);
            nextRequiredXP = parseInt(nextLevelXml.@requiredXP);
            newWidth = this.m_displayObject.stats_r.experience_mc.base_mc.width * Number((ZGlobal.player.xp - currentRequiredXP) / (nextRequiredXP - currentRequiredXP));
            TweenLite.to(this.m_displayObject.stats_r.experience_mc.xpBar_mc,0.5,{"width":newWidth});
         }
      }
      
      private function onPlayerXpPickup(param1:ResourceRewardEvent) : void
      {
         this.m_xpStatsIcon.bloop();
      }
      
      private function onPlayerLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         TextFieldUtil.processTextField(this.m_displayObject.stats_r.experience_mc.level_tf,param1.newAmount.toString());
         if(this.m_manaBarVisible && !this.m_displayObject.elementZ_mc.visible)
         {
            if(this.shouldManaBarBeVisible())
            {
               this.m_displayObject.elementZ_mc.visible = true;
               Zlab.processManager.schedule(10,this,this.updateManaAfterShortDelay);
            }
         }
      }
      
      private function updateManaAfterShortDelay() : void
      {
         this.updateManaBar(ZGlobal.player.mana.value);
      }
      
      public function hideZRegenerator() : void
      {
         this.m_displayObject.elementZ_mc.ElementZRegenerator_mc.visible = false;
      }
      
      public function showZRegenerator() : void
      {
         this.m_displayObject.elementZ_mc.ElementZRegenerator_mc.visible = true;
      }
      
      private function onExperienceRollOver(param1:MouseEvent) : void
      {
         Tooltip.show(this.generateExperienceString(),null,this.m_displayObject.stats_r.experience_mc);
      }
      
      private function onExperienceRollOut(param1:MouseEvent) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_displayObject.stats_r.experience_mc))
         {
            Tooltip.hide();
         }
      }
      
      private function onFightMeterRollOver(param1:MouseEvent) : void
      {
         var _loc2_:String = "assets/game/GeneralAssetGroup_UI.swf/GreenEnergy_01_96.png";
         this.m_displayObject.stats_r.fightMeter_mc.gotoAndPlay("maximized");
         TextFieldUtil.compactTextField(this.m_displayObject.stats_r.fightMeter_mc.description_tf,ZGameUtils.ZlocT("Dialogs","FightMeterHoverOverDesc"));
         TextFieldUtil.compactTextField(this.m_displayObject.stats_r.fightMeter_mc.description2_tf,ZGameUtils.ZlocT("Dialogs","FightMeterHoverOverDesc1"));
         TextFieldUtil.compactTextField(this.m_displayObject.stats_r.fightMeter_mc.description3_tf,ZGameUtils.ZlocT("Dialogs","FightMeterHoverOverDesc2"));
         this.m_fightMeterIconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_),this.m_displayObject.stats_r.fightMeter_mc.icon);
         this.m_fightMeterIconLoader.smooth = true;
         StatsManager.count("fightmeter","bar","rollover");
         this.initFightMeter();
      }
      
      private function onFightMeterRollOut(param1:MouseEvent) : void
      {
         this.m_displayObject.stats_r.fightMeter_mc.gotoAndPlay("minimized");
         this.initFightMeter();
      }
      
      private function generateExperienceString() : String
      {
         var experienceString:String = null;
         var levels:XMLList = null;
         var nextLevelXml:XMLList = null;
         var requiredXp:int = 0;
         levels = ZGlobal.gameSettings.getXML().levels.level;
         nextLevelXml = levels.(@num == ZGlobal.player.level + 1);
         if(nextLevelXml[0])
         {
            requiredXp = parseInt(nextLevelXml[0].@requiredXP);
            experienceString = ZGameUtils.ZlocT("Main","XP_Tooltip",{
               "xp":ZGlobal.player.xp,
               "xpNext":requiredXp
            });
         }
         else
         {
            experienceString = ZGameUtils.ZlocT("Main","XP_TooltipCapped",{"xp":ZGlobal.player.xp});
         }
         return experienceString;
      }
      
      private function onPlayerEnergyUpdated(param1:EnergyUpdatedEvent) : void
      {
         if(param1.newAmount == 0 && param1.oldAmount > 0)
         {
            Zlab.processManager.schedule(500,this,this.onShowBuyEnergyPopup);
         }
         this.m_energyTextTweener.tweenTo(param1.newAmount,0.5,this.onEnergyTextUpdate);
         this.updateEnergyBar();
         this.updateEnergyAlerts();
      }
      
      public function onShowBuyEnergyPopup() : void
      {
         if(ZGlobal.player.m_energy.energy == 0 && !ZGlobal.player.m_energy.updateAndCheckUnlimitedEnergy())
         {
            BuyEnergyPopup.enableWatchToEarn();
            BuyEnergyPopup.show(null,true);
         }
      }
      
      public function onShowBuyAmmoPopup() : void
      {
         if(ZGlobal.player.m_ammo.ammo == 0)
         {
            PopupManager.instance.push(new BuyAmmoPopup(null,true));
         }
      }
      
      private function onPlayerMaxEnergyUpdated(param1:EnergyUpdatedEvent) : void
      {
         this.updateEnergyBar();
         this.updateEnergyAlerts();
      }
      
      private function onPlayerManaUpdated(param1:WorldEvent) : void
      {
         this.updateManaBar(param1.eventData as int);
      }
      
      private function updateEnergyBar() : void
      {
         var _loc1_:int = Math.min(ZGlobal.player.m_energy.energyMax,ZGlobal.player.m_energy.energy);
         var _loc2_:int = this.m_displayObject.stats_r.energy_mc.base_mc.width * Number(_loc1_ / ZGlobal.player.m_energy.energyMax);
         TweenLite.to(this.m_displayObject.stats_r.energy_mc.energyBar_mc,0.5,{"width":_loc2_});
      }
      
      private function updateManaBar(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         if(ZGlobal.player.mana)
         {
            _loc2_ = ZGlobal.player.mana.percent;
            _loc3_ = this.m_displayObject.elementZ_mc.base_mc.width * _loc2_;
            TweenLite.to(this.m_displayObject.elementZ_mc.energyBar_mc,0.5,{"width":_loc3_});
            TextFieldUtil.processTextField(this.m_displayObject.elementZ_mc.label_tf,param1.toString());
            Tooltip.unsubscribe(this.m_displayObject.elementZ_mc);
            Tooltip.subscribe(this.m_displayObject.elementZ_mc,ZGameUtils.ZlocT("Main","Mana_Tooltip",{
               "mana":param1,
               "manaMax":ZGlobal.player.mana.cap
            }));
            _loc4_ = _loc2_ >= 1;
            this.m_manaBtn.disabled = _loc4_;
            ZGameUtils.setButtonEnabled(this.m_displayObject.elementZ_mc.add_bt,this.onManaButton,!_loc4_);
            this.m_getMoreManaAlert.updateStateForValue(param1);
         }
      }
      
      private function updateEnergyAlerts() : void
      {
         if(ZGlobal.player.m_energy.energy <= ZGlobal.gameSettings.getNumber("lowEnergyFeedbackPromptThreshold"))
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackLowEnergy"));
         }
         this.m_getMoreEnergyAlert.updateStateForValue(ZGlobal.player.m_energy.energy);
      }
      
      private function onEnergyTextUpdate() : void
      {
         var _loc1_:TextFormat = new TextFormat();
         if(this.m_energyTextTweener.value > 5 && this.m_energyTextTweener.value <= ZGlobal.player.m_energy.energyMax)
         {
            _loc1_.color = 16777215;
         }
         else
         {
            _loc1_.color = 16776960;
         }
         this.m_energyTextTweener.textField.setTextFormat(_loc1_);
      }
      
      private function onAmmoTextUpdate() : void
      {
         var _loc1_:TextFormat = new TextFormat();
         if(this.m_ammoTextTweener.value > 5 && this.m_ammoTextTweener.value <= ZGlobal.player.m_ammo.ammoMax)
         {
            _loc1_.color = 16777215;
         }
         else
         {
            _loc1_.color = 16776960;
         }
         this.m_ammoTextTweener.textField.setTextFormat(_loc1_);
      }
      
      private function onEnergyRollOver(param1:MouseEvent) : void
      {
         Tooltip.show(this.generateRemainingEnergyString(),null,this.m_displayObject.stats_r.energy_mc);
         Zlab.processManager.schedule(1000,this,this.updateEnergyToolTip);
      }
      
      private function onEnergyRollOut(param1:MouseEvent = null) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_displayObject.stats_r.energy_mc))
         {
            Tooltip.hide();
         }
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onDominationBarRollOver(param1:MouseEvent) : void
      {
      }
      
      private function onDominationBarRollOut(param1:MouseEvent = null) : void
      {
      }
      
      public function updateEnergyToolTip(param1:Boolean = false) : void
      {
         if(Tooltip.getInstance().visible)
         {
            Tooltip.getInstance().setCurrentProps(this.generateRemainingEnergyString(),null,this.m_displayObject.stats_r.energy_mc);
            Tooltip.getInstance().updateText();
         }
         Zlab.processManager.schedule(200,this,this.updateEnergyToolTip);
      }
      
      private function generateRemainingEnergyString() : String
      {
         var _loc2_:int = 0;
         var _loc1_:String = ZGameUtils.ZlocT("Main","Energy_Tooltip",{
            "energy":ZGlobal.player.m_energy.energy,
            "energyMax":ZGlobal.player.m_energy.energyMax
         });
         if(ZGlobal.player.m_energy.energy < ZGlobal.player.m_energy.energyMax)
         {
            _loc2_ = ZGlobal.player.m_energy.energyTimer.delta;
            _loc1_ = ZGameUtils.ZlocT("Main","MoreEnergy_Tooltip",{
               "currentEnergy":_loc1_,
               "timeString":ZGameTimeUtil.instance.getClockString(_loc2_ + 1)
            });
         }
         return _loc1_;
      }
      
      private function generateRemainingAmmoString() : String
      {
         var _loc2_:int = 0;
         var _loc1_:String = ZGameUtils.ZlocT("Main","Ammo_Tooltip",{
            "ammo":ZGlobal.player.m_ammo.ammo,
            "ammoMax":ZGlobal.player.m_ammo.ammoMax
         });
         if(ZGlobal.player.m_ammo.ammo < ZGlobal.player.m_ammo.ammoMax)
         {
            _loc2_ = ZGlobal.player.m_ammo.ammoTimer.delta;
            _loc1_ = ZGameUtils.ZlocT("Main","MoreAmmo_Tooltip",{
               "currentAmmo":_loc1_,
               "timeString":ZGameTimeUtil.instance.getClockString(_loc2_ + 1)
            });
         }
         return _loc1_;
      }
      
      private function onHideNonEssentialElements(param1:WorldEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Boolean = param1.eventData == false;
         this.m_displayObject.wood_mc.visible = _loc2_;
         this.m_displayObject.oil_mc.visible = _loc2_;
         this.m_displayObject.rare_mc.visible = _loc2_;
         this.m_displayObject.coin_mc.visible = _loc2_;
         this.m_displayObject.immunity_mc.visible = _loc2_;
         this.m_immunity.enable(_loc2_);
         this.m_displayObject.resources_mc.visible = false;
         this.m_manaBarVisible = !_loc2_;
         if(this.shouldManaBarBeVisible())
         {
            this.m_displayObject.elementZ_mc.visible = this.m_manaBarVisible;
            if(this.m_manaBarVisible)
            {
               this.updateManaBar(ZGlobal.player.mana.value);
            }
         }
         if(!_loc2_ && SurvivalModeManager.instance.isInSurvivalBattle())
         {
            if(SurvivalModeManager.instance.isInSurvivalMode3Battle)
            {
               this.m_survivalRewardUI.updateState();
               this.m_survivalRewardUI.visible = true;
               this.m_survivalEliteRewardUI.visible = false;
               this.m_displayObject.wave_tf.visible = false;
            }
            else if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && (SurvivalModeManager.instance.isInEliteSurvivalModeBattle || SurvivalModeManager.instance.isEliteMode))
            {
               this.m_survivalEliteRewardUI.updateState();
               this.m_survivalEliteRewardUI.visible = true;
               TextFieldUtil.compactTextField(this.m_displayObject.wave_tf,ZGameUtils.ZlocT("Dialogs","EliteSurvivalModeWave",{"wave":_loc3_}));
               this.m_displayObject.elitewave_tf.visible = false;
            }
            else
            {
               this.m_displayObject.wave_tf.visible = true;
               _loc3_ = SurvivalModeManager.instance.getCurrentRound();
               TextFieldUtil.compactTextField(this.m_displayObject.wave_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWave",{"wave":_loc3_}));
               this.m_survivalRewardUI.updateState();
               this.m_survivalRewardUI.visible = true;
            }
         }
         else if(!_loc2_ && AlliancesManager.instance.allianceBattle)
         {
            this.m_allianceLegionUI.updateState();
            this.m_allianceLegionUI.visible = true;
            this.m_survivalEliteRewardUI.visible = false;
         }
         else if(!_loc2_ && QuestSurvivalModeManager.instance.isInQuestSurvivalBattle())
         {
            this.m_displayObject.rewardInfo_mc.visible = true;
            this.m_survivalRewardUI.dispose();
            _loc3_ = QuestSurvivalModeManager.instance.getCurrentRound();
            _loc4_ = QuestSurvivalModeManager.instance.getMaxWaves();
            this.m_displayObject.rewardInfo_mc.header_tf.visible = false;
            TextFieldUtil.compactTextField(this.m_displayObject.rewardInfo_mc.current_tf,ZGameUtils.ZlocT("Dialogs","QuestSurvival1",{"wave":_loc3_}));
            TextFieldUtil.compactTextField(this.m_displayObject.rewardInfo_mc.wave_tf,ZGameUtils.ZlocT("Dialogs","QuestSurvival2",{"wave":_loc4_}));
         }
         else
         {
            this.m_allianceLegionUI.visible = false;
            this.m_survivalRewardUI.visible = false;
            this.m_displayObject.wave_tf.visible = false;
            TextFieldUtil.processTextField(this.m_displayObject.wave_tf," ");
            this.m_survivalEliteRewardUI.visible = false;
            this.m_displayObject.elitewave_tf.visible = false;
            TextFieldUtil.processTextField(this.m_displayObject.elitewave_tf," ");
         }
         this.repositionCashDisplay(_loc2_);
      }
      
      private function shouldManaBarBeVisible() : Boolean
      {
         var _loc1_:int = 0;
         if(ExperimentsManager.instance.getExperimentVariant(ZGlobal.EXPERIMENT_SUPPORT_UNITS) >= ZGlobal.EXPERIMENT_SUPPORT_UNITS_ACTIVE)
         {
            _loc1_ = ZGlobal.gameSettings.getInt("manaStartingLevel");
            if(ZGlobal.player.level >= _loc1_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function repositionCashDisplay(param1:Boolean) : void
      {
         this.m_displayObject.cash_mc.y = param1 ? this.m_cashQuestGatedIcon.currentPositionAnchor.y : this.m_displayObject.cashAnchorAlt_mc.y;
      }
      
      override public function removeItem() : void
      {
         this.m_displayObject.parent.removeChild(this.m_displayObject);
         InitializationManager.getInstance().removeEventListener(Event.COMPLETE,this.onGameInitComplete);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.CASH,this.onPlayerCashUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.COINS,this.onPlayerCoinsUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceRewardEvent.COINS_PICKUP,this.onPlayerCoinsPickup);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.OIL,this.onPlayerOilUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceRewardEvent.OIL_PICKUP,this.onPlayerOilPickup);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.WOOD,this.onPlayerWoodUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceRewardEvent.WOOD_PICKUP,this.onPlayerWoodPickup);
         var _loc1_:String = WorldResourceManager.instance.resourceInfo[ZGlobal.player.rareResourceType].type;
         ResourceDispatcher.instance.removeEventListener(_loc1_,this.onPlayerRareUpdated);
         this.enableRareResourceListeners(false);
         ResourceDispatcher.instance.removeEventListener(ResourceRewardEvent.RARE_PICKUP,this.onPlayerRarePickup);
         EnergyDispatcher.instance.removeEventListener(EnergyUpdatedEvent.ENERGY,this.onPlayerEnergyUpdated);
         EnergyDispatcher.instance.removeEventListener(EnergyUpdatedEvent.MAX_ENERGY,this.onPlayerMaxEnergyUpdated);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.EXPERIENCE,this.onPlayerExperienceUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceRewardEvent.EXPERIENCE_PICKUP,this.onPlayerXpPickup);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerLevelUpdated);
         this.activateEnergyBar(false);
         this.activateUnlimitedEnergyBar(false);
         this.activateDominanceBar(false);
         this.disposeUnlimitedEnergyLoader();
         this.m_displayObject.stats_r.experience_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onExperienceRollOver);
         this.m_displayObject.stats_r.experience_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onExperienceRollOut);
         m_transactionTracker.addEventListener(Event.RESIZE,this.onTransactionsUpdated);
         this.m_getMoreEnergyAlert.dispose();
         MessageDispatcher.instance.removeEventListener(PlayerEnergy.UNLIMITED_ENERGY_CHANGED,this.onUnlimitedEnergyChanged);
         DominationModeManager.instance.removeEventListener(DominationModeManager.UPDATED_DOMINANCE_RANK,this.onDominanceRankUpdated);
         DominationModeManager.instance.removeEventListener(DominationModeManager.UPDATED_DOMINANCE_SCORE,this.onDominanceScoreUpdated);
         this.m_displayObject = null;
      }
      
      private function onDominanceRankUpdated(param1:Event) : void
      {
         this.updateDominanceBar();
      }
      
      private function onDominanceScoreUpdated(param1:Event) : void
      {
         this.updateDominanceBar();
      }
      
      private function updateDominanceBar() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc1_:Boolean = DominationModeManager.instance.enabled;
         this.activateDominanceBar(_loc1_);
         if(_loc1_)
         {
            this.m_displayObject.stats_r.ammo_mc.timer_frame_lt.visible = false;
            this.m_displayObject.stats_r.ammo_mc.timer_frame_md.visible = false;
            this.m_displayObject.stats_r.ammo_mc.timer_frame_rt.visible = false;
            this.m_displayObject.stats_r.ammo_mc.more_tf.visible = false;
            _loc2_ = DominationModeManager.instance.dominanceRank;
            _loc3_ = DominationModeManager.instance.dominance;
            TextFieldUtil.processTextField(this.m_displayObject.stats_r.ammo_mc.label_tf,String(_loc3_));
            TextFieldUtil.processTextField(this.m_displayObject.stats_r.ammo_mc.icon_mc.dominanceLevel_tf,String(_loc2_));
            _loc4_ = DominationModeManager.instance.percentThroughLevel;
            _loc5_ = this.m_displayObject.stats_r.ammo_mc.base_mc.width * _loc4_;
            Tooltip.unsubscribe(this.m_displayObject.stats_r.ammo_mc);
            Tooltip.subscribe(this.m_displayObject.stats_r.ammo_mc,DominationModeManager.instance.currentDominancePointsTooltip);
            TweenLite.to(this.m_displayObject.stats_r.ammo_mc.energyBar_mc,0.5,{"width":_loc5_});
         }
      }
      
      private function disposeUnlimitedEnergyLoader() : void
      {
         if(this.m_unlimitedEnergyLoader)
         {
            this.m_unlimitedEnergyLoader.destroy();
            this.m_unlimitedEnergyLoader = null;
         }
      }
      
      private function onUnlimitedEnergyChanged(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = ZGlobal.player.m_energy.updateAndCheckUnlimitedEnergy();
         this.activateEnergyBar(!_loc2_);
         this.activateUnlimitedEnergyBar(_loc2_);
      }
      
      private function activateUnlimitedEnergyBar(param1:Boolean) : void
      {
         var _loc2_:String = null;
         this.m_displayObject.stats_r.energyBarUnlimited_mc.visible = param1;
         if(param1)
         {
            if(!this.m_unlimitedEnergyTimer)
            {
               this.m_unlimitedEnergyTimer = new Timer(1000);
               this.m_unlimitedEnergyTimer.addEventListener(TimerEvent.TIMER,this.onUnlimitedEnergyTick,false,0,true);
            }
            this.m_unlimitedEnergyTimer.start();
            this.updateUnlimitedEnergyBarImage();
            this.updateUnlimitedEnergyBar();
            _loc2_ = ZGameUtils.ZlocT("Main","UnlimitedEnergy_Tooltip");
            Tooltip.subscribe(this.m_displayObject.stats_r.energyBarUnlimited_mc,_loc2_);
         }
         else
         {
            if(this.m_unlimitedEnergyTimer)
            {
               this.m_unlimitedEnergyTimer.stop();
               this.m_unlimitedEnergyTimer.removeEventListener(TimerEvent.TIMER,this.onUnlimitedEnergyTick);
               this.m_unlimitedEnergyTimer = null;
            }
            Tooltip.unsubscribe(this.m_displayObject.stats_r.energyBarUnlimited_mc);
         }
      }
      
      private function updateUnlimitedEnergyBarImage() : void
      {
         var _loc1_:int = ZGlobal.player.m_energy.unlimitedEnergyPackagePurchased;
         var _loc2_:String = PromoManager.instance.getUnlimitedEnergySmallImage(_loc1_);
         if(_loc2_)
         {
            this.m_displayObject.stats_r.energyBarUnlimited_mc.icon.visible = true;
            this.disposeUnlimitedEnergyLoader();
            _loc2_ = ZGlobal.getAssetURL(_loc2_);
            this.m_unlimitedEnergyLoader = ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_displayObject.stats_r.energyBarUnlimited_mc.icon);
         }
         else
         {
            this.m_displayObject.stats_r.energyBarUnlimited_mc.icon.visible = false;
         }
      }
      
      private function onUnlimitedEnergyTick(param1:TimerEvent) : void
      {
         this.updateUnlimitedEnergyBar();
      }
      
      private function updateUnlimitedEnergyBar() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         if(ZGlobal.player.m_energy.updateAndCheckUnlimitedEnergy())
         {
            _loc1_ = ZGlobal.player.m_energy.unlimitedEnergyTimeRemaining;
            _loc2_ = ZGameTimeUtil.instance.getClockString(_loc1_);
            TextFieldUtil.processTextField(this.m_displayObject.stats_r.energyBarUnlimited_mc.label_tf,_loc2_);
            _loc3_ = ZGlobal.gameSettings.getString("UnlimitedEnergyUIWarningTime","5m");
            _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc3_,0);
            _loc5_ = _loc1_ < _loc4_;
            this.m_displayObject.stats_r.energyBarUnlimited_mc.label_tf.textColor = _loc5_ ? 4292898560 : 4294967295;
         }
      }
      
      private function activateEnergyBar(param1:Boolean) : void
      {
         this.m_displayObject.stats_r.energy_mc.visible = param1;
         if(param1)
         {
            this.m_displayObject.stats_r.energy_mc.addEventListener(MouseEvent.ROLL_OVER,this.onEnergyRollOver,false,0,true);
            this.m_displayObject.stats_r.energy_mc.addEventListener(MouseEvent.ROLL_OUT,this.onEnergyRollOut,false,0,true);
         }
         else
         {
            this.m_displayObject.stats_r.energy_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onEnergyRollOver);
            this.m_displayObject.stats_r.energy_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onEnergyRollOut);
            this.onEnergyRollOut();
         }
      }
      
      private function activateDominanceBar(param1:Boolean) : void
      {
         this.m_displayObject.stats_r.ammo_mc.visible = param1;
         if(param1)
         {
            this.m_displayObject.stats_r.ammo_mc.addEventListener(MouseEvent.ROLL_OVER,this.onDominationBarRollOver,false,0,true);
            this.m_displayObject.stats_r.ammo_mc.addEventListener(MouseEvent.ROLL_OUT,this.onDominationBarRollOut,false,0,true);
         }
         else
         {
            this.m_displayObject.stats_r.ammo_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onDominationBarRollOver);
            this.m_displayObject.stats_r.ammo_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onDominationBarRollOut);
            this.onDominationBarRollOut();
         }
      }
      
      private function onTransactionsUpdated(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = Boolean(this.m_displayObject.stats_r.pending_mc.visible);
         var _loc3_:int = int(param1.eventData);
         var _loc4_:Boolean = _loc3_ > 0;
         if(_loc2_ != _loc4_)
         {
            if(_loc4_)
            {
               this.m_displayObject.stats_r.pending_mc.gotoAndPlay(1);
            }
            else if(!_loc4_)
            {
               this.m_displayObject.stats_r.pending_mc.gotoAndStop(1);
            }
            this.m_displayObject.stats_r.pending_mc.visible = _loc4_;
         }
      }
      
      private function enableRareResourceListeners(param1:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:int = WorldResourceManager.instance.firstRareResourceIndex;
         var _loc3_:int = WorldResourceManager.instance.numRareResources;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = _loc2_ + _loc4_;
            _loc6_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc5_);
            if(param1)
            {
               ResourceDispatcher.instance.addEventListener(_loc6_,this.onRareResourceUpdated,false,0,true);
            }
            else
            {
               ResourceDispatcher.instance.removeEventListener(_loc6_,this.onRareResourceUpdated);
            }
            _loc4_++;
         }
      }
   }
}

