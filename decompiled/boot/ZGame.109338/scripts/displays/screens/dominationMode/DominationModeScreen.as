package displays.screens.dominationMode
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.gameobjects.UnitItem;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.AlarmCountdownClock;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class DominationModeScreen extends ZGamePopUp
   {
      
      private static const SCREEN_WIDTH:int = 758;
      
      private static const SCREEN_HEIGHT:int = 642;
      
      private static const PANE_GLOBAL:String = "global";
      
      private static const PANE_RIVALS:String = "rivals";
      
      private static const PANE_ALLIANCE:String = "alliance";
      
      private var m_resource:SWFResource = null;
      
      private var m_mc:MovieClip = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_strength:int = 0;
      
      private var m_globalTab:DominationScreenTab = null;
      
      private var m_rivalTab:DominationScreenTab = null;
      
      private var m_allianceTab:DominationScreenTab = null;
      
      private var m_DFUpdateButton:ZGameButton = null;
      
      private var m_imageLoaders:Array = [];
      
      private var m_currentTabIndex:int = 0;
      
      private var m_currentTab:String = "";
      
      private var m_globalGrid:DominationModeScreenGrid = null;
      
      private var m_rivalGrid:DominationModeScreenGrid = null;
      
      private var m_rewardGrid:DominationModeRewardGrid = null;
      
      private var m_allianceGrid:DominationModeScreenGrid = null;
      
      private var m_loaded:Boolean = false;
      
      private var m_helpActive:Boolean = false;
      
      private var m_clock:AlarmCountdownClock = null;
      
      private var m_allianceClock:AlarmCountdownClock = null;
      
      private var m_motdActive:Boolean = false;
      
      private var m_currentPane:String;
      
      private var m_currentEnemyID:String;
      
      private var m_inAlliance:Boolean = false;
      
      public function DominationModeScreen()
      {
         var _loc1_:String = "assets/displays/screens/FightList.swf";
         super(ZGlobal.getAssetURL(_loc1_));
         DominationModeManager.instance.addEventListener(DominationModeManager.FIGHT_LIST_UPDATED,this.onFightListUpdated,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.FIGHT_LIST_TARGET_SELECTED,this.onFightListTargetSelected,false,0,true);
      }
      
      private function get defenceIcons() : Array
      {
         return [this.screen.defenseUnits_mc.icon0,this.screen.defenseUnits_mc.icon1,this.screen.defenseUnits_mc.icon2,this.screen.defenseUnits_mc.icon3,this.screen.defenseUnits_mc.icon4];
      }
      
      private function get defenceBkgnds() : Array
      {
         return [this.screen.defenseUnits_mc.frame0,this.screen.defenseUnits_mc.frame1,this.screen.defenseUnits_mc.frame2,this.screen.defenseUnits_mc.frame3,this.screen.defenseUnits_mc.frame4];
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("Screen");
         if(_loc2_)
         {
            this.m_mc = new _loc2_();
            addChild(this.m_mc);
         }
         this.m_loaded = true;
         this.initDialog();
         DominationModeManager.instance.addEventListener(DominationModeManager.DVTS_UPDATED,this.onDVTSUpdated,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.PCT_UPDATED,this.onPCTUpdated,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.UPDATED_DOMINANCE_SCORE,this.onDominanceScoreUpdated,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.UPDATED_DOMINANCE_RANK,this.onDominanceRankUpdated,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.DEFENSE_ALERT_CHANGED,this.onDefenseAlertChanged,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.DOMINATION_REWARD_UNLOCKED,this.onDominationRewardUnlocked,false,0,true);
      }
      
      private function get victimListLifetime() : int
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("DominanceNewVictimListLifetime","24h");
         return int(ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,0));
      }
      
      private function setupClock(param1:int) : void
      {
         this.cleanupClock();
         this.m_clock = new AlarmCountdownClock(this.screen.clock_mc,param1 + this.victimListLifetime);
         this.m_clock.alarm.addEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onTimerEnd);
      }
      
      private function cleanupClock() : void
      {
         if(this.m_clock)
         {
            this.m_clock.alarm.removeEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onTimerEnd);
            this.m_clock = null;
         }
      }
      
      private function setupAllianceClock(param1:int, param2:int) : void
      {
         this.cleanupAllianceClock();
         this.m_allianceClock = new AlarmCountdownClock(this.screen.clock2_mc,param1 + param2);
         this.m_allianceClock.alarm.addEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onAllianceTimerEnd);
         if(param1 + param2 < GlobalEngine.serverTime / 1000)
         {
            this.m_allianceClock.alarm.dispatchEvent(new Event(AlarmCountdownClock.TIMER_EXPIRED));
         }
      }
      
      private function cleanupAllianceClock() : void
      {
         if(this.m_allianceClock)
         {
            this.m_allianceClock.alarm.removeEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onAllianceTimerEnd);
            this.m_allianceClock = null;
         }
      }
      
      private function onAllianceTimerEnd(param1:Event) : void
      {
         this.cleanupAllianceClock();
         this.disposeAllianceGrid();
         this.m_rivalTab.disable(true);
         this.m_globalTab.disable(true);
         this.m_allianceTab.disable(true);
         this.screen.loading_tf.visible = true;
         this.statusText = ZGameUtils.ZlocT("Dialogs","DominationLoadingPlaceholder");
         DominationModeManager.instance.clearAllianceList();
         DominationModeManager.instance.refreshFightList();
         AlliancesManager.instance.refreshAllianceInfo();
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.contentWidth = SCREEN_WIDTH;
         this.contentHeight = SCREEN_HEIGHT;
         centerWithinStage(Zlab.mainStage);
         var _loc1_:int = DominationModeManager.instance.dvts;
         if(_loc1_)
         {
            this.setupClock(_loc1_);
         }
         this.initImageLoaders();
         this.initButtons();
         this.initText();
         this.initTooltips();
         this.hideHelp();
         this.hideInitialOverlay();
         this.beginMOTDFlow();
         this.initGrid();
         this.onDefenseAlertChanged();
      }
      
      protected function onTimerEnd(param1:Event) : void
      {
         this.cleanupClock();
         DominationModeManager.instance.refreshFightList();
      }
      
      override protected function deinitDialog() : void
      {
         this.deinitGrid();
         this.deinitImageLoaders();
         this.deinitText();
         this.deinitTooltips();
         this.deinitButtons();
         DominationModeManager.instance.removeEventListener(DominationModeManager.DVTS_UPDATED,this.onDVTSUpdated);
         DominationModeManager.instance.removeEventListener(DominationModeManager.PCT_UPDATED,this.onPCTUpdated);
         DominationModeManager.instance.removeEventListener(DominationModeManager.UPDATED_DOMINANCE_SCORE,this.onDominanceScoreUpdated);
         DominationModeManager.instance.removeEventListener(DominationModeManager.UPDATED_DOMINANCE_RANK,this.onDominanceRankUpdated);
         DominationModeManager.instance.removeEventListener(DominationModeManager.DEFENSE_ALERT_CHANGED,this.onDefenseAlertChanged);
         DominationModeManager.instance.removeEventListener(DominationModeManager.FIGHT_LIST_UPDATED,this.onFightListUpdated);
         DominationModeManager.instance.removeEventListener(DominationModeManager.FIGHT_LIST_TARGET_SELECTED,this.onFightListTargetSelected);
         DominationModeManager.instance.removeEventListener(DominationModeManager.DOMINATION_REWARD_UNLOCKED,this.onDominationRewardUnlocked);
         this.cleanupAllianceClock();
         super.deinitDialog();
      }
      
      private function get screen() : MovieClip
      {
         return this.m_mc;
      }
      
      private function initButtons() : void
      {
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_globalTab = new DominationScreenTab(this.screen.tabs_mc.tab0,this.onSelectGlobalTab);
         this.m_globalTab.setText(ZLoc.t("Dialogs","DominationGlobalTab_Title"));
         this.m_rivalTab = new DominationScreenTab(this.screen.tabs_mc.tab1,this.onSelectRivalTab);
         this.m_rivalTab.setText(ZLoc.t("Dialogs","DominationRivalsTab_Title"));
         this.m_allianceTab = new DominationScreenTab(this.screen.tabs_mc.tab2,this.onSelectAllianceTab);
         this.m_allianceTab.setText(ZLoc.t("Dialogs","Alliance4WorldDomination_Tab"));
         this.m_DFUpdateButton = new ZGameButton(this.screen.change_bt,this.onUpdateDefenseForce);
         this.m_DFUpdateButton.text = ZLoc.t("Dialogs","DominationUpdateDefenseForce");
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         this.screen.help_bt.addEventListener(MouseEvent.CLICK,this.onHelpClicked,false,0,true);
         if(!AlliancesManager.isPhase4Enabled())
         {
            this.screen.clock2_mc.visible = false;
            this.screen.alliancelock_mc.visible = false;
            this.screen.tabs_mc.tab2.visible = false;
            this.screen.list3_mc.visible = false;
         }
      }
      
      protected function onHelpClicked(param1:Event) : void
      {
         if(!this.m_helpActive)
         {
            this.showHelp();
         }
         else
         {
            this.hideHelp();
         }
      }
      
      private function hideHelp() : void
      {
         this.screen.helpOverlay_mc.visible = false;
         this.screen.helpOverlay_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onHelpClicked);
         this.m_DFUpdateButton.enable();
         if(this.m_motdActive)
         {
            DominationModeManager.instance.updateDominationSeenFlag(DominationModeManager.SEEN_MAIN_SCREEN_HELP);
         }
         if(Boolean(this.m_globalGrid) && Boolean(!ZGlobal.player.getSeenFlag(DominationModeManager.SEEN_FIRST_FIGHT)) && !this.currentEnemyID)
         {
            this.beginFirstFightFlow();
         }
         this.m_helpActive = false;
      }
      
      private function showHelp() : void
      {
         this.screen.helpOverlay_mc.visible = true;
         this.screen.helpOverlay_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onHelpClicked);
         this.m_DFUpdateButton.disable();
         this.m_helpActive = true;
      }
      
      private function hideInitialOverlay() : void
      {
         this.screen.initialOverlay_mc.visible = false;
      }
      
      private function showInitialOverlay() : void
      {
         this.screen.initialOverlay_mc.visible = true;
      }
      
      private function deinitButtons() : void
      {
         this.screen.help_bt.removeEventListener(MouseEvent.CLICK,this.onHelpClicked);
         if(this.m_DFUpdateButton)
         {
            this.m_DFUpdateButton.dispose();
         }
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds.removeButton(this.screen.exit_bt);
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
      }
      
      private function initText() : void
      {
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","DominationFightList_Title"));
         TextFieldUtil.compactTextField(this.screen.playerHeader_tf,ZGameUtils.ZlocT("Dialogs","DominationPlayer"));
         this.screen.help_tf.visible = false;
         TextFieldUtil.compactTextField(this.screen.profileHeader_tf,ZGlobal.player.firstName);
         TextFieldUtil.compactTextField(this.screen.name_tf," ");
         TextFieldUtil.compactTextField(this.screen.level_mc.value_tf,ZGlobal.player.level.toString());
         TextFieldUtil.compactTextField(this.screen.rankHeader_tf,ZGameUtils.ZlocT("Dialogs","DominationRank"));
         TextFieldUtil.compactTextField(this.screen.domHeader_tf,ZGameUtils.ZlocT("Dialogs","DominationDominance_Label"));
         this.updateDominanceRank();
         this.updateDominancePointsFeedback();
         TextFieldUtil.compactTextField(this.screen.percHeader_tf,ZGameUtils.ZlocT("Dialogs","DominationPercentileRank"));
         this.updatePercentile();
         TextFieldUtil.compactTextField(this.screen.winsHeader_tf,ZGameUtils.ZlocT("Dialogs","DominationAttackWins"));
         TextFieldUtil.compactTextField(this.screen.wins_tf,DominationModeManager.instance.wins.toString());
         TextFieldUtil.compactTextField(this.screen.lossesHeader_tf,ZGameUtils.ZlocT("Dialogs","DominationDefenseWins"));
         TextFieldUtil.compactTextField(this.screen.losses_tf,DominationModeManager.instance.dfw.toString());
         TextFieldUtil.compactTextField(this.screen.defense_tf,ZGameUtils.ZlocT("Dialogs","DominationDefenceForce"));
         TextFieldUtil.compactTextField(this.screen.title_tf2,ZGameUtils.ZlocT("Dialogs","DominationDefenseRewards"));
         var _loc1_:int = DominationModeManager.instance.getStrengthColor(this.m_strength);
         this.screen.strength_tf.textColor = _loc1_;
         TextFieldUtil.compactTextField(this.screen.strength_tf,this.m_strength + "/" + DominationModeManager.instance.maxForceStrengthDefend);
         var _loc2_:Object = {"maxLines":6};
         TextFieldUtil.compactTextField(this.screen.helpOverlay_mc.header_tf_0,ZGameUtils.ZlocT("Dialogs","DominationHelpTitle0"));
         TextFieldUtil.compactTextField(this.screen.helpOverlay_mc.info_tf_0,ZGameUtils.ZlocT("Dialogs","DominationHelpText0"),_loc2_);
         TextFieldUtil.compactTextField(this.screen.helpOverlay_mc.header_tf_1,ZGameUtils.ZlocT("Dialogs","DominationHelpTitle1"));
         TextFieldUtil.compactTextField(this.screen.helpOverlay_mc.info_tf_1,ZGameUtils.ZlocT("Dialogs","DominationHelpText1"),_loc2_);
         TextFieldUtil.compactTextField(this.screen.helpOverlay_mc.header_tf_2,ZGameUtils.ZlocT("Dialogs","DominationHelpTitle2"));
         TextFieldUtil.compactTextField(this.screen.helpOverlay_mc.info_tf_2,ZGameUtils.ZlocT("Dialogs","DominationHelpText2"),_loc2_);
         TextFieldUtil.compactTextField(this.screen.initialOverlay_mc.header_tf,ZGameUtils.ZlocT("Dialogs","DominationHelpFTUE_DefenseForceTitle"));
         TextFieldUtil.compactTextField(this.screen.initialOverlay_mc.info_tf,ZGameUtils.ZlocT("Dialogs","DominationHelpFTUE_DefenseForce"));
      }
      
      private function deinitText() : void
      {
      }
      
      private function initTooltips() : void
      {
         this.screen.winsHeader_tf.mouseEnabled = true;
         this.screen.wins_tf.mouseEnabled = true;
         this.screen.lossesHeader_tf.mouseEnabled = true;
         this.screen.losses_tf.mouseEnabled = true;
         this.screen.percHeader_tf.mouseEnabled = true;
         this.screen.perc_tf.mouseEnabled = true;
         this.screen.strength_tf.mouseEnabled = true;
         this.screen.initialOverlay_mc.mouseEnabled = true;
         var _loc1_:Object = DominationModeManager.instance.tooltipOptions;
         Tooltip.subscribe(this.screen.clock_mc,ZGameUtils.ZlocT("Dialogs","DominanceClockTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.winsHeader_tf,ZGameUtils.ZlocT("Dialogs","DominanceAttackWinsTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.wins_tf,ZGameUtils.ZlocT("Dialogs","DominanceAttackWinsTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.lossesHeader_tf,ZGameUtils.ZlocT("Dialogs","DominanceDefenseWinsTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.losses_tf,ZGameUtils.ZlocT("Dialogs","DominanceDefenseWinsTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.percHeader_tf,ZGameUtils.ZlocT("Dialogs","DominanceGlobalRankingTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.perc_tf,ZGameUtils.ZlocT("Dialogs","DominanceGlobalRankingTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.strength_tf,ZGameUtils.ZlocT("Dialogs","DominanceDefenseForceStrengthTooltip"),_loc1_);
         Tooltip.subscribe(this.screen.help_bt,ZGameUtils.ZlocT("Dialogs","DominanceQuestionMarkTooltip"),_loc1_);
      }
      
      private function deinitTooltips() : void
      {
         Tooltip.unsubscribe(this.screen.dominance_mc);
         Tooltip.unsubscribe(this.screen.clock_mc);
         Tooltip.unsubscribe(this.screen.winsHeader_tf);
         Tooltip.unsubscribe(this.screen.wins_tf);
         Tooltip.unsubscribe(this.screen.lossesHeader_tf);
         Tooltip.unsubscribe(this.screen.losses_tf);
         Tooltip.unsubscribe(this.screen.percHeader_tf);
         Tooltip.unsubscribe(this.screen.perc_tf);
         Tooltip.unsubscribe(this.screen.strength_tf);
         Tooltip.unsubscribe(this.screen.help_bt);
      }
      
      private function initImageLoaders() : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:UnitItem = null;
         var _loc7_:ImageLoader = null;
         this.m_imageLoaders = new Array();
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.screen.player_mc.icon_mc);
         this.m_imageLoaders.push(_loc1_);
         var _loc2_:Fleet = DominationModeManager.instance.getDefenseForce();
         if(_loc2_)
         {
            _loc3_ = _loc2_.units;
            this.m_strength = 0;
            if(_loc3_)
            {
               _loc4_ = int(_loc3_.length);
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc3_[_loc5_].code,UnitItem) as UnitItem;
                  this.m_strength += _loc6_.getUpgradedStrength();
                  _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc6_.name,"icon"),this.defenceIcons[_loc5_]);
                  this.m_imageLoaders.push(_loc7_);
                  this.defenceBkgnds[_loc5_].frame_empty.visible = false;
                  this.defenceBkgnds[_loc5_].frame_filled.visible = true;
                  _loc5_++;
               }
               while(_loc5_ < 4)
               {
                  this.defenceBkgnds[_loc5_].frame_empty.visible = true;
                  this.defenceBkgnds[_loc5_].frame_filled.visible = false;
                  _loc5_++;
               }
            }
         }
      }
      
      private function deinitImageLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this.m_imageLoaders = [];
      }
      
      private function autoFocus() : void
      {
         if(Boolean(this.m_allianceGrid) && Boolean(this.m_allianceGrid.numCards))
         {
            this.m_allianceGrid.show();
            this.m_rivalGrid.hide();
            this.m_globalGrid.hide();
            this.activateAllianceTab();
            this.screen.clock2_mc.visible = true;
            this.activatePane(PANE_ALLIANCE);
         }
         else if(this.m_rivalGrid.anyActiveEnemies)
         {
            this.m_rivalGrid.show();
            this.m_globalGrid.hide();
            if(this.m_allianceGrid)
            {
               this.m_allianceGrid.hide();
            }
            this.activateRivalTab();
            this.activatePane(PANE_RIVALS);
         }
         else if(this.m_globalGrid.anyActiveEnemies)
         {
            this.m_rivalGrid.hide();
            if(this.m_allianceGrid)
            {
               this.m_allianceGrid.hide();
            }
            this.m_globalGrid.show();
            this.activateGlobalTab();
            this.screen.clock_mc.visible = true;
            this.activatePane(PANE_GLOBAL);
         }
         else if(this.m_rivalGrid.numCards)
         {
            this.m_rivalGrid.show();
            this.m_globalGrid.hide();
            if(this.m_allianceGrid)
            {
               this.m_allianceGrid.hide();
            }
            this.activateRivalTab();
            this.activatePane(PANE_RIVALS);
         }
         else
         {
            this.m_rivalTab.setActive();
            this.m_globalTab.setActive();
            if(this.m_allianceGrid)
            {
               this.m_allianceTab.setActive();
            }
            this.m_rivalTab.disable(true);
            this.m_globalTab.disable(true);
            this.m_allianceTab.disable(true);
            this.screen.loading_tf.visible = true;
            this.statusText = ZGameUtils.ZlocT("Dialogs","DominationLoadingPlaceholder");
         }
      }
      
      private function initGrid() : void
      {
         var _loc12_:Array = null;
         var _loc13_:Object = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         if(!this.m_loaded)
         {
            return;
         }
         var _loc1_:Boolean = Boolean(this.m_globalGrid) && Boolean(this.m_globalGrid.numCards);
         var _loc2_:Boolean = Boolean(this.m_rivalGrid) && Boolean(this.m_rivalGrid.numCards);
         var _loc3_:Boolean = _loc1_ || _loc2_;
         var _loc4_:Array = DominationModeManager.instance.getDominationFightList();
         this.m_currentEnemyID = this.currentEnemyID;
         if(_loc4_)
         {
            _loc4_.sort(this.sortGlobalVictims);
         }
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         if(this.m_globalGrid)
         {
            _loc5_ = this.m_globalGrid.slotAnchorPositionPublic;
            _loc6_ = this.m_globalGrid.clickPositionPublic;
         }
         this.disposeGlobalGrid();
         this.m_globalGrid = new DominationModeScreenGrid(this.screen.list_mc,this.m_resource,_loc4_,false,_loc5_,_loc6_);
         var _loc7_:Array = DominationModeManager.instance.getRivalsFightList();
         var _loc8_:Array = DominationModeManager.instance.getAllianceRivalList();
         var _loc9_:int = _loc7_ ? int(_loc7_.length) : 0;
         if(_loc7_)
         {
            _loc7_.sort(this.sortRivalVictims);
         }
         if(_loc8_)
         {
            _loc8_.sort(this.compareAllianceRivals);
         }
         this.m_currentEnemyID = null;
         if(_loc7_)
         {
            _loc7_ = _loc7_.concat(_loc8_);
         }
         else if(_loc8_)
         {
            _loc7_ = _loc8_;
         }
         var _loc10_:Number = 0;
         var _loc11_:Number = 0;
         if(this.m_rivalGrid)
         {
            _loc10_ = this.m_rivalGrid.slotAnchorPositionPublic;
            _loc11_ = this.m_rivalGrid.clickPositionPublic;
         }
         this.disposeRivalGrid();
         this.m_rivalGrid = new DominationModeScreenGrid(this.screen.list2_mc,this.m_resource,_loc7_,true,_loc10_,_loc11_,_loc9_);
         if(AlliancesManager.isPhase4Enabled())
         {
            if(AlliancesManager.instance.isInitialised())
            {
               this.screen.alliancelock_mc.visible = false;
               this.m_inAlliance = true;
               this.setupAllianceClock(AlliancesManager.instance.cycleStartTime,AlliancesManager.instance.cycleDuration);
               _loc12_ = DominationModeManager.instance.getAllianceFightList();
               if(_loc12_)
               {
                  _loc12_.sort(this.compareAllianceVictims);
               }
               _loc13_ = AlliancesManager.instance.getAllianceInfo();
               if((Boolean(_loc13_)) && Boolean(_loc12_))
               {
                  _loc12_ = [_loc13_].concat(_loc12_);
               }
               _loc14_ = 0;
               _loc15_ = 0;
               if(this.m_allianceGrid)
               {
                  _loc14_ = this.m_allianceGrid.slotAnchorPositionPublic;
                  _loc15_ = this.m_allianceGrid.clickPositionPublic;
               }
               this.disposeAllianceGrid();
               this.m_allianceGrid = new DominationModeScreenGrid(this.screen.list3_mc,this.m_resource,_loc12_,false,_loc14_,_loc15_,0,true);
            }
            else
            {
               this.m_inAlliance = false;
               this.screen.alliancelock_mc.visible = true;
               this.m_allianceTab.disable_visual(false);
               this.screen.list3_mc.visible = false;
            }
         }
         else
         {
            this.m_inAlliance = false;
            this.screen.alliancelock_mc.visible = false;
            this.screen.tabs_mc.tab2.visible = false;
            this.screen.list3_mc.visible = false;
            this.screen.clock2_mc.visible = false;
            this.m_allianceTab.disable();
         }
         this.screen.loading_tf.visible = false;
         if(this.m_currentPane == PANE_GLOBAL)
         {
            this.activateGlobalTab();
         }
         else if(this.m_currentPane == PANE_RIVALS)
         {
            this.activateRivalTab();
         }
         else if(this.m_currentPane == PANE_ALLIANCE)
         {
            this.activateAllianceTab();
         }
         else if(Boolean(_loc12_) && Boolean(_loc8_) && this.m_currentTab != "")
         {
            this.manualTabFocus();
         }
         else if(!_loc3_)
         {
            this.screen.clock_mc.visible = false;
            this.screen.clock2_mc.visible = false;
            this.autoFocus();
         }
         if(this.m_globalGrid.activeEnemyNotFound() && this.m_rivalGrid.activeEnemyNotFound())
         {
            this.m_globalGrid.activateFirstCard();
         }
         if(!this.m_rewardGrid)
         {
            this.m_rewardGrid = new DominationModeRewardGrid(this.screen.grid_mc,this.m_resource);
         }
         if(Boolean((!this.m_helpActive || ZGlobal.player.getSeenFlag(DominationModeManager.SEEN_MAIN_SCREEN_HELP)) && !ZGlobal.player.getSeenFlag(DominationModeManager.SEEN_FIRST_FIGHT)) && Boolean(!this.currentEnemyID) && Boolean(this.m_globalGrid.numCards))
         {
            this.beginFirstFightFlow();
         }
      }
      
      private function deinitGrid() : void
      {
         this.disposeGlobalGrid();
         this.disposeRivalGrid();
         this.disposeAllianceGrid();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.cleanupMOTDFlow();
         super.close(param1);
         DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.HIDE_DOMINATION_SCREEN));
      }
      
      private function updateLoadingString(param1:DominationModeScreenGrid) : void
      {
         if(param1.numCards)
         {
            this.screen.loading_tf.visible = false;
         }
         else
         {
            this.statusText = ZGameUtils.ZlocT("Dialogs","DominationNoEntries");
            this.screen.loading_tf.visible = true;
         }
      }
      
      private function onSelectGlobalTab(param1:MouseEvent) : void
      {
         if(!this.m_globalGrid)
         {
            return;
         }
         this.m_globalGrid.show();
         if(this.m_rivalGrid)
         {
            this.m_rivalGrid.hide();
         }
         if(this.m_allianceGrid)
         {
            this.m_allianceGrid.hide();
         }
         this.updateLoadingString(this.m_globalGrid);
         this.activateGlobalTab();
         if(this.m_globalGrid.numCards)
         {
            this.screen.clock_mc.visible = true;
         }
         this.screen.clock2_mc.visible = false;
         this.activatePane(PANE_GLOBAL);
      }
      
      private function onSelectRivalTab(param1:MouseEvent) : void
      {
         if(!this.m_rivalGrid)
         {
            return;
         }
         if(this.m_globalGrid)
         {
            this.m_globalGrid.hide();
         }
         if(this.m_allianceGrid)
         {
            this.m_allianceGrid.hide();
         }
         this.m_rivalGrid.show();
         this.updateLoadingString(this.m_rivalGrid);
         this.activateRivalTab();
         this.screen.clock_mc.visible = false;
         this.screen.clock2_mc.visible = false;
         this.activatePane(PANE_RIVALS);
      }
      
      private function onSelectAllianceTab(param1:MouseEvent) : void
      {
         if(!this.m_allianceGrid)
         {
            return;
         }
         this.m_allianceGrid.show();
         if(this.m_globalGrid)
         {
            this.m_globalGrid.hide();
         }
         if(this.m_rivalGrid)
         {
            this.m_rivalGrid.hide();
         }
         this.updateLoadingString(this.m_allianceGrid);
         this.activateAllianceTab();
         this.screen.clock_mc.visible = false;
         this.screen.clock2_mc.visible = true;
         this.activatePane(PANE_ALLIANCE);
      }
      
      private function onUpdateDefenseForce(param1:MouseEvent) : void
      {
         DominationModeManager.instance.enterDefenseForceEditor();
         this.close();
      }
      
      private function onFightListTargetSelected(param1:Event) : void
      {
         this.close();
      }
      
      private function onDominationRewardUnlocked(param1:WorldEvent) : void
      {
         this.m_rewardGrid.updateCards();
      }
      
      private function onFightListUpdated(param1:Event) : void
      {
         this.initGrid();
      }
      
      private function onDefenseAlertChanged(param1:Event = null) : void
      {
         this.screen.DefenseAlert_mc.visible = DominationModeManager.instance.shouldShowDefenseAlert;
      }
      
      private function onDVTSUpdated(param1:Event) : void
      {
         if(this.screen != null)
         {
            this.setupClock(DominationModeManager.instance.dvts);
         }
      }
      
      private function onPCTUpdated(param1:Event) : void
      {
         this.updatePercentile();
      }
      
      private function updateDominanceRank() : void
      {
         var _loc1_:int = DominationModeManager.instance.dominanceRank;
         TextFieldUtil.compactTextField(this.screen.rank_tf,DominationModeManager.instance.getRankName(_loc1_));
         TextFieldUtil.compactTextField(this.screen.dominance_mc.rank_tf,_loc1_.toString());
      }
      
      private function onDominanceRankUpdated(param1:Event) : void
      {
         this.updateDominanceRank();
      }
      
      private function onDominanceScoreUpdated(param1:Event) : void
      {
         this.updateDominancePointsFeedback();
      }
      
      private function updateDominancePointsFeedback() : void
      {
         this.screen.dominance_mc.energyBar_mc.width = this.screen.dominance_mc.base_mc.width * DominationModeManager.instance.percentThroughLevel;
         TextFieldUtil.compactTextField(this.screen.dominance_mc.value_tf,DominationModeManager.instance.dominance.toString());
         Tooltip.subscribe(this.screen.dominance_mc,DominationModeManager.instance.currentDominancePointsTooltip,DominationModeManager.instance.tooltipOptions);
      }
      
      private function updatePercentile() : void
      {
         if(this.screen)
         {
            TextFieldUtil.compactTextField(this.screen.perc_tf,DominationModeManager.instance.dominancePercentile.toString() + "%");
         }
      }
      
      private function beginFirstFightFlow() : void
      {
         this.m_globalGrid.beginMOTDFlow();
         this.m_rivalGrid.hide();
         if(this.m_allianceGrid != null)
         {
            this.m_allianceGrid.hide();
         }
         this.m_globalGrid.show();
         this.m_rivalTab.setActive();
         this.m_allianceTab.setActive();
         this.m_globalTab.setInactive();
         this.screen.clock_mc.visible = true;
         this.screen.clock2_mc.visible = false;
         this.m_rivalTab.disable_visual();
         this.m_allianceTab.disable_visual();
         this.m_DFUpdateButton.disable();
      }
      
      private function beginMOTDFlow() : void
      {
         if(!this.m_motdActive)
         {
            if(!ZGlobal.player.getSeenFlag(DominationModeManager.SEEN_MAIN_SCREEN_HELP))
            {
               this.m_motdActive = true;
               this.showHelp();
            }
            else if(Boolean(ZGlobal.player.getSeenFlag(DominationModeManager.SEEN_FIRST_FIGHT)) && !ZGlobal.player.getSeenFlag(DominationModeManager.SEEN_FIRST_DEFENSE_SETUP))
            {
               this.showInitialOverlay();
               this.m_motdActive = true;
               TutorialManager.instance.registerUIItem(this.screen.change_bt,TutorialManager.DOMINATION_FIRST_DEFENSE_SETUP);
               TutorialManager.instance.sendEvent(TutorialManager.UI_DOMINATION_FIRST_DEFENSE_SETUP,true);
            }
         }
      }
      
      private function set statusText(param1:String) : void
      {
         TextFieldUtil.compactTextField(this.screen.loading_tf,param1);
      }
      
      private function cleanupMOTDFlow() : void
      {
         if(this.m_motdActive)
         {
            TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
            TutorialManager.instance.sendEvent(TutorialManager.UI_DISABLE);
            TutorialManager.instance.sendEvent(TutorialManager.UI_ENABLE);
            this.hideInitialOverlay();
            this.m_motdActive = false;
         }
      }
      
      private function disposeGlobalGrid() : void
      {
         if(this.m_globalGrid)
         {
            this.m_globalGrid.dispose();
            this.m_globalGrid = null;
         }
      }
      
      private function disposeRivalGrid() : void
      {
         if(this.m_rivalGrid)
         {
            this.m_rivalGrid.dispose();
            this.m_rivalGrid = null;
         }
      }
      
      private function disposeAllianceGrid() : void
      {
         if(this.m_allianceGrid)
         {
            this.m_allianceGrid.dispose();
            this.m_allianceGrid = null;
         }
      }
      
      private function activateGlobalTab() : void
      {
         this.m_rivalTab.setActive();
         if(this.m_inAlliance)
         {
            this.m_allianceTab.setActive();
         }
         this.m_globalTab.setInactive();
      }
      
      private function activateRivalTab() : void
      {
         this.m_globalTab.setActive();
         if(this.m_inAlliance)
         {
            this.m_allianceTab.setActive();
         }
         this.m_rivalTab.setInactive();
      }
      
      private function activateAllianceTab() : void
      {
         this.m_globalTab.setActive();
         this.m_rivalTab.setActive();
         this.m_allianceTab.setInactive();
      }
      
      private function activatePane(param1:String) : void
      {
         StatsManager.count("dialog","dominance",param1,"view");
         this.m_currentPane = param1;
      }
      
      private function sortRivalVictims(param1:Object, param2:Object) : int
      {
         if(param1.d_info.zid == this.m_currentEnemyID)
         {
            return -1;
         }
         if(param2.d_info.zid == this.m_currentEnemyID)
         {
            return 1;
         }
         if(param1.d_info.status != param2.d_info.status)
         {
            if(param1.d_info.status != DominationModeManager.DOM_VICTIMSTATUS_WAITING)
            {
               return -1;
            }
            if(param2.d_info.status != DominationModeManager.DOM_VICTIMSTATUS_WAITING)
            {
               return 1;
            }
         }
         if(param1.d_info.ts > param2.d_info.ts)
         {
            return -1;
         }
         if(param2.d_info.ts > param1.d_info.ts)
         {
            return 1;
         }
         if(param1.d_info.zid > param2.d_info.zid)
         {
            return -1;
         }
         return 1;
      }
      
      private function sortGlobalVictims(param1:Object, param2:Object) : int
      {
         if(param1.d_info.zid == this.m_currentEnemyID)
         {
            return -1;
         }
         if(param2.d_info.zid == this.m_currentEnemyID)
         {
            return 1;
         }
         var _loc3_:int = Math.max(1,param1.d_info.dr);
         var _loc4_:int = Math.max(1,param2.d_info.dr);
         if(_loc3_ > _loc4_)
         {
            return -1;
         }
         if(_loc4_ > _loc3_)
         {
            return 1;
         }
         if(param1.u_info.level > param2.u_info.level)
         {
            return -1;
         }
         if(param2.u_info.level > param1.u_info.level)
         {
            return 1;
         }
         if(param1.d_info.zid > param2.d_info.zid)
         {
            return -1;
         }
         return 1;
      }
      
      private function get currentEnemyID() : String
      {
         var _loc1_:Fleet = ZGlobal.player.fleets.getFleetByName(DominationModeManager.FLEET_DOMINATION_ENEMY_NAME);
         return _loc1_ ? _loc1_.uid : null;
      }
      
      private function compareAllianceVictims(param1:Object, param2:Object) : int
      {
         var _loc3_:String = AlliancesManager.instance.allianceBattleInProgress();
         if(_loc3_ == param1.id)
         {
            return -1;
         }
         if(_loc3_ == param2.id)
         {
            return 1;
         }
         return param1.health > param2.health ? -1 : 1;
      }
      
      private function compareAllianceRivals(param1:Object, param2:Object) : int
      {
         var _loc3_:String = AlliancesManager.instance.allianceBattleInProgress();
         if(_loc3_ == param1.id)
         {
            return -1;
         }
         if(_loc3_ == param2.id)
         {
            return 1;
         }
         if(param1.status != DominationModeManager.DOM_VICTIMSTATUS_WAITING && param2.status == DominationModeManager.DOM_VICTIMSTATUS_WAITING)
         {
            return -1;
         }
         if(param1.status == DominationModeManager.DOM_VICTIMSTATUS_WAITING && param2.status != DominationModeManager.DOM_VICTIMSTATUS_WAITING)
         {
            return 1;
         }
         return param1.ts > param2.ts ? -1 : 1;
      }
      
      public function setCurrentTab(param1:String = "") : void
      {
         this.m_currentTab = param1;
      }
      
      private function manualTabFocus() : void
      {
         if(this.m_currentTab == "rivals")
         {
            this.onSelectRivalTab(null);
         }
         else if(this.m_currentTab == "alliance")
         {
            this.onSelectAllianceTab(null);
         }
         else if(this.m_currentTab == "domination")
         {
            this.onSelectGlobalTab(null);
         }
      }
   }
}

