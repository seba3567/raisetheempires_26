package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.UnitItem;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import displays.popups.alliancePopup.AllianceBattleTransitionPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.ModalPopup;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class TLoadAllianceBattle extends Transaction
   {
      
      private static const FLEET_DEFENSE_DUMMY_PLAYER:String = "fleet_defense_dummy_player";
      
      private static const FLEET_DEFENSE_DUMMY_ENEMY:String = "fleet_defense_dummy_enemy";
      
      private var m_data:Object = null;
      
      private var m_enemyId:String = null;
      
      private var m_loadingScreen:ModalPopup;
      
      public function TLoadAllianceBattle(param1:String = null, param2:String = null, param3:String = null, param4:Boolean = false)
      {
         super();
         this.m_enemyId = param2;
         this.m_data = new Object();
         this.m_data.enemyID = param2;
         this.m_data.allianceName = param3;
         this.m_data.continueBattle = param4;
         this.m_data.memberInfo = false;
         var _loc5_:String = null;
         var _loc6_:Object = DominationModeManager.instance.getAllianceInfo(param3);
         if(!_loc6_ || !_loc6_.membersInfo)
         {
            this.m_data.memberInfo = true;
         }
         if(param1 != null)
         {
            AlliancesManager.instance.battleWaveIntro();
            this.m_data.playerFleetName = param1;
            this.m_data.playerFleet = ZGlobal.player.fleets.getSerialisableFleet(param1);
         }
         else if(!param4)
         {
            this.m_loadingScreen = new AllianceBattleTransitionPopup(param3,true);
         }
         else
         {
            this.m_loadingScreen = new AllianceBattleTransitionPopup(param3,true);
         }
         if(this.m_loadingScreen)
         {
            WindowManager.instance.push(this.m_loadingScreen,0,false,true);
         }
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.loadAllianceBattle",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup1B = null;
         super.onComplete(param1);
         if(this.m_loadingScreen)
         {
            this.m_loadingScreen.pop();
            this.m_loadingScreen = null;
         }
         else
         {
            AlliancesManager.instance.closeWaveLoadingScreen();
         }
         if(Boolean(param1) && Boolean(param1.state))
         {
            if(Boolean(this.m_data) && Boolean(this.m_data.memberInfo))
            {
               if(param1.membersInfo)
               {
                  DominationModeManager.instance.updateAllianceMemberList(this.m_data.allianceName,param1.membersInfo);
               }
               if(param1.members)
               {
                  _loc2_ = new Dictionary();
                  _loc2_[this.m_data.allianceName] = param1.members;
                  AlliancesManager.instance.populateAllianceData(_loc2_);
               }
            }
            if(param1.hasOwnProperty("BattleData"))
            {
               AlliancesManager.instance.allianceBattleData(param1.BattleData);
               if(Boolean(param1.BattleData) && Boolean(param1.BattleData["inProgress"]))
               {
                  this.m_enemyId = param1.BattleData["inProgress"];
               }
            }
            switch(param1.state)
            {
               case 1:
                  this.dominationBattlePlayerSetup(this.m_enemyId,param1.type,param1);
                  break;
               case 2:
                  this.loadBattle(param1);
                  break;
               case 3:
                  if(param1.error)
                  {
                     _loc3_ = "DominationBattleError" + param1.error;
                     _loc4_ = ZGameUtils.ZlocT("Dialogs",_loc3_);
                     _loc5_ = GenericPopup1B.NewOk(_loc4_,null);
                     PopupManager.instance.push(_loc5_);
                     if(!this.m_enemyId)
                     {
                        this.m_enemyId = "no uid";
                     }
                     Logger.print(this,"Domination Battle error for uid " + this.m_enemyId + ": " + _loc4_);
                  }
               default:
                  if(AlliancesManager.instance.allianceBattle)
                  {
                     DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.EXIT_DOMINATION_PREBATTLE));
                  }
                  DominationModeManager.instance.exitDominationBattle();
            }
         }
      }
      
      public function isNewBattle(param1:String) : Boolean
      {
         var _loc2_:Object = DominationModeManager.instance.getAllianceInfo(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.int))
         {
            return false;
         }
         return true;
      }
      
      private function dominationBattlePlayerSetup(param1:String, param2:String, param3:Object) : void
      {
         if(param2 == null || param2 != UnitItem.ARMY && param2 != UnitItem.NAVY && param2 != UnitItem.AIR)
         {
            param2 = UnitItem.ARMY;
         }
         var _loc4_:Fleet = ZGlobal.player.fleets.getFleetByName(FLEET_DEFENSE_DUMMY_PLAYER);
         if(!_loc4_)
         {
            _loc4_ = ZGlobal.player.fleets.createTempFleet(param2,"0");
            _loc4_.name = FLEET_DEFENSE_DUMMY_PLAYER;
            _loc4_.setStatus(Fleet.DOMINATION_DEFENSE);
            if(!this.isNewBattle(this.m_data.allianceName))
            {
               _loc4_.setStatus(Fleet.DOMINATION_RETAL);
            }
         }
         else
         {
            _loc4_.clearUnits();
            _loc4_.type = param2;
            if(this.isNewBattle(this.m_data.allianceName))
            {
               _loc4_.clearStatus(Fleet.DOMINATION_RETAL);
            }
            else
            {
               _loc4_.setStatus(Fleet.DOMINATION_RETAL);
            }
         }
         var _loc5_:Fleet = ZGlobal.player.fleets.getFleetByName(FLEET_DEFENSE_DUMMY_ENEMY);
         if(!_loc5_)
         {
            _loc5_ = ZGlobal.player.fleets.createTempFleet(param2,"0");
            _loc5_.name = FLEET_DEFENSE_DUMMY_ENEMY;
         }
         else
         {
            _loc5_.type = param2;
         }
         DominationModeManager.instance.resetSetupFleetStrength();
         DominationModeManager.instance.setInDominationBattle(param1);
         AlliancesManager.instance.allianceBattleMember = param1;
         AlliancesManager.instance.allianceBattle = true;
         AlliancesManager.instance.battleAllianceName = this.m_data.allianceName;
         GameModeManager.instance.addGameMode(new GMBattle(_loc4_,_loc5_));
         if(GMPreBattle.ENABLED)
         {
            GMPreBattle.ACTIVE = true;
            GameModeManager.instance.addGameMode(new GMPreBattle(_loc4_,_loc5_,Fleet.MAX_UNITS),false);
         }
      }
      
      private function loadBattle(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc6_:String = null;
         ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.playerFleet,param1.playerFleet.type,param1.playerFleet.uid);
         ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.enemyFleet,param1.enemyFleet.type,param1.enemyFleet.uid);
         var _loc2_:Fleet = Fleet.getFleet(param1.playerFleet.name);
         var _loc3_:Fleet = Fleet.getFleet(param1.enemyFleet.name);
         var _loc4_:Object = DominationModeManager.instance.getDominationInfo(this.m_enemyId);
         if(param1.hasOwnProperty("scDec"))
         {
            if(_loc4_)
            {
               _loc4_.scDec = param1.scDec;
            }
         }
         if(param1.hasOwnProperty("battleScores"))
         {
            if(_loc4_)
            {
               _loc5_ = param1["battleScores"];
               for(_loc6_ in _loc5_)
               {
                  _loc4_[_loc6_] = _loc5_[_loc6_];
               }
            }
         }
         if(param1.newStart)
         {
            _loc2_.deploy();
            DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.EXIT_DOMINATION_PREBATTLE));
         }
         AlliancesManager.instance.allianceBattle = true;
         AlliancesManager.instance.allianceBattleMember = this.m_enemyId;
         DominationModeManager.instance.setInDominationBattle(param1.enemyFleet.uid);
         GameModeManager.instance.addGameMode(new GMBattle(_loc2_,_loc3_));
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
      }
   }
}

