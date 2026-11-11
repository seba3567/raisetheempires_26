package transactions
{
   import core.managers.WorldObjectManager;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TSell extends TWorldState
   {
      
      public function TSell(param1:IEntity)
      {
         super(param1);
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_SOLD,param1));
      }
      
      override public function perform() : void
      {
         signedWorldAction("sell");
      }
   }
}

