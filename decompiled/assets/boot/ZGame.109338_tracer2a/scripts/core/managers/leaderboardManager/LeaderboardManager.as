package core.managers.leaderboardManager
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.ConsumableItem;
   import core.managers.ChallengeModeManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.campaignManager.CampaignManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.ManaDispatcher;
   import dispatchers.ResearchDispatcher;
   import dispatchers.ResourceDispatcher;
   import dispatchers.StrategicDispatcher;
   import displays.popups.leaderboard.LeaderboardCompletePopup;
   import displays.popups.leaderboard.LeaderboardPlaceChangedManager;
   import displays.popups.leaderboard.LeaderboardSurfacingPopup;
   import displays.popups.leaderboard.LeaderboardUpdatedPopup;
   import events.ExperienceUpdatedEvent;
   import events.ResearchUpdatedEvent;
   import events.ResourceUpdatedEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import init.CompleteMonitor;
   import transactions.TGetLeaderBoard;
   import utils.ZGameTimeUtil;
   import zlabs.Zlab;
   import zlabs.ZlabUtil;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class LeaderboardManager extends EventDispatcher
   {
      
      public static var instance:LeaderboardManager = new LeaderboardManager();
      
      public static const LEADERBOARDS_EXPERIMENT_ACTIVE:int = 2;
      
      public static const LEADERBOARD_COMPLETE:String = "leaderboardcomplete";
      
      public static const LEADERBOARD_PLACE_CHANGED:String = "leaderboardplacechanged";
      
      public static const LEADERBOARD_CAMPAIGN_BATTLE_COMPLETE:String = "leaderboardcampaignbattlecomplete";
      
      public static const LEADERBOARD_PVP_BATTLE_COMPLETE:String = "leaderboardpvpbattlecomplete";
      
      public static const LEADERBOARD_REWARD_COLLECTED:String = "leaderboardrewardcollected";
      
      public static const LEADERBOARD_REWARD_AVAILABLE:String = "leaderboardrewardavailable";
      
      public static const LEADERBOARD_HUD_ENABLED:String = "leaderboardhudenabled";
      
      public static const LEADERBOARD_IGNORE_TRANSACTIONS:String = "leaderboardignoretransactions";
      
      public static const LEADERBOARD_SUPRESS_SURFACING:String = "leaderboardsuppresssurfacing";
      
      public static const LEADERBOARD_UPDATE_POSITION:String = "leaderboardupdateposition";
      
      public static const LEADERBOARD_SUMMARY_CLOSED:String = "leaderboardsummaryclosed";
      
      public static const PVP_NONE:int = -1;
      
      public static const PVP_INVASION:int = 0;
      
      public static const PVP_ASSIST:int = 1;
      
      private static const SEEN_FLAG_FIRST_RESOURCE:String = "lb_firstresource";
      
      private static const SEEN_FLAG_FIRST_CAMPAIGN:String = "lb_firstcampaign";
      
      private static const SEEN_FLAG_SECOND_CAMPAIGN:String = "lb_secondcampaign";
      
      private static const SEEN_FLAG_FIRST_INFAMY:String = "lb_firstinfamy";
      
      private static const SEEN_FLAG_FIRST_HONOR:String = "lb_firsthonor";
      
      private static const SEEN_FLAG_FIRST_UNITS_KILLED:String = "lb_firstunitskilled";
      
      private static const SEEN_FLAG_FIRST_CRITICAL_HITS:String = "lb_firstcriticalhits";
      
      private static const SEEN_FLAG_FIRST_EXPANSIONS:String = "lb_firstexpansions";
      
      public static const SEEN_FLAG_COMPLETED_ON_INIT:String = "lb_completedinit";
      
      public static const COMPLETED_MASK:int = 134217728;
      
      public static const REWARD_MASK:int = 4026531840;
      
      private var m_leaderboards:Dictionary = null;
      
      private var m_uiOffset:Number = -1;
      
      private var m_surfaceCampaign:Boolean = false;
      
      private var m_surfaceSurvival:Boolean = false;
      
      private var m_surfaceSurvival2:Boolean = false;
      
      private var m_surfaceSurvival3:Boolean = false;
      
      private var m_surfaceSurvival4:Boolean = false;
      
      private var m_surfaceSurvival5:Boolean = false;
      
      private var m_surfaceSurvivalDamage:Boolean = false;
      
      private var m_surfacePvp:int = -1;
      
      private var m_surfaceTend:Boolean = false;
      
      private var m_ignoringTransactions:Boolean = false;
      
      private var m_surfacingSuppressed:Boolean = false;
      
      private var m_surfaceExpansionHint:Boolean = false;
      
      private var m_surfaceCriticalHitsHint:Boolean = false;
      
      private var m_surfaceUnitsKilledHint:Boolean = false;
      
      public function LeaderboardManager()
      {
         super();
      }
      
      public function register(param1:Object, param2:Object) : void
      {
         var _loc5_:String = null;
         var _loc3_:int = WorldResourceManager.instance.numResources;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc4_);
            ResourceDispatcher.instance.addEventListener(_loc5_,this.onResourceUpdated);
            _loc4_++;
         }
         LeaderboardPlaceChangedManager.instance.init();
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_DAMAGED,this.onUnitDamaged);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.CAMPAIGN_BATTLE_WON,this.onCampaignBattleWon);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.SURVIVAL_BATTLE_WON,this.onSurvivalBattleWon);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ENTERED,this.onStrategicMapEntered);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.EXPANSION_PURCHASED,this.onExpansionPurchased);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ALLY_TEND,this.onAllyTend);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.VILLAIN_TOKEN_AWARDED,this.onVillainTokenAwarded);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.BAD_XP,this.onInfamy);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.GOOD_XP,this.onHonor);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.EXPERIENCE,this.onExperience);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_VISUAL_KILL,this.onUnitKilled);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_VISUAL_HIT,this.onUnitHit);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_POWER_USED,this.onUnitPowerUsed);
         ResearchDispatcher.instance.addEventListener(ResearchUpdatedEvent.UPGRADE_ADDED,this.onResearchComplete);
         PVPManager.instance.addEventListener(PVPManager.WHITE_KNIGHT_REPEL,this.onWhiteKnightRepel);
         addEventListener(LEADERBOARD_COMPLETE,this.onLeaderboardCompleted);
         addEventListener(LEADERBOARD_IGNORE_TRANSACTIONS,this.onIgnoreTransactions);
         addEventListener(LEADERBOARD_SUPRESS_SURFACING,this.onSuppressSurfacing);
         addEventListener(LEADERBOARD_UPDATE_POSITION,this.onUIWidthOffsetUpdated);
         addEventListener(LEADERBOARD_PVP_BATTLE_COMPLETE,this.onPvpBattleComplete);
         GameModeManager.instance.addEventListener(GMIsland.ISLAND_MODE_ENTERED,this.onIslandMapEntered);
         ManaDispatcher.instance.addEventListener(ManaDispatcher.AMOUNT_USED,this.onPlayerManaUsed);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated);
         this.populateLeaderboards();
         this.initFromData(param2.world.leaderboard);
         if(param1.leaderboards)
         {
            this.loadLeaderboards(param1.leaderboards);
         }
         if(this.setHUDEnabled())
         {
            this.updateInteresting();
         }
      }
      
      public function get leaderboards() : Dictionary
      {
         return this.m_leaderboards;
      }
      
      public function get uiOffset() : Number
      {
         return this.m_uiOffset;
      }
      
      public function init() : void
      {
         TransactionManager.addTransaction(new TGetLeaderBoard(this.getActiveNames(),this.onLeaderBoardLoaded),true);
      }
      
      public function updateInteresting() : void
      {
         var _loc2_:Leaderboard = null;
         var _loc1_:Boolean = false;
         for each(_loc2_ in this.m_leaderboards)
         {
            if(_loc2_.isInteresting)
            {
               dispatchEvent(new Event(LeaderboardManager.LEADERBOARD_REWARD_AVAILABLE));
               return;
            }
         }
         dispatchEvent(new Event(LeaderboardManager.LEADERBOARD_REWARD_COLLECTED));
      }
      
      public function getOrderedIDs() : Array
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in ZGlobal.gameSettings.getXML().leaderboards.leaderboard)
         {
            _loc3_ = this.calcID(_loc2_);
            if(this.m_leaderboards[_loc3_])
            {
               _loc1_.push(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function showCompletedLeaderboards(param1:CompleteMonitor = null) : Boolean
      {
         var _loc4_:String = null;
         var _loc5_:Leaderboard = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:LeaderboardCompletePopup = null;
         var _loc2_:Boolean = false;
         var _loc3_:Array = this.getOrderedIDs();
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = this.leaderboards[_loc4_];
            _loc6_ = _loc5_.getDateState();
            if(_loc6_ == ZGameTimeUtil.DATE_STATUS_LATE)
            {
               _loc7_ = _loc5_.getValue(ZGlobal.player.uid);
               if(_loc7_ > 0)
               {
                  _loc8_ = new LeaderboardCompletePopup(_loc5_);
                  PopupManager.instance.push(_loc8_);
                  _loc2_ = true;
                  if(param1)
                  {
                     param1.addDispatcher(_loc8_);
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function updateResource(param1:String, param2:int) : void
      {
         var _loc3_:Leaderboard = null;
         if(!this.m_ignoringTransactions && param2 < 0)
         {
            for each(_loc3_ in this.m_leaderboards)
            {
               if(_loc3_.type == Leaderboard.TYPE_RESOURCE)
               {
                  if(_loc3_.active)
                  {
                     if(_loc3_.matchesMetric(param1))
                     {
                        _loc3_.updateValue(Math.abs(param2),ZGlobal.player.uid);
                        this.updateInteresting();
                        this.triggerSurfacingPopup(_loc3_,null);
                     }
                  }
               }
            }
         }
      }
      
      private function updateDamage(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_DAMAGE);
      }
      
      private function updateGPVPDamage(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_GPVP_DAMAGE);
      }
      
      private function updateSurvivalDamage(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_SURVIVAL_DAMAGE);
         this.m_surfaceSurvivalDamage = true;
      }
      
      private function updateInfamy(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_INFAMY);
      }
      
      private function updateHonor(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_HONOR);
      }
      
      private function updateUnitsKilled(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_UNITS_KILLED);
      }
      
      private function updateCriticalHits(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_CRITICAL_HITS);
      }
      
      private function updateExpansions(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_EXPANSIONS);
      }
      
      private function updateNeighborTends(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_NEIGHBOR_TENDS);
      }
      
      private function updateResearchUpdates(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_RESEARCH_UPGRADES);
      }
      
      private function updateAllyTend(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_NEIGHBOR_TENDS);
      }
      
      private function updateVillainTokens(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_VILLAIN_TOKENS);
      }
      
      private function updateElementZConsumed(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_ELEMENT_Z_CONSUMED);
      }
      
      private function updateWhiteKnightRepels(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_WHITE_KNIGHT_REPELS);
      }
      
      public function updateDominationScoreGained(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_DOMINATION_SCORE_GAINED);
      }
      
      private function updatePowerUpAddict(param1:int) : void
      {
         this.updateGenericBoards(param1,Leaderboard.TYPE_POWER_UP_ADDICT);
      }
      
      private function updateGenericBoards(param1:int, param2:String) : void
      {
         var _loc3_:Leaderboard = null;
         if(param1 > 0)
         {
            for each(_loc3_ in this.m_leaderboards)
            {
               if(_loc3_.type == param2)
               {
                  if(_loc3_.active)
                  {
                     _loc3_.updateValue(param1,ZGlobal.player.uid);
                     this.updateInteresting();
                  }
               }
            }
         }
      }
      
      private function updateSurvival(param1:int, param2:String) : void
      {
         var _loc3_:Leaderboard = null;
         var _loc4_:int = 0;
         if(param1 > 0)
         {
            for each(_loc3_ in this.m_leaderboards)
            {
               if(_loc3_.type == param2)
               {
                  if(_loc3_.getValue(ZGlobal.player.uid) < param1)
                  {
                     _loc4_ = _loc3_.getDateState();
                     if(_loc4_ != ZGameTimeUtil.DATE_STATUS_LATE)
                     {
                        _loc3_.setValue(param1,ZGlobal.player.uid);
                     }
                  }
               }
            }
         }
      }
      
      private function updateCampaign(param1:String, param2:int) : void
      {
         var _loc3_:Leaderboard = null;
         var _loc4_:int = 0;
         if(param2 > 0)
         {
            for each(_loc3_ in this.m_leaderboards)
            {
               if(_loc3_.type == param1)
               {
                  _loc4_ = _loc3_.getDateState();
                  if(_loc4_ != ZGameTimeUtil.DATE_STATUS_LATE)
                  {
                     _loc3_.setValue(param2,ZGlobal.player.uid);
                  }
               }
            }
         }
      }
      
      private function triggerSurfacingPopup(param1:Leaderboard, param2:Object) : Boolean
      {
         var _loc3_:LeaderboardSurfacingPopup = null;
         if(this.m_surfacingSuppressed)
         {
            return false;
         }
         if(param1.active && !LeaderboardUpdatedPopup.ACTIVE)
         {
            if(param1.checkGate())
            {
               if(param1.type == Leaderboard.TYPE_INFAMY)
               {
                  if(!this.updateFlag(SEEN_FLAG_FIRST_INFAMY,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_HONOR)
               {
                  if(!this.updateFlag(SEEN_FLAG_FIRST_HONOR,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_DAMAGE)
               {
                  if(this.m_surfacePvp == PVP_NONE && !this.checkFlag(SEEN_FLAG_FIRST_CAMPAIGN,param2))
                  {
                     return false;
                  }
                  if(!this.updateFlag(SEEN_FLAG_SECOND_CAMPAIGN,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_RESOURCE)
               {
                  if(!this.updateFlag(SEEN_FLAG_FIRST_RESOURCE,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_CAMPAIGN)
               {
                  if(!this.updateFlag(SEEN_FLAG_FIRST_CAMPAIGN,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_UNITS_KILLED)
               {
                  if(this.m_surfaceUnitsKilledHint == false)
                  {
                     return false;
                  }
                  if(!this.updateFlag(SEEN_FLAG_FIRST_UNITS_KILLED,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_CRITICAL_HITS)
               {
                  if(this.m_surfaceCriticalHitsHint == false)
                  {
                     return false;
                  }
                  if(!this.updateFlag(SEEN_FLAG_FIRST_CRITICAL_HITS,param2))
                  {
                     return false;
                  }
               }
               else if(param1.type == Leaderboard.TYPE_EXPANSIONS)
               {
                  if(!this.updateFlag(SEEN_FLAG_FIRST_EXPANSIONS,param2))
                  {
                     return false;
                  }
               }
               _loc3_ = new LeaderboardSurfacingPopup(param1);
               PopupManager.instance.push(_loc3_);
               return true;
            }
         }
         return false;
      }
      
      private function checkFlag(param1:String, param2:Object) : Boolean
      {
         if(param2)
         {
            return param2[param1];
         }
         return ZGlobal.player.getSeenFlag(param1) != 0;
      }
      
      private function updateFlag(param1:String, param2:Object) : Boolean
      {
         if(this.checkFlag(param1,param2))
         {
            return false;
         }
         ZGlobal.player.setSeenFlag(param1);
         return true;
      }
      
      private function initFromData(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1)
         {
            for(_loc2_ in param1)
            {
               if(this.m_leaderboards[_loc2_])
               {
                  _loc3_ = int(param1[_loc2_]);
                  _loc4_ = ZGameTimeUtil.instance.getDateStatus(null,this.m_leaderboards[_loc2_].xml);
                  if(_loc4_ == ZGameTimeUtil.DATE_STATUS_LATE)
                  {
                     if((_loc3_ & COMPLETED_MASK) != 0)
                     {
                        this.removeLeaderboard(_loc2_);
                        continue;
                     }
                     dispatchEvent(new Event(LEADERBOARD_REWARD_AVAILABLE));
                  }
                  _loc5_ = (_loc3_ & REWARD_MASK) >> 28;
                  _loc6_ = 0;
                  while(_loc6_ < Leaderboard.MAX_REWARDS)
                  {
                     if((_loc5_ & 1 << _loc6_) != 0)
                     {
                        this.m_leaderboards[_loc2_].completedRewards[_loc6_] = true;
                     }
                     _loc6_++;
                  }
               }
            }
         }
      }
      
      private function onPvpBattleComplete(param1:WorldEvent) : void
      {
         this.m_surfacePvp = param1.eventData as int;
         this.m_surfaceTend = false;
      }
      
      private function onLeaderboardCompleted(param1:WorldEvent) : void
      {
         this.removeLeaderboard(param1.eventData as String);
      }
      
      private function onIgnoreTransactions(param1:WorldEvent) : void
      {
         this.m_ignoringTransactions = param1.eventData;
      }
      
      private function onSuppressSurfacing(param1:WorldEvent) : void
      {
         this.m_surfacingSuppressed = param1.eventData;
      }
      
      private function removeLeaderboard(param1:String) : void
      {
         delete this.m_leaderboards[param1];
         this.setHUDEnabled();
      }
      
      private function onUnitDamaged(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = param1.eventData.target;
         if(Boolean(param1.eventData.enemyFleet) || !_loc2_.fleet.isOwnedByPlayer(ZGlobal.player.uid))
         {
            this.updateDamage(param1.eventData.damage);
            if(ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
            {
               this.updateGPVPDamage(param1.eventData.damage);
            }
            else if(SurvivalModeManager.instance.isInSurvivalBattle())
            {
               this.updateSurvivalDamage(param1.eventData.damage);
            }
         }
      }
      
      private function onInfamy(param1:ExperienceUpdatedEvent) : void
      {
         this.updateInfamy(param1.newAmount - param1.oldAmount);
      }
      
      private function onHonor(param1:ExperienceUpdatedEvent) : void
      {
         this.updateHonor(param1.newAmount - param1.oldAmount);
         if(ZGlobal.isVisiting())
         {
            this.m_surfaceTend = true;
         }
      }
      
      private function onExperience(param1:ExperienceUpdatedEvent) : void
      {
         var _loc2_:int = param1.newAmount - param1.oldAmount;
         this.updateGenericBoards(_loc2_,Leaderboard.TYPE_XP);
      }
      
      private function onUnitKilled(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData) && Boolean(param1.eventData.attacker != null) && (param1.eventData.attacker as BattleObject).fleet.isOwnedByPlayer(ZGlobal.player.uid) == true)
         {
            this.updateUnitsKilled(1);
            this.m_surfaceUnitsKilledHint = true;
            if(param1.eventData.critical != null && param1.eventData.critical == true)
            {
               this.updateCriticalHits(1);
               this.m_surfaceCriticalHitsHint = true;
            }
         }
      }
      
      private function onUnitHit(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData && param1.eventData.critical != null && param1.eventData.attacker != null) && Boolean((param1.eventData.attacker as BattleObject).fleet.isOwnedByPlayer(ZGlobal.player.uid) == true) && param1.eventData.critical == true)
         {
            this.updateCriticalHits(1);
            this.m_surfaceCriticalHitsHint = true;
         }
      }
      
      private function onUnitPowerUsed(param1:WorldEvent) : void
      {
         var _loc2_:ConsumableItem = param1.eventData.consumableItem as ConsumableItem;
         if(_loc2_.secondary != true)
         {
            this.updatePowerUpAddict(1);
         }
      }
      
      private function onPlayerManaUsed(param1:WorldEvent) : void
      {
         this.updateElementZConsumed(int(param1.eventData));
      }
      
      private function onExpansionPurchased(param1:WorldEvent) : void
      {
         this.updateExpansions(1);
         this.m_surfaceExpansionHint = true;
      }
      
      private function onAllyTend(param1:WorldEvent) : void
      {
         this.updateAllyTend(1);
      }
      
      private function onVillainTokenAwarded(param1:WorldEvent) : void
      {
         this.updateVillainTokens(1);
      }
      
      private function onResearchComplete(param1:Event) : void
      {
         this.updateResearchUpdates(1);
      }
      
      private function onWhiteKnightRepel(param1:WorldEvent) : void
      {
         this.updateWhiteKnightRepels(1);
      }
      
      private function onSurvivalBattleWon(param1:WorldEvent) : void
      {
         switch(param1.eventData.set)
         {
            case SurvivalModeManager.SET_NAME_1:
               this.m_surfaceSurvival = true;
               this.updateSurvival(param1.eventData.round as int,Leaderboard.TYPE_SURVIVAL);
               break;
            case SurvivalModeManager.SET_NAME_2:
               this.m_surfaceSurvival2 = true;
               this.updateSurvival(param1.eventData.round as int,Leaderboard.TYPE_SURVIVAL2);
               break;
            case SurvivalModeManager.SET_NAME_3:
               this.m_surfaceSurvival3 = true;
               this.updateSurvival(param1.eventData.round as int,Leaderboard.TYPE_SURVIVAL3);
               break;
            case SurvivalModeManager.SET_NAME_5:
               this.m_surfaceSurvival4 = true;
               this.updateSurvival(param1.eventData.round as int,Leaderboard.TYPE_SURVIVAL4);
               break;
            case SurvivalModeManager.SET_NAME_6:
               this.m_surfaceSurvival5 = true;
               this.updateSurvival(param1.eventData.round as int,Leaderboard.TYPE_SURVIVAL5);
         }
      }
      
      private function onCampaignBattleWon(param1:WorldEvent) : void
      {
         this.updateCampaign(param1.eventData.leaderboardId,param1.eventData.index);
         this.m_surfaceCampaign = true;
      }
      
      private function onStrategicMapEntered(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         if(this.m_surfaceCampaign)
         {
            _loc2_ = ZGlobal.player.campaign.currentCampaignName;
            _loc3_ = CampaignManager.instance.getCampaignDefinition(_loc2_);
            this.doSurfacing([_loc3_.@leaderboardId.toString(),Leaderboard.TYPE_DAMAGE,Leaderboard.TYPE_UNITS_KILLED,Leaderboard.TYPE_CRITICAL_HITS]);
            this.m_surfaceCampaign = false;
         }
      }
      
      private function onIslandMapEntered(param1:Event) : void
      {
         if(ZGlobal.isHome())
         {
            if(this.m_surfacePvp == PVP_INVASION)
            {
               this.doSurfacing([Leaderboard.TYPE_DAMAGE,Leaderboard.TYPE_INFAMY,Leaderboard.TYPE_XP,Leaderboard.TYPE_GPVP_DAMAGE,Leaderboard.TYPE_UNITS_KILLED,Leaderboard.TYPE_CRITICAL_HITS]);
               this.m_surfacePvp = PVP_NONE;
            }
            else if(this.m_surfacePvp == PVP_ASSIST)
            {
               this.doSurfacing([Leaderboard.TYPE_DAMAGE,Leaderboard.TYPE_HONOR,Leaderboard.TYPE_XP,Leaderboard.TYPE_GPVP_DAMAGE,Leaderboard.TYPE_UNITS_KILLED,Leaderboard.TYPE_CRITICAL_HITS]);
               this.m_surfacePvp = PVP_NONE;
            }
            else if(this.m_surfaceTend)
            {
               this.doSurfacing([Leaderboard.TYPE_HONOR]);
               this.m_surfaceTend = false;
            }
            else if(this.m_surfaceExpansionHint)
            {
               this.doSurfacing([Leaderboard.TYPE_EXPANSIONS]);
               this.m_surfaceExpansionHint = false;
            }
            else if(this.m_surfaceSurvival)
            {
               this.doSurfacing([Leaderboard.TYPE_SURVIVAL]);
               this.m_surfaceSurvival = false;
               if(this.m_surfaceSurvivalDamage)
               {
                  this.doSurfacing([Leaderboard.TYPE_SURVIVAL_DAMAGE]);
                  this.m_surfaceSurvivalDamage = false;
               }
            }
            else if(this.m_surfaceSurvival2)
            {
               this.doSurfacing([Leaderboard.TYPE_SURVIVAL2]);
               this.m_surfaceSurvival2 = false;
               if(this.m_surfaceSurvivalDamage)
               {
                  this.doSurfacing([Leaderboard.TYPE_SURVIVAL_DAMAGE]);
                  this.m_surfaceSurvivalDamage = false;
               }
            }
            else if(this.m_surfaceSurvival3)
            {
               this.doSurfacing([Leaderboard.TYPE_SURVIVAL3]);
               this.m_surfaceSurvival3 = false;
               if(this.m_surfaceSurvivalDamage)
               {
                  this.doSurfacing([Leaderboard.TYPE_SURVIVAL_DAMAGE]);
                  this.m_surfaceSurvivalDamage = false;
               }
            }
            else if(this.m_surfaceSurvival4)
            {
               this.doSurfacing([Leaderboard.TYPE_SURVIVAL4]);
               this.m_surfaceSurvival4 = false;
               if(this.m_surfaceSurvivalDamage)
               {
                  this.doSurfacing([Leaderboard.TYPE_SURVIVAL_DAMAGE]);
                  this.m_surfaceSurvivalDamage = false;
               }
            }
            else if(this.m_surfaceSurvival5)
            {
               this.doSurfacing([Leaderboard.TYPE_SURVIVAL5]);
               this.m_surfaceSurvival5 = false;
               if(this.m_surfaceSurvivalDamage)
               {
                  this.doSurfacing([Leaderboard.TYPE_SURVIVAL_DAMAGE]);
                  this.m_surfaceSurvivalDamage = false;
               }
            }
            else if(this.m_surfaceSurvivalDamage)
            {
               this.doSurfacing([Leaderboard.TYPE_SURVIVAL_DAMAGE]);
               this.m_surfaceSurvivalDamage = false;
            }
         }
      }
      
      private function doSurfacing(param1:Array) : void
      {
         var _loc4_:String = null;
         var _loc5_:Leaderboard = null;
         var _loc2_:Object = ZlabUtil.cloneObject(ZGlobal.player.seenFlags);
         var _loc3_:Array = this.getOrderedIDs();
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = this.m_leaderboards[_loc4_];
            if(param1.indexOf(_loc5_.type) >= 0)
            {
               if(this.triggerSurfacingPopup(_loc5_,_loc2_))
               {
                  break;
               }
            }
         }
      }
      
      private function onResourceUpdated(param1:ResourceUpdatedEvent) : void
      {
         this.updateResource(param1.type,param1.newAmount - param1.oldAmount);
      }
      
      private function populateLeaderboards() : void
      {
         var _loc1_:XML = null;
         var _loc2_:int = 0;
         var _loc3_:Leaderboard = null;
         this.m_leaderboards = new Dictionary();
         for each(_loc1_ in ZGlobal.gameSettings.getXML().leaderboards.leaderboard)
         {
            _loc2_ = ZGameTimeUtil.instance.getDateStatus(null,_loc1_);
            if(_loc2_ != ZGameTimeUtil.DATE_STATUS_EARLY)
            {
               if(!this.ignoreDevLeaderboard(_loc1_))
               {
                  _loc3_ = new Leaderboard();
                  _loc3_.id = this.calcID(_loc1_);
                  _loc3_.type = _loc1_.@type;
                  _loc3_.xml = _loc1_;
                  this.m_leaderboards[_loc3_.id] = _loc3_;
               }
            }
         }
      }
      
      private function ignoreDevLeaderboard(param1:XML) : Boolean
      {
         if(!Config.DEBUG_MODE)
         {
            if(param1.@dev != undefined)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getActiveNames() : Array
      {
         var _loc2_:Leaderboard = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_leaderboards)
         {
            _loc1_.push(_loc2_.id);
         }
         return _loc1_;
      }
      
      private function shortDate(param1:String) : String
      {
         return param1.substr(0,param1.length - 5);
      }
      
      private function calcID(param1:XML) : String
      {
         var _loc2_:String = param1.@type;
         if(param1.@id != undefined)
         {
            _loc2_ += "-" + param1.@id;
         }
         return _loc2_;
      }
      
      private function onLeaderBoardLoaded(param1:Object) : void
      {
         this.loadLeaderboards(param1.value);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function loadLeaderboards(param1:Object) : void
      {
         var _loc2_:Object = null;
         for(_loc2_ in param1)
         {
            if(Boolean(param1[_loc2_]) && Boolean(this.m_leaderboards[_loc2_]))
            {
               this.m_leaderboards[_loc2_].addResults(param1[_loc2_]);
            }
         }
      }
      
      private function setHUDEnabled() : Boolean
      {
         var _loc2_:Leaderboard = null;
         var _loc1_:Boolean = false;
         for each(_loc2_ in this.m_leaderboards)
         {
            if(_loc2_.isVisible(true))
            {
               _loc1_ = true;
               break;
            }
         }
         dispatchEvent(new WorldEvent(LEADERBOARD_HUD_ENABLED,_loc1_));
         return _loc1_;
      }
      
      private function onQuestComplete(param1:WorldEvent) : void
      {
         this.setHUDEnabled();
      }
      
      private function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("leaderboardAutoMOTDLevel",4);
         if(param1.newAmount == _loc2_)
         {
            Zlab.processManager.schedule(500,this,this.showAutoMOTD);
         }
         this.setHUDEnabled();
      }
      
      private function showAutoMOTD() : void
      {
         MessageOfTheDayManager.instance.openMOTDPopupByName("motd_Leaderboards",true);
      }
      
      private function onUIWidthOffsetUpdated(param1:WorldEvent) : void
      {
         this.m_uiOffset = param1.eventData as Number;
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc2_:int = int(param1.transaction.rawResult.metadata.dominanceGained);
         if(_loc2_)
         {
            this.updateDominationScoreGained(_loc2_);
         }
      }
   }
}

