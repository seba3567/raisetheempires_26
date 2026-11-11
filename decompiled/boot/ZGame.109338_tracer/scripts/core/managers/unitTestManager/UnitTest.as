package core.managers.unitTestManager
{
   import zlabs.debug.Logger;
   
   public class UnitTest
   {
      
      private var m_name:String = null;
      
      public function UnitTest(param1:XML, param2:String = null)
      {
         super();
         this.m_name = param1.@name.toString();
         Logger.info(this,"UnitTest","func:" + this.m_name);
         this[this.m_name]();
      }
      
      public function dispose() : void
      {
      }
      
      private function showDossiers() : void
      {
         var _loc1_:UnitTestDossiers = new UnitTestDossiers();
         _loc1_.startTest();
      }
      
      private function showSpeeches() : void
      {
         var _loc1_:UnitTestSpeeches = new UnitTestSpeeches();
         _loc1_.startTest();
      }
      
      private function validateQuests() : void
      {
         var _loc1_:UnitTestValidateQuests = new UnitTestValidateQuests();
         _loc1_.startTest();
      }
      
      private function validateTutorial() : void
      {
         var _loc1_:UnitTestValidateTutorial = new UnitTestValidateTutorial();
         _loc1_.startTest();
      }
      
      private function testPopups() : void
      {
         var _loc1_:UnitTestPopups = new UnitTestPopups();
         _loc1_.startTest();
      }
   }
}

