package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import displays.ImageLoaderFactory;
   import displays.popups.MOTDCountdownClock;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class DailyQuestScreen extends QuestTreeScreen
   {
      
      private static var DEFAULT_ITEM_FONTSIZE:Number = 18;
      
      public function DailyQuestScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         contentWidth = screen.bg_mc.width;
         contentHeight = screen.bg_mc.height;
         var _loc1_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_questTree.mainReward,UnitItem) as UnitItem;
         m_loader = ImageLoaderFactory.CreateImageLoader(_loc1_.getCachedImage("sw").url,screen.reward_mc.icon_mc.icon);
         m_loader.smooth = true;
         var _loc2_:Object = ZGameUtils.callFunctionFromXml(m_questTree.textReplacements);
         TextFieldUtil.compactTextField(screen.title_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.title));
         TextFieldUtil.compactTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.popup,_loc2_));
         TextFieldUtil.compactTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hintTitle));
         TextFieldUtil.compactTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hint),{
            "maxLines":2,
            "minScale":0.7,
            "fontSize":DEFAULT_ITEM_FONTSIZE
         });
         TextFieldUtil.compactTextField(screen.reward_tf,ZGameUtils.ZlocT("Dialogs",m_questTree.rewardTitle));
         TextFieldUtil.compactTextField(screen.reward_mc.strength_mc.strength_tf,_loc1_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc1_.code)).toString());
         TextFieldUtil.compactTextField(screen.reward_mc.complete_tf,ZGameUtils.ZlocT("DailyQuests","CompleteMessage",{"num":m_questTree.steps}));
         TextFieldUtil.compactTextField(screen.reward_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(screen.reward_mc.name_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         m_clock = new MOTDCountdownClock(screen.reward_mc.clock_mc,m_questTree.xml,true);
      }
      
      override protected function createTree() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Node = null;
         m_nodes = new Array();
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:* = 1;
         for each(_loc3_ in m_questTree.nodes)
         {
            _loc5_ = _loc3_.@screenId;
            if(_loc5_)
            {
               _loc6_ = new DailyQuestNode(screen[_loc5_],null,_loc3_,m_questTree.id,_loc2_++);
               m_nodes.push(_loc6_);
               m_buttonSounds.addButton(screen[_loc5_],ButtonSound.DEFAULT);
               _loc1_[_loc6_.questName] = _loc6_;
            }
         }
         for(_loc4_ in _loc1_)
         {
            _loc1_[_loc4_].updateState();
         }
         updateProgress();
         this.updatePlayAgainButton();
      }
      
      override protected function onQuestComplete(param1:WorldEvent) : void
      {
         updateProgress();
         this.updatePlayAgainButton();
      }
      
      override protected function updatePlayAgainButton() : void
      {
         var _loc1_:Boolean = false;
         if(numCompleted() == m_nodes.length)
         {
            _loc1_ = true;
         }
         enablePlayAgainButton(_loc1_);
      }
   }
}

