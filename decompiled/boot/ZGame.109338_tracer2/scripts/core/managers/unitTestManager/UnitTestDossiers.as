package core.managers.unitTestManager
{
   import core.ZGlobal;
   import displays.popups.LetterPopup;
   import flash.events.Event;
   import zlabs.managers.PopupManager;
   
   public class UnitTestDossiers
   {
      
      private var m_dossiers:Array = null;
      
      public function UnitTestDossiers()
      {
         super();
         this.m_dossiers = new Array();
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.letters.letter.length())
         {
            this.m_dossiers.push(_loc1_.letters.letter[_loc2_].@id.toString());
            _loc2_++;
         }
      }
      
      public function startTest() : void
      {
         this.displayDossier();
      }
      
      public function displayDossier() : void
      {
         var _loc1_:String = null;
         if(this.m_dossiers.length > 0)
         {
            _loc1_ = this.m_dossiers.shift();
            PopupManager.instance.push(new LetterPopup(_loc1_,this.onDossierClosed));
         }
      }
      
      public function onDossierClosed(param1:Event) : void
      {
         if(this.m_dossiers.length > 0)
         {
            this.displayDossier();
         }
         else
         {
            UnitTestManager.instance.dispatchEvent(new Event(UnitTestManager.TEST_COMPLETE));
         }
      }
   }
}

