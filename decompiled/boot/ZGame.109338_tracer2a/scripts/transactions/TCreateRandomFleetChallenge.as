package transactions
{
   import Engine.Transactions.Transaction;
   import core.gamemode.battle.BattleDispatcher;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.managers.dooberManager.DooberManager;
   import flash.events.Event;
   
   public class TCreateRandomFleetChallenge extends Transaction
   {
      
      private var m_defenderID:String;
      
      private var m_fleetType:String;
      
      private var m_restoreToStrategicMap:Boolean;
      
      public function TCreateRandomFleetChallenge(param1:String, param2:String, param3:Boolean = false)
      {
         super();
         this.m_restoreToStrategicMap = param3;
         this.m_defenderID = param1;
         this.m_fleetType = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.createRandomFleetChallenge",this.m_defenderID,this.m_fleetType);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1 == ChallengeModeManager.ERR_CANT_INVADE_IMMUNITY_ON)
         {
            ChallengeModeManager.instance.cantInvadeImmunityPopup();
         }
         else if(param1 == ChallengeModeManager.ERR_CANT_INVADE_AREA_IMMUNE)
         {
            ChallengeModeManager.instance.cantInvadeAreaImmunePopup();
         }
         else
         {
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.PRE_BATTLE_CANCEL));
            ChallengeModeManager.instance.onCreateRandomFleetChallenge(param1,this.m_restoreToStrategicMap);
         }
         PVPManager.instance.clearCombatPopup();
         if(param1.hasOwnProperty("loot") && Boolean(param1.loot))
         {
            DooberManager.instance.setMysteryDooberResult(DooberManager.MYSTERY_DOOBER_ITEM,param1.loot);
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.PRE_BATTLE_CANCEL));
         PVPManager.instance.clearCombatPopup();
      }
   }
}

