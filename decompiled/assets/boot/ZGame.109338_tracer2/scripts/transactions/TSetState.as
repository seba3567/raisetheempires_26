package transactions
{
   import core.entities.components.behaviors.BehaviorStateMachine;
   import zlabs.entity.IEntity;
   
   public class TSetState extends TWorldState
   {
      
      protected var m_params:Object;
      
      private var m_machine:BehaviorStateMachine = null;
      
      public function TSetState(param1:IEntity, param2:String = null, param3:Boolean = false)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.referenceItem = param2;
         if(param3)
         {
            this.m_params.cancel = true;
         }
      }
      
      public function set stateMachine(param1:BehaviorStateMachine) : void
      {
         this.m_machine = param1;
      }
      
      public function get stateMachine() : BehaviorStateMachine
      {
         return this.m_machine;
      }
      
      public function get currReferenceItem() : String
      {
         return this.m_params.referenceItem;
      }
      
      override public function perform() : void
      {
         signedWorldAction("setState",this.m_params);
      }
   }
}

