package transactions
{
   import zlabs.entity.IEntity;
   
   public class TSetRaffleHintSeen extends TWorldState
   {
      
      public function TSetRaffleHintSeen(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("seen");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

