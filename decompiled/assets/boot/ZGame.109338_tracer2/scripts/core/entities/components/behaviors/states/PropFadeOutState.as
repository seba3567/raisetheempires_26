package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.WorldObjectManager;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class PropFadeOutState extends FadeOutState
   {
      
      public function PropFadeOutState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function onProgressComplete() : void
      {
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_CLEARED,IEntity(stateMachine.propertyBag)));
         setAlpha(0);
         autoNextState();
      }
   }
}

