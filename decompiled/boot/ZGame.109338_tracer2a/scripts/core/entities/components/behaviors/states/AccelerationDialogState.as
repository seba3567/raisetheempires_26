package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import displays.screens.accelerationScreen.AccelerationActivationScreen;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import transactions.TFluxatronSpeedUp;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class AccelerationDialogState extends DialogState
   {
      
      public static const CONTRACT_STATE_MACHINE:String = "DefaultContractStateMachine";
      
      public static const CONTRACT_IN_PROGRESS_STATE:String = "9";
      
      public function AccelerationDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         stateMachine.propertyBag.eventDispatcher.addEventListener(AccelerationActivationScreen.ACTIVATION,this.onActivationSelected,false,0,true);
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         var _loc2_:Number = 0;
         AccelerationActivationScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.code,owner,_loc2_,false,stateMachine.currentStateName);
      }
      
      protected function onActivationSelected(param1:WorldEvent) : void
      {
         var _loc7_:Object = null;
         var _loc8_:GameDataComponent = null;
         var _loc9_:BuildingFSMComponent = null;
         var _loc10_:BehaviorStateMachine = null;
         var _loc11_:AutoDialogState = null;
         var _loc12_:Number = NaN;
         stateMachine.propertyBag.eventDispatcher.removeEventListener(AccelerationActivationScreen.ACTIVATION,this.onActivationSelected);
         clickNextState();
         var _loc2_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         var _loc3_:GameDataComponent = GameDataComponent(owner.lookupComponentByType(GameDataComponent));
         var _loc4_:Object = _loc3_.getSaveObject();
         var _loc5_:Number = 0;
         if(Boolean(_loc4_) && Boolean(_loc4_.id))
         {
            _loc5_ = Number(_loc4_.id);
         }
         var _loc6_:Dictionary = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
         for each(_loc7_ in _loc6_)
         {
            _loc8_ = GameDataComponent(_loc7_.lookupComponentByType(GameDataComponent));
            if((Boolean(_loc8_)) && Boolean(_loc8_.gameData) && _loc8_.gameData.getStateMachineName(null) == CONTRACT_STATE_MACHINE)
            {
               _loc9_ = BuildingFSMComponent(_loc7_.lookupComponentByType(BuildingFSMComponent));
               if(Boolean(_loc9_.isBuilt) && Boolean(_loc9_.stateMachine) && Boolean(BehaviorStateMachine(_loc9_.stateMachine).referenceItemName))
               {
                  _loc10_ = BehaviorStateMachine(_loc9_.stateMachine);
                  if(_loc10_.currentState is AutoDialogState && _loc10_.currentStateName == CONTRACT_IN_PROGRESS_STATE)
                  {
                     _loc11_ = AutoDialogState(_loc10_.currentState);
                     _loc12_ = BehaviorState(_loc11_).updateHelper.elapsedTime;
                     TransactionManager.addTransaction(new TFluxatronSpeedUp(IEntity(_loc10_.propertyBag),_loc12_,_loc5_));
                     _loc11_.nextState();
                  }
               }
            }
         }
      }
   }
}

