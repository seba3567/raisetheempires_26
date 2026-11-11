package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries021QuestTreeScreen extends DailyQuestScreen
   {
      
      public function MiniSeries021QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries21Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT021",["playerA","playerB"],param1);
      }
      
      public static function getMiniSeries21Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT021")["allies"];
      }
      
      public static function getMiniSeries21PlayerAPic() : String
      {
         return getMiniSeries21PlayerPic(0);
      }
      
      public static function getMiniSeries21PlayerBPic() : String
      {
         return getMiniSeries21PlayerPic(1);
      }
      
      public static function getMiniSeries21PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT021",param1);
      }
      
      public static function getMiniSeries21VillainPic() : String
      {
         return ZGlobal.getAssetURL("assets/game/quests/DailyQuestAssets.swf/dealio_50.png");
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.processTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         var _loc1_:String = m_questTree.xml.@rewardQuest;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(_loc1_) as ZGameQuest;
         var _loc3_:Object = _loc2_.getRewardTextObject();
         if(Boolean(_loc3_) && Boolean(_loc3_.rewardPairs) && _loc3_.rewardPairs.length >= 2)
         {
            TextFieldUtil.processTextField(screen.reward_mc.epAmount_tf,"+" + _loc3_.rewardPairs[1].count);
         }
         m_progressBarContainer = screen.progressBar_mc;
      }
   }
}

