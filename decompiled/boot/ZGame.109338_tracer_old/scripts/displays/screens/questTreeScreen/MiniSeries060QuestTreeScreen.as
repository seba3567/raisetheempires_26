package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import com.greensock.TweenLite;
   import com.greensock.easing.*;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.unitClassManager.*;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.Event;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries060QuestTreeScreen extends MiniSeries013QuestTreeScreen
   {
      
      public function MiniSeries060QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries060Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT060",["playerA","playerB"],param1);
      }
      
      public static function getMiniSeries060Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT060")["allies"];
      }
      
      public static function getMiniSeries060PlayerAPic() : String
      {
         return getMiniSeries060PlayerPic(0);
      }
      
      public static function getMiniSeries060PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT060",param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc8_:ZGameButton = null;
         var _loc9_:ImageLoader = null;
         super.initializeUI();
         screen.reward_mc.rewardIcon.visible = false;
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName("QT060_reward") as ZGameQuest;
         var _loc2_:XML = new XML(_loc1_.xml.reward.toXMLString());
         var _loc3_:RewardHelper = new RewardHelper(_loc2_);
         var _loc4_:String = _loc3_.modifiedReward();
         var _loc5_:String = "x" + String(_loc3_.modifiedRewardCount());
         TextFieldUtil.compactTextField(screen.reward_mc.qty_tf,_loc5_);
         var _loc6_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
         TextFieldUtil.compactTextField(screen.reward_mc.name_tf,_loc6_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(screen.reward_mc.strength_mc.strength_tf,_loc6_.getStrength(null,null).toString());
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"),{"maxLines":1});
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT029_Progress"));
         TextFieldUtil.compactTextField(screen.panelBottomAssets_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         if(screen.hasOwnProperty("hintTip_mc") && screen.hasOwnProperty("tooltipBtn"))
         {
            screen.hintTip_mc.visible = false;
            TextFieldUtil.compactTextField(screen.hintTip_mc.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT060_Hint"),{"minScale":1.1});
            _loc8_ = new ZGameButton(screen.tooltipBtn,this.onHintShow,1.1,false,this.onHintHide,this.onHintShow);
         }
         var _loc7_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc6_.unitClass);
         if(_loc7_)
         {
            _loc9_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc7_.getIconURL()),screen.reward_mc.strength_mc.icon);
            _loc9_.smooth = true;
            m_loaders.push(_loc9_);
         }
         TextFieldUtil.compactTextField(screen.reward_mc.tierRating_mc.tier_tf,String(_loc6_.tier));
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
      
      private function onHintShow(param1:Event) : void
      {
         screen.hintTip_mc.visible = true;
         TweenLite.to(screen.hintTip_mc,0.1,{
            "alpha":1,
            "ease":Quint.easeIn
         });
      }
      
      private function onHintHide(param1:Event) : void
      {
         TweenLite.to(screen.hintTip_mc,1,{
            "alpha":0,
            "ease":Quint.easeIn,
            "onComplete":this.hideTip
         });
      }
      
      private function hideTip() : void
      {
         screen.hintTip_mc.visible = false;
      }
   }
}

