package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.BookmarksIncentiveManager;
   import zlabs.events.WorldEvent;
   
   public class TBookmarksIncentive extends Transaction
   {
      
      private var m_mode:uint;
      
      public function TBookmarksIncentive(param1:uint)
      {
         super();
         this.m_mode = param1;
         BookmarksIncentiveManager.instance.dispatchEvent(new WorldEvent(BookmarksIncentiveManager.SPIN_START));
      }
      
      override public function perform() : void
      {
         signedCall("UserService.bookmarksDailySpin",this.m_mode);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         BookmarksIncentiveManager.instance.dispatchEvent(new WorldEvent(BookmarksIncentiveManager.SPIN_RESULTS,param1));
      }
   }
}

