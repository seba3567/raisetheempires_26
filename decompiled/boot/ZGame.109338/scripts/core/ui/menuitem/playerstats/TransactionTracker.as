package core.ui.menuitem.playerstats
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class TransactionTracker extends EventDispatcher
   {
      
      private var m_transactionCount:int = 0;
      
      public function TransactionTracker()
      {
         super();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionCompleted);
      }
      
      private function onTransactionAdded(param1:TransactionEvent) : void
      {
         ++this.m_transactionCount;
         Logger.info(this,getQualifiedClassName(param1.transaction),"Transaction added, Count: " + this.m_transactionCount);
         this.updated();
      }
      
      private function onTransactionCompleted(param1:TransactionEvent) : void
      {
         --this.m_transactionCount;
         Logger.info(this,getQualifiedClassName(param1.transaction),"Transaction completed, Count: " + this.m_transactionCount);
         if(this.m_transactionCount < 0)
         {
            Logger.error(this,"onTransactionCompleted","m_transactionCount gone negative (" + this.m_transactionCount + "), we\'ve completed more than we\'ve sent!");
         }
         else if(this.m_transactionCount > 50)
         {
            Logger.error(this,"onTransactionCompleted","m_transactionCount gone high (" + this.m_transactionCount + ")");
         }
         this.updated();
      }
      
      private function updated() : void
      {
         dispatchEvent(new WorldEvent(Event.RESIZE,this.m_transactionCount));
      }
   }
}

