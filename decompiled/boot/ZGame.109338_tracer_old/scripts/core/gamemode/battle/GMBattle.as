package core.gamemode.battle
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.GMDefault;
   import core.gamemode.GameModeManager;
   import core.gamemode.avatar.AvatarComponent;
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggester;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gamemode.strategic.GMStrategic;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.EpisodeItemWrapper;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.ItemImage;
   import core.gameobjects.LetterItemWrapper;
   import core.gameobjects.SpeechItemWrapper;
   import core.managers.AlliancesManager;
   import core.managers.ChallengeModeManager;
   import core.managers.ExperimentsManager;
   import core.managers.FightMeterManager;
   import core.managers.PVPManager;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.player.IPVPPlayer;
   import core.player.PlayerVillain;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UIManager;
   import core.ui.menuitem.CombatBarUIItem;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.ui.menuitem.VisitorEnergyUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.strategicWorld.StrategicWorld;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.CommentPopup;
   import displays.popups.CommentTauntPopup;
   import displays.popups.EpisodePopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.LetterPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.alliancePopup.AllianceBattleContinuePopup;
   import displays.popups.alliancePopup.AllianceBattleWonPopup;
   import displays.popups.battlebase.BattleBasePopup;
   import displays.popups.battlelost.BattleCampaignDefeatedPopup;
   import displays.popups.battlelost.BattleChallengeLostPopup;
   import displays.popups.battlelost.BattleChallengeRetreatedPopup;
   import displays.popups.battlelost.BattleDominationLostPopup;
   import displays.popups.battlelost.BattleRetreatedPopup;
   import displays.popups.battlewon.BattleChallengeWonPopup;
   import displays.popups.battlewon.BattleDominationWonPopup;
   import displays.popups.battlewon.BattleFirstVictoryPopup;
   import displays.popups.survivalMode.SurvivalModeEndPopup;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import transactions.TBeginQuestBattle;
   import transactions.TExitBattle;
   import transactions.TSetDefenderComment;
   import transactions.TSetInvasionComment;
   import transactions.TString;
   import transactions.TWorldLoad;
   import utils.ZGameRandom;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class GMBattle extends GMDefault
   {
      
      public static const BATTLE_EXIT:String = "battleexit";
      
      private static const COMMENT_KINGDOM:String = "pvp_comment";
      
      private static const COMMENT_EXIT:String = "exit";
      
      private static const COMMENT_SUPPRESS:String = "suppress";
      
      private static const COMMENT_POST:String = "post";
      
      private static const COMMENT_POST_COMMENT:String = "post_comment";
      
      private static const COMMENT_POST_TAUNT:String = "post_taunt";
      
      private static const COMMENT_BLANK:String = "blank";
      
      private static const COMMENT_NOT_BLANK:String = "not_blank";
      
      public static var debugSeeds:Array = null;
      
      private static var m_episodeDialog:String = null;
      
      private static var m_enemyFleetName:String = null;
      
      private var m_battle:BattleHost = null;
      
      private var m_highlightedEnemy:BattleObject = null;
      
      private var m_highlightedPlayer:BattleObject = null;
      
      private var m_currentConsumable:ConsumableItem = null;
      
      private var m_consumableCursor:Object = null;
      
      private var m_waitingForCursorImage:Boolean = false;
      
      private var m_exitButton:int = -1;
      
      private var m_retreat:Boolean = false;
      
      private var m_cancel:Boolean = false;
      
      private var m_pause:Boolean = false;
      
      private var m_pausedInPreBattle:Boolean = false;
      
      private var m_isChallenge:Boolean = false;
      
      private var m_isSurvival:Boolean = false;
      
      private var m_isQuestSurvival:Boolean = false;
      
      private var m_exitToIslandWorld:Boolean = false;
      
      private var m_lostUnits:Dictionary = null;
      
      private var m_remainingUnits:Array = null;
      
      private var m_playerHasRevivedUnits:Boolean = false;
      
      private var m_allies:Array = null;
      
      private var m_challengerName:String = null;
      
      private var m_showingLetter:Boolean = false;
      
      private var m_winPopupUsesFirstVictory:Boolean;
      
      private var m_firstVictoryQuest:String = null;
      
      private var m_isPVPInitialInvasion:Boolean = false;
      
      private var m_consumableSuggester:ConsumableSuggester;
      
      private var m_suggesterHasSuggested:Boolean;
      
      public function GMBattle(param1:Fleet, param2:Fleet, param3:Boolean = false, param4:Boolean = false, param5:Object = null)
      {
         var _loc7_:IPVPPlayer = null;
         super();
         UIDispatcher.instance.dispatchEvent(new Event(VisitorEnergyUIItem.HIDE_VISITORENERGY));
         UIDispatcher.instance.dispatchEvent(new Event(AvatarComponent.CANCEL_AVATAR_ORDERS));
         this.m_isChallenge = param3;
         if(this.m_isChallenge)
         {
            _loc7_ = PVPManager.instance.getPVPPlayer(param2.uid);
            param4 = _loc7_ is PlayerVillain ? true : param4;
            param4 = ChallengeModeManager.instance.isNeighborAssist() ? false : param4;
            this.m_battle = new BattleChallenge(param1,param2,param4);
            if(_loc7_)
            {
               this.m_challengerName = _loc7_.firstName;
            }
            if(param2.hasStatus(Fleet.QUEST))
            {
               if((QuestManager.getInstance() as ZGameQuestManager).fightTaskWinPopupUsesFirstVictory(param2.name))
               {
                  this.m_winPopupUsesFirstVictory = true;
                  this.m_firstVictoryQuest = param2.name;
               }
            }
            if(ZGlobal.isVisiting() && !ChallengeModeManager.instance.isNeighborAssist())
            {
               this.m_isPVPInitialInvasion = true;
            }
         }
         else if(param2.hasStatus(Fleet.SURVIVAL_ENEMY))
         {
            this.m_battle = new BattleSurvival(param1,param2);
            this.m_isSurvival = true;
         }
         else if(param1.hasStatus(Fleet.DOMINATION_DEFENSE))
         {
            this.m_battle = new BattleDefenseForceEdit(param1,param2);
         }
         else if(param2.hasStatus(Fleet.DOMINATION_ENEMY))
         {
            this.m_battle = new BattleDomination(param1,param2);
         }
         else if(param2.hasStatus(Fleet.QUEST))
         {
            this.m_battle = new BattleQuest(param1,param2,param5);
            this.storeAllies(param1.allies);
         }
         else if(param2.hasStatus(Fleet.MECHLAB))
         {
            this.m_battle = new BattleMechlab(param1,param2);
         }
         else if(param2.hasStatus(Fleet.QUEST_SURVIVAL))
         {
            this.m_battle = new BattleSurvivalQuest(param1,param2,param5);
            this.m_isQuestSurvival = true;
         }
         else if(param2.hasStatus(Fleet.DEATHMATCH_ENEMY))
         {
            this.m_battle = new BattleDeathMatch(param1,param2);
         }
         else
         {
            this.m_battle = new BattleCampaign(param1,param2);
            this.storeAllies(param1.allies);
         }
         param1 = ZGlobal.player.fleets.getFleetByName(this.m_battle.getPlayerFleetName());
         param2 = ZGlobal.player.fleets.getFleetByName(this.m_battle.getEnemyFleetName());
         var _loc6_:Object = new Object();
         _loc6_.type = CombatBarUIItem.STARTUP_DATA;
         _loc6_.playerFleet = param1;
         _loc6_.enemyFleet = param2;
         ContextualBarUIItem.getContextualBar().dispatchEvent(new WorldEvent(ContextualBarUIItem.ADD_COMBAT_EVENT,_loc6_));
         _loc6_ = new Object();
         _loc6_.type = CombatBarUIItem.CLEAR_ENEMY_UNIT_STATS_DATA;
         ContextualBarUIItem.getContextualBar().dispatchEvent(new WorldEvent(ContextualBarUIItem.ADD_COMBAT_EVENT,_loc6_));
         debugSeeds = [ZGameRandom.instance.initialisers.w,ZGameRandom.instance.initialisers.z];
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_RECREATE_PLAYER_GROUP,this.onRecreatePlayerGroup);
         this.resetConsumableSuggester(param1,param2);
         UIManager.instance.dispatchEvent(new WorldEvent(UIManager.UI_ENABLE_COMBAT_PAUSE_RETREAT,"true"));
      }
      
      public static function createStaticBattleFromQuest(param1:Object, param2:String, param3:String = null, param4:ZGameTask = null) : void
      {
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc5_:Fleet = Fleet.getFleet(param2);
         var _loc6_:Fleet = ZGlobal.player.fleets.getFleetWithBattleTarget(param2);
         var _loc7_:Boolean = (Boolean(_loc6_)) && _loc6_.units.length > 0;
         if(param1 != null && param1.id != null)
         {
            ZGlobal.player.m_currentQuestBattleId = param1.id;
         }
         if(null != param3)
         {
            m_episodeDialog = param3;
         }
         if(_loc7_ && (Boolean(!_loc6_.hasStatus(Fleet.FREE)) || Boolean(param1 && param1.pve)))
         {
            GameModeManager.instance.addGameMode(new GMBattle(_loc6_,_loc5_,false,false,param1));
         }
         else if(_loc7_ && Boolean(_loc5_.battleTarget))
         {
            startStaticQuestBattle(_loc6_,_loc5_);
            ZGameStats.instance.dispatchEvent(new Event(ZGameStats.STATS_RESUME_QUEST_BATTLE));
         }
         else
         {
            m_enemyFleetName = param2;
            _loc8_ = Boolean(param1) && param1.id != m_enemyFleetName;
            if(_loc7_)
            {
               onFleetDeploy(new WorldEvent("",_loc6_));
            }
            else if(_loc8_)
            {
               GMPreBattle.ACTIVE = true;
               _loc9_ = 5;
               if(Boolean(param4) && param4.hasCombatSetup)
               {
                  _loc10_ = param4.combatSetup;
                  if(_loc10_.maxUnits > 0)
                  {
                     _loc9_ = int(_loc10_.maxUnits);
                  }
                  param1.maxUnits = _loc9_;
                  param1.playerType = _loc10_.playerType;
                  param1.numAllies = _loc10_.numAllies;
               }
               GameModeManager.instance.addGameMode(new GMBattle(_loc6_,_loc5_,false,false,param1));
               GameModeManager.instance.addGameMode(new GMPreBattle(_loc6_,_loc5_,_loc9_,false,param1),false);
            }
         }
      }
      
      private static function onFleetDeploy(param1:WorldEvent) : void
      {
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.DEPLOY,onFleetDeploy);
         var _loc2_:Fleet = Fleet.getFleet(m_enemyFleetName);
         var _loc3_:Fleet = param1.eventData as Fleet;
         TransactionManager.addTransaction(new TBeginQuestBattle(m_enemyFleetName,m_enemyFleetName));
         m_enemyFleetName = null;
         Fleet.linkFleets(_loc3_,_loc2_);
         startStaticQuestBattle(_loc3_,_loc2_);
      }
      
      private static function startStaticQuestBattle(param1:Fleet, param2:Fleet) : void
      {
         ChallengeModeManager.instance.setInChallengeBattle(param1.name,param2.name,PVPManager.PVE_MARKER_KEY,true,true,false,0);
         GameModeManager.instance.addGameMode(new GMBattle(param1,param2,true));
      }
      
      public static function QuitBattleMode() : void
      {
         var _loc1_:GMBattle = GMBattle(GameModeManager.instance.getTopGameMode());
         if(_loc1_ == null)
         {
            return;
         }
         _loc1_.leaveBattleMode(BattleBasePopup.EXIT);
      }
      
      public function get battle() : Battle
      {
         return this.m_battle;
      }
      
      private function killConsumableSuggester() : void
      {
         if(this.m_consumableSuggester != null)
         {
            this.m_consumableSuggester.dispose();
            this.m_consumableSuggester = null;
         }
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurn);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_ENEMY_TURN,this.onEnemyTurn);
      }
      
      private function resetConsumableSuggester(param1:Fleet, param2:Fleet) : void
      {
         if(param1 == null && this.battle.getPlayerFleetName() != null)
         {
            param1 = Fleet.getFleet(this.battle.getPlayerFleetName());
         }
         if(param2 == null && this.battle.getEnemyFleetName() != null)
         {
            param2 = Fleet.getFleet(this.battle.getEnemyFleetName());
         }
         if(param1 != null && param2 != null)
         {
            this.killConsumableSuggester();
            this.m_suggesterHasSuggested = false;
            this.m_consumableSuggester = new ConsumableSuggester();
            this.m_consumableSuggester.setupStandardSuggestionAlgorithms(param1,param2);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurn);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_ENEMY_TURN,this.onEnemyTurn);
         }
      }
      
      private function onEnemyTurn(param1:Event) : void
      {
         this.m_suggesterHasSuggested = false;
      }
      
      private function onPlayerTurn(param1:Event) : void
      {
         var consumableSuggestion:IConsumableSuggestion = null;
         var e:Event = param1;
         if(this.m_suggesterHasSuggested == false)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_EVERY_OTHER_TURN || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT_EVERY_OTHER_TURN)
            {
               if(this.m_consumableSuggester == null)
               {
                  throw Error(" the consumable suggester is self is null ");
               }
               try
               {
                  consumableSuggestion = this.m_consumableSuggester.suggestConsumable();
                  this.m_suggesterHasSuggested = true;
                  if(consumableSuggestion != null && consumableSuggestion.consumableCode != AbstractConsumableSuggestionAlgorithm.NO_CONSUMABLE_SUGGESTABLE)
                  {
                     BattleDispatcher.instance.dispatchEvent(new WorldEvent(ConsumableSuggester.CONSUMABLE_SUGGESTED,consumableSuggestion));
                  }
               }
               catch(error:Error)
               {
                  Logger.info(this,"OnPLayerTurn","Error with consumable suggestions algorithm. Best guess is that one side of a fleet wasn\'t set. " + error.message);
               }
            }
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         UIDispatcher.instance.dispatchEvent(new Event(VisitorEnergyUIItem.SHOW_VISITORENERGY));
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RECREATE_PLAYER_GROUP,this.onRecreatePlayerGroup);
         Zlab.processManager.removeScheduledObject(this);
         this.m_highlightedEnemy = null;
         this.m_highlightedPlayer = null;
         this.m_currentConsumable = null;
         this.m_consumableCursor = null;
         this.m_waitingForCursorImage = false;
         this.m_lostUnits = null;
         this.m_remainingUnits = null;
         this.m_battle.dispose();
         this.m_battle = null;
         this.m_allies = null;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,{"entered":true}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":false}));
         PlayerStatsUIItem.getPlayerStats().dispatchEvent(new WorldEvent(PlayerStatsUIItem.HIDE_ELEMENTS_FOR_BATTLE,true));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,true));
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_MANUAL_HOST,this.onUserExitBattle,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onExitBattle,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onEnemyUnitHighlighted,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,this.onPlayerUnitHighlighted,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onConsumableSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_SET_PLAYER_HIGHLIGHTED_UNIT,this.onPlayerUnitHighlighted);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,this.onEnemyUnitHighlighted);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PAUSE,this.onPause);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_RETREAT,this.onRetreat);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CANCEL,this.onCancel);
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,{"entered":false}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":true}));
         PlayerStatsUIItem.getPlayerStats().dispatchEvent(new WorldEvent(PlayerStatsUIItem.HIDE_ELEMENTS_FOR_BATTLE,false));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,false));
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_COMPLETE_MANUAL_HOST,this.onUserExitBattle);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onExitBattle);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onEnemyUnitHighlighted);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,this.onPlayerUnitHighlighted);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onConsumableSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_SET_PLAYER_HIGHLIGHTED_UNIT,this.onPlayerUnitHighlighted);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,this.onEnemyUnitHighlighted);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PAUSE,this.onPause);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RETREAT,this.onRetreat);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CANCEL,this.onCancel);
         ContextualBarUIItem.getContextualBar().dispatchEvent(new WorldEvent(ContextualBarUIItem.REMOVE_COMBAT_EVENT));
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
      }
      
      override protected function selectEntity(param1:IEntity, param2:MouseEvent) : void
      {
      }
      
      override protected function deselectObject() : void
      {
      }
      
      override protected function doHandleMouseMove(param1:Point) : void
      {
      }
      
      override public function onMouseMove(param1:MouseEvent) : Boolean
      {
         return true;
      }
      
      private function onPause(param1:WorldEvent) : void
      {
         this.m_pause = true;
         this.m_pausedInPreBattle = param1.eventData.inPreBattle;
         if(this.m_isChallenge)
         {
            PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.UPDATE_MARKER));
         }
         if(this.m_battle.checkExitBattle())
         {
            this.userExitBattle();
         }
      }
      
      private function onRetreat(param1:Event) : void
      {
         this.m_retreat = true;
         if(this.m_battle.checkExitBattle())
         {
            this.userExitBattle();
         }
      }
      
      private function onCancel(param1:Event) : void
      {
         this.m_cancel = true;
         this.userExitBattle();
      }
      
      private function onRecreatePlayerGroup(param1:WorldEvent) : void
      {
         var _loc2_:Fleet = param1.eventData as Fleet;
         if(this.m_consumableSuggester != null)
         {
            this.m_consumableSuggester.updateFleets(_loc2_,Fleet.getFleet(_loc2_.battleTarget));
         }
         else
         {
            this.resetConsumableSuggester(_loc2_,Fleet.getFleet(_loc2_.battleTarget));
         }
         this.storeAllies(_loc2_.allies);
      }
      
      private function userExitBattle() : void
      {
         var _loc3_:TExitBattle = null;
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         var _loc6_:Fleet = null;
         var _loc7_:Array = null;
         var _loc1_:Boolean = false;
         var _loc2_:Fleet = ZGlobal.player.fleets.getFleetByName(this.m_battle.getEnemyFleetName());
         if(Boolean(_loc2_) && _loc2_.hasStatus(Fleet.RESTORE_ON_RETREAT))
         {
            _loc1_ = true;
         }
         if(!(this.m_cancel && _loc1_ || this.m_battle.isDefenseForceEditMode))
         {
            if(!this.m_pause)
            {
               _loc3_ = new TExitBattle(this.m_battle.getPlayerFleetName(),this.m_battle.getEnemyFleetName(),this.m_retreat,this.m_cancel);
               TransactionManager.addTransaction(_loc3_);
            }
         }
         if(this.m_retreat)
         {
            if(this.m_isSurvival)
            {
               _loc4_ = uint(ExperimentsManager.instance.getExperimentVariant(SurvivalModeManager.EXPERIMENT_SURVIVALMODE_RETREAT));
               if(_loc4_ == SurvivalModeManager.RETREAT_VARIANT_PENALTY_ON)
               {
                  _loc5_ = this.m_battle.getPlayerFleetName();
                  _loc6_ = ZGlobal.player.fleets.getFleetByName(_loc5_);
                  _loc7_ = _loc6_.units;
                  while(_loc7_.length > 0)
                  {
                     WorldUnitManager.instance.destroyUnit(_loc7_[0].code,WorldUnitManager.UNIT_IN_FLEET);
                     ZGlobal.player.fleets.removeUnit(_loc5_,_loc7_[0]);
                  }
               }
            }
            if(AlliancesManager.instance.allianceBattle)
            {
               ZGlobal.player.fleets.destroyFleet(DominationModeManager.FLEET_DEFENSE_DUMMY_PLAYER,Battle.BATTLE_RESULT_RETREAT);
               AlliancesManager.instance.resetAllianceBattleData();
            }
            this.m_battle.endBattleWithRetreat();
            if(AlliancesManager.instance.allianceBattle)
            {
               AlliancesManager.instance.resetAllianceBattleData();
            }
            if(DeathMatchManager.instance.isInDeathMatchBattle())
            {
               DeathMatchManager.instance.onBattleComplete(false,this.m_remainingUnits,this.m_lostUnits,false);
            }
            if(this.m_isChallenge)
            {
               PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.UPDATE_MARKER));
               PopupManager.instance.push(new BattleChallengeRetreatedPopup(this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed));
            }
            else
            {
               PopupManager.instance.push(new BattleRetreatedPopup(this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed));
            }
         }
         else if(this.m_cancel)
         {
            if(!_loc1_ && !this.m_battle.isDefenseForceEditMode)
            {
               this.m_battle.endBattleWithCancel();
            }
            this.exitBattle();
         }
         else
         {
            this.exitBattle();
         }
      }
      
      private function returnToHomeIsland() : void
      {
         ViewManager.instance.goToPreviousView();
         GameModeManager.instance.setDefaultGameMode();
         ZGame.instance.performVisitNeighbor(ZGlobal.player.uid,false,TWorldLoad.DBG_RETURN,false);
      }
      
      private function exitBattle() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         if(Boolean(this.m_battle && !this.m_pause) && Boolean(!this.m_retreat) && ExperimentsManager.instance.getExperimentVariant("empire_fightmeter") == ExperimentsManager.VARIANT_FIGHTMETER_ON)
         {
            if(this.m_battle.isDefenseForceEditMode == false)
            {
               FightMeterManager.instance.incrementfightCount();
               UIDispatcher.instance.dispatchEvent(new Event(UIDispatcher.UI_BATTLEWINLOSE));
            }
         }
         if(null != BattleQuest.rematchTarget)
         {
            ViewManager.instance.goToView(IslandWorld.ID);
            GameModeManager.instance.setDefaultGameMode();
         }
         else if(this.m_isSurvival)
         {
            SurvivalModeManager.instance.exitSurvivalBattle(this.m_battle.battleResult == Battle.BATTLE_RESULT_RETREAT || this.m_battle.battleResult == Battle.BATTLE_RESULT_LOST);
            if(this.m_battle)
            {
               _loc1_ = SurvivalModeManager.instance.completeSurvivalBattle(this.m_battle.battleResult,this.m_lostUnits,this.m_remainingUnits);
               if(_loc1_)
               {
                  ViewManager.instance.goToView(IslandWorld.ID);
                  GameModeManager.instance.setDefaultGameMode();
               }
            }
         }
         else if(this.m_isQuestSurvival)
         {
            QuestSurvivalModeManager.instance.exitSurvivalBattle(this.m_battle.battleResult == Battle.BATTLE_RESULT_RETREAT || this.m_battle.battleResult == Battle.BATTLE_RESULT_LOST);
            if(this.m_battle)
            {
               _loc1_ = QuestSurvivalModeManager.instance.completeSurvivalBattle(this.m_battle.battleResult,this.m_lostUnits,this.m_remainingUnits);
               if(_loc1_)
               {
                  ViewManager.instance.goToView(IslandWorld.ID);
                  GameModeManager.instance.setDefaultGameMode();
               }
            }
         }
         else if(DeathMatchManager.instance.isInDeathMatchBattle())
         {
            if(this.m_pause)
            {
               DeathMatchManager.instance.exitBattle();
               ViewManager.instance.goToView(IslandWorld.ID);
               GameModeManager.instance.setDefaultGameMode();
            }
            else
            {
               DeathMatchManager.instance.onBattleComplete(this.m_battle.battleResult == Battle.BATTLE_RESULT_RETREAT || this.m_battle.battleResult == Battle.BATTLE_RESULT_LOST,this.m_remainingUnits,this.m_lostUnits);
            }
         }
         else if(DominationModeManager.instance.isInDominationBattle())
         {
            _loc2_ = true;
            if(AlliancesManager.isExperimentEnabled() && AlliancesManager.instance.isAllianceBattleEnabled())
            {
               _loc3_ = null;
               _loc4_ = DominationModeManager.instance.getDominationEnemyUID();
               if(Boolean(AlliancesManager.instance.allianceBattle) && Boolean(this.m_battle) && this.m_battle.battleResult != Battle.BATTLE_RESULT_NONE)
               {
                  _loc5_ = this.m_battle.battleResult == Battle.BATTLE_RESULT_WON;
                  _loc3_ = AlliancesManager.instance.loadNextMember(_loc4_,AlliancesManager.instance.battleAllianceName);
                  if(Boolean(_loc3_) && _loc5_)
                  {
                     _loc6_ = this.m_battle.getPlayerFleetName();
                     AlliancesManager.instance.allianceBattleMember = _loc3_;
                     AlliancesManager.instance.nextAllianceBattle(this.m_battle.battleResult,this.m_lostUnits,this.m_remainingUnits,_loc3_,_loc6_);
                     _loc2_ = false;
                  }
               }
            }
            if(this.m_battle)
            {
               _loc7_ = Boolean(this.m_battle) && this.m_battle.battleResult == Battle.BATTLE_RESULT_WON;
               if(!(AlliancesManager.instance.allianceBattle && _loc7_))
               {
                  DominationModeManager.instance.completeDominationBattle(this.m_battle);
               }
            }
            if(this.m_pause)
            {
               DominationModeManager.instance.launchDominationScreen();
               if(AlliancesManager.instance.allianceBattle)
               {
                  AlliancesManager.instance.allianceBattle = false;
               }
            }
            if(_loc2_)
            {
               if(Boolean(!_loc3_ && this.m_battle) && Boolean(this.m_battle.battleResult != Battle.BATTLE_RESULT_NONE) && AlliancesManager.instance.allianceBattle)
               {
                  if(!AlliancesManager.instance.isLostAllianceBattle())
                  {
                     AlliancesManager.instance.resetAllianceBattleData(this.m_battle.battleResult == Battle.BATTLE_RESULT_WON);
                  }
               }
               DominationModeManager.instance.exitDominationBattle();
               ViewManager.instance.goToView(IslandWorld.ID);
               GameModeManager.instance.setDefaultGameMode();
            }
         }
         else if(this.m_exitToIslandWorld)
         {
            _loc8_ = ZGlobal.player.campaign.currentMapName;
            StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.TOGGLE));
            this.showEndingSpeech(_loc8_);
         }
         else if(this.m_isPVPInitialInvasion && this.m_pause && !this.m_pausedInPreBattle)
         {
            this.returnToHomeIsland();
         }
         else if(this.m_battle.returnToPreviousView)
         {
            ViewManager.instance.goToPreviousView();
            GameModeManager.instance.setDefaultGameMode();
         }
         else
         {
            ViewManager.instance.goToView(StrategicWorld.ID);
            GameModeManager.instance.addGameMode(new GMStrategic());
         }
         if(this.m_isChallenge)
         {
            ChallengeModeManager.instance.exitChallengeBattle();
         }
         TransactionManager.addTransaction(new TString("ExitBattle"));
         GameModeManager.instance.dispatchEvent(new Event(GMBattle.BATTLE_EXIT));
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_END));
         this.killConsumableSuggester();
      }
      
      private function onUserExitBattle(param1:WorldEvent) : void
      {
         this.userExitBattle();
      }
      
      private function onExitBattle(param1:WorldEvent) : void
      {
         this.m_remainingUnits = param1.eventData.remainingUnits as Array;
         this.m_lostUnits = param1.eventData.lostUnits as Dictionary;
         this.m_playerHasRevivedUnits = param1.eventData.hasRevivedUnits as Boolean;
         if(this.m_playerHasRevivedUnits)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","RevivedUnitsInInventory"));
         }
         var _loc2_:String = ZGlobal.gameSettings.getString("combatCompleteDialogDelay");
         var _loc3_:Number = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_,0);
         _loc3_ *= 1000;
         Zlab.processManager.schedule(_loc3_,this,this.tryToDisplayExitPopup);
         UIManager.instance.dispatchEvent(new WorldEvent(UIManager.UI_ENABLE_COMBAT_PAUSE_RETREAT));
      }
      
      private function tryToDisplayExitPopup() : void
      {
         if(RewardPickupManager.instance.anyActivePickups)
         {
            Zlab.processManager.schedule(1000,this,this.tryToDisplayExitPopup);
         }
         else if(AlliancesManager.instance.allianceBattle && !AlliancesManager.instance.activeVictoryMessage())
         {
            if(this.m_battle.battleResult == Battle.BATTLE_RESULT_WON)
            {
               AlliancesManager.instance.battleWaveVictory();
               Zlab.processManager.schedule(3000,this,this.tryToDisplayExitPopup);
            }
            else
            {
               this.displayExitPopup();
            }
         }
         else
         {
            this.displayExitPopup();
         }
      }
      
      private function displayExitPopup() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc4_:BattleDominationWonPopup = null;
         var _loc5_:AllianceBattleWonPopup = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc3_:String = null;
         if(this.m_battle.battleResult == Battle.BATTLE_RESULT_WON)
         {
            if(this.m_battle.isDominationMode)
            {
               _loc2_ = DominationModeManager.instance.getDominationEnemyUID();
               _loc1_ = DominationModeManager.instance.getDominationInfo(_loc2_);
               if(AlliancesManager.isPhase4Enabled() && AlliancesManager.instance.allianceBattle)
               {
                  _loc3_ = AlliancesManager.instance.loadNextMember(_loc2_,AlliancesManager.instance.battleAllianceName);
                  AlliancesManager.instance.completeAllianceWave(this.m_battle);
               }
            }
            if(Boolean(_loc1_) && Boolean(!_loc3_) && !AlliancesManager.instance.allianceBattle)
            {
               _loc4_ = new BattleDominationWonPopup(_loc2_,_loc1_,this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed);
               PopupManager.instance.push(_loc4_);
            }
            else if(Boolean(_loc1_) && Boolean(!_loc3_) && AlliancesManager.instance.allianceBattle)
            {
               AlliancesManager.instance.updateAllianceBattleBonus(this.m_battle);
               _loc5_ = new AllianceBattleWonPopup(_loc2_,_loc1_,this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed);
               PopupManager.instance.push(_loc5_);
            }
            else if(_loc3_)
            {
               this.leaveBattleMode(BattleBasePopup.EXIT);
            }
            else if(this.m_isChallenge)
            {
               if(this.m_winPopupUsesFirstVictory)
               {
                  PopupManager.instance.push(new BattleFirstVictoryPopup(this.m_firstVictoryQuest,this.onFirstVictoryClosed));
               }
               else
               {
                  PopupManager.instance.push(new BattleChallengeWonPopup(this.m_battle.getEnemyFleetName(),this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed));
               }
            }
            else if(this.m_isSurvival || this.m_isQuestSurvival)
            {
               this.leaveBattleMode(BattleBasePopup.EXIT);
            }
            else if(DeathMatchManager.instance.isInDeathMatchBattle())
            {
               DeathMatchManager.instance.onBattleComplete(true,this.m_remainingUnits,this.m_lostUnits);
            }
            else if(this.m_battle.showWinLosePopup)
            {
               this.m_battle.showWonPopup(this.m_allies,this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed);
            }
            else
            {
               PopupManager.instance.push(new BattleFirstVictoryPopup(this.m_firstVictoryQuest,this.onFirstVictoryClosed));
            }
         }
         else if(this.m_battle.battleResult == Battle.BATTLE_RESULT_LOST)
         {
            if(this.m_battle.isDominationMode)
            {
               _loc2_ = DominationModeManager.instance.getDominationEnemyUID();
               _loc1_ = DominationModeManager.instance.getDominationInfo(_loc2_);
               _loc6_ = this.m_battle.battleResult == Battle.BATTLE_RESULT_RETREAT;
               if(AlliancesManager.isExperimentEnabled() && AlliancesManager.instance.allianceBattle && !_loc6_)
               {
                  AlliancesManager.instance.lostAllianceBattle();
                  this.showAllianceContinuePopup();
               }
            }
            if(_loc1_)
            {
               if(!AlliancesManager.instance.allianceBattle)
               {
                  PopupManager.instance.push(new BattleDominationLostPopup(_loc2_,_loc1_,this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed,this.m_battle));
               }
            }
            else if(this.m_battle.isChallenge)
            {
               PopupManager.instance.push(new BattleChallengeLostPopup(this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed));
            }
            else if(this.m_battle.isQuest || this.m_battle.isMechLab || this.m_battle.isQuestSurvival)
            {
               this.m_battle.showLosePopup(this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed);
            }
            else if(this.m_isSurvival)
            {
               _loc7_ = this.m_battle.battleResult == Battle.BATTLE_RESULT_RETREAT;
               if(!_loc7_)
               {
                  this.showContinuePopup();
               }
               else
               {
                  this.leaveBattleMode(BattleBasePopup.EXIT);
               }
            }
            else if(DeathMatchManager.instance.isInDeathMatchBattle())
            {
               if(DeathMatchManager.instance.onBattleComplete(false,this.m_remainingUnits,this.m_lostUnits))
               {
                  ViewManager.instance.goToView(IslandWorld.ID);
                  GameModeManager.instance.setDefaultGameMode();
               }
            }
            else
            {
               PopupManager.instance.push(new BattleCampaignDefeatedPopup(this.m_remainingUnits,this.m_lostUnits,this.onBattleDialogClosed));
            }
         }
      }
      
      private function onContinueAllianceBattle() : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         var _loc1_:int = AlliancesManager.instance.continuePurchaseCost;
         if(!ZGlobal.player.canBuyCash(_loc1_))
         {
            this.leaveBattleMode(BattleBasePopup.EXIT);
            return;
         }
         if(ZGlobal.gameSettings.showConfirmationPopup(_loc1_))
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeContinueConfirmTitle");
            _loc3_ = ZGameUtils.CashTokenReplacements(_loc1_);
            _loc4_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeContinueConfirmMessage",_loc3_);
            _loc5_ = GenericPopup2B.NewYesNo(_loc4_,_loc2_,this.continueAllianceConfirmed);
            _loc5_.userData = {"price":_loc1_};
            PopupManager.instance.push(_loc5_,0,false);
         }
         else
         {
            this.continueAllianceBattle(_loc1_);
         }
      }
      
      private function continueAllianceConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.continueAllianceBattle(param1.userData.price);
         }
         else
         {
            this.leaveBattleMode(BattleBasePopup.EXIT);
         }
      }
      
      private function continueAllianceBattle(param1:int = 0) : void
      {
         if(!param1)
         {
            param1 = AlliancesManager.instance.continuePurchaseCost;
         }
         ZGlobal.player.cash -= param1;
         var _loc2_:String = DominationModeManager.instance.getDominationEnemyUID();
         var _loc3_:String = AlliancesManager.instance.battleAllianceName;
         this.leaveBattleMode(BattleBasePopup.EXIT);
         AlliancesManager.instance.loadBattle(null,_loc2_,_loc3_,true);
      }
      
      private function onAllianceContinue(param1:GenericPopupEvent) : void
      {
         if(param1.button == AllianceBattleContinuePopup.ALLIANCEMODE_END_CONTINUE)
         {
            this.onContinueAllianceBattle();
         }
         else
         {
            DominationModeManager.instance.launchDominationScreen();
            AlliancesManager.instance.resetAllianceBattleData(false);
            this.leaveBattleMode(BattleBasePopup.EXIT);
         }
      }
      
      private function showAllianceContinuePopup() : void
      {
         var _loc1_:AllianceBattleContinuePopup = new AllianceBattleContinuePopup(this.m_remainingUnits,this.m_lostUnits,this.m_battle,this.onAllianceContinue);
         WindowManager.instance.push(_loc1_);
      }
      
      private function showContinuePopup() : void
      {
         var _loc1_:SurvivalModeEndPopup = new SurvivalModeEndPopup(this.onContinueClosed);
         WindowManager.instance.push(_loc1_);
      }
      
      private function onContinueClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == SurvivalModeEndPopup.SURVIVALMODE_END_CONTINUE)
         {
            this.onContinueSurvivalMode();
         }
         else
         {
            this.leaveBattleMode(BattleBasePopup.EXIT);
         }
      }
      
      public function onContinueSurvivalMode() : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         var _loc1_:int = SurvivalModeManager.continuePurchaseCost;
         if(!ZGlobal.player.canBuyCash(_loc1_))
         {
            this.leaveBattleMode(BattleBasePopup.EXIT);
            return;
         }
         if(ZGlobal.gameSettings.showConfirmationPopup(_loc1_))
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeContinueConfirmTitle");
            _loc3_ = ZGameUtils.CashTokenReplacements(_loc1_);
            _loc4_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeContinueConfirmMessage",_loc3_);
            _loc5_ = GenericPopup2B.NewYesNo(_loc4_,_loc2_,this.continueConfirmed);
            _loc5_.userData = {"price":_loc1_};
            PopupManager.instance.push(_loc5_,0,false);
         }
         else
         {
            this.continueSurvivalBattle(_loc1_);
         }
      }
      
      private function continueConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.continueSurvivalBattle(param1.userData.price);
         }
         else
         {
            this.leaveBattleMode(BattleBasePopup.EXIT);
         }
      }
      
      private function continueSurvivalBattle(param1:int = 0) : void
      {
         if(!param1)
         {
            param1 = SurvivalModeManager.continuePurchaseCost;
         }
         ZGlobal.player.cash -= param1;
         SurvivalModeManager.instance.loadSurvivalMode("",null,null,true);
      }
      
      private function onFirstVictoryClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == BattleBasePopup.INVITE)
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_FIRST_VICTORY));
         }
         if(m_episodeDialog)
         {
            PopupManager.instance.push(new EpisodePopup(m_episodeDialog,this.onEpisodeDialogClosed));
            m_episodeDialog = null;
         }
         else
         {
            this.exitBattle();
         }
      }
      
      private function onPlayerUnitHighlighted(param1:WorldEvent) : void
      {
         this.m_highlightedPlayer = param1.eventData as BattleObject;
         updateCursor();
      }
      
      private function onEnemyUnitHighlighted(param1:WorldEvent) : void
      {
         this.m_highlightedEnemy = param1.eventData as BattleObject;
         updateCursor();
      }
      
      private function onConsumableSelected(param1:WorldEvent) : void
      {
         if(!param1.eventData.ai)
         {
            this.m_consumableCursor = null;
            this.m_waitingForCursorImage = false;
            this.m_currentConsumable = param1.eventData.consumableItem;
            updateCursor();
         }
      }
      
      override protected function getCursor() : Object
      {
         var _loc1_:ItemImage = null;
         if(null != this.m_currentConsumable)
         {
            if(null == this.m_consumableCursor && !this.m_waitingForCursorImage)
            {
               _loc1_ = this.m_currentConsumable.getCachedImage("cursor");
               if(null != _loc1_)
               {
                  this.m_waitingForCursorImage = true;
                  ImageLoaderFactory.CreateImageLoader(_loc1_.url,null,this.onCursorLoaded);
               }
               else
               {
                  this.m_consumableCursor = new Cursor_SpecialPower(1,1);
               }
            }
            return this.m_consumableCursor;
         }
         if(null != this.m_highlightedPlayer)
         {
            return new Cursor_SpecialPower(1,1);
         }
         if(null != this.m_highlightedEnemy)
         {
            return new Cursor_Attack(1,1);
         }
         return super.getCursor();
      }
      
      private function onCursorLoaded(param1:String, param2:BitmapData) : void
      {
         if(this.m_waitingForCursorImage)
         {
            this.m_waitingForCursorImage = false;
            this.m_consumableCursor = new Bitmap(param2);
            setCursor(this.m_consumableCursor);
         }
      }
      
      private function onBattleDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(ChallengeModeManager.instance.isInChallengeBattle() && ChallengeModeManager.instance.isRandomFleetChallenge() && ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
         {
            if(this.m_battle.battleResult == Battle.BATTLE_RESULT_WON)
            {
               ViralsManager.instance.feedGPVPVictoryTokens();
            }
            else
            {
               ViralsManager.instance.feedGPVPDefeatTokens();
            }
         }
         if(!this.addEndingDialog(param1.button) && param1.button != BattleBasePopup.AUTOSHARE_COMMENT && param1.button != BattleBasePopup.AUTOSHARE_TAUNT && param1.button != BattleBasePopup.AUTOSHARE_DIRECT && param1.button != BattleBasePopup.ALLIANCE_WIN_NEW && param1.button != BattleBasePopup.ALLIANCE_WIN_REVENGE)
         {
            if(this.m_isChallenge)
            {
               this.trackComment(COMMENT_SUPPRESS,null);
            }
            this.leaveBattleMode(param1.button);
         }
         if(param1.button == BattleBasePopup.SHARE_VILLAIN)
         {
            _loc2_ = ZGlobal.player.campaign.currentMap.villain;
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            if(_loc3_)
            {
               _loc4_ = _loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               _loc5_ = "defeated_villain_" + _loc3_.code;
               ViralsManager.instance.sendFeed(_loc5_,{"villain_name":_loc4_});
            }
         }
         else if(param1.button == BattleBasePopup.AUTOSHARE_COMMENT)
         {
            PopupManager.instance.push(new CommentPopup(this.onCommentPopupClosed));
         }
         else if(param1.button == BattleBasePopup.AUTOSHARE_TAUNT)
         {
            PopupManager.instance.push(new CommentTauntPopup(this.onCommentPopupClosed));
         }
         else if(param1.button == BattleBasePopup.AUTOSHARE_DIRECT)
         {
            _loc6_ = null;
            if(Boolean(param1.userData) && param1.userData.comment != null)
            {
               _loc6_ = param1.userData.comment as String;
            }
            this.leaveBattleMode(param1.button,_loc6_);
         }
         else if(param1.button == BattleBasePopup.ALLIANCE_WIN_NEW || param1.button == BattleBasePopup.ALLIANCE_WIN_REVENGE)
         {
            if(param1.button == BattleBasePopup.ALLIANCE_WIN_NEW)
            {
               ViralsManager.instance.sendFeed("alliance_win_new",param1.userData);
            }
            else if(param1.button == BattleBasePopup.ALLIANCE_WIN_REVENGE)
            {
               ViralsManager.instance.sendFeed("alliance_win_revenge",param1.userData);
            }
            this.leaveBattleMode(param1.button);
         }
      }
      
      private function onCommentPopupClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(param1.userData) && param1.userData.comment != null)
         {
            _loc2_ = param1.userData.comment as String;
         }
         if(param1.button == BattleBasePopup.EXIT)
         {
            this.trackComment(COMMENT_EXIT,_loc2_);
         }
         this.leaveBattleMode(param1.button,_loc2_);
      }
      
      private function trackComment(param1:String, param2:String) : void
      {
         var _loc3_:String = param2 != null && param2.length > 0 ? COMMENT_NOT_BLANK : COMMENT_BLANK;
         if(this.m_battle.battleResult == Battle.BATTLE_RESULT_WON)
         {
            if(ChallengeModeManager.instance.isRandomFleetChallenge())
            {
               if(ChallengeModeManager.instance.isPVEChallenge())
               {
                  if(ZGlobal.isVisiting())
                  {
                     StatsManager.count(COMMENT_KINGDOM,param1,"pvp_defender_wins",_loc3_);
                  }
                  else
                  {
                     StatsManager.count(COMMENT_KINGDOM,param1,"pve_repel_wins",_loc3_);
                  }
               }
               else
               {
                  StatsManager.count(COMMENT_KINGDOM,param1,"pvp_attacker_wins",_loc3_);
               }
            }
            else if(ZGlobal.isHome())
            {
               StatsManager.count(COMMENT_KINGDOM,param1,"pvp_repel_wins",_loc3_);
            }
            else if(ZGlobal.isVisiting())
            {
               StatsManager.count(COMMENT_KINGDOM,param1,"pvp_defender_wins",_loc3_);
            }
         }
         else if(ChallengeModeManager.instance.isRandomFleetChallenge())
         {
            if(ChallengeModeManager.instance.isPVEChallenge())
            {
               if(ZGlobal.isVisiting())
               {
                  StatsManager.count(COMMENT_KINGDOM,param1,"pvp_defender_loses",_loc3_);
               }
               else
               {
                  StatsManager.count(COMMENT_KINGDOM,param1,"pve_repel_loses",_loc3_);
               }
            }
            else
            {
               StatsManager.count(COMMENT_KINGDOM,param1,"pvp_attacker_loses",_loc3_);
            }
         }
         else if(ZGlobal.isHome())
         {
            StatsManager.count(COMMENT_KINGDOM,param1,"pvp_repel_loses",_loc3_);
         }
         else if(ZGlobal.isVisiting())
         {
            StatsManager.count(COMMENT_KINGDOM,param1,"pvp_defender_loses",_loc3_);
         }
      }
      
      private function onEpisodeDialogClosed(param1:GenericPopupEvent) : void
      {
         this.exitBattle();
      }
      
      private function addEndingDialog(param1:int) : Boolean
      {
         var _loc2_:IslandItem = null;
         var _loc3_:Boolean = false;
         if(Boolean(!this.m_isChallenge && !this.m_battle.isQuest) && Boolean(ZGlobal.player.campaign.currentMap) && ZGlobal.player.campaign.justCompletedMap)
         {
            _loc2_ = ZGlobal.player.campaign.currentMap.currentIslandItem;
            if(ZGlobal.player.campaign.getPreviousMastery(_loc2_.index) == 0)
            {
               _loc3_ = false;
               if(this.showEndingLetter())
               {
                  this.m_exitButton = param1;
                  _loc3_ = true;
                  return true;
               }
               if(!_loc3_)
               {
                  if(this.showEndingEpisode())
                  {
                     this.m_exitButton = param1;
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private function showEndingLetter() : Boolean
      {
         var _loc1_:String = ZGlobal.player.campaign.currentMapName;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc1_,GameItem) as GameItem;
         var _loc3_:LetterItemWrapper = new LetterItemWrapper(_loc2_);
         var _loc4_:String = _loc3_.letterVersion;
         if(Boolean(_loc3_.endingLetter) && !ZGlobal.player.hasSeenDialog("letter",_loc3_.endingLetter))
         {
            PopupManager.instance.push(new LetterPopup(_loc3_.endingLetter,this.onLetterClosed,_loc4_));
            return true;
         }
         return false;
      }
      
      private function showEndingEpisode() : Boolean
      {
         var _loc1_:String = ZGlobal.player.campaign.currentMapName;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc1_,GameItem) as GameItem;
         var _loc3_:EpisodeItemWrapper = new EpisodeItemWrapper(_loc2_);
         if(Boolean(_loc3_.endingEpisode) && !ZGlobal.player.hasSeenDialog("episode",_loc3_.endingEpisode))
         {
            PopupManager.instance.push(new EpisodePopup(_loc3_.endingEpisode,this.onEpisodeClosed),0,true,false);
            return true;
         }
         return false;
      }
      
      private function onLetterClosed(param1:Event) : void
      {
         if(!this.showEndingEpisode() && this.m_exitButton >= 0)
         {
            this.leaveBattleMode(this.m_exitButton);
            this.m_exitButton = -1;
         }
      }
      
      private function onEpisodeClosed(param1:Event) : void
      {
         if(this.m_exitButton >= 0)
         {
            this.leaveBattleMode(this.m_exitButton);
            this.m_exitButton = -1;
         }
      }
      
      private function storeAllies(param1:Dictionary) : void
      {
         var _loc2_:String = null;
         this.m_allies = new Array();
         for(_loc2_ in param1)
         {
            if(ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) == null)
            {
               this.m_allies.push(_loc2_);
            }
         }
      }
      
      private function handleComment(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = "";
         if(ZGlobal.autopublishFeedVarient == ZGlobal.EXPERIMENT_AUTOPUBLISH_W2W || ZGlobal.autopublishFeedVarient == ZGlobal.EXPERIMENT_MANUALPUBLISH_W2W)
         {
            _loc2_ = ZGlobal.hostPlayer.uid;
            _loc3_ = "_w2w";
         }
         var _loc4_:String = "";
         var _loc5_:Boolean = false;
         if(ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
         {
            _loc2_ = null;
            _loc4_ = "g_";
            _loc3_ = "";
            _loc5_ = true;
         }
         var _loc6_:String = ZGlobal.hostPlayer.firstName;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Object = {};
         var _loc10_:String = param1 != null && param1.length > 0 ? COMMENT_NOT_BLANK : COMMENT_BLANK;
         if(this.m_challengerName == null || this.m_challengerName.length == 0)
         {
            this.m_challengerName = ZGameUtils.ZlocT("Items","villain18_firstName");
         }
         if(this.m_battle.battleResult == Battle.BATTLE_RESULT_WON)
         {
            if(ChallengeModeManager.instance.isRandomFleetChallenge())
            {
               if(ChallengeModeManager.instance.isPVEChallenge())
               {
                  if(ZGlobal.isVisiting())
                  {
                     _loc7_ = "pvp_defender_wins" + _loc3_;
                     _loc9_ = {
                        "invader":this.m_challengerName,
                        "victim":_loc6_
                     };
                     StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,"pvp_defender_wins",_loc10_);
                     if(param1.length > 0)
                     {
                        TransactionManager.addTransaction(new TSetDefenderComment(ChallengeModeManager.instance.currentChallengerID(),param1));
                     }
                  }
                  else
                  {
                     _loc2_ = null;
                     _loc7_ = "pve_repel_wins";
                     StatsManager.count(COMMENT_KINGDOM,COMMENT_POST,"pve_repel_wins",_loc10_);
                  }
               }
               else
               {
                  _loc8_ = _loc4_ + "pvp_attacker_wins";
                  StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_TAUNT,_loc8_,_loc10_);
                  if(_loc8_ == "pvp_attacker_wins" && PrisonCampManager.instance.isHomePrisonCampBuilt())
                  {
                     _loc8_ = "pc_" + _loc8_;
                  }
                  _loc7_ = _loc8_ + _loc3_;
                  _loc9_ = {"host":_loc6_};
                  if(param1.length > 0 && !_loc5_)
                  {
                     TransactionManager.addTransaction(new TSetInvasionComment(ZGlobal.player.uid,param1));
                  }
               }
            }
            else if(ZGlobal.isHome())
            {
               _loc2_ = ChallengeModeManager.instance.currentChallengerID();
               _loc8_ = _loc4_ + "pvp_repel_wins";
               _loc7_ = _loc8_ + _loc3_;
               _loc9_ = {"invader":this.m_challengerName};
               StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_TAUNT,_loc8_,_loc10_);
            }
            else if(ZGlobal.isVisiting())
            {
               _loc8_ = _loc4_ + "pvp_defender_wins";
               _loc7_ = _loc8_ + _loc3_;
               _loc9_ = {
                  "invader":this.m_challengerName,
                  "victim":_loc6_
               };
               StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,_loc8_,_loc10_);
               if(param1.length > 0)
               {
                  TransactionManager.addTransaction(new TSetDefenderComment(ChallengeModeManager.instance.currentChallengerID(),param1));
               }
            }
         }
         else if(ChallengeModeManager.instance.isRandomFleetChallenge())
         {
            if(ChallengeModeManager.instance.isPVEChallenge())
            {
               if(ZGlobal.isVisiting())
               {
                  _loc7_ = "pvp_defender_loses" + _loc3_;
                  _loc9_ = {
                     "invader":this.m_challengerName,
                     "victim":_loc6_
                  };
                  StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,"pvp_defender_loses",_loc10_);
               }
               else
               {
                  _loc2_ = null;
                  _loc7_ = "pve_repel_loses";
                  StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,"pve_repel_loses",_loc10_);
               }
            }
            else
            {
               _loc8_ = _loc4_ + "pvp_attacker_loses";
               _loc7_ = _loc8_ + _loc3_;
               _loc9_ = {"host":_loc6_};
               StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,_loc8_,_loc10_);
            }
         }
         else if(ZGlobal.isHome())
         {
            _loc2_ = ChallengeModeManager.instance.currentChallengerID();
            _loc8_ = _loc4_ + "pvp_repel_loses";
            _loc7_ = _loc8_ + _loc3_;
            _loc9_ = {"invader":this.m_challengerName};
            StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,_loc8_,_loc10_);
         }
         else if(ZGlobal.isVisiting())
         {
            _loc8_ = _loc4_ + "pvp_defender_loses";
            _loc7_ = _loc8_ + _loc3_;
            _loc9_ = {
               "invader":this.m_challengerName,
               "victim":_loc6_
            };
            StatsManager.count(COMMENT_KINGDOM,COMMENT_POST_COMMENT,_loc8_,_loc10_);
         }
         if(_loc7_)
         {
            ViralsManager.instance.sendFeedWithComment(_loc7_,_loc9_,param1,_loc2_);
         }
      }
      
      private function leaveBattleMode(param1:int, param2:String = null) : void
      {
         var _loc3_:Boolean = false;
         if(param2 != null)
         {
            this.handleComment(param2);
         }
         else if(param1 == BattleBasePopup.EXIT)
         {
            _loc3_ = Boolean(this.m_battle) && this.m_battle.battleResult == Battle.BATTLE_RESULT_RETREAT;
            if(this.m_isPVPInitialInvasion && _loc3_)
            {
               PVPManager.instance.initialInvasionRetreated();
               Zlab.processManager.schedule(100,this,this.returnToHomeIsland);
               if(this.m_isChallenge)
               {
                  ChallengeModeManager.instance.exitChallengeBattle();
               }
               return;
            }
         }
         else if(param1 == BattleBasePopup.SHARE)
         {
            ViralsManager.instance.sendCampaignBattleWonFeed();
         }
         else if(param1 == BattleBasePopup.REMATCH)
         {
            this.startRematch();
         }
         else if(param1 == BattleBasePopup.INVITE)
         {
            ZGlobal.switchToTab("invite");
         }
         else if(param1 != BattleBasePopup.INVITE_RETREAT)
         {
            if(param1 == BattleBasePopup.REQUEST_ENERGY)
            {
               ViralsManager.instance.requestEnergy();
            }
            else if(param1 == BattleBasePopup.DOMINATION_WIN_NEW)
            {
               ViralsManager.instance.sendFeed("dominance_win_new",{});
            }
            else if(param1 == BattleBasePopup.DOMINATION_WIN_REVENGE)
            {
               ViralsManager.instance.sendFeed("dominance_win_revenge",{});
            }
         }
         if(!this.m_isChallenge && ZGlobal.player.campaign.justCompletedMap)
         {
            this.m_exitToIslandWorld = true;
         }
         this.exitBattle();
      }
      
      protected function startRematch() : void
      {
         this.m_battle.rematch();
      }
      
      private function showEndingSpeech(param1:String) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:SpeechItemWrapper = new SpeechItemWrapper(_loc2_);
         var _loc4_:String = _loc3_.endingSpeech;
         if((Boolean(_loc4_)) && !ZGlobal.player.hasSeenSpeech(_loc4_))
         {
            PopupManager.instance.push(new SpeechPopup(_loc4_),0,true,false);
         }
      }
   }
}

