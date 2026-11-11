package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import utils.QuestTreeHelper;
   
   public class MiniSeries019QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries019QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries019Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT019",["playerA"],param1);
      }
      
      public static function getMiniSeries019Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT019")["allies"];
      }
      
      public static function getMiniSeries019PlayerAPic() : String
      {
         return getMiniSeries019PlayerPic(0);
      }
      
      public static function getMiniSeries019PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT019",param1);
      }
   }
}

