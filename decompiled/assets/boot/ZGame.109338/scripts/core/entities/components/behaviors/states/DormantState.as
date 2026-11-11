package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gamemode.GMSell;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   
   public class DormantState extends SimpleAutoState
   {
      
      public static const SLEEP:String = "sleep";
      
      public static const AWAKE:String = "awake";
      
      public function DormantState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         Zlab.processManager.schedule(500,this,this.removeFromWorld);
         IEntity(stateMachine.propertyBag).eventDispatcher.dispatchEvent(new Event(SLEEP));
      }
      
      override public function stop() : void
      {
         super.stop();
         Zlab.processManager.removeScheduledObject(this);
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         IEntity(param1.propertyBag).eventDispatcher.dispatchEvent(new Event(AWAKE));
      }
      
      override protected function onProgress(param1:Number) : void
      {
      }
      
      override protected function onProgressComplete() : void
      {
      }
      
      private function removeFromWorld() : void
      {
         GMSell.clearObject(IEntity(stateMachine.propertyBag),true);
      }
   }
}

