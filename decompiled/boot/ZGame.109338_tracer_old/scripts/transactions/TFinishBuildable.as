package transactions
{
   import zlabs.entity.IEntity;
   
   public class TFinishBuildable extends TWorldState
   {
      
      public function TFinishBuildable(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("finishBuildable");
      }
   }
}

