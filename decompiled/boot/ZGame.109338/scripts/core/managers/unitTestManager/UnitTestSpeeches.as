package core.managers.unitTestManager
{
   import core.ZGlobal;
   import displays.popups.SpeechPopup;
   import flash.events.Event;
   import zlabs.managers.PopupManager;
   
   public class UnitTestSpeeches
   {
      
      private var m_speeches:Array = null;
      
      public function UnitTestSpeeches()
      {
         super();
         this.m_speeches = new Array();
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.speeches.speech.length())
         {
            this.m_speeches.push(_loc1_.speeches.speech[_loc2_].@id.toString());
            _loc2_++;
         }
      }
      
      public function startTest() : void
      {
         this.displaySpeech();
      }
      
      public function displaySpeech() : void
      {
         var _loc1_:String = null;
         if(this.m_speeches.length > 0)
         {
            _loc1_ = this.m_speeches.shift();
            PopupManager.instance.push(new SpeechPopup(_loc1_,this.onSpeechClosed));
         }
      }
      
      public function onSpeechClosed(param1:Event) : void
      {
         if(this.m_speeches.length > 0)
         {
            this.displaySpeech();
         }
         else
         {
            UnitTestManager.instance.dispatchEvent(new Event(UnitTestManager.TEST_COMPLETE));
         }
      }
   }
}

