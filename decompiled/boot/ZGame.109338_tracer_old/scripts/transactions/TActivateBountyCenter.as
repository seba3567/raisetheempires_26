package transactions
{
   import zlabs.entity.IEntity;
   
   public class TActivateBountyCenter extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TActivateBountyCenter(param1:IEntity, param2:Boolean = false)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.skipCooling = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("activateBountyCenter",this.m_params);
      }
   }
}

