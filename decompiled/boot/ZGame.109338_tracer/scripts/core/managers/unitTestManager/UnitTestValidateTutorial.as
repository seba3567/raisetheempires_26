package core.managers.unitTestManager
{
   import core.ZGlobal;
   import flash.events.Event;
   import zlabs.debug.Logger;
   
   public class UnitTestValidateTutorial
   {
      
      private var m_rawXml:XML;
      
      private var m_data:XMLList = null;
      
      public function UnitTestValidateTutorial()
      {
         super();
         this.m_data = ZGlobal.gameSettings.getXML().tutorial2;
      }
      
      public function startTest() : void
      {
         this.validateTutorial();
      }
      
      public function validateTutorial() : void
      {
         var _loc2_:XML = null;
         var _loc1_:Boolean = false;
         for each(_loc2_ in this.m_data.step)
         {
            if(!_loc2_.@id.toString())
            {
               Logger.error(this,"validateTutorial","TUTORIAL VALIDATION ERROR: Tutorial Step found without an id field");
               _loc1_ = true;
            }
         }
         if(this.checkForDuplicateTutorialIds())
         {
            _loc1_ = true;
         }
         if(_loc1_)
         {
            Logger.error(this,"validateTutorial","TUTORIAL VALIDATION Completed with errors please check the log for more information");
         }
         else
         {
            Logger.info(this,"validateQuests","TUTORIAL VALIDATION Completed successfully no errors found");
         }
         UnitTestManager.instance.dispatchEvent(new Event(UnitTestManager.TEST_COMPLETE));
      }
      
      public function checkForDuplicateTutorialIds() : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc1_:Boolean = false;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this.m_data.step)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               if(_loc3_.@id.toString() == _loc2_[_loc4_])
               {
                  Logger.error("","","TUTORIAL VALIDATION ERROR: Step: " + _loc3_.@id.toString() + " has a duplicate entry.  All steps must have a unique id.");
                  _loc1_ = true;
               }
               _loc4_++;
            }
            if(!_loc1_)
            {
               _loc2_.push(_loc3_.@id.toString());
            }
         }
         return _loc1_;
      }
   }
}

