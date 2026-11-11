package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.ExperimentsManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import zlabs.debug.Logger;
   
   public class ZGenerateState extends SimpleAutoState
   {
      
      private static var m_timer:Timer;
      
      private var m_extendedStartTime:Number = 0;
      
      private var m_totalTicks:int = 0;
      
      public function ZGenerateState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         if(!m_startTime)
         {
            this.m_extendedStartTime = GlobalEngine.serverTime;
         }
         else
         {
            this.m_extendedStartTime = m_startTime;
         }
         super.performEnterActions();
         this.m_totalTicks = (this.m_extendedStartTime + m_durationSeconds.adjusted * 1000 - GlobalEngine.getTimer()) / (1000 * 60);
         Logger.info(this,"ZGenerate","m_totalTicks is " + this.m_totalTicks);
         if(ZGlobal.isHome())
         {
            if(!m_timer)
            {
               m_timer = new Timer(60000,this.m_totalTicks);
               m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
               m_timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerOver);
               m_timer.start();
               Logger.info(this,"ZGenerate","Starting the ZGeneration");
            }
            PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).showZRegenerator();
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         if(ZGlobal.isHome())
         {
            this.onTimerOver();
         }
         super.performExitActions(param1);
      }
      
      override public function sell() : void
      {
         if(ZGlobal.isHome())
         {
            this.onTimerOver();
         }
         super.sell();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         switch(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_ZGENERATOR_REGENTIME))
         {
            case 0:
            case 1:
               ZGlobal.player.mana.give(4);
               break;
            case 2:
               ZGlobal.player.mana.give(2);
         }
      }
      
      private function onTimerOver(param1:TimerEvent = null) : void
      {
         if(m_timer != null)
         {
            m_timer.stop();
            m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerOver);
            m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            m_timer = null;
            Logger.info(this,"ZGenerate","Removing the Timer");
         }
         Logger.info(this,"ZGenerate","Stopping the ZGeneration");
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).hideZRegenerator();
      }
   }
}

