package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.tutorialManager.TutorialManager;
   import flash.events.Event;
   
   public class DoStartTutorial extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartTutorial";
      
      protected var m_id:String;
      
      public function DoStartTutorial(param1:String)
      {
         super(INIT_ID);
         this.m_id = param1;
         addDependency(DoDisplayDialog.INIT_ID);
         if(MessageOfTheDayManager.instance.addedToActionQueue)
         {
            addDependency(DoMessageOfTheDay.INIT_ID);
         }
      }
      
      override public function execute() : void
      {
         TutorialManager.instance.initFromSettings(ZGlobal.gameSettings.getXML().tutorial);
         TutorialManager.instance.setStartingIndex(this.m_id);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

