package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.MOTDCountdownClock;
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class DailyRevealScreen extends QuestTreeScreen
   {
      
      protected var m_loaders:Array = new Array();
      
      protected var m_numLoadedImages:int = 0;
      
      public function DailyRevealScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc1_:UnitItem = null;
         var _loc2_:ImageLoader = null;
         contentWidth = screen.bg_mc.width;
         contentHeight = screen.bg_mc.height;
         _loc1_ = ZGlobal.gameSettings.getItemByCode(m_questTree.mainReward,UnitItem) as UnitItem;
         m_loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_questTree.xml.@rewardIcon),screen.reward_mc.rewardIcon);
         m_loader.smooth = true;
         screen.reward_mc.rewardIcon.visible = false;
         screen.reward_mc.strength_mc.visible = false;
         screen.reward_mc.name_tf.visible = false;
         _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_questTree.xml.@advisor),screen.panelCharacter);
         _loc2_.smooth = true;
         this.m_loaders.push(_loc2_);
         TextFieldUtil.processTextField(screen.title_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.title));
         TextFieldUtil.processTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.desc));
         TextFieldUtil.processTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"));
         TextFieldUtil.processTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT04_Hint"));
         TextFieldUtil.processTextField(screen.reward_mc.strength_mc.strength_tf,_loc1_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc1_.code)).toString());
         TextFieldUtil.processTextField(screen.reward_mc.name_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.processTextField(screen.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         m_clock = new MOTDCountdownClock(screen.clock_mc,m_questTree.xml,true);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            m_loader.destroy();
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
      
      override protected function createTree() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Node = null;
         m_nodes = new Array();
         var _loc1_:* = 1;
         var _loc2_:Dictionary = new Dictionary();
         for each(_loc3_ in m_questTree.nodes)
         {
            _loc5_ = _loc3_.@screenId;
            _loc6_ = this.createNode(_loc3_,_loc1_++);
            m_nodes.push(_loc6_);
            if(screen[_loc5_])
            {
               m_buttonSounds.addButton(screen[_loc5_],ButtonSound.DEFAULT);
            }
            _loc2_[_loc6_.questName] = _loc6_;
         }
         for(_loc4_ in _loc2_)
         {
            _loc2_[_loc4_].updateState();
         }
         updateProgress();
         this.updatePlayAgainButton();
      }
      
      protected function createNode(param1:XML, param2:int) : Node
      {
         var _loc3_:String = param1.@screenId;
         return new DailyRevealNode(screen[_loc3_],null,param1,m_questTree.id,param2,this.onImageLoaded);
      }
      
      override protected function onQuestComplete(param1:WorldEvent) : void
      {
         updateProgress();
         this.updatePlayAgainButton();
      }
      
      override protected function updatePlayAgainButton() : void
      {
         var _loc3_:String = null;
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         screen.maxPlays_tf.visible = false;
         if(numCompleted() == m_nodes.length)
         {
            _loc3_ = m_questTree.lastUnlockedQuest;
            if(ZGlobal.player.questTrees.validForRestarting(_loc3_))
            {
               _loc1_ = true;
            }
            else
            {
               _loc2_ = true;
            }
         }
         enablePlayAgainButton(_loc1_);
         if(_loc2_)
         {
            screen.playAgain_bt.visible = false;
            screen.playAgain_shadow_mc.visible = true;
         }
      }
      
      protected function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         ++this.m_numLoadedImages;
         if(this.m_numLoadedImages == m_nodes.length - 1)
         {
            screen.reward_mc.rewardIcon.visible = true;
            screen.reward_mc.strength_mc.visible = true;
            screen.reward_mc.name_tf.visible = true;
         }
      }
   }
}

