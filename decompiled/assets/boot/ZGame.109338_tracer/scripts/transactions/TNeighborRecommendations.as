package transactions
{
   import displays.screens.neighborScreen.INeighborsReceiver;
   import zlabs.debug.Logger;
   
   public class TNeighborRecommendations extends TGameTransaction
   {
      
      private var m_receiver:INeighborsReceiver = null;
      
      public function TNeighborRecommendations(param1:INeighborsReceiver)
      {
         super();
         this.m_receiver = param1;
      }
      
      override public function perform() : void
      {
         super.perform();
         Logger.info(this,"perform","Getting recommended neighbors");
         signedCall("DataServicesService.getRecommendedNeighbors");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         this.m_receiver.recommendedNeighbors = param1 as Array;
      }
   }
}

