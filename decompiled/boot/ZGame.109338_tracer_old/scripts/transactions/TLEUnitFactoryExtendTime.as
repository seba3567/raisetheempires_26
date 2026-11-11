package transactions
{
   import zlabs.entity.IEntity;
   
   public class TLEUnitFactoryExtendTime extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TLEUnitFactoryExtendTime(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("extendTime",this.m_params);
      }
   }
}

