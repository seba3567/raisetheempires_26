package transactions
{
   import displays.screens.neighborScreen.INeighborsReceiver;
   import zlabs.debug.Logger;
   
   public class TNeighborSuggestions extends TGameTransaction
   {
      
      private var m_receiver:INeighborsReceiver = null;
      
      public function TNeighborSuggestions(param1:INeighborsReceiver)
      {
         super();
         this.m_receiver = param1;
      }
      
      override public function perform() : void
      {
         super.perform();
         Logger.info(this,"perform","Getting suggested neighbors");
         signedCall("DataServicesService.getSuggestedNeighbors");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         this.m_receiver.suggestedNeighbors = param1 as Array;
      }
   }
}

