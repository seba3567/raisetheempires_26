package core.entities.components.behaviors.states
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.RafflePickComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.RaffleManager;
   import displays.popups.RaffleDrawPopUp;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import transactions.TRaffleDraw;
   import transactions.TSetRaffleHintSeen;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntityComponent;
   import zlabs.managers.WindowManager;
   
   public class RaffleRollState extends DialogState
   {
      
      private var m_timer:Timer = null;
      
      private var gdc:GameDataComponent = null;
      
      public function RaffleRollState(param1:BehaviorStateInit)
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
            RaffleManager.instance.addEventListener(RaffleManager.START_CLICK,this.onStartRoll);
            RaffleManager.instance.addEventListener(RaffleManager.ROLL_COMPLETE,this.onRollComplete);
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
            RaffleManager.instance.removeEventListener(RaffleManager.ROLL_COMPLETE,this.onRollComplete);
            RaffleManager.instance.removeEventListener(RaffleManager.START_CLICK,this.onStartRoll);
         }
         super.performExitActions(param1);
      }
      
      override public function onClick(param1:Event) : void
      {
         if(ZGlobal.isHome())
         {
            this.gdc = GameDataComponent.getGameDataComponent(owner);
            if(Boolean(this.gdc) && Boolean(this.gdc.userData))
            {
               if(!this.gdc.userData.winningTickets)
               {
                  this.gdc.userData.winningTickets = [];
               }
            }
            if(this.gdc.userData.winningTickets.length >= 5)
            {
               onCloseClick(null);
               clickNextState();
            }
            else
            {
               StatsManager.count("dialog","Raffle","raffle_ui","draw_stage");
               super.onClick(param1);
            }
         }
      }
      
      override protected function showDialog() : void
      {
         if(ZGlobal.isHome())
         {
            if(this.gdc.userData.hintSeen)
            {
               WindowManager.instance.push(new RaffleDrawPopUp(owner,false));
            }
            else
            {
               StatsManager.count("dialog","Raffle","tutorial");
               TransactionManager.addTransaction(new TSetRaffleHintSeen(owner),true);
               WindowManager.instance.push(new RaffleDrawPopUp(owner,true));
               this.gdc.userData.hintSeen = true;
            }
         }
      }
      
      protected function onRollComplete(param1:Event) : void
      {
         onCloseClick(null);
         this.showDialog();
      }
      
      protected function onStartRoll(param1:Event) : void
      {
         TransactionManager.addTransaction(new TRaffleDraw(owner),true);
      }
      
      private function onTimer(param1:Event) : void
      {
         var _loc2_:XML = RaffleManager.instance.rollDateRange;
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
         owner.addComponent(new RafflePickComponent(owner,true),"RafflePick");
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

