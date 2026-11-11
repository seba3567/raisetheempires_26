package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries023QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries023QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries023Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT023",["playerA"],param1);
      }
      
      public static function getMiniSeries023Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT023")["allies"];
      }
      
      public static function getMiniSeries023PlayerAPic() : String
      {
         return getMiniSeries023PlayerPic(0);
      }
      
      public static function getMiniSeries023PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT023",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.hint_tf,"\n" + ZGameUtils.ZlocT("QuestTrees","QT023_Hint"));
      }
   }
}

