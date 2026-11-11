package transactions
{
   import core.managers.RaffleManager;
   import flash.events.Event;
   import zlabs.entity.IEntity;
   
   public class TRaffleDraw extends TWorldState
   {
      
      public function TRaffleDraw(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("raffleDraw");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         RaffleManager.instance.dispatchEvent(new Event(RaffleManager.ROLL));
      }
   }
}

