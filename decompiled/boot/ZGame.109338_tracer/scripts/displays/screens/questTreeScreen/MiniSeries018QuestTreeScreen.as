package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import displays.popups.miniSeriesFinalReward.CashMysteryCrateFinalReward;
   import displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward;
   import flash.geom.Rectangle;
   import utils.QuestTreeHelper;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   
   public class MiniSeries018QuestTreeScreen extends QuestTreeScreen
   {
      
      private static var dialogTypes:Array = [CashMysteryCrateFinalReward,MiniSeriesFinalReward];
      
      public function MiniSeries018QuestTreeScreen(param1:String)
      {
         super(param1);
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
      
      public static function getMiniSeries018Tokens(param1:String = "") : Object
      {
         return QuestTreeHelper.getMiniSeriesNameTokens("QT018",["playerA"],param1);
      }
      
      public static function getMiniSeries018Allies() : Object
      {
         return ZGlobal.player.questTrees.getQuestTreeDataForQuestTree("QT018")["allies"];
      }
      
      public static function getMiniSeries018PlayerAPic() : String
      {
         return getMiniSeries018PlayerPic(0);
      }
      
      public static function getMiniSeries018PlayerPic(param1:int) : String
      {
         return QuestTreeHelper.getMiniSeriesPlayerPic("QT018",param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc1_:Rectangle = null;
         m_progressBarContainer = screen.progressBar_mc;
         super.initializeUI();
         _loc1_ = getVisibleBounds(screen.bg_mc);
         this.contentWidth = _loc1_.width;
         this.contentHeight = _loc1_.height;
         var _loc2_:Object = getMiniSeries018Tokens();
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode("UA60",UnitItem) as UnitItem;
         TextFieldUtil.processTextField(screen.tree_mc1.strength_mc.strength_tf,_loc3_.getStrength(null).toString());
         TextFieldUtil.processTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.xml.ui.mainScreen.@description.toString(),_loc2_));
         TextFieldUtil.compactTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("DailyQuests","Hint"));
         TextFieldUtil.processTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.xml.ui.mainScreen.@hint.toString()));
      }
   }
}

