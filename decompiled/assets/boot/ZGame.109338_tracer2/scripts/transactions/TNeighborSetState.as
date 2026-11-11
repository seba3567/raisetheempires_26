package transactions
{
   import zlabs.entity.IEntity;
   
   public class TNeighborSetState extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TNeighborSetState(param1:IEntity, param2:String, param3:String = null)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.hostId = param2;
         this.m_params.referenceItem = param3;
      }
      
      override public function perform() : void
      {
         signedWorldAction("neighborSetState",this.m_params);
      }
   }
}

