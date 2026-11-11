package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   
   public class MiniSeries020QuestTreeScreen extends QuestTreeScreen
   {
      
      public function MiniSeries020QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getMiniSeriesFinalRewardPopup(param1:String) : ZGamePopUp
      {
         var _loc2_:String = null;
         var _loc3_:Class = null;
         if(isMysteryRewardQuest(param1))
         {
            _loc2_ = "assets/displays/miniseries/020/Miniseries020_FinalReward_mystery.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.CashMysteryCrateFinalReward") as Class;
         }
         else
         {
            _loc2_ = "assets/displays/miniseries/020/Miniseries020_FinalReward.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward") as Class;
         }
         return new _loc3_(param1,_loc2_);
      }
      
      public static function isMysteryRewardQuest(param1:String) : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:GameItem = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_.xml.reward)
            {
               if(_loc3_.@type != undefined && _loc3_.@type == "item")
               {
                  _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.@item,GameItem) as GameItem;
                  if(_loc4_.type == GameItem.TYPE_CONSUMABLE)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      override protected function initDialog() : void
      {
         var _loc1_:Node = null;
         var _loc2_:ZGameQuest = null;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:UnitItem = null;
         super.initDialog();
         for each(_loc1_ in m_nodes)
         {
            if(_loc1_.questName == "QT020_reward_a")
            {
               _loc2_ = QuestSettingsInit.getInstance().getItemByName(_loc1_.questName) as ZGameQuest;
               if(_loc2_)
               {
                  for each(_loc3_ in _loc2_.xml.reward)
                  {
                     if(_loc3_.@type != undefined && _loc3_.@type == "item")
                     {
                        _loc4_ = _loc3_.@item;
                        if(_loc4_ != null && _loc4_ != "")
                        {
                           _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
                           if(_loc5_)
                           {
                              TextFieldUtil.compactTextField(screen.tree_mc1.strength_mc.strength_tf,_loc5_.getStrength(null,null).toString());
                              TextFieldUtil.compactTextField(screen.tree_mc1.name_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
                           }
                        }
                        break;
                     }
                  }
               }
               break;
            }
         }
      }
      
      override protected function initializeUI() : void
      {
         var _loc1_:Rectangle = null;
         super.initializeUI();
         _loc1_ = getVisibleBounds(screen.bg_mc);
         this.contentWidth = _loc1_.width;
         this.contentHeight = _loc1_.height + 15;
         m_progressBarContainer = screen.progressBar_mc;
         TextFieldUtil.compactTextField(screen.header_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         TextFieldUtil.compactTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"));
         TextFieldUtil.compactTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.xml.ui.mainScreen.@hint,{"num":m_questTree.xml.ui.mainScreen.@maxNukeRewardsText}));
         if(Boolean(screen.tree_mc1.nuke1.number_tf) && m_questTree.xml.ui.mainScreen.@nukeRewardCount1 != undefined)
         {
            TextFieldUtil.compactTextField(screen.tree_mc1.nuke1.number_tf,m_questTree.xml.ui.mainScreen.@nukeRewardCount1);
         }
         if(Boolean(screen.tree_mc1.nuke2.number_tf) && m_questTree.xml.ui.mainScreen.@nukeRewardCount2 != undefined)
         {
            TextFieldUtil.compactTextField(screen.tree_mc1.nuke2.number_tf,m_questTree.xml.ui.mainScreen.@nukeRewardCount2);
         }
         if(Boolean(screen.tree_mc1.nuke3.number_tf) && m_questTree.xml.ui.mainScreen.@nukeRewardCount3 != undefined)
         {
            TextFieldUtil.compactTextField(screen.tree_mc1.nuke3.number_tf,m_questTree.xml.ui.mainScreen.@nukeRewardCount3);
         }
         TextFieldUtil.compactTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.xml.ui.mainScreen.@description));
         this.y = 300;
      }
      
      override protected function enablePlayAgainButton(param1:Boolean) : void
      {
         super.enablePlayAgainButton(false);
      }
   }
}

