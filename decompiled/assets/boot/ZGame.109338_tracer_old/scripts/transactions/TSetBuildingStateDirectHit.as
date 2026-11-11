package transactions
{
   import zlabs.entity.IEntity;
   
   public class TSetBuildingStateDirectHit extends TWorldState
   {
      
      protected var m_params:Object;
      
      public function TSetBuildingStateDirectHit(param1:IEntity)
      {
         super(param1);
         this.m_params = new Object();
      }
      
      override public function perform() : void
      {
         signedWorldAction("setBuildingStateDirectHit",this.m_params);
      }
   }
}

