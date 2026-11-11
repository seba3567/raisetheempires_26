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
   import displays.popups.miniSeriesFinalReward.CashMysteryCrateFinalReward;
   import displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.utils.getDefinitionByName;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries046QuestTreeScreen extends QuestTreeScreen
   {
      
      private static var dialogTypes:Array = [CashMysteryCrateFinalReward,MiniSeriesFinalReward];
      
      protected var m_loaders:Array = new Array();
      
      public function MiniSeries046QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries046FinalRewardPopup(param1:String) : ZGamePopUp
      {
         var _loc2_:String = null;
         var _loc3_:Class = null;
         if(getMainRewardType(param1) == "item")
         {
            _loc2_ = "assets/displays/miniseries/046/Miniseries046_FinalReward.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward") as Class;
         }
         else
         {
            _loc2_ = "assets/displays/miniseries/046/Miniseries046_FinalReward_mystery.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.CashMysteryCrateFinalReward") as Class;
         }
         return new _loc3_(param1,_loc2_);
      }
      
      public static function getMainRewardType(param1:String) : String
      {
         var _loc3_:ZGameQuest = null;
         var _loc4_:XML = null;
         var _loc2_:String = null;
         if(_loc2_ == null)
         {
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
            if(_loc3_)
            {
               for each(_loc4_ in _loc3_.xml.reward)
               {
                  if(_loc4_.@mainReward != undefined)
                  {
                     return _loc4_.@type;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      override protected function initializeUI() : void
      {
         var _loc5_:ImageLoader = null;
         var _loc6_:ImageLoader = null;
         var _loc9_:ImageLoader = null;
         var _loc10_:ImageLoader = null;
         m_progressBarContainer = screen.progressBar_mc;
         super.initializeUI();
         this.contentWidth = screen.bg_mc.width;
         this.contentHeight = screen.bg_mc.height;
         var _loc1_:String = this.getMainReward("QT046_reward_a");
         var _loc2_:String = this.getMainReward("QT046_reward_b");
         TextFieldUtil.compactTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hintTitle));
         TextFieldUtil.compactTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hint));
         TextFieldUtil.compactTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         TextFieldUtil.compactTextField(screen.header_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc1_,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
         _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc3_.getCachedImage("icon").url,screen.tree_mc1.rewardIcon);
         _loc5_.smooth = true;
         this.m_loaders.push(_loc5_);
         _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc4_.getCachedImage("icon").url,screen.tree_mc1.rewardIcon2);
         _loc6_.smooth = true;
         this.m_loaders.push(_loc6_);
         var _loc7_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc3_.unitClass);
         var _loc8_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc4_.unitClass);
         if(_loc7_)
         {
            _loc9_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc7_.getIconURL()),screen.tree_mc1.strength_mc.icon);
            _loc9_.smooth = true;
            this.m_loaders.push(_loc9_);
         }
         if(_loc7_)
         {
            _loc10_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc8_.getIconURL()),screen.tree_mc1.strength_mc2.icon);
            _loc10_.smooth = true;
            this.m_loaders.push(_loc10_);
         }
         TextFieldUtil.compactTextField(screen.tree_mc1.name_tf,_loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(screen.tree_mc1.strength_mc.strength_tf,_loc3_.getStrength(null,null).toString());
         TextFieldUtil.compactTextField(screen.tree_mc1.strength_mc2.strength_tf,_loc4_.getStrength(null,null).toString());
         TextFieldUtil.compactTextField(screen.tree_mc1.name_tf2,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
      }
      
      override protected function enablePlayAgainButton(param1:Boolean) : void
      {
         super.enablePlayAgainButton(false);
      }
      
      protected function getMainReward(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:XML = new XML(_loc2_.xml.reward.toXMLString());
         var _loc4_:RewardHelper = new RewardHelper(_loc3_);
         return _loc4_.modifiedReward();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         _loc1_ = null;
         super.deinitDialog();
      }
   }
}

