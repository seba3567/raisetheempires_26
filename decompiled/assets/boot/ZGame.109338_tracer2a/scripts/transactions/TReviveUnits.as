package transactions
{
   import Engine.Events.TransactionFaultEvent;
   import Engine.Managers.TransactionManager;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.combatchain.HitValue;
   import displays.popups.GenericPopup;
   import zlabs.debug.Logger;
   import zlabs.managers.PopupManager;
   
   public class TReviveUnits extends TZGameTransaction
   {
      
      private var m_data:Object = null;
      
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
      
      public function TReviveUnits(param1:Array, param2:String)
      {
         super();
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.m_data = new Object();
         this.m_data.fleet = param2;
         this.m_data.units = param1;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.reviveUnits",modifiedData(this.m_data));
      }
      
      override protected function onComplete(param1:Object) : void
      {
         Logger.info(this,"onComplete","Transaction complete");
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

