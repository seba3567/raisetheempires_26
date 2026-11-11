package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleCampaign;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggester;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ChallengeModeManager;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.managers.RetreatManager;
   import core.managers.battleManager.BattleManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.player.Friend;
   import core.player.IPVPPlayer;
   import core.player.PlayerDummy;
   import core.ui.Style;
   import core.ui.Tooltip;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.combatbar.SpecialAbilityUnitCard;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.screens.pickConsumableScreen.CombatConsumablesScreen;
   import displays.screens.pickConsumableScreen.ConsumableSlot;
   import displays.screens.researchScreens.UpgradesDisplay;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TBuyFullHeal;
   import transactions.TInitUser;
   import transactions.TReviveUnits;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.CombatBar.CombatBarMenu;
   import zlabs.ZGameBase;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class CombatBarUIItem extends MenuItem
   {
      
      public static const ITEM_ID:String = "combatBarUIitem";
      
      public static const UPDATE_ENEMY_UNIT_STATS_DATA:String = "updateEnemyUnitStats";
      
      public static const UPDATE_PLAYER_UNIT_STATS_DATA:String = "updatePlayerUnitStats";
      
      public static const CLEAR_ENEMY_UNIT_STATS_DATA:String = "clearEnemyUnitStats";
      
      public static const CLEAR_PLAYER_UNIT_STATS_DATA:String = "clearPlayerUnitStats";
      
      public static const SET_HIT_PERCENTAGES:String = "setHitPercentages";
      
      public static const CLEAR_HIT_PERCENTAGES:String = "clearHitPercentages";
      
      public static const STARTUP_DATA:String = "startupData";
      
      private static const TRACK_SUGGESTION_COUNTER:String = "dialog";
      
      private static const TRACK_SUGGESTION_KINGDOM:String = "recommend_consumable";
      
      private static const TRACK_SUGGESTION_REVIVE_KINGDOM:String = "recommend_revive";
      
      private static const TRACK_SUGGESTION_PHYLUM_VIEW:String = "view";
      
      private static const TRACK_SUGGESTION_PHYLUM_CLICK:String = "click";
      
      private static const TRACK_SUGGESTION_ZCLASS_BUY:String = "buy";
      
      private static const TRACK_SUGGESTION_ZCLASS_USE:String = "use";
      
      private static const TRACK_SUGGESTION_ZCLASS_CLOSE:String = "close";
      
      private static const MESSAGE_TAB_MARGIN:int = 167;
      
      private var m_bar:CombatBarMenu = null;
      
      private var m_parent:MenuItem = null;
      
      private var m_active:Boolean = false;
      
      private var m_fleet:Fleet = null;
      
      private var m_specialAbilityUnitCard:SpecialAbilityUnitCard = null;
      
      private var m_availableSpecialPowers:Array = null;
      
      private var m_currentSpecialPowerIndex:int = 0;
      
      private var m_tutorialHidden:Boolean = false;
      
      private var m_powersDisabled:Boolean = false;
      
      private var m_cachedTypes:Dictionary = null;
      
      private var m_cachedAgainsts:Dictionary = null;
      
      private var m_allowSpecialPower:Boolean = false;
      
      private var m_specialPowersOn:Boolean = false;
      
      private var m_specialPowerControlsOff:Boolean = false;
      
      private var m_enablePauseRetreat:Boolean = true;
      
      private var m_enableReviveUnits:Boolean = false;
      
      private var m_tutorialEnablePauseRetreat:Boolean = true;
      
      private var m_playerIcons:Array = null;
      
      private var m_enemyIcons:Array = null;
      
      private var m_playerItem:UnitItem = null;
      
      private var m_enemyItem:UnitItem = null;
      
      private var m_playerUpgradesDisplay:UpgradesDisplay = null;
      
      private var m_enemyUpgradesDisplay:UpgradesDisplay = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_hideSuggesterForRestOfBattle:Boolean;
      
      private var m_hideSuggesterForRestOfTurn:Boolean;
      
      private var m_isFirstRound:Boolean;
      
      private var m_iconLoaders:Array;
      
      private var m_shouldShow:Boolean;
      
      private var m_isReviveShown:Boolean;
      
      private var m_reviveTurnsLeft:int = 0;
      
      private var m_suggestedConsumable:ConsumableItem;
      
      private var m_fullHeal:HealAll_mc;
      
      private var m_fullHealBuyBt:ZGameButton;
      
      private var m_fullHealBt:ZGameButton;
      
      private var m_fullHealExitBt:ZGameButton;
      
      private var m_fullHealPrice:Number;
      
      private var m_lastUnitLost:UnitItem;
      
      private var m_messageTab:FriendsBarMessageTabUIItem = null;
      
      private var m_fullHealVariant:Number = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIEMNT_FULL_HEALER);
      
      public function CombatBarUIItem(param1:MenuItem)
      {
         super(ITEM_ID);
         this.m_bar = new CombatBarMenu();
         this.m_cachedTypes = new Dictionary();
         this.m_cachedAgainsts = new Dictionary();
         this.m_parent = param1;
         addChild(this.m_bar);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_bar.enemy_unit_card_mc.deselect.visible = false;
         this.m_bar.player_unit_card_mc.deselect.visible = false;
         param1.addEventListener(ContextualBarUIItem.ADD_COMBAT_EVENT,this.onCombatEvent);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurnStarts);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SEQUENCE_STARTED,this.onPlayerTurnEnds);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_RESUME,this.onResume);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PRE_START,this.onPreStart);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CANCELED,this.onSpecialAbilityCanceled);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_RANSOM_PAID,this.onRansomPaid);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_RANSOM_CANCELLED,this.onRansomCancelled);
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_HIDE_UI,this.onHideCombatUI);
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_SHOW_UI,this.onShowCombatUI);
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_DISABLE_SPECIAL_POWERS,this.onDisableSpecialPowers);
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_ENABLE_SPECIAL_POWERS,this.onEnableSpecialPowers);
         TutorialManager.instance.addEventListener(TutorialManager.DISABLE_SPECIAL_POWER_SELECTION_CONTROLS,this.onDisableSpecialPowerControls);
         TutorialManager.instance.addEventListener(TutorialManager.ENABLE_SPECIAL_POWER_SELECTION_CONTROLS,this.onEnableSpecialPowerControls);
         TutorialManager.instance.addEventListener(TutorialManager.ENABLE_COMBAT_PAUSE_RETREAT,this.onTutorialEnablePauseRetreatButtons);
         TutorialManager.instance.addEventListener(TutorialManager.ADD_STENCIL,this.onStencilAdded);
         TutorialManager.instance.addEventListener(TutorialManager.REMOVE_STENCIL,this.onStencilRemoved);
         UIManager.instance.addEventListener(UIManager.UI_ENABLE_COMBAT_PAUSE_RETREAT,this.onEnablePauseRetreatButtons);
         TutorialManager.instance.addToUIElements(this.m_bar.exit_bt);
         TutorialManager.instance.addToUIElements(this.m_bar.consumable_bt.deploy_bt);
         TutorialManager.instance.addToUIElements(this.m_bar.pause);
         TutorialManager.instance.registerUIItem(this.m_bar.consumable_bt,"SpecialPower");
         TutorialManager.instance.registerUIItem(this.m_bar.player_unit_card_mc.against_mc.icon0,"CombatClassPlayerIcon1");
         TutorialManager.instance.registerUIItem(this.m_bar.player_unit_card_mc.against_mc.icon1,"CombatClassPlayerIcon2");
         TutorialManager.instance.registerUIItem(this.m_bar.player_unit_card_mc.against_mc.icon2,"CombatClassPlayerIcon3");
         this.m_bar.exit_bt.addEventListener(MouseEvent.CLICK,this.onRetreatClicked);
         Tooltip.subscribe(this.m_bar.exit_bt,ZGameUtils.ZlocT("Tooltips","CombatBar_retreat"));
         this.m_buttonSounds.addButton(this.m_bar.exit_bt,ButtonSound.DEFAULT);
         this.m_bar.pause.addEventListener(MouseEvent.CLICK,this.onPauseClicked);
         Tooltip.subscribe(this.m_bar.pause,ZGameUtils.ZlocT("Tooltips","CombatBar_pause"));
         this.m_buttonSounds.addButton(this.m_bar.pause,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.m_bar.player_unit_card_mc.bonusAgainst_tf,ZGameUtils.ZlocT("Dialogs","CombatCardGoodAgainst"));
         TextFieldUtil.processTextField(this.m_bar.enemy_unit_card_mc.bonusAgainst_tf,ZGameUtils.ZlocT("Dialogs","CombatCardGoodAgainst"));
         ZGameUtils.hideIfExists(this.m_bar.player_unit_card_mc.enemyAbility_mc);
         ZGameUtils.hideIfExists(this.m_bar.player_unit_card_mc.secondaryAbility_mc);
         this.setSpecialPowerMode(false);
         this.m_bar.messageTab_mc.visible = false;
         if(TInitUser.initComplete)
         {
            this.initMessageTab();
         }
         else
         {
            UIDispatcher.instance.addEventListener(TInitUser.EVENT_COMPLETE,this.experimentsAdded);
         }
      }
      
      override public function get height() : Number
      {
         return this.m_bar.player_profile_card_mc.height + 24;
      }
      
      override public function removeItem() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_bar.exit_bt.removeEventListener(MouseEvent.CLICK,this.onRetreatClicked);
         Tooltip.unsubscribe(this.m_bar.exit_bt);
         Tooltip.unsubscribe(this.m_bar.consumable_bt);
         this.m_bar = null;
         this.m_parent.removeEventListener(ContextualBarUIItem.ADD_COMBAT_EVENT,this.onCombatEvent);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurnStarts);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SEQUENCE_STARTED,this.onPlayerTurnEnds);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RESUME,this.onResume);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PRE_START,this.onPreStart);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CANCELED,this.onSpecialAbilityCanceled);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RANSOM_PAID,this.onRansomPaid);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RANSOM_CANCELLED,this.onRansomCancelled);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_HIDE_UI,this.onHideCombatUI);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_SHOW_UI,this.onShowCombatUI);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_DISABLE_SPECIAL_POWERS,this.onDisableSpecialPowers);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_ENABLE_SPECIAL_POWERS,this.onEnableSpecialPowers);
         UIManager.instance.removeEventListener(UIManager.UI_ENABLE_COMBAT_PAUSE_RETREAT,this.onEnablePauseRetreatButtons);
         this.clearPlayerIcons();
         this.clearEnemyIcons();
         this.clearUpgradeDisplays();
      }
      
      private function onResume(param1:Event) : void
      {
         this.m_isFirstRound = false;
      }
      
      private function onPreStart(param1:Event) : void
      {
         this.m_isFirstRound = true;
      }
      
      public function initFullHealer() : void
      {
         if(this.m_fullHeal == null)
         {
            this.m_fullHeal = new HealAll_mc();
            TextFieldUtil.compactTextField(this.m_fullHeal.panel_mc.title_tf,ZGameUtils.ZlocT("Dialogs","FullHealerHeader"));
            TextFieldUtil.compactTextField(this.m_fullHeal.panel_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","FullHealerDesc"));
            this.m_fullHeal.healAll_bt.addEventListener(MouseEvent.MOUSE_OVER,this.fullHealBtClicked);
            this.m_fullHeal.visible = false;
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,this.updateFullHealer);
            this.m_fullHealBuyBt = new ZGameButton(this.m_fullHeal.panel_mc.buy_bt,this.fullHealBuyClicked);
            this.m_fullHeal.panel_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.fullHealExitClicked);
            this.m_fullHeal.panel_mc.addEventListener(MouseEvent.ROLL_OUT,this.fullHealExitClicked);
            ZGameBase.layerPopUp.addChild(this.m_fullHeal);
            this.m_fullHeal.x = this.x;
            this.m_fullHeal.y = Zlab.mainStage.stageHeight - this.height - this.m_fullHeal.height;
            UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.positionFullHealer,false,0,true);
         }
      }
      
      private function positionFullHealer(param1:RepositionEvent) : void
      {
         this.m_fullHeal.x = this.x;
         this.m_fullHeal.y = Zlab.mainStage.stageHeight - this.height - this.m_fullHeal.height;
      }
      
      private function calculateNumberOfHealsRequired() : Number
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:UnitItem = null;
         var _loc10_:BattleObject = null;
         var _loc11_:Number = NaN;
         var _loc1_:Battle = ZGameStats.currentBattle;
         var _loc2_:Array = _loc1_.playerGroup;
         var _loc3_:Array = new Array();
         var _loc7_:Number = 0;
         var _loc8_:ConsumableItem = BattleManager.instance.powerItem;
         var _loc9_:Number = Math.abs(_loc8_.di);
         for each(_loc10_ in _loc2_)
         {
            if(!_loc10_.dead)
            {
               _loc11_ = _loc10_.unitItem.getStrength(_loc10_.fleet) - _loc10_.unit.strength;
               _loc7_ += Math.ceil(_loc11_ / _loc9_);
            }
         }
         return _loc7_;
      }
      
      private function get healerCost() : Number
      {
         var _loc1_:ConsumableItem = BattleManager.instance.powerItem;
         return _loc1_.cash;
      }
      
      private function damagedEnoughToShowPowerButton(param1:BattleObject) : Boolean
      {
         var _loc2_:Number = BattleManager.instance.powerButtonHealPercent;
         if(_loc2_ > 0 && param1.unit.strength > 0)
         {
            if(param1.unit.strength < param1.unitItem.getStrength(param1.fleet) * _loc2_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getshowHeal() : Boolean
      {
         var _loc3_:BattleObject = null;
         var _loc1_:Battle = ZGameStats.currentBattle;
         var _loc2_:Array = _loc1_.playerGroup;
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.dead)
            {
               if(this.damagedEnoughToShowPowerButton(_loc3_))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function updateFullHealer(param1:WorldEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         if(Boolean(param1.eventData.active) && param1.eventData.active == true)
         {
            _loc2_ = this.calculateNumberOfHealsRequired();
            _loc3_ = this.getshowHeal();
            if(_loc2_ == 0 || !_loc3_)
            {
               this.m_fullHeal.visible = false;
            }
            else
            {
               this.m_fullHealPrice = _loc2_ * this.healerCost;
               TextFieldUtil.compactTextField(this.m_fullHeal.panel_mc.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","FullHealerButton",{"total":this.m_fullHealPrice}));
               this.m_fullHeal.visible = true;
               this.m_fullHeal.healAll_bt.visible = true;
               this.m_fullHeal.panel_mc.visible = false;
            }
         }
         else
         {
            this.m_fullHeal.visible = false;
         }
      }
      
      private function fullHealBtClicked(param1:MouseEvent) : void
      {
         this.m_fullHeal.panel_mc.visible = true;
      }
      
      private function fullHealExitClicked(param1:MouseEvent) : void
      {
         this.m_fullHeal.panel_mc.visible = false;
      }
      
      private function clearFullHealDisplay() : void
      {
         if(this.m_fullHealBt)
         {
            this.m_fullHealBt.dispose();
            this.m_fullHealBt = null;
         }
         if(this.m_fullHealBuyBt)
         {
            this.m_fullHealBuyBt.dispose();
            this.m_fullHealBuyBt = null;
         }
         if(this.m_fullHealBuyBt)
         {
            this.m_fullHealBuyBt.dispose();
            this.m_fullHealBuyBt = null;
         }
         if(Boolean(this.m_fullHeal) && ZGameBase.layerPopUp.contains(this.m_fullHeal))
         {
            ZGameBase.layerPopUp.removeChild(this.m_fullHeal);
            this.m_fullHeal.panel_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.fullHealExitClicked);
            this.m_fullHeal.panel_mc.removeEventListener(MouseEvent.ROLL_OUT,this.fullHealExitClicked);
         }
         this.m_fullHeal = null;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,this.updateFullHealer);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.positionFullHealer);
      }
      
      private function fullHealBuyClicked(param1:MouseEvent) : void
      {
         if(ZGlobal.player.canBuyCash(this.m_fullHealPrice,false,"",false))
         {
            this.buyPower();
            this.m_fullHeal.visible = false;
            StatsManager.count("Healer","Click");
         }
         else
         {
            PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash"),GenericPopup.TYPE_OK),0,false);
         }
         this.fullHealExitClicked(param1);
      }
      
      private function buyPower() : void
      {
         var _loc4_:BattleObject = null;
         var _loc5_:BattleObject = null;
         var _loc15_:UnitItem = null;
         var _loc1_:Battle = ZGameStats.currentBattle;
         var _loc2_:String = "";
         var _loc3_:Array = _loc1_.playerGroup;
         for each(_loc5_ in _loc3_)
         {
            if(!_loc5_.unit.dead)
            {
               _loc4_ = _loc5_;
            }
         }
         if(_loc4_)
         {
            _loc15_ = _loc4_.unitItem;
            if(_loc15_)
            {
               _loc2_ = _loc15_.code;
            }
         }
         var _loc6_:int = Battle.BATTLE_STATE_ACTIVE;
         var _loc7_:Boolean = _loc1_ is BattleCampaign;
         var _loc8_:Boolean = _loc1_.isQuestTreeBattle;
         var _loc9_:Boolean = _loc1_.isQuestSurvival;
         var _loc10_:Boolean = _loc1_.isDeathMatchBattle;
         var _loc11_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(ConsumableItem.HEAL_ALL_ITEM_CODE,ConsumableItem) as ConsumableItem;
         var _loc12_:Object = {
            "combatPhase":_loc6_,
            "deathmatch":_loc10_,
            "inCampaign":_loc7_,
            "isQuestSurvival":_loc9_,
            "unitCode":_loc2_,
            "gpvp":PVPManager.instance.isVisitGlobalPVP(),
            "questTree":_loc8_
         };
         ZGlobal.player.buyGameItem(_loc11_,true,1,_loc12_);
         var _loc13_:String = _loc4_.fleet.name;
         var _loc14_:TBuyFullHeal = new TBuyFullHeal(this.m_fullHealPrice,_loc13_);
         TransactionManager.addTransaction(_loc14_,true);
         ZGlobal.player.cash -= this.m_fullHealPrice;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,{"consumableItem":_loc11_}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_UNIT_CLICKED,_loc4_));
      }
      
      public function get active() : Boolean
      {
         return this.m_active;
      }
      
      public function set active(param1:Boolean) : void
      {
         if(!param1 && this.m_active)
         {
            this.allowSpecialPowerSelection(false);
            this.disposeConsumableSuggestionUI();
            this.disposeSpecialAbilityUnitCard();
         }
         else if(param1 == true && this.m_active == false)
         {
            this.initConsumableSuggestionUI();
         }
         this.m_active = param1;
      }
      
      private function onPlayerTurnStarts(param1:Event) : void
      {
         this.allowSpecialPowerSelection(true);
      }
      
      private function onPlayerTurnEnds(param1:Event) : void
      {
         this.allowSpecialPowerSelection(false);
         this.hideAllSuggestionUI();
         if(this.m_reviveTurnsLeft <= 0)
         {
            this.hideReviveSuggestionUI();
         }
         else
         {
            --this.m_reviveTurnsLeft;
         }
         if(this.m_isFirstRound == true)
         {
            this.m_isFirstRound = false;
         }
         this.m_hideSuggesterForRestOfTurn = false;
      }
      
      private function onUnitKilled(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = param1.eventData.target as BattleObject;
         if(this.m_enableReviveUnits)
         {
            if(_loc2_.fleet.numUnits > 0)
            {
               if(_loc2_.fleet == this.m_fleet)
               {
                  this.m_fleet.lastUnitLost = _loc2_.unitItem.code;
                  this.m_lastUnitLost = _loc2_.unitItem;
                  Zlab.processManager.schedule(250,this,this.showReviveToaster);
               }
            }
            else
            {
               this.hideReviveSuggestionUI();
            }
         }
      }
      
      private function showReviveToaster() : void
      {
         this.hideAllSuggestionUI();
         this.m_isReviveShown = true;
         this.m_reviveTurnsLeft = 2;
         this.showReviveSuggestionUI(true);
         this.displayReviveSuggestionText(ZGameUtils.ZlocT("Combat","ReviveUnitSuggestionMessage"),"Revive Unit");
      }
      
      private function onConsumableSuggested(param1:WorldEvent) : void
      {
         var _loc2_:ConsumableItem = null;
         if(this.m_isReviveShown)
         {
            return;
         }
         if(param1.eventData != null && (param1.eventData as IConsumableSuggestion).forceIfSuggested == true && this.m_shouldShow || this.m_hideSuggesterForRestOfBattle == false && this.m_hideSuggesterForRestOfTurn == false && this.m_isFirstRound == false && this.m_shouldShow && (this.m_suggestedConsumable == null || this.m_suggestedConsumable.code != (param1.eventData as IConsumableSuggestion).consumableCode))
         {
            if((param1.eventData as IConsumableSuggestion).consumableCode != AbstractConsumableSuggestionAlgorithm.NO_CONSUMABLE_SUGGESTABLE)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode((param1.eventData as IConsumableSuggestion).consumableCode,ConsumableItem) as ConsumableItem;
               this.m_suggestedConsumable = _loc2_;
               this.showPowerUpSuggestionUI(true);
               this.displaySuggestionText(ZGameUtils.ZlocT("Combat",(param1.eventData as IConsumableSuggestion).consumableMessage,{"consumable":_loc2_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)}),_loc2_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME));
               if(this.m_isFirstRound == false && (ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT_EVERY_OTHER_TURN || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_EVERY_OTHER_TURN))
               {
                  this.m_shouldShow = !this.m_shouldShow;
               }
            }
         }
         else
         {
            this.m_shouldShow = true;
         }
      }
      
      private function onConsumableClicked(param1:WorldEvent) : void
      {
         this.setSpecialPowerMode(true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onPlayerTurnEnds);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_UNIT_CLICKED,this.onPlayerTurnEnds);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,{"consumableItem":param1.eventData}));
         this.listenForConsumableClick(false);
      }
      
      private function onSpecialAbilityCanceled(param1:Event) : void
      {
         this.cancelConsumable();
      }
      
      private function initConsumableSuggestionUI() : void
      {
         BattleDispatcher.instance.addEventListener(ConsumableSuggester.CONSUMABLE_SUGGESTED,this.onConsumableSuggested);
         this.hideAllSuggestionUI();
         this.hideReviveSuggestionUI();
         this.m_hideSuggesterForRestOfBattle = false;
         this.m_hideSuggesterForRestOfTurn = false;
         this.m_isFirstRound = true;
         this.m_shouldShow = true;
         this.m_bar.redHaloGlow_mc.mouseChildren = false;
         this.m_bar.redHaloGlow_mc.mouseEnabled = false;
         this.m_bar.powerUpSuggesterBig_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onSuggestionUIExitClick,false,0,true);
         this.m_bar.unitReviveToaster_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onReviveSuggestionUIExitClick,false,0,true);
      }
      
      private function disposeConsumableSuggestionUI() : void
      {
         var _loc1_:ImageLoader = null;
         BattleDispatcher.instance.removeEventListener(ConsumableSuggester.CONSUMABLE_SUGGESTED,this.onConsumableSuggested);
         this.hideAllSuggestionUI();
         this.hideReviveSuggestionUI();
         this.m_bar.powerUpSuggesterBig_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onSuggestionUIExitClick);
         this.m_bar.powerUpSuggesterBig_mc.accept_bt.removeEventListener(MouseEvent.CLICK,this.onClickBuySuggestedConsumable);
         this.m_bar.unitReviveToaster_mc.use_bt.removeEventListener(MouseEvent.CLICK,this.onClickShowRevivePopup);
         this.m_bar.unitReviveToaster_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onReviveSuggestionUIExitClick);
         for each(_loc1_ in this.m_iconLoaders)
         {
            _loc1_.destroy();
         }
         this.m_iconLoaders = null;
         this.m_suggestedConsumable == null;
      }
      
      private function onClickBuySuggestedConsumable(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(ZGlobal.player.getNumberOfInventoryItems(this.m_suggestedConsumable.code) == 0)
         {
            if(ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
            {
               _loc2_ = "combat_gpvp";
            }
            else if(ChallengeModeManager.instance.isInChallengeBattle() == false && ChallengeModeManager.instance.isPVEChallenge() == false)
            {
               _loc2_ = "combat_pvp";
            }
            else
            {
               _loc2_ = "combat_pve";
            }
            ZGlobal.player.buyPremiumGameItem(this.m_suggestedConsumable,true,false,{
               "combatType":_loc2_,
               "buyType":"recommend_consumable"
            },this.onSuggestionItemPurchased);
            StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_KINGDOM,TRACK_SUGGESTION_PHYLUM_CLICK,TRACK_SUGGESTION_ZCLASS_BUY,this.m_suggestedConsumable.code);
            StatsManager.count("game_actions","combat","buy_consumable_combat","combat",this.m_suggestedConsumable.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         }
         else
         {
            this.onConsumableClicked(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.m_suggestedConsumable));
            StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_KINGDOM,TRACK_SUGGESTION_PHYLUM_CLICK,TRACK_SUGGESTION_ZCLASS_USE,this.m_suggestedConsumable.code);
         }
      }
      
      private function onSuggestionItemPurchased(param1:Object = null) : void
      {
         this.displaySuggestionText();
         StatsManager.economy(this.m_suggestedConsumable.cash,"empirepoint","true_spend","combat","consumable",this.m_suggestedConsumable.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.onConsumableClicked(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.m_suggestedConsumable));
      }
      
      private function onSuggestionUIExitClick(param1:MouseEvent) : void
      {
         this.m_hideSuggesterForRestOfTurn = true;
         this.hideAllSuggestionUI();
         this.cancelConsumable();
         if(this.m_suggestedConsumable)
         {
            StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_KINGDOM,TRACK_SUGGESTION_PHYLUM_CLICK,TRACK_SUGGESTION_ZCLASS_CLOSE,this.m_suggestedConsumable.code);
         }
      }
      
      private function onReviveSuggestionUIExitClick(param1:MouseEvent) : void
      {
         this.m_hideSuggesterForRestOfTurn = true;
         this.hideReviveSuggestionUI();
         if(this.m_lastUnitLost)
         {
            StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_REVIVE_KINGDOM,TRACK_SUGGESTION_PHYLUM_CLICK,TRACK_SUGGESTION_ZCLASS_CLOSE,this.m_lastUnitLost.code);
         }
      }
      
      private function hideReviveSuggestionUI() : void
      {
         this.m_bar.unitReviveToaster_mc.visible = false;
         this.m_isReviveShown = false;
         this.m_reviveTurnsLeft = 0;
      }
      
      private function hideAllSuggestionUI() : void
      {
         this.m_bar.powerUpSuggesterBig_mc.visible = false;
         this.hideRedHaloGlow();
      }
      
      private function showPowerUpSuggestionUI(param1:Boolean) : void
      {
         if(this.m_isReviveShown)
         {
            return;
         }
         if(param1)
         {
            this.m_bar.powerUpSuggesterBig_mc.visible = true;
         }
      }
      
      private function showReviveSuggestionUI(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_bar.unitReviveToaster_mc.visible = true;
         }
      }
      
      private function displayReviveSuggestionText(param1:String = null, param2:String = null) : void
      {
         if(param1 != null && param2 != null)
         {
            TextFieldUtil.processTextField(this.m_bar.unitReviveToaster_mc.description_tf,param1);
            TextFieldUtil.processTextField(this.m_bar.unitReviveToaster_mc.itemName_tf,param2);
         }
         this.m_bar.unitReviveToaster_mc.icon96_mc.visible = false;
         this.m_bar.unitReviveToaster_mc.icon48_mc.star_mc.visible = false;
         var _loc3_:ZGameButton = new ZGameButton(this.m_bar.unitReviveToaster_mc.use_bt,this.onClickShowRevivePopup);
         var _loc4_:int = this.m_lastUnitLost.getModifiedCash(BattleManager.instance.reviveUnitMultiplier());
         _loc3_.text = ZLoc.t("Combat","ReviveUnitBuyButton",{"amount":_loc4_.toString()});
         if(this.m_iconLoaders == null)
         {
            this.m_iconLoaders = [];
         }
         var _loc5_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_lastUnitLost.name,"icon"),this.m_bar.unitReviveToaster_mc.icon48_mc.icon);
         _loc5_.smooth = true;
         this.m_iconLoaders.push(_loc5_);
         StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_REVIVE_KINGDOM,TRACK_SUGGESTION_PHYLUM_VIEW,TRACK_SUGGESTION_ZCLASS_BUY,this.m_lastUnitLost.code);
      }
      
      private function onClickShowRevivePopup(param1:MouseEvent) : void
      {
         this.hideReviveSuggestionUI();
         StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_REVIVE_KINGDOM,TRACK_SUGGESTION_PHYLUM_CLICK,TRACK_SUGGESTION_ZCLASS_BUY,this.m_lastUnitLost.code);
         if(ZGlobal.player.reviveItems([this.m_lastUnitLost]))
         {
            TransactionManager.addTransaction(new TReviveUnits([this.m_lastUnitLost.code],this.m_fleet.name),true);
            this.m_fleet.reviveUnits([this.m_lastUnitLost.code]);
            this.m_lastUnitLost = null;
            this.m_fleet.lastUnitLost = null;
         }
      }
      
      private function displaySuggestionText(param1:String = null, param2:String = null) : void
      {
         if(param1 != null && param2 != null)
         {
            TextFieldUtil.processTextField(this.m_bar.powerUpSuggesterBig_mc.talkBubble_tf,param1);
            TextFieldUtil.processTextField(this.m_bar.powerUpSuggesterBig_mc.itemName_tf,param2);
         }
         var _loc3_:int = ZGlobal.player.getNumberOfInventoryItems(this.m_suggestedConsumable.code);
         this.m_bar.powerUpSuggesterBig_mc.badge_mc.counter_tf.text = _loc3_;
         var _loc4_:ZGameButton = new ZGameButton(this.m_bar.powerUpSuggesterBig_mc.accept_bt,this.onClickBuySuggestedConsumable);
         if(_loc3_ == 0)
         {
            StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_KINGDOM,TRACK_SUGGESTION_PHYLUM_VIEW,TRACK_SUGGESTION_ZCLASS_BUY,this.m_suggestedConsumable.code);
            if(this.m_bar.powerUpSuggesterBig_mc.accept_bt.generic_tf)
            {
               _loc4_.text = ZLoc.t("Dialogs","BuyForAmount",{"amount":this.m_suggestedConsumable.cash});
               this.m_bar.powerUpSuggesterBig_mc.accept_bt.points_mc.visible = true;
               if(ZGlobal.player.cash < this.m_suggestedConsumable.cash)
               {
                  _loc4_.textColor = Style.COLOR_UNSUFFICIENT_RESOURCES;
               }
            }
         }
         else
         {
            this.showRedHaloGlow();
            if(this.m_bar.powerUpSuggesterBig_mc.accept_bt.generic_tf)
            {
               this.m_bar.powerUpSuggesterBig_mc.accept_bt.points_mc.visible = false;
               _loc4_.text = ZLoc.t("Dialogs","Use",{});
               _loc4_.textColor = Style.COLOR_SUFFICIENT_FUNDS;
            }
            StatsManager.count(TRACK_SUGGESTION_COUNTER,TRACK_SUGGESTION_KINGDOM,TRACK_SUGGESTION_PHYLUM_VIEW,TRACK_SUGGESTION_ZCLASS_USE,this.m_suggestedConsumable.code);
         }
         if(this.m_iconLoaders == null)
         {
            this.m_iconLoaders = [];
         }
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_suggestedConsumable.name,"icon"),this.m_bar.powerUpSuggesterBig_mc.icon));
      }
      
      private function showRedHaloGlow() : void
      {
         this.m_bar.redHaloGlow_mc.visible = true;
         this.m_bar.redHaloGlow_mc.play();
      }
      
      private function hideRedHaloGlow() : void
      {
         this.m_bar.redHaloGlow_mc.visible = false;
         this.m_bar.redHaloGlow_mc.stop();
      }
      
      private function clear() : void
      {
         this.m_bar.player_profile_card_mc.name_tf.text = "";
         this.m_bar.player_profile_card_mc.level_tf.text = "";
         this.m_bar.player_profile_card_mc.icon.unload();
         this.clearPlayerIcons();
         this.m_bar.enemy_profile_card_mc.name_tf.text = "";
         this.m_bar.enemy_profile_card_mc.level_tf.text = "";
         this.m_bar.enemy_profile_card_mc.icon.unload();
         this.clearEnemyIcons();
         this.clearUpgradeDisplays();
         this.clearFullHealDisplay();
         this.m_playerItem = null;
         this.m_enemyItem = null;
      }
      
      private function clearUpgradeDisplays() : void
      {
         if(this.m_playerUpgradesDisplay)
         {
            this.m_playerUpgradesDisplay.dispose();
            this.m_playerUpgradesDisplay = null;
         }
         if(this.m_enemyUpgradesDisplay)
         {
            this.m_enemyUpgradesDisplay.dispose();
            this.m_enemyUpgradesDisplay = null;
         }
      }
      
      private function onPauseClicked(param1:MouseEvent) : void
      {
         this.clear();
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_PAUSE,{"inPreBattle":false}));
      }
      
      private function onRetreatClicked(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:uint = 0;
         if(DominationModeManager.instance.isInDominationBattle())
         {
            RetreatManager.instance.resolveDominationRetreat();
            return;
         }
         var _loc2_:Boolean = false;
         var _loc3_:uint = uint(ExperimentsManager.instance.getExperimentVariant(SurvivalModeManager.EXPERIMENT_SURVIVALMODE_RETREAT));
         if(SurvivalModeManager.instance.isInSurvivalBattle() && _loc3_ == SurvivalModeManager.RETREAT_VARIANT_PENALTY_ON)
         {
            _loc2_ = true;
         }
         if(!_loc2_ && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RETREAT_COST_MASTER) == ExperimentsManager.VARIANT_VALUE_RETREAT_COST_MASTER_ENABLED)
         {
            RetreatManager.instance.resolveRetreat();
         }
         else
         {
            _loc4_ = "CombatRetreatCheck";
            _loc5_ = uint(ExperimentsManager.instance.getExperimentVariant(SurvivalModeManager.EXPERIMENT_SURVIVALMODE_RETREAT));
            if(_loc5_ == SurvivalModeManager.RETREAT_VARIANT_PENALTY_ON && SurvivalModeManager.instance.isInSurvivalBattle())
            {
               _loc4_ = "CombatSurvivalRetreatCheck";
            }
            PopupManager.instance.push(GenericPopup2B.NewYesNo(ZGameUtils.ZlocT("Dialogs",_loc4_),null,this.onRetreatCheck));
         }
      }
      
      private function onRansomPaid(param1:Event) : void
      {
         this.endCombat();
      }
      
      private function onRansomCancelled(param1:Event) : void
      {
      }
      
      private function onRetreatCheck(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.endCombat();
         }
      }
      
      private function endCombat() : void
      {
         this.clear();
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RETREAT));
      }
      
      private function onSpecialPowerClicked(param1:MouseEvent) : void
      {
         if(this.m_bar.consumable_bt.currentFrame == 1)
         {
            CombatConsumablesScreen.display(this,this.m_specialPowerControlsOff);
         }
         else
         {
            this.cancelConsumable();
         }
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_SPECIAL_POWER_CLICKED));
         }
      }
      
      private function cancelConsumable() : void
      {
         this.setSpecialPowerMode(false);
         this.setSpecialPowersEnabled(false);
         this.onPlayerTurnStarts(null);
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_CANCEL_CONSUMABLE));
      }
      
      private function getType(param1:String) : String
      {
         if(null == this.m_cachedTypes[param1])
         {
            this.m_cachedTypes[param1] = ZGameUtils.ZlocT("Items","CombatBarUnitType",{"type":param1});
         }
         return this.m_cachedTypes[param1];
      }
      
      private function getGoodAgainst(param1:String) : String
      {
         if(null == this.m_cachedAgainsts[param1])
         {
            if(null != param1)
            {
               this.m_cachedAgainsts[param1] = ZGameUtils.ZlocT("Items","CombatBarUnitAgainst",{"type":param1});
            }
            else
            {
               this.m_cachedAgainsts[param1] = "";
            }
         }
         return this.m_cachedAgainsts[param1];
      }
      
      private function onCombatEvent(param1:WorldEvent) : void
      {
         var _loc2_:UnitItem = null;
         var _loc3_:ImageLoader = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         if(param1.eventData != null)
         {
            if(param1.eventData.type == UPDATE_ENEMY_UNIT_STATS_DATA || param1.eventData.type == UPDATE_PLAYER_UNIT_STATS_DATA)
            {
               _loc2_ = null;
               if(param1.eventData.type == UPDATE_PLAYER_UNIT_STATS_DATA)
               {
                  TextFieldUtil.processTextField(this.m_bar.player_unit_card_mc.my_unit_title_tf,param1.eventData.playerUnitName);
                  this.m_bar.player_unit_card_mc.deselect.visible = false;
                  _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.playerUnitCode,UnitItem) as UnitItem;
                  this.m_bar.player_unit_card_mc.upgrades_mc.visible = true;
                  if(_loc2_ != null && _loc2_ != this.m_playerItem)
                  {
                     this.m_playerItem = _loc2_;
                     _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("icon").url,this.m_bar.player_unit_card_mc.icon);
                     _loc3_.reverse = true;
                     this.clearPlayerIcons(true);
                     if(_loc2_.secondaryAbility)
                     {
                        this.populateSecondaryAbility(_loc2_,this.m_bar.player_unit_card_mc);
                     }
                     else
                     {
                        this.populateGoodAgainstIcons(_loc2_,this.m_bar.player_unit_card_mc,this.m_playerIcons,false);
                     }
                     if(!this.m_playerUpgradesDisplay)
                     {
                        _loc4_ = [this.m_bar.player_unit_card_mc.upgrades_mc.icon0,this.m_bar.player_unit_card_mc.upgrades_mc.icon1,this.m_bar.player_unit_card_mc.upgrades_mc.icon2,this.m_bar.player_unit_card_mc.upgrades_mc.icon3,this.m_bar.player_unit_card_mc.upgrades_mc.icon4];
                        this.m_playerUpgradesDisplay = new UpgradesDisplay(_loc4_,this.m_bar.player_unit_card_mc.upgrades_mc,this.m_bar.player_unit_card_mc.tooltip,this.m_bar,this.m_playerItem,param1.eventData.playerUnitUpgrades[this.m_playerItem.code]);
                     }
                     else if(this.m_playerUpgradesDisplay.unitItem != this.m_playerItem)
                     {
                        this.m_playerUpgradesDisplay.setUnitItem(this.m_playerItem,param1.eventData.playerUnitUpgrades[this.m_playerItem.code]);
                     }
                  }
               }
               if(param1.eventData.type == UPDATE_ENEMY_UNIT_STATS_DATA)
               {
                  TextFieldUtil.processTextField(this.m_bar.enemy_unit_card_mc.enemy_unit_title_tf,param1.eventData.enemyUnitName);
                  this.m_bar.enemy_unit_card_mc.deselect.visible = false;
                  this.m_bar.enemy_unit_card_mc.upgrades_mc.visible = true;
                  _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.enemyUnitCode,UnitItem) as UnitItem;
                  if(_loc2_ != null && _loc2_ != this.m_enemyItem)
                  {
                     this.m_enemyItem = _loc2_;
                     ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("icon").url,this.m_bar.enemy_unit_card_mc.icon);
                     this.clearEnemyIcons(true);
                     if(Boolean(_loc2_.secondaryAbility) && !_loc2_.hasType(UnitItem.MEGA_UNIT))
                     {
                        this.populateEnemySecondaryAbility(_loc2_,this.m_bar.enemy_unit_card_mc);
                     }
                     else
                     {
                        this.populateGoodAgainstIcons(_loc2_,this.m_bar.enemy_unit_card_mc,this.m_enemyIcons,true);
                     }
                     if(!this.m_enemyUpgradesDisplay)
                     {
                        _loc5_ = [this.m_bar.enemy_unit_card_mc.upgrades_mc.icon0,this.m_bar.enemy_unit_card_mc.upgrades_mc.icon1,this.m_bar.enemy_unit_card_mc.upgrades_mc.icon2,this.m_bar.enemy_unit_card_mc.upgrades_mc.icon3,this.m_bar.enemy_unit_card_mc.upgrades_mc.icon4];
                        this.m_enemyUpgradesDisplay = new UpgradesDisplay(_loc5_,this.m_bar.enemy_unit_card_mc.upgrades_mc,this.m_bar.enemy_unit_card_mc.tooltip,this.m_bar,this.m_enemyItem,param1.eventData.enemyUnitUpgrades[this.m_enemyItem.code]);
                     }
                     else if(this.m_enemyUpgradesDisplay.unitItem != this.m_enemyItem)
                     {
                        this.m_enemyUpgradesDisplay.setUnitItem(this.m_enemyItem,param1.eventData.enemyUnitUpgrades[this.m_enemyItem.code]);
                     }
                  }
               }
            }
            else if(param1.eventData.type == CLEAR_PLAYER_UNIT_STATS_DATA)
            {
               this.m_bar.player_unit_card_mc.my_unit_title_tf.text = "";
               this.clearPlayerIcons();
               this.m_playerItem = null;
               this.m_bar.player_unit_card_mc.icon.unload();
               this.disposeSpecialAbilityUnitCard();
               this.m_bar.player_unit_card_mc.deselect.visible = true;
               this.m_bar.player_unit_card_mc.bonusAgainst_tf.visible = false;
               this.m_bar.player_unit_card_mc.upgrades_mc.visible = false;
               this.m_bar.player_unit_card_mc.tooltip.visible = false;
            }
            else if(param1.eventData.type == CLEAR_ENEMY_UNIT_STATS_DATA)
            {
               this.m_bar.enemy_unit_card_mc.enemy_unit_title_tf.text = "";
               this.clearEnemyIcons();
               this.m_enemyItem = null;
               this.m_bar.enemy_unit_card_mc.icon.unload();
               ZGameUtils.hideIfExists(this.m_bar.enemy_unit_card_mc.enemyAbility_mc);
               this.m_bar.enemy_unit_card_mc.deselect.visible = true;
               this.m_bar.enemy_unit_card_mc.bonusAgainst_tf.visible = false;
               this.m_bar.enemy_unit_card_mc.upgrades_mc.visible = false;
            }
            else if(param1.eventData.type == STARTUP_DATA)
            {
               this.m_fleet = param1.eventData.playerFleet;
               this.loadPlayerInfo(param1.eventData.playerFleet,this.m_bar.player_profile_card_mc);
               this.loadPlayerInfo(param1.eventData.enemyFleet,this.m_bar.enemy_profile_card_mc);
               if(Boolean(this.m_enableReviveUnits) && Boolean(this.m_fleet.lastUnitLost) && this.m_fleet.numUnits > 0)
               {
                  this.m_lastUnitLost = ZGlobal.gameSettings.getItemByCode(this.m_fleet.lastUnitLost,UnitItem) as UnitItem;
                  Zlab.processManager.schedule(250,this,this.showReviveToaster);
               }
            }
         }
      }
      
      private function disposeSpecialAbilityUnitCard() : void
      {
         if(this.m_specialAbilityUnitCard)
         {
            this.m_specialAbilityUnitCard.dispose();
            this.m_specialAbilityUnitCard = null;
         }
      }
      
      private function populateEnemySecondaryAbility(param1:UnitItem, param2:MovieClip) : void
      {
         var _loc3_:ConsumableItem = null;
         if(ZGameUtils.showIfExists(param2.enemyAbility_mc))
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(param1.secondaryAbility,ConsumableItem) as ConsumableItem;
            TextFieldUtil.processTextField(param2.enemyAbility_mc.secondaryAbility_tf,_loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            ImageLoaderFactory.CreateImageLoader(_loc3_.getCachedImage("icon").url,param2.enemyAbility_mc.icon);
         }
         param2.bonusAgainst_tf.visible = false;
         param2.against_mc.visible = false;
      }
      
      private function populateSecondaryAbility(param1:UnitItem, param2:MovieClip) : void
      {
         var _loc3_:ConsumableItem = null;
         if(ZGameUtils.showIfExists(param2.secondaryAbility_mc))
         {
            if(!this.m_specialAbilityUnitCard)
            {
               this.m_specialAbilityUnitCard = new SpecialAbilityUnitCard(param2.secondaryAbility_mc);
            }
            _loc3_ = ZGlobal.gameSettings.getItemByCode(param1.secondaryAbility,ConsumableItem) as ConsumableItem;
            this.m_specialAbilityUnitCard.consumableItem = _loc3_;
         }
         param2.bonusAgainst_tf.visible = false;
         param2.against_mc.visible = false;
      }
      
      private function populateGoodAgainstIcons(param1:UnitItem, param2:MovieClip, param3:Array, param4:Boolean) : void
      {
         var _loc5_:Array = param1.goodAgainst;
         var _loc6_:ImageLoader = null;
         var _loc7_:UnitClass = null;
         var _loc8_:int = int(_loc5_.length);
         param2.bonusAgainst_tf.visible = true;
         param2.against_mc.visible = true;
         if(!param4)
         {
            this.disposeSpecialAbilityUnitCard();
         }
         ZGameUtils.hideIfExists(param2.enemyAbility_mc);
         switch(_loc8_)
         {
            case 1:
               param2.against_mc.x = param2.anchor1_mc.x;
               break;
            case 2:
               param2.against_mc.x = param2.anchor2_mc.x;
               break;
            default:
               param2.against_mc.x = param2.anchor3_mc.x;
         }
         switch(_loc8_)
         {
            case 3:
            case 4:
               _loc7_ = UnitClassManager.instance.unitClassNamed(_loc5_[2]);
               if(_loc7_)
               {
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param4 ? _loc7_.getIconURL() : _loc7_.getAltIconURL()),param2.against_mc.icon2);
                  _loc6_.reverse = param4;
                  param3.push(_loc6_);
               }
            case 2:
               _loc7_ = UnitClassManager.instance.unitClassNamed(_loc5_[1]);
               if(_loc7_)
               {
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param4 ? _loc7_.getIconURL() : _loc7_.getAltIconURL()),param2.against_mc.icon1);
                  _loc6_.reverse = param4;
                  param3.push(_loc6_);
               }
            case 1:
               _loc7_ = UnitClassManager.instance.unitClassNamed(_loc5_[0]);
               if(_loc7_)
               {
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param4 ? _loc7_.getIconURL() : _loc7_.getAltIconURL()),param2.against_mc.icon0);
                  _loc6_.reverse = param4;
                  param3.push(_loc6_);
               }
         }
      }
      
      private function clearPlayerIcons(param1:Boolean = false) : void
      {
         var _loc2_:ImageLoader = null;
         for each(_loc2_ in this.m_playerIcons)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
            }
         }
         this.m_playerIcons = param1 ? new Array() : null;
      }
      
      private function clearEnemyIcons(param1:Boolean = false) : void
      {
         var _loc2_:ImageLoader = null;
         for each(_loc2_ in this.m_enemyIcons)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
            }
         }
         this.m_enemyIcons = param1 ? new Array() : null;
      }
      
      private function loadPlayerInfo(param1:Fleet, param2:Object) : void
      {
         var _loc3_:ImageLoader = null;
         var _loc4_:Object = null;
         var _loc5_:IPVPPlayer = null;
         var _loc6_:GameItem = null;
         var _loc7_:GameItem = null;
         var _loc8_:GameItem = null;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc13_:Friend = null;
         var _loc14_:Object = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         if(param1.hasStatus(Fleet.DOMINATION_ENEMY))
         {
            _loc4_ = DominationModeManager.instance.getDominationInfo(param1.uid,true);
            if(_loc4_)
            {
               TextFieldUtil.processTextField(param2.name_tf,_loc4_.u_info.name);
               param2.level_tf.text = _loc4_.u_info.level.toString();
               ZGameUtils.showIfExists(param2.enemy_level_icon_mc);
               _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc4_.u_info.image,param2.icon);
            }
            else
            {
               _loc5_ = new PlayerDummy(param1.uid);
               TextFieldUtil.processTextField(param2.name_tf,_loc5_.firstName);
               ZGameUtils.hideIfExists(param2.enemy_level_icon_mc);
               _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc5_.portraitURL,param2.icon);
            }
         }
         else if(param1.hasStatus(Fleet.QUEST) || param1.hasStatus(Fleet.CAMPAIGN))
         {
            _loc6_ = null;
            if(param1.hasStatus(Fleet.CAMPAIGN) && ZGlobal.player.campaign.currentMap.villain.length > 0)
            {
               _loc6_ = ZGlobal.gameSettings.getItemByCode(ZGlobal.player.campaign.currentMap.villain,GameItem) as GameItem;
            }
            else
            {
               _loc6_ = (QuestManager.getInstance() as ZGameQuestManager).getCurrentVillain(param1.name);
            }
            if(!_loc6_)
            {
               Logger.warn(this,"loadPlayerInfo","Failed to get villain from strategic map, using villain v01");
               _loc6_ = ZGlobal.gameSettings.getItemByCode("v01",GameItem) as GameItem;
            }
            TextFieldUtil.processTextField(param2.name_tf,ZGameUtils.ZlocT("Items",_loc6_.name + "_firstName"));
            param2.level_tf.text = "";
            if(null != param2.enemy_level_icon_mc)
            {
               param2.enemy_level_icon_mc.visible = false;
            }
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc6_.name,"icon"),param2.icon);
         }
         else if(param1.hasStatus(Fleet.QUEST_SURVIVAL))
         {
            _loc7_ = null;
            _loc7_ = (QuestManager.getInstance() as ZGameQuestManager).getCurrentVillain(param1.name);
            if(!_loc7_)
            {
               Logger.warn(this,"loadPlayerInfo","Failed to get villain from strategic map, using villain v01");
               _loc7_ = ZGlobal.gameSettings.getItemByCode("v01",GameItem) as GameItem;
            }
            TextFieldUtil.processTextField(param2.name_tf,ZGameUtils.ZlocT("Items",_loc7_.name + "_firstName"));
            param2.level_tf.text = "";
            if(null != param2.enemy_level_icon_mc)
            {
               param2.enemy_level_icon_mc.visible = false;
            }
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon"),param2.icon);
         }
         else if(param1.hasStatus(Fleet.SURVIVAL_ENEMY))
         {
            _loc8_ = null;
            _loc8_ = ZGlobal.gameSettings.getItemByCode("v00",GameItem) as GameItem;
            _loc9_ = SurvivalModeManager.instance.getCurrentRound();
            TextFieldUtil.compactTextField(param2.name_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWave",{"wave":_loc9_}));
            TextFieldUtil.processTextField(param2.level_tf,_loc9_.toString());
            param2.enemy_level_icon_mc.visible = true;
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc8_.name,"icon"),param2.icon);
         }
         else
         {
            _loc10_ = true;
            if(param1.uid == ZGlobal.hostPlayer.uid)
            {
               TextFieldUtil.processTextField(param2.name_tf,ZGlobal.hostPlayer.firstName);
               TextFieldUtil.processTextField(param2.level_tf,ZGlobal.hostPlayer.level.toString());
               _loc11_ = ZGlobal.player.neighbors[param1.uid];
               if(_loc11_ != null)
               {
                  TextFieldUtil.processTextField(param2.level_tf,_loc11_.level.toString());
               }
               else
               {
                  _loc12_ = PVPManager.instance.getGlobalPVPStrangerInfo(param1.uid);
                  if((Boolean(_loc12_)) && Boolean(_loc12_.friendInfo))
                  {
                     _loc13_ = _loc12_.friendInfo;
                     TextFieldUtil.processTextField(param2.level_tf,_loc13_.level.toString());
                  }
               }
               _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.hostPlayer.snUser.picture,param2.icon);
            }
            else if(param1.uid == ZGlobal.player.uid)
            {
               TextFieldUtil.processTextField(param2.name_tf,ZGlobal.player.firstName);
               TextFieldUtil.processTextField(param2.level_tf,ZGlobal.player.level.toString());
               _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,param2.icon);
            }
            else
            {
               _loc14_ = PVPManager.instance.getPVPPlayer(param1.uid);
               if(_loc14_ != null)
               {
                  TextFieldUtil.processTextField(param2.name_tf,_loc14_.firstName);
                  _loc16_ = " ";
                  _loc10_ = false;
                  if(param1.uid == PVPManager.PVE_MARKER_KEY)
                  {
                     _loc15_ = _loc14_.portraitURL;
                  }
                  else
                  {
                     if(_loc14_.level != 0)
                     {
                        _loc16_ = _loc14_.level.toString();
                        _loc10_ = true;
                     }
                     _loc11_ = ZGlobal.player.neighbors[param1.uid];
                     if(_loc11_ != null)
                     {
                        _loc16_ = _loc11_.level.toString();
                        _loc10_ = true;
                     }
                     _loc15_ = _loc14_.snUser.picture;
                  }
                  TextFieldUtil.processTextField(param2.level_tf,_loc16_);
                  _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc15_,param2.icon);
               }
            }
            if(null != param2.enemy_level_icon_mc)
            {
               param2.enemy_level_icon_mc.visible = _loc10_;
            }
         }
      }
      
      private function setSpecialPowerMode(param1:Boolean) : void
      {
         if(!this.m_powersDisabled)
         {
            this.m_bar.consumable_bt.gotoAndStop(param1 ? 2 : 1);
            Tooltip.unsubscribe(this.m_bar.consumable_bt);
            if(param1)
            {
               Tooltip.subscribe(this.m_bar.consumable_bt,ZGameUtils.ZlocT("Tooltips","CombatBar_cancelConsumable"));
            }
            else
            {
               Tooltip.subscribe(this.m_bar.consumable_bt,ZGameUtils.ZlocT("Tooltips","CombatBar_pickConsumable"));
            }
         }
         if(!param1)
         {
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onPlayerTurnEnds);
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_UNIT_CLICKED,this.onPlayerTurnEnds);
         }
      }
      
      private function allowSpecialPowerSelection(param1:Boolean) : void
      {
         this.m_allowSpecialPower = param1;
         if(this.m_allowSpecialPower)
         {
            this.setSpecialPowersEnabled(true);
         }
         else
         {
            this.setSpecialPowerMode(false);
            this.setSpecialPowersEnabled(false);
         }
      }
      
      public function allowSpecialPowerSelection2(param1:Boolean) : void
      {
         this.m_allowSpecialPower = param1;
         if(this.m_allowSpecialPower)
         {
            this.setSpecialPowerMode(true);
            this.setSpecialPowersEnabled(true);
         }
         else
         {
            this.setSpecialPowerMode(false);
            this.setSpecialPowersEnabled(false);
         }
      }
      
      private function setSpecialPowersEnabled(param1:Boolean) : void
      {
         if(param1 && !this.m_powersDisabled && !this.m_specialPowersOn)
         {
            this.listenForConsumableClick(true);
            ZGameUtils.enableButton(this.m_bar.consumable_bt,this.onSpecialPowerClicked);
            this.m_buttonSounds.addButton(this.m_bar.consumable_bt,ButtonSound.DEFAULT);
            this.m_specialPowersOn = true;
         }
         else if(!param1)
         {
            this.listenForConsumableClick(false);
            ZGameUtils.disableButton(this.m_bar.consumable_bt,this.onSpecialPowerClicked);
            this.m_buttonSounds.removeButton(this.m_bar.consumable_bt);
            this.m_specialPowersOn = false;
         }
      }
      
      private function listenForConsumableClick(param1:Boolean) : void
      {
         if(param1)
         {
            addEventListener(ConsumableSlot.CLICKED,this.onConsumableClicked);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CLICKED,this.onConsumableClicked);
         }
         else
         {
            removeEventListener(ConsumableSlot.CLICKED,this.onConsumableClicked);
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CLICKED,this.onConsumableClicked);
         }
      }
      
      private function onDisableSpecialPowers(param1:WorldEvent) : void
      {
         this.setSpecialPowersEnabled(false);
         this.m_powersDisabled = true;
      }
      
      private function onEnableSpecialPowers(param1:WorldEvent) : void
      {
         this.m_powersDisabled = false;
         if(this.m_allowSpecialPower)
         {
            this.setSpecialPowersEnabled(true);
         }
      }
      
      private function onHideCombatUI(param1:WorldEvent) : void
      {
         this.m_bar.exit_bt.visible = false;
         this.m_bar.consumable_bt.visible = false;
         this.m_bar.pause.visible = false;
         this.m_tutorialHidden = true;
         this.hideAllSuggestionUI();
         this.hideReviveSuggestionUI();
      }
      
      private function onShowCombatUI(param1:WorldEvent) : void
      {
         this.m_bar.exit_bt.visible = true;
         this.m_bar.consumable_bt.visible = true;
         this.m_bar.pause.visible = true;
      }
      
      private function onDisableSpecialPowerControls(param1:WorldEvent) : void
      {
         this.m_specialPowerControlsOff = true;
      }
      
      private function onEnableSpecialPowerControls(param1:WorldEvent) : void
      {
         this.m_specialPowerControlsOff = false;
      }
      
      private function onStencilAdded(param1:WorldEvent) : void
      {
         this.enablePauseRetreatButtons(false);
      }
      
      private function onStencilRemoved(param1:WorldEvent) : void
      {
         this.enablePauseRetreatButtons(true);
      }
      
      private function onTutorialEnablePauseRetreatButtons(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData as String) && param1.eventData == "true")
         {
            this.m_tutorialEnablePauseRetreat = true;
            this.m_enablePauseRetreat = true;
            this.enablePauseRetreatButtons(true);
         }
         else
         {
            this.m_tutorialEnablePauseRetreat = false;
            this.m_enablePauseRetreat = false;
            this.enablePauseRetreatButtons(false);
         }
      }
      
      private function onEnablePauseRetreatButtons(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData as String) && param1.eventData == "true")
         {
            if(this.m_tutorialEnablePauseRetreat)
            {
               this.m_enablePauseRetreat = true;
               this.enablePauseRetreatButtons(true);
            }
         }
         else
         {
            this.m_enablePauseRetreat = false;
            this.enablePauseRetreatButtons(false);
         }
      }
      
      private function enablePauseRetreatButtons(param1:Boolean) : void
      {
         if(param1 && this.m_enablePauseRetreat)
         {
            ZGameUtils.enableButton(this.m_bar.pause,this.onPauseClicked);
            ZGameUtils.enableButton(this.m_bar.exit_bt,this.onRetreatClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.m_bar.pause,this.onPauseClicked);
            ZGameUtils.disableButton(this.m_bar.exit_bt,this.onRetreatClicked);
         }
      }
      
      private function experimentsAdded(param1:Event) : void
      {
         this.initMessageTab();
      }
      
      private function initMessageTab() : void
      {
         var _loc1_:Boolean = false;
         _loc1_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_COMBAT_TOASTER) == ExperimentsManager.VARIANT_VALUE_COMBAT_TOASTER_ON;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_COMBAT_REVIVE_UNIT);
         this.m_enableReviveUnits = _loc2_ <= 2 ? false : true;
         Logger.info(this,"CombatBar","Revive Unit Variant: " + _loc2_.toString() + ". Enable Toaster: " + this.m_enableReviveUnits.toString());
         this.m_isReviveShown = false;
         this.m_reviveTurnsLeft = 0;
         if(_loc1_ || this.m_enableReviveUnits)
         {
            this.m_bar.messageTab_mc.visible = true;
            this.m_messageTab = new FriendsBarMessageTabUIItem(this.m_bar.messageTab_mc);
            this.m_messageTab.combatToasterEnabled = true;
            this.m_bar.messageTab_mc.x = MESSAGE_TAB_MARGIN;
            this.m_messageTab.setMaxWidth(this.m_bar.bg_mc.width - MESSAGE_TAB_MARGIN * 2);
         }
      }
   }
}

