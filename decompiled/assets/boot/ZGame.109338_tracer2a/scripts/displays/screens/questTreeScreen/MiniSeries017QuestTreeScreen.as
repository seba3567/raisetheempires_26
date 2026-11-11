package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries017QuestTreeScreen extends DailyQuestScreen
   {
      
      public function MiniSeries017QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries017Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT017",["playerA","playerB"],param1);
      }
      
      public static function getMiniSeries017Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT017")["allies"];
      }
      
      public static function getMiniSeries017PlayerAPic() : String
      {
         return getMiniSeries017PlayerPic(0);
      }
      
      public static function getMiniSeries017PlayerBPic() : String
      {
         return getMiniSeries017PlayerPic(1);
      }
      
      public static function getMiniSeries017PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT017",param1);
      }
      
      public static function getMiniSeries017VillainPic() : String
      {
         return ZGlobal.getAssetURL("assets/game/quests/DailyQuestAssets.swf/lechomp.png");
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         TextFieldUtil.processTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         var _loc1_:String = m_questTree.xml.@rewardQuest;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(_loc1_) as ZGameQuest;
         var _loc3_:Object = _loc2_.getRewardTextObject();
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode("US64",UnitItem) as UnitItem;
         TextFieldUtil.compactTextField(screen.hint_tf,ZGameUtils.ZlocTP("QuestTrees",m_questTree.hint,{
            "theUnitName":_loc4_.getSentenceNameLocalizationObject("singular,definite"),
            "levelNum":"55",
            "unitName":_loc4_.getSentenceNameLocalizationObject()
         }));
         if(Boolean(_loc3_) && Boolean(_loc3_.rewardPairs) && _loc3_.rewardPairs.length >= 2)
         {
            TextFieldUtil.processTextField(screen.reward_mc.epAmount_tf,"+" + _loc3_.rewardPairs[1].count);
         }
         m_progressBarContainer = screen.progressBar_mc;
      }
   }
}

