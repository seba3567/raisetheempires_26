package init
{
   import Engine.Events.TransactionEvent;
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.PreCacheManager;
   import flash.events.Event;
   import transactions.TInitUser;
   import zlabs.debug.Logger;
   
   public class TransactionsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "TransactionsInit";
      
      private var m_skipSocial:Boolean;
      
      public function TransactionsInit(param1:Boolean = false, param2:Boolean = false)
      {
         super(INIT_ID);
         this.m_skipSocial = param1;
         if(!param2)
         {
            addDependency(GameSettingsInit.INIT_ID);
            addDependency(LocalizationInit.INIT_ID);
         }
         else
         {
            addDependency(PreloaderInit.INIT_ID);
         }
         addDependency(SocialNetworkInit.INIT_ID);
         addDependency(GlobalsInit.INIT_ID);
         addDependency(FontMapperInit.INIT_ID);
         addDependency(UIInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var _loc1_:CompleteMonitor = null;
         var _loc2_:TInitUser = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         TransactionManager.initialize();
         if(this.m_skipSocial)
         {
            this.onTransactionsComplete();
         }
         else if(GlobalEngine.socialNetwork)
         {
            _loc1_ = new CompleteMonitor();
            _loc2_ = new TInitUser(GlobalEngine.socialNetwork.getLoggedInUser().firstName);
            _loc1_.addDispatcher(_loc2_);
            _loc1_.addEventListener(Event.COMPLETE,this.onTransactionsComplete);
            if(Boolean(ZGlobal.initUserData) && ZGlobal.initUserData != "0")
            {
               _loc3_ = ZGlobal.initUserData.data;
               ZGlobal.initUserData = null;
               if(_loc3_ != null)
               {
                  Logger.info(this,"execute","Not null");
                  if(_loc3_.length)
                  {
                     Logger.info(this,"execute","has length");
                     _loc4_ = _loc3_[0];
                     if(_loc4_.errorType == Transaction.NO_ERROR)
                     {
                        Logger.info(this,"execute","No error");
                        TransactionManager.setInitialized();
                        TransactionManager.getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.ADDED,_loc2_));
                        _loc2_.amfComplete(_loc4_);
                        TransactionManager.getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED,_loc2_));
                        return;
                     }
                  }
               }
            }
            TransactionManager.addTransaction(_loc2_,true);
         }
      }
      
      protected function onTransactionsComplete(param1:Event = null) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         new PreCacheManager();
      }
   }
}

