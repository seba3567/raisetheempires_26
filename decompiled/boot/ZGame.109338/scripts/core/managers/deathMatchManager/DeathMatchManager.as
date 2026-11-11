package core.managers.deathMatchManager
{
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import com.adobe.serialization.json.JSON;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldObjectManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import displays.popups.DeathMatchRewardPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.genericPopup.ModalPopup;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import transactions.TStartDeathMatchFight;
   import transactions.deathMatch.TFetchDeathMatchOpponents;
   import transactions.deathMatch.TJoinDeathMatchRoom;
   import transactions.deathMatch.TProcessRewardQueue;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.utils.MathUtils;
   
   public class DeathMatchManager extends EventDispatcher
   {
      
      private static var _instance:DeathMatchManager;
      
      private static var stageRatios:Array = [1,1,1,2,2,3];
      
      private static const LEADERBOARD_OPPONENT:int = 1;
      
      private static const REGULAR_OPPONENT:int = 2;
      
      private static const DUMMY_OPPONENT:int = 3;
      
      public static const LOAD_BATTLE_PLAYER_SETUP:int = 2;
      
      public static const LOAD_BATTLE_IN_PROGRESS:int = 3;
      
      public static const LOAD_BATTLE_ERROR:int = 3;
      
      public static const NEW_USER:Number = 1;
      
      public static const ACTIVE_BATTLE:Number = 2;
      
      public static const NO_ACTIVE_BATTLE:Number = 3;
      
      public static const HAS_REACHED_MAX_SCORE:Number = 4;
      
      public static const BUILDING_ITEMCODE:String = "DM00";
      
      public static const STAGE_REWARD:int = 1;
      
      public static const GRAND_REWARD:int = 2;
      
      public static const LOADING_SCREEN:String = "assets/displays/dialogs/LiveCombat_loading.swf";
      
      public static const OPPONENT_LIST_UPDATED:String = "opponent_list_updated";
      
      public static const REWARDS_GRANTED:String = "rewards_granted";
      
      public static const REWARD_POPUP_VIEWED:String = "reward_popup_viewed";
      
      private var m_isDeathMatchBattle:Boolean;
      
      private var m_playerFleetName:String = "";
      
      private var m_enemyFleetName:String = "";
      
      private var m_enemyID:String = "";
      
      private var m_roomID:String = "";
      
      private var m_band:int;
      
      private var m_roomInfo:Object;
      
      private var m_endTS:Number;
      
      private var m_cacheTTL:Number;
      
      private var m_fragLimits:Object;
      
      private var m_opponentCoolDown:Number;
      
      private var m_currentRoomID:String;
      
      private var m_battleInfo:Object;
      
      private var m_rewardData:Object;
      
      private var m_grandRewards:Object;
      
      private var m_startTime:Number;
      
      private var m_duration:Number;
      
      private var m_loadingScreenPopup:ModalPopup = null;
      
      private var m_rewardPopups:Array;
      
      public function DeathMatchManager(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_band = 0;
         this.m_roomInfo = null;
         this.m_endTS = 0;
         this.m_opponentCoolDown = 0;
         this.m_rewardPopups = new Array();
      }
      
      public static function get instance() : DeathMatchManager
      {
         if(!_instance)
         {
            _instance = new DeathMatchManager();
         }
         return _instance;
      }
      
      private function getCacheTTL(param1:String) : Number
      {
         var _loc2_:String = param1.charAt(2);
         return this.m_roomInfo[_loc2_]["dm_opponents"]["ts"];
      }
      
      private function getFragLimit(param1:String) : int
      {
         return this.m_fragLimits[param1];
      }
      
      public function get isExperimentEnabled() : Boolean
      {
         return ZGlobal.player.level >= 20 && ExperimentsManager.instance.getExperimentVariant("empire_deathmatch_master") == 3;
      }
      
      public function get isActive() : Boolean
      {
         return this.isExperimentEnabled && this.timeRemaining > 0;
      }
      
      public function get counterData() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.band = "dominationPod_" + this.m_band.toString();
         var _loc2_:String = this.m_currentRoomID.charAt(2);
         switch(_loc2_)
         {
            case "1":
               _loc1_.level = "room_elite";
               break;
            case "2":
               _loc1_.level = "room_veteran";
               break;
            default:
               _loc1_.level = "room_master";
         }
         return _loc1_;
      }
      
      public function init(param1:int, param2:int, param3:Object, param4:Object) : void
      {
         this.m_band = param1;
         this.m_endTS = param2;
         this.m_roomInfo = param3;
         this.m_battleInfo = param4;
         this.clearOpponentCache();
         DeathMatchManager.instance.addEventListener(DeathMatchManager.REWARDS_GRANTED,this.displayRewards);
         DeathMatchManager.instance.addEventListener(DeathMatchManager.REWARD_POPUP_VIEWED,this.processRewardPopupQueue);
      }
      
      public function setDeathMatchConstants(param1:String, param2:Number, param3:Number, param4:String, param5:String, param6:Number, param7:Number) : void
      {
         var fragLimits:String = param1;
         var cacheTTL:Number = param2;
         var oppCooldown:Number = param3;
         var rewards:String = param4;
         var grandRewards:String = param5;
         var startTime:Number = param6;
         var duration:Number = param7;
         this.m_cacheTTL = cacheTTL;
         this.m_opponentCoolDown = oppCooldown;
         try
         {
            this.m_fragLimits = com.adobe.serialization.json.JSON.decode(fragLimits);
         }
         catch(e:Error)
         {
            m_fragLimits = null;
         }
         this.m_rewardData = com.adobe.serialization.json.JSON.decode(rewards);
         this.m_grandRewards = com.adobe.serialization.json.JSON.decode(grandRewards);
         this.m_startTime = startTime;
         this.m_duration = duration;
      }
      
      public function set loadingScreen(param1:ModalPopup) : void
      {
         this.m_loadingScreenPopup = param1;
      }
      
      public function get loadingScreen() : ModalPopup
      {
         return this.m_loadingScreenPopup;
      }
      
      public function get deathMatchRewards() : Object
      {
         return this.m_rewardData;
      }
      
      public function get grandRewards() : Object
      {
         return this.m_grandRewards;
      }
      
      public function get maxFragsForRooms() : Object
      {
         return this.m_fragLimits;
      }
      
      public function get dmBand() : int
      {
         return this.m_band;
      }
      
      public function get winsByPlayer() : Object
      {
         var _loc1_:String = this.m_currentRoomID.charAt(2);
         return this.m_roomInfo[_loc1_].aWins + this.m_roomInfo[_loc1_].pWins;
      }
      
      public function get lossByPlayer() : Object
      {
         var _loc1_:String = this.m_currentRoomID.charAt(2);
         return this.m_roomInfo[_loc1_].aLosses + this.m_roomInfo[_loc1_].pLosses;
      }
      
      public function startFight(param1:String = null, param2:String = null) : void
      {
         var _loc3_:String = null;
         if(this.m_loadingScreenPopup)
         {
            this.m_loadingScreenPopup.pop();
         }
         if(param1)
         {
            _loc3_ = ZGameUtils.ZlocT("Dialogs","DM_loadingBattle");
            DeathMatchManager.instance.loadingScreen = new ModalPopup(_loc3_,null,LOADING_SCREEN);
            PopupManager.instance.push(DeathMatchManager.instance.loadingScreen);
         }
         if(param1)
         {
            this.m_enemyID = param1;
         }
         if(param2)
         {
            this.m_roomID = param2;
         }
         TransactionManager.addTransaction(new TStartDeathMatchFight(this.m_playerFleetName,this.m_enemyID,this.m_roomID),true);
      }
      
      public function isInDeathMatchBattle() : Boolean
      {
         return this.m_isDeathMatchBattle;
      }
      
      public function onLoadBattle(param1:Object, param2:String, param3:String) : void
      {
         var _loc4_:Fleet = null;
         var _loc5_:Fleet = null;
         var _loc6_:Fleet = null;
         if(this.m_loadingScreenPopup)
         {
            this.m_loadingScreenPopup.pop();
         }
         if(Boolean(param1) && Boolean(param1.state))
         {
            switch(param1.state)
            {
               case LOAD_BATTLE_PLAYER_SETUP:
                  ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.enemyFleet,param1.enemyFleet.type,param1.enemyFleet.uid);
                  _loc4_ = ZGlobal.player.fleets.createFleet(param1.enemyFleet.type,true);
                  _loc4_.setStatus(Fleet.DEATHMATCH_PLAYER);
                  _loc4_.battleTarget = param1.enemyFleet.name;
                  this.setInDeathMatchBattle(_loc4_.name,param1.enemyFleet.name,param2,param3);
                  GameModeManager.instance.addGameMode(new GMBattle(_loc4_,Fleet.getFleet(param1.enemyFleet.name)));
                  if(GMPreBattle.ENABLED)
                  {
                     GMPreBattle.ACTIVE = true;
                     GameModeManager.instance.addGameMode(new GMPreBattle(_loc4_,Fleet.getFleet(param1.enemyFleet.name),Fleet.MAX_UNITS),false);
                  }
                  break;
               case LOAD_BATTLE_IN_PROGRESS:
                  if(!param1.newStart)
                  {
                     ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.enemyFleet,param1.enemyFleet.type,param1.enemyFleet.uid);
                     ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.playerFleet,param1.playerFleet.type,param1.playerFleet.uid);
                     _loc5_ = Fleet.getFleet(param1.playerFleet.name);
                     _loc6_ = Fleet.getFleet(param1.enemyFleet.name);
                     this.setInDeathMatchBattle(param1.playerFleet,param1.enemyFleet,param2,param3);
                     GameModeManager.instance.addGameMode(new GMBattle(_loc5_,_loc6_));
                     BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
                  }
            }
         }
      }
      
      public function setInDeathMatchBattle(param1:String, param2:String, param3:String, param4:String) : void
      {
         this.m_isDeathMatchBattle = true;
         this.m_playerFleetName = param1;
         this.m_enemyFleetName = param2;
         this.m_enemyID = param3;
         this.m_roomID = param4;
      }
      
      private function getOpponentIndex(param1:String) : int
      {
         var _loc2_:String = this.m_currentRoomID.charAt(2);
         var _loc3_:Object = this.m_roomInfo[_loc2_]["dm_opponents"]["opponents"];
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].zid == param1)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return -1;
      }
      
      private function getLeaderIndex(param1:String) : int
      {
         var _loc2_:String = this.m_currentRoomID.charAt(2);
         var _loc3_:Object = this.m_roomInfo[_loc2_]["dm_opponents"]["leaders"];
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].zid == param1)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return -1;
      }
      
      public function onBattleComplete(param1:Boolean, param2:Array, param3:Dictionary, param4:Boolean = true) : Boolean
      {
         TransactionManager.addTransaction(new TProcessRewardQueue(this.m_currentRoomID),true);
         var _loc5_:String = this.m_currentRoomID.charAt(2);
         var _loc6_:String = this.m_battleInfo[this.m_currentRoomID].enemyUID;
         if(param1)
         {
            this.m_roomInfo[_loc5_].aWins += 1;
            this.m_roomInfo[_loc5_].dm_frags += 1;
         }
         else
         {
            this.m_roomInfo[_loc5_].aLosses += 1;
            if(this.m_battleInfo[this.m_currentRoomID].playerType == LEADERBOARD_OPPONENT)
            {
               --this.m_roomInfo[_loc5_].dm_frags;
               if(this.m_roomInfo[_loc5_].dm_frags < 0)
               {
                  this.m_roomInfo[_loc5_].dm_frags = 0;
               }
            }
         }
         var _loc7_:int = this.getLeaderIndex(ZGlobal.player.uid);
         if(_loc7_ != -1)
         {
            this.m_roomInfo[_loc5_]["dm_opponents"]["leaders"][_loc7_].frags = this.m_roomInfo[_loc5_].dm_frags;
         }
         if(param4)
         {
            PopupManager.instance.push(new DeathMatchPostBattle(param1,this.m_roomInfo[_loc5_].dm_frags,param2,param3));
         }
         var _loc8_:int = this.getOpponentIndex(_loc6_);
         if(_loc8_ != -1)
         {
            if(!param1)
            {
               ++this.m_roomInfo[_loc5_]["dm_opponents"]["opponents"][_loc8_].frags;
            }
            else if(this.m_battleInfo[this.m_currentRoomID].enemyType == LEADERBOARD_OPPONENT)
            {
               --this.m_roomInfo[_loc5_].dm_frags;
               if(this.m_roomInfo[_loc5_].dm_frags < 0)
               {
                  this.m_roomInfo[_loc5_].dm_frags = 0;
               }
            }
            this.m_roomInfo[_loc5_]["dm_opponents"]["opponents"][_loc8_].ts = GlobalEngine.serverTime / 1000;
         }
         _loc7_ = this.getLeaderIndex(_loc6_);
         if(_loc7_ != -1)
         {
            if(!param1)
            {
               ++this.m_roomInfo[_loc5_]["dm_opponents"]["leaders"][_loc7_].frags;
            }
            else if(this.m_battleInfo[this.m_currentRoomID].enemyType == LEADERBOARD_OPPONENT)
            {
               --this.m_roomInfo[_loc5_].dm_frags;
               if(this.m_roomInfo[_loc5_].dm_frags < 0)
               {
                  this.m_roomInfo[_loc5_].dm_frags = 0;
               }
            }
            this.m_roomInfo[_loc5_]["dm_opponents"]["leaders"][_loc7_].ts = GlobalEngine.serverTime / 1000;
         }
         this.m_battleInfo[this.m_currentRoomID] = null;
         this.exitBattle();
         return true;
      }
      
      public function exitBattle() : Boolean
      {
         this.m_isDeathMatchBattle = false;
         this.m_playerFleetName = "";
         this.m_enemyFleetName = "";
         this.m_enemyID = "";
         this.m_roomID = "";
         return true;
      }
      
      public function get currentEnemyID() : String
      {
         return this.m_enemyID;
      }
      
      public function cancelFight() : void
      {
         ZGlobal.player.fleets.battleOver(this.m_playerFleetName,this.m_enemyFleetName,Battle.BATTLE_RESULT_CANCEL);
         ZGlobal.player.fleets.returnFleetName();
         this.exitBattle();
      }
      
      public function getOpponentsForRoom(param1:String) : Object
      {
         var _loc2_:String = param1.charAt(2);
         return this.m_roomInfo[_loc2_]["dm_opponents"]["opponents"];
      }
      
      public function getLeadersForRoom(param1:String) : Object
      {
         var _loc2_:String = param1.charAt(2);
         return this.m_roomInfo[_loc2_]["dm_opponents"]["leaders"];
      }
      
      private function isUseraLeader(param1:String) : Boolean
      {
         var _loc2_:Array = this.m_roomInfo[param1]["dm_opponents"]["leaders"];
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].zid == ZGlobal.player.uid)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function getSortedLeadersForRoom(param1:String) : Array
      {
         var _loc4_:Object = null;
         var _loc2_:String = param1.charAt(2);
         var _loc3_:Array = this.m_roomInfo[_loc2_]["dm_opponents"]["leaders"];
         if(!this.isUseraLeader(_loc2_))
         {
            _loc4_ = new Object();
            _loc4_.zid = ZGlobal.player.uid;
            _loc4_.frags = this.getFragsForRoom(param1);
            _loc4_.ts = 0;
            _loc4_.name = ZGlobal.player.snUser.firstName;
            _loc4_.pic = ZGlobal.player.snUser.picture;
            _loc3_.push(_loc4_);
         }
         _loc3_.sort(this.maxFragSort);
         return _loc3_;
      }
      
      private function maxFragSort(param1:Object, param2:Object) : int
      {
         if(param1.frags > param2.frags)
         {
            return -1;
         }
         param1.frags < param2.frags;
         return 1;
      }
      
      public function isDummyData(param1:String) : Boolean
      {
         var _loc2_:String = param1.charAt(2);
         return this.m_roomInfo[_loc2_]["dm_opponents"]["dummy"];
      }
      
      public function isCacheValid(param1:String) : Boolean
      {
         var _loc2_:int = int(GlobalEngine.serverTime / 1000);
         var _loc3_:String = param1.charAt(2);
         if(_loc2_ - this.getCacheTTL(param1) > this.m_cacheTTL)
         {
            return false;
         }
         if(this.m_roomInfo[_loc3_]["dm_opponents"]["opponents"].length == 0)
         {
            return false;
         }
         return true;
      }
      
      public function fetchOpponentsForRoom(param1:String) : void
      {
         TransactionManager.addTransaction(new TFetchDeathMatchOpponents(param1),true);
      }
      
      public function updateLocalOpponentCache(param1:String, param2:Object) : void
      {
         var _loc3_:String = param1.charAt(2);
         this.m_roomInfo[_loc3_]["dm_opponents"] = param2;
      }
      
      public function updateBattleInfo(param1:Object) : void
      {
         this.m_battleInfo = param1;
      }
      
      public function clearOpponentCache() : void
      {
         this.m_roomInfo["1"]["dm_opponents"]["opponents"] = new Array();
         this.m_roomInfo["2"]["dm_opponents"]["opponents"] = new Array();
         this.m_roomInfo["3"]["dm_opponents"]["opponents"] = new Array();
      }
      
      public function getFragsForRoom(param1:String) : Number
      {
         var _loc2_:String = param1.charAt(2);
         return this.m_roomInfo[_loc2_]["dm_frags"];
      }
      
      public function isOpponentActive(param1:String, param2:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:String = param2.charAt(2);
         var _loc5_:Number = int(GlobalEngine.serverTime / 1000);
         var _loc6_:Number = 0;
         _loc3_ = 0;
         while(_loc3_ < this.m_roomInfo[_loc4_]["dm_opponents"]["opponents"].length)
         {
            if(param1 == this.m_roomInfo[_loc4_]["dm_opponents"]["opponents"][_loc3_]["zid"])
            {
               _loc6_ = Number(this.m_roomInfo[_loc4_]["dm_opponents"]["opponents"][_loc3_]["ts"]);
               if(_loc5_ - _loc6_ > this.m_opponentCoolDown)
               {
                  return true;
               }
               return false;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this.m_roomInfo[_loc4_]["dm_opponents"]["leaders"].length)
         {
            if(param1 == this.m_roomInfo[_loc4_]["dm_opponents"]["leaders"][_loc3_]["zid"])
            {
               _loc6_ = Number(this.m_roomInfo[_loc4_]["dm_opponents"]["leaders"][_loc3_]["ts"]);
               if(_loc5_ - _loc6_ > this.m_opponentCoolDown)
               {
                  return true;
               }
               return false;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isPartOfRoom(param1:String) : Boolean
      {
         var _loc2_:String = param1.charAt(2);
         return this.m_roomInfo[_loc2_]["dm_frags"] != -1;
      }
      
      public function joinRoom(param1:String) : void
      {
         if(this.isPartOfRoom(param1))
         {
            return;
         }
         TransactionManager.addTransaction(new TJoinDeathMatchRoom(param1),true);
         var _loc2_:String = param1.charAt(2);
         this.m_roomInfo[_loc2_]["dm_frags"] = 0;
      }
      
      public function get currentRoomID() : String
      {
         return this.m_currentRoomID;
      }
      
      public function set currentRoomID(param1:String) : void
      {
         this.m_currentRoomID = param1;
      }
      
      public function updateFrags(param1:String, param2:int) : void
      {
         var _loc3_:String = param1.charAt(2);
         var _loc4_:int = this.getFragsForRoom(param1);
         _loc4_ = _loc4_ + param2;
         _loc4_ = _loc4_ < 0 ? 0 : _loc4_;
         this.m_roomInfo[_loc3_]["dm_frags"] = _loc4_;
      }
      
      public function getStage(param1:String) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:int = this.getFragsForRoom(param1);
         var _loc3_:int = this.getFragLimit(param1);
         _loc4_ = 1;
         _loc5_ = _loc3_ / 10;
         _loc6_ = 0;
         while(_loc6_ < DeathMatchManager.stageRatios.length)
         {
            _loc2_ -= DeathMatchManager.stageRatios[_loc6_] * _loc5_;
            if(_loc2_ <= 0)
            {
               return _loc4_;
            }
            _loc4_ += 1;
            _loc6_++;
         }
         return _loc4_;
      }
      
      public function getOpponentType(param1:String, param2:String) : int
      {
         var _loc4_:int = 0;
         var _loc3_:String = param2.charAt(2);
         if(this.m_roomInfo[_loc3_]["dummy"])
         {
            return DeathMatchManager.DUMMY_OPPONENT;
         }
         _loc4_ = 0;
         while(_loc4_ < this.m_roomInfo[_loc3_]["dm_opponents"]["leaders"].length)
         {
            if(this.m_roomInfo[_loc3_]["dm_opponents"]["leaders"][_loc4_]["zid"] == param1)
            {
               return DeathMatchManager.LEADERBOARD_OPPONENT;
            }
            _loc4_++;
         }
         return DeathMatchManager.REGULAR_OPPONENT;
      }
      
      public function launchRoom() : void
      {
         if(this.m_loadingScreenPopup)
         {
            this.m_loadingScreenPopup.pop();
         }
         PopupManager.instance.push(new DeathMatchRoomUI());
      }
      
      public function launchLobby() : void
      {
         PopupManager.instance.push(new DeathMatchLobby());
         DeathMatchManager.instance.checkUngrantedRewards();
      }
      
      private function hasActiveBattle(param1:String) : Boolean
      {
         if(Boolean(this.m_battleInfo) && Boolean(this.m_battleInfo[param1]) && Boolean(this.m_battleInfo[param1].enemyFleet))
         {
            return true;
         }
         return false;
      }
      
      public function onAcceptMOTD() : void
      {
         PopupManager.instance.push(new SpeechPopup("deathMatch",this.onSpeechClosed));
      }
      
      private function onSpeechClosed(param1:Event = null) : void
      {
         this.panToItemDelay(BUILDING_ITEMCODE);
      }
      
      private function panToItemDelay(param1:String) : void
      {
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:BuildingSpatialComponent = null;
         var _loc7_:Pt = null;
         var _loc8_:CineCameraComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(_loc2_)
         {
            _loc3_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc5_)) && _loc5_.gameData.code == param1)
               {
                  _loc6_ = BuildingSpatialComponent(_loc4_.lookupComponentByType(BuildingSpatialComponent));
                  if(_loc6_)
                  {
                     _loc7_ = new Pt(_loc6_.position.x,_loc6_.position.y);
                     _loc7_ = MathUtils.worldToTile(_loc7_,ZGlobal.cellSize);
                     _loc8_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
                     _loc8_.moveTo(_loc7_);
                     break;
                  }
               }
            }
         }
      }
      
      public function get timeRemaining() : Number
      {
         var _loc1_:int = GlobalEngine.serverTime / 1000;
         var _loc2_:int = this.m_startTime + this.m_duration;
         if(_loc1_ > _loc2_ || _loc1_ < this.m_startTime)
         {
            return -1;
         }
         return _loc2_ - _loc1_;
      }
      
      public function get endTime() : int
      {
         return this.m_startTime + this.m_duration;
      }
      
      public function hasDeathMatchExpired() : Boolean
      {
         if(this.timeRemaining == -1)
         {
            return true;
         }
         return false;
      }
      
      public function getRoomState(param1:String) : Number
      {
         if(this.isPartOfRoom(param1))
         {
            if(this.hasActiveBattle(param1))
            {
               return ACTIVE_BATTLE;
            }
            if(this.m_fragLimits[param1] <= this.getFragsForRoom(param1))
            {
               return HAS_REACHED_MAX_SCORE;
            }
            return NO_ACTIVE_BATTLE;
         }
         return NEW_USER;
      }
      
      public function getPausedBattleOpponentForRoom(param1:String) : String
      {
         if(Boolean(this.m_battleInfo) && Boolean(this.m_battleInfo[param1]) && Boolean(Number(this.m_battleInfo[param1].enemyUID)))
         {
            return this.m_battleInfo[param1].enemyUID;
         }
         return "0";
      }
      
      public function displayRewards(param1:WorldEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         if(!param1 || !param1.eventData)
         {
            return;
         }
         var _loc2_:Array = param1.eventData["rewards"];
         var _loc3_:String = param1.eventData["roomId"];
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc5_ = _loc2_[_loc4_];
            _loc6_ = new Object();
            _loc6_["roomId"] = _loc3_;
            if(_loc5_[2] == DeathMatchManager.STAGE_REWARD)
            {
               _loc6_["rewards"] = new Array();
               _loc6_["rewards"].push(_loc5_);
               _loc6_["type"] = DeathMatchManager.STAGE_REWARD;
               this.m_rewardPopups.push(_loc6_);
            }
            else if(_loc5_[2] == DeathMatchManager.GRAND_REWARD)
            {
               _loc6_["rewards"] = _loc2_.slice(_loc4_);
               _loc6_["type"] = DeathMatchManager.GRAND_REWARD;
               this.m_rewardPopups.push(_loc6_);
               break;
            }
            _loc4_++;
         }
         this.dispatchEvent(new Event(DeathMatchManager.REWARD_POPUP_VIEWED));
      }
      
      public function checkUngrantedRewards() : void
      {
         if(this.m_roomInfo["1"]["itemsToReward"].length != 0)
         {
            TransactionManager.addTransaction(new TProcessRewardQueue(this.m_band.toString() + "_1"),true);
            this.m_roomInfo["1"]["itemsToReward"] = new Array();
         }
         if(this.m_roomInfo["2"]["itemsToReward"].length != 0)
         {
            TransactionManager.addTransaction(new TProcessRewardQueue(this.m_band.toString() + "_2"),true);
            this.m_roomInfo["2"]["itemsToReward"] = new Array();
         }
         if(this.m_roomInfo["3"]["itemsToReward"].length != 0)
         {
            TransactionManager.addTransaction(new TProcessRewardQueue(this.m_band.toString() + "_3"),true);
            this.m_roomInfo["3"]["itemsToReward"] = new Array();
         }
      }
      
      private function processRewardPopupQueue(param1:Event) : void
      {
         var _loc2_:Object = null;
         if(this.m_rewardPopups.length > 0)
         {
            _loc2_ = this.m_rewardPopups.pop();
            PopupManager.instance.push(new DeathMatchRewardPopup(_loc2_["roomId"],_loc2_["rewards"],_loc2_["type"]));
         }
      }
   }
}

