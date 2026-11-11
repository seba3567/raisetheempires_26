package core.gameobjects
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import flash.utils.Dictionary;
   
   public class PlayerFleets
   {
      
      private var m_globalFleetId:int = 0;
      
      private var m_fleets:Array = null;
      
      private var m_battleStatus:Dictionary = null;
      
      public function PlayerFleets(param1:Array, param2:Array, param3:int, param4:Object)
      {
         var _loc6_:String = null;
         var _loc7_:Fleet = null;
         super();
         var _loc5_:Object = null;
         this.m_globalFleetId = param3;
         this.m_fleets = new Array();
         for each(_loc5_ in param1)
         {
            this.addFleetFromData(_loc5_,_loc5_.type,_loc5_.uid);
         }
         for each(_loc5_ in param2)
         {
            _loc7_ = new Fleet(_loc5_,_loc5_.type,null);
            _loc7_.setStatus(Fleet.QUEST);
            this.m_fleets.push(_loc7_);
         }
         this.m_battleStatus = new Dictionary();
         for(_loc6_ in param4)
         {
            this.m_battleStatus[_loc6_] = param4[_loc6_];
         }
      }
      
      public function get battleStatus() : Dictionary
      {
         return this.m_battleStatus;
      }
      
      public function addFleetFromData(param1:Object, param2:String, param3:String) : void
      {
         if(this.getFleetByName(param1.name) == null)
         {
            this.m_fleets.push(new Fleet(param1,param2,param3));
         }
      }
      
      public function addServerGeneratedFleetFromData(param1:Object, param2:String, param3:String) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Fleet = this.getFleetByName(param1.name);
         if(_loc4_ != null)
         {
            _loc5_ = this.m_fleets.indexOf(_loc4_);
            _loc4_.clearWarehouseHoldings();
            this.m_fleets.splice(_loc5_,1);
         }
         this.m_fleets.push(new Fleet(param1,param2,param3));
      }
      
      public function teleportFleet(param1:Object, param2:String, param3:Number, param4:Number) : void
      {
         var _loc7_:Fleet = null;
         var _loc8_:int = 0;
         if(param1.name != null)
         {
            _loc7_ = this.getFleet(param1.name);
            if(_loc7_ != null)
            {
               _loc8_ = this.m_fleets.indexOf(_loc7_);
               this.m_fleets.splice(_loc8_,1);
            }
         }
         var _loc5_:Fleet = new Fleet(param1,param1.type,null);
         this.m_fleets.push(_loc5_);
         var _loc6_:Pt = new Pt(param3,param4,0);
         _loc5_.teleport(_loc6_);
      }
      
      public function get fleets() : Array
      {
         return this.m_fleets;
      }
      
      public function getNextFleetName(param1:String) : String
      {
         var _loc2_:String = "fleet" + this.m_globalFleetId.toString() + "_" + param1;
         ++this.m_globalFleetId;
         return _loc2_;
      }
      
      public function returnFleetName() : void
      {
         --this.m_globalFleetId;
      }
      
      public function updateName(param1:String) : String
      {
         var _loc2_:int = param1.indexOf("_");
         var _loc3_:String = param1.slice(_loc2_ + 1);
         return this.getNextFleetName(_loc3_);
      }
      
      public function createFleet(param1:String, param2:Boolean) : Fleet
      {
         var _loc3_:Fleet = new Fleet(null,param1,ZGlobal.player.uid);
         _loc3_.name = this.getNextFleetName(ZGlobal.player.uid);
         if(param2)
         {
            _loc3_.createHitPercentageRecorder(null);
         }
         this.m_fleets.push(_loc3_);
         return _loc3_;
      }
      
      public function createTempFleet(param1:String, param2:String) : Fleet
      {
         var _loc3_:Fleet = new Fleet(null,param1,param2);
         this.m_fleets.push(_loc3_);
         return _loc3_;
      }
      
      public function destroyFleet(param1:String, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Fleet = this.getFleetByName(param1);
         if(null != _loc3_)
         {
            _loc3_.undeploy(param2);
            if(param2 == Battle.BATTLE_RESULT_LOST && _loc3_.hasStatus(Fleet.QUEST))
            {
               _loc3_.setOutOfCombat();
            }
            else
            {
               _loc3_.dispose();
               _loc4_ = this.m_fleets.indexOf(_loc3_);
               this.m_fleets.splice(_loc4_,1);
            }
         }
      }
      
      public function fightItemTaskComplete(param1:String, param2:int) : void
      {
         var _loc3_:Fleet = this.getFleetByName(param1);
         if(_loc3_)
         {
            this.battleOver(_loc3_.battleTarget,param1,param2);
         }
      }
      
      public function battleOver(param1:String, param2:String, param3:int) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc4_:Fleet = this.getFleetByName(param1);
         if(null != _loc4_)
         {
            if(ZGlobal.combatAllyGatingVarient != ZGlobal.EXPERIMENT_ALLY_GATING_START_TIMERS_WHEN_USED)
            {
               _loc4_.finishedWithAllies();
            }
            _loc4_.finishedWithConsumables();
         }
         if(!(_loc4_.hasStatus(Fleet.SURVIVAL_PLAYER) && param3 == Battle.BATTLE_RESULT_WON))
         {
            if(AlliancesManager.instance.allianceBattle && param3 == Battle.BATTLE_RESULT_WON)
            {
               _loc5_ = AlliancesManager.instance.battleAllianceName;
               _loc6_ = DominationModeManager.instance.getDominationEnemyUID();
               _loc7_ = AlliancesManager.instance.loadNextMember(_loc6_,_loc5_);
               if(!_loc7_)
               {
                  this.destroyFleet(param1,param3);
                  this.destroyFleet(DominationModeManager.FLEET_DEFENSE_DUMMY_PLAYER,param3);
               }
            }
            else
            {
               this.destroyFleet(param1,param3);
               if(AlliancesManager.instance.allianceBattle)
               {
                  this.destroyFleet(DominationModeManager.FLEET_DEFENSE_DUMMY_PLAYER,param3);
               }
            }
         }
         this.destroyFleet(param2,param3);
      }
      
      public function getFleetByName(param1:String) : Fleet
      {
         return this.getFleet(param1);
      }
      
      public function getFleetWithBattleTarget(param1:String) : Fleet
      {
         var _loc2_:Fleet = null;
         for each(_loc2_ in this.m_fleets)
         {
            if(_loc2_.battleTarget == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function removeUnit(param1:String, param2:Unit) : void
      {
         var _loc3_:Fleet = this.getFleet(param1);
         if(_loc3_)
         {
            _loc3_.removeUnitObject(param2);
            if(_loc3_.units.length == 0)
            {
               _loc3_.dispose();
            }
         }
      }
      
      public function retreatUnit(param1:String, param2:Unit) : void
      {
         var _loc3_:Fleet = this.getFleet(param1);
         if(_loc3_)
         {
            _loc3_.retreatUnitObject(param2);
            if(_loc3_.units.length == 0)
            {
               _loc3_.dispose();
            }
         }
      }
      
      public function countUnits(param1:String) : int
      {
         var _loc3_:Fleet = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_fleets)
         {
            _loc2_ += _loc3_.countUnits(param1);
         }
         return _loc2_;
      }
      
      public function numUnits(param1:String) : int
      {
         var _loc2_:Fleet = this.getFleet(param1);
         if(_loc2_)
         {
            return _loc2_.units.length;
         }
         return 0;
      }
      
      public function hasPlayerOwnedFleetNamed(param1:String, param2:String) : Boolean
      {
         var _loc3_:Fleet = this.getFleet(param1);
         if(_loc3_)
         {
            return _loc3_.isOwnedByPlayer(param2) == true;
         }
         return false;
      }
      
      public function hasEnemyOwnedFleetNamed(param1:String, param2:String) : Boolean
      {
         var _loc3_:Fleet = this.getFleet(param1);
         if(_loc3_)
         {
            return _loc3_.isOwnedByPlayer(param2) == false;
         }
         return false;
      }
      
      public function getUnitIndex(param1:String, param2:Unit) : int
      {
         var _loc3_:Fleet = this.getFleet(param1);
         if(_loc3_)
         {
            return _loc3_.units.indexOf(param2);
         }
         return -1;
      }
      
      public function getSerialisableFleet(param1:String, param2:Array = null) : Object
      {
         var _loc3_:Fleet = this.getFleet(param1);
         return _loc3_.serialisableObject(param2);
      }
      
      public function serialisableObject(param1:Array = null) : Array
      {
         var _loc3_:Fleet = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this.m_fleets)
         {
            _loc2_.push(_loc3_.serialisableObject(param1));
         }
         return _loc2_;
      }
      
      public function getFirstFleet(param1:Boolean) : Fleet
      {
         var _loc2_:Fleet = null;
         for each(_loc2_ in this.m_fleets)
         {
            if(param1 == (_loc2_.uid == ZGlobal.player.uid))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function numPlayerOwnedFleets(param1:String, param2:String) : int
      {
         var _loc4_:Fleet = null;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_fleets)
         {
            if(_loc4_.type == param2)
            {
               if(_loc4_.isOwnedByPlayer(ZGlobal.player.uid))
               {
                  _loc3_++;
               }
            }
         }
         return _loc3_;
      }
      
      private function getFleet(param1:String) : Fleet
      {
         var _loc2_:Fleet = null;
         for each(_loc2_ in this.m_fleets)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function setupExistingBattles() : void
      {
      }
   }
}

