package transactions
{
   import zlabs.entity.IEntity;
   
   public class TLEUnitFactoryUnlockLevelGate extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TLEUnitFactoryUnlockLevelGate(param1:IEntity, param2:String)
      {
         super(param1);
         this.m_params = {};
         this.m_params.unitCode = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("unlockLevelGate",this.m_params);
      }
   }
}

