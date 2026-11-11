package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.MOTDCountdownClock;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class DoorQuestTreeScreen extends QuestTreeScreen
   {
      
      protected var m_loaders:Array = new Array();
      
      protected var m_rewardLoaders:Array = new Array();
      
      public function DoorQuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc1_:ImageLoader = null;
         contentWidth = screen.bg_mc.width;
         contentHeight = screen.bg_mc.height;
         if(m_questTree.character)
         {
            _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_questTree.character),screen.panelCharacter);
            _loc1_.smooth = true;
            this.m_loaders.push(_loc1_);
         }
         TextFieldUtil.processTextField(screen.title_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.title));
         TextFieldUtil.processTextField(screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.popup));
         TextFieldUtil.compactTextField(screen.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"),{"minScale":0.7});
         TextFieldUtil.processTextField(screen.hint_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.hint));
         TextFieldUtil.processTextField(screen.rewards_mc.rewardsInfo_mc.rewardHeader_tf,ZGameUtils.ZlocT("QuestTrees","QT06_ChanceToWinHeader"));
         TextFieldUtil.processTextField(screen.time1_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         m_clock = new MOTDCountdownClock(screen.clock_mc,m_questTree.xml,true);
         screen.rewards_mc.rewardsInfo_mc.visible = false;
      }
      
      override protected function get tree() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      override protected function createTree() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:DoorQuestNode = null;
         m_nodes = new Array();
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:* = 1;
         for each(_loc3_ in m_questTree.nodes)
         {
            _loc5_ = _loc3_.@screenId;
            _loc6_ = new DoorQuestNode(screen[_loc5_],null,_loc3_,m_questTree.id,_loc2_++);
            m_nodes.push(_loc6_);
            if(screen[_loc5_] != null)
            {
               screen[_loc5_]["rewards"] = _loc3_.@reward;
               screen[_loc5_].addEventListener(MouseEvent.ROLL_OVER,this.onRollOverNode,false,0,true);
               screen[_loc5_].addEventListener(MouseEvent.ROLL_OUT,this.onRollOutNode,false,0,true);
               m_buttonSounds.addButton(this.tree[_loc5_],ButtonSound.DEFAULT);
            }
            _loc1_[_loc6_.questName] = _loc6_;
         }
         for(_loc4_ in _loc1_)
         {
            _loc1_[_loc4_].updateState();
         }
         updateProgress();
         screen.playAgain_bt.visible = false;
         screen.playAgain_shadow_mc.visible = false;
         screen.maxPlays_tf.visible = false;
      }
      
      private function onRollOverNode(param1:MouseEvent) : void
      {
         var rewards:String;
         var mysteryCrateRewards:XMLList = null;
         var cards:Array = null;
         var index:int = 0;
         var item:XML = null;
         var gameItem:GameItem = null;
         var loader:ImageLoader = null;
         var unitItem:UnitItem = null;
         var event:MouseEvent = param1;
         screen.rewards_mc.rewardsInfo_mc.visible = true;
         rewards = event.currentTarget["rewards"];
         if(rewards)
         {
            mysteryCrateRewards = ZGlobal.gameSettings.getXML().mysteryCrates.mysteryCrate.(@name == rewards);
            if(mysteryCrateRewards)
            {
               cards = [screen.rewards_mc.rewardsInfo_mc.mainRewardCard01_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard02_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard03_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard04_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard05_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard06_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard07_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard08_mc,screen.rewards_mc.rewardsInfo_mc.mainRewardCard09_mc];
               index = 0;
               for each(item in mysteryCrateRewards.reward)
               {
                  if(!cards[index])
                  {
                     break;
                  }
                  gameItem = ZGlobal.gameSettings.getItemByCode(item.@item,GameItem) as GameItem;
                  if(gameItem.isUnit())
                  {
                     unitItem = ZGlobal.gameSettings.getItemByCode(item.@item,UnitItem) as UnitItem;
                     TextFieldUtil.processTextField(cards[index]["strength_mc"]["value_tf"],unitItem.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(unitItem.code)).toString());
                     cards[index]["strength_mc"].visible = true;
                  }
                  else
                  {
                     cards[index]["strength_mc"].visible = false;
                  }
                  TextFieldUtil.processTextField(cards[index]["value_tf"],"x" + item.@count);
                  loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(gameItem.name,"icon"),cards[index]["icon01"]);
                  loader.smooth = true;
                  this.m_rewardLoaders.push(loader);
                  index++;
               }
            }
         }
      }
      
      private function onRollOutNode(param1:MouseEvent) : void
      {
         var _loc2_:ImageLoader = null;
         screen.rewards_mc.rewardsInfo_mc.visible = false;
         for each(_loc2_ in this.m_rewardLoaders)
         {
            _loc2_.destroy();
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:XML = null;
         var _loc2_:ImageLoader = null;
         var _loc3_:String = null;
         for each(_loc1_ in m_questTree.nodes)
         {
            _loc3_ = _loc1_.@screenId;
            if(screen[_loc3_] != null)
            {
               screen[_loc3_].removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverNode);
               screen[_loc3_].removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutNode);
            }
         }
         for each(_loc2_ in this.m_loaders)
         {
            _loc2_.destroy();
         }
         super.deinitDialog();
      }
      
      override protected function onFinalRewardClose(param1:WorldEvent) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < m_nodes.length)
         {
            m_nodes[_loc2_].updateState();
            _loc2_++;
         }
      }
      
      override protected function onQuestComplete(param1:WorldEvent) : void
      {
      }
   }
}

