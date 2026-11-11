package core.entities.components.behaviors.states
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.RafflePickComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.RaffleManager;
   import displays.popups.RafflePopUp;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import transactions.TSetRaffleHintSeen;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntityComponent;
   import zlabs.managers.WindowManager;
   
   public class RaffleCollectState extends DialogState
   {
      
      private var m_timer:Timer = null;
      
      private var gdc:GameDataComponent = null;
      
      public function RaffleCollectState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.isHome())
         {
            this.m_timer = new Timer(10000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
            this.showPick();
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         if(ZGlobal.isHome())
         {
            this.removePick();
            if(this.m_timer != null)
            {
               this.m_timer.stop();
               this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer = null;
            }
         }
         super.performExitActions(param1);
      }
      
      override public function onClick(param1:Event) : void
      {
         if(ZGlobal.isHome())
         {
            StatsManager.count("dialog","Raffle","raffle_ui","collect_stage");
            this.gdc = GameDataComponent.getGameDataComponent(owner);
            super.onClick(param1);
         }
      }
      
      override protected function showDialog() : void
      {
         if(ZGlobal.isHome())
         {
            if(this.gdc.userData.hintSeen)
            {
               WindowManager.instance.push(new RafflePopUp(owner,false));
            }
            else
            {
               StatsManager.count("dialog","Raffle","tutorial");
               TransactionManager.addTransaction(new TSetRaffleHintSeen(owner),true);
               WindowManager.instance.push(new RafflePopUp(owner,true));
               this.gdc.userData.hintSeen = true;
            }
         }
      }
      
      private function onTimer(param1:Event) : void
      {
         var _loc2_:XML = RaffleManager.instance.collectDateRange;
         var _loc3_:Object = {"stringNotUsed":true};
         if(ZGameTimeUtil.instance.getDateStatus(_loc3_,_loc2_) == ZGameTimeUtil.DATE_STATUS_LATE)
         {
            onCloseClick(null);
            clickNextState();
         }
      }
      
      public function showPick() : void
      {
         var _loc1_:IEntityComponent = owner.lookupComponentByName("RafflePick");
         if(_loc1_)
         {
            owner.removeComponent(_loc1_);
         }
         owner.addComponent(new RafflePickComponent(owner,false),"RafflePick");
      }
      
      public function removePick() : void
      {
         var _loc1_:IEntityComponent = owner.lookupComponentByName("RafflePick");
         if(_loc1_)
         {
            owner.removeComponent(_loc1_);
         }
      }
   }
}

