package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CapsuleHousingManager;
   
   public class CapsuleAutoState extends SimpleAutoState
   {
      
      protected var m_currentWorkers:int;
      
      protected var m_currentWorkersCap:int;
      
      public function CapsuleAutoState(param1:BehaviorStateInit)
      {
         super(param1);
         this.m_currentWorkers = this.currentWorkers;
         this.m_currentWorkersCap = this.currentWorkersCap;
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.isVisiting())
         {
            CapsuleHousingManager.visitInstance.initWorkers(this.m_currentWorkers,this.m_currentWorkersCap);
         }
         else
         {
            CapsuleHousingManager.instance.initWorkers(this.m_currentWorkers,this.m_currentWorkersCap);
         }
      }
      
      override protected function shouldShowOverlay() : Object
      {
         return {"show":false};
      }
      
      override public function sell() : void
      {
         CapsuleHousingManager.instance.sell();
         super.sell();
      }
      
      protected function get currentWorkers() : int
      {
         return m_data.@currentWorkers != undefined ? int(parseInt(m_data.@currentWorkers)) : 0;
      }
      
      protected function get currentWorkersCap() : int
      {
         return m_data.@currentWorkers != undefined ? int(parseInt(m_data.@currentWorkersCap)) : 0;
      }
   }
}

