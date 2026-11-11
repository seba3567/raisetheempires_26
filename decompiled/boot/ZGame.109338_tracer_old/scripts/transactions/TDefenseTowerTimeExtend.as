package transactions
{
   import zlabs.entity.IEntity;
   
   public class TDefenseTowerTimeExtend extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TDefenseTowerTimeExtend(param1:IEntity, param2:Boolean)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.buy = param2 ? 1 : 0;
      }
      
      override public function perform() : void
      {
         signedWorldAction("defenseTimeExtend",this.m_params);
      }
   }
}

