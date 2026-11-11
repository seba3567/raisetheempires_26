package core.managers
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.player.IPVPPlayer;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.PVPCombatStartPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TCreateRandomFleetChallenge;
   import transactions.TLoadChallenge;
   import transactions.TLoadEnemyFleetForChallenge;
   import transactions.TRetrieveNeighborRepelChallenge;
   import transactions.TWorldLoad;
   import utils.ConnectionStatus;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class ChallengeModeManager
   {
      
      public static var instance:ChallengeModeManager = new ChallengeModeManager();
      
      public static const CHALLENGE_STARTED:String = "challengeStarted";
      
      public static const CHALLENGE_RECEIVED_LIST_UPDATED:String = "challengeReceivedListUpdated";
      
      public static const CHALLENGE_STATE_PENDING:int = 0;
      
      public static const CHALLENGE_STATE_IN_PROGRESS:int = 1;
      
      public static const RANDOM_FLEET_CHALLENGE_INVALID_NO_DEFENDER:int = -4;
      
      public static const RANDOM_FLEET_CHALLENGE_IN_PROGRESS_PVE:int = -3;
      
      public static const RANDOM_FLEET_CHALLENGE_REFRESH_CLIENT:int = -2;
      
      public static const RANDOM_FLEET_CHALLENGE_INVALID:int = -1;
      
      public static const RANDOM_FLEET_CHALLENGE_NEW:int = 0;
      
      public static const RANDOM_FLEET_CHALLENGE_EXISTING:int = 1;
      
      public static const RANDOM_FLEET_CHALLENGE_IN_PROGRESS:int = 2;
      
      public static const ERR_CANT_INVADE_IMMUNITY_ON:int = 106;
      
      public static const ERR_CANT_INVADE_AREA_IMMUNE:int = 108;
      
      public static const CHALLENGE_FLAG_GLOBAL_PVP:int = 1;
      
      private var m_receivedChallenges:Dictionary = new Dictionary();
      
      private var m_cantInvadeDialogUp:Boolean = false;
      
      private var m_inChallengeBattle:Boolean = false;
      
      private var m_playerFleetName:String = "";
      
      private var m_challengerFleetName:String = "";
      
      private var m_challengerID:String = "";
      
      private var m_isRandomFleetChallenge:Boolean = false;
      
      private var m_isPVEChallenge:Boolean = false;
      
      private var m_isNeighborAssist:Boolean = false;
      
      private var m_status:int = 0;
      
      public function ChallengeModeManager()
      {
         super();
      }
      
      public function receivedChallenges() : Dictionary
      {
         return this.m_receivedChallenges;
      }
      
      public function getChallenge(param1:String) : Object
      {
         return this.m_receivedChallenges[param1];
      }
      
      public function storeChallenges(param1:Object) : void
      {
         this.m_receivedChallenges = new Dictionary();
         this.updateChallenges(param1);
      }
      
      public function updateChallenges(param1:Object) : void
      {
         var _loc2_:String = null;
         if(!this.m_receivedChallenges)
         {
            this.m_receivedChallenges = new Dictionary();
         }
         for(_loc2_ in param1)
         {
            this.m_receivedChallenges[_loc2_] = param1[_loc2_];
         }
      }
      
      public function onSelectNewChallengePlayer(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc3_:String = "fleet_" + param1 + "_ai";
         if(this.loadExistingInProgressFleetChallenge(_loc3_))
         {
            return false;
         }
         TransactionManager.addTransaction(new TCreateRandomFleetChallenge(param1,"",param2),true);
         return true;
      }
      
      public function isChallengeInProgress(param1:String) : Boolean
      {
         var _loc2_:Object = this.getOldestChallengeFromUser(param1);
         if(_loc2_ != null)
         {
            return _loc2_.state == ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS;
         }
         return false;
      }
      
      public function isChallengeIDInProgress(param1:String) : Boolean
      {
         var _loc2_:Object = this.m_receivedChallenges[param1];
         if(_loc2_ != null)
         {
            return _loc2_.state == ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS;
         }
         return false;
      }
      
      public function onSelectChallengerPlayer(param1:String) : Boolean
      {
         var _loc2_:Object = this.getOldestChallengeFromUser(param1);
         return this.startChallenge(_loc2_);
      }
      
      public function StartChallengeForChallengeID(param1:String) : Boolean
      {
         var _loc2_:Object = this.m_receivedChallenges[param1];
         return this.startChallenge(_loc2_);
      }
      
      public function startChallenge(param1:Object) : Boolean
      {
         var _loc2_:Fleet = null;
         var _loc3_:Fleet = null;
         if(param1 != null)
         {
            if(param1.state != ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS)
            {
               TransactionManager.addTransaction(new TLoadEnemyFleetForChallenge(param1.eFID),true);
               return true;
            }
            _loc2_ = Fleet.getFleet(param1.pFID);
            _loc3_ = Fleet.getFleet(param1.eFID);
            ChallengeModeManager.instance.setInChallengeBattle(param1.pFID,param1.eFID,param1.eID,param1.isAI,param1.isPVE,param1.isAssist,param1.status);
            GameModeManager.instance.addGameMode(new GMBattle(_loc2_,_loc3_,true));
         }
         return false;
      }
      
      public function getOldestChallengeFromUser(param1:String) : Object
      {
         var _loc4_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         for(_loc4_ in this.m_receivedChallenges)
         {
            if(this.m_receivedChallenges[_loc4_].eID == param1 && !this.m_receivedChallenges[_loc4_].isAI)
            {
               _loc3_ = this.m_receivedChallenges[_loc4_];
               break;
            }
         }
         return _loc3_;
      }
      
      public function loadExistingInProgressFleetChallenge(param1:String) : Boolean
      {
         var _loc3_:Fleet = null;
         var _loc4_:Fleet = null;
         var _loc2_:Object = this.m_receivedChallenges[param1];
         if(_loc2_ != null)
         {
            if(_loc2_.state == ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS)
            {
               _loc3_ = Fleet.getFleet(_loc2_.pFID);
               _loc4_ = Fleet.getFleet(_loc2_.eFID);
               ChallengeModeManager.instance.setInChallengeBattle(_loc2_.pFID,_loc2_.eFID,_loc2_.eID,_loc2_.isAI,_loc2_.isPVE,_loc2_.isAssist,_loc2_.status);
               GameModeManager.instance.addGameMode(new GMBattle(_loc3_,_loc4_,true));
               BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
               return true;
            }
         }
         return false;
      }
      
      public function onLoadEnemyFleetForChallenge(param1:Object) : void
      {
         ZGlobal.player.fleets.addFleetFromData(param1.challengerFleet,param1.challengerFleet.type,param1.challengerFleet.uid);
         var _loc2_:Fleet = ZGlobal.player.fleets.createFleet(param1.challengerFleet.type,true);
         _loc2_.battleTarget = param1.challengerFleet.name;
         var _loc3_:Boolean = PVPManager.instance.isNormalVisit() && ZGlobal.isVisiting();
         this.setInChallengeBattle(_loc2_.name,param1.challengerFleet.name,param1.challengerFleet.uid,false,false,_loc3_,0);
         GameModeManager.instance.addGameMode(new GMBattle(_loc2_,Fleet.getFleet(param1.challengerFleet.name),true));
         if(GMPreBattle.ENABLED)
         {
            GMPreBattle.ACTIVE = true;
            GameModeManager.instance.addGameMode(new GMPreBattle(_loc2_,Fleet.getFleet(param1.challengerFleet.name),Fleet.MAX_UNITS),false);
         }
      }
      
      public function onCreateRandomFleetChallenge(param1:Object, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Fleet = null;
         switch(param1.state)
         {
            case RANDOM_FLEET_CHALLENGE_NEW:
               ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.challengerFleet,param1.challengerFleet.type,param1.challengerFleet.uid);
               this.m_receivedChallenges[param1.challengerFleet.name] = param1.challengeInfo;
               _loc6_ = ZGlobal.player.fleets.createFleet(param1.challengerFleet.type,true);
               _loc6_.battleTarget = param1.challengerFleet.name;
               this.setInChallengeBattle(_loc6_.name,param1.challengerFleet.name,param1.challengerFleet.uid,true,param1.challengerFleet.uid == PVPManager.PVE_MARKER_KEY,false,param1.challengeInfo.status);
               GameModeManager.instance.addGameMode(new GMBattle(_loc6_,Fleet.getFleet(param1.challengerFleet.name),true,param2));
               if(GMPreBattle.ENABLED)
               {
                  GMPreBattle.ACTIVE = true;
                  GameModeManager.instance.addGameMode(new GMPreBattle(_loc6_,Fleet.getFleet(param1.challengerFleet.name),param1.maxUnits),false);
               }
               break;
            case RANDOM_FLEET_CHALLENGE_REFRESH_CLIENT:
               TransactionManager.disable();
               StatsManager.disable();
               _loc3_ = ZGameUtils.ZlocT("Main","RefreshGame");
               ConnectionStatus.showTransactionFaultDialog(_loc3_,GenericPopup.MOOD_SURPRISED);
               break;
            default:
               _loc4_ = int(param1.state);
               _loc3_ = ZGameUtils.ZlocT("Dialogs","InvalidFleetChallengeText") + "  (" + param1.state + ")";
               _loc5_ = ZGameUtils.ZlocT("Dialogs","InvalidFleetChallengeTitle");
               PopupManager.instance.push(GenericPopup1B.NewOk(_loc3_,_loc5_,null));
         }
      }
      
      public function getNeighborRepelChallengeInfo(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:Object = PVPManager.instance.getNeighborAssist(param1);
         if(_loc2_)
         {
            _loc3_ = this.m_receivedChallenges[_loc2_.chID];
            return {
               "challenge":_loc3_,
               "assist":_loc2_
            };
         }
         return null;
      }
      
      public function startNeighborRepel(param1:String, param2:String) : void
      {
         var _loc3_:Object = this.getNeighborRepelChallengeInfo(param1);
         if(Boolean(_loc3_) && Boolean(_loc3_.challenge) && Boolean(_loc3_.assist) && _loc3_.challenge.state == CHALLENGE_STATE_IN_PROGRESS)
         {
            if(_loc3_.challenge.eID != param2)
            {
               PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","PVPFriendDefendInProgressText"),ZGameUtils.ZlocT("Dialogs","PVPFriendDefendInProgressTitle"),null));
            }
            else
            {
               this.StartChallengeForChallengeID(_loc3_.assist.chID);
            }
         }
         else
         {
            TransactionManager.addTransaction(new TRetrieveNeighborRepelChallenge(param1,param2),true);
         }
      }
      
      public function onRetrievedNeighborRepelChallenge(param1:Object, param2:String, param3:String) : void
      {
         var _loc4_:IPVPPlayer = null;
         var _loc5_:PVPCombatStartPopup = null;
         this.m_receivedChallenges[param1.eFID] = param1;
         PVPManager.instance.addNeighborAssist(param2,param1.eFID,param3);
         if(this.StartChallengeForChallengeID(param1.eFID))
         {
            _loc4_ = PVPManager.instance.getPVPPlayer(param3);
            _loc5_ = new PVPCombatStartPopup(ZGlobal.player,_loc4_);
            PVPManager.instance.setAndShowCombatPopup(_loc5_);
         }
      }
      
      public function startFight() : void
      {
         TransactionManager.addTransaction(new TLoadChallenge(this.m_challengerFleetName,this.m_playerFleetName),true);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(ChallengeModeManager.CHALLENGE_STARTED));
      }
      
      public function cancelFight() : void
      {
         ZGlobal.player.fleets.battleOver(this.m_playerFleetName,this.m_challengerFleetName,Battle.BATTLE_RESULT_CANCEL);
         ZGlobal.player.fleets.returnFleetName();
         if(this.isNeighborAssist())
         {
            PVPManager.instance.clearNeighborAssist(ZGlobal.hostPlayer.uid);
         }
      }
      
      public function onAcceptReceivedChallenge(param1:Object) : void
      {
         if(param1)
         {
            this.m_receivedChallenges[param1.eFID] = param1;
         }
      }
      
      public function completeChallengeBattle(param1:int, param2:String) : void
      {
         var _loc3_:Object = this.m_receivedChallenges[param2];
         if(_loc3_ != null)
         {
            if(this.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP) && param1 == Battle.BATTLE_RESULT_WON && ChallengeModeManager.instance.isRandomFleetChallenge() && !ChallengeModeManager.instance.isPVEChallenge())
            {
               ZGlobal.player.addToInventory("GPTK",PVPManager.spinPurchaseKeyCost);
            }
            if(Boolean(_loc3_.isAI) || Boolean(_loc3_.isAssist) || param1 == Battle.BATTLE_RESULT_WON)
            {
               this.deleteReceivedChallenge(param2);
            }
            else
            {
               _loc3_.state = ChallengeModeManager.CHALLENGE_STATE_PENDING;
            }
         }
      }
      
      public function cleanupChallengeBattle(param1:String) : void
      {
         var _loc2_:Object = this.m_receivedChallenges[param1];
         if(_loc2_ != null)
         {
            if(_loc2_.state == ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS)
            {
               ZGlobal.player.fleets.destroyFleet(_loc2_.eFID,Battle.BATTLE_RESULT_NONE);
               ZGlobal.player.fleets.destroyFleet(_loc2_.pFID,Battle.BATTLE_RESULT_NONE);
            }
            this.deleteReceivedChallenge(param1);
         }
      }
      
      private function deleteReceivedChallenge(param1:String) : void
      {
         delete this.m_receivedChallenges[param1];
      }
      
      public function cantInvadeImmunityPopup() : void
      {
         if(!this.m_cantInvadeDialogUp)
         {
            this.m_cantInvadeDialogUp = true;
            PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","CantInvadeImmunityOnMessage"),ZGameUtils.ZlocT("Dialogs","CantInvadeImmunityOnTitle"),this.onImmunityDialogClosed));
         }
      }
      
      public function cantInvadeAreaImmunePopup() : void
      {
         if(!this.m_cantInvadeDialogUp)
         {
            this.m_cantInvadeDialogUp = true;
            PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","CantInvadeAreaImmuneMessage"),ZGameUtils.ZlocT("Dialogs","CantInvadeAreaImmuneTitle"),this.onAreaImmuneDialogClosed));
         }
      }
      
      private function onImmunityDialogClosed(param1:GenericPopupEvent) : void
      {
         this.m_cantInvadeDialogUp = false;
         if(ViewManager.instance.currentViewName != IslandWorld.ID)
         {
            ViewManager.instance.goToPreviousView();
            GameModeManager.instance.setDefaultGameMode();
         }
         ZGame.instance.performVisitNeighbor(ZGlobal.player.uid,false,TWorldLoad.DBG_RETURN,false);
      }
      
      private function onAreaImmuneDialogClosed(param1:GenericPopupEvent) : void
      {
         this.m_cantInvadeDialogUp = false;
         if(ViewManager.instance.currentViewName != IslandWorld.ID)
         {
            ViewManager.instance.goToPreviousView();
            GameModeManager.instance.setDefaultGameMode();
         }
         ZGame.instance.performVisitNeighbor(ZGlobal.player.uid,false,TWorldLoad.DBG_RETURN,false);
      }
      
      public function setInChallengeBattle(param1:String, param2:String, param3:String, param4:Boolean, param5:Boolean, param6:Boolean, param7:int) : void
      {
         this.m_inChallengeBattle = true;
         this.m_playerFleetName = param1;
         this.m_challengerFleetName = param2;
         this.m_challengerID = param3;
         this.m_isRandomFleetChallenge = param4;
         this.m_isPVEChallenge = param5;
         this.m_isNeighborAssist = param6;
         this.m_status = param7;
      }
      
      public function exitChallengeBattle() : void
      {
         this.m_inChallengeBattle = false;
         this.m_playerFleetName = "";
         this.m_challengerFleetName = "";
         this.m_challengerID = "";
         this.m_isRandomFleetChallenge = false;
         this.m_isPVEChallenge = false;
         this.m_isNeighborAssist = false;
         this.m_status = 0;
      }
      
      public function isInChallengeBattle() : Boolean
      {
         return this.m_inChallengeBattle;
      }
      
      public function currentPlayerFleet() : String
      {
         return this.m_playerFleetName;
      }
      
      public function currentChallengerFleet() : String
      {
         return this.m_challengerFleetName;
      }
      
      public function currentChallengerID() : String
      {
         return this.m_challengerID;
      }
      
      public function isRandomFleetChallenge() : Boolean
      {
         return this.m_isRandomFleetChallenge;
      }
      
      public function isPVEChallenge() : Boolean
      {
         return this.m_isPVEChallenge;
      }
      
      public function isNeighborAssist() : Boolean
      {
         return this.m_isNeighborAssist;
      }
      
      public function currentChallengeHasStatus(param1:int) : Boolean
      {
         return (this.m_status & param1) != 0;
      }
      
      public function globalPVPOptedOut() : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc1_:Array = new Array();
         for(_loc2_ in this.m_receivedChallenges)
         {
            _loc3_ = this.m_receivedChallenges[_loc2_];
            if(_loc3_.state == CHALLENGE_STATE_IN_PROGRESS && Boolean(_loc3_.status & CHALLENGE_FLAG_GLOBAL_PVP))
            {
               _loc1_.push(_loc2_);
               ZGlobal.player.fleets.destroyFleet(_loc3_.pFID,Battle.BATTLE_RESULT_RETREAT);
               ZGlobal.player.fleets.destroyFleet(_loc3_.eFID,Battle.BATTLE_RESULT_NONE);
            }
         }
         for each(_loc2_ in _loc1_)
         {
            this.deleteReceivedChallenge(_loc2_);
         }
      }
   }
}

