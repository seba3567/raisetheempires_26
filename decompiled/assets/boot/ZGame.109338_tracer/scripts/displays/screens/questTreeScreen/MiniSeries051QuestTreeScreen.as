package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.unitClassManager.*;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries051QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries051QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries051Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT051",["playerA","playerB"],param1);
      }
      
      public static function getMiniSeries051Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT051")["allies"];
      }
      
      public static function getMiniSeries051PlayerAPic() : String
      {
         return getMiniSeries051PlayerPic(0);
      }
      
      public static function getMiniSeries051PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT051",param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc7_:ImageLoader = null;
         super.initializeUI();
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName("QT051_reward") as ZGameQuest;
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
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT051_Hint"),{"minScale":1.1});
         var _loc6_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc5_.unitClass);
         if(_loc6_)
         {
            _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc6_.getIconURL()),screen.reward_mc.strength_mc.icon);
            _loc7_.smooth = true;
            m_loaders.push(_loc7_);
         }
         TextFieldUtil.compactTextField(screen.reward_mc.tierRating_mc.tier_tf,String(_loc5_.tier));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in m_loaders)
         {
            _loc1_.destroy();
         }
         _loc1_ = null;
         super.deinitDialog();
      }
   }
}

