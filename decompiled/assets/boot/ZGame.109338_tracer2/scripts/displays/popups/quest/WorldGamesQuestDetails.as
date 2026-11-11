package displays.popups.quest
{
   public class WorldGamesQuestDetails extends QuestDetailsPopup
   {
      
      public var m_textObj:Object = null;
      
      public function WorldGamesQuestDetails(param1:String)
      {
         super(param1);
      }
      
      public function get wtextObj() : Object
      {
         return textObj;
      }
      
      override public function onShow() : void
      {
      }
      
      public function finish() : void
      {
         deinitDialog();
      }
   }
}

