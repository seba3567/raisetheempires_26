package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries025QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries025QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries025Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT025",["playerA"],param1);
      }
      
      public static function getMiniSeries025Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT025")["allies"];
      }
      
      public static function getMiniSeries025PlayerAPic() : String
      {
         return getMiniSeries025PlayerPic(0);
      }
      
      public static function getMiniSeries025PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT025",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         var _loc1_:Number = 3;
         var _loc2_:Number = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MINISERIES025_REWARDS);
         if(_loc2_ == 1 || _loc2_ == 2)
         {
            _loc1_ = 3;
         }
         else if(_loc2_ == 3)
         {
            _loc1_ = 1;
         }
         else if(_loc2_ == 4)
         {
            _loc1_ = 6;
         }
         else if(_loc2_ == 5)
         {
            _loc1_ = 10;
         }
         TextFieldUtil.processTextField(screen.reward_mc.qty_tf,"x" + _loc1_.toString());
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.hint_tf,"\n" + ZGameUtils.ZlocT("QuestTrees","QT025_Hint"));
      }
   }
}

