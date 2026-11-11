package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries029QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries029QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries029Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT029",["playerA"],param1);
      }
      
      public static function getMiniSeries029Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT029")["allies"];
      }
      
      public static function getMiniSeries029PlayerAPic() : String
      {
         return getMiniSeries029PlayerPic(0);
      }
      
      public static function getMiniSeries029PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT029",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.compactTextField(screen.reward_mc.qty_tf,"x5");
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"),{"maxLines":1});
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.hint_tf,"\n" + ZGameUtils.ZlocT("QuestTrees","QT029_Hint"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT029_Progress"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
      }
   }
}

