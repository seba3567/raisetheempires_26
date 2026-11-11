package core.managers.autoActionsManager
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.states.FSMComponent;
   import core.entities.components.states.IState;
   import core.managers.visitorManager.VisitorManager;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import transactions.TSetBuildingStateGlancingBlow;
   import transactions.TWorldState;
   import zlabs.entity.IEntity;
   
   public class AutoActionSetStateGlancingBlow extends AutoAction
   {
      
      public function AutoActionSetStateGlancingBlow(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         if(!ZGlobal.isVisiting())
         {
            this.doGlancingBlow();
         }
         else
         {
            VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(!ZGlobal.isVisiting())
         {
            VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
            this.doGlancingBlow();
         }
      }
      
      private function doGlancingBlow() : void
      {
         var _loc1_:IEntity = null;
         var _loc2_:FSMComponent = null;
         var _loc3_:IState = null;
         var _loc4_:String = null;
         var _loc5_:TWorldState = null;
         var _loc6_:String = null;
         doDisableInput();
         _loc1_ = data.target;
         _loc2_ = _loc1_.lookupComponentByType(FSMComponent) as FSMComponent;
         if(!_loc2_)
         {
            _loc1_ = (data.entityGetter as Function)();
            _loc2_ = _loc1_.lookupComponentByType(FSMComponent) as FSMComponent;
         }
         if(_loc2_)
         {
            _loc3_ = _loc2_.stateMachine.getCurrentState();
            _loc4_ = _loc2_.stateMachine.getStateName(_loc3_);
            BehaviorState(_loc3_).cleanupProgressBar();
            _loc6_ = BehaviorState(_loc3_).data.@glancingBlow;
            _loc5_ = new TSetBuildingStateGlancingBlow(_loc1_);
            _loc2_.stateMachine.setCurrentState(_loc6_);
            TransactionManager.addTransaction(_loc5_);
         }
         startEndAction();
      }
   }
}

