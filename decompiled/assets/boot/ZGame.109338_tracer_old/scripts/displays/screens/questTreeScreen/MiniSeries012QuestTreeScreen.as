package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.DecorationItem;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.questManager.ZGameQuest;
   import flash.geom.Rectangle;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   
   public class MiniSeries012QuestTreeScreen extends QuestTreeScreen
   {
      
      public function MiniSeries012QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc1_:Rectangle = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:XML = null;
         super.initializeUI();
         _loc1_ = getVisibleBounds(screen.background_mc);
         this.contentWidth = _loc1_.width;
         this.contentHeight = _loc1_.height + 50;
         m_progressBarContainer = screen.progressBar_mc;
         TextFieldUtil.processTextField(screen.header_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.processTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName("QT012a_reward") as ZGameQuest;
         var _loc3_:String = _loc2_.xml.reward.@count;
         TextFieldUtil.processTextField(screen.tree_mc1.name_tf2,ZGameUtils.ZlocT("Main","GenericItemAmount",{
            "amount":_loc3_,
            "item":ZGameUtils.ZlocT("Main","Cash")
         }));
         TextFieldUtil.processTextField(screen.tree_mc1.name_tf,ZGameUtils.ZlocT("Items","Crystal_Palace_menuName"));
         var _loc8_:int = int(m_questTree.xml.@maxPlays);
         var _loc9_:DecorationItem = ZGlobal.gameSettings.getItemByCode("BB14",DecorationItem) as DecorationItem;
         for each(_loc10_ in _loc9_.effectsXML)
         {
            if(_loc10_.@effect == "maturationYield")
            {
               _loc4_ = DecorationsManager.instance.getEffectVariantAmount(_loc10_.@amountNormal.toString(),_loc10_.@effect.toString());
               _loc5_ = DecorationsManager.instance.getEffectVariantAmount(_loc10_.@amountCrewed.toString(),_loc10_.@effect.toString());
            }
            else if(_loc10_.@effect == "crewTendBuff")
            {
               _loc6_ = DecorationsManager.instance.getEffectVariantAmount(_loc10_.@amountNormal.toString(),_loc10_.@effect.toString());
               _loc7_ = DecorationsManager.instance.getEffectVariantAmount(_loc10_.@amountCrewed.toString(),_loc10_.@effect.toString());
            }
         }
         TextFieldUtil.processTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"));
         TextFieldUtil.processTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.xml.ui.mainScreen.@hint,{
            "crewableDeco":ZGameUtils.ZlocT("Items","Crystal_Palace_menuName"),
            "decoBonusNum":_loc4_,
            "crewedDecoBonusNum":_loc5_,
            "staffBonusNum":_loc6_,
            "crewedStaffBonusNum":_loc7_,
            "timesAmount":_loc8_
         }));
         TextFieldUtil.processTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.xml.ui.mainScreen.@description));
      }
   }
}

