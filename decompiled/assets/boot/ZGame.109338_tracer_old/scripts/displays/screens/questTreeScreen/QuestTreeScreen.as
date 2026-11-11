package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.GameItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.player.questTrees.QuestTree;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.MOTDCountdownClock;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class QuestTreeScreen extends ZGamePopUp
   {
      
      protected var m_questTree:QuestTree = null;
      
      protected var m_nodes:Array = null;
      
      protected var m_loader:ImageLoader = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_clock:MOTDCountdownClock = null;
      
      protected var m_playAgainButton:ZGameButton;
      
      protected var m_progressBarContainer:MovieClip;
      
      public function QuestTreeScreen(param1:String)
      {
         this.m_questTree = ZGlobal.player.questTrees.getQuestTree(param1);
         this.m_questTree.setquestTreeDialogActive(true);
         super(ZGlobal.getAssetURL(this.m_questTree.screenUrl));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initDialog();
         addChild(m_window);
      }
      
      override protected function initDialog() : void
      {
         this.initializeUI();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         ZGameQuestManager.instance.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         ZGameQuestManager.instance.addEventListener(PlayerQuestTrees.FINAL_REWARD_PLACE,this.onFinalRewardPlace,false,0,true);
         ZGameQuestManager.instance.addEventListener(PlayerQuestTrees.FINAL_REWARD_CLOSE,this.onFinalRewardClose,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PRE_START,this.onBattleStart);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onQuestBattleStart);
         this.createTree();
         super.initDialog();
      }
      
      protected function initializeUI() : void
      {
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("QuestTrees",this.m_questTree.title),{"minScale":0.7});
         TextFieldUtil.compactTextField(this.tree.reward_tf,ZGameUtils.ZlocT("QuestTrees","Reward"));
         TextFieldUtil.compactTextField(this.screen.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         TextFieldUtil.compactTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",this.m_questTree.popup),{
            "filter":"ignore",
            "minScale":0.7
         });
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_questTree.mainReward,GameItem) as GameItem;
         if(_loc1_)
         {
            this.m_loader = ImageLoaderFactory.CreateImageLoader(_loc1_.getCachedImage("sw").url,this.tree.icon_main);
            this.m_loader.smooth = true;
            TextFieldUtil.compactTextField(this.tree.name_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         }
         this.m_clock = new MOTDCountdownClock(this.screen.clock_mc,this.m_questTree.xml,true);
         this.tree.start_tf.visible = false;
         this.tree.blue_tf.visible = false;
         this.tree.red_tf.visible = false;
         this.tree.goal1_tf.visible = false;
         this.tree.goal2_tf.visible = false;
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:Node = null;
         ZGameQuestManager.instance.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         ZGameQuestManager.instance.removeEventListener(PlayerQuestTrees.FINAL_REWARD_PLACE,this.onFinalRewardPlace);
         ZGameQuestManager.instance.removeEventListener(PlayerQuestTrees.FINAL_REWARD_CLOSE,this.onFinalRewardClose);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PRE_START,this.onBattleStart);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onQuestBattleStart);
         this.m_clock.dispose();
         this.m_clock = null;
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         if(this.m_playAgainButton)
         {
            this.m_playAgainButton.dispose();
            this.m_playAgainButton = null;
         }
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         for each(_loc1_ in this.m_nodes)
         {
            _loc1_.dispose();
         }
         this.m_nodes = null;
         this.m_questTree.setquestTreeDialogActive(false);
         super.deinitDialog();
      }
      
      protected function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      protected function get tree() : MovieClip
      {
         return m_window.screen_mc.tree_mc1;
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         close();
      }
      
      protected function getNodeNames() : Array
      {
         return ["icon0","icon1","icon2","icon3","icon4","icon5","icon6","icon7","icon8","icon9","icon10"];
      }
      
      protected function createLink(param1:String, param2:MovieClip) : Dictionary
      {
         var _loc3_:Dictionary = new Dictionary();
         _loc3_[param1] = param2;
         return _loc3_;
      }
      
      protected function getLines() : Dictionary
      {
         var _loc1_:Dictionary = new Dictionary();
         _loc1_["icon0"] = null;
         _loc1_["icon1"] = this.createLink("icon0",this.tree["line1"]);
         _loc1_["icon3"] = this.createLink("icon1",this.tree["line3"]);
         _loc1_["icon4"] = this.createLink("icon1",this.tree["line4"]);
         _loc1_["icon6"] = this.createLink("icon3",this.tree["line6_3"]);
         _loc1_["icon6"]["icon4"] = this.tree["line6_4"];
         _loc1_["icon9"] = this.createLink("icon6",this.tree["line9"]);
         _loc1_["icon2"] = this.createLink("icon0",this.tree["line2"]);
         _loc1_["icon5"] = this.createLink("icon2",this.tree["line5"]);
         _loc1_["icon7"] = this.createLink("icon5",this.tree["line7"]);
         _loc1_["icon8"] = this.createLink("icon5",this.tree["line8"]);
         _loc1_["icon10"] = this.createLink("icon7",this.tree["line10_7"]);
         _loc1_["icon10"]["icon8"] = this.tree["line10_8"];
         return _loc1_;
      }
      
      protected function createTree() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Node = null;
         var _loc8_:ZGameQuest = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc1_:Dictionary = this.getLines();
         this.m_nodes = new Array();
         var _loc2_:Dictionary = new Dictionary();
         for each(_loc3_ in this.m_questTree.nodes)
         {
            _loc6_ = _loc3_.@screenId;
            _loc7_ = new Node(this.tree[_loc6_],_loc1_[_loc6_],_loc3_,this.m_questTree.id,Boolean(_loc3_.@noScale.toString()),Boolean(_loc3_.@center.toString()));
            this.m_nodes.push(_loc7_);
            if(this.tree[_loc6_] != null)
            {
               this.m_buttonSounds.addButton(this.tree[_loc6_],ButtonSound.DEFAULT);
            }
            _loc2_[_loc7_.questName] = _loc7_;
         }
         for(_loc4_ in _loc2_)
         {
            _loc8_ = QuestSettingsInit.getInstance().getItemByName(_loc4_) as ZGameQuest;
            if(_loc8_)
            {
               _loc9_ = _loc8_.sequels;
               for each(_loc10_ in _loc9_)
               {
                  if(_loc2_[_loc10_] != undefined)
                  {
                     this.addSequel(_loc2_[_loc4_],_loc2_[_loc10_]);
                  }
               }
            }
         }
         for(_loc5_ in _loc2_)
         {
            _loc2_[_loc5_].updateState();
         }
         this.updateProgress();
         this.updatePlayAgainButton();
      }
      
      protected function addSequel(param1:Node, param2:Node) : void
      {
         param1.addSequel(param2);
         param2.addParent(param1);
      }
      
      protected function onQuestBattleStart(param1:Event) : void
      {
         this.onBattleStart(null);
      }
      
      protected function onBattleStart(param1:Event) : void
      {
         close();
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = false;
         this.updateProgress();
         var _loc3_:String = param1.eventData.name;
         var _loc4_:Object = ZGlobal.player.questInitAsn;
         if(_loc3_ != null && _loc4_ != null && _loc4_[_loc3_] != undefined)
         {
            ZGlobal.player.questInitAsn[_loc3_] = ZGlobal.player.asn;
         }
         if(ZGlobal.player.questTrees.isEndQuest(_loc3_) && ZGlobal.player.questTrees.getQuestTreeNameForQuest(_loc3_) == this.m_questTree.id && ZGlobal.player.questTrees.validForRestarting(_loc3_))
         {
            this.enablePlayAgainButton(true);
         }
      }
      
      protected function updatePlayAgainButton() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:String = this.m_questTree.lastUnlockedQuest;
         if(Boolean(_loc2_ && ZGlobal.player.questTrees.isEndQuest(_loc2_)) && Boolean(ZGlobal.player.didCompleteQuest(_loc2_)) && ZGlobal.player.questTrees.validForRestarting(_loc2_))
         {
            _loc1_ = true;
         }
         this.enablePlayAgainButton(_loc1_);
      }
      
      protected function enablePlayAgainButton(param1:Boolean) : void
      {
         var _loc2_:String = null;
         this.screen.playAgain_bt.visible = param1;
         this.screen.playAgain_shadow_mc.visible = param1;
         if(param1)
         {
            if(!this.m_playAgainButton)
            {
               this.m_playAgainButton = new ZGameButton(this.screen.playAgain_bt,this.onPlayAgainClicked);
               this.m_playAgainButton.text = ZGameUtils.ZlocT("QuestTrees","PlayAgainText");
               this.m_playAgainButton.enable();
            }
            _loc2_ = ZGameUtils.ZlocT("QuestTrees","PlayAgainTooltip");
            Tooltip.subscribe(this.screen.playAgain_bt.m_overlay,_loc2_);
         }
         else
         {
            if(this.m_playAgainButton)
            {
               this.m_playAgainButton.disable();
            }
            Tooltip.unsubscribe(this.screen.playAgain_bt);
         }
      }
      
      protected function onPlayAgainClicked(param1:MouseEvent) : void
      {
         ZGlobal.player.questTrees.resetQuestTree(this.m_questTree.id);
         if(!this.m_questTree.rememberUnlocks)
         {
            ZGlobal.player.questTrees.resetUnlockedNodes(this.m_questTree.id);
         }
         if(this.m_questTree.difficultyModeEnabled && ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(this.m_questTree.id)["difficultyMode"] != undefined)
         {
            ZGlobal.player.questTrees.resetDifficultyMode(this.m_questTree.id);
         }
         this.enablePlayAgainButton(false);
         close();
         QuestTree.showScreen(this.m_questTree.id,"other");
      }
      
      protected function updateProgress() : void
      {
         var _loc1_:Number = NaN;
         if(this.numCompleted() <= this.m_questTree.steps)
         {
            if(this.m_progressBarContainer)
            {
               _loc1_ = this.numCompleted() / this.m_questTree.steps;
               this.m_progressBarContainer.loadBar_mc.width = this.m_progressBarContainer.loadBase_mc.width * _loc1_;
            }
            TextFieldUtil.compactTextField(this.screen.progress_tf,ZGameUtils.ZlocT("QuestTrees","Progress",{
               "amount":this.numCompleted(),
               "total":this.m_questTree.steps
            }));
         }
      }
      
      protected function numCompleted() : int
      {
         var _loc2_:Node = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_nodes)
         {
            if(_loc2_.isDone())
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      protected function onFinalRewardPlace(param1:WorldEvent) : void
      {
         close();
      }
      
      protected function onFinalRewardClose(param1:WorldEvent) : void
      {
      }
   }
}

