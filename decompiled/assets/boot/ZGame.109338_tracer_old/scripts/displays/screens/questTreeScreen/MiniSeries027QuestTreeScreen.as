package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries027QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries027QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries027Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT027",["playerA"],param1);
      }
      
      public static function getMiniSeries027Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT027")["allies"];
      }
      
      public static function getMiniSeries027PlayerAPic() : String
      {
         return getMiniSeries027PlayerPic(0);
      }
      
      public static function getMiniSeries027PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT027",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.compactTextField(screen.reward_mc.qty_tf,"x5");
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"),{"maxLines":1});
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.hint_tf,"\n" + ZGameUtils.ZlocT("QuestTrees","QT027_Hint"));
      }
   }
}

