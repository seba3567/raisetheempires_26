package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.viralsManager.ViralsManager;
   import core.player.questTrees.QuestTree;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TBuyItem;
   import transactions.TBuyQuestRestartTask;
   import transactions.TBuyQuestTask;
   import transactions.TSpend;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class AllianceQuestPopup extends ZGamePopUp
   {
      
      private static var DEFAULT_TASK_FONT_SIZE:Number = 14;
      
      private static const NUM_CARDS_PER_PAGE:uint = 6;
      
      private static const CARD_VERTICAL_SPACING:Number = 69;
      
      private static const CARD_HORIZONTAL_OFFSET:Number = 0;
      
      private static const CARD_VERTICAL_OFFSET:Number = -3;
      
      private var m_acceptBt:ZGameButton = null;
      
      private var m_initialized:Boolean;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_taskButtons:Vector.<Object> = null;
      
      private var m_buyAllButton:ZGameButton = null;
      
      private var m_restartButton:ZGameButton = null;
      
      private var m_buyPopup:GenericPopup;
      
      private var m_id:String = null;
      
      private var m_textObj:Object = null;
      
      private var m_rewardsTextObj:Object = null;
      
      private var m_clock:MOTDCountdownClock = null;
      
      private var m_backButton:ZGameButton;
      
      private var m_questCardClass:Class = null;
      
      private var m_questCards:Vector.<Object> = new Vector.<Object>();
      
      private var m_firstIndex:uint = 0;
      
      private var m_loaders:Vector.<Object> = null;
      
      private var m_ensureVisible:Boolean = false;
      
      private const CARD_LOADERS:uint = 0;
      
      private const TASK_LOADERS:uint = 1;
      
      private const REWARD_LOADERS:uint = 2;
      
      private var m_questIconLoader:ImageLoader;
      
      public function AllianceQuestPopup(param1:String, param2:Boolean = false)
      {
         this.m_id = param1;
         this.m_ensureVisible = param2;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_AllianceQuestManager.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip as MovieClip;
         param1.destroy();
         this.m_questCardClass = param1.getAssetClass("QuestCard");
         this.setUpQuestUI();
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_loaders = new Vector.<Object>();
         this.m_loaders[this.CARD_LOADERS] = new Object();
         this.m_loaders[this.TASK_LOADERS] = new Object();
         this.m_loaders[this.REWARD_LOADERS] = new Object();
         var _loc1_:MovieClip = this.screen;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         _loc1_.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.m_buttonSounds.addButton(_loc1_.exit_bt,ButtonSound.DEFAULT);
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         _loc2_.addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
         _loc2_.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","QuestManagerTitle"));
         TextFieldUtil.processTextField(this.screen.rewards_tf,ZGameUtils.ZlocT("Dialogs","QuestRewards"));
         this.m_buyAllButton = new ZGameButton(this.screen.skip_btn,null);
         this.m_backButton = new ZGameButton(this.screen.back_bt,this.onBack);
         this.m_backButton.text = ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_Back");
         this.m_backButton.enable();
         if(this.screen.icon)
         {
            this.m_questIconLoader = ImageLoaderFactory.CreateImageLoader(_loc2_.getButtonIconPath(this.m_id),this.screen.icon);
         }
         if(this.screen.hint_tf)
         {
            TextFieldUtil.compactTextField(this.screen.hint_tf,ZGameUtils.ZlocT("Dialogs","Alliance_quest_Footer"));
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         super.deinitDialog();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         var _loc1_:MovieClip = this.screen;
         this.stopDateTimer();
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         _loc2_.removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress);
         _loc2_.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         for each(_loc3_ in this.m_taskButtons)
         {
            if(Boolean(_loc3_) && _loc3_.button != null)
            {
               _loc3_.button.dispose();
            }
         }
         this.m_taskButtons = null;
         if(this.m_buyAllButton != null)
         {
            this.m_buyAllButton.dispose();
         }
         this.m_buyAllButton = null;
         if(this.m_backButton != null)
         {
            this.m_backButton.dispose();
            this.m_backButton = null;
         }
         if(this.m_restartButton)
         {
            this.m_restartButton.dispose();
            this.m_restartButton = null;
         }
         if(this.m_clock)
         {
            this.m_clock.dispose();
            this.m_clock = null;
         }
         for each(_loc4_ in this.m_questCards)
         {
            this.screen.anchor_mc.removeChild(_loc4_.card);
            this.disposeQuestCard(_loc4_.card);
         }
         this.destroyLoaders(this.CARD_LOADERS);
         this.destroyLoaders(this.TASK_LOADERS);
         this.destroyLoaders(this.REWARD_LOADERS);
         this.m_loaders = null;
         if(this.m_questIconLoader)
         {
            this.m_questIconLoader.destroy();
            this.m_questIconLoader = null;
         }
      }
      
      private function destroyLoaders(param1:uint) : void
      {
         var _loc3_:ImageLoader = null;
         if(this.m_loaders == null)
         {
            return;
         }
         var _loc2_:Object = this.m_loaders[param1];
         for each(_loc3_ in _loc2_)
         {
            _loc3_.destroy();
         }
         this.m_loaders[param1] = new Object();
      }
      
      public function get currentQuestId() : String
      {
         return this.m_id;
      }
      
      public function set currentQuestId(param1:String) : void
      {
         this.m_id = param1;
      }
      
      protected function get screen() : MovieClip
      {
         return window.getChildAt(0) as MovieClip;
      }
      
      protected function get textObj() : Object
      {
         return this.m_textObj;
      }
      
      protected function set textObj(param1:Object) : void
      {
         this.m_textObj = param1;
      }
      
      protected function get rewardsTextObj() : Object
      {
         return this.m_rewardsTextObj;
      }
      
      protected function set rewardsTextObj(param1:Object) : void
      {
         this.m_rewardsTextObj = param1;
      }
      
      protected function getTextObject(param1:String) : Object
      {
         return (QuestManager.getInstance() as ZGameQuestManager).getTextObject(param1);
      }
      
      protected function getRewardsTextObject(param1:String) : Object
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         return _loc2_.getRewardTextObject();
      }
      
      private function updateQuestDisplay() : void
      {
         this.updateQuestDetailsDisplay();
         this.updateQuestRewardsDisplay();
      }
      
      private function validateSelectedQuest() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_questCards)
         {
            if(this.currentQuestId == _loc1_.id)
            {
               return;
            }
         }
         if(this.m_questCards.length > 0)
         {
            this.currentQuestId = this.m_questCards[0].id;
         }
         else
         {
            this.close();
         }
      }
      
      private function setSelectedQuest(param1:String) : void
      {
         var _loc2_:MovieClip = this.getCardForId(this.currentQuestId);
         _loc2_.highlightSelect.visible = false;
         var _loc3_:String = this.currentQuestId;
         this.currentQuestId = param1;
         this.updateQuestCardInternal(_loc3_,_loc2_);
         _loc2_ = this.getCardForId(this.currentQuestId);
         _loc2_.highlightSelect.visible = true;
         _loc2_.highlightHover.visible = false;
         this.updateQuestCardInternal(this.currentQuestId,_loc2_);
         this.updateQuestDetailsDisplay();
         this.updateQuestRewardsDisplay();
      }
      
      private function updateQuestListDisplay() : void
      {
         this.updateQuestCards();
         this.positionCards();
         this.updatePageUI();
      }
      
      private function updateQuestCards() : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Vector.<Object> = null;
         var _loc8_:int = 0;
         var _loc9_:MovieClip = null;
      }
      
      private function initQuestCard(param1:MovieClip) : void
      {
         param1.arrow_btn_up.visible = false;
         param1.arrow_btn_dn.visible = false;
         param1.highlightHover.visible = false;
         param1.highlightSelect.visible = false;
         param1.star_icon.visible = false;
         param1.timedOut_icon.visible = false;
         param1.addEventListener(MouseEvent.ROLL_OVER,this.onCardMouseOver,false,0,true);
         param1.addEventListener(MouseEvent.ROLL_OUT,this.onCardMouseOut,false,0,true);
         param1.addEventListener(MouseEvent.CLICK,this.onCardMouseClick,false,0,true);
         param1.arrow_btn_up.addEventListener(MouseEvent.CLICK,this.onCardArrowUp,false,0,true);
         param1.arrow_btn_dn.addEventListener(MouseEvent.CLICK,this.onCardArrowDown,false,0,true);
      }
      
      private function disposeQuestCard(param1:MovieClip) : void
      {
         param1.removeEventListener(MouseEvent.ROLL_OVER,this.onCardMouseOver);
         param1.removeEventListener(MouseEvent.ROLL_OUT,this.onCardMouseOut);
         param1.removeEventListener(MouseEvent.CLICK,this.onCardMouseClick);
         param1.arrow_btn_up.removeEventListener(MouseEvent.CLICK,this.onCardArrowUp);
         param1.arrow_btn_dn.removeEventListener(MouseEvent.CLICK,this.onCardArrowDown);
      }
      
      private function updateQuestCardInternal(param1:String, param2:MovieClip) : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:ZGameQuest = null;
         var _loc3_:Object = this.getTextObject(param1);
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         for each(_loc6_ in _loc3_.taskText)
         {
            if(_loc3_.taskComplete[_loc5_])
            {
               _loc4_++;
            }
            _loc5_++;
         }
         _loc7_ = String(_loc4_) + "/" + String(_loc3_.taskText.length);
         TextFieldUtil.processTextField(param2.count_tf,_loc7_);
         _loc8_ = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(_loc8_.hasDate || _loc8_.hasLifeTime)
         {
            param2.timed_icon.visible = true;
            if(param1 == this.currentQuestId)
            {
               param2.frame_default.visible = false;
               param2.frame_default_selected.visible = false;
               if(_loc8_.hasDate)
               {
                  param2.frame_limited.visible = false;
                  param2.frame_limited_selected.visible = true;
                  param2.frame_timed.visible = false;
                  param2.frame_timed_selected.visible = false;
               }
               else
               {
                  param2.frame_limited.visible = false;
                  param2.frame_limited_selected.visible = false;
                  param2.frame_timed.visible = false;
                  param2.frame_timed_selected.visible = true;
               }
            }
            else
            {
               param2.frame_default.visible = false;
               param2.frame_default_selected.visible = false;
               if(_loc8_.hasDate)
               {
                  param2.frame_limited.visible = true;
                  param2.frame_limited_selected.visible = false;
                  param2.frame_timed.visible = false;
                  param2.frame_timed_selected.visible = false;
               }
               else
               {
                  param2.frame_limited.visible = false;
                  param2.frame_limited_selected.visible = false;
                  param2.frame_timed.visible = true;
                  param2.frame_timed_selected.visible = false;
               }
            }
         }
         else if(param1 == this.currentQuestId)
         {
            param2.timed_icon.visible = false;
            param2.frame_default.visible = false;
            param2.frame_default_selected.visible = true;
            param2.frame_limited.visible = false;
            param2.frame_limited_selected.visible = false;
            param2.frame_timed.visible = false;
            param2.frame_timed_selected.visible = false;
         }
         else
         {
            param2.timed_icon.visible = false;
            param2.frame_default.visible = true;
            param2.frame_default_selected.visible = false;
            param2.frame_limited.visible = false;
            param2.frame_limited_selected.visible = false;
            param2.frame_timed.visible = false;
            param2.frame_timed_selected.visible = false;
         }
         if(this.isExpiredAndCanRestart(_loc8_))
         {
            param2.timed_icon.visible = false;
            param2.timedOut_icon.visible = true;
         }
         else
         {
            param2.timedOut_icon.visible = false;
         }
      }
      
      private function updatePageUI() : void
      {
         var _loc1_:uint = this.m_firstIndex;
         var _loc2_:uint = this.m_firstIndex + AllianceQuestPopup.NUM_CARDS_PER_PAGE;
         if(_loc1_ > 0)
         {
            this.screen.up_mc.gotoAndStop(1);
            this.screen.pageUp_mc.gotoAndStop(1);
         }
         else
         {
            this.screen.up_mc.gotoAndStop(5);
            this.screen.pageUp_mc.gotoAndStop(5);
         }
         if(_loc2_ < this.numCards)
         {
            this.screen.down_mc.gotoAndStop(1);
            this.screen.pageDown_mc.gotoAndStop(1);
         }
         else
         {
            this.screen.down_mc.gotoAndStop(5);
            this.screen.pageDown_mc.gotoAndStop(5);
         }
      }
      
      private function positionCards() : void
      {
         var _loc2_:int = 0;
         var _loc1_:uint = 0;
         while(_loc1_ < this.numCards)
         {
            if(_loc1_ >= this.firstCardIndex && _loc1_ <= this.lastCardIndex)
            {
               this.m_questCards[_loc1_].card.visible = true;
               this.m_questCards[_loc1_].card.x = AllianceQuestPopup.CARD_HORIZONTAL_OFFSET;
               this.m_questCards[_loc1_].card.y = AllianceQuestPopup.CARD_VERTICAL_OFFSET + (_loc1_ - this.firstCardIndex) * AllianceQuestPopup.CARD_VERTICAL_SPACING;
               _loc2_ = this.screen.anchor_mc.numChildren - 1;
               this.screen.anchor_mc.setChildIndex(this.m_questCards[_loc1_].card,_loc2_);
            }
            else
            {
               this.m_questCards[_loc1_].card.visible = false;
            }
            _loc1_++;
         }
      }
      
      private function displayCurrentQuestCard() : void
      {
         var _loc1_:int = this.getIndexForId(this.currentQuestId);
         if(_loc1_ >= this.firstCardIndex && _loc1_ <= this.lastCardIndex)
         {
            return;
         }
         this.m_firstIndex = Math.min(_loc1_,this.numCards - AllianceQuestPopup.NUM_CARDS_PER_PAGE);
      }
      
      private function get numCards() : uint
      {
         return this.m_questCards.length;
      }
      
      private function get firstCardIndex() : uint
      {
         return this.m_firstIndex;
      }
      
      private function get lastCardIndex() : uint
      {
         return this.m_firstIndex + AllianceQuestPopup.NUM_CARDS_PER_PAGE - 1;
      }
      
      private function onUp(param1:MouseEvent) : void
      {
         if(this.m_firstIndex > 0)
         {
            --this.m_firstIndex;
            this.positionCards();
            this.updatePageUI();
         }
      }
      
      private function onPageUp(param1:MouseEvent) : void
      {
         this.m_firstIndex = Math.max(0,this.m_firstIndex - AllianceQuestPopup.NUM_CARDS_PER_PAGE);
         this.positionCards();
         this.updatePageUI();
      }
      
      private function onDown(param1:MouseEvent) : void
      {
         if(this.lastCardIndex < this.numCards - 1)
         {
            ++this.m_firstIndex;
            this.positionCards();
            this.updatePageUI();
         }
      }
      
      private function onPageDown(param1:MouseEvent) : void
      {
         this.m_firstIndex = Math.min(this.numCards - AllianceQuestPopup.NUM_CARDS_PER_PAGE,this.m_firstIndex + AllianceQuestPopup.NUM_CARDS_PER_PAGE);
         this.positionCards();
         this.updatePageUI();
      }
      
      private function getCardForId(param1:String) : MovieClip
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_questCards)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_.card;
            }
         }
         return null;
      }
      
      private function getIdForCard(param1:MovieClip) : String
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_questCards)
         {
            if(_loc2_.card == param1)
            {
               return _loc2_.id;
            }
         }
         return "";
      }
      
      private function getIndexForId(param1:String) : int
      {
         var _loc2_:uint = 0;
         while(_loc2_ < this.m_questCards.length)
         {
            if(this.m_questCards[_loc2_].id == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function onCardMouseOver(param1:MouseEvent) : void
      {
         if(this.m_questCards[0].card != param1.currentTarget)
         {
            param1.currentTarget.arrow_btn_up.visible = false;
            param1.currentTarget.arrow_btn_dn.visible = false;
         }
         if(this.getIdForCard(param1.currentTarget as MovieClip) != this.currentQuestId)
         {
            param1.currentTarget.highlightHover.visible = true;
         }
      }
      
      private function onCardMouseOut(param1:MouseEvent) : void
      {
         param1.currentTarget.arrow_btn_up.visible = false;
         param1.currentTarget.arrow_btn_dn.visible = false;
         param1.currentTarget.highlightHover.visible = false;
      }
      
      private function onCardMouseClick(param1:MouseEvent) : void
      {
         this.setSelectedQuest(this.getIdForCard(param1.currentTarget as MovieClip));
      }
      
      private function onCardArrowUp(param1:MouseEvent) : void
      {
      }
      
      private function onCardArrowDown(param1:MouseEvent) : void
      {
      }
      
      private function updateQuestDetailsDisplay() : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc6_:ZGameQuestManager = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc17_:Boolean = false;
         var _loc18_:Boolean = false;
         var _loc19_:ZGameButton = null;
         var _loc20_:Object = null;
         var _loc21_:String = null;
         var _loc22_:ZGameButton = null;
         var _loc23_:String = null;
         var _loc24_:String = null;
         var _loc25_:Array = null;
         var _loc26_:ZGameButton = null;
         var _loc27_:ZGameButton = null;
         var _loc28_:Array = null;
         var _loc29_:ZGameButton = null;
         var _loc30_:Array = null;
         var _loc31_:MovieClip = null;
         var _loc32_:ZGameButton = null;
         var _loc33_:ZGameButton = null;
         var _loc34_:int = 0;
         var _loc35_:int = 0;
         var _loc36_:String = null;
         var _loc37_:String = null;
         var _loc38_:String = null;
         var _loc39_:String = null;
         var _loc40_:String = null;
         var _loc41_:String = null;
         this.m_textObj = this.getTextObject(this.currentQuestId);
         this.m_rewardsTextObj = this.getRewardsTextObject(this.currentQuestId);
         var _loc1_:MovieClip = this.screen;
         TextFieldUtil.processTextField(_loc1_.header_tf,this.textObj.title);
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.currentQuestId) as ZGameQuest;
         if(this.isExpiredAndCanRestart(_loc2_))
         {
            _loc9_ = ZGameTimeUtil.instance.getTimeString(_loc2_.lifeTime);
            TextFieldUtil.processTextField(_loc1_.popupBox_tf,ZGameUtils.ZlocT("Dialogs","BuyQuestRestartMessage",{"time":_loc9_}));
         }
         else
         {
            TextFieldUtil.processTextField(_loc1_.popupBox_tf,this.textObj.hint);
         }
         this.clearTaskButtons();
         this.m_taskButtons = new Vector.<Object>();
         var _loc3_:Array = this.getTasks();
         for each(_loc4_ in _loc3_)
         {
            _loc4_.visible = false;
         }
         _loc5_ = 0;
         _loc6_ = QuestManager.getInstance() as ZGameQuestManager;
         _loc7_ = _loc6_.getQuestTasks(this.m_id);
         for each(_loc8_ in this.textObj.taskText)
         {
            if(_loc5_ < _loc3_.length)
            {
               _loc10_ = String(_loc5_);
               _loc11_ = Boolean(this.textObj.taskComplete[_loc5_]);
               _loc12_ = !_loc11_ && Boolean(this.textObj.taskBuyable[_loc5_]);
               _loc13_ = !_loc11_ && Boolean(this.textObj.taskRequestable[_loc5_]);
               _loc14_ = !_loc11_ && (_loc2_.dialogAcceptButtonOverride != null || Boolean(this.textObj.taskInvites[_loc5_]));
               _loc15_ = !_loc11_ && Boolean(this.textObj.taskFeeds[_loc5_]);
               _loc16_ = !_loc11_ && Boolean(this.textObj.taskBattle[_loc5_]);
               _loc17_ = !_loc11_ && Boolean(this.textObj.taskSpendButton[_loc5_]);
               _loc18_ = false;
               if(!_loc12_)
               {
                  _loc18_ = !_loc11_ && Boolean(this.textObj.taskItemBuyable[_loc5_]);
               }
               _loc3_[_loc5_].visible = true;
               TextFieldUtil.compactTextField(_loc3_[_loc5_].name_tf,_loc8_);
               TextFieldUtil.processTextField(_loc3_[_loc5_].progress_tf,this.textObj.taskProgress[_loc5_]);
               _loc3_[_loc5_].check_mc.visible = _loc11_;
               _loc3_[_loc5_].accept_bt.visible = _loc12_ || _loc18_;
               _loc3_[_loc5_].invite_bt.visible = _loc14_;
               if(_loc3_[_loc5_].accept_bt2)
               {
                  if(Boolean(_loc3_[_loc5_].accept_bt) && _loc3_[_loc5_].accept_bt != _loc3_[_loc5_].accept_bt2)
                  {
                     _loc3_[_loc5_].accept_bt.parent.removeChild(_loc3_[_loc5_].accept_bt);
                     _loc3_[_loc5_]["accept_bt"] = _loc3_[_loc5_].accept_bt2;
                  }
               }
               ZGameTask.applyDiscountText(_loc3_[_loc5_].accept_bt,0);
               _loc3_[_loc5_].accept_bt.visible = _loc12_ || _loc18_;
               if(_loc3_[_loc5_].fight_bt)
               {
                  _loc3_[_loc5_].fight_bt.visible = _loc16_ || _loc17_;
                  _loc3_[_loc5_].ask_bt.visible = _loc13_ || _loc15_ || _loc14_;
               }
               else
               {
                  _loc3_[_loc5_].ask_bt.visible = _loc13_ || _loc15_ || _loc16_ || _loc14_ || _loc17_;
               }
               if(_loc12_)
               {
                  _loc19_ = new ZGameButton(_loc3_[_loc5_].accept_bt,this.onBuy);
                  _loc20_ = _loc7_[_loc5_].getDynamicSkipCost();
                  ZGameTask.applyDiscountText(_loc3_[_loc5_].accept_bt,_loc20_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_DISCOUNT]);
                  _loc21_ = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc20_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
                  _loc19_.compactText(_loc21_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "fontSize":14,
                     "onFail":"return"
                  });
                  _loc19_.buttonValue = _loc10_;
                  _loc19_.buttonObject = {"buttonType":"buyButton"};
                  this.m_taskButtons.push({
                     "taskIndex":_loc5_,
                     "button":_loc19_
                  });
               }
               else if(_loc18_)
               {
                  _loc22_ = new ZGameButton(_loc3_[_loc5_].accept_bt,this.onBuyItem);
                  _loc23_ = ZGameUtils.ZlocT("Dialogs","BuildingPartBuyPartButton",{"amount":this.textObj.taskItemBuyAmountCash[_loc5_]});
                  _loc22_.compactText(_loc23_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "fontSize":14,
                     "onFail":"return"
                  });
                  _loc22_.buttonValue = _loc10_;
                  _loc22_.buttonObject = {"buttonType":"itemBuyButton"};
                  this.m_taskButtons.push({
                     "taskIndex":_loc5_,
                     "button":_loc22_
                  });
               }
               if(_loc14_)
               {
                  _loc24_ = this.textObj.taskInvites[_loc5_] == null ? _loc2_.dialogAcceptButtonOverride : this.textObj.taskInvites[_loc5_].button.toString();
                  if(_loc24_)
                  {
                     _loc25_ = _loc24_.split(":");
                     if(_loc25_.length == 2)
                     {
                        _loc26_ = new ZGameButton(_loc3_[_loc5_].invite_bt,this.onInvite);
                        _loc26_.compactText(ZGameUtils.ZlocT(_loc25_[0],_loc25_[1]),{
                           "maxLines":1,
                           "minScale":0.4,
                           "fontSize":14,
                           "onFail":"return"
                        });
                        this.m_taskButtons.push({
                           "taskIndex":_loc5_,
                           "button":_loc26_
                        });
                     }
                  }
               }
               if(_loc13_)
               {
                  _loc27_ = new ZGameButton(_loc3_[_loc5_].ask_bt,this.onRequest);
                  _loc27_.compactText(ZGameUtils.ZlocT("Dialogs","BuildingPartAskPartButton"),{
                     "maxLines":1,
                     "minScale":0.4,
                     "fontSize":14,
                     "onFail":"return"
                  });
                  _loc27_.buttonValue = _loc10_;
                  this.m_taskButtons.push({
                     "taskIndex":_loc5_,
                     "button":_loc27_
                  });
               }
               else if(_loc15_)
               {
                  _loc28_ = this.textObj.taskFeeds[_loc5_].button.split(":");
                  _loc29_ = new ZGameButton(_loc3_[_loc5_].ask_bt,this.onFeed);
                  _loc29_.compactText(ZGameUtils.ZlocT(_loc28_[0],_loc28_[1]),{
                     "maxLines":1,
                     "minScale":0.4,
                     "fontSize":14,
                     "onFail":"return"
                  });
                  _loc29_.buttonValue = _loc10_;
                  this.m_taskButtons.push({
                     "taskIndex":_loc5_,
                     "button":_loc29_
                  });
               }
               else if(_loc16_)
               {
                  _loc30_ = this.textObj.taskBattle[_loc5_].button.split(":");
                  _loc31_ = _loc3_[_loc5_].fight_bt ? _loc3_[_loc5_].fight_bt : _loc3_[_loc5_].ask_bt;
                  _loc32_ = new ZGameButton(_loc31_,this.onBattle);
                  _loc32_.compactText(ZGameUtils.ZlocT(_loc30_[0],_loc30_[1]),{
                     "maxLines":1,
                     "minScale":0.4,
                     "fontSize":14,
                     "onFail":"return"
                  });
                  _loc32_.buttonValue = _loc10_;
                  this.m_taskButtons.push({
                     "taskIndex":_loc5_,
                     "button":_loc32_
                  });
               }
               else if(_loc17_)
               {
                  _loc30_ = this.textObj.taskSpendButton[_loc5_].button.split(":");
                  _loc33_ = new ZGameButton(_loc3_[_loc5_].ask_bt,this.onSpend);
                  _loc33_.text = ZGameUtils.ZlocT(_loc30_[0],_loc30_[1]);
                  _loc33_.buttonValue = _loc10_;
                  this.m_taskButtons.push({
                     "taskIndex":_loc5_,
                     "button":_loc33_
                  });
                  _loc34_ = 0;
                  _loc35_ = parseInt(this.textObj.taskTotal[_loc5_]);
                  if(this.textObj.taskSpendButton[_loc5_].type == "item")
                  {
                     _loc34_ = ZGlobal.player.getNumberOfInventoryItems(this.textObj.taskItem[_loc5_]);
                  }
                  else
                  {
                     _loc34_ = int(ZGlobal.player.resources.resourceAmounts[WorldResourceManager.instance.resourceFromRareResource(this.textObj.taskSpendButton[_loc5_].type)]);
                     if(_loc2_.name == "QALL1" && _loc5_ == 2)
                     {
                        _loc36_ = ZGlobal.player.rareResourceName;
                        _loc37_ = ZGameUtils.ZlocT("Items",_loc36_ + "_menuName");
                        _loc38_ = ZGameUtils.ZlocTP("QuestTrees","QALL1_03_button",{"nrare0":_loc37_});
                        _loc33_.text = _loc38_;
                     }
                  }
                  if(_loc34_ < _loc35_)
                  {
                     if(_loc2_.name == "QALL1" && _loc5_ == 2)
                     {
                        _loc39_ = ZGlobal.player.rareResourceName;
                        _loc40_ = ZGameUtils.ZlocT("Items",_loc39_ + "_menuName");
                        _loc41_ = ZGameUtils.ZlocTP("QuestTrees",this.textObj.taskSpendButton[_loc5_].tooltip,{
                           "num":_loc34_,
                           "total":_loc35_,
                           "nrare0":_loc40_
                        });
                        _loc33_.disableWithTooltip(_loc41_);
                     }
                     else
                     {
                        _loc33_.disableWithTooltip(ZGameUtils.ZlocTP("QuestTrees",this.textObj.taskSpendButton[_loc5_].tooltip,{
                           "num":_loc34_,
                           "total":_loc35_
                        }));
                     }
                  }
               }
               if(this.textObj.taskIcons[_loc5_].length > 0)
               {
                  if(this.m_loaders[this.TASK_LOADERS][_loc5_] != null)
                  {
                     this.m_loaders[this.TASK_LOADERS][_loc5_].destroy();
                  }
                  this.m_loaders[this.TASK_LOADERS][_loc5_] = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(this.textObj.taskIcons[_loc5_]),_loc3_[_loc5_].icon_mc);
                  this.m_loaders[this.TASK_LOADERS][_loc5_].smooth = true;
               }
               else
               {
                  _loc3_[_loc5_].icon_mc.unload();
               }
            }
            _loc5_++;
         }
         this.updateBuyAllDisplay();
         this.setupDialogType();
      }
      
      private function setupDialogType() : void
      {
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.currentQuestId) as ZGameQuest;
         var _loc2_:String = null;
         if(_loc1_.advisorId)
         {
            _loc2_ = _loc1_.advisorId;
         }
         else
         {
            _loc2_ = "a01";
         }
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
         var _loc4_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc3_.getCachedImage("questNormal").url,this.screen.uiloader_mc);
         _loc4_.smooth = true;
      }
      
      private function updateBuyAllDisplay() : void
      {
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:String = null;
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.currentQuestId) as ZGameQuest;
         var _loc2_:Array = this.getTasks();
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc7_:Array = _loc6_.getQuestTasks(this.m_id);
         for each(_loc8_ in this.textObj.taskText)
         {
            if(_loc5_ < _loc2_.length)
            {
               _loc9_ = Boolean(this.textObj.taskComplete[_loc5_]);
               _loc10_ = !_loc9_ && Boolean(this.textObj.taskBuyable[_loc5_]);
               _loc11_ = false;
               if(!_loc10_)
               {
                  _loc11_ = !_loc9_ && Boolean(this.textObj.taskItemBuyable[_loc5_]);
               }
               if(_loc10_)
               {
                  _loc3_ += _loc7_[_loc5_].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST];
                  _loc4_ = true;
               }
               else if(_loc11_)
               {
                  _loc3_ += this.textObj.taskItemBuyAmountCash[_loc5_];
               }
            }
            _loc5_++;
         }
         if(_loc3_ > 0)
         {
            _loc12_ = _loc4_ ? "QuestManagerSkipAllButtonLabel" : "BuyAllForAmount";
            this.m_buyAllButton.compactText(ZGameUtils.ZlocT("Dialogs",_loc12_,{"amount":_loc3_}),{
               "maxLines":1,
               "minScale":0.4,
               "fontSize":14,
               "onFail":"return"
            });
            this.m_buyAllButton.callback = this.onBuyAll;
            if(this.m_restartButton)
            {
               this.m_buyAllButton.hide();
            }
            else
            {
               this.m_buyAllButton.show();
            }
         }
         else
         {
            this.m_buyAllButton.hide();
         }
      }
      
      private function updateQuestRewardsDisplay() : void
      {
         var _loc3_:String = null;
         var _loc1_:Array = this.getRewardClips();
         var _loc2_:int = 0;
         for each(_loc3_ in this.rewardsTextObj.rewardText)
         {
            if(_loc2_ < _loc1_.length)
            {
               _loc1_[_loc2_].visible = true;
               TextFieldUtil.processTextField(_loc1_[_loc2_].value_tf,this.m_rewardsTextObj.rewardPairs[_loc2_].count);
               if(this.m_rewardsTextObj.rewardPairs[_loc2_].hasOwnProperty("strength"))
               {
                  if(_loc1_[_loc2_].strength_mc)
                  {
                     _loc1_[_loc2_].strength_mc.visible = true;
                     TextFieldUtil.processTextField(_loc1_[_loc2_].strength_mc.strength_tf,this.m_rewardsTextObj.rewardPairs[_loc2_].strength);
                  }
               }
               else if(_loc1_[_loc2_].strength_mc)
               {
                  _loc1_[_loc2_].strength_mc.visible = false;
               }
               if(this.m_loaders[this.REWARD_LOADERS][_loc2_] != null)
               {
                  this.m_loaders[this.REWARD_LOADERS][_loc2_].destroy();
               }
               this.m_loaders[this.REWARD_LOADERS][_loc2_] = ImageLoaderFactory.CreateImageLoader(this.rewardsTextObj.rewardIcons[_loc2_],_loc1_[_loc2_].icon);
               this.m_loaders[this.REWARD_LOADERS][_loc2_].smooth = true;
            }
            _loc2_++;
         }
         while(_loc2_ < _loc1_.length)
         {
            _loc1_[_loc2_].visible = false;
            _loc2_++;
         }
      }
      
      private function get numRewards() : int
      {
         var _loc2_:String = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.rewardsTextObj.rewardText)
         {
            _loc1_ += 1;
         }
         return _loc1_;
      }
      
      private function getRewardClips() : Array
      {
         var _loc1_:Array = null;
         if(this.numRewards == 0)
         {
            _loc1_ = [];
            this.screen.rewards_even.visible = false;
            this.screen.rewards_odd.visible = false;
         }
         else if(this.numRewards % 2 == 0)
         {
            _loc1_ = [this.screen.rewards_even.rewardCard_01,this.screen.rewards_even.rewardCard_02];
            this.screen.rewards_even.visible = true;
            this.screen.rewards_odd.visible = false;
         }
         else
         {
            _loc1_ = [this.screen.rewards_odd.rewardCard_02,this.screen.rewards_odd.rewardCard_01,this.screen.rewards_odd.rewardCard_03];
            this.screen.rewards_even.visible = false;
            this.screen.rewards_odd.visible = true;
         }
         return _loc1_;
      }
      
      private function updateTaskButtons(param1:int, param2:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:ZGameQuestManager = null;
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         if(this.m_taskButtons)
         {
            _loc3_ = 0;
            for(; _loc3_ < this.m_taskButtons.length; _loc3_++)
            {
               _loc4_ = this.m_taskButtons[_loc3_];
               if(_loc4_.taskIndex != param1)
               {
                  continue;
               }
               if(!(Boolean(_loc4_.button) && Boolean(_loc4_.button.buttonObject) && Boolean(_loc4_.button.buttonObject.buttonType)))
               {
                  continue;
               }
               switch(_loc4_.button.buttonObject.buttonType)
               {
                  case "buyButton":
                     _loc5_ = QuestManager.getInstance() as ZGameQuestManager;
                     _loc6_ = _loc5_.getQuestTasks(this.m_id);
                     _loc7_ = _loc6_[param1].getDynamicSkipCost();
                     _loc4_.button.text = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc7_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
                     break;
                  case "itemBuyButton":
                     _loc8_ = ZGameUtils.ZlocT("Dialogs","BuildingPartBuyPartButton",{"amount":param2.taskItemBuyAmountCash[param1]});
                     _loc4_.button.compactText(_loc8_,{
                        "maxLines":1,
                        "minScale":0.4,
                        "fontSize":14,
                        "onFail":"return"
                     });
               }
            }
         }
      }
      
      private function clearButtonsForTask(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.m_taskButtons)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_taskButtons.length)
            {
               _loc3_ = this.m_taskButtons[_loc2_];
               if(_loc3_.taskIndex == param1)
               {
                  if(_loc3_.button)
                  {
                     _loc3_.button.dispose();
                     _loc3_.button = null;
                  }
                  this.m_taskButtons.splice(_loc2_,1);
               }
               else
               {
                  _loc2_++;
               }
            }
         }
      }
      
      private function clearTaskButtons() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(this.m_taskButtons)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_taskButtons.length)
            {
               _loc2_ = this.m_taskButtons[_loc1_];
               if(_loc2_.button)
               {
                  _loc2_.button.dispose();
                  _loc2_.button = null;
               }
               _loc1_++;
            }
         }
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         this.close();
      }
      
      private function getTasks() : Array
      {
         var _loc1_:MovieClip = this.screen;
         return [_loc1_.requirement1_mc,_loc1_.requirement2_mc,_loc1_.requirement3_mc];
      }
      
      protected function setUpQuestUI() : void
      {
         var _loc1_:Object = this.getTextObject(this.currentQuestId);
         if(null == _loc1_.taskText)
         {
            this.close();
            return;
         }
         if(this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         this.contentWidth = this.screen.width;
         this.contentHeight = this.screen.height;
         this.initDialog();
         addChild(m_window);
         m_origOffsetX = m_window.screen_mc.panel_mc.x;
         m_origOffsetY = m_window.screen_mc.panel_mc.y;
         this.contentWidth = m_window.screen_mc.width;
         this.contentHeight = m_window.screen_mc.height;
         centerWithinStage(Zlab.mainStage);
         dispatchEvent(new Event(Event.COMPLETE));
         var _loc2_:MovieClip = this.screen;
         _loc2_.visible = true;
         this.updateQuestDisplay();
      }
      
      private function isExpiredAndCanRestart(param1:ZGameQuest) : Boolean
      {
         return param1.hasLifeTime && param1.getTimeRemaining() <= 0;
      }
      
      private function updateDate(param1:Boolean = false) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:QuestTree = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.currentQuestId) as ZGameQuest;
         if(this.isExpiredAndCanRestart(_loc2_))
         {
            this.screen.timeOutMask_mc.visible = true;
            this.screen.rewards_tf.visible = false;
            if(this.screen.limited_mc)
            {
               this.screen.limited_mc.visible = false;
            }
            TextFieldUtil.processTextField(this.screen.timeOutMask_mc.timeOut_tf,ZGameUtils.ZlocT("Dialogs","BuyQuestRestartHeader"));
            this.m_buyAllButton.hide();
            this.m_restartButton = new ZGameButton(this.screen.timeOutMask_mc.skip_btn,this.onRestartQuest);
            this.m_restartButton.show();
            this.m_restartButton.text = ZGameUtils.ZlocT("Dialogs","BuyQuestRestartButton",{"amount":_loc2_.restartCost});
         }
         else
         {
            this.screen.timeOutMask_mc.visible = false;
            if(this.m_buyAllButton.callback == this.onBuyAll)
            {
               this.m_buyAllButton.show();
            }
            _loc3_ = ZGlobal.player.questTrees.isQuestTreeQuest(this.m_id);
            if(_loc2_.hasDate || _loc2_.hasLifeTime || _loc3_)
            {
               if(_loc2_.hasDate || _loc3_)
               {
                  if(param1)
                  {
                     if(this.screen.limited_mc)
                     {
                        if(_loc3_)
                        {
                           TextFieldUtil.compactTextField(this.screen.limited_mc.time_tf,"");
                        }
                        else
                        {
                           TextFieldUtil.compactTextField(this.screen.limited_mc.time_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionBanner"));
                        }
                     }
                  }
                  _loc4_ = new Object();
                  _loc5_ = ZGameTimeUtil.instance.getDateStatus(_loc4_,_loc2_.xml);
                  if(_loc5_ == ZGameTimeUtil.DATE_STATUS_LATE)
                  {
                     QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_COMPLETE,{"name":_loc2_.name}));
                  }
                  else
                  {
                     if(param1)
                     {
                        if(this.screen.limited_mc)
                        {
                           if(this.m_clock)
                           {
                              this.m_clock.dispose();
                              this.m_clock = null;
                           }
                           _loc6_ = _loc2_.xml;
                           if(_loc3_)
                           {
                              _loc7_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_id);
                              _loc8_ = ZGlobal.player.questTrees.getQuestTree(_loc7_);
                              _loc6_ = _loc8_.xml;
                           }
                           this.m_clock = new MOTDCountdownClock(this.screen.limited_mc.clock_mc,_loc6_,true);
                        }
                     }
                     this.startDateTimer();
                  }
               }
               if(_loc2_.hasLifeTime)
               {
                  if(param1)
                  {
                     if(this.screen.limited_mc)
                     {
                        this.m_clock = new MOTDCountdownClock(this.screen.limited_mc.clock_mc,_loc2_.xml,true);
                     }
                  }
                  this.startDateTimer();
               }
            }
            if(param1)
            {
               this.screen.rewards_tf.visible = true;
               if(this.screen.limited_mc)
               {
                  this.screen.limited_mc.visible = _loc2_.hasDate || ZGlobal.player.questTrees.isQuestTreeQuest(this.m_id);
               }
            }
         }
      }
      
      private function startDateTimer() : void
      {
         this.stopDateTimer();
         Zlab.processManager.schedule(1000,this,this.onDateTimer);
      }
      
      private function stopDateTimer() : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onDateTimer() : void
      {
         this.updateDate();
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         if(this.currentQuestId == param1.eventData.name)
         {
            this.close();
         }
      }
      
      protected function onQuestProgress(param1:WorldEvent) : void
      {
         this.textObj = this.getTextObject(this.currentQuestId);
         var _loc2_:Array = this.getTasks();
         var _loc3_:int = Math.min(this.textObj.taskProgress.length,_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            TextFieldUtil.compactTextField(_loc2_[_loc4_].progress_tf,this.textObj.taskProgress[_loc4_]);
            if(this.textObj.taskComplete[_loc4_])
            {
               this.clearButtonsForTask(_loc4_);
               _loc2_[_loc4_].accept_bt.visible = false;
               _loc2_[_loc4_].ask_bt.visible = false;
               _loc2_[_loc4_].check_mc.visible = true;
            }
            else
            {
               this.updateTaskButtons(_loc4_,this.textObj);
            }
            _loc4_++;
         }
         this.updateBuyAllDisplay();
      }
      
      private function onFeed(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:GameItem = null;
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         if(Boolean(this.textObj.taskFeeds) && Boolean(_loc2_ >= 0) && _loc2_ < this.textObj.taskFeeds.length)
         {
            _loc3_ = this.textObj.taskFeeds[_loc2_];
            _loc4_ = {};
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,GameItem) as GameItem;
            if(_loc5_)
            {
               _loc4_.itemCode = _loc5_.code;
               _loc4_.buildingName = _loc5_.name;
               _loc4_.ITEMTOKOVERRIDEitem = _loc5_.name + "|";
            }
            ViralsManager.instance.sendFeedWithLotsOfFriction(_loc3_.name,_loc4_,null);
         }
      }
      
      private function onBattle(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         var _loc3_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc4_:Array = _loc3_.getQuestTasks(this.currentQuestId);
         var _loc5_:ZGameTask = _loc4_[_loc2_];
         GMBattle.createStaticBattleFromQuest({
            "id":this.currentQuestId,
            "index":_loc2_,
            "quest":this.currentQuestId,
            "allies":_loc5_.combatAllies
         },_loc5_.fleetName,null,_loc5_);
         this.close();
      }
      
      private function onRequest(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:GameItem = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         var _loc2_:String = param1.currentTarget.buttonValue;
         var _loc3_:int = int(_loc2_);
         if(_loc3_ >= 0 && _loc3_ < this.textObj.taskRequestAction.length && _loc3_ < this.textObj.taskItem.length)
         {
            _loc4_ = this.textObj.taskRequestAction[_loc3_];
            _loc5_ = this.textObj.taskItem[_loc3_];
            if(_loc5_ != null && _loc5_.length > 0)
            {
               _loc6_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem));
               if(WindowManager.isFullScreen())
               {
                  WindowManager.toggleFullScreen();
               }
               _loc7_ = ZGlobal.player.questTrees.isQuestTreeQuest(this.m_id) ? "mini_series" : "quest";
               _loc4_ += _loc6_.name + "&source=" + _loc7_ + "&quest=" + this.m_id + "&task=" + _loc3_;
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
               {
                  _loc8_ = new Array();
                  _loc8_["source"] = _loc7_;
                  _loc8_["quest"] = this.m_id;
                  _loc8_["task"] = _loc3_;
                  PopupManager.instance.push(new RequestAskPartsDialog(_loc6_.name,"",_loc8_),0,false);
               }
               else
               {
                  ExternalInterface.call("ZYFrameManager.navigateTo",_loc4_);
               }
            }
         }
         else
         {
            Logger.print(this,"Warning, button user data indicates incorrect task #");
         }
      }
      
      protected function onSpend(param1:MouseEvent) : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         var _loc2_:String = param1.currentTarget.buttonValue;
         var _loc3_:int = int(_loc2_);
         if(_loc3_ >= 0 && _loc3_ < this.textObj.taskItem.length)
         {
            _loc5_ = null;
            _loc6_ = this.textObj.taskSpendButton[_loc3_].type;
            if(_loc6_ == "item")
            {
               _loc5_ = this.textObj.taskItem[_loc3_];
               if(_loc5_)
               {
                  _loc4_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem));
                  if(_loc4_)
                  {
                     ZGlobal.player.removeInventoryItem(_loc4_.code,this.textObj.taskTotal[_loc3_]);
                  }
               }
            }
            else
            {
               ZGlobal.player.resources.updateResourceAmount(WorldResourceManager.instance.resourceFromRareResource(this.textObj.taskSpendButton[_loc3_].type),-this.textObj.taskTotal[_loc3_]);
            }
            if(_loc6_ != null)
            {
               TransactionManager.addTransaction(new TSpend(_loc6_,_loc5_,this.textObj.taskTotal[_loc3_]));
               _loc7_ = 0;
               while(_loc7_ < this.m_taskButtons.length)
               {
                  if(this.m_taskButtons[_loc7_].taskIndex == _loc3_)
                  {
                     this.m_taskButtons[_loc7_].button.disable();
                  }
                  _loc7_++;
               }
            }
         }
         else
         {
            Logger.print(this,"Warning, button user data indicates incorrect task #");
         }
      }
      
      private function onRestartQuest(param1:MouseEvent) : void
      {
         var _loc3_:ZGameQuestManager = null;
         if(this.m_restartButton)
         {
            this.m_restartButton.dispose();
            this.m_restartButton = null;
         }
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.currentQuestId) as ZGameQuest;
         if(this.isExpiredAndCanRestart(_loc2_))
         {
            if(ZGlobal.player.canBuyCash(_loc2_.restartCost,true,"",false))
            {
               TransactionManager.addTransaction(new TBuyQuestRestartTask(_loc2_.name));
               ZGlobal.player.cash -= _loc2_.restartCost;
               _loc2_.startTime = GlobalEngine.getTimer() / 1000;
               _loc3_ = QuestManager.getInstance(null) as ZGameQuestManager;
               if(_loc3_)
               {
                  _loc3_.dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_RESTARTED,_loc2_.name));
               }
               this.updateQuestDisplay();
            }
         }
      }
      
      private function onBuyAll(param1:MouseEvent) : void
      {
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc4_:Array = _loc3_.getQuestTasks(this.m_id);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            if(!this.textObj.taskComplete[_loc5_])
            {
               if(this.textObj.taskBuyable[_loc5_])
               {
                  _loc2_ += _loc4_[_loc5_].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST];
               }
               else if(this.textObj.taskItemBuyable[_loc5_])
               {
                  _loc2_ += this.textObj.taskItemBuyAmountCash[_loc5_];
               }
            }
            _loc5_++;
         }
         if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc6_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc2_));
               _loc7_ = new Array("EmpirePointsConfirm","","","");
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc6_,null,this.onBuyAllConfirmed,_loc7_);
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else
            {
               this.buyAllTasks();
            }
         }
      }
      
      private function onBuyAllConfirmed(param1:GenericPopupEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            this.buyAllTasks();
         }
         this.m_buyPopup = null;
      }
      
      private function buyAllTasks() : void
      {
         var _loc1_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc2_:Array = _loc1_.getQuestTasks(this.m_id);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(!this.textObj.taskComplete[_loc3_])
            {
               if(this.textObj.taskBuyable[_loc3_])
               {
                  this.buyTask(_loc3_);
               }
               else if(this.textObj.taskItemBuyable[_loc3_])
               {
                  this.buyItem(this.textObj.taskItem[_loc3_],this.textObj.taskItemBuyAmount[_loc3_]);
               }
            }
            _loc3_++;
         }
      }
      
      private function onBuy(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         var _loc2_:String = param1.currentTarget.buttonValue;
         var _loc3_:int = int(_loc2_);
         var _loc4_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc5_:Array = _loc4_.getQuestTasks(this.m_id);
         if(_loc3_ >= 0 && _loc3_ < _loc5_.length)
         {
            _loc6_ = int(_loc5_[_loc3_].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            if(ZGlobal.player.canBuyCash(_loc6_,true,"",false))
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc6_))
               {
                  _loc7_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc6_));
                  _loc8_ = new Array("EmpirePointsConfirm","","","");
                  this.m_buyPopup = GenericPopup2B.NewYesNo(_loc7_,null,this.onBuyConfirmed,_loc8_);
                  this.m_buyPopup.userData = param1.currentTarget.buttonValue;
                  PopupManager.instance.push(this.m_buyPopup,0,false);
               }
               else
               {
                  this.buyTask(parseInt(param1.currentTarget.buttonValue));
               }
            }
         }
         else
         {
            Logger.print(this,"Warning, button user data indicates incorrect task #");
         }
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData as String;
            _loc3_ = int(_loc2_);
            this.buyTask(_loc3_);
         }
         this.m_buyPopup = null;
      }
      
      private function buyTask(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:TBuyQuestTask = null;
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc3_:Array = _loc2_.getQuestTasks(this.m_id);
         if(param1 < _loc3_.length)
         {
            _loc4_ = int(_loc3_[param1].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            ZGlobal.player.cash -= _loc4_;
            _loc3_[param1].buyCompletion();
            _loc5_ = new TBuyQuestTask(this.currentQuestId,param1,_loc4_);
            TransactionManager.addTransaction(_loc5_,true);
            _loc5_ = null;
         }
      }
      
      private function onBuyItem(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:int = int(this.textObj.taskItemBuyAmountCash[param1.currentTarget.buttonValue]);
         if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmAllPartsBuyMessage",_loc4_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,_loc3_,this.buyItemConfirmed);
               this.m_buyPopup.userData = {
                  "item":this.textObj.taskItem[param1.currentTarget.buttonValue],
                  "amount":this.textObj.taskItemBuyAmount[param1.currentTarget.buttonValue]
               };
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else
            {
               this.buyItem(this.textObj.taskItem[param1.currentTarget.buttonValue],this.textObj.taskItemBuyAmount[param1.currentTarget.buttonValue]);
            }
         }
      }
      
      private function buyItemConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyItem(param1.userData.item,param1.userData.amount);
         }
      }
      
      private function buyItem(param1:String, param2:int) : void
      {
         var _loc3_:Boolean = true;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         ZGlobal.player.buyItem(_loc4_,_loc3_,param2);
         ZGlobal.player.addToInventory(param1,param2);
         TransactionManager.addTransaction(new TBuyItem(param1,_loc3_,param2),true);
      }
      
      private function onInvite(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.currentQuestId) as ZGameQuest;
         if(Boolean(_loc2_) && Boolean(_loc2_.onDialogClosedShowInviteTabView))
         {
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST,_loc2_.onDialogClosedShowInviteTabView,null,null,true);
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.closeBuyConfirmation();
         super.close();
      }
      
      private function closeBuyConfirmation() : void
      {
         if(this.m_buyPopup)
         {
            this.m_buyPopup.closeWindow();
            this.m_buyPopup = null;
         }
      }
      
      private function onBack(param1:Event) : void
      {
         PopupManager.instance.push(new AllianceQuestMain());
         this.close();
      }
   }
}

