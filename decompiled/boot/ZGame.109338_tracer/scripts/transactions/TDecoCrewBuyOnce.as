package transactions
{
   import zlabs.entity.IEntity;
   
   public class TDecoCrewBuyOnce extends TWorldState
   {
      
      public function TDecoCrewBuyOnce(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("decoCrewBuyOnce");
      }
   }
}

