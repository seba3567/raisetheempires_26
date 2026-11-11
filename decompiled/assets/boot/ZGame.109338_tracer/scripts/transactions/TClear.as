package transactions
{
   import core.managers.WorldObjectManager;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TClear extends TWorldState
   {
      
      public function TClear(param1:IEntity)
      {
         super(param1);
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_CLEARED,param1));
      }
      
      override public function perform() : void
      {
         signedWorldAction("clear");
      }
   }
}

