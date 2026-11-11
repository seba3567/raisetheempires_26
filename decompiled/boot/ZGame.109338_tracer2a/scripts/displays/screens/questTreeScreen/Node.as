package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.questTrees.QuestTree;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.quest.QuestDetailsPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class Node
   {
      
      protected static const STATE_NONE:int = 0;
      
      protected static const STATE_AVAILABLE:int = 1;
      
      protected static const STATE_LOCKED:int = 2;
      
      protected static const STATE_DONE:int = 3;
      
      protected var m_clip:MovieClip = null;
      
      protected var m_lines:Dictionary = null;
      
      protected var m_xml:XML = null;
      
      protected var m_treeId:String = null;
      
      protected var m_parents:Array = null;
      
      protected var m_sequels:Array = null;
      
      protected var m_questPopup:QuestDetailsPopup = null;
      
      protected var m_button:ZGameButton = null;
      
      protected var m_state:int = 0;
      
      protected var m_flyoutInitialised:Boolean = false;
      
      protected var m_loader:ImageLoader = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_iconNoScale:Boolean;
      
      protected var m_centerIconToUiLoaderCenter:Boolean;
      
      protected var m_uiLoaderCenterPoint:Point;
      
      protected var m_imageLoader:ImageLoader;
      
      protected var m_continueBtn:ZGameButton = null;
      
      public function Node(param1:MovieClip, param2:Dictionary, param3:XML, param4:String, param5:Boolean = false, param6:Boolean = false)
      {
         super();
         this.m_xml = param3;
         this.m_treeId = param4;
         this.m_clip = param1;
         this.m_lines = param2;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_iconNoScale = param5;
         this.m_centerIconToUiLoaderCenter = param6;
         if(this.m_clip)
         {
            this.initializeUI();
            this.addEventListeners();
         }
      }
      
      protected function initializeUI() : void
      {
         var _loc2_:Rectangle = null;
         var _loc1_:Function = null;
         if(this.m_centerIconToUiLoaderCenter == true)
         {
            _loc1_ = this.onIconLoadedComplete;
            _loc2_ = getVisibleBounds(this.m_clip.card_mc.unitCard_mc.icon);
            this.m_uiLoaderCenterPoint = new Point(_loc2_.width * 0.5,_loc2_.height * 0.5);
         }
         if(this.m_iconNoScale == true)
         {
            (this.m_clip.card_mc.unitCard_mc.icon as UILoader).scaleContent = false;
         }
         if(this.m_clip.card_mc.unitCard_mc != null)
         {
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGameQuestManager.instance.getButtonIconPath(this.questName),this.m_clip.card_mc.unitCard_mc.icon,_loc1_);
         }
         this.m_clip.visible = true;
      }
      
      protected function onIconLoadedComplete(param1:String, param2:BitmapData) : void
      {
         var _loc3_:Rectangle = getVisibleBounds(this.m_clip.card_mc.unitCard_mc);
         this.m_clip.card_mc.unitCard_mc.x = -_loc3_.width * 0.5 + this.m_uiLoaderCenterPoint.x;
         this.m_clip.card_mc.unitCard_mc.y = -_loc3_.height * 0.5 + this.m_uiLoaderCenterPoint.y;
      }
      
      protected function addEventListeners() : void
      {
         if(this.m_clip)
         {
            this.m_clip.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_clip.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            ZGameQuestManager.instance.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
            ZGameQuestManager.instance.addEventListener(ZGameQuestManager.QUEST_REWARDS_GIVEN,this.onRewardsGiven);
            ZGameQuestManager.instance.addEventListener(ZGameQuestManager.CLIENT_QUEST_ACTIVATED,this.onClientQuestActivated,false,0,true);
         }
      }
      
      protected function removeEventListeners() : void
      {
         if(this.m_clip)
         {
            this.m_clip.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_clip.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            ZGameQuestManager.instance.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
            ZGameQuestManager.instance.removeEventListener(ZGameQuestManager.QUEST_REWARDS_GIVEN,this.onRewardsGiven);
            ZGameQuestManager.instance.removeEventListener(ZGameQuestManager.CLIENT_QUEST_ACTIVATED,this.onClientQuestActivated);
         }
      }
      
      public function addParent(param1:Node) : void
      {
         if(!this.m_parents)
         {
            this.m_parents = new Array();
         }
         this.m_parents.push(param1);
      }
      
      public function addSequel(param1:Node) : void
      {
         if(!this.m_sequels)
         {
            this.m_sequels = new Array();
         }
         this.m_sequels.push(param1);
      }
      
      public function dispose() : void
      {
         this.m_questPopup = null;
         this.m_buttonSounds.release();
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
         }
         if(this.m_continueBtn)
         {
            this.m_continueBtn.dispose();
            this.m_continueBtn = null;
         }
         this.removeEventListeners();
         this.m_clip = null;
      }
      
      public function get questName() : String
      {
         if(this.m_xml.@quest == undefined)
         {
            return null;
         }
         return this.m_xml.@quest.toString();
      }
      
      public function updateState() : void
      {
         var _loc1_:MovieClip = null;
         if(this.m_continueBtn)
         {
            this.m_continueBtn.dispose();
            this.m_continueBtn = null;
         }
         if(!this.m_clip)
         {
            return;
         }
         if(this.isDone())
         {
            this.m_clip.card_mc.gotoAndStop("_complete");
            this.m_state = STATE_DONE;
            this.updateLineStates();
         }
         else if(this.isAvailable())
         {
            this.m_clip.card_mc.gotoAndStop("_available");
            if(this.m_clip.card_mc.hasOwnProperty("continue_bt"))
            {
               this.m_continueBtn = new ZGameButton(this.m_clip.card_mc.continue_bt);
               if(this.isActive())
               {
                  this.m_continueBtn.text = ZGameUtils.ZlocT("Dialogs","Continue");
               }
               else
               {
                  this.m_continueBtn.text = ZGameUtils.ZlocT("Dialogs","Accept");
               }
            }
            this.m_state = STATE_AVAILABLE;
            this.updateLineStates();
         }
         else
         {
            this.m_clip.card_mc.gotoAndStop("_locked");
            this.m_state = STATE_LOCKED;
            for each(_loc1_ in this.m_lines)
            {
               this.enableLine(_loc1_,false);
            }
         }
      }
      
      private function updateLineStates() : void
      {
         var _loc1_:String = null;
         var _loc2_:Node = null;
         if(this.m_parents)
         {
            for(_loc1_ in this.m_lines)
            {
               _loc2_ = this.getParent(_loc1_);
               this.enableLine(this.m_lines[_loc1_],_loc2_.isDone());
            }
         }
      }
      
      private function enableLine(param1:MovieClip, param2:Boolean) : void
      {
         var _loc3_:int = int(this.m_xml.@lineFrame);
         param1.gotoAndStop(param2 ? _loc3_ : 1);
      }
      
      private function getParent(param1:String) : Node
      {
         var _loc2_:Node = null;
         for each(_loc2_ in this.m_parents)
         {
            if(_loc2_.m_xml.@screenId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function isDone() : Boolean
      {
         return ZGlobal.player.didCompleteQuest(this.questName);
      }
      
      protected function isActive() : Boolean
      {
         var _loc1_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         return _loc1_.isQuestActive(this.questName);
      }
      
      protected function isAvailable() : Boolean
      {
         var _loc3_:QuestTree = null;
         var _loc4_:Node = null;
         if(!this.m_parents)
         {
            return true;
         }
         if(this.isActive())
         {
            return true;
         }
         var _loc1_:Node = this.m_parents[0];
         var _loc2_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         if(_loc1_.m_state == STATE_DONE || _loc2_.allParentQuestsComplete(this.questName))
         {
            _loc3_ = ZGlobal.player.questTrees.getQuestTree(this.m_treeId);
            if(Boolean(_loc3_) && !_loc3_.shouldAutoReset())
            {
               for each(_loc4_ in _loc1_.m_sequels)
               {
                  if(_loc4_ != this && (_loc4_.isActive() || _loc4_.isDone()))
                  {
                     return false;
                  }
               }
            }
            return true;
         }
         return false;
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         if(this.m_continueBtn)
         {
            this.m_continueBtn.dispose();
            this.m_continueBtn = null;
         }
         if(this.m_state == STATE_AVAILABLE)
         {
            this.m_clip.parent.setChildIndex(this.m_clip,this.m_clip.parent.numChildren - 1);
            this.m_clip.card_mc.gotoAndPlay("_active");
            this.initFlyout();
         }
      }
      
      protected function initFlyout() : void
      {
         var _loc1_:ZGameQuest = null;
         if(!this.m_flyoutInitialised)
         {
            this.m_flyoutInitialised = true;
            this.m_button = new ZGameButton(this.m_clip.card_mc.flyout_mc.green_bt,this.onAccept);
            this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
            _loc1_ = QuestSettingsInit.getInstance().getItemByName(this.questName) as ZGameQuest;
            if(_loc1_)
            {
               if(_loc1_.hideRewards)
               {
                  this.hideAllRewards();
                  ZGameUtils.showIfExists(this.m_clip.card_mc.flyout_mc.mystery_mc);
               }
               else
               {
                  ZGameUtils.hideIfExists(this.m_clip.card_mc.flyout_mc.mystery_mc);
                  this.addRewardIcons(_loc1_);
               }
               TextFieldUtil.compactTextField(this.m_clip.card_mc.flyout_mc.header_tf,ZGameUtils.ZlocTP("QuestTrees",_loc1_.title),{
                  "maxLines":1,
                  "fontSize":16
               });
            }
         }
         if(this.isActive())
         {
            this.m_button.text = ZGameUtils.ZlocT("Dialogs","Continue");
         }
         else
         {
            this.m_button.text = ZGameUtils.ZlocT("Dialogs","Accept");
         }
      }
      
      protected function get flyout() : MovieClip
      {
         return this.m_clip.card_mc.flyout_mc;
      }
      
      protected function hideAllRewards() : void
      {
         this.flyout.rewards_even.visible = false;
         this.flyout.rewards_odd.visible = false;
         this.hideArray([this.flyout.rewards_even.rewardCard_01,this.flyout.rewards_even.rewardCard_02]);
         this.hideArray([this.flyout.rewards_odd.rewardCard_01,this.flyout.rewards_odd.rewardCard_02,this.flyout.rewards_odd.rewardCard_03]);
      }
      
      protected function hideArray(param1:Array) : void
      {
         var _loc2_:MovieClip = null;
         for each(_loc2_ in param1)
         {
            _loc2_.visible = false;
         }
      }
      
      protected function getRewardCards(param1:int) : Array
      {
         switch(param1)
         {
            case 1:
               this.flyout.rewards_odd.visible = true;
               return [this.flyout.rewards_odd.rewardCard_02];
            case 2:
               this.flyout.rewards_even.visible = true;
               return [this.flyout.rewards_even.rewardCard_01,this.flyout.rewards_even.rewardCard_02];
            case 3:
               this.flyout.rewards_odd.visible = true;
               return [this.flyout.rewards_odd.rewardCard_01,this.flyout.rewards_odd.rewardCard_02,this.flyout.rewards_odd.rewardCard_03];
            default:
               return null;
         }
      }
      
      protected function addRewardIcons(param1:ZGameQuest) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         var _loc4_:* = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:ImageLoader = null;
         this.hideAllRewards();
         param1 = QuestSettingsInit.getInstance().getItemByName(this.questName) as ZGameQuest;
         if(Boolean(param1) && !param1.hideRewards)
         {
            _loc2_ = param1.getRewardTextObject();
            _loc3_ = this.getRewardCards(_loc2_.rewardIcons.length);
            _loc4_ = 0;
            for each(_loc5_ in _loc3_)
            {
               _loc5_.visible = true;
               _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc2_.rewardIcons[_loc4_],_loc5_.icon);
               _loc6_.smooth = true;
               TextFieldUtil.processTextField(_loc5_.value_tf,ZGameUtils.ZlocT("QuestTrees","RewardAmount",{"amount":_loc2_.rewardPairs[_loc4_++].count}));
            }
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         this.updateState();
      }
      
      protected function onAccept(param1:MouseEvent) : void
      {
         if(!ZGameQuestManager.instance.isQuestActive(this.questName,true))
         {
            ZGlobal.player.questTrees.startQuest(this.questName);
         }
         this.m_questPopup = this.createQuestDetailsPopup(this.questName);
         this.m_questPopup.addEventListener(ZGamePopUp.CLOSED,this.onPopupClosed);
         PopupManager.instance.push(this.m_questPopup);
      }
      
      protected function onPopupClosed(param1:Event) : void
      {
         this.m_questPopup = null;
      }
      
      private function onClientQuestActivated(param1:WorldEvent) : void
      {
         this.updateState();
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         this.updateState();
      }
      
      protected function onRewardsGiven(param1:WorldEvent) : void
      {
         this.updateState();
      }
      
      protected function createQuestDetailsPopup(param1:String) : QuestDetailsPopup
      {
         return new QuestDetailsPopup(param1);
      }
   }
}

