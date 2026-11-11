package core.managers.autoActionsManager
{
   import Engine.Managers.TransactionManager;
   import core.managers.mayhemManager.MayhemManager;
   import flash.events.IEventDispatcher;
   import transactions.TStartMayhemEvent;
   
   public class AutoActionStartMayhemEvent extends AutoAction
   {
      
      public function AutoActionStartMayhemEvent(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         TransactionManager.addTransaction(new TStartMayhemEvent(data.eventKey,Number(data.endTime).toString()));
         MayhemManager.instance.setMayhemEvent(data.eventKey,data.endTime);
         var _loc1_:Object = {"mayhemEvents":{}};
         _loc1_.mayhemEvents[data.eventKey] = {"endTime":data.endTime};
         MayhemManager.instance.init(_loc1_);
         startEndAction();
      }
   }
}

