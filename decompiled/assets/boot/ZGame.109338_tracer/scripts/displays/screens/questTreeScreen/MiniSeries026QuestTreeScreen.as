package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import core.player.Player;
   import displays.popups.miniSeriesFinalReward.CashMysteryCrateFinalReward;
   import displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.utils.getDefinitionByName;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeries026QuestTreeScreen extends QuestTreeScreen
   {
      
      private static var dialogTypes:Array = [CashMysteryCrateFinalReward,MiniSeriesFinalReward];
      
      public function MiniSeries026QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeries026FinalRewardPopup(param1:String) : ZGamePopUp
      {
         var _loc2_:String = null;
         var _loc3_:Class = null;
         if(getMainRewardType(param1) == "item")
         {
            _loc2_ = "assets/displays/miniseries/026/Miniseries026_FinalReward.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward") as Class;
         }
         else
         {
            _loc2_ = "assets/displays/miniseries/026/Miniseries026_FinalReward_mystery.swf";
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
         m_progressBarContainer = screen.progressBar_mc;
         super.initializeUI();
         this.contentWidth = screen.bg_mc.width;
         this.contentHeight = screen.bg_mc.height;
         var _loc1_:Object = new Object();
         var _loc2_:Player = ZGlobal.player;
         if(_loc2_)
         {
            _loc1_.empire = _loc2_.empireName;
         }
         TextFieldUtil.compactTextField(screen.title_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.title,_loc1_),{"minScale":0.7});
         TextFieldUtil.compactTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hintTitle));
         TextFieldUtil.compactTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hint));
         TextFieldUtil.compactTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         TextFieldUtil.compactTextField(screen.header_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(screen.tree_mc1.name_tf2,ZGameUtils.ZlocT("QuestTrees","mystery_crate"));
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_questTree.xml.ui.mainScreen.@rewardGameItem.toString(),UnitItem) as UnitItem;
         TextFieldUtil.compactTextField(screen.tree_mc1.strength_mc.strength_tf,_loc3_.getStrength(null,null).toString());
         TextFieldUtil.compactTextField(screen.tree_mc1.name_tf,_loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
      }
      
      override protected function enablePlayAgainButton(param1:Boolean) : void
      {
         super.enablePlayAgainButton(false);
      }
   }
}

