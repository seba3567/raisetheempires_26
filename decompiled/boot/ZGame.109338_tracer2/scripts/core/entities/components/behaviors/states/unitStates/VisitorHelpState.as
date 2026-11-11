package core.entities.components.behaviors.states.unitStates
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gamemode.avatar.VisitorAvatarComponent;
   import utils.ZGameTimeUtil;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   
   public class VisitorHelpState extends BehaviorState
   {
      
      private var m_avatarComponent:VisitorAvatarComponent = null;
      
      protected var m_helpDuration:Number = 1;
      
      public function VisitorHelpState(param1:BehaviorStateInit)
      {
         super(param1);
         this.m_helpDuration = ZGameTimeUtil.instance.parseTimeAsSeconds(m_data.@helpDuration,1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         Zlab.processManager.schedule(this.helpDuration * 1000,this,this.onStateEnd);
         this.m_avatarComponent = IEntity(stateMachine.propertyBag).lookupComponentByType(VisitorAvatarComponent) as VisitorAvatarComponent;
         this.m_avatarComponent.onHelpNewTarget(this.helpDuration);
      }
      
      override protected function autoNextState() : void
      {
      }
      
      private function onStateEnd() : void
      {
         if(this.m_avatarComponent.onTargetHelpStateEnded())
         {
            switchToState(m_autoNextStateIndex);
         }
         else
         {
            switchToState(stateMachine.builtState);
            this.m_avatarComponent.endHelp();
         }
      }
      
      private function get helpDuration() : Number
      {
         return this.m_helpDuration;
      }
   }
}

