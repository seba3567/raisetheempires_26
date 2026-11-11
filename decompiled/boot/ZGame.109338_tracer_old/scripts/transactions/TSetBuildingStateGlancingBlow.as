package transactions
{
   import zlabs.entity.IEntity;
   
   public class TSetBuildingStateGlancingBlow extends TWorldState
   {
      
      protected var m_params:Object;
      
      public function TSetBuildingStateGlancingBlow(param1:IEntity)
      {
         super(param1);
         this.m_params = new Object();
      }
      
      override public function perform() : void
      {
         signedWorldAction("setBuildingStateGlancingBlow",this.m_params);
      }
   }
}

