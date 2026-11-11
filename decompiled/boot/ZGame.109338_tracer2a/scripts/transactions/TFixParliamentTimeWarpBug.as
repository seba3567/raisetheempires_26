package transactions
{
   import zlabs.entity.IEntity;
   
   public class TFixParliamentTimeWarpBug extends TWorldState
   {
      
      protected var m_params:Object;
      
      public function TFixParliamentTimeWarpBug(param1:IEntity)
      {
         super(param1);
         this.m_params = new Object();
      }
      
      override public function perform() : void
      {
         signedWorldAction("fixParliamentTimeWarpBug",this.m_params);
      }
   }
}

