package init.PostInit
{
   import Engine.Init.InitializationAction;
   import ZQuest.Managers.QuestManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.ui.menuitem.QuestsUIItem;
   import flash.events.Event;
   
   public class DoStartQuests extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartQuests";
      
      public function DoStartQuests()
      {
         super(INIT_ID);
         addDependency(DoDisplayDialog.INIT_ID);
         addDependency(DoStartTutorial.INIT_ID);
      }
      
      override public function execute() : void
      {
         if(ZGameQuestManager(QuestManager.getInstance(ZGameQuestManager)).receivedInit)
         {
            this.start();
         }
         else
         {
            ZGameQuestManager(QuestManager.getInstance(ZGameQuestManager)).addEventListener(Event.INIT,this.onStart);
         }
      }
      
      private function onStart(param1:Event) : void
      {
         ZGameQuestManager(QuestManager.getInstance()).removeEventListener(Event.INIT,this.onStart);
         this.start();
      }
      
      private function start() : void
      {
         var _loc2_:ZGameTask = null;
         QuestsUIItem.IN_INIT = true;
         ZGameQuestManager(QuestManager.getInstance()).startQuests();
         var _loc1_:Array = ZGameQuestManager(QuestManager.getInstance()).getQuestTasks(null);
         for each(_loc2_ in _loc1_)
         {
            _loc2_.start();
         }
         QuestsUIItem.IN_INIT = false;
         ZGameQuestManager(QuestManager.getInstance()).dispatchEvent(new Event(ZGameQuestManager.QUESTS_STARTED));
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

