package transactions
{
   import zlabs.entity.IEntity;
   
   public class TSpeedup extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TSpeedup(param1:IEntity, param2:Number)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.elapsed = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("speedUp",this.m_params);
      }
   }
}

