package ZQuest.Classes
{
   import ZQuest.Managers.QuestManager;
   
   public class QuestComponentOptions
   {
      
      public var questClass:Class = Quest;
      
      public var questManager:Class = QuestManager;
      
      public var questUtility:Class = null;
      
      public var compressedXML:Boolean = false;
      
      public var preloaderData:Object = null;
      
      public function QuestComponentOptions()
      {
         super();
      }
   }
}

