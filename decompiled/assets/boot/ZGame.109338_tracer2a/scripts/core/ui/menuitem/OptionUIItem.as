package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import ZQuest.Managers.QuestManager;
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.GMMultiHarvest;
   import core.gamemode.GMObjectEditMove;
   import core.gamemode.GMSell;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.managers.BountyCenterManager;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.managers.campaignManager.CampaignManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.MovieClipButton;
   import core.ui.Tooltip;
   import core.ui.UI;
   import core.ui.UIManager;
   import core.ui.menuitem.battleListMenu.BattleListMenuGrid;
   import core.ui.menuitem.battleListMenu.BattleListMenuGridSlot;
   import core.ui.menuitem.campaignMapMenu.CampaignMapMenuGrid;
   import core.ui.menuitem.campaignMapMenu.CampaignMapMenuGridSlot;
   import core.ui.menuitem.campaignMapMenu.CampaignMapMenuInfo;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.CampaignMasteryHelpPopup;
   import displays.screens.globalpvp.GlobalPVPInfoPopup;
   import displays.screens.leaderboard.LeaderboardScreen;
   import events.ExperienceUpdatedEvent;
   import events.RepositionEvent;
   import fl.containers.UILoader;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import transactions.TInitUser;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.OptionMenu.EditPanel;
   import zgame.assets.ui.OptionMenu.EditPanelMH;
   import zgame.assets.ui.OptionMenu.OptionMenu;
   import zgame.assets.ui.OptionMenu.OptionMenu2;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class OptionUIItem extends MenuItem
   {
      
      public static const BATTLETYPE_DOMINATION:uint = 0;
      
      public static const BATTLETYPE_BBLITZ:uint = 1;
      
      public static const BATTLETYPE_DEATHMATCH:uint = 2;
      
      private static const X_OFFSET:Number = -15;
      
      private static const Y_OFFSET:Number = 0;
      
      private static const WIDTH:Number = 170;
      
      private static const CAMPV2_UI:Boolean = true;
      
      public static const ITEM_ID:String = "actionMenu";
      
      public static const EXIT:String = "uiExit";
      
      public static const EXIT_TOOLTIP:String = "uiExitTooltip";
      
      public static const EXIT_TYPE_EVENT:String = "uiExitTypeEvent";
      
      public static const EXIT_TYPE_MODE:String = "uiExitTypeGame";
      
      public static const SELECTED_OBJECT_HELPED:String = "selectedObjectHelped";
      
      public static const WORLD_LOADED:String = "worldLoaded";
      
      public static const GLOBAL_PVP_UIITEM:String = "GlobalPVP";
      
      public static const DOMINATION_UIITEM:String = "Domination";
      
      protected static var STRANGERBAR_TOGGLE_ANIM_LENGTH_MSECS:Number = 400;
      
      protected static var STRANGERBAR_TOGGLE_BUTTON_ANIM_IDLEFRAME:int = 1;
      
      protected static var STRANGERBAR_TOGGLE_BUTTON_ANIM_STARTFRAME:String = "_show";
      
      protected static var STRANGERBAR_TOGGLE_BUTTON_ANIM_ENDFRAME:int = 9;
      
      protected static var STRANGERBAR_TOGGLE_BUTTON_ANIM_DONEFRAME:int = 39;
      
      private static var NAVIGATION_SAMPLE_RATE:int = 1000;
      
      private var m_displayObject:MovieClip;
      
      private var m_editBar:MovieClip;
      
      private var m_inEditMode:Boolean = false;
      
      private var m_editBarTweening:Boolean = false;
      
      private var m_contextualBarTweening:Boolean = false;
      
      private var m_challengeModeActive:Boolean = false;
      
      private var m_strategicModeActive:Boolean = false;
      
      private var m_fullScreen:Boolean = false;
      
      private var m_tutorialDisabledStrat:Boolean = false;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_UIOffset:Point = new Point(0,0);
      
      private var m_homePosition:Point = null;
      
      private var m_masteryHelpPosition:Point = null;
      
      private var m_leaderboardButton:MovieClipButton = null;
      
      private var m_leaderboardHUDEnabled:Boolean = true;
      
      private var m_campaignMapMenuActive:Boolean = false;
      
      private var m_campaignMapMenuGrid:CampaignMapMenuGrid = null;
      
      private var m_strategicMapButtonIcon:ImageLoader = null;
      
      private var m_chooserBtn:MovieClipButton = null;
      
      private var m_chooserCloseBtn:MovieClipButton = null;
      
      private var m_stratBtn:MovieClipButton = null;
      
      private var m_battleChooserBtn:MovieClipButton = null;
      
      private var m_battleChooserCloseBtn:MovieClipButton = null;
      
      private var m_battleListMenuGrid:BattleListMenuGrid;
      
      private var m_battleButtonMode:uint = 1;
      
      private var m_dominationModeButtonIcon:ImageLoader;
      
      private var m_dominationButtonModified:Boolean = false;
      
      private var m_campaignMenuModified:Boolean = false;
      
      private var m_survivalModeButton:MovieClipButton;
      
      private var m_survivalModeIconLoader:ImageLoader;
      
      public function OptionUIItem(param1:String = "actionMenu")
      {
         super(param1);
         this.m_displayObject = CAMPV2_UI ? new OptionMenu2() : new OptionMenu();
         addChild(this.m_displayObject);
         this.m_displayObject.inventory_bt.addEventListener(MouseEvent.CLICK,this.onDisplayInventory,false,0,true);
         this.m_displayObject.store_bt.addEventListener(MouseEvent.CLICK,this.onDisplayStore,false,0,true);
         this.m_displayObject.edit_bt.addEventListener(MouseEvent.CLICK,this.onDisplayEditMenu,false,0,true);
         this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.addEventListener(MouseEvent.CLICK,this.onGoHome,false,0,true);
         this.m_displayObject.masteryHelp_bt.addEventListener(MouseEvent.CLICK,this.onMasteryHelp,false,0,true);
         this.m_homePosition = new Point(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.x,this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.y);
         this.m_masteryHelpPosition = new Point(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.x - 75,this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.y + 25);
         this.updateDisplay();
         Tooltip.subscribe(this.m_displayObject.inventory_bt,ZGameUtils.ZlocT("Main","Inventory_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.store_bt,ZGameUtils.ZlocT("Main","Store_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.edit_bt,ZGameUtils.ZlocT("Main","Edit_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt,ZGameUtils.ZlocT("Main","ReturnHome_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.masteryHelp_bt,ZGameUtils.ZlocT("Main","MasteryHelp_Tooltip"));
         Tooltip.subscribe(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,ZGameUtils.ZlocT("Main","Strategic_ToolTip"));
         this.onExitTooltip(null);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_displayObject.inventory_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.store_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.edit_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.masteryHelp_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.exit_bt,ButtonSound.DEFAULT);
         this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.addEventListener(MouseEvent.CLICK,this.onToggleStrategicMap,false,0,true);
         UIDispatcher.instance.addEventListener(TInitUser.EVENT_COMPLETE,this.onInitUserComplete,false,0,true);
         this.m_displayObject.badge_mc.visible = false;
         this.m_displayObject.leaderboard_mc.visible = false;
         this.m_displayObject.masteryHelp_bt.visible = false;
         this.initBattleButtonUI();
         this.initSurvivalModeButtonUI();
         this.initGlobalPVPButton();
         this.updateBattleListButton(BATTLETYPE_DOMINATION);
         if(CAMPV2_UI)
         {
            this.initCampaignMapUI();
            this.configureCampaignBountyIcon();
            this.configurePVPBountyIcon();
            BountyCenterManager.instance.addEventListener(BountyCenterManager.EVENT_STATE_CHANGE,this.configureCampaignBountyIcon,false,0,true);
            BountyCenterManager.instance.addEventListener(BountyCenterManager.EVENT_STATE_CHANGE,this.configurePVPBountyIcon,false,0,true);
         }
         this.m_displayObject.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitMode,false,0,true);
         this.m_displayObject.battleButtons_mc.battle03_bt.exclamation_mc.mouseEnabled = false;
         this.m_displayObject.battleButtons_mc.battle03_bt.exclamation_mc.mouseChildren = false;
         TutorialManager.instance.addToUIElements(this.m_displayObject.inventory_bt);
         TutorialManager.instance.addToUIElements(this.m_displayObject.store_bt);
         TutorialManager.instance.addToUIElements(this.m_displayObject.edit_bt);
         TutorialManager.instance.addToUIElements(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt);
         TutorialManager.instance.addToUIElements(this.m_displayObject.exit_bt);
         TutorialManager.instance.addToUIElements(this.m_displayObject.customize_1);
         TutorialManager.instance.addToUIElements(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt);
         TutorialManager.instance.addToUIElements(this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt);
         TutorialManager.instance.addToUIElements(this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt);
         TutorialManager.instance.registerUIItem(this.m_displayObject.store_bt,"Store");
         TutorialManager.instance.registerUIItem(this.m_displayObject.inventory_bt,"Inventory");
         TutorialManager.instance.registerUIItem(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,"StratMap");
         TutorialManager.instance.registerUIItem(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt,"Home");
         TutorialManager.instance.registerUIItem(this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt,GLOBAL_PVP_UIITEM);
         TutorialManager.instance.registerUIItem(this.battleButtonMC.battle01_icon,DOMINATION_UIITEM);
         if(CAMPV2_UI)
         {
            TutorialManager.instance.addToUIElements(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn);
            TutorialManager.instance.addToUIElements(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close);
            TutorialManager.instance.registerUIItem(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,TutorialManager.UI_CAMPAIGN_SELECTOR_OPENER);
         }
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_FRIENDBAR,this.onReposition,false,0,true);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerLevelUpdated);
         UIManager.instance.addEventListener(WORLD_LOADED,this.updateDisplay,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleOrPreBattleGMEntered,false,0,true);
         UIDispatcher.instance.addEventListener(ContextualBarUIItem.TWEEN_START,this.onTweenChanged,false,0,true);
         UIDispatcher.instance.addEventListener(ContextualBarUIItem.TWEEN_END,this.onTweenChanged,false,0,true);
         UIDispatcher.instance.addEventListener(SELECTED_OBJECT_HELPED,this.exitEditMode,false,0,true);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.CAMPAIGN_LOADED,this.onCampaignLoaded);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.TOGGLE,this.onStrategicToggled);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ENTERED,this.onStrategicMapEntered,false,0,true);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.EXITED,this.onStrategicMapExited,false,0,true);
         TutorialManager.instance.addEventListener(TutorialManager.DISABLE_ISLAND_RETURN_HOME,this.onDisableIslandReturnHomeButton,false,0,true);
         TutorialManager.instance.addEventListener(TutorialManager.ENABLE_ISLAND_RETURN_HOME,this.onEnableIslandReturnHomeButton,false,0,true);
         TutorialManager.instance.addEventListener(TutorialManager.DISABLE_STRATEGIC_MAP,this.onDisableStrategicMap,false,0,true);
         TutorialManager.instance.addEventListener(TutorialManager.ENABLE_STRATEGIC_MAP,this.onEnableStrategicMap,false,0,true);
         TutorialManager.instance.addEventListener(TutorialManager.TUTORIAL_PAUSED,this.onTutorialPaused,false,0,true);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_HEIGHT_OFFSET,this.onUIHeightOffset);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         LeaderboardManager.instance.addEventListener(LeaderboardManager.LEADERBOARD_HUD_ENABLED,this.onLeaderboardHUDEnabled);
         PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGlobalPVPUIStateChange,false,0,true);
      }
      
      public static function get instance() : OptionUIItem
      {
         var _loc1_:MenuItem = UIManager.instance.getMenuItemByName(ITEM_ID);
         return _loc1_ as OptionUIItem;
      }
      
      public static function worldLoaded() : void
      {
         UIManager.instance.dispatchEvent(new Event(WORLD_LOADED));
      }
      
      protected function get buttonSounds() : ButtonMouseEventSoundContainer
      {
         return this.m_buttonSounds;
      }
      
      protected function configureCampaignBountyIcon(param1:Event = null) : void
      {
         if(BountyCenterManager.instance.displayLibertyHUDIcons && BountyCenterManager.instance.currentState != BountyCenterManager.STATE_DOESNT_EXIST)
         {
            this.m_displayObject.battleButtons_mc.battle03_bt.bond_mc.visible = true;
            ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BondBlue_36.png"),this.m_displayObject.battleButtons_mc.battle03_bt.bond_mc);
         }
         else
         {
            this.m_displayObject.battleButtons_mc.battle03_bt.bond_mc.visible = false;
         }
      }
      
      protected function configurePVPBountyIcon(param1:Event = null) : void
      {
         if(BountyCenterManager.instance.displayLibertyHUDIcons && BountyCenterManager.instance.currentState == BountyCenterManager.STATE_ACTIVE)
         {
            this.m_displayObject.battleButtons_mc.battle01_bt.bond_mc.visible = true;
            ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BondBlue_36.png"),this.m_displayObject.battleButtons_mc.battle01_bt.bond_mc);
         }
         else
         {
            this.m_displayObject.battleButtons_mc.battle01_bt.bond_mc.visible = false;
         }
      }
      
      protected function get displayObject() : MovieClip
      {
         return this.m_displayObject;
      }
      
      private function onStrategicMapEntered(param1:Event) : void
      {
         this.m_strategicModeActive = true;
         this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.visible = true;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc2_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            if(ZGlobal.player.campaign.isMasteryEnabled)
            {
               this.m_displayObject.masteryHelp_bt.visible = true;
            }
         }
         this.m_displayObject.battleButtons_mc.battle03_bt.exclamation_mc.visible = false;
         this.setLotsOfMiscButtons(false);
         this.closeCampaignMapList();
         this.onExitMode();
      }
      
      public function exitEditMode(param1:Event = null) : void
      {
         this.exitCurrentEditMode();
      }
      
      private function onStrategicMapExited(param1:Event) : void
      {
         this.m_strategicModeActive = false;
         this.m_displayObject.masteryHelp_bt.visible = false;
         this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.visible = false;
         this.setLotsOfMiscButtons(true);
      }
      
      private function onUIHeightOffset(param1:RepositionEvent) : void
      {
         this.m_UIOffset = new Point(param1.x,param1.y);
         this.updateReturnHomeButton();
      }
      
      private function updateReturnHomeButton() : void
      {
         var _loc1_:Point = null;
         if(this.m_UIOffset.x != 0 || this.m_UIOffset.y != 0)
         {
            this.m_UIOffset.x = Zlab.mainStage.stageWidth;
            _loc1_ = this.m_displayObject.globalToLocal(this.m_UIOffset);
            this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.y = this.m_homePosition.y - this.m_UIOffset.y;
            this.m_displayObject.masteryHelp_bt.x = this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.x - 75;
            this.m_displayObject.masteryHelp_bt.y = this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.y + 25;
            this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.visible = false;
            this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.visible = false;
         }
         else
         {
            this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.x = this.m_homePosition.x;
            this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.y = this.m_homePosition.y;
            this.m_displayObject.masteryHelp_bt.x = this.m_masteryHelpPosition.x;
            this.m_displayObject.masteryHelp_bt.y = this.m_masteryHelpPosition.y;
         }
      }
      
      protected function handleGlobalPVPButtons(param1:Boolean) : void
      {
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.visible = param1;
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = param1;
         this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.visible = param1;
         this.battleButtonMC.battleBlitz_bt.btn_flip_green.visible = param1;
         if(param1)
         {
            if(PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_NONE)
            {
               this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.visible = false;
               this.battleButtonMC.battleBlitz_bt.btn_flip_green.visible = false;
            }
            else
            {
               this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.visible = false;
               this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = false;
            }
         }
      }
      
      private function setLotsOfMiscButtons(param1:Boolean) : void
      {
         this.m_displayObject.optionsBtShadow_mc.visible = param1;
         this.m_displayObject.inventory_bt.visible = param1;
         this.m_displayObject.store_bt.visible = param1;
         this.m_displayObject.edit_bt.visible = param1;
         this.m_displayObject.exit_bt.visible = param1;
         this.m_displayObject.leaderboard_mc.visible = param1;
         this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.visible = param1;
         this.battleButtonMC.visible = param1;
         this.m_displayObject.battleButtons_mc.battle02_bt.visible = param1;
         this.m_displayObject.battleButtons_mc.battle03_bt.battleBtBkgd_mc.visible = param1;
         this.battleChooserCloseButton.visible = param1 ? this.isBattleListActive : false;
         this.battleChooserButton.visible = param1 ? !this.isBattleListActive : false;
         if(CAMPV2_UI)
         {
            this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.visible = param1 ? !this.m_campaignMapMenuActive : false;
            this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.visible = param1 ? this.m_campaignMapMenuActive : false;
         }
         this.handleGlobalPVPButtons(param1);
         this.updateLeaderboardButton();
      }
      
      private function set leaderboardButtonEnable(param1:Boolean) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(!this.m_leaderboardButton)
         {
            return;
         }
         if(param1)
         {
            _loc2_ = ZGameUtils.ZlocT("Leaderboards","Leaderboards_Tooltip");
         }
         else
         {
            _loc3_ = ZGlobal.gameSettings.getInt("leaderboardAutoMOTDLevel",4);
            _loc2_ = ZGameUtils.ZlocT("Leaderboards","Leaderboards_Tooltip_Disabled",{"level":_loc3_});
         }
         Tooltip.subscribe(this.m_displayObject.leaderboard_mc,_loc2_);
         this.m_leaderboardButton.enable = param1;
      }
      
      private function onInitUserComplete(param1:WorldEvent) : void
      {
         if(!DominationModeManager.instance.enabled)
         {
            this.updateBattleListButton(BATTLETYPE_BBLITZ);
         }
         if(CAMPV2_UI)
         {
            this.configureCampaignBountyIcon();
            this.configurePVPBountyIcon();
         }
         this.loadStrategicMapButtonIcon();
         this.updateSurvivalModeButton();
         this.updateLeaderboardButton();
         this.updateDominationButton();
         this.updateNewFightsIndicator();
      }
      
      private function updateDominationButton() : void
      {
         this.dominationButtonEnable = DominationModeManager.instance.enabled;
      }
      
      private function loadStrategicMapButtonIcon() : void
      {
         var _loc1_:XML = null;
         if(CAMPV2_UI)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED) == ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED_VARIANT_ENABLED)
            {
               if(this.m_strategicMapButtonIcon)
               {
                  this.m_strategicMapButtonIcon.destroy();
               }
               _loc1_ = CampaignManager.instance.getCampaignDefinition(ZGlobal.player.campaign.currentCampaignName);
               this.m_strategicMapButtonIcon = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc1_.@buttonIcon),this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.iconContainer_mc.icon);
               this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.defaultIcon_mc.visible = false;
            }
         }
      }
      
      private function onExitMode(param1:Event = null) : void
      {
         this.m_inEditMode = false;
         UIDispatcher.instance.dispatchEvent(new Event(EXIT));
      }
      
      private function exitCurrentEditMode() : void
      {
         if(this.m_inEditMode)
         {
            this.onExitMode();
         }
      }
      
      public function onToggleStrategicMap(param1:Event = null) : void
      {
         if(!this.m_contextualBarTweening)
         {
            if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
            {
               this.onClearEditPanel();
               if(this.m_inEditMode)
               {
                  this.onExitMode();
               }
               if(!ZGlobal.player.loaded)
               {
                  return;
               }
               StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.TOGGLE));
               if(TutorialManager.instance.active)
               {
                  TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.STRATEGIC_MAP_CONTINUE));
               }
            }
         }
         if(param1)
         {
            param1.stopImmediatePropagation();
            param1.stopPropagation();
         }
      }
      
      private function initCampaignMapUI() : void
      {
         this.m_chooserBtn = new MovieClipButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn);
         this.m_chooserCloseBtn = new MovieClipButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close);
         this.m_stratBtn = new MovieClipButton(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt);
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.visible = false;
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.buttonMode = true;
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.useHandCursor = true;
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.buttonMode = true;
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.useHandCursor = true;
         this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.buttonMode = true;
         this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.useHandCursor = true;
         Tooltip.subscribe(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,ZGameUtils.ZlocT("Main","CampaignMenu_ToolTip"));
         Tooltip.subscribe(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close,ZGameUtils.ZlocT("Main","CampaignMenu_ToolTip"));
         this.m_buttonSounds.addButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close,ButtonSound.DEFAULT);
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.addEventListener(MouseEvent.CLICK,this.onToggleCampaignMapList,false,0,true);
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.addEventListener(MouseEvent.CLICK,this.onToggleCampaignMapList,false,0,true);
         TextFieldUtil.processTextField(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.title_tf,ZGameUtils.ZlocT("Campaign","CampaignSelectorTitle"));
      }
      
      private function buildCampaignMapMenu() : void
      {
         this.destroyCampaignMapMenu();
         this.m_campaignMapMenuGrid = new CampaignMapMenuGrid(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.menu_mc,new CampaignMapMenuInfo());
         if(this.m_campaignMapMenuGrid.numCards == 3)
         {
            if(!this.m_campaignMenuModified)
            {
               this.m_campaignMenuModified = true;
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.menu_mc.mask_mc.height += 37;
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.menu_mc.y -= 37;
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.title_tf.y -= 37;
            }
         }
      }
      
      private function destroyCampaignMapMenu() : void
      {
         if(this.m_campaignMapMenuGrid)
         {
            this.m_campaignMapMenuGrid.dispose();
         }
         this.m_campaignMapMenuGrid = null;
      }
      
      private function onToggleCampaignMapList(param1:Event) : void
      {
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            this.doToggleCampaignMapList();
         }
      }
      
      private function updateCampaignMapChooserButton() : void
      {
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.visible = !this.m_campaignMapMenuActive;
         this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.visible = this.m_campaignMapMenuActive;
      }
      
      private function doToggleCampaignMapList() : void
      {
         if(this.m_campaignMapMenuActive)
         {
            this.closeCampaignMapList();
         }
         else
         {
            this.openCampaignMapList();
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CAMPAIGN_SELECTOR_OPENED));
         }
      }
      
      private function openCampaignMapList() : void
      {
         if(CAMPV2_UI)
         {
            this.closeBattleList();
            UIDispatcher.instance.addEventListener(CampaignMapMenuGridSlot.CAMPAIGNMAPMENUGRIDSLOT_SELECTED,this.onCampaignMapSelected,false,0,true);
            this.buildCampaignMapMenu();
            this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.visible = true;
            this.m_campaignMapMenuActive = true;
            this.updateCampaignMapChooserButton();
         }
      }
      
      private function closeCampaignMapList() : void
      {
         if(CAMPV2_UI)
         {
            UIDispatcher.instance.removeEventListener(CampaignMapMenuGridSlot.CAMPAIGNMAPMENUGRIDSLOT_SELECTED,this.onCampaignMapSelected);
            this.destroyCampaignMapMenu();
            this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_mc.visible = false;
            this.m_campaignMapMenuActive = false;
            this.updateCampaignMapChooserButton();
         }
      }
      
      private function onCampaignMapSelected(param1:WorldEvent) : void
      {
         var _loc2_:CampaignMapMenuGridSlot = param1.eventData as CampaignMapMenuGridSlot;
         ZGlobal.player.campaign.currentCampaignName = _loc2_.campaignName;
         this.loadStrategicMapButtonIcon();
         this.onToggleStrategicMap();
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CAMPAIGN_MAP_SELECTED));
      }
      
      private function onLeaderboardRewardAvailable(param1:Event) : void
      {
         if(!this.m_displayObject.leaderboard_mc.starburst_mc.visible)
         {
            this.m_displayObject.leaderboard_mc.starburst_mc.gotoAndPlay(1);
            this.m_displayObject.leaderboard_mc.starburst_mc.visible = true;
         }
      }
      
      private function onLeaderboardRewardCollected(param1:Event) : void
      {
         if(this.m_displayObject.leaderboard_mc.starburst_mc.visible)
         {
            this.m_displayObject.leaderboard_mc.starburst_mc.gotoAndStop(1);
            this.m_displayObject.leaderboard_mc.starburst_mc.visible = false;
         }
      }
      
      private function onChallengeClick(param1:MouseEvent) : void
      {
         if(this.m_leaderboardButton.enabled && this.m_challengeModeActive)
         {
            if(ZGlobal.leaderboardsVariant == 2)
            {
               if(this.m_displayObject.leaderboard_mc.mouseEnabled)
               {
                  ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
                     "counter":"friend_bar",
                     "kingdom":"tools",
                     "phylum":"leaderboard"
                  }));
                  WindowManager.instance.push(new LeaderboardScreen());
               }
            }
         }
      }
      
      public function switchView(param1:String) : void
      {
         ViewManager.instance.goToView(param1);
      }
      
      private function onDisplayInventory(param1:Event) : void
      {
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(this.m_inEditMode)
            {
               this.onExitMode();
            }
            UI.instance.displayInventoryDialog();
            if(TutorialManager.instance.active)
            {
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.INVENTORY_OPENED));
            }
         }
      }
      
      private function onHideStrangerBar(param1:MouseEvent) : void
      {
         if(PVPManager.instance.canHideGlobalPVPBar())
         {
            PVPManager.instance.hideGlobalPVPBar();
         }
      }
      
      private function onDisplayStrangerBar(param1:MouseEvent) : void
      {
         var _loc2_:IWindow = null;
         if(!this.strangerBarButtonEnabled)
         {
            return;
         }
         PVPManager.instance.onStrangerBarTogglePressed();
         if(!PVPManager.instance.globalPVPOptedIn)
         {
            _loc2_ = new GlobalPVPInfoPopup(GlobalPVPInfoPopup.MODE_OPTIN);
            PopupManager.instance.push(_loc2_);
         }
         else
         {
            PVPManager.instance.showGlobalPVPBar();
         }
      }
      
      private function onDisplayStore(param1:Event) : void
      {
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(this.m_inEditMode)
            {
               this.onExitMode();
            }
            if(TutorialManager.instance.storeTab)
            {
               UI.instance.displayStoreDialog({
                  "tab":TutorialManager.instance.storeTab,
                  "disableStoreTabs":true
               });
               TutorialManager.instance.storeTab = null;
            }
            else
            {
               UI.instance.displayStoreDialog();
            }
            if(TutorialManager.instance.active)
            {
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.STORE_OPENED));
            }
         }
      }
      
      private function onDisplayEditMenu(param1:Event) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:WorldEvent = null;
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(!this.m_editBar || this.m_editBarTweening)
            {
               if(this.m_editBar)
               {
                  TweenLite.killTweensOf(this.m_editBar);
                  this.onFadeDone();
               }
               if(GMMultiHarvest.multiHarvestEnabled)
               {
                  this.m_editBar = new EditPanelMH();
               }
               else
               {
                  this.m_editBar = new EditPanel();
               }
               SoundEvent.getSoundEvent("EditMenu").play();
               this.m_editBar.move.addEventListener(MouseEvent.CLICK,this.onEnterMode,false,0,true);
               this.m_editBar.sell.addEventListener(MouseEvent.CLICK,this.onEnterMode,false,0,true);
               this.m_editBar.tools.addEventListener(MouseEvent.CLICK,this.onEnterMode,false,0,true);
               this.m_buttonSounds.addButton(this.m_editBar.move,ButtonSound.DEFAULT);
               this.m_buttonSounds.addButton(this.m_editBar.sell,ButtonSound.DEFAULT);
               this.m_buttonSounds.addButton(this.m_editBar.tools,ButtonSound.DEFAULT);
               Tooltip.subscribe(this.m_editBar.move,ZGameUtils.ZlocT("Main","Move_ToolTip"));
               Tooltip.subscribe(this.m_editBar.sell,ZGameUtils.ZlocT("Main","Sell_ToolTip"));
               Tooltip.subscribe(this.m_editBar.tools,ZGameUtils.ZlocT("Main","Tools_ToolTip"));
               TextFieldUtil.processTextField(this.m_editBar.move_tf,ZGameUtils.ZlocT("Main","Move_Caption"));
               TextFieldUtil.processTextField(this.m_editBar.sell_tf,ZGameUtils.ZlocT("Main","Sell_Caption"));
               TextFieldUtil.processTextField(this.m_editBar.tools_tf,ZGameUtils.ZlocT("Main","Tools_Caption"));
               if(GMMultiHarvest.multiHarvestEnabled)
               {
                  this.m_editBar.multiharvest.addEventListener(MouseEvent.CLICK,this.onEnterMode,false,0,true);
                  this.m_buttonSounds.addButton(this.m_editBar.multiharvest,ButtonSound.DEFAULT);
                  Tooltip.subscribe(this.m_editBar.multiharvest,ZGameUtils.ZlocT("Main","MultiHarvest_ToolTip"));
                  TextFieldUtil.processTextField(this.m_editBar.multiharvest_tf,ZGameUtils.ZlocT("Main","MultiHarvest_Caption"));
               }
               _loc2_ = this.m_displayObject.edit_bt;
               this.m_editBar.x = _loc2_.x + _loc2_.width / 2;
               this.m_editBar.y = _loc2_.y - 10;
               this.m_editBar.alpha = 0;
               this.m_editBar.scaleY = 0.25;
               this.m_displayObject.addChild(this.m_editBar);
               TweenLite.to(this.m_editBar,0.25,{
                  "y":0,
                  "alpha":1,
                  "scaleY":1,
                  "ease":Back.easeOut,
                  "onComplete":this.onFadeInDone
               });
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_DOWN,this.onClearEditPanel,false,0,true);
               if(param1)
               {
                  param1.stopImmediatePropagation();
                  param1.stopPropagation();
               }
               UIDispatcher.instance.addEventListener(UIManager.UI_MOUSE_CLICK,this.onClearEditPanel);
               delete this.m_editBar.arrowOnIcon;
               _loc3_ = param1 as WorldEvent;
               if(_loc3_)
               {
                  if(_loc3_.eventData.arrowOnIcon)
                  {
                     this.m_editBar.arrowOnIcon = _loc3_.eventData.arrowOnIcon;
                  }
               }
            }
         }
      }
      
      private function onEnterMode(param1:Event) : void
      {
         this.onClearEditPanel();
         var _loc2_:String = param1.target.name;
         switch(_loc2_)
         {
            case "sell":
               this.exitCurrentEditMode();
               GameModeManager.instance.addGameMode(new GMSell());
               this.m_inEditMode = true;
               break;
            case "move":
               this.exitCurrentEditMode();
               GameModeManager.instance.addGameMode(new GMObjectEditMove());
               this.m_inEditMode = true;
               break;
            case "multiharvest":
               this.exitCurrentEditMode();
               GameModeManager.instance.addGameMode(new GMMultiHarvest());
               this.m_inEditMode = true;
               break;
            case "tools":
               this.exitCurrentEditMode();
               break;
            case "store":
               Logger.info(this,"onEnterMode","No storage mode yet");
         }
      }
      
      private function onClearEditPanel(param1:Event = null) : void
      {
         if(this.m_editBar)
         {
            this.m_editBar.move.removeEventListener(MouseEvent.CLICK,this.onEnterMode);
            this.m_editBar.sell.removeEventListener(MouseEvent.CLICK,this.onEnterMode);
            this.m_editBar.tools.removeEventListener(MouseEvent.CLICK,this.onEnterMode);
            this.m_buttonSounds.removeButton(this.m_editBar.move);
            this.m_buttonSounds.removeButton(this.m_editBar.sell);
            this.m_buttonSounds.removeButton(this.m_editBar.tools);
            if(this.m_editBar.multiharvest)
            {
               this.m_editBar.multiharvest.removeEventListener(MouseEvent.CLICK,this.onEnterMode);
               this.m_buttonSounds.removeButton(this.m_editBar.multiharvest);
            }
            this.removeEditBarArrow();
            Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClearEditPanel);
            UIDispatcher.instance.removeEventListener(UIManager.UI_MOUSE_CLICK,this.onClearEditPanel);
            SoundEvent.getSoundEvent("EditMenu").play();
            this.m_editBarTweening = true;
            TweenLite.to(this.m_editBar,0.25,{
               "alpha":0,
               "onComplete":this.onFadeDone
            });
         }
      }
      
      private function onFadeDone() : void
      {
         if(this.m_editBar)
         {
            this.removeEditBarArrow();
            this.m_editBar.parent.removeChild(this.m_editBar);
            this.m_editBar = null;
            this.m_editBarTweening = false;
         }
      }
      
      private function onFadeInDone() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:Point = null;
         if(Boolean(this.m_editBar) && Boolean(this.m_editBar.arrowOnIcon) && Boolean(this.m_editBar[this.m_editBar.arrowOnIcon]))
         {
            _loc1_ = this.m_editBar[this.m_editBar.arrowOnIcon];
            _loc2_ = new Point(-_loc1_.width,_loc1_.height * 2);
            TutorialManager.instance.addArrowToUIElement(_loc1_,true,false,_loc2_,-90,false);
         }
      }
      
      public function onGoHome(param1:Event) : void
      {
         if(this.m_strategicModeActive)
         {
            this.onToggleStrategicMap(param1);
            if(TutorialManager.instance.active)
            {
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.STRAT_MAP_HOME_CLICK));
            }
            StatsManager.countSample(NAVIGATION_SAMPLE_RATE,"navigation","home","campaign");
         }
         else
         {
            FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).returnToHomeIsland();
            StatsManager.countSample(NAVIGATION_SAMPLE_RATE,"navigation","home","friend");
         }
      }
      
      public function onMasteryHelp(param1:Event) : void
      {
         PopupManager.instance.push(new CampaignMasteryHelpPopup());
      }
      
      public function setMenuLength() : void
      {
         this.displayObject.battleButtons_mc.battle01_bt.mapChooser_mc.menu_mc = 84.3 + 40;
      }
      
      protected function onGlobalPVPUIStateChange(param1:WorldEvent) : void
      {
         if(param1.eventData.oldState == PVPManager.GLOBALPVP_UI_NONE && param1.eventData.newState == PVPManager.GLOBALPVP_UI_FADEIN)
         {
            this.battleButtonMC.battleBlitz_bt.btn_flip_green.visible = false;
            this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = true;
            this.battleButtonMC.battleBlitz_bt.btn_flip_red.gotoAndPlay(STRANGERBAR_TOGGLE_BUTTON_ANIM_STARTFRAME);
            Zlab.processManager.schedule(STRANGERBAR_TOGGLE_ANIM_LENGTH_MSECS,this,this.onStrangerButtonAnimEnd);
         }
         else if(param1.eventData.oldState == PVPManager.GLOBALPVP_UI_ACTIVE)
         {
            this.displayObject.battleButtons_mc.battle01_bt.battleBlitz_bt.btn_flip_red.gotoAndStop(STRANGERBAR_TOGGLE_BUTTON_ANIM_IDLEFRAME);
            if(param1.eventData.newState == PVPManager.GLOBALPVP_UI_FADEOUT)
            {
               this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = false;
               this.battleButtonMC.battleBlitz_bt.btn_flip_green.visible = true;
               this.battleButtonMC.battleBlitz_bt.btn_flip_green.gotoAndPlay(STRANGERBAR_TOGGLE_BUTTON_ANIM_STARTFRAME);
               Zlab.processManager.schedule(STRANGERBAR_TOGGLE_ANIM_LENGTH_MSECS,this,this.onStrangerButtonAnimEnd);
            }
         }
         this.activateButton(this.displayObject.battleButtons_mc.battle01_bt.battleBlitz_bt.globalPvp_stranger_bt,param1.eventData.newState == PVPManager.GLOBALPVP_UI_NONE);
         this.activateButton(this.displayObject.battleButtons_mc.battle01_bt.battleBlitz_bt.globalPvp_home_bt,param1.eventData.newState == PVPManager.GLOBALPVP_UI_ACTIVE);
      }
      
      protected function onStrangerButtonAnimEnd() : void
      {
         if(PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_FADEIN)
         {
            ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).fadeInStrangerBar();
         }
         else if(PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_FADEOUT)
         {
            ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).fadeOutStrangerBar();
         }
      }
      
      override public function removeItem() : void
      {
         this.dominationButtonEnable = false;
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_FRIENDBAR,this.onReposition);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerLevelUpdated);
         UIManager.instance.removeEventListener(WORLD_LOADED,this.updateDisplay);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleOrPreBattleGMEntered);
         UIDispatcher.instance.removeEventListener(ContextualBarUIItem.TWEEN_START,this.onTweenChanged);
         UIDispatcher.instance.removeEventListener(ContextualBarUIItem.TWEEN_END,this.onTweenChanged);
         UIDispatcher.instance.removeEventListener(SELECTED_OBJECT_HELPED,this.exitEditMode);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ENTERED,this.onStrategicMapEntered);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.EXITED,this.onStrategicMapExited);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         PVPManager.instance.removeEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGlobalPVPUIStateChange);
         PVPManager.instance.removeEventListener(PVPManager.GPVP_OPT_INOUT_CHANGED,this.onOptInOutChanged);
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.removeEventListener(MouseEvent.CLICK,this.onDisplayStrangerBar);
         this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.removeEventListener(MouseEvent.CLICK,this.onHideStrangerBar);
         DominationModeManager.instance.removeEventListener(DominationModeManager.NUM_REVENGEFIGHTS_CHANGED,this.onNumRevengeFightsChanged);
         this.battleButtonMC.battle01_icon.removeEventListener(MouseEvent.CLICK,this.onDominationModeClicked);
         this.m_battleChooserBtn.dispose();
         this.m_battleChooserCloseBtn.dispose();
         this.battleChooserButton.removeEventListener(MouseEvent.CLICK,this.onToggleBattleList);
         this.battleChooserCloseButton.removeEventListener(MouseEvent.CLICK,this.onToggleBattleList);
         if(this.m_dominationModeButtonIcon)
         {
            this.m_dominationModeButtonIcon.destroy();
            this.m_dominationModeButtonIcon = null;
         }
         if(this.m_survivalModeButton)
         {
            this.m_survivalModeButton.dispose();
            this.m_survivalModeButton = null;
         }
         this.survivalModeButtonMC.removeListener(MouseEvent.CLICK,this.onSurvivalModeClicked);
         if(this.m_survivalModeIconLoader)
         {
            this.m_survivalModeIconLoader.destroy();
            this.m_survivalModeIconLoader = null;
         }
         this.m_displayObject.leaderboard_mc.removeEventListener(MouseEvent.CLICK,this.onChallengeClick);
         UIDispatcher.instance.removeEventListener(EXIT_TOOLTIP,this.onExitTooltip);
         this.m_displayObject.parent.removeChild(this.m_displayObject);
         this.m_displayObject = null;
      }
      
      private function onDominationModeClicked(param1:MouseEvent) : void
      {
         if(DominationModeManager.instance.enabled)
         {
            DominationModeManager.instance.launchDominationScreen();
         }
      }
      
      public function updateDisplay(param1:Event = null) : void
      {
         var _loc2_:Boolean = false;
         if(ZGlobal.visitMode == ZGlobal.MODE_VISIT)
         {
            this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.visible = true;
            this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.visible = false;
            _loc2_ = true;
            if(CAMPV2_UI && this.m_campaignMapMenuActive)
            {
               this.doToggleCampaignMapList();
            }
         }
         else
         {
            if(ZGlobal.visitMode != ZGlobal.MODE_HOME)
            {
               throw new Error("Unknown Visit Mode: ",ZGlobal.visitMode);
            }
            this.m_displayObject.battleButtons_mc.battle03_bt.home_bt.visible = false;
            this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.visible = true;
         }
         this.activateButton(this.m_displayObject.store_bt,_loc2_ == false);
         this.activateButton(this.m_displayObject.edit_bt,_loc2_ == false);
         this.activateButton(this.m_displayObject.inventory_bt,_loc2_ == false);
         this.activateButton(this.m_displayObject.exit_bt,_loc2_ == false);
         if(CAMPV2_UI)
         {
            this.activateButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,_loc2_ == false);
         }
         this.onClearEditPanel();
         this.updateStrategicButton();
         GameModeManager.instance.setDefaultGameMode();
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.m_fullScreen = param1.fullScreen;
      }
      
      private function onBattleOrPreBattleGMEntered(param1:WorldEvent) : void
      {
         visible = !param1.eventData.entered;
      }
      
      private function onReposition(param1:RepositionEvent) : void
      {
         this.m_displayObject.x = param1.x + param1.width - WIDTH + X_OFFSET;
         this.m_displayObject.y = param1.y + Y_OFFSET;
         this.updateReturnHomeButton();
      }
      
      private function onExitTooltip(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(param1) && Boolean(param1.eventData))
         {
            _loc2_ = String(param1.eventData);
         }
         else
         {
            _loc2_ = "Exit_ToolTip";
         }
         Tooltip.subscribe(this.m_displayObject.exit_bt,ZGameUtils.ZlocT("Main",_loc2_));
      }
      
      private function onPlayerLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.updateChallengeMode();
         this.updateStrangerBarToggleIcon();
         this.updateDominationButton();
      }
      
      public function updateChallengeMode() : void
      {
         if(ZGlobal.leaderboardsVariant == 2)
         {
            this.activateChallengeMode();
         }
         else if(PVPManager.canLevelParticipate(ZGlobal.player.level))
         {
            this.activateChallengeMode();
         }
         else
         {
            this.deactivateChallengeMode();
         }
      }
      
      private function onChallengeMouseOut(param1:MouseEvent) : void
      {
         Tooltip.hide();
      }
      
      protected function activateButton(param1:DisplayObject, param2:Boolean) : void
      {
         if(param2)
         {
            param1.filters = null;
         }
         else
         {
            param1.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
      }
      
      public function activateChallengeMode() : void
      {
         this.m_challengeModeActive = true;
      }
      
      public function deactivateChallengeMode() : void
      {
         this.m_challengeModeActive = false;
      }
      
      public function showAndHighlightOption(param1:String) : void
      {
         var _loc2_:WorldEvent = null;
         if(param1.length)
         {
            _loc2_ = new WorldEvent(MouseEvent.CLICK,{"arrowOnIcon":param1});
            this.onDisplayEditMenu(_loc2_);
         }
      }
      
      public function doFinalizeStrangerBarFadeIn() : void
      {
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.gotoAndStop(STRANGERBAR_TOGGLE_BUTTON_ANIM_IDLEFRAME);
         this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.visible = true;
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.visible = true;
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.gotoAndPlay("_hide");
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.addFrameScript(STRANGERBAR_TOGGLE_BUTTON_ANIM_DONEFRAME,this.onFinalizeStrangerBarFadeIn);
      }
      
      private function onFinalizeStrangerBarFadeIn() : void
      {
         this.battleButtonMC.battleBlitz_bt.btn_flip_green.visible = false;
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.addFrameScript(STRANGERBAR_TOGGLE_BUTTON_ANIM_DONEFRAME,null);
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.GLOBALPVP_UI_STATECHANGEDONE));
      }
      
      public function doFinalizeStrangerBarFadeOut() : void
      {
         this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.visible = false;
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.visible = true;
         this.battleButtonMC.battleBlitz_bt.btn_flip_green.gotoAndPlay("_hide");
         this.battleButtonMC.battleBlitz_bt.btn_flip_green.addFrameScript(STRANGERBAR_TOGGLE_BUTTON_ANIM_DONEFRAME,this.onFinalizeStrangerBarFadeOut);
      }
      
      private function onFinalizeStrangerBarFadeOut() : void
      {
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = false;
         this.battleButtonMC.battleBlitz_bt.btn_flip_green.addFrameScript(STRANGERBAR_TOGGLE_BUTTON_ANIM_DONEFRAME,null);
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.GLOBALPVP_UI_STATECHANGEDONE));
      }
      
      private function onCampaignLoaded(param1:Event) : void
      {
         this.m_displayObject.badge_mc.visible = false;
         this.m_displayObject.leaderboard_mc.visible = true;
         this.m_displayObject.leaderboard_mc.starburst_mc.gotoAndStop(1);
         this.m_displayObject.leaderboard_mc.starburst_mc.visible = false;
         this.m_leaderboardButton = new MovieClipButton(this.m_displayObject.leaderboard_mc);
         this.m_buttonSounds.addButton(this.m_displayObject.leaderboard_mc,ButtonSound.DEFAULT);
         if(ZGlobal.leaderboardsVariant == 2)
         {
            this.m_displayObject.leaderboard_mc.addEventListener(MouseEvent.CLICK,this.onChallengeClick,false,0,true);
            LeaderboardManager.instance.addEventListener(LeaderboardManager.LEADERBOARD_REWARD_AVAILABLE,this.onLeaderboardRewardAvailable);
            LeaderboardManager.instance.addEventListener(LeaderboardManager.LEADERBOARD_REWARD_COLLECTED,this.onLeaderboardRewardCollected);
         }
         else
         {
            this.m_leaderboardButton.enable = false;
            Tooltip.subscribe(this.m_displayObject.leaderboard_mc,ZGameUtils.ZlocT("Leaderboards","Leaderboards_TooltipComingSoon"));
         }
         this.updateStrategicButton();
         this.postInitGlobalPVPButton();
      }
      
      private function onStrategicToggled(param1:Event) : void
      {
         this.updateStrategicButton();
      }
      
      private function updateStrategicButton() : void
      {
         if(this.m_tutorialDisabledStrat)
         {
            this.m_displayObject.battleButtons_mc.battle03_bt.exclamation_mc.visible = false;
            return;
         }
         var _loc1_:Boolean = false;
         if(ZGlobal.player.campaign)
         {
            if(ZGlobal.visitMode == ZGlobal.MODE_HOME && ViewManager.instance.currentViewName == IslandWorld.ID)
            {
               if(ZGlobal.player.campaign.newMapAvailable)
               {
                  _loc1_ = true;
               }
            }
            if(!this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt.mouseEnabled)
            {
               ZGameUtils.enableButton(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,this.onToggleStrategicMap);
            }
         }
         this.m_displayObject.battleButtons_mc.battle03_bt.exclamation_mc.visible = _loc1_;
         if(CAMPV2_UI)
         {
            if(!this.m_strategicModeActive && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED) == ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED_VARIANT_ENABLED)
            {
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.visible = !this.m_campaignMapMenuActive;
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.visible = this.m_campaignMapMenuActive;
            }
            else
            {
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn.visible = false;
               this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn_close.visible = false;
            }
         }
      }
      
      private function onTweenChanged(param1:Event) : void
      {
         this.m_contextualBarTweening = param1.type == ContextualBarUIItem.TWEEN_START;
      }
      
      private function onQuestComplete(param1:WorldEvent) : void
      {
         this.updateStrategicButton();
      }
      
      private function updateLeaderboardButton() : void
      {
         if(ZGlobal.leaderboardsVariant == 2)
         {
            this.leaderboardButtonEnable = this.m_leaderboardHUDEnabled && Boolean(this.m_displayObject.inventory_bt.visible);
         }
      }
      
      private function onLeaderboardHUDEnabled(param1:WorldEvent) : void
      {
         this.m_leaderboardHUDEnabled = param1.eventData;
         this.updateLeaderboardButton();
      }
      
      private function onDisableIslandReturnHomeButton(param1:WorldEvent) : void
      {
         ZGameUtils.disableButton(this.m_displayObject.masteryHelp_bt,this.onMasteryHelp);
         ZGameUtils.disableButton(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt,this.onGoHome);
      }
      
      private function onEnableIslandReturnHomeButton(param1:WorldEvent) : void
      {
         ZGameUtils.enableButton(this.m_displayObject.masteryHelp_bt,this.onMasteryHelp);
         ZGameUtils.enableButton(this.m_displayObject.battleButtons_mc.battle03_bt.home_bt,this.onGoHome);
      }
      
      private function onDisableStrategicMap(param1:WorldEvent) : void
      {
         ZGameUtils.disableButton(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,this.onToggleStrategicMap);
         if(CAMPV2_UI)
         {
            ZGameUtils.disableButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,this.onToggleCampaignMapList);
         }
         this.m_tutorialDisabledStrat = true;
         this.updateStrategicButton();
      }
      
      private function onEnableStrategicMap(param1:WorldEvent) : void
      {
         ZGameUtils.enableButton(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,this.onToggleStrategicMap);
         if(CAMPV2_UI)
         {
            ZGameUtils.enableButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,this.onToggleCampaignMapList);
         }
         this.m_tutorialDisabledStrat = false;
         this.updateStrategicButton();
      }
      
      private function onTutorialPaused(param1:WorldEvent) : void
      {
         if(this.m_tutorialDisabledStrat)
         {
            ZGameUtils.disableButton(this.m_displayObject.battleButtons_mc.battle03_bt.strategicMap_bt,this.onToggleStrategicMap);
            if(CAMPV2_UI)
            {
               ZGameUtils.disableButton(this.m_displayObject.battleButtons_mc.battle03_bt.mapChooser_btn,this.onToggleCampaignMapList);
            }
         }
      }
      
      private function removeEditBarArrow() : void
      {
         if(this.m_editBar.arrowOnIcon)
         {
            TutorialManager.instance.removeArrows();
            delete this.m_editBar.arrowOnIcon;
         }
      }
      
      private function updateStrangerBarToggleIcon() : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc1_:Boolean = this.strangerBarButtonEnabled;
         this.activateButton(this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt,_loc1_);
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.useHandCursor = _loc1_;
         if(_loc1_)
         {
            _loc3_ = PVPManager.instance.globalPVPOptedIn;
            _loc2_ = _loc3_ ? "GlobalPVPStrangerBarButtonNormal" : "GlobalPVPStrangerButtonTooltipNotOptedIn";
            _loc2_ = ZGameUtils.ZlocT("Tooltips",_loc2_);
            this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.addEventListener(MouseEvent.CLICK,this.onDisplayStrangerBar,false,0,true);
            PVPManager.instance.addEventListener(PVPManager.GPVP_OPT_INOUT_CHANGED,this.onOptInOutChanged,false,0,true);
         }
         else
         {
            _loc2_ = ZGameUtils.ZlocT("Tooltips","GlobalPVPStrangerBarButtonDisabled");
            this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.removeEventListener(MouseEvent.CLICK,this.onDisplayStrangerBar);
            PVPManager.instance.removeEventListener(PVPManager.GPVP_OPT_INOUT_CHANGED,this.onOptInOutChanged);
         }
         Tooltip.subscribe(this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt,_loc2_);
      }
      
      protected function postInitGlobalPVPButton() : void
      {
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.visible = true;
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = true;
         this.m_buttonSounds.addButton(this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt,ButtonSound.DEFAULT);
         this.updateStrangerBarToggleIcon();
      }
      
      private function get strangerBarButtonEnabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_globalpvp_master");
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant("empire_globalpvp_strangerbar_enable");
         if(_loc1_ < 2 || _loc2_ < 2)
         {
            return false;
         }
         var _loc3_:int = ZGlobal.player.level;
         var _loc4_:int = ZGlobal.gameSettings.getInt("GlobalPVPMinLevel",8);
         if(_loc3_ < _loc4_)
         {
            return false;
         }
         return true;
      }
      
      private function initGlobalPVPButton() : void
      {
         this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.visible = false;
         this.battleButtonMC.battleBlitz_bt.globalPvp_stranger_bt.visible = false;
         this.battleButtonMC.battleBlitz_bt.btn_flip_green.visible = false;
         this.battleButtonMC.battleBlitz_bt.btn_flip_red.visible = false;
         this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt.addEventListener(MouseEvent.CLICK,this.onHideStrangerBar,false,0,true);
         var _loc1_:String = ZGameUtils.ZlocT("Tooltips","GlobalPVPStrangerBarButtonReturn");
         Tooltip.subscribe(this.battleButtonMC.battleBlitz_bt.globalPvp_home_bt,_loc1_);
      }
      
      private function onOptInOutChanged(param1:Event = null) : void
      {
         this.updateStrangerBarToggleIcon();
      }
      
      private function initSurvivalModeButtonUI() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("SurvivalModeButtonIcon");
         var _loc2_:String = ZGlobal.getAssetURL(_loc1_);
         this.m_survivalModeIconLoader = ImageLoaderFactory.CreateImageLoader(_loc2_,this.survivalModeButtonMC.battle01_icon);
         if(this.m_survivalModeIconLoader)
         {
            this.m_survivalModeIconLoader.smooth = true;
         }
         this.survivalModeButtonMC.battle01_icon.mouseEnabled = false;
         TextFieldUtil.processTextField(this.survivalModeButtonMC.label_tf,ZGameUtils.ZlocT("Dialogs","NewCaps"));
         this.m_survivalModeButton = new MovieClipButton(this.survivalModeButtonMC);
         this.survivalModeButtonMC.addEventListener(MouseEvent.CLICK,this.onSurvivalModeClicked);
         this.m_buttonSounds.addButton(this.survivalModeButtonMC,ButtonSound.DEFAULT);
      }
      
      public function updateSurvivalModeButtonUI(param1:String) : void
      {
         var _loc2_:String = ZGlobal.gameSettings.getString("SurvivalModeButtonIconBasePath") + param1;
         var _loc3_:String = ZGlobal.getAssetURL(_loc2_);
         this.m_survivalModeIconLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,this.survivalModeButtonMC.battle01_icon);
         if(this.m_survivalModeIconLoader)
         {
            this.m_survivalModeIconLoader.smooth = true;
         }
      }
      
      private function onSurvivalModeClicked(param1:MouseEvent) : void
      {
         if(SurvivalModeManager.instance.enabled)
         {
            SurvivalModeManager.instance.launchSurvivalMode(SurvivalModeManager.ENTRY_POINT_OPTIONSMENU);
         }
         SurvivalModeManager.instance.removeTutorial();
      }
      
      private function updateSurvivalModeButton() : void
      {
         var _loc1_:Boolean = SurvivalModeManager.instance.enabled;
         if(_loc1_)
         {
            Tooltip.subscribe(this.survivalModeButtonMC,ZGameUtils.ZlocT("Dialogs","SurvivalModeOptionMenuTooltip"));
         }
         else
         {
            Tooltip.subscribe(this.survivalModeButtonMC,ZGameUtils.ZlocT("Dialogs","SurvivalModeDisabled"));
         }
         this.activateButton(this.survivalModeButtonMC,_loc1_);
         this.m_survivalModeButton.enable = _loc1_;
      }
      
      private function initBattleButtonUI() : void
      {
         DominationModeManager.instance.addEventListener(DominationModeManager.NUM_REVENGEFIGHTS_CHANGED,this.onNumRevengeFightsChanged,false,0,true);
         this.updateNewFightsIndicator();
         this.initBattleListToggleButtons();
         var _loc1_:String = ZGlobal.gameSettings.getString("DominationBattleButtonIcon");
         var _loc2_:String = ZGlobal.getAssetURL(_loc1_);
         this.m_dominationModeButtonIcon = ImageLoaderFactory.CreateImageLoader(_loc2_,this.battleButtonMC.battle01_icon);
         if(this.m_dominationModeButtonIcon)
         {
            this.m_dominationModeButtonIcon.smooth = true;
         }
      }
      
      private function get dominationModeIcon() : UILoader
      {
         return this.battleButtonMC.battle01_icon;
      }
      
      private function get RevengeClip() : MovieClip
      {
         return this.battleButtonMC.DominanceGlobe_mc;
      }
      
      private function set dominationButtonEnable(param1:Boolean) : void
      {
         var _loc3_:Object = null;
         var _loc2_:UILoader = this.dominationModeIcon;
         _loc2_.mouseEnabled = param1;
         _loc2_.buttonMode = param1;
         _loc2_.useHandCursor = param1;
         this.activateButton(_loc2_,param1);
         if(param1)
         {
            _loc2_.addEventListener(MouseEvent.CLICK,this.onDominationModeClicked,false,0,true);
            Tooltip.subscribe(_loc2_,ZGameUtils.ZlocT("Dialogs","DominationLevelUpUnlockLabel"));
         }
         else if(DominationModeManager.instance.inDominationExperiment)
         {
            _loc3_ = {"level":DominationModeManager.instance.requiredLevel};
            Tooltip.subscribe(_loc2_,ZGameUtils.ZlocT("Dialogs","DominanceInsufficientLevelNew",_loc3_));
         }
         else
         {
            _loc2_.removeEventListener(MouseEvent.CLICK,this.onDominationModeClicked);
            Tooltip.subscribe(_loc2_,ZGameUtils.ZlocT("Dialogs","ComingSoon"));
         }
      }
      
      private function initBattleListToggleButtons() : void
      {
         this.battleButtonMC.mapChooser_mc.visible = false;
         TextFieldUtil.processTextField(this.battleButtonMC.mapChooser_mc.title_tf,ZGameUtils.ZlocT("Main","BattleMenuTitle"));
         var _loc1_:MovieClip = this.battleChooserButton;
         var _loc2_:MovieClip = this.battleChooserCloseButton;
         this.m_battleChooserBtn = new MovieClipButton(_loc1_);
         this.m_battleChooserCloseBtn = new MovieClipButton(_loc2_);
         _loc1_.buttonMode = true;
         _loc1_.useHandCursor = true;
         _loc2_.buttonMode = true;
         _loc2_.useHandCursor = true;
         Tooltip.subscribe(_loc1_,ZGameUtils.ZlocT("Main","BattleButtonCloseTooltip"));
         Tooltip.subscribe(_loc2_,ZGameUtils.ZlocT("Main","BattleButtonCloseTooltip"));
         this.m_buttonSounds.addButton(_loc1_,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(_loc2_,ButtonSound.DEFAULT);
         TutorialManager.instance.addToUIElements(_loc1_);
         TutorialManager.instance.addToUIElements(_loc2_);
         _loc1_.addEventListener(MouseEvent.CLICK,this.onToggleBattleList,false,0,true);
         _loc2_.addEventListener(MouseEvent.CLICK,this.onToggleBattleList,false,0,true);
         this.updateBattleButtonVisibility();
      }
      
      private function onToggleBattleList(param1:MouseEvent) : void
      {
         if(this.isBattleListActive)
         {
            this.closeBattleList();
         }
         else
         {
            this.openBattleList();
         }
      }
      
      private function get isBattleListActive() : Boolean
      {
         return this.m_battleListMenuGrid != null;
      }
      
      private function updateBattleButtonVisibility() : void
      {
         this.battleChooserCloseButton.visible = this.isBattleListActive;
         this.battleChooserButton.visible = !this.battleChooserCloseButton.visible;
      }
      
      private function closeBattleList() : void
      {
         this.destroyBattleListMenu();
         this.updateBattleButtonVisibility();
      }
      
      private function openBattleList() : void
      {
         this.destroyBattleListMenu();
         this.closeCampaignMapList();
         this.battleButtonMC.mapChooser_mc.visible = true;
         this.m_battleListMenuGrid = new BattleListMenuGrid(this.battleButtonMC.mapChooser_mc.menu_mc);
         UIDispatcher.instance.addEventListener(BattleListMenuGridSlot.SELECTED,this.onBattleListButtonClicked,false,0,true);
         if(this.m_battleListMenuGrid.numCards == 3)
         {
            this.displayObject.battleButtons_mc.battle01_bt.mapChooser_mc.menu_mc.gotoAndStop(2);
            if(!this.m_dominationButtonModified)
            {
               this.m_dominationButtonModified = true;
               this.displayObject.battleButtons_mc.battle01_bt.mapChooser_mc.back_mc.height += 37;
               this.displayObject.battleButtons_mc.battle01_bt.mapChooser_mc.menu_mc.y -= 37;
               this.displayObject.battleButtons_mc.battle01_bt.mapChooser_mc.title_tf.y -= 37;
            }
         }
         else
         {
            this.displayObject.battleButtons_mc.battle01_bt.mapChooser_mc.menu_mc.gotoAndStop(1);
         }
         this.updateBattleButtonVisibility();
      }
      
      private function destroyBattleListMenu() : void
      {
         if(this.m_battleListMenuGrid)
         {
            this.battleButtonMC.mapChooser_mc.visible = false;
            UIDispatcher.instance.removeEventListener(BattleListMenuGridSlot.SELECTED,this.onBattleListButtonClicked);
            this.m_battleListMenuGrid.dispose();
            this.m_battleListMenuGrid = null;
         }
      }
      
      private function onBattleListButtonClicked(param1:WorldEvent) : void
      {
         this.closeBattleList();
         var _loc2_:BattleListMenuGridSlot = param1.eventData as BattleListMenuGridSlot;
         if(_loc2_)
         {
            this.updateBattleListButton(_loc2_.battleType);
            if(this.m_battleButtonMode == BATTLETYPE_DOMINATION)
            {
               DominationModeManager.instance.launchDominationScreen();
            }
            else if(this.m_battleButtonMode == BATTLETYPE_BBLITZ)
            {
               PVPManager.instance.toggleGlobalPVPBar();
            }
            else if(this.m_battleButtonMode == BATTLETYPE_DEATHMATCH)
            {
               DeathMatchManager.instance.launchLobby();
            }
         }
      }
      
      private function onNumRevengeFightsChanged(param1:Event) : void
      {
         this.updateNewFightsIndicator();
      }
      
      private function updateNewFightsIndicator() : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:Boolean = false;
         var _loc1_:uint = DominationModeManager.instance.newRevengeFights;
         var _loc2_:MovieClip = this.battleButtonMC.badge_mc;
         var _loc3_:Boolean = this.m_battleButtonMode == BATTLETYPE_DOMINATION;
         if(_loc3_ && DominationModeManager.instance.enabled && Boolean(_loc1_))
         {
            TextFieldUtil.processTextField(_loc2_.counter_tf,String(_loc1_));
            _loc2_.visible = true;
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DOMINANCE_CHANGE_REVENGE_ICON) == ExperimentsManager.VARIANT_DOMINANCE_CHANGE_REVENGE_ICON)
            {
               this.battleButtonMC.DominanceGlobe_mc.visible = true;
               _loc4_ = this.RevengeClip;
               _loc5_ = true;
               _loc4_.mouseEnabled = _loc5_;
               _loc4_.buttonMode = _loc5_;
               _loc4_.useHandCursor = _loc5_;
               this.activateButton(_loc4_,_loc5_);
               if(_loc5_)
               {
                  _loc4_.addEventListener(MouseEvent.CLICK,this.onDominationModeClicked,false,0,true);
               }
               this.battleButtonMC.battle01_icon.visible = false;
            }
         }
         else
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DOMINANCE_CHANGE_REVENGE_ICON) == ExperimentsManager.VARIANT_DOMINANCE_CHANGE_REVENGE_ICON)
            {
               if(this.battleButtonMC.DominanceGlobe_mc)
               {
                  this.battleButtonMC.DominanceGlobe_mc.removeEventListener(MouseEvent.CLICK,this.onDominationModeClicked);
               }
               this.battleButtonMC.battle01_icon.visible = true;
               this.battleButtonMC.DominanceGlobe_mc.visible = false;
            }
            _loc2_.visible = false;
         }
      }
      
      public function get survivalModeButtonMC() : MovieClip
      {
         return this.m_displayObject.battleButtons_mc.battle02_bt;
      }
      
      private function get battleButtonMC() : MovieClip
      {
         return this.m_displayObject.battleButtons_mc.battle01_bt;
      }
      
      private function get battleChooserCloseButton() : MovieClip
      {
         return this.battleButtonMC.mapChooser_btn_close;
      }
      
      private function get battleChooserButton() : MovieClip
      {
         return this.battleButtonMC.mapChooser_btn;
      }
      
      private function updateBattleListButton(param1:uint) : void
      {
         this.m_battleButtonMode = param1;
         this.battleButtonMC.battleBlitz_bt.visible = false;
         this.battleButtonMC.battle01_icon.visible = false;
         if(param1 == BATTLETYPE_BBLITZ)
         {
            this.battleButtonMC.battleBlitz_bt.visible = true;
            this.battleButtonMC.battle01_icon.visible = true;
         }
         else if(param1 == BATTLETYPE_DOMINATION)
         {
            this.battleButtonMC.battle01_icon.visible = true;
         }
         this.updateNewFightsIndicator();
      }
   }
}

