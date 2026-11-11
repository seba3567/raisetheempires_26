package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.FightMeterManager;
   import dispatchers.UIDispatcher;
   import flash.events.Event;
   
   public class TActivateFightMeter extends Transaction
   {
      
      private var m_lastActivatedTime:int = 0;
      
      private var m_weeklyProgressionExpired:Boolean = false;
      
      public function TActivateFightMeter(param1:int, param2:Boolean)
      {
         this.m_lastActivatedTime = param1;
         this.m_weeklyProgressionExpired = param2;
         FightMeterManager.instance.setLevelTarget(FightMeterManager.instance.getLevelTargetProgression(ZGlobal.player.level));
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.reactivateFightMeter",this.m_lastActivatedTime,this.m_weeklyProgressionExpired);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:int = int(param1.targetFights);
         FightMeterManager.instance.battleTarget = _loc2_;
         UIDispatcher.instance.dispatchEvent(new Event(UIDispatcher.UI_FIGHTMETER_RELOADED));
      }
   }
}

