package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries035QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries035QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries035Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT035",["playerA"],param1);
      }
      
      public static function getMiniSeries035Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT035")["allies"];
      }
      
      public static function getMiniSeries035PlayerAPic() : String
      {
         return getMiniSeries035PlayerPic(0);
      }
      
      public static function getMiniSeries035PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT035",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.compactTextField(screen.reward_mc.qty_tf,"x5");
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"),{"maxLines":1});
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT029_Progress"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT035_Hint"));
      }
   }
}

