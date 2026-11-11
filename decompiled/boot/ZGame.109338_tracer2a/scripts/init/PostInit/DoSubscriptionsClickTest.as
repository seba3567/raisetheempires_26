package init.PostInit
{
   import Engine.Init.InitializationAction;
   import dispatchers.UIDispatcher;
   import displays.popups.subscriptions.ClickTestInit;
   import flash.events.Event;
   import zlabs.managers.PopupManager;
   
   public class DoSubscriptionsClickTest extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoSubscriptionsClickTest";
      
      public static const SUBS_CLICK_TEST_DONE:String = "subs_click_test_done";
      
      public static const CLICK_TEST_FLAG:String = "subscriptions_click_test_played";
      
      public function DoSubscriptionsClickTest()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         UIDispatcher.instance.addEventListener(SUBS_CLICK_TEST_DONE,this.onClickTestDone);
         PopupManager.instance.push(new ClickTestInit());
      }
      
      private function onClickTestDone(param1:Event) : void
      {
         UIDispatcher.instance.removeEventListener(SUBS_CLICK_TEST_DONE,this.onClickTestDone);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

