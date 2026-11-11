package core
{
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.questPower.QuestPower;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.SurveyManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.menuitem.SettingsUIItem;
   import dispatchers.EnergyDispatcher;
   import dispatchers.MessageDispatcher;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.ResourceDispatcher;
   import displays.cinema.Cinematics;
   import displays.popups.GenericPopup;
   import displays.popups.LetterPopup;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.popups.leaderboard.LeaderboardPopup;
   import displays.popups.quest.QuestPopup;
   import displays.screens.dominationMode.DominationModeChatInput;
   import events.CinematicsEvent;
   import events.EnergyUpdatedEvent;
   import events.FriendBarEvent;
   import events.FriendBarSlotEvent;
   import events.ResourceRewardEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.system.System;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class ZGameStats extends EventDispatcher
   {
      
      public static var instance:ZGameStats = new ZGameStats();
      
      public static const STATS_EXPANSION_ATTEMPT_SUCCESS:String = "stats.expansion.success";
      
      public static const STATS_EXPANSION_ATTEMPT_FAILURE:String = "stats.expansion.failure";
      
      public static const STATS_RESUME_CAMPAIGN_BATTLE:String = "stats.battle.resume.campaign";
      
      public static const STATS_RESUME_QUEST_BATTLE:String = "stats.battle.resume.quest";
      
      public static const STATS_LETTER_SHOW:String = "stats.letter.show";
      
      public static const STATS_STORE_VIEW:String = "stats.store.view";
      
      public static const STATS_INVENTORY_VIEW:String = "stats.inventory.view";
      
      public static const STATS_QUEST_TASK_COMPLETE:String = "stats.quest.task.complete";
      
      public static const STATS_FRIEND_INVITE:String = "stats.friend.invite";
      
      public static const STATS_FRIEND_ADD:String = "stats.friend.add";
      
      public static const STATS_UNIT_PARTS_PURCHASE:String = "stats.unitparts.purchase";
      
      public static const STATS_DYNAMIC_RESOURCE_ACTION:String = "stats.dynamicresource.action";
      
      public static const STATS_GENERIC_BUTTON_CLICKED:String = "stats.genericbutton.click";
      
      public static const STATS_GENERIC_DIALOG_ACTION:String = "stats.genericDialog.action";
      
      private static var battleDetails:Object = new Object();
      
      private static var battleResumed:Boolean = false;
      
      private static var doHeartbeat:Boolean = false;
      
      private static var buildCategories:Array = new Array();
      
      private static var inventoryCategories:Array = new Array();
      
      private static const PERF_FPS:String = "fps";
      
      private static const PERF_WIDTH:String = "client_width";
      
      private static const PERF_HEIGHT:String = "client_height";
      
      private static const PERF_MEM_USAGE:String = "mem_usage";
      
      private static const KB_PERF_MEM_USAGE:String = "kb_mem_usage";
      
      private static const PERF_UPDATE_INTERVAL:Number = 120000;
      
      private static const PERF_RATE:int = 10000;
      
      private static const STORE_VIEWS_RATE:int = 1000;
      
      private static const INVENTORY_VIEWS_RATE:int = 1000;
      
      private var m_perfFrameCount:int = 0;
      
      private var m_lastPerfUpdate:Number = 0;
      
      public function ZGameStats()
      {
         super();
         Zlab.mainStage.addEventListener(MouseEvent.CLICK,activity);
         if(active)
         {
            Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,onScreenEvent);
            MessageDispatcher.instance.addEventListener(SettingsUIItem.TOGGLE_MUSIC,onToggleMusic);
            MessageDispatcher.instance.addEventListener(SettingsUIItem.TOGGLE_SFX,onToggleSFX);
            Zlab.mainStage.addEventListener(SettingsUIItem.ZOOM_CHANGED,onZoomChanged);
            NeighborsDispatcher.instance.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,onFriendBarSlotClick);
            NeighborsDispatcher.instance.addEventListener(FriendBarEvent.MOVE,onFriendBarScroll);
            TutorialManager.instance.addEventListener(TutorialManager.QUEST_TASK_CLICKED,onQuestIconClicked);
            addEventListener(STATS_LETTER_SHOW,onLetterShow);
            addEventListener(STATS_STORE_VIEW,onStoreView);
            addEventListener(STATS_INVENTORY_VIEW,onInventoryView);
            addEventListener(STATS_FRIEND_INVITE,onFriendInvite);
            addEventListener(STATS_UNIT_PARTS_PURCHASE,onUnitPartsPurchase);
            addEventListener(STATS_DYNAMIC_RESOURCE_ACTION,onDynamicResourceDialogAction);
            addEventListener(STATS_GENERIC_BUTTON_CLICKED,onGenericButtonClicked);
            addEventListener(STATS_GENERIC_DIALOG_ACTION,onGenericDialogAction);
            LeaderboardManager.instance.addEventListener(LeaderboardManager.LEADERBOARD_PLACE_CHANGED,this.onLeaderboardPlaceChanged);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,onBattleStart);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,onBattleCompleteHost);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_POWERUP_CONSUMABLE_USED,onBattleConsumableUsed);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_USED,onBattleConsumableUsed);
            addEventListener(STATS_RESUME_CAMPAIGN_BATTLE,onBattleResume);
            addEventListener(STATS_RESUME_QUEST_BATTLE,onBattleResume);
            EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.ENERGY,onPlayerEnergyUpdated);
            EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.ENERGY_REGEN,onPlayerEnergyUpdated);
            EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.AMMO,onPlayerAmmoUpdated);
            EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.AMMO_REGEN,onPlayerAmmoUpdated);
            addEventListener(STATS_QUEST_TASK_COMPLETE,onQuestTaskComplete);
            addEventListener(STATS_EXPANSION_ATTEMPT_SUCCESS,onExpansionSuccess);
            addEventListener(STATS_EXPANSION_ATTEMPT_FAILURE,onExpansionFailure);
            PopupManager.instance.addEventListener(PopupManager.SHOW_POPUP,onShowPopup);
            PopupManager.instance.container.addEventListener(GenericPopupEvent.SELECTED,onPopupSelected,true);
            ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.ENERGY_PICKUP,onEnergyPickup);
            ResourceDispatcher.instance.addEventListener(ResourceRewardEvent.AMMO_PICKUP,onAmmoPickup);
            SurveyManager.getInstance().addEventListener(SurveyManager.SHOW_SCREEN,onShowSurvey);
            Zlab.mainStage.addEventListener(Cinematics.PLAY,onCinematicsEvent);
            Zlab.mainStage.addEventListener(Cinematics.INTERRUPT,onCinematicsEvent);
            Zlab.mainStage.addEventListener(Cinematics.FINISH,onCinematicsEvent);
            Zlab.mainStage.addEventListener(Cinematics.FAIL,onCinematicsEvent);
            Zlab.processManager.schedule(1,this,this.trackPerf);
         }
      }
      
      public static function get active() : Boolean
      {
         return GlobalEngine.getFlashVar("stats") != null && GlobalEngine.getFlashVar("stats").toString() == "1";
      }
      
      public static function activity(param1:Event = null) : void
      {
         doHeartbeat = true;
      }
      
      private static function onScreenEvent(param1:FullScreenEvent) : void
      {
         StatsManager.countSample(10000,"navigation","full_screen",param1.fullScreen ? "on" : "off");
      }
      
      private static function onQuestIconClicked(param1:WorldEvent) : void
      {
         StatsManager.countSample(100,"hud_icon","quest",param1.eventData as String);
      }
      
      private static function onFriendInvite(param1:Event) : void
      {
         StatsManager.countSample(100,"friend_bar","invite_friend");
      }
      
      private static function onFriendAdd(param1:Event) : void
      {
         StatsManager.countSample(100,"friend_bar","add_friend");
      }
      
      private static function onBattleStart(param1:Event) : void
      {
         var _loc3_:* = undefined;
         battleDetails = new Object();
         battleDetails.energy_used = 0;
         battleDetails.energy_start = ZGlobal.player.m_energy.energy;
         battleDetails.ammo_used = 0;
         battleDetails.ammo_start = ZGlobal.player.m_ammo.ammo;
         battleDetails.power_up = new Object();
         battleDetails.inventory_start = Utilities.clone(ZGlobal.player.inventory);
         battleDetails.units_start = currentBattle.playerUnitTally();
         battleDetails.allies_start = battleDetails.mercs_start = 0;
         var _loc2_:Fleet = ZGlobal.player.fleets.getFleetByName(currentBattle.getPlayerFleetName());
         for(_loc3_ in _loc2_.allies)
         {
            if(isNaN(_loc3_))
            {
               ++battleDetails.mercs_start;
            }
            else
            {
               ++battleDetails.allies_start;
            }
         }
         if(!battleResumed)
         {
            if(ZGlobal.player.campaign.currentMap != null && ZGlobal.player.campaign.currentMap.currentIslandItem != null)
            {
               StatsManager.count("game_actions","campaign",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString());
            }
         }
         else
         {
            battleResumed = false;
         }
      }
      
      private static function onBattleResume(param1:Event) : void
      {
         battleResumed = true;
         if(param1.type == STATS_RESUME_CAMPAIGN_BATTLE)
         {
            StatsManager.count("combat.campaign.resume",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString());
         }
         else if(param1.type == STATS_RESUME_QUEST_BATTLE)
         {
            StatsManager.count("combat.quest.resume",currentBattle.getEnemyFleetName());
         }
      }
      
      private static function onPlayerEnergyUpdated(param1:EnergyUpdatedEvent) : void
      {
         if(param1.newAmount < param1.oldAmount)
         {
            if(battleDetails != null)
            {
               battleDetails.energy_used += param1.oldAmount - param1.newAmount;
            }
         }
         if(param1.type == EnergyUpdatedEvent.ENERGY_REGEN)
         {
            StatsManager.count("energy","earn","regen","","","",param1.newAmount - param1.oldAmount);
         }
         if(param1.newAmount != param1.oldAmount && ExperimentsManager.instance.experimentGateEnabled(ExperimentsManager.EXPERIMENT_CAPTURE_ENERGY_STATS,ExperimentsManager.EXPERIMENT_CAPTURE_ENERGY_STATS_ENABLED.toString()))
         {
            StatsManager.count("client_energy","updated",(param1.newAmount - param1.oldAmount).toString(),"","","",param1.newAmount);
         }
      }
      
      private static function onPlayerAmmoUpdated(param1:EnergyUpdatedEvent) : void
      {
         if(param1.newAmount < param1.oldAmount)
         {
            if(battleDetails != null)
            {
               battleDetails.ammo_used += param1.oldAmount - param1.newAmount;
            }
         }
         if(param1.type == EnergyUpdatedEvent.AMMO_REGEN)
         {
            StatsManager.count("ammo","earn","regen","","","",param1.newAmount - param1.oldAmount);
         }
      }
      
      private static function onLetterShow(param1:WorldEvent) : void
      {
         StatsManager.count("dialog",param1.eventData as String);
      }
      
      private static function onUnitPartsPurchase(param1:WorldEvent) : void
      {
         StatsManager.count("dialog","research","buildable_part",param1.eventData.unitItem.name,param1.eventData.buyAllParts ? "buy_all_part" : "buy_1_part",param1.eventData.unitItem.subType);
      }
      
      private static function onDynamicResourceDialogAction(param1:WorldEvent) : void
      {
         StatsManager.count("dialog","BuyDynamicResourcesPopup",param1.eventData.action);
      }
      
      private static function onGenericButtonClicked(param1:WorldEvent) : void
      {
         if(param1.eventData.zclass)
         {
            StatsManager.count(param1.eventData.counter,param1.eventData.kingdom,param1.eventData.phylum,param1.eventData.zclass,param1.eventData.family,param1.eventData.genus);
         }
         else
         {
            StatsManager.count(param1.eventData.counter,param1.eventData.kingdom,param1.eventData.phylum,"click",param1.eventData.family,param1.eventData.genus);
         }
      }
      
      private static function onGenericDialogAction(param1:WorldEvent) : void
      {
         StatsManager.count(param1.eventData.counter,param1.eventData.kingdom,param1.eventData.phylum,param1.eventData.zclass,param1.eventData.family,param1.eventData.genus);
      }
      
      private static function onStoreView(param1:WorldEvent) : void
      {
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         if(buildCategories.length <= 0)
         {
            _loc2_ = ZGlobal.gameSettings.getBuildCategories();
            for each(_loc3_ in _loc2_)
            {
               buildCategories.push(_loc3_.@label);
            }
         }
         StatsManager.countSample(STORE_VIEWS_RATE,"store_views",buildCategories[param1.eventData.category as int],param1.eventData.page.toString());
      }
      
      private static function onInventoryView(param1:WorldEvent) : void
      {
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         if(inventoryCategories.length <= 0)
         {
            _loc2_ = ZGlobal.gameSettings.getInventoryCategories();
            for each(_loc3_ in _loc2_)
            {
               inventoryCategories.push(_loc3_.@label.toString());
            }
         }
         StatsManager.countSample(INVENTORY_VIEWS_RATE,"inventory_views",inventoryCategories[param1.eventData.category as int],param1.eventData.page.toString());
      }
      
      public static function get currentBattle() : Battle
      {
         var _loc1_:Battle = null;
         var _loc2_:Array = GameModeManager.instance.getActiveGameModes();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_] is GMBattle)
            {
               _loc1_ = _loc2_[_loc3_].battle;
               break;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      private static function onBattleConsumableUsed(param1:WorldEvent) : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:Object = null;
         var _loc2_:String = "";
         var _loc3_:String = "";
         if(param1.type == BattleDispatcher.BATTLE_CONSUMABLE_USED && param1.eventData.hasOwnProperty("id"))
         {
            if(QuestPower.isQuestPower(param1.eventData.id))
            {
               _loc3_ = "questpower";
            }
            else if(isNaN(param1.eventData.id))
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.id,GameItem) as GameItem;
               _loc2_ = _loc4_.name;
               _loc3_ = "merc";
            }
            else
            {
               _loc3_ = "ally";
            }
         }
         else if(param1.type == BattleDispatcher.BATTLE_POWERUP_CONSUMABLE_USED)
         {
            if(!battleDetails.power_up.hasOwnProperty(param1.eventData.item.code))
            {
               battleDetails.power_up[param1.eventData.item.code] = true;
            }
            _loc3_ = "powerup";
         }
         if(currentBattle.isGlobalPVP)
         {
            StatsManager.count("stranger_pvp","combat","consumable",param1.eventData.item.name,_loc3_,_loc2_);
         }
         else if(currentBattle.isChallenge)
         {
            StatsManager.count("combat.challenge.consumable",param1.eventData.item.name,_loc3_,_loc2_);
         }
         else if(currentBattle.isQuest)
         {
            StatsManager.count("combat.quest.consumable",currentBattle.getEnemyFleetName(),param1.eventData.item.name,_loc3_,_loc2_);
         }
         else if(currentBattle.isSurvivalMode)
         {
            StatsManager.count("combat.survival.consumable",currentBattle.getEnemyFleetName(),param1.eventData.item.name,_loc3_,_loc2_);
         }
         else if(currentBattle.isQuestSurvival)
         {
            StatsManager.count("combat.questSurvival.consumable",currentBattle.getEnemyFleetName(),param1.eventData.item.name,_loc3_,_loc2_);
         }
         else if(!currentBattle.isMechLab)
         {
            if(currentBattle.isDominationMode)
            {
               if(currentBattle.playerFleet.name == AlliancesManager.ALLIANCE_PLAYER_FLEET)
               {
                  StatsManager.count("combat.alliances.consumable",param1.eventData.item.name,_loc3_,_loc2_);
                  if(param1.eventData.alliance)
                  {
                     StatsManager.count("alliances.battle.consumable",param1.eventData.playerRank.toString(),param1.eventData.enemyRank.toString(),"0",param1.eventData.item.code);
                  }
               }
               else
               {
                  StatsManager.count("combat.dominance.consumable",param1.eventData.item.name,_loc3_,_loc2_);
               }
            }
            else if(currentBattle.isDeathMatchBattle)
            {
               _loc5_ = DeathMatchManager.instance.counterData;
               if(!_loc5_.band)
               {
                  _loc5_.band = "";
               }
               if(!_loc5_.level)
               {
                  _loc5_.level = "";
               }
               StatsManager.count("combat.deathmatch.consumable",_loc5_.band,_loc5_.level,param1.eventData.item.name);
            }
            else
            {
               StatsManager.count("combat.campaign.consumable",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),param1.eventData.item.name,_loc3_,_loc2_);
            }
         }
      }
      
      private static function onBattleCompleteHost(param1:WorldEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:Battle = null;
         var _loc7_:Object = null;
         var _loc8_:Boolean = false;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc2_:String = null;
         switch(param1.eventData.result)
         {
            case Battle.BATTLE_RESULT_LOST:
               _loc2_ = "loss";
               break;
            case Battle.BATTLE_RESULT_WON:
               _loc2_ = "win";
               break;
            case Battle.BATTLE_RESULT_RETREAT:
               _loc2_ = "retreat";
         }
         if(_loc2_)
         {
            battleDetails.energy_end = ZGlobal.player.m_energy.energy;
            battleDetails.ammo_end = ZGlobal.player.m_ammo.ammo;
            battleDetails.units_end = param1.eventData.battle.playerUnitTally();
            if(param1.eventData.battle.isDeathMatchBattle)
            {
               _loc6_ = param1.eventData.battle;
               _loc7_ = DeathMatchManager.instance.counterData;
               if(!_loc7_.band)
               {
                  _loc7_.band = "";
               }
               if(!_loc7_.level)
               {
                  _loc7_.level = "";
               }
               StatsManager.count("combat.deathmatch.result",_loc7_.band,_loc7_.level,_loc2_);
               for(_loc3_ in battleDetails.units_start)
               {
                  StatsManager.count("combat.deathmatch.unit.start",_loc7_.band,_loc7_.level,_loc3_,"","",battleDetails.units_start[_loc3_]);
                  StatsManager.count("combat.deathmatch.unit.end",_loc7_.band,_loc7_.level,_loc3_,"","",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
               }
            }
            if(param1.eventData.battle.isChallenge)
            {
               _loc6_ = param1.eventData.battle;
               _loc8_ = _loc6_.isGlobalPVP;
               if(_loc8_)
               {
                  StatsManager.count("stranger_pvp","combat","result",_loc2_);
                  StatsManager.count("stranger_pvp","combat","energy","used","","",battleDetails.energy_used);
                  StatsManager.count("stranger_pvp","combat","ammo","start","","",battleDetails.ammo_start);
                  StatsManager.count("stranger_pvp","combat","ammo","end","","",battleDetails.ammo_end);
                  StatsManager.count("stranger_pvp","combat","ammo","used","","",battleDetails.ammo_used);
               }
               else if(_loc6_.isDominationMode)
               {
                  if(_loc6_.getEnemyFleetName() == AlliancesManager.ALLIANCE_ENEMY_FLEET)
                  {
                     StatsManager.count("combat.alliances.result",_loc2_);
                  }
                  else
                  {
                     StatsManager.count("combat.dominance.result",_loc2_);
                  }
               }
               else
               {
                  StatsManager.count("combat.challenge.result",_loc2_);
                  if(param1.eventData.isStrikeTeamInvasion)
                  {
                     StatsManager.count("combat.challenge.mindcontrol.result",_loc2_);
                  }
                  StatsManager.count("combat.challenge.energy.start","","","","","",battleDetails.energy_start);
                  StatsManager.count("combat.challenge.energy.end","","","","","",battleDetails.energy_end);
                  StatsManager.count("combat.challenge.energy.used","","","","","",battleDetails.energy_used);
                  StatsManager.count("combat.challenge.ammo.start","","","","","",battleDetails.ammo_start);
                  StatsManager.count("combat.challenge.ammo.end","","","","","",battleDetails.ammo_end);
                  StatsManager.count("combat.challenge.ammo.used","","","","","",battleDetails.ammo_used);
               }
               for(_loc3_ in battleDetails.units_start)
               {
                  if(_loc8_)
                  {
                     StatsManager.count("stranger_pvp","combat","unit","start",_loc3_,"",battleDetails.units_start[_loc3_]);
                     StatsManager.count("stranger_pvp","combat","unit","end",_loc3_,"",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
                  }
                  else if(_loc6_.isDominationMode)
                  {
                     if(_loc6_.getEnemyFleetName() == AlliancesManager.ALLIANCE_ENEMY_FLEET)
                     {
                        StatsManager.count("combat.alliances.units.start",_loc3_,"","","","",battleDetails.units_start[_loc3_]);
                        StatsManager.count("combat.alliances.units.end",_loc3_,"","","","",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
                     }
                     else
                     {
                        StatsManager.count("combat.dominance.units.start",_loc3_,"","","","",battleDetails.units_start[_loc3_]);
                        StatsManager.count("combat.dominance.units.end",_loc3_,"","","","",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
                     }
                  }
                  else
                  {
                     StatsManager.count("combat.challenge.units.start",_loc3_,"","","","",battleDetails.units_start[_loc3_]);
                     StatsManager.count("combat.challenge.units.end",_loc3_,"","","","",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
                  }
               }
               if(battleDetails.mercs_start > 0)
               {
                  if(_loc8_)
                  {
                     StatsManager.count("stranger_pvp","combat","mercs","start","","",battleDetails.mercs_start);
                  }
                  else
                  {
                     StatsManager.count("combat.challenge.mercs.start","","","","","",battleDetails.mercs_start);
                  }
               }
               if(battleDetails.allies_start > 0)
               {
                  if(_loc8_)
                  {
                     StatsManager.count("stranger_pvp","combat","allies","start","","",battleDetails.allies_start);
                  }
                  else
                  {
                     StatsManager.count("combat.challenge.allies.start","","","","","",battleDetails.allies_start);
                  }
               }
            }
            else if(Boolean(param1.eventData.battle.isSurvivalMode) || Boolean(param1.eventData.battle.isMechLab) || Boolean(param1.eventData.battle.isQuest) || Boolean(param1.eventData.battle.isDominationMode) || Boolean(param1.eventData.battle.isQuestSurvival))
            {
               _loc9_ = "";
               _loc10_ = param1.eventData.battle.getEnemyFleetName();
               if(param1.eventData.battle.isSurvivalMode)
               {
                  _loc9_ = "survival";
               }
               else if(param1.eventData.battle.isQuest)
               {
                  _loc9_ = "quest";
               }
               else if(param1.eventData.battle.isQuestSurvival)
               {
                  _loc9_ = "questSurvival";
               }
               else if(param1.eventData.battle.isMechLab)
               {
                  _loc9_ = "mechlab";
               }
               else if(param1.eventData.battle.isDominationMode)
               {
                  _loc9_ = "domination";
                  if(param1.eventData.battle.getEnemyFleetName() == AlliancesManager.ALLIANCE_ENEMY_FLEET)
                  {
                     _loc9_ = "alliances";
                  }
               }
               StatsManager.count("combat." + _loc9_ + ".result",_loc10_,_loc2_);
               StatsManager.count("combat." + _loc9_ + ".energy.used",_loc10_,"","","","",battleDetails.energy_used);
               StatsManager.count("combat." + _loc9_ + ".ammo.start",param1.eventData.battle.getEnemyFleetName(),"","","","",battleDetails.ammo_start);
               StatsManager.count("combat." + _loc9_ + ".ammo.end",param1.eventData.battle.getEnemyFleetName(),"","","","",battleDetails.ammo_end);
               StatsManager.count("combat." + _loc9_ + ".ammo.used",param1.eventData.battle.getEnemyFleetName(),"","","","",battleDetails.ammo_used);
               for(_loc3_ in battleDetails.units_start)
               {
                  StatsManager.count("combat." + _loc9_ + ".units.start",_loc10_,_loc3_,"","","",battleDetails.units_start[_loc3_]);
                  StatsManager.count("combat." + _loc9_ + ".units.end",_loc10_,_loc3_,"","","",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
               }
               if(battleDetails.mercs_start > 0)
               {
                  StatsManager.count("combat." + _loc9_ + ".mercs.start",_loc10_,"","","","",battleDetails.mercs_start);
               }
               if(battleDetails.allies_start > 0)
               {
                  StatsManager.count("combat." + _loc9_ + ".allies.start",_loc10_,"","","","",battleDetails.allies_start);
               }
            }
            else if(!param1.eventData.battle.isDeathMatchBattle)
            {
               StatsManager.count("combat.campaign.result",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),_loc2_);
               StatsManager.count("combat.campaign.energy.used",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),"","","",battleDetails.energy_used);
               StatsManager.count("combat.campaign.ammo.start",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),"","","",battleDetails.ammo_start);
               StatsManager.count("combat.campaign.ammo.end",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),"","","",battleDetails.ammo_end);
               StatsManager.count("combat.campaign.ammo.used",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),"","","",battleDetails.ammo_used);
               for(_loc3_ in battleDetails.units_start)
               {
                  StatsManager.count("combat.campaign.units.start",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),_loc3_,"","",battleDetails.units_start[_loc3_]);
                  StatsManager.count("combat.campaign.units.end",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),_loc3_,"","",battleDetails.units_end.hasOwnProperty(_loc3_) ? int(battleDetails.units_end[_loc3_]) : 0);
               }
               if(battleDetails.mercs_start)
               {
                  StatsManager.count("combat.campaign.mercs.start",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),"","","",battleDetails.mercs_start);
               }
               if(battleDetails.allies_start)
               {
                  StatsManager.count("combat.campaign.allies.start",ZGlobal.player.campaign.currentMapName,ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString(),"","","",battleDetails.allies_start);
               }
            }
         }
         battleDetails = null;
      }
      
      private static function onToggleMusic(param1:WorldEvent) : void
      {
         StatsManager.countSample(10000,"navigation","music",param1.eventData as Boolean ? "off" : "on");
      }
      
      private static function onShowPopup(param1:WorldEvent) : void
      {
         var _loc6_:LetterPopup = null;
         var _loc7_:GenericPopup = null;
         var _loc8_:Object = null;
         var _loc2_:String = "";
         var _loc3_:String = "";
         var _loc4_:String = "";
         var _loc5_:String = "";
         param1.eventData.addEventListener(GenericPopupEvent.SELECTED,onPopupSelected);
         _loc2_ = getQualifiedClassName(param1.eventData);
         if(_loc2_.lastIndexOf("BattleCampaign") > 0)
         {
            _loc3_ = ZGlobal.player.campaign.currentMapName;
            _loc4_ = ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString();
         }
         else if(param1.eventData is QuestPopup && param1.eventData.hasOwnProperty("id"))
         {
            _loc3_ = param1.eventData.id;
         }
         else if(_loc2_.lastIndexOf("DominationModeChatInput") > 0)
         {
            _loc3_ = (param1.eventData as DominationModeChatInput).statsClass;
         }
         else if(param1.eventData is LetterPopup)
         {
            _loc6_ = LetterPopup(param1.eventData);
            if(_loc6_.letterID.lastIndexOf("Start") > 0)
            {
               _loc5_ = "lettermechanic_intro";
            }
            else
            {
               _loc5_ = "lettermechanic_defeat";
            }
            StatsManager.count("dialog",_loc5_,_loc6_.letterName);
            return;
         }
         if(param1.eventData is GenericPopup)
         {
            _loc7_ = GenericPopup(param1.eventData);
            if(Boolean(_loc7_.statsData) && Boolean(_loc7_.statsData is Array) && _loc7_.statsData.length >= 4)
            {
               if(_loc7_.statsData[0] != "ModalPopup" && _loc7_.statsData[0] != "SpeechPopup")
               {
                  StatsManager.count("dialog",_loc7_.statsData[0],"view",_loc7_.statsData[2],_loc7_.statsData[3]);
               }
               return;
            }
         }
         else if(param1.eventData is LeaderboardPopup)
         {
            _loc8_ = param1.eventData.statsData;
            if(_loc8_)
            {
               StatsManager.count("dialog",_loc8_.kingdom,"view");
               return;
            }
         }
         _loc2_ = _loc2_.substring(_loc2_.lastIndexOf("::") + 2);
         if(_loc2_ != "ModalPopup" && _loc2_ != "SpeechPopup")
         {
            StatsManager.count("dialog",_loc2_,"view",_loc3_,_loc4_);
         }
      }
      
      private static function onCinematicsEvent(param1:CinematicsEvent) : void
      {
         switch(param1.type)
         {
            case Cinematics.PLAY:
               StatsManager.count("cinematics","play",param1.movieUrl);
               break;
            case Cinematics.INTERRUPT:
               StatsManager.count("cinematics","interrupt",param1.movieUrl);
               break;
            case Cinematics.FINISH:
               StatsManager.count("cinematics","finish",param1.movieUrl);
               break;
            case Cinematics.FAIL:
               StatsManager.count("cinematics","fail",param1.movieUrl);
         }
      }
      
      private static function onEnergyPickup(param1:ResourceRewardEvent) : void
      {
         StatsManager.count("energy_earn","doober");
      }
      
      private static function onAmmoPickup(param1:ResourceRewardEvent) : void
      {
         StatsManager.count("ammo_earn","doober");
      }
      
      private static function onPopupSelected(param1:GenericPopupEvent) : void
      {
         var _loc6_:GenericPopup = null;
         var _loc7_:Object = null;
         param1.target.removeEventListener(GenericPopupEvent.SELECTED,onPopupSelected);
         var _loc2_:String = "";
         var _loc3_:String = "";
         var _loc4_:String = "";
         var _loc5_:String = "";
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = "yes";
         }
         else
         {
            _loc2_ = "no";
         }
         _loc3_ = getQualifiedClassName(param1.target);
         if(_loc3_.lastIndexOf("BattleCampaign") > 0)
         {
            _loc4_ = ZGlobal.player.campaign.currentMapName;
            _loc5_ = ZGlobal.player.campaign.currentMap.currentIslandItem.index.toString();
         }
         else if(param1.target is QuestPopup)
         {
            _loc4_ = param1.target.id;
         }
         else if(param1.target is NotEnoughCashPopup && param1.button == GenericPopup.YES)
         {
            StatsManager.count("dialog","popup","zbill","accept");
         }
         if(param1.target is GenericPopup)
         {
            _loc6_ = GenericPopup(param1.target);
            if(Boolean(_loc6_.statsData) && Boolean(_loc6_.statsData is Array) && _loc6_.statsData.length >= 4)
            {
               if(_loc6_.statsData[0] != "ModalPopup" && _loc6_.statsData[0] != "SpeechPopup")
               {
                  StatsManager.count("dialog",_loc6_.statsData[0],_loc2_,_loc6_.statsData[2],_loc6_.statsData[3]);
               }
               return;
            }
         }
         else if(param1.target is LeaderboardPopup)
         {
            _loc7_ = param1.target.statsData;
            if(_loc7_)
            {
               StatsManager.count("dialog",_loc7_.kingdom,"close");
               return;
            }
         }
         _loc3_ = _loc3_.substring(_loc3_.lastIndexOf("::") + 2);
         if(_loc3_ != "ModalPopup" && _loc3_ != "SpeechPopup")
         {
            StatsManager.count("dialog",_loc3_,_loc2_,_loc4_,_loc5_);
         }
         activity();
      }
      
      private static function onShowSurvey(param1:WorldEvent) : void
      {
         StatsManager.count("nps_survey","impression");
      }
      
      private static function onToggleSFX(param1:WorldEvent) : void
      {
         StatsManager.countSample(10000,"navigation","sound",param1.eventData as Boolean ? "off" : "on");
      }
      
      private static function onZoomChanged(param1:WorldEvent) : void
      {
         StatsManager.countSample(10000,"navigation","zoom",param1.eventData.zoom);
      }
      
      private static function onFriendBarSlotClick(param1:FriendBarSlotEvent) : void
      {
         var _loc2_:String = null;
         switch(param1.buttonType)
         {
            case FriendBarSlotEvent.BUTTON_VISIT:
               _loc2_ = "visit";
               break;
            case FriendBarSlotEvent.BUTTON_MARKET:
               _loc2_ = "market";
               break;
            case FriendBarSlotEvent.BUTTON_GIFT:
               _loc2_ = "gift";
               break;
            case FriendBarSlotEvent.BUTTON_REQ_RESOURCE:
               _loc2_ = "ask_metal";
               break;
            case FriendBarSlotEvent.BUTTON_CHALLENGE:
               _loc2_ = "challenge";
               break;
            case FriendBarSlotEvent.BUTTON_ATTACK:
            case FriendBarSlotEvent.BUTTON_CONTINUE_ATTACK:
               _loc2_ = "invade";
               break;
            case FriendBarSlotEvent.BUTTON_PILLAGE:
               _loc2_ = "pillage";
         }
         if(_loc2_)
         {
            StatsManager.countSample(100,"friend_bar",_loc2_);
         }
      }
      
      private static function onFriendBarScroll(param1:FriendBarEvent) : void
      {
         StatsManager.countSample(100,"friend_bar",(Math.abs(param1.delta) == 1 ? "scroll" : "page") + "_" + (param1.delta > 0 ? "left" : "right"));
      }
      
      private static function onExpansionSuccess(param1:Event) : void
      {
         StatsManager.count("expansion","attempted","enough");
      }
      
      private static function onExpansionFailure(param1:Event) : void
      {
         StatsManager.count("expansion","attempted","not enough");
      }
      
      private static function onQuestTaskComplete(param1:WorldEvent) : void
      {
         StatsManager.countSample(100,"quest_task_complete",param1.eventData.quest,param1.eventData.task);
         StatsManager.milestone("quest_completed_" + param1.eventData.task.toString(),1);
      }
      
      public static function doDeferredTracking(param1:Event = null) : void
      {
         ExternalInterface.call("statTracker.logWorldObjectCount");
      }
      
      public function trackPerf() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Number = getTimer();
         ++this.m_perfFrameCount;
         if(_loc1_ >= this.m_lastPerfUpdate + ZGameStats.PERF_UPDATE_INTERVAL)
         {
            _loc2_ = this.m_perfFrameCount / (_loc1_ - this.m_lastPerfUpdate) * 1000;
            _loc3_ = Number(System.totalMemory / 1024);
            _loc4_ = Number(System.totalMemory / 1024 / 1024);
            _loc2_ = int(_loc2_ * 10) / 10;
            _loc3_ = Math.round(_loc3_);
            _loc4_ = Math.round(_loc4_);
            if(Boolean(GlobalEngine) && Zlab.mainStage.frameRate > 1)
            {
               StatsManager.countSample(ZGameStats.PERF_RATE,ZGameStats.PERF_FPS,"clientPerformance","","","","",_loc2_);
               StatsManager.countSample(ZGameStats.PERF_RATE,ZGameStats.PERF_MEM_USAGE,"clientPerformance","","","","",_loc4_);
               StatsManager.countSample(ZGameStats.PERF_RATE,ZGameStats.KB_PERF_MEM_USAGE,"clientPerformance","","","","",_loc3_);
               StatsManager.countSample(ZGameStats.PERF_RATE,ZGameStats.PERF_WIDTH,"clientPerformance","","","","",Zlab.mainStage.stageWidth);
               StatsManager.countSample(ZGameStats.PERF_RATE,ZGameStats.PERF_HEIGHT,"clientPerformance","","","","",Zlab.mainStage.stageHeight);
            }
            this.m_lastPerfUpdate = _loc1_;
            this.m_perfFrameCount = 0;
         }
         Zlab.processManager.schedule(1,this,this.trackPerf);
      }
      
      private function onLeaderboardPlaceChanged(param1:WorldEvent) : void
      {
         StatsManager.count("dialog","lb_floating_dialog_passing","view");
      }
   }
}

