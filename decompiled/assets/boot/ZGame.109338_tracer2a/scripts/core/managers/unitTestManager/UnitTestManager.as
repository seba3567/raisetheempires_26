package core.managers.unitTestManager
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class UnitTestManager extends EventDispatcher
   {
      
      public static var instance:UnitTestManager = new UnitTestManager();
      
      public static var START_UNIT_TESTS:String = "startUnitTests";
      
      public static var TEST_COMPLETE:String = "testComplete";
      
      public static var ALL_TESTS_COMPLETE:String = "testsComplete";
      
      private var m_data:XMLList = null;
      
      private var m_index:int = 0;
      
      private var m_singleTestMode:Boolean = false;
      
      public function UnitTestManager()
      {
         super();
         addEventListener(START_UNIT_TESTS,this.onStartUnitTests,false,0,true);
         addEventListener(TEST_COMPLETE,this.onTestComplete,false,0,true);
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_data = param1;
      }
      
      public function dispose() : void
      {
         this.m_index = 0;
         this.m_data = null;
         this.m_singleTestMode = false;
         removeEventListener(TEST_COMPLETE,this.onTestComplete);
         removeEventListener(START_UNIT_TESTS,this.onStartUnitTests);
      }
      
      private function onStartUnitTests(param1:WorldEvent) : void
      {
         var _loc2_:XML = null;
         if(param1.eventData as String == "all")
         {
            this.runAllTests();
         }
         for each(_loc2_ in this.m_data.unitTest)
         {
            if(_loc2_.@id.toString() == param1.eventData)
            {
               this.runTest(param1.eventData as String);
            }
         }
      }
      
      private function runAllTests() : void
      {
         this.setupNextTest();
      }
      
      private function runTest(param1:String) : void
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         this.m_singleTestMode = true;
         for each(_loc2_ in this.m_data.unitTest)
         {
            if(_loc2_.@id.toString() == param1)
            {
               for each(_loc3_ in _loc2_.func)
               {
                  new UnitTest(_loc3_);
               }
            }
         }
      }
      
      private function setupNextTest() : void
      {
         var _loc2_:XML = null;
         var _loc1_:XML = this.m_data.unitTest[this.m_index];
         if(_loc1_)
         {
            for each(_loc2_ in _loc1_.func)
            {
               new UnitTest(_loc2_);
            }
         }
         else
         {
            this.onTestComplete(null);
         }
      }
      
      private function onTestComplete(param1:Event) : void
      {
         ++this.m_index;
         if(this.m_singleTestMode || this.m_index >= this.m_data.unitTest.length())
         {
            dispatchEvent(new Event(ALL_TESTS_COMPLETE));
            this.m_index = 0;
            this.m_singleTestMode = false;
         }
         else
         {
            this.setupNextTest();
         }
      }
   }
}

