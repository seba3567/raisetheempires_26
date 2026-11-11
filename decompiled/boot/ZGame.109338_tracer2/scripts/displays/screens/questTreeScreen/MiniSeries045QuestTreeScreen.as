package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries045QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries045QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries045Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT045",["playerA"],param1);
      }
      
      public static function getMiniSeries045Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT045")["allies"];
      }
      
      public static function getMiniSeries045PlayerAPic() : String
      {
         return getMiniSeries045PlayerPic(0);
      }
      
      public static function getMiniSeries045PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT045",param1);
      }
      
      override protected function initializeUI() : void
      {
         super.initializeUI();
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName("QT045_reward") as ZGameQuest;
         var _loc2_:XML = new XML(_loc1_.xml.reward.toXMLString());
         var _loc3_:RewardHelper = new RewardHelper(_loc2_);
         var _loc4_:String = _loc3_.modifiedReward();
         var _loc5_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
         TextFieldUtil.compactTextField(screen.reward_mc.name_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(screen.reward_mc.strength_mc.strength_tf,_loc5_.getStrength(null,null).toString());
         TextFieldUtil.compactTextField(screen.reward_mc.qty_tf,"x5");
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"),{"maxLines":1});
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT029_Progress"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT045_Hint"));
      }
   }
}

