package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries011QuestTreeScreen extends DailyQuestScreen
   {
      
      public function MiniSeries011QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries11Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT011",["playerA","playerB"],param1);
      }
      
      public static function getMiniSeries11Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT011")["allies"];
      }
      
      public static function getMiniSeries11PlayerAPic() : String
      {
         return getMiniSeries11PlayerPic(0);
      }
      
      public static function getMiniSeries11PlayerBPic() : String
      {
         return getMiniSeries11PlayerPic(1);
      }
      
      public static function getMiniSeries11PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT011",param1);
      }
      
      public static function getMiniSeries11VillainPic() : String
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

