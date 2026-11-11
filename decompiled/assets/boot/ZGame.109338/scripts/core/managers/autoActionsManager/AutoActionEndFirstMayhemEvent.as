package core.managers.autoActionsManager
{
   import Engine.Managers.TransactionManager;
   import core.managers.mayhemManager.MayhemManager;
   import flash.events.IEventDispatcher;
   import transactions.TStopMayhemEvent;
   
   public class AutoActionEndFirstMayhemEvent extends AutoAction
   {
      
      private var m_averted:Boolean;
      
      public function AutoActionEndFirstMayhemEvent(param1:IEventDispatcher = null, param2:Boolean = false)
      {
         this.m_averted = param2;
         super(param1);
      }
      
      override protected function performAction() : void
      {
         TransactionManager.addTransaction(new TStopMayhemEvent(MayhemManager.FIRST_ATTACK,this.m_averted));
         if(this.m_averted)
         {
            MayhemManager.instance.resetParliament();
         }
         startEndAction();
      }
   }
}

