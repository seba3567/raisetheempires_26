package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CommandoManager;
   import entity.GameDataComponent;
   
   public class CommandoSimpleClickState extends SimpleClickState
   {
      
      public function CommandoSimpleClickState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function clicked() : void
      {
         super.clicked();
         var _loc1_:GameDataComponent = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
         CommandoManager.instance.init(_loc1_,owner);
      }
   }
}

