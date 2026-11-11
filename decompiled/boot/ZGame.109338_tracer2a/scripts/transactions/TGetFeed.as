package transactions
{
   public class TGetFeed extends TZGameTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TGetFeed(param1:Function)
      {
         super();
         this.m_callback = param1;
      }
      
      override public function perform() : void
      {
         signedCall("FeedService.getFeed");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         this.m_callback(param1);
      }
   }
}

