package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.utils.ServerTimeProgressionHelper;
   import core.gameobjects.GameItem;
   import displays.screens.accelerationScreen.AccelerationActivationScreen;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class AccelerationAutoDialogState extends AutoDialogState
   {
      
      public function AccelerationAutoDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!m_window)
         {
            stateMachine.propertyBag.eventDispatcher.addEventListener(AccelerationActivationScreen.ACTIVATION,this.onActivationSelected,false,0,true);
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ServerTimeProgressionHelper(m_updateHelper).remainingDuration;
            _loc3_ = GlobalEngine.serverTime + ZGlobal.player.timeWarpSeconds / 1000;
            _loc4_ = _loc2_ + _loc3_;
            AccelerationActivationScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.code,owner,_loc4_,true,stateMachine.currentStateName);
         }
      }
      
      protected function onActivationSelected(param1:WorldEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(AccelerationActivationScreen.ACTIVATION,this.onActivationSelected);
         clickNextState();
      }
   }
}

