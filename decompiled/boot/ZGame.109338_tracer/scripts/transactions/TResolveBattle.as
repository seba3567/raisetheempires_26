package transactions
{
   import Engine.Events.TransactionFaultEvent;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.battle.combatchain.HitValue;
   import core.managers.PVPManager;
   import core.managers.dooberManager.DooberManager;
   import displays.popups.GenericPopup;
   import utils.ZGameRandom;
   import zlabs.managers.PopupManager;
   
   public class TResolveBattle extends TZGameTransaction
   {
      
      private var m_data:Object = null;
      
      private var m_w:uint = 0;
      
      private var m_z:uint = 0;
      
      private var m_playerID:int = -1;
      
      private var m_enemyID:int = -1;
      
      private var m_aiAttack:Boolean = false;
      
      private var m_attacker:BattleObject = null;
      
      private var m_defender:BattleObject = null;
      
      private var m_hitValues:HitValue = null;
      
      private var m_attackerStrength:Number = 0;
      
      private var m_defenderStrength:Number = 0;
      
      private var m_unitRoll:Number = 0;
      
      private var m_attackerShields:Number;
      
      private var m_defenderShields:Number;
      
      public function TResolveBattle(param1:BattleObject, param2:BattleObject, param3:Boolean)
      {
         super();
         var _loc4_:Object = ZGameRandom.instance.initialisers;
         this.m_data = new Object();
         this.m_data.fleet = param1.fleet.name;
         this.m_data.target = param2.fleet.name;
         this.m_data.map = ZGlobal.player.campaign.currentMapName;
         this.m_playerID = param1.unit.id;
         this.m_enemyID = param2.unit.id;
         this.m_aiAttack = param3;
         this.m_attacker = param1;
         this.m_defender = param2;
         if(!param3)
         {
            this.m_data.id = new Array();
            this.m_data.id[0] = param1.unit.id;
            this.m_data.id[1] = param2.unit.id;
         }
         if(DooberManager.instance.mysteryDooberResult)
         {
            this.m_data.mysteryDooberResult = DooberManager.instance.mysteryDooberResult;
         }
         if(PVPManager.instance.isAttackVisit())
         {
            this.m_data.attackHostId = ZGlobal.hostPlayer.uid;
         }
      }
      
      public function set target(param1:String) : void
      {
         this.m_data.target = param1;
      }
      
      public function setDebugInfo(param1:HitValue, param2:Number) : void
      {
         this.m_hitValues = param1;
         this.m_unitRoll = param2;
      }
      
      public function setCommandoAssaultFlag(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_data.commandoAssaultBonus = param1;
         }
      }
      
      public function battleComplete(param1:BattleObject, param2:BattleObject) : void
      {
         if(param1)
         {
            this.m_defender = param1;
         }
         if(param2)
         {
            this.m_attacker = param2;
         }
         var _loc3_:Object = ZGameRandom.instance.initialisers;
         this.m_w = _loc3_.w;
         this.m_z = _loc3_.z;
         this.m_attackerStrength = this.m_attacker.unit.strength;
         this.m_defenderStrength = this.m_defender.unit.strength;
         this.m_attackerShields = this.m_attacker.unit.shields;
         this.m_defenderShields = this.m_defender.unit.shields;
         if(Boolean(param1 && param1.dead) && Boolean(param1.fleet.numUnits < 2) && Boolean(DooberManager.instance.mysteryDooberResult))
         {
            this.m_data.mysteryDooberResult = DooberManager.instance.mysteryDooberResult;
         }
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.resolveBattle",modifiedData(this.m_data));
      }
      
      private function debugSeeds() : String
      {
         return "(w:" + GMBattle.debugSeeds[0] + " z:" + GMBattle.debugSeeds[1] + ")";
      }
      
      private function different(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Number = Math.abs(param2 - param1);
         return _loc3_ >= 0.01;
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.attackerStunned != null)
         {
            this.warning("TResolveBattle: the attacker should be stunned!");
         }
         else
         {
            if(param1.psh != this.m_attackerShields || param1.esh != this.m_defenderShields)
            {
               this.warning("TResolveBattle: unit shields out of sync: (" + param1.psh + "," + this.m_attackerShields + ")(" + param1.esh + "," + this.m_defenderShields + ") " + this.debugSeeds());
            }
            if(param1.ps != this.m_attackerStrength || param1.es != this.m_defenderStrength)
            {
               this.warning("TResolveBattle: unit strength out of sync: (" + param1.ps + "," + this.m_attackerStrength + ")(" + param1.es + "," + this.m_defenderStrength + ") " + this.debugSeeds());
            }
            if(param1.hv)
            {
               if(this.different(param1.hv.critical,this.m_hitValues.critical))
               {
                  this.warning("TResolveBattle: hitValues critical out of sync: (" + param1.hv.critical + "," + this.m_hitValues.critical + ") " + this.debugSeeds());
               }
               if(this.different(param1.hv.direct,this.m_hitValues.direct))
               {
                  this.warning("TResolveBattle: hitValues direct out of sync: (" + param1.hv.direct + "," + this.m_hitValues.direct + ") " + this.debugSeeds());
               }
            }
            if(this.different(param1.ur,this.m_unitRoll))
            {
               this.warning("TResolveBattle: unitRoll out of sync: (" + param1.ur + "," + this.m_unitRoll + ") " + this.debugSeeds());
            }
            if(param1.playerUnit != this.m_playerID || param1.enemyUnit != this.m_enemyID)
            {
               this.error("TResolveBattle: unit IDs out of sync: aiAttack(" + this.m_aiAttack + ") player(" + param1.playerUnit + "," + this.m_playerID + ") enemy(" + param1.enemyUnit + "," + this.m_enemyID + ") " + this.debugSeeds());
            }
            if(param1.seeds.w != this.m_w || param1.seeds.z != this.m_z)
            {
               this.error("TResolveBattle: ZGameRandom fatally out of sync: (" + param1.seeds.w + "," + this.m_w + ")(" + param1.seeds.z + "," + this.m_z + ") " + this.debugSeeds());
            }
         }
         super.onComplete(param1);
      }
      
      private function error(param1:String) : void
      {
         TransactionManager.getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.FAULT,this,INVALID_DATA,param1));
      }
      
      private function warning(param1:String) : void
      {
         if(Config.DEBUG_MODE)
         {
            PopupManager.instance.push(new GenericPopup(param1));
         }
      }
   }
}

