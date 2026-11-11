package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries037QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries037QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries037Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT037",["playerA"],param1);
      }
      
      public static function getMiniSeries037Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT037")["allies"];
      }
      
      public static function getMiniSeries037PlayerAPic() : String
      {
         return getMiniSeries037PlayerPic(0);
      }
      
      public static function getMiniSeries037PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT037",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.compactTextField(screen.reward_mc.qty_tf,"x5");
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"),{"maxLines":1});
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT029_Progress"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT037_Hint"));
      }
   }
}

