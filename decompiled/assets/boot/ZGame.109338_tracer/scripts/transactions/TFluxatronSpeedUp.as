package transactions
{
   import zlabs.entity.IEntity;
   
   public class TFluxatronSpeedUp extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TFluxatronSpeedUp(param1:IEntity, param2:Number, param3:Number = 0)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.elapsed = param2;
         this.m_params.objId = param3;
      }
      
      override public function perform() : void
      {
         signedWorldAction("fluxatronSpeedUp",this.m_params);
      }
   }
}

