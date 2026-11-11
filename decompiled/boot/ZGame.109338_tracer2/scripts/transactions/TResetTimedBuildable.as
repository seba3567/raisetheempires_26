package transactions
{
   import zlabs.entity.IEntity;
   
   public class TResetTimedBuildable extends TWorldState
   {
      
      public function TResetTimedBuildable(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("resetTimedBuildable");
      }
   }
}

