package transactions
{
   import zlabs.entity.IEntity;
   
   public class TBuildingReward extends TWorldState
   {
      
      public function TBuildingReward(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("buildingReward");
      }
   }
}

