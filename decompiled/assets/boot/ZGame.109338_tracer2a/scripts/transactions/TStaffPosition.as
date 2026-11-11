package transactions
{
   import core.managers.CrewManager;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TStaffPosition extends TWorldState
   {
      
      private var m_params:Object = new Object();
      
      private var m_cost:int;
      
      public function TStaffPosition(param1:IEntity, param2:int, param3:int)
      {
         this.m_params.index = param2;
         this.m_cost = param3;
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("staffPosition",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:WorldEvent = null;
         if(param1.full)
         {
            _loc2_ = new WorldEvent(CrewManager.PURCHASED_CREW_SLOT_FULL,{
               "objid":param1.id,
               "cost":this.m_cost,
               "crew":param1.crew
            });
            CrewManager.instance.dispatchEvent(_loc2_);
         }
         super.onComplete(param1);
      }
   }
}

