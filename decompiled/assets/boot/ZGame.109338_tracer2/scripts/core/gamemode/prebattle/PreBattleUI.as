package core.gamemode.prebattle
{
   import Engine.Managers.TransactionManager;
   import com.adobe.utils.DictionaryUtil;
   import com.greensock.TweenLite;
   import com.greensock.easing.Quad;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.BattleCampaign;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.AlliancesManager;
   import core.managers.ChallengeModeManager;
   import core.managers.EspionageHQManager;
   import core.managers.ExperimentsManager;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.ReviveAlliesManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.IAlly;
   import core.ui.Tooltip;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.CombatBarUIItem;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.MenuItem;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleWorld;
   import core.worlds.strategicWorld.StrategicMap;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.battleWarning.BattleWarningPopup;
   import displays.screens.challengesScreen.ChallengeBattleTheaterCard;
   import displays.screens.dominationMode.DominationScoutWarningPopup;
   import displays.screens.mechBattleSetup.MechBattleSetup;
   import displays.screens.pickAlliesScreen.BattleSetupAllyCard;
   import displays.screens.pickAlliesScreen.BattleSetupAllyGrid;
   import displays.screens.pickAlliesScreen.BattleSetupAllyPlacementCard;
   import displays.screens.pickAlliesScreen.BattleSetupInviteCard;
   import displays.screens.pickUnitsScreen.StackedUnitInfo;
   import displays.screens.pickUnitsScreen.StackedUnitsGrid;
   import displays.screens.pickUnitsScreen.UnitsPurchaseDialog;
   import events.RepositionEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TCancelUnstartedChallenge;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class PreBattleUI extends MenuItem
   {
      
      public static const ITEM_ID:String = "PreBattleUI";
      
      private static const WIDTH:int = 760;
      
      private static const HEIGHT:int = 640;
      
      private static const ALLY_CARD_INITIAL_TWEEN_DELAY:Number = 800;
      
      private static const ALLY_CARD_TWEEN_TIME:Number = 0.5;
      
      private static const ALLY_CARD_TWEEN_INTERVAL:int = 150;
      
      private static const DOM_ENEMY_X_INSET:int = 110;
      
      private static const DOM_ENEMY_Y_INSET:int = 60;
      
      private static const PANEL_ALLIES:int = 0;
      
      private static const PANEL_UNITS:int = 1;
      
      private static const PANEL_TERRAIN:int = 2;
      
      public static var TITAN_MODE:Boolean = false;
      
      private static const SEEN_UNIT_SUGGESTER_FLAG_NAME:String = "battleSetupUSCount";
      
      public static const ADD_PREBATTLE_UI:String = "addPreBattleUI";
      
      public static const REMOVE_PREBATTLE_UI:String = "removePreBattleUI";
      
      private var m_preBattle:IPreBattle = null;
      
      private var m_resource:SWFResource = null;
      
      private var m_screen:MovieClip = null;
      
      private var m_content:MovieClip = null;
      
      private var m_overlay:MovieClip = null;
      
      private var m_allyoverlay:MovieClip = null;
      
      private var m_tooltipOverlay:MovieClip = null;
      
      private var m_unitPlacementCards:Array = null;
      
      private var m_enemyTooltipCards:Array = null;
      
      private var m_activePlacement:PreBattleUnitCard = null;
      
      private var m_allyGridCards:Array = null;
      
      private var m_allyPlacementCards:Array = null;
      
      private var m_allyTweenCards:Array = null;
      
      private var m_mechSetup:MechBattleSetup = null;
      
      private var m_theaterNextButton:ZGameButton = null;
      
      private var m_nextButton:ZGameButton = null;
      
      private var m_backButton:ZGameButton = null;
      
      private var m_buyButton:ZGameButton = null;
      
      private var m_fightButton:ZGameButton = null;
      
      private var m_reviveButton:ZGameButton = null;
      
      private var m_inviteCard:BattleSetupInviteCard = null;
      
      private var m_unitSuggester:UnitSuggester = null;
      
      private var m_reviveButtonEnabled:Boolean = false;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_alliesGrid:BattleSetupAllyGrid = null;
      
      private var m_unitsGrid:StackedUnitsGrid = null;
      
      private var m_currentPanel:int = 0;
      
      private var m_currentTweenIndex:int;
      
      private var m_isTweening:Boolean = false;
      
      private var m_initialized:Boolean = false;
      
      private var m_prioritizeSupportUnits:Boolean = false;
      
      private var m_terrainSelectionEnabled:Boolean = false;
      
      private var m_theaterCard:Array = new Array();
      
      private var m_theater:int = 0;
      
      private var m_preBattleAdded:Boolean = false;
      
      private var m_disableOnLoad:Boolean = false;
      
      private var m_disableAllyRemoveButton:Boolean = false;
      
      private var m_forcedAllies:Array = new Array();
      
      private var m_titanUI:TitanUI = null;
      
      private var m_scoutWarningSkipped:Boolean;
      
      private var m_currentFleetStrength:int;
      
      private var m_domEnemyPortrait:ImageLoader;
      
      private var m_UIWidthOffset:Number = 0;
      
      private var m_UIHeightOffset:Number = 0;
      
      public function PreBattleUI()
      {
         super(ITEM_ID);
         this.m_titanUI = new TitanUI();
         addEventListener(ADD_PREBATTLE_UI,this.onAddPreBattleUI);
         addEventListener(REMOVE_PREBATTLE_UI,this.onRemovePreBattleUI);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_WIDTH_OFFSET,this.onUIWidthOffset);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_HEIGHT_OFFSET,this.onUIHeightOffset);
      }
      
      public static function getPreBattleUI() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(PreBattleUI.ITEM_ID);
      }
      
      private function onUIWidthOffset(param1:RepositionEvent) : void
      {
         this.m_UIWidthOffset = param1.x;
         if(this.m_content)
         {
            this.positionScreen();
         }
      }
      
      private function onUIHeightOffset(param1:RepositionEvent) : void
      {
         this.m_UIHeightOffset = param1.y;
         if(this.m_content)
         {
            this.positionScreen();
         }
      }
      
      private function onAddPreBattleUI(param1:WorldEvent) : void
      {
         this.m_preBattleAdded = true;
         this.m_preBattle = param1.eventData.preBattle as IPreBattle;
         if(this.m_preBattle.questData)
         {
            if(this.m_preBattle.questData.allies)
            {
               this.m_forcedAllies = this.m_preBattle.questData.allies;
            }
         }
         if(null == this.m_resource)
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/displays/screens/BattleSetupHudOverlay.swf"),SWFResource,this.onLoadComplete,this.onLoadFailed);
         }
         else
         {
            this.addPreBattleUI();
         }
      }
      
      private function addPreBattleUI() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.DISABLE_PRE_BATTLE_UI_CONTROLS,this.onDisablePreBattleUIControls);
         TutorialManager.instance.addEventListener(TutorialManager.ENABLE_PRE_BATTLE_UI_CONTROLS,this.onEnablePreBattleUIControls);
         TutorialManager.instance.addEventListener(TutorialManager.LIMIT_ALLY_SELECTION,this.onLimitAllySelection);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_TITAN_MODE,this.onTitanMode);
         this.m_screen.visible = true;
         this.m_terrainSelectionEnabled = ChallengeModeManager.instance.isInChallengeBattle() || this.m_preBattle.enemyFleet.hasStatus(Fleet.QUEST) || this.m_preBattle.enemyFleet.hasStatus(Fleet.MECHLAB) || SurvivalModeManager.instance.isInSurvivalBattle() || DominationModeManager.instance.isInDefenseForceEditMode() || QuestSurvivalModeManager.instance.isInQuestSurvivalBattle() || DeathMatchManager.instance.isInDeathMatchBattle();
         if(Boolean(this.m_preBattle.questData) && Boolean(this.m_preBattle.questData.playerType))
         {
            this.m_terrainSelectionEnabled = false;
         }
         this.setupUI();
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_PRE_BATTLE_UI_READY));
         }
      }
      
      private function disposeDominationEnemyPortrait() : void
      {
         if(this.m_domEnemyPortrait)
         {
            this.m_domEnemyPortrait.destroy();
            this.m_domEnemyPortrait = null;
         }
      }
      
      private function onRemovePreBattleUI(param1:WorldEvent) : void
      {
         this.m_preBattleAdded = false;
         if(this.m_initialized)
         {
            this.m_screen.visible = false;
         }
         this.disposeDominationEnemyPortrait();
         this.dispose();
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:CombatBarUIItem = null;
         this.m_resource = param1;
         this.m_screen = this.m_resource.clip;
         addChild(this.m_screen);
         this.m_screen.visible = false;
         if(this.m_preBattleAdded)
         {
            this.addPreBattleUI();
            _loc2_ = ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).getCombatBar();
            UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,_loc2_.x,Zlab.mainStage.stageHeight,_loc2_.width,_loc2_.height));
         }
      }
      
      private function hideDominationModeSkin() : void
      {
         this.m_content.terrainSelect.dominanceFrame_mc.visible = false;
         this.m_content.terrainSelect.innerFrameDominance_mc.visible = false;
         this.m_content.terrainSelect.dominanceCancel_bt.visible = false;
         this.m_content.UnitSelect.dominanceFrame_mc.visible = false;
         this.m_content.UnitSelect.innerFrameDominance_mc.visible = false;
         this.m_content.UnitSelect.force_mc.visible = false;
         this.m_content.UnitSelect.dominanceCancel_bt.visible = false;
         this.m_content.UnitSelect.dominanceTitle_tf.visible = false;
         this.m_content.UnitSelect.dominanceStats_mc.visible = false;
         this.m_content.UnitSelect.help_mc.visible = false;
         this.m_content.UnitSelect.save_bt.visible = false;
         this.m_content.UnitSelect.fight_bt.visible = true;
         this.m_content.UnitSelect.cancel_bt.visible = true;
         this.m_content.terrainSelect.cancel_bt.visible = true;
         this.m_content.UnitSelect.title_tf.visible = true;
      }
      
      private function showDominationModeSkin() : void
      {
         this.m_content.terrainSelect.dominanceFrame_mc.visible = true;
         this.m_content.terrainSelect.innerFrameDominance_mc.visible = true;
         this.m_content.terrainSelect.dominanceCancel_bt.visible = true;
         this.m_content.UnitSelect.dominanceFrame_mc.visible = true;
         this.m_content.UnitSelect.innerFrameDominance_mc.visible = true;
         this.m_content.UnitSelect.force_mc.visible = true;
         this.m_content.UnitSelect.dominanceCancel_bt.visible = true;
         this.m_content.UnitSelect.dominanceTitle_tf.visible = true;
         this.m_content.UnitSelect.dominanceStats_mc.visible = false;
         this.m_content.UnitSelect.help_mc.visible = DominationModeManager.instance.isInDefenseForceEditMode();
         this.m_content.UnitSelect.save_bt.visible = DominationModeManager.instance.isInDefenseForceEditMode();
         this.m_content.UnitSelect.fight_bt.visible = !DominationModeManager.instance.isInDefenseForceEditMode();
         this.m_content.UnitSelect.cancel_bt.visible = false;
         this.m_content.terrainSelect.cancel_bt.visible = false;
         this.m_content.UnitSelect.title_tf.visible = false;
         var _loc1_:String = DominationModeManager.instance.isInDefenseForceEditMode() ? "DominationSetupDefenseTitle" : "DominationSetupAttackTitle";
         TextFieldUtil.processTextField(this.m_content.UnitSelect.dominanceTitle_tf,ZGameUtils.ZlocT("Dialogs",_loc1_));
         TextFieldUtil.processTextField(this.m_content.UnitSelect.help_mc.help_tf," ");
         this.updateTotalStrength();
         this.enableDominationModeTooltips();
         this.enableEnemyPortrait();
      }
      
      private function enableEnemyPortrait() : void
      {
         var _loc1_:String = null;
         var _loc2_:Object = null;
         if(DominationModeManager.instance.isInDominationBattle())
         {
            this.m_content.opponentIcon_mc.visible = true;
            _loc1_ = DominationModeManager.instance.getDominationEnemyUID();
            _loc2_ = DominationModeManager.instance.getDominationInfo(_loc1_,true);
            if(!_loc2_)
            {
               _loc2_ = new Object();
               _loc2_.u_info = new Object();
               _loc2_.u_info.name = "";
               _loc2_.u_info.image = "";
            }
            if(!_loc2_.u_info.name)
            {
               _loc2_.u_info.name = "";
            }
            TextFieldUtil.compactTextField(this.m_content.opponentIcon_mc.name_tf,_loc2_.u_info.name,{"maxLines":1});
            this.disposeDominationEnemyPortrait();
            if(!_loc2_.u_info.image)
            {
               _loc2_.u_info.image = ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
            }
            this.m_domEnemyPortrait = ImageLoaderFactory.CreateImageLoader(_loc2_.u_info.image,this.m_content.opponentIcon_mc.icon);
         }
      }
      
      private function enableDominationModeTooltips() : void
      {
         Tooltip.subscribe(this.m_content.UnitSelect.force_mc,ZGameUtils.ZlocT("Dialogs","DominationStrengthHelp"));
         Tooltip.subscribe(this.m_content.UnitSelect.help_mc,ZGameUtils.ZlocT("Dialogs","DominanceQuestionMarkTooltip"));
         if(this.m_backButton)
         {
            this.m_backButton.addTooltip(ZGameUtils.ZlocT("Dialogs","DominationTheaterHelp"));
         }
      }
      
      private function disableDominationModeTooltip() : void
      {
         Tooltip.unsubscribe(this.m_content.UnitSelect.force_mc);
         Tooltip.unsubscribe(this.m_content.UnitSelect.help_mc);
      }
      
      private function updateTotalStrength() : void
      {
         var _loc1_:PreBattleUnitCard = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:UnitItem = null;
         if(DominationModeManager.instance.isInDefenseForceEditMode() || DominationModeManager.instance.isInDominationBattle())
         {
            this.m_currentFleetStrength = 0;
            for each(_loc1_ in this.m_unitPlacementCards)
            {
               _loc5_ = _loc1_.code;
               if(_loc5_)
               {
                  _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc5_,UnitItem) as UnitItem;
                  this.m_currentFleetStrength += _loc6_.getUpgradedStrength();
               }
            }
            _loc2_ = int(DominationModeManager.instance.maxForceStrengthDefend);
            _loc3_ = this.m_currentFleetStrength.toString() + "/" + _loc2_.toString();
            TextFieldUtil.processTextField(this.m_content.UnitSelect.force_mc.force_tf,_loc3_);
            _loc4_ = DominationModeManager.instance.getStrengthColor(this.m_currentFleetStrength);
            this.m_content.UnitSelect.force_mc.force_tf.textColor = _loc4_;
         }
      }
      
      private function setupUI() : void
      {
         var _loc2_:String = null;
         var _loc3_:Fleet = null;
         this.m_initialized = true;
         this.m_content = this.m_screen.content_mc;
         this.m_overlay = this.m_screen.overlay_mc;
         this.m_allyoverlay = this.m_screen.allyoverlay_mc;
         this.m_tooltipOverlay = this.m_screen.tooltip_mc;
         this.m_content.UnitSelect.grid_mc.warning_tf.visible = false;
         this.m_content.unitSuggester_mc.visible = false;
         this.m_content.UnitSelect.titanFightFrame_mc.visible = false;
         this.hideDominationModeSkin();
         this.m_content.gotoAndStop(1);
         this.positionScreen();
         var _loc1_:Function = Boolean(this.m_forcedAllies) && this.m_forcedAllies.length > 0 ? this.onGotoAlliesPanelFromTerrain : this.onGotoUnitsPanel;
         this.m_theaterNextButton = this.initButton(this.m_content.terrainSelect.next_bt,ZGameUtils.ZlocT("Dialogs","Next"),_loc1_);
         this.m_nextButton = this.initButton(this.m_content.AllySelect.next_bt,ZGameUtils.ZlocT("Dialogs","Next"),this.onGotoUnitsPanel);
         this.m_backButton = this.initButton(this.m_content.UnitSelect.back_bt,ZGameUtils.ZlocT("Dialogs","Back"),this.onGotoAlliesPanel);
         this.m_buyButton = this.initButton(this.m_content.UnitSelect.buy_bt,ZGameUtils.ZlocT("Dialogs","BuyUnits"),this.onBuyUnits);
         this.m_content.AllySelect.revive_bt.visible = false;
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.addToUIElements(this.m_content.AllySelect.next_bt);
            TutorialManager.instance.registerUIItem(this.m_content.AllySelect.next_bt,"CombatSetupNext");
         }
         if(DominationModeManager.instance.isInDefenseForceEditMode())
         {
            _loc2_ = "Save";
            this.m_fightButton = new ZGameButton(this.m_content.UnitSelect.save_bt,this.onFight);
            this.m_backButton.text = ZGameUtils.ZlocT("Dialogs","CombatSetupTheater");
         }
         else
         {
            _loc2_ = "Fight";
            this.m_fightButton = new PreBattleFightButton(this.m_content.UnitSelect.fight_bt,this.onFight);
         }
         this.m_fightButton.text = ZGameUtils.ZlocT("Dialogs",_loc2_);
         this.m_fightButton.show();
         this.m_fightButton.enable();
         this.m_content.opponentIcon_mc.visible = false;
         if(DominationModeManager.instance.isInDefenseForceEditMode() || DominationModeManager.instance.isInDominationBattle())
         {
            this.showDominationModeSkin();
         }
         else
         {
            this.hideDominationModeSkin();
         }
         if(!AlliancesManager.instance.allianceBattle)
         {
            this.m_inviteCard = new BattleSetupInviteCard(this.m_content.AllySelect.grid_mc.inviteCard_mc,this.onInviteFriendButton);
         }
         else
         {
            this.m_inviteCard = new BattleSetupInviteCard(this.m_content.allianceAlly.grid_mc.inviteCard_mc,this.onInviteFriendButton);
         }
         this.m_content.UnitSelect.help_mc.mouseEnabled = true;
         this.m_content.UnitSelect.help_mc.buttonMode = true;
         this.m_content.UnitSelect.help_mc.useHandCursor = true;
         this.m_content.UnitSelect.help_mc.addEventListener(MouseEvent.CLICK,this.onDominationHelp);
         this.m_content.terrainSelect.cancel_bt.mouseEnabled = true;
         this.m_content.terrainSelect.cancel_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         this.m_content.terrainSelect.dominanceCancel_bt.mouseEnabled = true;
         this.m_content.terrainSelect.dominanceCancel_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         this.m_content.AllySelect.cancel_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         this.m_content.allianceAlly.cancel_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         this.m_content.UnitSelect.cancel_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         this.m_content.UnitSelect.dominanceCancel_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_theaterNextButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_nextButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_buyButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_fightButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.terrainSelect.cancel_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.terrainSelect.dominanceCancel_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.AllySelect.cancel_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.allianceAlly.cancel_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.UnitSelect.cancel_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.UnitSelect.dominanceCancel_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.terrainSelect.air_bt_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.terrainSelect.land_bt_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_content.terrainSelect.sea_bt_mc,ButtonSound.DEFAULT);
         this.addTheaterCard(this.m_content.terrainSelect.air_bt_mc,ChallengeBattleTheaterCard.THEATER_AIR);
         this.addTheaterCard(this.m_content.terrainSelect.land_bt_mc,ChallengeBattleTheaterCard.THEATER_LAND);
         this.addTheaterCard(this.m_content.terrainSelect.sea_bt_mc,ChallengeBattleTheaterCard.THEATER_SEA);
         TextFieldUtil.processTextField(this.m_content.terrainSelect.title_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupTerrainSelectTitle"));
         this.setUnitSelectTitle("CombatSetupUnitSelectTitle");
         TextFieldUtil.processTextField(this.m_content.AllySelect.title_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupAllySelectTitle"));
         TextFieldUtil.processTextField(this.m_content.allianceAlly.title_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupAllySelectTitle"));
         this.m_content.terrainSelect.title_tf.mouseEnabled = false;
         this.m_content.UnitSelect.title_tf.mouseEnabled = false;
         this.m_content.AllySelect.title_tf.mouseEnabled = false;
         this.m_content.allianceAlly.title_tf.mouseEnabled = false;
         this.createAllyCards();
         this.updateAllySelectionText();
         this.createUnitPlacementCards();
         addEventListener(PreBattleUnitCard.CARD_CANCEL,this.onUnitPlacementCardCancel,false,0,true);
         this.createEnemyTooltipCards();
         this.activateFirstVacantCard();
         if(DominationModeManager.instance.isInDefenseForceEditMode() && DominationModeManager.instance.getPrevDefenseForceFleet() != null)
         {
            _loc3_ = DominationModeManager.instance.getPrevDefenseForceFleet();
            this.m_preBattle.fleet.type = _loc3_.type;
            this.activateUnitsPanel();
            this.m_content.gotoAndPlay("_units");
         }
         else if(this.m_terrainSelectionEnabled)
         {
            this.activateTerrainPanel();
            this.m_content.gotoAndStop("_terrain");
         }
         else if(this.numAlliesAllowedForCurrentMap > 0)
         {
            if(AlliancesManager.instance.allianceBattle)
            {
               this.activateAllianceAlliesPanel(true);
               this.m_nextButton = this.initButton(this.m_content.allianceAlly.next_bt,ZGameUtils.ZlocT("Dialogs","Next"),this.onGotoUnitsPanel);
               this.m_content.gotoAndPlay("_allianceAllies");
            }
            else
            {
               this.activateAlliesPanel(true);
               this.m_content.gotoAndPlay("_allies");
            }
         }
         else
         {
            this.activateUnitsPanel();
            this.m_content.gotoAndPlay("_units");
            this.m_backButton.hide();
         }
         addEventListener(StackedUnitsGrid.UNIT_CARD_SELECTED,this.onUnitCardSelected,false,0,true);
         addEventListener(BattleSetupAllyGrid.ALLY_SELECTED,this.onAllySelected,false,0,true);
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullscreenEvent,false,0,true);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.onCombatAllyOverlayReposition,false,0,true);
         this.updateUIState();
         this.onUnitsPanelReached(false);
         if(this.m_disableOnLoad)
         {
            this.onDisablePreBattleUIControls();
            this.m_disableOnLoad = false;
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:PreBattleUnitCard = null;
         var _loc2_:IPreBattleEnemyCard = null;
         var _loc3_:ChallengeBattleTheaterCard = null;
         for each(_loc1_ in this.m_unitPlacementCards)
         {
            this.m_overlay.cardAnchor_mc.removeChild(_loc1_.art);
            _loc1_.dispose();
         }
         this.m_unitPlacementCards = null;
         for each(_loc2_ in this.m_enemyTooltipCards)
         {
            this.m_tooltipOverlay.anchor_mc.removeChild(_loc2_.art);
            _loc2_.dispose();
         }
         this.m_enemyTooltipCards = null;
         if(this.m_alliesGrid)
         {
            this.m_alliesGrid.dispose();
            this.m_alliesGrid = null;
         }
         if(this.m_unitsGrid)
         {
            this.m_unitsGrid.dispose();
            this.m_unitsGrid = null;
         }
         this.disposeUnitSuggester();
         this.disposeMechSetup();
         removeEventListener(StackedUnitsGrid.UNIT_CARD_SELECTED,this.onUnitCardSelected);
         removeEventListener(BattleSetupAllyGrid.ALLY_SELECTED,this.onAllySelected);
         Zlab.inputManager.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullscreenEvent);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.onCombatAllyOverlayReposition);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_TITAN_MODE,this.onTitanMode);
         removeEventListener(PreBattleUnitCard.CARD_CANCEL,this.onUnitPlacementCardCancel);
         Zlab.processManager.removeScheduledObject(this);
         this.disposeAllyCards();
         if(this.m_initialized)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
            this.m_fightButton.pulse = false;
            this.m_nextButton.dispose();
            this.m_backButton.dispose();
            this.m_buyButton.dispose();
            this.m_fightButton.dispose();
            this.m_inviteCard.dispose();
            this.m_content.terrainSelect.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.m_content.terrainSelect.dominanceCancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.m_content.AllySelect.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.m_content.allianceAlly.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.m_content.UnitSelect.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.m_content.UnitSelect.dominanceCancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.m_content.UnitSelect.help_mc.removeEventListener(MouseEvent.CLICK,this.onDominationHelp);
         }
         while(this.m_theaterCard.length)
         {
            _loc3_ = ChallengeBattleTheaterCard(this.m_theaterCard.pop());
            _loc3_.card.removeEventListener(MouseEvent.CLICK,this.onTheaterCardSelected);
            _loc3_.dispose();
         }
         TutorialManager.instance.removeEventListener(TutorialManager.DISABLE_PRE_BATTLE_UI_CONTROLS,this.onDisablePreBattleUIControls);
         TutorialManager.instance.removeEventListener(TutorialManager.ENABLE_PRE_BATTLE_UI_CONTROLS,this.onEnablePreBattleUIControls);
         TutorialManager.instance.removeEventListener(TutorialManager.LIMIT_ALLY_SELECTION,this.onLimitAllySelection);
         this.disableDominationModeTooltip();
         this.m_forcedAllies = null;
         TITAN_MODE = false;
      }
      
      private function onLoadFailed(param1:SWFResource) : void
      {
         Logger.error(this,"onLoadFailed","unable to load " + param1.filename);
      }
      
      private function initButton(param1:MovieClip, param2:String = "", param3:Function = null) : ZGameButton
      {
         var _loc4_:ZGameButton = new ZGameButton(param1,param3);
         _loc4_.compactText(param2,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         _loc4_.show();
         _loc4_.enable();
         return _loc4_;
      }
      
      public function get titanUI() : TitanUI
      {
         return this.m_titanUI;
      }
      
      private function get numAlliesAllowedForCurrentMap() : int
      {
         var _loc1_:int = 0;
         if(Boolean(this.m_forcedAllies) && this.m_forcedAllies.length > 0)
         {
            return this.m_forcedAllies.length;
         }
         if(this.m_preBattle.questData)
         {
            return this.m_preBattle.questData.numAllies != undefined ? int(this.m_preBattle.questData.numAllies) : 0;
         }
         if(ChallengeModeManager.instance.isInChallengeBattle() || this.m_terrainSelectionEnabled)
         {
            return 0;
         }
         if(AlliancesManager.instance.allianceBattle)
         {
            if(Boolean(AlliancesManager.instance.members) && AlliancesManager.instance.members.length > 1)
            {
               _loc1_ = int(AlliancesManager.instance.members.length);
            }
            else
            {
               _loc1_ = 2;
            }
            if(_loc1_ > 0)
            {
               if(_loc1_ <= 5)
               {
                  return _loc1_ - 1;
               }
               return 4;
            }
            return 0;
         }
         if(Boolean(ZGlobal.player.campaign.currentMapName) && Boolean(ZGlobal.player.campaign.currentMap))
         {
            return ZGlobal.player.campaign.currentMap.numAllies < 0 ? 1 : ZGlobal.player.campaign.currentMap.numAllies;
         }
         return 0;
      }
      
      private function get numAlliesSelectedForCurrentMap() : int
      {
         return this.m_alliesGrid ? int(this.m_alliesGrid.selections.length) : 0;
      }
      
      private function updateAllySelectionText() : void
      {
         TextFieldUtil.processTextField(this.m_content.lineup_mc.title_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupAllyLineupTitle",{
            "num":this.numAlliesSelectedForCurrentMap,
            "total":this.numAlliesAllowedForCurrentMap,
            "ally":ZGameUtils.ZlocTk("Objects","ally","",this.numAlliesAllowedForCurrentMap)
         }));
      }
      
      private function onAllyPlacementCardClicked(param1:WorldEvent) : void
      {
         var _loc2_:BattleSetupAllyPlacementCard = BattleSetupAllyPlacementCard(param1.eventData);
         this.m_alliesGrid.removeAlly(_loc2_.ally);
         this.populateAllyCards();
         this.updateUIState();
         if(this.m_currentPanel == PANEL_UNITS)
         {
            this.onGotoAlliesPanel();
         }
      }
      
      private function onUnitCardSelected(param1:WorldEvent) : void
      {
         var _loc2_:StackedUnitInfo = null;
         if(this.m_activePlacement)
         {
            _loc2_ = StackedUnitInfo(param1.eventData);
            this.m_activePlacement.setOccupied(_loc2_.unitItem);
            if(_loc2_.unitItem.code == EspionageHQManager.instance.stolenUnit && EspionageHQManager.instance.shouldShowCard())
            {
               EspionageHQManager.instance.unitInPreBattle = true;
               this.m_unitsGrid.disableStolenCard(_loc2_.unitItem);
            }
            this.m_unitsGrid.deductUnit(_loc2_.unitItem);
            this.activateFirstVacantCard();
            this.updateUIState();
            this.updateTotalStrength();
            this.sortCards();
         }
      }
      
      private function sortCards() : void
      {
         var _loc1_:Dictionary = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         var _loc5_:DisplayObject = null;
         var _loc6_:PreBattleUnitCard = null;
         var _loc7_:int = 0;
         if(TITAN_MODE)
         {
            _loc1_ = new Dictionary();
            _loc2_ = int(this.m_overlay.cardAnchor_mc.numChildren);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = this.m_overlay.cardAnchor_mc.getChildAt(_loc3_);
               _loc6_ = this.getPreBattleUnitCard(_loc5_);
               if(_loc6_)
               {
                  _loc1_[_loc6_.unitItem.formationIndex.toString()] = _loc6_;
               }
               _loc3_++;
            }
            _loc4_ = 0;
            while(DictionaryUtil.getKeys(_loc1_).length)
            {
               _loc7_ = this.getLowestKey(_loc1_);
               this.m_overlay.cardAnchor_mc.setChildIndex(_loc1_[_loc7_].art,_loc4_++);
               delete _loc1_[_loc7_];
            }
         }
      }
      
      private function defaultFleetSetup() : void
      {
         var _loc2_:String = null;
         var _loc4_:UnitItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc1_:Array = DominationModeManager.instance.getDefaultFleet(this.m_preBattle.fleet.type);
         if(!_loc1_ || !_loc1_.length)
         {
            return;
         }
         var _loc3_:Dictionary = new Dictionary();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc3_.hasOwnProperty(_loc2_))
            {
               _loc3_[_loc2_] = 0;
            }
            _loc3_[_loc2_] += 1;
         }
         for(_loc2_ in _loc3_)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
            if(_loc4_)
            {
               _loc5_ = int(_loc3_[_loc2_]);
               _loc6_ = Fleet.getDeployableCount(_loc2_);
               _loc5_ = Math.min(_loc5_,_loc6_);
               _loc7_ = 0;
               while(_loc7_ < _loc5_)
               {
                  if(this.m_activePlacement)
                  {
                     DominationModeManager.instance.updateSetupFleetStrength(_loc4_.getUpgradedStrength());
                     this.m_activePlacement.setOccupied(_loc4_);
                     this.activateFirstVacantCard();
                  }
                  _loc7_++;
               }
               if(_loc5_)
               {
                  this.m_unitsGrid.addUnitWithAmount(_loc4_,-_loc5_);
               }
            }
         }
         this.updateUIState();
      }
      
      private function defenseForceEditorSetup() : void
      {
         var _loc2_:Unit = null;
         var _loc3_:UnitItem = null;
         DominationModeManager.instance.resetSetupFleetStrength();
         var _loc1_:Fleet = DominationModeManager.instance.getPrevDefenseForceFleet();
         if(Boolean(_loc1_) && _loc1_.type == this.m_preBattle.fleet.type)
         {
            for each(_loc2_ in _loc1_.units)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,UnitItem) as UnitItem;
               if(this.m_activePlacement)
               {
                  DominationModeManager.instance.updateSetupFleetStrength(_loc3_.getUpgradedStrength());
                  this.m_activePlacement.setOccupied(_loc3_);
                  this.activateFirstVacantCard();
                  this.updateUIState();
               }
            }
         }
         DominationModeManager.instance.handleDefenseForceIntro();
      }
      
      private function getPreBattleUnitCard(param1:DisplayObject) : PreBattleUnitCard
      {
         var _loc2_:PreBattleUnitCard = null;
         for each(_loc2_ in this.m_unitPlacementCards)
         {
            if(Boolean(_loc2_.unitItem) && _loc2_.art == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function getLowestKey(param1:Dictionary) : int
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc2_:int = int.MAX_VALUE;
         for(_loc3_ in param1)
         {
            _loc4_ = parseInt(_loc3_);
            if(_loc4_ < _loc2_)
            {
               _loc2_ = _loc4_;
            }
         }
         return _loc2_;
      }
      
      private function onAllySelected(param1:WorldEvent) : void
      {
         this.populateAllyCards();
         this.updateUIState();
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_ALLY_ADDED));
         }
      }
      
      private function onLocationCancel(param1:int) : void
      {
         var _loc3_:PreBattleUnitCard = null;
         var _loc2_:String = this.m_titanUI.getOccupiedAt(param1);
         for each(_loc3_ in this.m_unitPlacementCards)
         {
            if(_loc3_.code == _loc2_)
            {
               this.cancelCard(_loc3_);
               break;
            }
         }
      }
      
      private function onUnitPlacementCardCancel(param1:WorldEvent) : void
      {
         this.cancelCard(PreBattleUnitCard(param1.eventData));
      }
      
      private function cancelCard(param1:PreBattleUnitCard) : void
      {
         if(this.m_activePlacement)
         {
            this.m_activePlacement.setVacant();
         }
         this.m_activePlacement = param1;
         this.m_unitsGrid.returnUnit(this.m_activePlacement.unitItem);
         if(this.m_activePlacement.unitItem.code == EspionageHQManager.instance.stolenUnit && EspionageHQManager.instance.shouldShowCard())
         {
            EspionageHQManager.instance.unitInPreBattle = false;
            this.m_unitsGrid.enableStolenCard(this.m_activePlacement.unitItem);
         }
         this.m_activePlacement.setActive();
         this.updateUIState();
         this.updateTotalStrength();
      }
      
      private function populateAllyCards() : void
      {
         var _loc3_:BattleSetupAllyPlacementCard = null;
         var _loc4_:IAlly = null;
         var _loc5_:Array = null;
         var _loc1_:int = this.m_alliesGrid ? int(this.m_alliesGrid.selections.length) : 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_allyPlacementCards.length)
         {
            _loc3_ = BattleSetupAllyPlacementCard(this.m_allyPlacementCards[_loc2_]);
            _loc4_ = this.m_alliesGrid ? (_loc2_ < this.m_alliesGrid.selections.length ? this.m_alliesGrid.selections[_loc2_] as IAlly : null) : null;
            _loc3_.displayAlly(_loc4_,this.m_disableAllyRemoveButton);
            BattleSetupAllyCard(this.m_allyTweenCards[_loc2_]).displayAlly(_loc4_);
            BattleSetupAllyCard(this.m_allyGridCards[_loc2_]).displayAlly(_loc4_);
            if(!_loc4_ && _loc2_ == _loc1_)
            {
               _loc3_.setFocused();
            }
            _loc2_++;
         }
         if(this.numAlliesAllowedForCurrentMap > 0)
         {
            _loc5_ = [this.m_content.lineup_mc.anchor1,this.m_content.lineup_mc.anchor2,this.m_content.lineup_mc.anchor3,this.m_content.lineup_mc.anchor4,this.m_content.lineup_mc.anchor5];
            this.m_content.lineup_mc.cards_mc.x = _loc5_[this.numAlliesAllowedForCurrentMap - 1].x;
            this.m_content.lineup_mc.visible = true;
         }
         else
         {
            this.m_content.lineup_mc.visible = false;
         }
      }
      
      private function updateUIState() : void
      {
         if(this.numAlliesSelectedForCurrentMap == this.numAlliesAllowedForCurrentMap || AlliancesManager.instance.allianceBattle)
         {
            this.disableReviveAllyButton();
            this.m_nextButton.enable();
         }
         else
         {
            this.updateReviveAllyButton(null,true);
            this.m_nextButton.disable_visual(true);
         }
         this.updateAllySelectionText();
         if(ZGlobal.stencilActive && this.numOccupiedCards() == this.m_preBattle.numUnits || this.numOccupiedCards() > 0 && !ZGlobal.stencilActive)
         {
            this.m_fightButton.enable();
         }
         else
         {
            this.m_fightButton.disable_visual();
         }
         this.m_fightButton.pulse = this.numOccupiedCards() == this.m_preBattle.numUnits;
         if(this.m_mechSetup)
         {
            this.m_mechSetup.updateUI(this.m_titanUI);
         }
      }
      
      private function get numFilledOutSlots() : int
      {
         var _loc2_:PreBattleUnitCard = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_unitPlacementCards)
         {
            if(_loc2_.code)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function onFight(param1:MouseEvent = null) : void
      {
         if(this.shouldShowDominationScoutWarning(DominationModeManager.DOMINATION_PREBATTLE_ATTACK_EDITOR))
         {
            this.showScoutWarningPopup(DominationModeManager.DOMINATION_PREBATTLE_ATTACK_EDITOR);
         }
         else if(this.shouldShowDominationScoutWarning(DominationModeManager.DOMINATION_PREBATTLE_DEFENSE_EDITOR))
         {
            this.showScoutWarningPopup(DominationModeManager.DOMINATION_PREBATTLE_DEFENSE_EDITOR);
         }
         else if(this.shouldShowWarning())
         {
            PopupManager.instance.push(new BattleWarningPopup(this.m_preBattle.enemyFleet,this.m_preBattle.fleet.type,this.m_preBattle.numUnits,this.onBattleWarningPopupClosed));
         }
         else
         {
            this.m_scoutWarningSkipped = false;
            this.startFight();
         }
      }
      
      private function showScoutWarningPopup(param1:int) : void
      {
         var _loc2_:DominationScoutWarningPopup = new DominationScoutWarningPopup(param1);
         _loc2_.addEventListener(Event.CLOSE,this.onScoutWarningClosed,false,0,true);
         PopupManager.instance.push(_loc2_);
      }
      
      private function onScoutWarningClosed(param1:Event) : void
      {
         if(Boolean(param1 as WorldEvent) && Boolean((param1 as WorldEvent).eventData.proceed))
         {
            this.m_scoutWarningSkipped = true;
            this.onFight();
         }
      }
      
      private function shouldShowDominationScoutWarning(param1:int) : Boolean
      {
         if(this.m_scoutWarningSkipped)
         {
            return false;
         }
         if(param1 == DominationModeManager.DOMINATION_PREBATTLE_ATTACK_EDITOR && !DominationModeManager.instance.isInDominationBattle())
         {
            return false;
         }
         if(param1 == DominationModeManager.DOMINATION_PREBATTLE_DEFENSE_EDITOR && !DominationModeManager.instance.isInDefenseForceEditMode())
         {
            return false;
         }
         if(!DominationModeManager.instance.isUnderStrengthPercent(this.m_currentFleetStrength,DominationModeManager.STRENGTH_TYPE_LOW))
         {
            return false;
         }
         return true;
      }
      
      private function shouldShowWarning() : Boolean
      {
         var _loc3_:Array = null;
         var _loc1_:Boolean = true;
         var _loc2_:StrategicMap = ZGlobal.player.campaign.currentMap;
         if(_loc2_)
         {
            if(!_loc2_.inReplay)
            {
               if(Boolean(_loc2_.currentIslandItem) && _loc2_.currentIslandItem.suppressCCPopup)
               {
                  _loc1_ = false;
               }
            }
         }
         if(_loc1_)
         {
            _loc3_ = this.getFleetUnits();
            _loc1_ = BattleWarningPopup.shouldShowWarning(_loc3_,this.m_preBattle.enemyFleet);
         }
         if(_loc1_)
         {
            _loc1_ = !DominationModeManager.instance.isInDominationBattle();
         }
         return _loc1_;
      }
      
      private function getFleetUnits() : Array
      {
         var _loc2_:PreBattleUnitCard = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_unitPlacementCards)
         {
            if(_loc2_.code)
            {
               _loc1_.push(_loc2_.code);
            }
         }
         return _loc1_;
      }
      
      private function onBattleWarningPopupClosed(param1:int) : void
      {
         if(param1 == GenericPopup.NO)
         {
            this.startFight();
         }
      }
      
      private function onFightCheck(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.startFight();
         }
      }
      
      private function startFight() : void
      {
         var _loc4_:PreBattleUnitCard = null;
         var _loc5_:IAlly = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc1_:Array = new Array();
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         for each(_loc4_ in this.m_unitPlacementCards)
         {
            _loc3_ = _loc4_.code;
            if(_loc3_)
            {
               _loc1_.push(_loc3_);
               if(!_loc2_ && _loc4_.unitItem.hasType(UnitItem.MEGA_UNIT))
               {
                  _loc2_ = true;
               }
            }
         }
         if(_loc2_)
         {
            _loc1_.sort(this.compareFormation);
         }
         for each(_loc3_ in _loc1_)
         {
            this.m_preBattle.fleet.addUpgrades(_loc3_,WorldUpgradeManager.instance.getUpgradesByCode(_loc3_));
            this.m_preBattle.fleet.addUnit(_loc3_);
            if(_loc3_ == EspionageHQManager.instance.stolenUnit && EspionageHQManager.instance.shouldShowCard())
            {
               EspionageHQManager.instance.unitInBattle = true;
               EspionageHQManager.instance.sendtransaction();
            }
         }
         if(null != this.m_alliesGrid)
         {
            for each(_loc5_ in this.m_alliesGrid.selections)
            {
               this.m_preBattle.fleet.addAlly(_loc5_.id);
               ZGlobal.player.allies.addAlly(_loc5_.id);
            }
         }
         if(this.m_preBattle.fleet.units.length <= 0)
         {
            this.updateUIState();
            return;
         }
         if(this.m_unitSuggester)
         {
            ZGlobal.player.setSeenFlag(SEEN_UNIT_SUGGESTER_FLAG_NAME);
         }
         if(DominationModeManager.instance.isInDefenseForceEditMode())
         {
            DominationModeManager.instance.updateDefenseForce();
            this.m_preBattle.cancelFight();
            DominationModeManager.instance.exitDefenseForceEditMode();
            return;
         }
         if(DominationModeManager.instance.isInDominationBattle() && !AlliancesManager.instance.allianceBattle)
         {
            DominationModeManager.instance.loadDominationModeBattle(this.m_preBattle.fleet.name,DominationModeManager.instance.getDominationEnemyUID());
            DominationModeManager.instance.addEventListener(DominationModeManager.EXIT_DOMINATION_PREBATTLE,this.onExitDominationPreBattle);
            return;
         }
         if(AlliancesManager.instance.allianceBattle)
         {
            _loc6_ = AlliancesManager.instance.allianceBattleMember;
            _loc7_ = AlliancesManager.instance.battleAllianceName;
            _loc8_ = AlliancesManager.instance.isLostAllianceBattle();
            AlliancesManager.instance.loadBattle(this.m_preBattle.fleet.name,_loc6_,_loc7_,_loc8_);
            if(_loc8_)
            {
               AlliancesManager.instance.resetLostBattleData();
            }
            DominationModeManager.instance.addEventListener(DominationModeManager.EXIT_DOMINATION_PREBATTLE,this.onExitDominationPreBattle);
            return;
         }
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_FIGHT_CONTINUE));
         this.m_preBattle.fleet.deploy();
         this.m_preBattle.startFight();
      }
      
      private function compareFormation(param1:String, param2:String) : Number
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2,UnitItem) as UnitItem;
         var _loc5_:int = _loc3_.formationIndex;
         var _loc6_:int = _loc4_.formationIndex;
         if(_loc5_ > _loc6_)
         {
            return 1;
         }
         return -1;
      }
      
      public function onExitDominationPreBattle(param1:Event) : void
      {
         DominationModeManager.instance.removeEventListener(DominationModeManager.EXIT_DOMINATION_PREBATTLE,this.onExitDominationPreBattle);
         this.m_preBattle.cancelFight();
         DominationModeManager.instance.exitDominationBattle();
      }
      
      private function addTheaterCard(param1:MovieClip, param2:int) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:ChallengeBattleTheaterCard = new ChallengeBattleTheaterCard(param1,param2);
         _loc3_.card.addEventListener(MouseEvent.CLICK,this.onTheaterCardSelected,false,0,true);
         this.m_theaterCard.push(_loc3_);
         if(_loc3_.battleType == this.m_preBattle.fleet.type)
         {
            _loc3_.setSelected();
            this.m_theater = _loc3_.theater;
         }
         if(!DominationModeManager.instance.isInSetupFleetEditMode())
         {
            _loc4_ = _loc3_.battleType == UnitItem.ARMY;
            if(_loc4_)
            {
               _loc4_ = MechBattleSetup.isEnabled();
            }
         }
         param1.mechIcon_mc.visible = _loc4_;
      }
      
      protected function onTheaterCardSelected(param1:MouseEvent) : void
      {
         var _loc3_:ChallengeBattleTheaterCard = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_theaterCard.length)
         {
            _loc3_ = ChallengeBattleTheaterCard(this.m_theaterCard[_loc2_]);
            if(_loc3_.card == param1.currentTarget)
            {
               _loc3_.setSelected();
               this.m_theater = _loc3_.theater;
               this.selectTheater(_loc3_.battleType);
            }
            else
            {
               _loc3_.setUnselected();
            }
            _loc2_++;
         }
      }
      
      private function selectTheater(param1:String) : void
      {
         this.m_preBattle.fleet.type = param1;
         if(DominationModeManager.instance.isInDefenseForceEditMode())
         {
            this.m_preBattle.enemyFleet.type = param1;
         }
         var _loc2_:IEntity = ViewManager.instance.getView(BattleWorld.ID);
         _loc2_.eventDispatcher.dispatchEvent(new WorldEvent(BattleWorld.REGISTER_FLEETS,{
            "player":this.m_preBattle.fleet.name,
            "enemy":this.m_preBattle.enemyFleet.name
         }));
      }
      
      private function onUnitsPanelFinished() : void
      {
         this.onUnitsPanelReached(false);
      }
      
      private function onUnitsPanelReached(param1:Boolean) : void
      {
         if(param1)
         {
            Zlab.processManager.schedule(1000,this,this.onUnitsPanelFinished);
         }
         else if(this.m_currentPanel == PANEL_UNITS && TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_UNITS_SCREEN));
         }
      }
      
      private function onInviteFriendButton(param1:MouseEvent) : void
      {
         ZGlobal.switchToTab("invite");
      }
      
      private function onGotoUnitsPanel(param1:MouseEvent) : void
      {
         this.activateUnitsPanel();
         if(AlliancesManager.instance.allianceBattle)
         {
            this.deactivateAlliesPanel();
            this.m_content.gotoAndPlay("_unitsScroll");
         }
         else if(!this.m_terrainSelectionEnabled)
         {
            this.deactivateAlliesPanel();
            this.m_content.gotoAndPlay("_unitsScroll");
         }
         else
         {
            this.deactivateAlliesPanel();
            this.m_content.gotoAndPlay("_units");
         }
         this.onUnitsPanelReached(true);
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_ALLY_NEXT));
      }
      
      private function onGotoAlliesPanel(param1:MouseEvent = null) : void
      {
         if(TITAN_MODE)
         {
            this.onTitanMode(null);
            return;
         }
         this.deactivateUnitsPanel();
         if(AlliancesManager.instance.allianceBattle)
         {
            this.activateAllianceAlliesPanel(true);
            this.m_content.gotoAndPlay("_allianceAllies");
            this.m_content.lineup_mc.visible = true;
         }
         else if(!this.m_terrainSelectionEnabled)
         {
            this.activateAlliesPanel();
            this.m_content.gotoAndPlay("_alliesBack");
            this.m_content.lineup_mc.visible = true;
         }
         else
         {
            this.cancelActiveCards();
            if(this.m_unitsGrid)
            {
               this.m_unitsGrid.dispose();
               this.m_unitsGrid = null;
            }
            this.reCreateUnitPlacementCards();
            this.activateFirstVacantCard();
            this.activateTerrainPanel();
            this.m_content.gotoAndStop("_terrain");
         }
      }
      
      private function onReviveAllyClicked(param1:Event) : void
      {
         ReviveAlliesManager.instance.reviveAllies();
      }
      
      private function cancelActiveCards() : void
      {
         var _loc1_:PreBattleUnitCard = null;
         for each(_loc1_ in this.m_unitPlacementCards)
         {
            if(_loc1_.unitItem)
            {
               this.cancelCard(_loc1_);
            }
         }
      }
      
      private function reCreateUnitPlacementCards() : void
      {
         var _loc1_:PreBattleUnitCard = null;
         for each(_loc1_ in this.m_unitPlacementCards)
         {
            this.m_overlay.cardAnchor_mc.removeChild(_loc1_.art);
            _loc1_.dispose();
         }
         this.m_unitPlacementCards = null;
         this.createUnitPlacementCards();
      }
      
      private function onGotoAlliesPanelFromTerrain(param1:MouseEvent = null) : void
      {
         this.activateAlliesPanel();
         this.m_content.gotoAndPlay("_alliesBack");
         this.m_content.lineup_mc.visible = true;
      }
      
      private function onDominationHelp(param1:MouseEvent) : void
      {
         DominationModeManager.instance.displayDefenseForceDescription();
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            TransactionManager.addTransaction(new TCancelUnstartedChallenge(ChallengeModeManager.instance.currentChallengerFleet()));
         }
         else if(DominationModeManager.instance.isInDefenseForceEditMode())
         {
            DominationModeManager.instance.exitDefenseForceEditMode();
            DominationModeManager.instance.launchDominationScreen();
         }
         else if(DominationModeManager.instance.isInDominationBattle())
         {
            DominationModeManager.instance.exitDominationBattle();
            DominationModeManager.instance.launchDominationScreen();
            if(AlliancesManager.instance.allianceBattle && Boolean(AlliancesManager.instance.allianceBattleMember))
            {
               AlliancesManager.instance.resetAllianceBattleData();
            }
         }
         this.m_preBattle.cancelFight();
      }
      
      private function onBuyUnitsFromSuggester(param1:Event) : void
      {
         UnitsPurchaseDialog.display(this.m_preBattle.fleet.type,this.getPVPOpponentLevelLimit(),this.m_prioritizeSupportUnits);
      }
      
      private function onExitSuggester(param1:Event) : void
      {
         this.disposeUnitSuggester();
      }
      
      private function onBuyUnits(param1:MouseEvent) : void
      {
         UnitsPurchaseDialog.display(this.m_preBattle.fleet.type,this.getPVPOpponentLevelLimit(),false);
      }
      
      private function createAllyCards() : void
      {
         var _loc3_:BattleSetupAllyCard = null;
         var _loc4_:BattleSetupAllyCard = null;
         this.m_allyGridCards = [new BattleSetupAllyCard(this.m_allyoverlay.allyCards_mc.ally0),new BattleSetupAllyCard(this.m_allyoverlay.allyCards_mc.ally1),new BattleSetupAllyCard(this.m_allyoverlay.allyCards_mc.ally2),new BattleSetupAllyCard(this.m_allyoverlay.allyCards_mc.ally3),new BattleSetupAllyCard(this.m_allyoverlay.allyCards_mc.ally4)];
         var _loc1_:int = this.numAlliesAllowedForCurrentMap;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_allyGridCards.length)
         {
            BattleSetupAllyCard(this.m_allyGridCards[_loc2_]).visible = Boolean(_loc2_ < _loc1_);
            _loc2_++;
         }
         this.m_allyTweenCards = [new BattleSetupAllyCard(this.m_screen.fly0),new BattleSetupAllyCard(this.m_screen.fly1),new BattleSetupAllyCard(this.m_screen.fly2),new BattleSetupAllyCard(this.m_screen.fly3),new BattleSetupAllyCard(this.m_screen.fly4)];
         for each(_loc3_ in this.m_allyTweenCards)
         {
            _loc3_.visible = false;
         }
         this.m_allyPlacementCards = [new BattleSetupAllyPlacementCard(this.m_content.lineup_mc.cards_mc.slot0,this),new BattleSetupAllyPlacementCard(this.m_content.lineup_mc.cards_mc.slot1,this),new BattleSetupAllyPlacementCard(this.m_content.lineup_mc.cards_mc.slot2,this),new BattleSetupAllyPlacementCard(this.m_content.lineup_mc.cards_mc.slot3,this),new BattleSetupAllyPlacementCard(this.m_content.lineup_mc.cards_mc.slot4,this)];
         for each(_loc4_ in this.m_allyPlacementCards)
         {
            _loc4_.visible = false;
         }
         this.populateAllyCards();
         addEventListener(BattleSetupAllyPlacementCard.ALLY_PLACEMENT_CARD_SELECTED,this.onAllyPlacementCardClicked,false,0,true);
      }
      
      private function disposeAllyCards() : void
      {
         var _loc1_:BattleSetupAllyCard = null;
         var _loc2_:BattleSetupAllyPlacementCard = null;
         var _loc3_:BattleSetupAllyCard = null;
         for each(_loc1_ in this.m_allyGridCards)
         {
            _loc1_.dispose();
         }
         this.m_allyGridCards = null;
         for each(_loc2_ in this.m_allyPlacementCards)
         {
            _loc2_.dispose();
         }
         this.m_allyPlacementCards = null;
         removeEventListener(BattleSetupAllyPlacementCard.ALLY_PLACEMENT_CARD_SELECTED,this.onAllyPlacementCardClicked);
         for each(_loc3_ in this.m_allyTweenCards)
         {
            TweenLite.killTweensOf(_loc3_.clip);
            _loc3_.dispose();
         }
         this.m_allyTweenCards = null;
      }
      
      private function createUnitPlacementCards() : void
      {
         var _loc4_:PreBattleUnitCard = null;
         this.m_unitPlacementCards = new Array();
         var _loc1_:Class = this.m_resource.getAssetClass("PlacementUnitCard");
         var _loc2_:int = this.m_preBattle.numUnits;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = null;
            if(TITAN_MODE)
            {
               _loc4_ = new PreBattleMegaUnitCard(this,_loc1_,_loc2_,_loc3_);
            }
            else
            {
               _loc4_ = new PreBattleUnitCard(this,_loc1_,_loc2_,_loc3_);
            }
            this.m_overlay.cardAnchor_mc.addChild(_loc4_.art);
            this.m_unitPlacementCards.push(_loc4_);
            _loc3_++;
         }
      }
      
      private function setupNoUnitsWarning() : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc1_:String = ChallengeBattleTheaterCard.getTheaterTypeUnitLabel(this.m_theater);
         if(_loc1_)
         {
            _loc1_ = ZGameUtils.ZlocT("Dialogs",_loc1_);
            _loc2_ = ZGameUtils.ZlocT("Dialogs","BuyUnits");
            _loc3_ = {
               "theaterType":_loc1_,
               "buyButtonText":_loc2_
            };
            _loc4_ = ZGameUtils.ZlocT("Dialogs","NoTheaterUnitsWarning",_loc3_);
            TextFieldUtil.processTextField(this.m_content.UnitSelect.grid_mc.warning_tf,_loc4_);
            this.m_content.UnitSelect.grid_mc.warning_tf.visible = true;
         }
      }
      
      private function createEnemyTooltipCards() : void
      {
         var _loc2_:Class = null;
         var _loc3_:Class = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:IPreBattleEnemyCard = null;
         var _loc8_:UnitItem = null;
         var _loc9_:Class = null;
         var _loc1_:Fleet = this.m_preBattle.enemyFleet;
         if(_loc1_)
         {
            this.m_enemyTooltipCards = new Array();
            _loc2_ = this.m_resource.getAssetClass("EnemyTooltipCard");
            _loc3_ = this.m_resource.getAssetClass("EnemySupportTooltipCard");
            _loc4_ = int(_loc1_.units.length);
            _loc5_ = this.m_preBattle.fleet.type;
            _loc7_ = null;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc1_.units[_loc6_].code,UnitItem) as UnitItem;
               if(Boolean(_loc8_.secondaryAbility) && !_loc8_.hasType(UnitItem.MEGA_UNIT))
               {
                  _loc7_ = new PreBattleEnemySupportTooltipCard(_loc8_,_loc3_,_loc4_,_loc6_,_loc5_,_loc1_.upgrades[_loc1_.units[_loc6_].code]);
               }
               else
               {
                  _loc7_ = new PreBattleEnemyTooltipCard(_loc8_,_loc2_,_loc4_,_loc6_,_loc5_,_loc1_.upgrades[_loc1_.units[_loc6_].code]);
               }
               this.m_tooltipOverlay.anchor_mc.addChild(_loc7_.art);
               this.m_enemyTooltipCards.push(_loc7_);
               _loc6_++;
            }
            if(!DominationModeManager.instance.isInDefenseForceEditMode())
            {
               if(DominationModeManager.instance.isInDominationBattle())
               {
                  _loc9_ = this.m_resource.getAssetClass("EnemyFogOfWarCard");
                  while(_loc6_ < Fleet.MAX_UNITS)
                  {
                     _loc7_ = new PreBattleEnemyFogOfWarCard(_loc9_,_loc6_);
                     this.m_tooltipOverlay.anchor_mc.addChild(_loc7_.art);
                     this.m_enemyTooltipCards.push(_loc7_);
                     _loc6_++;
                  }
               }
            }
         }
      }
      
      private function activateFirstVacantCard() : void
      {
         var _loc2_:PreBattleUnitCard = null;
         this.m_activePlacement = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_unitPlacementCards.length)
         {
            _loc2_ = this.m_unitPlacementCards[_loc1_];
            if(_loc2_.unitItem == null)
            {
               this.m_activePlacement = _loc2_;
               break;
            }
            _loc1_++;
         }
         if(this.m_activePlacement)
         {
            this.m_activePlacement.setActive();
         }
      }
      
      private function numOccupiedCards() : int
      {
         var _loc2_:PreBattleUnitCard = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_unitPlacementCards)
         {
            if(_loc2_.unitItem != null)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function setUnitsPanelCardsVisible(param1:Boolean) : void
      {
         var _loc2_:PreBattleUnitCard = null;
         var _loc3_:IPreBattleEnemyCard = null;
         for each(_loc2_ in this.m_unitPlacementCards)
         {
            _loc2_.visible = param1;
         }
         for each(_loc3_ in this.m_enemyTooltipCards)
         {
            _loc3_.visible = param1;
         }
      }
      
      private function onCombatAllyOverlayReposition(param1:RepositionEvent) : void
      {
         this.m_allyoverlay.x = param1.x;
         this.m_allyoverlay.y = param1.y - param1.height - this.m_allyoverlay.height;
      }
      
      private function onFullscreenEvent(param1:FullScreenEvent) : void
      {
         this.positionScreen();
      }
      
      private function positionScreen() : void
      {
         var _loc1_:Number = 1;
         if(Zlab.mainStage.stageHeight < Zlab.mainStage.stageWidth && HEIGHT < Zlab.mainStage.stageHeight)
         {
            _loc1_ = Zlab.mainStage.stageHeight / HEIGHT;
         }
         var _loc2_:Number = (Zlab.mainStage.stageWidth - this.m_content.bounds_mc.width) * 0.5;
         var _loc3_:Number = Zlab.mainStage.stageHeight - this.m_content.bounds_mc.height;
         this.m_content.x = _loc2_ >= 0 ? _loc2_ : 0;
         this.m_content.y = _loc3_ >= 0 ? _loc3_ : 0;
         this.m_tooltipOverlay.scaleX = this.m_tooltipOverlay.scaleY = this.m_overlay.scaleX = this.m_overlay.scaleY = _loc1_;
         this.m_tooltipOverlay.x = (Zlab.mainStage.stageWidth - WIDTH * _loc1_) * 0.5;
         this.m_tooltipOverlay.y = (Zlab.mainStage.stageHeight - HEIGHT * _loc1_) * 0.5;
         if(_loc2_ >= 0)
         {
            if(this.m_tooltipOverlay.x > _loc2_)
            {
               this.m_overlay.x = this.m_tooltipOverlay.x = _loc2_;
            }
            else
            {
               this.m_overlay.x = this.m_tooltipOverlay.x > 0 ? this.m_tooltipOverlay.x : _loc2_;
            }
         }
         else
         {
            this.m_overlay.x = this.m_tooltipOverlay.x = 0;
         }
         this.m_overlay.y = this.m_tooltipOverlay.y >= 0 && this.m_tooltipOverlay.y <= _loc3_ ? this.m_tooltipOverlay.y : 0;
         this.repositionDominanceEnemyPortrait();
         this.m_content.bounds_mc.visible = false;
      }
      
      private function repositionDominanceEnemyPortrait() : void
      {
         var _loc1_:int = Zlab.mainStage.stageWidth - DOM_ENEMY_X_INSET + this.m_UIWidthOffset;
         var _loc2_:int = DOM_ENEMY_Y_INSET + this.m_UIHeightOffset;
         var _loc3_:Point = new Point(_loc1_,_loc2_);
         var _loc4_:Point = Zlab.mainStage.localToGlobal(_loc3_);
         var _loc5_:Point = this.m_content.globalToLocal(_loc4_);
         this.m_content.opponentIcon_mc.x = _loc5_.x;
         this.m_content.opponentIcon_mc.y = _loc5_.y;
      }
      
      private function activateTerrainPanel() : void
      {
         this.setUnitsPanelCardsVisible(false);
         this.m_currentPanel = PANEL_TERRAIN;
      }
      
      private function cueTweenInward() : void
      {
         this.m_isTweening = true;
         this.m_currentTweenIndex = 0;
         this.tweenInward();
      }
      
      private function activateAlliesPanel(param1:Boolean = false) : void
      {
         if(!this.m_alliesGrid)
         {
            this.m_alliesGrid = new BattleSetupAllyGrid(this.m_content.AllySelect.grid_mc,this.m_resource,this,null,this.numAlliesAllowedForCurrentMap,this.m_preBattle,this.m_forcedAllies);
            if(ReviveAlliesManager.isEnabled() && this.meetsCriteriaReviveAllies() && ReviveAlliesManager.numNonMercAlliesAvailable(this.m_alliesGrid.players,this.m_forcedAllies) < this.numAlliesAllowedForCurrentMap)
            {
               this.activateReviveAllies();
            }
         }
         this.m_alliesGrid.startListening();
         if(this.numAlliesAllowedForCurrentMap > 0)
         {
            if(param1)
            {
               Zlab.processManager.schedule(ALLY_CARD_INITIAL_TWEEN_DELAY,this,this.cueTweenInward);
            }
            else
            {
               this.cueTweenInward();
            }
         }
         this.setUnitsPanelCardsVisible(false);
         this.m_currentPanel = PANEL_ALLIES;
      }
      
      private function activateAllianceAlliesPanel(param1:Boolean = false) : void
      {
         if(!this.m_alliesGrid)
         {
            this.m_alliesGrid = new BattleSetupAllyGrid(this.m_content.allianceAlly.grid_mc,this.m_resource,this,null,this.numAlliesAllowedForCurrentMap,this.m_preBattle,this.m_forcedAllies);
         }
         this.m_alliesGrid.startListening();
         if(this.numAlliesAllowedForCurrentMap > 0)
         {
            if(param1)
            {
               Zlab.processManager.schedule(ALLY_CARD_INITIAL_TWEEN_DELAY,this,this.cueTweenInward);
            }
            else
            {
               this.cueTweenInward();
            }
         }
         this.setUnitsPanelCardsVisible(false);
         this.m_currentPanel = PANEL_ALLIES;
      }
      
      private function deactivateAllianceAlliesPanel() : void
      {
         if(this.numAlliesAllowedForCurrentMap > 0)
         {
            this.m_currentTweenIndex = 0;
            this.tweenOutward();
         }
         if(this.m_alliesGrid)
         {
            this.m_alliesGrid.stopListening();
         }
      }
      
      private function deactivateAlliesPanel() : void
      {
         if(this.numAlliesAllowedForCurrentMap > 0)
         {
            this.m_currentTweenIndex = 0;
            this.tweenOutward();
         }
         if(this.m_alliesGrid)
         {
            this.m_alliesGrid.stopListening();
         }
         if(this.m_reviveButton)
         {
            this.deactivateReviveAllies();
         }
      }
      
      private function disableAlliesPanel() : void
      {
         if(this.m_alliesGrid)
         {
            this.m_alliesGrid.stopListening();
            this.m_alliesGrid = null;
         }
      }
      
      private function activateUnitsPanel() : void
      {
         this.updateUIState();
         if(!this.m_unitsGrid)
         {
            this.m_unitsGrid = new StackedUnitsGrid(this.m_content.UnitSelect.grid_mc,this.m_resource,this,"Buildable",this.m_preBattle.fleet.type,null,1,null,this.getPVPOpponentLevelLimit());
         }
         this.m_unitsGrid.startListening();
         addEventListener(StackedUnitsGrid.UNIT_CARD_ADDED,this.onUnitGridCardAdded,false,0,true);
         if(DominationModeManager.instance.isInDominationBattle() && !AlliancesManager.instance.allianceBattle)
         {
            this.defaultFleetSetup();
            this.m_unitsGrid.updateCards();
         }
         else if(DominationModeManager.instance.isInDefenseForceEditMode())
         {
            this.defenseForceEditorSetup();
            this.m_unitsGrid.updateCards();
         }
         if(!this.m_unitsGrid.numCards && !this.m_unitsGrid.numUnitsLength)
         {
            this.setupNoUnitsWarning();
         }
         this.updateUnitSuggester();
         this.updateTotalStrength();
         this.setUnitsPanelCardsVisible(true);
         this.m_currentPanel = PANEL_UNITS;
      }
      
      private function updateUnitSuggester() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Unit = null;
         var _loc2_:UnitItem = null;
         this.m_prioritizeSupportUnits = false;
         if(ExperimentsManager.instance.getExperimentVariant(ZGlobal.EXPERIMENT_SUPPORT_UNITS) >= ZGlobal.EXPERIMENT_SUPPORT_UNITS_ACTIVE)
         {
            _loc3_ = ZGlobal.gameSettings.getInt("manaStartingLevel");
            if(ZGlobal.player.level >= _loc3_)
            {
               _loc4_ = ZGlobal.gameSettings.getInt("combatSetupSuggesterViews",5);
               if(ZGlobal.player.getSeenFlag(SEEN_UNIT_SUGGESTER_FLAG_NAME) < _loc4_)
               {
                  for each(_loc1_ in this.m_preBattle.enemyFleet.units)
                  {
                     _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,UnitItem) as UnitItem;
                     if(_loc2_.secondaryAbility)
                     {
                        this.m_prioritizeSupportUnits = true;
                        this.m_unitSuggester = new UnitSuggester(this.m_content.unitSuggester_mc,"Combat_SecondaryHint");
                        break;
                     }
                  }
               }
            }
         }
         if(!this.m_unitSuggester && SurvivalModeManager.instance.isInSurvivalBattle())
         {
            this.m_unitSuggester = new UnitSuggester(this.m_content.unitSuggester_mc,"Combat_SurvivalHint");
         }
         if(!this.m_unitSuggester)
         {
            for each(_loc1_ in this.m_preBattle.enemyFleet.units)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,UnitItem) as UnitItem;
               if(_loc2_.hasType(UnitItem.MEGA_UNIT))
               {
                  this.m_unitSuggester = new UnitSuggester(this.m_content.unitSuggester_mc,"Combat_MegaUnitHint");
                  break;
               }
            }
         }
         if(this.m_unitSuggester)
         {
            this.m_unitSuggester.addEventListener(UnitSuggester.BUY_UNITS,this.onBuyUnitsFromSuggester);
            this.m_unitSuggester.addEventListener(UnitSuggester.EXIT,this.onExitSuggester);
         }
      }
      
      private function getPVPOpponentLevelLimit() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            _loc2_ = ZGlobal.player.neighbors[ChallengeModeManager.instance.currentChallengerID()];
            if(_loc2_ != null)
            {
               _loc1_ = int(_loc2_.level) + ZGlobal.gameSettings.getInt("challengeLevelPlusMinusRange",0);
            }
         }
         return _loc1_;
      }
      
      private function deactivateUnitsPanel() : void
      {
         this.m_unitsGrid.stopListening();
         removeEventListener(StackedUnitsGrid.UNIT_CARD_ADDED,this.onUnitGridCardAdded);
         this.m_content.UnitSelect.grid_mc.warning_tf.visible = false;
         this.disposeUnitSuggester();
      }
      
      private function onUnitGridCardAdded(param1:Event) : void
      {
         this.m_content.UnitSelect.grid_mc.warning_tf.visible = false;
      }
      
      private function disposeUnitSuggester() : void
      {
         if(this.m_unitSuggester)
         {
            this.m_unitSuggester.removeEventListener(UnitSuggester.BUY_UNITS,this.onBuyUnitsFromSuggester);
            this.m_unitSuggester.removeEventListener(UnitSuggester.EXIT,this.onExitSuggester);
            this.m_unitSuggester.dispose();
            this.m_unitSuggester = null;
         }
      }
      
      private function doCardTween(param1:String) : void
      {
         var _loc2_:Boolean = param1 == "out";
         Zlab.processManager.removeScheduledObject(this);
         var _loc3_:BattleSetupAllyCard = BattleSetupAllyCard(_loc2_ ? this.m_allyPlacementCards[this.m_currentTweenIndex] : this.m_allyGridCards[this.m_currentTweenIndex]);
         var _loc4_:BattleSetupAllyCard = BattleSetupAllyCard(_loc2_ ? this.m_allyGridCards[this.m_currentTweenIndex] : this.m_allyPlacementCards[this.m_currentTweenIndex]);
         var _loc5_:Rectangle = _loc3_.sizer.getBounds(this.m_screen);
         var _loc6_:Rectangle = _loc4_.sizer.getBounds(this.m_screen);
         var _loc7_:BattleSetupAllyCard = BattleSetupAllyCard(this.m_allyTweenCards[this.m_currentTweenIndex]);
         _loc7_.visible = true;
         var _loc8_:MovieClip = _loc7_.clip;
         _loc8_.x = _loc5_.x;
         _loc8_.y = _loc5_.y;
         _loc8_.scaleX = _loc5_.width / _loc8_.sizer_mc.width;
         _loc8_.scaleY = _loc5_.height / _loc8_.sizer_mc.height;
         _loc3_.visible = false;
         _loc4_.visible = false;
         TweenLite.killTweensOf(_loc8_);
         TweenLite.to(_loc8_,ALLY_CARD_TWEEN_TIME,{
            "x":_loc6_.x,
            "y":_loc6_.y,
            "scaleX":_loc6_.width / _loc8_.sizer_mc.width,
            "scaleY":_loc6_.height / _loc8_.sizer_mc.height,
            "ease":Quad.easeInOut,
            "onComplete":(_loc2_ ? this.onOutwardTweenComplete : this.onInwardTweenComplete),
            "onCompleteParams":[this.m_currentTweenIndex]
         });
         if(++this.m_currentTweenIndex < this.numAlliesAllowedForCurrentMap)
         {
            Zlab.processManager.schedule(ALLY_CARD_TWEEN_INTERVAL,this,_loc2_ ? this.tweenOutward : this.tweenInward);
         }
      }
      
      private function tweenOutward() : void
      {
         this.doCardTween("out");
      }
      
      private function tweenInward() : void
      {
         this.doCardTween("in");
      }
      
      private function onOutwardTweenComplete(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         BattleSetupAllyCard(this.m_allyTweenCards[param1]).visible = false;
         if(AlliancesManager.instance.allianceBattle)
         {
            _loc2_ = param1 < this.numAlliesSelectedForCurrentMap;
         }
         else
         {
            _loc2_ = true;
         }
         BattleSetupAllyCard(this.m_allyGridCards[param1]).visible = _loc2_;
         if(this.m_currentTweenIndex >= this.numAlliesAllowedForCurrentMap)
         {
            this.m_isTweening = false;
         }
      }
      
      private function onInwardTweenComplete(param1:Number) : void
      {
         BattleSetupAllyCard(this.m_allyTweenCards[param1]).visible = false;
         BattleSetupAllyCard(this.m_allyPlacementCards[param1]).visible = true;
         if(this.m_currentTweenIndex >= this.numAlliesAllowedForCurrentMap)
         {
            if(param1 == this.numAlliesAllowedForCurrentMap - 1 && TutorialManager.instance.active)
            {
               TutorialManager.instance.dispatchEvent(new Event(TutorialManager.COMBAT_ALLIES_SCREEN));
            }
            this.m_isTweening = false;
         }
      }
      
      private function onDisablePreBattleUIControls(param1:WorldEvent = null) : void
      {
         if(!this.m_initialized)
         {
            this.m_disableOnLoad = true;
         }
         else
         {
            ZGameUtils.disableButton(this.m_content.terrainSelect.cancel_bt,this.onCancel);
            ZGameUtils.disableButton(this.m_content.terrainSelect.dominanceCancel_bt,this.onCancel);
            ZGameUtils.disableButton(this.m_content.AllySelect.cancel_bt,this.onCancel);
            ZGameUtils.disableButton(this.m_content.allianceAlly.cancel_bt,this.onCancel);
            ZGameUtils.disableButton(this.m_content.UnitSelect.cancel_bt,this.onCancel);
            ZGameUtils.disableButton(this.m_content.UnitSelect.dominanceCancel_bt,this.onCancel);
            ZGameUtils.disableButton(this.m_content.UnitSelect.buy_bt,this.onBuyUnits);
            ZGameUtils.disableButton(this.m_content.UnitSelect.back_bt,this.onGotoAlliesPanel);
            this.m_backButton.disable();
            this.m_buyButton.disable();
         }
      }
      
      private function onEnablePreBattleUIControls(param1:WorldEvent = null) : void
      {
         if(!this.m_initialized)
         {
            this.m_disableOnLoad = false;
         }
         else
         {
            ZGameUtils.enableButton(this.m_content.terrainSelect.cancel_bt,this.onCancel);
            ZGameUtils.enableButton(this.m_content.terrainSelect.dominanceCancel_bt,this.onCancel);
            ZGameUtils.enableButton(this.m_content.AllySelect.cancel_bt,this.onCancel);
            ZGameUtils.enableButton(this.m_content.allianceAlly.cancel_bt,this.onCancel);
            ZGameUtils.enableButton(this.m_content.UnitSelect.cancel_bt,this.onCancel);
            ZGameUtils.enableButton(this.m_content.UnitSelect.dominanceCancel_bt,this.onCancel);
            ZGameUtils.enableButton(this.m_content.UnitSelect.buy_bt,this.onBuyUnits);
            ZGameUtils.enableButton(this.m_content.UnitSelect.back_bt,this.onGotoAlliesPanel);
            this.m_backButton.enable();
            this.m_buyButton.enable();
         }
      }
      
      private function onLimitAllySelection(param1:WorldEvent) : void
      {
         this.m_disableAllyRemoveButton = true;
      }
      
      private function onTitanMode(param1:WorldEvent) : void
      {
         TITAN_MODE = !TITAN_MODE;
         this.cancelActiveCards();
         this.reCreateUnitPlacementCards();
         this.activateFirstVacantCard();
         this.m_titanUI.reset();
         this.m_unitsGrid.updateCards();
         this.m_content.UnitSelect.titanFightFrame_mc.visible = TITAN_MODE;
         this.m_content.UnitSelect.innerFrame_mc.visible = !TITAN_MODE;
         if(TITAN_MODE)
         {
            this.m_mechSetup = new MechBattleSetup(this.m_content.UnitSelect.titanFightAnchor,this.onLocationCancel,this.m_titanUI,this.m_unitPlacementCards.length);
            this.setUnitSelectTitle("CombatSetupTitanSelectTitle");
            this.m_backButton.show();
         }
         else
         {
            this.disposeMechSetup();
            this.setUnitSelectTitle("CombatSetupUnitSelectTitle");
            if(!this.numAlliesAllowedForCurrentMap)
            {
               this.m_backButton.hide();
            }
         }
      }
      
      private function setUnitSelectTitle(param1:String) : void
      {
         TextFieldUtil.processTextField(this.m_content.UnitSelect.title_tf,ZGameUtils.ZlocT("Dialogs",param1));
      }
      
      private function disposeMechSetup() : void
      {
         if(this.m_mechSetup)
         {
            this.m_mechSetup.dispose();
            this.m_mechSetup = null;
         }
      }
      
      private function activateReviveAllies() : void
      {
         ReviveAlliesManager.instance.initReviveAllies();
         ReviveAlliesManager.instance.addEventListener(ReviveAlliesManager.REVIVE_COUNT_UPDATED,this.updateReviveAllyButton);
         var _loc1_:int = ReviveAlliesManager.instance.reviveCount();
         this.m_reviveButton = new ZGameButton(this.m_content.AllySelect.revive_bt,this.onReviveAllyClicked);
         if(_loc1_ > 0)
         {
            this.m_reviveButton.compactText(ZGameUtils.ZlocT("Dialogs","ReviveAllyCountButton",{
               "num":_loc1_,
               "ally":ZGameUtils.ZlocTk("Objects","ally","",_loc1_),
               "amount":_loc1_ * ReviveAlliesManager.instance.reviveCostPerAlly()
            }),null);
            this.enableReviveAllyButton();
         }
         else
         {
            this.disableReviveAllyButton();
         }
      }
      
      private function deactivateReviveAllies() : void
      {
         ReviveAlliesManager.instance.removeEventListener(ReviveAlliesManager.REVIVE_COUNT_UPDATED,this.updateReviveAllyButton);
         ReviveAlliesManager.instance.deinitReviveAllies();
         this.disableReviveAllyButton();
         if(this.m_reviveButton)
         {
            this.m_reviveButton.dispose();
         }
         this.m_reviveButton = null;
      }
      
      private function updateReviveAllyButton(param1:Event = null, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         if(!this.m_reviveButton)
         {
            return;
         }
         if(Boolean(this.m_alliesGrid) && Boolean(this.meetsCriteriaReviveAllies()) && ReviveAlliesManager.numNonMercAlliesAvailable(this.m_alliesGrid.players,this.m_forcedAllies) < this.numAlliesAllowedForCurrentMap)
         {
            _loc3_ = ReviveAlliesManager.instance.reviveCount();
            if(!this.m_reviveButtonEnabled && param2 && _loc3_ > 0)
            {
               this.enableReviveAllyButton();
            }
            if(this.m_reviveButtonEnabled && _loc3_ > 0)
            {
               this.m_reviveButton.compactText(ZGameUtils.ZlocT("Dialogs","ReviveAllyCountButton",{
                  "num":_loc3_,
                  "ally":ZGameUtils.ZlocTk("Objects","ally","",_loc3_),
                  "amount":_loc3_ * ReviveAlliesManager.instance.reviveCostPerAlly()
               }),null);
               return;
            }
         }
         this.disableReviveAllyButton();
      }
      
      private function disableReviveAllyButton() : void
      {
         if(this.m_reviveButton)
         {
            this.m_reviveButton.hide();
            this.m_reviveButton.disable();
            this.m_reviveButtonEnabled = false;
            if(this.m_nextButton)
            {
               this.m_nextButton.show();
            }
         }
      }
      
      private function enableReviveAllyButton() : void
      {
         if(this.m_reviveButton)
         {
            if(this.m_nextButton)
            {
               this.m_nextButton.hide();
               this.m_nextButton.disable();
            }
            this.m_reviveButton.show();
            this.m_reviveButton.enable();
            this.m_reviveButtonEnabled = true;
         }
      }
      
      private function meetsCriteriaReviveAllies() : Boolean
      {
         var _loc1_:Boolean = Boolean(this.m_forcedAllies) && this.m_forcedAllies.length > 0;
         var _loc2_:Boolean = ZGameStats.currentBattle is BattleCampaign;
         return _loc2_ && !_loc1_;
      }
   }
}

