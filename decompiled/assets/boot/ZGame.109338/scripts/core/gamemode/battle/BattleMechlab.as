package core.gamemode.battle
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.BaddieItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.PartsBuildingItem;
   import core.gameobjects.UnitItem;
   import dispatchers.UIDispatcher;
   import displays.popups.battlelost.BattleMechlabLostPopup;
   import displays.popups.battlewon.BattleChallengeWonPopup;
   import displays.popups.mechlab.FinalReward;
   import displays.screens.partsGather.MechLabPartsGather;
   import flash.utils.Dictionary;
   import transactions.TMechlabStatus;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BattleMechlab extends BattleHost
   {
      
      private static const PRIZE_COUNT:uint = 3;
      
      private static var m_currentPrize:String = null;
      
      public function BattleMechlab(param1:Fleet, param2:Fleet)
      {
         super(param1,param2);
      }
      
      public static function startBattle(param1:int, param2:String) : void
      {
         var _loc3_:Fleet = getEnemyFleet(param1);
         if(!_loc3_)
         {
            _loc3_ = createEnemyFleet(param1,param2);
         }
         var _loc4_:Fleet = ZGlobal.player.fleets.getFleetWithBattleTarget(_loc3_.name);
         if(!_loc4_)
         {
            _loc4_ = createPlayerFleet(_loc3_);
         }
         TransactionManager.addTransaction(new TMechlabStatus(param1,param2));
         m_currentPrize = getRewardFromIndex(param1,param2);
         var _loc5_:Boolean = _loc4_.units.length > 0;
         if(!_loc5_)
         {
            GMPreBattle.ACTIVE = true;
            GameModeManager.instance.addGameMode(new GMBattle(_loc4_,_loc3_,false,false));
            GameModeManager.instance.addGameMode(new GMPreBattle(_loc4_,_loc3_,5,false),false);
         }
         else
         {
            GameModeManager.instance.addGameMode(new GMBattle(_loc4_,_loc3_,false,false));
         }
      }
      
      public static function startBattleFromEnemyFleet(param1:String) : void
      {
         startBattle(getEnemyFleetIndex(param1),"TL01");
      }
      
      private static function getEnemyFleetIndex(param1:String) : int
      {
         var _loc2_:Array = param1.split("_");
         return _loc2_[_loc2_.length - 1];
      }
      
      private static function getEnemyFleetPartsItemCode(param1:String) : String
      {
         var _loc2_:Array = param1.split("_");
         return _loc2_[_loc2_.length - 2];
      }
      
      private static function createEnemyFleet(param1:int, param2:String) : Fleet
      {
         var _loc3_:BaddieItem = ZGlobal.gameSettings.getItemByCode("BM03",BaddieItem) as BaddieItem;
         var _loc4_:Array = _loc3_.items;
         var _loc5_:Fleet = ZGlobal.player.fleets.createFleet(UnitItem.ARMY,false);
         _loc5_.name += "_" + getRewardFromIndex(param1,param2);
         _loc5_.name += "_" + param1;
         _loc5_.setStatus(Fleet.MECHLAB);
         _loc5_.setStatus(Fleet.RESTORE_ON_RETREAT);
         _loc5_.setStatus(Fleet.PERSISTS);
         _loc3_.addUnitsToFleet(_loc5_,_loc4_);
         return _loc5_;
      }
      
      private static function createPlayerFleet(param1:Fleet) : Fleet
      {
         var _loc2_:Fleet = ZGlobal.player.fleets.createFleet(UnitItem.ARMY,true);
         Fleet.linkFleets(_loc2_,param1);
         return _loc2_;
      }
      
      private static function getRewardFromIndex(param1:int, param2:String) : String
      {
         var _loc3_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(param2,PartsBuildingItem) as PartsBuildingItem;
         return _loc3_.getPartCodeForIndex(param1);
      }
      
      private static function getEnemyFleet(param1:int) : Fleet
      {
         var _loc2_:Fleet = null;
         var _loc3_:int = 0;
         for each(_loc2_ in ZGlobal.player.fleets.fleets)
         {
            if(_loc2_.hasStatus(Fleet.MECHLAB))
            {
               _loc3_ = getEnemyFleetIndex(_loc2_.name);
               if(_loc3_ == param1)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public static function get prizeCount() : uint
      {
         return BattleMechlab.PRIZE_COUNT;
      }
      
      override public function dispose() : void
      {
         if(m_battleResult == Battle.BATTLE_RESULT_WON)
         {
            PopupManager.instance.push(new FinalReward(m_currentPrize));
         }
         m_currentPrize = null;
         super.dispose();
         UIDispatcher.instance.dispatchEvent(new WorldEvent(MechLabPartsGather.SHOW_MECHLAB_PARTS_GATHER));
      }
      
      override public function showWonPopup(param1:Array, param2:Array, param3:Dictionary, param4:Function) : void
      {
         if(m_currentPrize)
         {
            ZGlobal.player.addToInventory(m_currentPrize,BattleMechlab.prizeCount);
         }
         PopupManager.instance.push(new BattleChallengeWonPopup(m_enemyFleetName,param2,param3,param4));
      }
      
      override public function showLosePopup(param1:Array, param2:Dictionary, param3:Function) : void
      {
         PopupManager.instance.push(new BattleMechlabLostPopup(param1,param2,param3));
      }
      
      override protected function removeFleets() : void
      {
         var _loc2_:Fleet = null;
         var _loc1_:String = m_enemyFleetName;
         if(m_battleResult == BATTLE_RESULT_RETREAT || m_battleResult == BATTLE_RESULT_LOST || m_battleResult == BATTLE_RESULT_CANCEL)
         {
            _loc2_ = Fleet.getFleet(_loc1_);
            _loc2_.battleTarget = null;
            if(m_battleResult == BATTLE_RESULT_RETREAT)
            {
               _loc2_.restore();
            }
            else if(m_battleResult == BATTLE_RESULT_LOST)
            {
               _loc2_.removeConsumables();
            }
            _loc1_ = null;
         }
         ZGlobal.player.fleets.battleOver(m_playerFleetName,_loc1_,m_battleResult);
      }
      
      override public function get isMechLab() : Boolean
      {
         return true;
      }
   }
}

