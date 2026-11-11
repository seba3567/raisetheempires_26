package core.managers.tutorialManager
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.managers.ChallengeModeManager;
   import core.managers.PopulationManager;
   import core.managers.WorldObjectManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.NarratorUIItem;
   import core.worlds.strategicWorld.StrategicMap;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import transactions.TSetTutorialProgress;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class TutorialManager extends EventDispatcher
   {
      
      public static const TUTORIAL_INDEX_CATEGORY:String = "tutorialStep";
      
      public static var BIND_QUEST:String = "bindQuest";
      
      public static var SET_LOCKED:String = "setLocked";
      
      public static var SET_UNLOCKED:String = "setUnlocked";
      
      public static var UI_ELEMENT:String = "uiElement";
      
      public static var STORE_CLOSED:String = "storeClosed";
      
      public static var QUEST_TASK_CLICKED:String = "taskClicked";
      
      public static var UI_HIGHLIGHT_ITEM:String = "uiitem";
      
      public static var UI_HIGHLIGHT_STORE_TAB:String = "uiStoreTab";
      
      public static var UI_HIGHLIGHT_STORE_INDEX:String = "uiStoreTabIndex";
      
      public static var UI_STORE_TAB_CLICK:String = "uiStoreTabClick";
      
      public static var UI_HIGHLIGHT_LETTER_FOLDER:String = "uiDossier";
      
      public static var UI_HIGHLIGHT_ISLAND:String = "uiIsland";
      
      public static var UI_STENCIL_ITEM:String = "uiStencilItem";
      
      public static var UI_STENCIL_ISLAND:String = "uiStencilIsland";
      
      public static var UI_STENCIL_COMBAT_ALLY:String = "uiStencilCombatAlly";
      
      public static var UI_HIGHLIGHT_NEIGHBOR:String = "uiHighlightNeighbor";
      
      public static var UI_HIGHLIGHT_STRATMAP_VILLAIN:String = "uiHighlightStratMapVillain";
      
      public static var PAUSE_QUEST_STARTS:String = "pauseQuestsStarts";
      
      public static var RESUME_QUEST_STARTS:String = "resumeQuestStarts";
      
      public static var DISABLE_ISLAND_RETURN_HOME:String = "disableIslandReturnHome";
      
      public static var ENABLE_ISLAND_RETURN_HOME:String = "enableIslandReturnHome";
      
      public static var DISABLE_STRATEGIC_MAP:String = "disableStrategicMap";
      
      public static var ENABLE_STRATEGIC_MAP:String = "enableStrategicMap";
      
      public static var TUTORIAL_PAUSED:String = "TutorialPaused";
      
      public static var DISABLE_PRE_BATTLE_UI_CONTROLS:String = "disablePreBattleUIControls";
      
      public static var ENABLE_PRE_BATTLE_UI_CONTROLS:String = "enablePreBatleUIControls";
      
      public static var DISABLE_SPECIAL_POWER_SELECTION_CONTROLS:String = "disableSpecialPowerSelectionControls";
      
      public static var ENABLE_SPECIAL_POWER_SELECTION_CONTROLS:String = "enableSpecialPowerSelectionControls";
      
      public static var SET_UNSELLABLE:String = "setUnsellable";
      
      public static var CLEAR_UNSELLABLE:String = "clearUnsellable";
      
      public static var LIMIT_ALLY_SELECTION:String = "limitAllySelection";
      
      public static var ENABLE_COMBAT_PAUSE_RETREAT:String = "enableCombatPauseRetreat";
      
      public static var QUEST_POPUP_CONTINUE:String = "tutorialcontinue01";
      
      public static var CLEAR_CONTINUE:String = "tutorialcontinue02";
      
      public static var REWARDPICKUP_CONTINUE:String = "tutorialcontinue03";
      
      public static var DIALOG_CONTINUE:String = "tutorialcontinue05";
      
      public static var SELECT_CONTINUE:String = "tutorialcontinue06";
      
      public static var QUEST_COMPLETE_POPUP_CONTINUE:String = "tutorialcontinue07";
      
      public static var COMBAT_SEQUENCE_CONTINUE:String = "tutorialcontinue08";
      
      public static var LETTER_CONTINUE:String = "tutorialcontinue10";
      
      public static var LETTER_CLOSE:String = "tutorialcontinue11";
      
      public static var ISLAND_CONTINUE:String = "tutorialcontinue12";
      
      public static var STRATEGIC_MAP_CONTINUE:String = "tutorialcontinue13";
      
      public static var CONTRACT_MARKET_CONTINUE:String = "tutorialcontinue14";
      
      public static var CONTRACT_MARKET_BUY_CONTINUE:String = "tutorialcontinue15";
      
      public static var LETTER_CREATION:String = "tutorialcontinue16";
      
      public static var SPEECH_CONTINUE:String = "tutorialcontinue17";
      
      public static var EPISODE_CONTINUE:String = "tutorialcontinue18";
      
      public static var BUILD_FINISHED:String = "tutorialcontinue19";
      
      public static var STORE_OPENED:String = "tutorialcontinue20";
      
      public static var NEW_NATION_CONTINUE:String = "tutorialcontinue21";
      
      public static var RETURN_HOME_CONTINUE:String = "tutorialcontinue22";
      
      public static var COMBAT_UNITS_SCREEN:String = "tutorialcontinue23";
      
      public static var COMBAT_ALLIES_SCREEN:String = "tutorialcontinue24";
      
      public static var COMBAT_ALLY_ADDED:String = "tutorialcontinue25";
      
      public static var COMBAT_CONSUMABLE_USED:String = "tutorialcontinue26";
      
      public static var COMBAT_SPECIALPOWERS_SCREEN:String = "tutorialcontinue27";
      
      public static var COMBAT_ALLY_NEXT:String = "tutorialcontinue28";
      
      public static var STRAT_MAP_HOME_CLICK:String = "tutorialcontinue29";
      
      public static var ZOOM_IN_CLICK:String = "tutorialcontinue30";
      
      public static var ZOOM_OUT_CLICK:String = "tutorialcontinue31";
      
      public static var FULL_SCREEN_CLICK:String = "tutorialcontinue32";
      
      public static var PVP_MARKER_LOADED:String = "tutorialcontinue33";
      
      public static var INVENTORY_OPENED:String = "tutorialcontinue34";
      
      public static var NEIGHBOR_VISIT_CLICKED:String = "tutorialcontinue35";
      
      public static var STRAT_MAP_LOADED:String = "tutorialcontinue36";
      
      public static var COMBAT_SPECIALPOWERS_SCREEN_PRE_ANIM:String = "tutorialcontinue37";
      
      public static var INVITE_FRIENDS_CONTINUE:String = "tutorialcontinue38";
      
      public static var WORLD_LOADED_CONTINUE:String = "tutorialcontinue29";
      
      public static var CONTRACT_SCREEN_LOADED:String = "tutorialcontinue30";
      
      public static var INVENTORY_CLOSED:String = "tutorialcontinue31";
      
      public static var COMBAT_START:String = "combatStart";
      
      public static var COMBAT_END:String = "combatEnd";
      
      public static var COMBAT_FIGHT_CONTINUE:String = "combatFightPressed";
      
      public static var COMBAT_HIDE_UI:String = "combatHideUI";
      
      public static var COMBAT_SHOW_UI:String = "combatShowUI";
      
      public static var COMBAT_UNIT_CLICK:String = "combatUnitClick";
      
      public static var COMBAT_DISABLE_SPECIAL_POWERS:String = "combatDisableSpecialPowers";
      
      public static var COMBAT_ENABLE_SPECIAL_POWERS:String = "combatEnableSpecialPowers";
      
      public static var COMBAT_SPECIAL_POWER_CLICKED:String = "combatSpecialPowerClicked";
      
      public static var COMBAT_LOCK_SELECTION:String = "combatLockSelection";
      
      public static var COMBAT_UNLOCK_SELECTION:String = "combatUnlockSelection";
      
      public static var COMBAT_PRE_BATTLE_UI_READY:String = "combatPreBattleUIReady";
      
      public static var COMBAT_ALWAYS_SHOW_CLASS_ICONS:String = "combatAlwaysShowClassIcons";
      
      public static var COMBAT_HIGHLIGHT_UNIT_CLASS_ICON:String = "combatHighlightUnitClassIcon";
      
      public static var COMBAT_HIGHLIGHT_CLEAR_UNIT_CLASS_ICON:String = "combatUnitHighlightUnitClassIcon";
      
      public static var COMBAT_HIGHLIGHT_CLASS_TOOLTIP_ICON:String = "combatHighlightClassTooltipIcon";
      
      public static var COMBAT_CLEAR_HIGHLIGHT_CLASS_TOOLTIP_ICON:String = "combatClearHighlightClassTooltipIcon";
      
      public static var PVP_REPEL_CLICKED:String = "pvpRepelClicked";
      
      public static var DOMINATION_FIRST_FIGHT:String = "DominationFirstFight";
      
      public static var DOMINATION_FIRST_DEFENSE_SETUP:String = "DominationFirstDefenseSetup";
      
      public static const ADD_STENCIL:String = "addStencil";
      
      public static const REMOVE_STENCIL:String = "removeStencil";
      
      public static var UI_TASK:String = "UI_TASK";
      
      public static var UI_STORE:String = "UI_STORE";
      
      public static var UI_DISABLE:String = "UI_DISABLE";
      
      public static var UI_INVENTORY:String = "UI_INVENTORY";
      
      public static var UI_STRATMAP:String = "UI_STRATMAP";
      
      public static var UI_HOME:String = "UI_HOME";
      
      public static var UI_COMBAT_FIGHT:String = "UI_COMBAT_FIGHT";
      
      public static var UI_SPECIAL_POWER:String = "UI_SPECIAL_POWER";
      
      public static var UI_COMBAT_SETUP_NEXT:String = "UI_COMBAT_SETUP_NEXT";
      
      public static var UI_GLOBAL_PVP:String = "UI_GLOBAL_PVP";
      
      public static var UI_DOMINATION:String = "UI_DOMINATION";
      
      public static var UI_DOMINATION_FIRST_FIGHT:String = "UI_DOMINATION_FIRST_FIGHT";
      
      public static var UI_DOMINATION_FIRST_DEFENSE_SETUP:String = "UI_DOMINATION_FIRST_DEFENSE_SETUP";
      
      public static var UI_CAMPAIGN_SELECTOR_OPENER:String = "UI_CAMPAIGN_SELECTOR_OPENER";
      
      public static var UI_CAMPAIGN_SELECTOR_CLOSER:String = "UI_CAMPAIGN_SELECTOR_CLOSER";
      
      public static var UI_CAMPAIGN_SELECTOR_NEWMAP:String = "UI_CAMPAIGN_SELECTOR_NEWMAP";
      
      public static var UI_STRATEGIC_MAP:String = "UI_STRATEGIC_MAP";
      
      public static var UI_ZOOM_IN:String = "UI_ZOOM_IN";
      
      public static var UI_ZOOM_OUT:String = "UI_ZOOM_OUT";
      
      public static var UI_FULL_SCREEN:String = "UI_FULL_SCREEN";
      
      public static var UI_ENABLE:String = "UI_ENABLE";
      
      public static var UI_PVP_PORTRAIT:String = "UI_PVP_PORTRAIT";
      
      public static var UI_CLEAR_STENCIL:String = "UI_CLEAR_STENCIL";
      
      public static const TUTORIAL_NEW_NATION:String = "tutorialNewNation";
      
      public static const SET_TUTORIAL_STEP:String = "setTutorialStep";
      
      public static const TUTORIAL_COMPLETE:String = "tutorialComplete";
      
      public static const CAMPAIGN_SELECTOR_OPENED:String = "CAMPAIGN_SELECTOR_OPENED";
      
      public static const CAMPAIGN_MAP_SELECTED:String = "CAMPAIGN_MAP_SELECTED";
      
      public static const CAMPAIGN_SELECTOR_HIGHLIGHT:String = "CAMPAIGN_SELECTOR_HIGHLIGHT";
      
      public static const ALLIANCE_HUD:String = "alliance_hud";
      
      public static var instance:TutorialManager = new TutorialManager();
      
      private static var m_uiHighlighted:String = null;
      
      private static var m_uiStoreTabIndex:String = null;
      
      private static var m_uiStencil:String = null;
      
      private static var m_highlightToolTipClassIcon:String = null;
      
      private var m_index:int = 0;
      
      private var m_data:XMLList = null;
      
      private var m_uiItems:Dictionary = null;
      
      private var m_tutorialHighlighter:TutorialHighlighter = null;
      
      private var m_tutorialClassHighlighter:TutorialClassHighlighter = null;
      
      private var m_uiElements:Array = null;
      
      private var m_active:Boolean = false;
      
      private var m_steps:Array = null;
      
      private var m_clearArrow:Boolean = true;
      
      private var m_storeTab:String = null;
      
      private var m_locked:String = null;
      
      private var m_unlocked:String = null;
      
      private var m_unsellable:String = null;
      
      private var m_eventUIMap:Dictionary = new Dictionary();
      
      private var m_restoringState:Boolean = false;
      
      private var m_restoringInCombat:Boolean = false;
      
      private var m_restoringPaused:Boolean = false;
      
      private var m_restoreState:Boolean = true;
      
      private var m_pvpTutorialMode:Boolean = false;
      
      private var m_disableUnitCardRemove:Boolean = false;
      
      private var m_waitForBattleUITweens:Boolean = false;
      
      private var m_newUser:Boolean = false;
      
      private var m_neighborBarEnabled:Boolean = true;
      
      private var m_arrowActive:Boolean = false;
      
      private var m_specialPowerSelectionTooltipsEnabled:Boolean = true;
      
      private var m_lockedPurchaseItems:Array = new Array();
      
      public function TutorialManager()
      {
         super();
         this.m_uiItems = new Dictionary();
         this.m_uiElements = new Array();
         addEventListener(UI_ELEMENT,this.onUIElement,false,0,true);
         addEventListener(UI_HIGHLIGHT_ITEM,this.onSetUiHighlighted,false,0,true);
         addEventListener(UI_HIGHLIGHT_STORE_TAB,this.onHighlightStoreTab,false,0,true);
         addEventListener(UI_HIGHLIGHT_STORE_INDEX,this.onSetStoreTabIndex,false,0,true);
         addEventListener(UI_STENCIL_ITEM,this.onStencilElement,false,0,true);
         addEventListener(SET_TUTORIAL_STEP,this.onSetTutorialStep,false,0,true);
         this.m_eventUIMap[UI_TASK] = "QuestList";
         this.m_eventUIMap[UI_STORE] = "Store";
         this.m_eventUIMap[UI_INVENTORY] = "Inventory";
         this.m_eventUIMap[UI_STRATMAP] = "StratMap";
         this.m_eventUIMap[UI_HOME] = "Home";
         this.m_eventUIMap[UI_COMBAT_FIGHT] = "CombatFight";
         this.m_eventUIMap[UI_SPECIAL_POWER] = "SpecialPower";
         this.m_eventUIMap[UI_COMBAT_SETUP_NEXT] = "CombatSetupNext";
         this.m_eventUIMap[UI_GLOBAL_PVP] = "GlobalPVP";
         this.m_eventUIMap[UI_DOMINATION] = "Domination";
         this.m_eventUIMap[UI_DOMINATION_FIRST_FIGHT] = DOMINATION_FIRST_FIGHT;
         this.m_eventUIMap[UI_DOMINATION_FIRST_DEFENSE_SETUP] = DOMINATION_FIRST_DEFENSE_SETUP;
         this.m_eventUIMap[UI_DISABLE] = null;
         this.m_eventUIMap[UI_ENABLE] = null;
         this.m_eventUIMap[UI_CLEAR_STENCIL] = null;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_data = param1;
      }
      
      public function setStartingIndex(param1:String) : void
      {
         var _loc2_:int = 0;
         this.m_index = this.getIndex(param1);
         if(param1 == "skip")
         {
            this.m_index = 1000;
         }
         Logger.info(this,"setStartingIndex","Tutorial id set to: " + this.getId(this.m_index) + " index: " + this.m_index);
         this.startTutorial();
      }
      
      public function completedTutorialStep(param1:String) : Boolean
      {
         var _loc2_:int = this.getIndex(param1);
         return _loc2_ > 0 && _loc2_ < this.m_index;
      }
      
      private function getIndex(param1:String) : int
      {
         var _loc3_:XML = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_data.step)
         {
            if(_loc3_.@id.toString() == param1 || _loc3_.@text.toString() == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function showInvalidVisitPopup() : void
      {
         var _loc1_:GenericPopup = new GenericPopup1B(ZGameUtils.ZlocT("Dialogs","CantVisitTutorialLockedMessage"),"",GenericPopup.TYPE_OK,null);
         _loc1_.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
         PopupManager.instance.push(_loc1_);
      }
      
      private function getId(param1:int) : String
      {
         if(this.m_data.step[param1])
         {
            return this.m_data.step[param1].@id.toString();
         }
         return null;
      }
      
      public function set tutorial(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         if(this.m_index < 1000)
         {
            Logger.info(this,"tutorial","Setting tutorial to step: " + param1);
            _loc2_ = 0;
            for each(_loc3_ in this.m_data.step)
            {
               if(_loc3_.@text.toString() == param1 || _loc3_.@id.toString() == param1)
               {
                  this.m_active = true;
                  this.m_index = _loc2_;
                  Logger.info(this,"tutorial","Setting m_index: " + this.m_index + " id: " + _loc3_.@id.toString());
                  this.setupNextAction();
                  TransactionManager.addTransaction(new TSetTutorialProgress(_loc3_.@id.toString()));
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function get storeTab() : String
      {
         return this.m_storeTab;
      }
      
      public function set storeTab(param1:String) : void
      {
         this.m_storeTab = param1;
      }
      
      public function get restoringState() : Boolean
      {
         return this.m_restoringState;
      }
      
      public function set pvpTutorialMode(param1:Boolean) : void
      {
         this.m_pvpTutorialMode = param1;
      }
      
      public function get pvpTutorialMode() : Boolean
      {
         return this.m_pvpTutorialMode;
      }
      
      public function set unitCardRemoveDisabled(param1:Boolean) : void
      {
         this.m_disableUnitCardRemove = param1;
      }
      
      public function get unitCardRemoveDisabled() : Boolean
      {
         return this.m_disableUnitCardRemove;
      }
      
      public function set newUser(param1:Boolean) : void
      {
         this.m_newUser = param1;
      }
      
      public function get newUser() : Boolean
      {
         return this.m_newUser;
      }
      
      public function set neighborBarEnabled(param1:Boolean) : void
      {
         this.m_neighborBarEnabled = param1;
      }
      
      public function get neighborBarEnabled() : Boolean
      {
         return this.m_neighborBarEnabled;
      }
      
      public function get highlightCombatTooltipClassIcon() : String
      {
         return m_highlightToolTipClassIcon;
      }
      
      public function set arrowActive(param1:Boolean) : void
      {
         this.m_arrowActive = param1;
      }
      
      public function get arrowActive() : Boolean
      {
         return this.m_arrowActive;
      }
      
      public function set specialPowerTooltipsEnabled(param1:Boolean) : void
      {
         this.m_specialPowerSelectionTooltipsEnabled = param1;
      }
      
      public function get specialPowerTooltipsEnabled() : Boolean
      {
         return this.m_specialPowerSelectionTooltipsEnabled;
      }
      
      public function set lockedPurchaseItems(param1:Array) : void
      {
         if(param1)
         {
            this.m_lockedPurchaseItems = param1;
         }
         else
         {
            this.m_lockedPurchaseItems = new Array();
         }
      }
      
      private function onSetTutorialStep(param1:WorldEvent) : void
      {
         if(param1.eventData as String)
         {
            this.tutorial = param1.eventData as String;
         }
      }
      
      public function isLocked(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         if(this.m_unlocked != null)
         {
            _loc2_ = this.m_unlocked.indexOf(param1);
            if(_loc2_ >= 0)
            {
               return false;
            }
         }
         if(this.m_locked != null)
         {
            if(this.m_locked == "all")
            {
               return true;
            }
            _loc2_ = this.m_locked.indexOf(param1);
            if(_loc2_ >= 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isUnsellable(param1:String) : Boolean
      {
         if(this.m_unsellable != null)
         {
            if(this.m_unsellable.indexOf(param1) >= 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isPurchaseable(param1:String) : Boolean
      {
         if(Boolean(this.m_lockedPurchaseItems) && this.m_lockedPurchaseItems.indexOf(param1) >= 0)
         {
            return false;
         }
         return true;
      }
      
      public function isTutorialComplete() : Boolean
      {
         return ZGlobal.player.tutorialProgress == "skip" || this.m_data && this.m_data.step && (ZGlobal.player.questGatesComplete || ZGlobal.player.didCompleteQuest("QV01") || ZGlobal.player.level > 7) && this.m_index >= this.m_data.step.length() - 1;
      }
      
      public function unlockTutorial(param1:String) : void
      {
         if(this.getIndex(param1) > this.m_index)
         {
            this.tutorial = param1;
         }
      }
      
      private function startTutorial() : void
      {
         if(this.m_index < this.m_data.step.length())
         {
            this.m_active = true;
            addEventListener(STORE_CLOSED,this.onStoreClosed);
            addEventListener(TutorialManager.SET_LOCKED,this.onSetLocked);
            addEventListener(TutorialManager.SET_UNLOCKED,this.onSetUnlocked);
            addEventListener(TutorialManager.SET_UNSELLABLE,this.onSetTutorialUnsellable);
            addEventListener(TutorialManager.CLEAR_UNSELLABLE,this.onClearUnsellable);
            addEventListener(COMBAT_HIGHLIGHT_CLASS_TOOLTIP_ICON,this.onHighlightCombatClassTooltipIcon,false,0,true);
            addEventListener(COMBAT_CLEAR_HIGHLIGHT_CLASS_TOOLTIP_ICON,this.onClearHighlightCombatClassTooltipIcon,false,0,true);
            if(GameModeManager.instance.getTopGameMode().canSwitchToTutorial)
            {
               GameModeManager.instance.setDefaultGameMode();
            }
            if(!this.newUser)
            {
               this.ValidateStartingStep();
            }
            if(!this.m_restoringInCombat && this.m_restoreState)
            {
               this.restoreState();
               this.setupNextAction();
            }
            if(this.m_restoringInCombat && this.m_restoreState)
            {
               this.restoreStateAlways();
            }
         }
      }
      
      private function ValidateStartingStep() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:XML = null;
         var _loc7_:String = null;
         if(ZGlobal.player.didCompleteQuest("QV01") && this.m_index != this.m_data.step.length() - 1)
         {
            this.m_index = this.m_data.step.length() - 1;
            this.m_restoreState = false;
            Logger.info(this,"ValidateStartingStep","User completed Krunsch updating Tutorial id to: " + this.getId(this.m_index) + " index: " + this.m_index);
            _loc3_ = this.m_data.step[this.m_index].@id.toString();
            TransactionManager.addTransaction(new TSetTutorialProgress(_loc3_));
            return;
         }
         var _loc1_:XML = this.m_data.step[this.m_index];
         var _loc2_:Boolean = false;
         if(_loc1_.@validatePlacement.toString())
         {
            _loc4_ = _loc1_.@validatePlacement.toString();
            if(this.isItemPlaced(_loc4_))
            {
               this.doValidateAction(true);
               _loc2_ = true;
            }
            else
            {
               this.doValidateAction(false);
               _loc2_ = true;
            }
         }
         else if(_loc1_.@advanceOnRefresh.toString() == "true")
         {
            this.onAdvance();
            _loc2_ = true;
         }
         else if(_loc1_.@rewindOnRefresh.toString() == "true")
         {
            this.onRewind();
            _loc2_ = true;
         }
         else
         {
            for each(_loc6_ in _loc1_.func)
            {
               if(_loc6_.@name.toString() == "waitForQuestCompletion")
               {
                  if(ZGlobal.player.didCompleteQuest(_loc6_.@param.toString()))
                  {
                     this.onAdvance();
                     _loc2_ = true;
                  }
               }
            }
         }
         if(_loc2_)
         {
            this.ValidateStartingStep();
            return;
         }
         if(_loc1_.@combatStep.toString() == "true")
         {
            _loc7_ = _loc1_.@combatEventWait.toString();
            if(_loc7_ == "BattleStart" || _loc7_ == "BattleStartWaitForTweens")
            {
               BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onRestoreTutorial);
               if(_loc7_ == "BattleStartWaitForTweens")
               {
                  this.m_waitForBattleUITweens = true;
               }
            }
            else if(_loc7_ == "PreBattleUI")
            {
               addEventListener(TutorialManager.COMBAT_PRE_BATTLE_UI_READY,this.onRestoreTutorial);
            }
            this.m_restoringInCombat = true;
         }
         if(_loc1_.@restoreState != undefined && _loc1_.@restoreState.toString() != "true")
         {
            Logger.info(this,"ValidateStartingStep","At end of tutorial skipping restoreState");
            this.m_restoreState = false;
         }
      }
      
      private function isItemPlaced(param1:String) : Boolean
      {
         if(WorldObjectManager.instance.getNumberObjectsWithCode(param1) > 0)
         {
            return true;
         }
         return false;
      }
      
      private function isItemBuilt(param1:String) : Boolean
      {
         if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode(param1) > 0)
         {
            return true;
         }
         return false;
      }
      
      private function onAdvance() : void
      {
         var _loc1_:XML = this.m_data.step[this.m_index];
         var _loc2_:Number = Number(_loc1_.@advanceSteps.toString());
         if(_loc2_ > 0)
         {
            this.m_index += _loc2_;
         }
         else
         {
            ++this.m_index;
         }
         var _loc3_:String = this.m_data.step[this.m_index].@id.toString();
         Logger.info(this,"onAdvance","ADVANCING TO STEP: " + this.m_index + " STEP ID: " + _loc3_);
      }
      
      private function onRewind() : void
      {
         var _loc1_:XML = this.m_data.step[this.m_index];
         var _loc2_:Number = Number(_loc1_.@rewindSteps.toString());
         if(_loc2_ > 0)
         {
            this.m_index -= _loc2_;
         }
         else
         {
            --this.m_index;
         }
         var _loc3_:String = this.m_data.step[this.m_index].@id.toString();
         Logger.info(this,"onRewind","MOVING BACK TO STEP: " + this.m_index + " STEP ID: " + _loc3_);
         if(this.m_index < 0)
         {
            this.m_index = 0;
         }
      }
      
      private function setStep() : void
      {
         var _loc1_:XML = this.m_data.step[this.m_index];
         var _loc2_:String = _loc1_.@jumpToStep.toString();
         var _loc3_:int = this.getIndex(_loc2_);
         Logger.info(this,"setStep","JUMPING STEP TO: " + _loc2_ + " STEP ID: " + _loc3_);
         this.m_index = _loc3_;
      }
      
      private function isPauseStep() : Boolean
      {
         var _loc2_:XML = null;
         var _loc1_:XML = this.m_data.step[this.m_index];
         for each(_loc2_ in _loc1_.func)
         {
            if(_loc2_.@name.toString() == "pauseTutorial")
            {
               return true;
            }
         }
         return false;
      }
      
      private function onRestoreTutorial(param1:Event) : void
      {
         if(this.isPVPBattle())
         {
            return;
         }
         if(this.m_waitForBattleUITweens)
         {
            if((ContextualBarUIItem.getContextualBar() as ContextualBarUIItem).isTweening())
            {
               UIDispatcher.instance.addEventListener(ContextualBarUIItem.TWEEN_END,this.onRestoreTutorial);
               this.m_waitForBattleUITweens = false;
               return;
            }
         }
         this.m_restoringInCombat = false;
         this.restoreState();
         this.setupNextAction();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onRestoreTutorial);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_PRE_BATTLE_UI_READY,this.onRestoreTutorial);
         UIDispatcher.instance.removeEventListener(ContextualBarUIItem.TWEEN_END,this.onRestoreTutorial);
      }
      
      public function pauseTutorial() : void
      {
         this.m_active = false;
         NarratorUIItem.getNarratorBar().dispatchEvent(new WorldEvent(NarratorUIItem.REMOVE_NARRATOR_EVENT));
         this.enableAllUIElements(true);
         if(this.m_tutorialHighlighter)
         {
            this.m_tutorialHighlighter.dispose();
            this.m_tutorialHighlighter = null;
         }
         dispatchEvent(new WorldEvent(TUTORIAL_PAUSED));
      }
      
      public function getAllyConsumableOverride() : ConsumableItem
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         if(this.m_active && this.m_index < this.m_data.step.length())
         {
            _loc1_ = this.m_data.step[this.m_index];
            _loc2_ = _loc1_.@allyConsumable.toString();
            return ZGlobal.gameSettings.getItemByCode(_loc2_,ConsumableItem) as ConsumableItem;
         }
         return null;
      }
      
      private function deinit() : void
      {
         if(this.m_active)
         {
            this.m_active = false;
            this.clearCurrentSteps();
            removeEventListener(STORE_CLOSED,this.onStoreClosed);
            removeEventListener(TutorialManager.SET_LOCKED,this.onSetLocked);
            removeEventListener(TutorialManager.SET_UNLOCKED,this.onSetUnlocked);
            removeEventListener(TutorialManager.SET_UNSELLABLE,this.onSetTutorialUnsellable);
            removeEventListener(TutorialManager.CLEAR_UNSELLABLE,this.onClearUnsellable);
            removeEventListener(COMBAT_HIGHLIGHT_CLASS_TOOLTIP_ICON,this.onHighlightCombatClassTooltipIcon);
            removeEventListener(COMBAT_CLEAR_HIGHLIGHT_CLASS_TOOLTIP_ICON,this.onClearHighlightCombatClassTooltipIcon);
            NarratorUIItem.getNarratorBar().dispatchEvent(new WorldEvent(NarratorUIItem.REMOVE_NARRATOR_EVENT));
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onRestoreTutorial);
            removeEventListener(TutorialManager.COMBAT_PRE_BATTLE_UI_READY,this.onRestoreTutorial);
            this.enableAllUIElements(true);
            GameModeManager.instance.setDefaultGameMode();
            if(this.m_tutorialHighlighter)
            {
               this.m_tutorialHighlighter.dispose();
               this.m_tutorialHighlighter = null;
            }
            if(this.m_tutorialClassHighlighter)
            {
               this.m_tutorialClassHighlighter.dispose();
               this.m_tutorialClassHighlighter = null;
            }
         }
         this.m_data = null;
         this.m_uiElements = null;
         this.m_uiItems = null;
      }
      
      private function clearCurrentSteps() : void
      {
         var _loc1_:TutorialStep = null;
         for each(_loc1_ in this.m_steps)
         {
            _loc1_.dispose();
         }
         this.m_steps = null;
      }
      
      public function get active() : Boolean
      {
         return this.m_active;
      }
      
      public function addToUIElements(param1:InteractiveObject) : void
      {
         if(Boolean(this.m_uiElements) && Boolean(param1))
         {
            this.m_uiElements.push(param1);
         }
      }
      
      public function registerUIItem(param1:DisplayObject, param2:String) : void
      {
         if(this.m_uiItems)
         {
            this.m_uiItems[param2] = param1;
         }
      }
      
      public function getUIItem(param1:String) : DisplayObject
      {
         return this.m_uiItems[param1];
      }
      
      private function decodeXML(param1:int) : void
      {
         var _loc3_:XML = null;
         var _loc4_:TutorialStep = null;
         this.clearCurrentSteps();
         var _loc2_:XML = this.m_data.step[param1];
         if(_loc2_)
         {
            this.m_steps = new Array();
            if(_loc2_.@item.toString())
            {
               if(ZGlobal.player.getNumberOfInventoryItems(_loc2_.@item.toString()) <= 0)
               {
                  ZGlobal.player.addToInventory(_loc2_.@item.toString());
               }
            }
            for each(_loc3_ in _loc2_.func)
            {
               _loc4_ = new TutorialStep(_loc3_);
               this.m_steps.push(_loc4_);
            }
            if(param1 == this.m_index)
            {
               this.setupNarrator(_loc2_);
            }
         }
      }
      
      private function setupNarrator(param1:XML) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = param1.@text.toString();
         if(_loc3_.length > 0)
         {
            _loc2_ = _loc3_;
         }
         if(_loc2_ == null)
         {
            NarratorUIItem.getNarratorBar().dispatchEvent(new WorldEvent(NarratorUIItem.REMOVE_NARRATOR_EVENT));
         }
         else
         {
            _loc2_ = ZGameUtils.ZlocT("Narrator",_loc2_);
            NarratorUIItem.getNarratorBar().dispatchEvent(new WorldEvent(NarratorUIItem.ADD_NARRATOR_EVENT,{"text":_loc2_}));
         }
      }
      
      public function addArrowToUIElement(param1:Object, param2:Boolean = true, param3:Boolean = false, param4:Point = null, param5:Number = 0, param6:Boolean = false) : void
      {
         if(param1 as MovieClip != null)
         {
            this.setArrowOnMovieClip(MovieClip(param1),param2,param3,param5,param4);
         }
         else if(param1 as SimpleButton != null)
         {
            this.setArrowOnDisplayObject(SimpleButton(param1),param2,param5,param6,param4);
         }
         else if(param1 as Sprite != null)
         {
            this.setArrowOnDisplayObject(Sprite(param1),param2,param5,param6,param4);
         }
      }
      
      private function allocateArrow() : void
      {
         if(this.m_tutorialHighlighter)
         {
            this.m_tutorialHighlighter.dispose();
            this.m_tutorialHighlighter = null;
         }
         this.m_tutorialHighlighter = new TutorialHighlighter();
      }
      
      public function removeArrows() : void
      {
         if(this.m_tutorialHighlighter)
         {
            this.m_tutorialHighlighter.dispose();
            this.m_tutorialHighlighter = null;
         }
      }
      
      private function allocateClassHighlighter() : void
      {
         this.removeClassHighlighter();
         this.m_tutorialClassHighlighter = new TutorialClassHighlighter();
      }
      
      public function removeClassHighlighter() : void
      {
         if(this.m_tutorialClassHighlighter)
         {
            this.m_tutorialClassHighlighter.dispose();
            this.m_tutorialClassHighlighter = null;
         }
      }
      
      private function setArrowOnMovieClip(param1:MovieClip, param2:Boolean = true, param3:Boolean = false, param4:Number = 0, param5:Point = null) : void
      {
         this.allocateArrow();
         if(!param5)
         {
            param5 = new Point();
         }
         this.m_tutorialHighlighter.setMovieClip(param1,false,param2,param3,param5,param4);
      }
      
      private function setArrowOnDisplayObject(param1:DisplayObject, param2:Boolean = true, param3:Number = 0, param4:Boolean = false, param5:Point = null) : void
      {
         this.allocateArrow();
         this.m_tutorialHighlighter.setDisplayObject(param1,param2,param3,param4,param5);
      }
      
      public function addStencilToUIElement(param1:Object, param2:Point = null, param3:Number = 1) : void
      {
         dispatchEvent(new WorldEvent(ADD_STENCIL,{
            "obj":DisplayObject(param1),
            "offset":param2,
            "modifier":param3,
            "center":false
         }));
      }
      
      private function stencilDisplayObject(param1:DisplayObject, param2:Point = null, param3:Number = 1) : void
      {
         dispatchEvent(new WorldEvent(ADD_STENCIL,{
            "obj":param1,
            "offset":param2,
            "modifier":param3
         }));
      }
      
      public function setClassHighlightOnDisplayObject(param1:DisplayObject, param2:Point = null) : void
      {
         this.allocateClassHighlighter();
         this.m_tutorialClassHighlighter.setDisplayObject(param1,param2);
      }
      
      private function setupNextAction() : void
      {
         if(this.m_clearArrow)
         {
            this.setArrowOnMovieClip(null);
         }
         dispatchEvent(new WorldEvent(TutorialManager.REMOVE_STENCIL));
         this.validateClientState();
         this.decodeXML(this.m_index);
      }
      
      private function validateClientState() : void
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc1_:XML = this.m_data.step[this.m_index];
         var _loc2_:String = _loc1_.@validateClientStep.toString();
         if(_loc2_)
         {
            _loc3_ = _loc1_.@validateClientItem.toString();
            _loc4_ = false;
            _loc5_ = _loc2_.split(",");
            for each(_loc6_ in _loc5_)
            {
               switch(_loc6_)
               {
                  case "built":
                     if(this.validateBuiltState(_loc3_))
                     {
                        _loc4_ = true;
                     }
                     break;
                  case "placed":
                     if(this.validatePlacedState(_loc3_))
                     {
                        _loc4_ = true;
                     }
                     break;
                  case "questComplete":
                     if(this.validateQuestComplete(_loc3_))
                     {
                        _loc4_ = true;
                     }
                     break;
                  case "popCap":
                     if(this.validatePopCap())
                     {
                        _loc4_ = true;
                     }
                     break;
                  case "fleetInventory":
                     if(this.validateCampaignFleetInventoryEmpty())
                     {
                        _loc4_ = true;
                     }
               }
            }
            if(_loc4_)
            {
               this.validateClientState();
            }
         }
      }
      
      private function validateBuiltState(param1:String) : Boolean
      {
         if(param1)
         {
            if(this.isItemBuilt(param1))
            {
               this.doValidateAction(true);
               return true;
            }
         }
         return false;
      }
      
      private function validatePlacedState(param1:String) : Boolean
      {
         if(param1)
         {
            if(this.isItemPlaced(param1))
            {
               this.doValidateAction(true);
               return true;
            }
         }
         return false;
      }
      
      private function validateQuestComplete(param1:String) : Boolean
      {
         if(param1)
         {
            if(ZGlobal.player.didCompleteQuest(param1))
            {
               this.doValidateAction(true);
               return true;
            }
         }
         return false;
      }
      
      private function validatePopCap() : Boolean
      {
         if(PopulationManager.instance.maxWorkers == PopulationManager.instance.maxWorkersCap)
         {
            this.doValidateAction(true);
            return true;
         }
         return false;
      }
      
      private function validateCampaignFleetInventoryEmpty() : Boolean
      {
         var _loc1_:StrategicMap = null;
         var _loc2_:Fleet = null;
         if(ZGlobal.player.campaign.currentMapName)
         {
            _loc1_ = ZGlobal.player.campaign.mapInProgress;
            if(_loc1_)
            {
               _loc2_ = Fleet.getFleet(_loc1_.fleets[0]);
               if(Boolean(_loc2_) && (!_loc2_.inventory || _loc2_.inventory.length == 0))
               {
                  this.doValidateAction(true);
                  return true;
               }
            }
         }
         return false;
      }
      
      private function doValidateAction(param1:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc2_:XML = this.m_data.step[this.m_index];
         if(param1)
         {
            _loc3_ = _loc2_.@validateActionTrue.toString();
         }
         else
         {
            _loc3_ = _loc2_.@validateActionFalse.toString();
         }
         switch(_loc3_)
         {
            case "advance":
               this.onAdvance();
               break;
            case "rewind":
               this.onRewind();
               break;
            case "setStep":
               this.setStep();
         }
      }
      
      private function enableAllUIElements(param1:Boolean) : void
      {
         var _loc2_:InteractiveObject = null;
         for each(_loc2_ in this.m_uiElements)
         {
            if(null != _loc2_)
            {
               _loc2_.mouseEnabled = param1;
               if(_loc2_ as DisplayObjectContainer)
               {
                  (_loc2_ as DisplayObjectContainer).mouseChildren = param1;
               }
            }
         }
      }
      
      private function onStoreClosed(param1:Event) : void
      {
         this.setArrowOnMovieClip(null);
      }
      
      private function canSendEvent(param1:String) : Boolean
      {
         var _loc2_:String = this.m_eventUIMap[param1];
         if(_loc2_)
         {
            return this.m_uiItems[_loc2_];
         }
         return true;
      }
      
      public function sendEvent(param1:String, param2:Boolean = false) : void
      {
         var _loc5_:DisplayObject = null;
         this.enableAllUIElements(false);
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         if(this.canSendEvent(param1))
         {
            switch(param1)
            {
               case UI_CAMPAIGN_SELECTOR_OPENER:
                  this.m_uiItems[UI_CAMPAIGN_SELECTOR_OPENER].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems[UI_CAMPAIGN_SELECTOR_OPENER]);
                  if(param2)
                  {
                     _loc4_ = new Point(14,15);
                     this.addStencilToUIElement(this.m_uiItems[UI_CAMPAIGN_SELECTOR_OPENER],_loc4_);
                  }
                  break;
               case UI_CAMPAIGN_SELECTOR_NEWMAP:
                  dispatchEvent(new WorldEvent(TutorialManager.CAMPAIGN_SELECTOR_HIGHLIGHT,1));
                  break;
               case UI_DOMINATION:
                  this.m_uiItems["Domination"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["Domination"]);
                  if(param2)
                  {
                     _loc4_ = new Point(30,30);
                     this.addStencilToUIElement(this.m_uiItems["Domination"],_loc4_);
                  }
                  break;
               case UI_DOMINATION_FIRST_FIGHT:
                  this.m_uiItems[DOMINATION_FIRST_FIGHT].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems[DOMINATION_FIRST_FIGHT]);
                  break;
               case UI_DOMINATION_FIRST_DEFENSE_SETUP:
                  this.m_uiItems[DOMINATION_FIRST_DEFENSE_SETUP].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems[DOMINATION_FIRST_DEFENSE_SETUP]);
                  break;
               case UI_GLOBAL_PVP:
                  this.m_uiItems["GlobalPVP"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["GlobalPVP"]);
                  if(param2)
                  {
                     _loc4_ = new Point(24,24);
                     this.addStencilToUIElement(this.m_uiItems["GlobalPVP"],_loc4_);
                  }
                  break;
               case UI_TASK:
                  if(this.m_uiItems["QuestList"])
                  {
                     this.m_uiItems["QuestList"].mouseEnabled = true;
                  }
                  break;
               case UI_STORE:
                  this.m_uiItems["Store"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["Store"]);
                  if(param2)
                  {
                     _loc4_ = new Point(20,24);
                     this.addStencilToUIElement(this.m_uiItems["Store"],_loc4_);
                  }
                  break;
               case UI_INVENTORY:
                  this.m_uiItems["Inventory"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["Inventory"]);
                  break;
               case UI_STRATMAP:
                  this.m_uiItems["StratMap"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["StratMap"]);
                  if(param2)
                  {
                     _loc4_ = new Point(30,35);
                     this.addStencilToUIElement(this.m_uiItems["StratMap"],_loc4_);
                  }
                  break;
               case UI_HOME:
                  this.m_uiItems["Home"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["Home"]);
                  if(param2)
                  {
                     _loc4_ = new Point(30,35);
                     this.addStencilToUIElement(this.m_uiItems["Home"],_loc4_);
                  }
                  break;
               case UI_COMBAT_FIGHT:
                  this.m_uiItems["CombatFight"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["CombatFight"]);
                  if(param2)
                  {
                     _loc4_ = new Point(47,48);
                     this.addStencilToUIElement(this.m_uiItems["CombatFight"],_loc4_);
                  }
                  break;
               case UI_SPECIAL_POWER:
                  this.m_uiItems["SpecialPower"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["SpecialPower"]);
                  if(param2)
                  {
                     _loc5_ = this.m_uiItems["SpecialPower"];
                     _loc4_ = new Point(33,33);
                     this.addStencilToUIElement(this.m_uiItems["SpecialPower"],_loc4_);
                  }
                  break;
               case UI_COMBAT_SETUP_NEXT:
                  this.m_uiItems["CombatSetupNext"].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems["CombatSetupNext"]);
                  if(param2)
                  {
                     _loc4_ = new Point();
                     this.addStencilToUIElement(this.m_uiItems["CombatSetupNext"],_loc4_);
                  }
                  break;
               case UI_ZOOM_IN:
                  this.enableAllUIElements(true);
                  this.m_uiItems["ZoomIn"].mouseEnabled = true;
                  _loc3_ = new Point(0,9);
                  this.setArrowOnDisplayObject(this.m_uiItems["ZoomIn"],false,-90,true,_loc3_);
                  break;
               case UI_ZOOM_OUT:
                  this.enableAllUIElements(true);
                  this.m_uiItems["ZoomOut"].mouseEnabled = true;
                  _loc3_ = new Point(0,12);
                  this.setArrowOnDisplayObject(this.m_uiItems["ZoomOut"],false,-90,true,_loc3_);
                  break;
               case UI_FULL_SCREEN:
                  this.enableAllUIElements(true);
                  this.m_uiItems["FullScreen"].mouseEnabled = true;
                  _loc3_ = new Point(0,9);
                  this.setArrowOnDisplayObject(this.m_uiItems["FullScreen"],false,-90,true,_loc3_);
                  break;
               case UI_PVP_PORTRAIT:
                  if(this.m_uiItems["PVPPortrait"])
                  {
                     this.enableAllUIElements(true);
                     this.m_uiItems["PVPPortrait"].mouseEnabled = true;
                     _loc3_ = new Point(0,-100);
                     this.setArrowOnMovieClip(this.m_uiItems["PVPPortrait"],false,false,0,_loc3_);
                     if(param2)
                     {
                        _loc4_ = new Point(0,-54);
                        this.addStencilToUIElement(this.m_uiItems["PVPPortrait"],_loc4_,0.75);
                     }
                  }
                  break;
               case UI_CLEAR_STENCIL:
                  dispatchEvent(new WorldEvent(TutorialManager.REMOVE_STENCIL));
                  break;
               case UI_DISABLE:
                  this.setArrowOnMovieClip(null);
                  break;
               case UI_ENABLE:
                  this.enableAllUIElements(true);
                  break;
               case ALLIANCE_HUD:
                  this.m_uiItems[ALLIANCE_HUD].mouseEnabled = true;
                  this.setArrowOnDisplayObject(this.m_uiItems[ALLIANCE_HUD]);
                  if(param2)
                  {
                     _loc4_ = new Point(30,20);
                     this.addStencilToUIElement(this.m_uiItems[ALLIANCE_HUD],_loc4_);
                  }
            }
         }
      }
      
      public function highlightCombatClassIcon(param1:int) : void
      {
         var _loc2_:Point = null;
         if(this.m_uiItems["CombatClassPlayerIcon" + param1])
         {
            _loc2_ = new Point(21,21);
            this.setClassHighlightOnDisplayObject(this.m_uiItems["CombatClassPlayerIcon" + param1],_loc2_);
         }
      }
      
      private function bindQuest(param1:String) : void
      {
         var _loc2_:String = null;
         if(param1 != "null")
         {
            _loc2_ = param1;
         }
         dispatchEvent(new WorldEvent(BIND_QUEST,_loc2_));
      }
      
      public function progress(param1:String, param2:Boolean = true) : void
      {
         this.m_clearArrow = param2;
         if(param1.length > 0)
         {
            this.tutorial = param1;
         }
         else
         {
            this.onProgress();
         }
      }
      
      private function onProgress() : void
      {
         ++this.m_index;
         var _loc1_:String = this.m_data.step[this.m_index].@id.toString();
         Logger.info(this,"onProgress","ADVANCING TO STEP: " + this.m_index + " STEP ID: " + _loc1_);
         if(this.m_index >= this.m_data.step.length())
         {
            this.deinit();
         }
         else
         {
            this.setupNextAction();
         }
         TransactionManager.addTransaction(new TSetTutorialProgress(_loc1_));
         if(this.isTutorialComplete())
         {
            dispatchEvent(new WorldEvent(TUTORIAL_COMPLETE));
         }
      }
      
      public function isComplete(param1:int = -1) : Boolean
      {
         if(param1 < 0)
         {
            param1 = this.m_index;
         }
         return !this.m_data || param1 >= this.m_data.step.length();
      }
      
      private function getPickString(param1:String) : String
      {
         if(param1 == "none")
         {
            return null;
         }
         return param1;
      }
      
      private function onSetLocked(param1:WorldEvent) : void
      {
         this.m_locked = this.getPickString(String(param1.eventData));
      }
      
      private function onSetUnlocked(param1:WorldEvent) : void
      {
         this.m_unlocked = this.getPickString(String(param1.eventData));
      }
      
      private function onSetTutorialUnsellable(param1:WorldEvent) : void
      {
         this.m_unsellable = this.getPickString(String(param1.eventData));
      }
      
      private function onClearUnsellable(param1:WorldEvent) : void
      {
         this.m_unsellable = null;
      }
      
      private function restoreState() : void
      {
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:TutorialStep = null;
         var _loc1_:Array = new Array("pickLock","pickUnlock","sendEvent","arrowAttach","disableStrategicMap","pauseQuestStarts","clearArrows","showBar","resumeQuestStarts","enableStrategicMap","disablePreBattleUIControls","enableIslandReturnHomeButton","clearStencil","enablePreBattleUIControls","hideCombatUI","disableStrategicMap","disableIslandReturnHomeButton","disableSpecialPowerSelectionUIControls","disableSpecialPowers","enableSpecialPowers","stencilUIItem","enableSpecialPowerSelectionUIControls","setUnsellable","clearUnsellable","showCombatUI","setPVPTutorialMode","enableCombatPauseRetreatButtons","disableUnitCardRemove","enableUnitCardRemove","enableNeighborBar","highlightPlayerClassCombatIcon","removePlayerClassCombatIcon","alwaysShowCombatClassIcon","highlightCombatUnitClassIcon","removeHighlightCombatUnitClassIcon","highlightCombatTooltipClassIcon","clearHighlightCombatTooltipClassIcon","enableSpecialPowerSelectionTooltip","lockItemPurchase","clearLockedPurchaseItems");
         this.m_restoringState = true;
         while(_loc2_ < this.m_index && _loc2_ < this.m_data.step.length())
         {
            _loc3_ = this.m_data.step[_loc2_];
            for each(_loc4_ in _loc3_.func)
            {
               if(_loc1_.indexOf(_loc4_.@name.toString()) >= 0)
               {
                  _loc5_ = new TutorialStep(_loc4_);
                  this.setupNarrator(_loc3_);
               }
            }
            _loc2_++;
         }
         this.m_restoringState = false;
      }
      
      private function restoreStateAlways() : void
      {
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:TutorialStep = null;
         var _loc1_:Array = new Array("setPVPTutorialMode");
         this.m_restoringState = true;
         while(_loc2_ < this.m_index && _loc2_ < this.m_data.step.length())
         {
            _loc3_ = this.m_data.step[_loc2_];
            for each(_loc4_ in _loc3_.func)
            {
               if(_loc1_.indexOf(_loc4_.@name.toString()) >= 0)
               {
                  _loc5_ = new TutorialStep(_loc4_);
                  this.setupNarrator(_loc3_);
               }
            }
            _loc2_++;
         }
         this.m_restoringState = false;
      }
      
      private function onUIElement(param1:WorldEvent) : void
      {
         if(Boolean(m_uiHighlighted) && m_uiHighlighted.indexOf(param1.eventData.item.code) >= 0)
         {
            this.addArrowToUIElement(param1.eventData.ui);
            m_uiHighlighted = null;
         }
         if(Boolean(m_uiStencil) && m_uiStencil.indexOf(param1.eventData.item.code) >= 0)
         {
            this.addStencilToUIElement(param1.eventData.ui);
            m_uiStencil = null;
         }
      }
      
      private function onSetUiHighlighted(param1:WorldEvent) : void
      {
         m_uiHighlighted = this.getPickString(String(param1.eventData));
      }
      
      private function onHighlightStoreTab(param1:WorldEvent) : void
      {
         if(Boolean(m_uiStoreTabIndex) && m_uiStoreTabIndex.indexOf(param1.eventData.index) >= 0)
         {
            TutorialManager.instance.addArrowToUIElement(param1.eventData.ui);
            m_uiStoreTabIndex = null;
         }
      }
      
      private function onSetStoreTabIndex(param1:WorldEvent) : void
      {
         m_uiStoreTabIndex = this.getPickString(String(param1.eventData));
      }
      
      private function onStencilElement(param1:WorldEvent) : void
      {
         m_uiStencil = this.getPickString(String(param1.eventData));
      }
      
      private function isPVPBattle() : Boolean
      {
         var _loc1_:String = ChallengeModeManager.instance.currentChallengerFleet();
         if((ChallengeModeManager.instance.isRandomFleetChallenge() || ChallengeModeManager.instance.isPVEChallenge() || ChallengeModeManager.instance.isNeighborAssist()) && !(QuestManager.getInstance() as ZGameQuestManager).isQuestPVPBattle(_loc1_))
         {
            return true;
         }
         return false;
      }
      
      private function onHighlightCombatClassTooltipIcon(param1:WorldEvent) : void
      {
         m_highlightToolTipClassIcon = param1.eventData as String;
      }
      
      private function onClearHighlightCombatClassTooltipIcon(param1:WorldEvent) : void
      {
         m_highlightToolTipClassIcon = null;
      }
   }
}

