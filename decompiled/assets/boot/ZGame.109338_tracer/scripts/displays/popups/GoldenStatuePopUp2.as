package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.QuestBuildableManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import transactions.TBuyQuestTask;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class GoldenStatuePopUp2 extends ZGamePopUp
   {
      
      public static const COMPLETE:String = "qbcompleted2";
      
      public static const QUEST_ID:String = "QB004";
      
      private var m_questActive:Boolean = false;
      
      private var m_initialised:Boolean = false;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var manager:ZGameQuestManager;
      
      protected var quest:ZGameQuest;
      
      protected var textObj:Object;
      
      protected var tasks:Array;
      
      private var m_buyPopup:GenericPopup;
      
      protected var m_dialogButtons:Array = null;
      
      public function GoldenStatuePopUp2(param1:EventDispatcher)
      {
         this.m_eventDispatcher = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_QuestBuildable.swf"));
      }
      
      public static function display(param1:EventDispatcher) : void
      {
         WindowManager.instance.push(new GoldenStatuePopUp2(param1));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      private function get screen() : MovieClip
      {
         return m_window.quest4_mc;
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function setupWindow() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(m_window) && !this.m_initialised)
         {
            m_window.crew_mc.visible = false;
            m_window.quest2_mc.visible = false;
            m_window.quest3_mc.visible = false;
            m_window.quest4_mc.visible = true;
            this.m_questActive = ZGameQuestManager.instance.getQuestProgressByName(QUEST_ID) != null && !ZGlobal.player.didCompleteQuest(QUEST_ID);
            this.initDialog();
            _loc1_ = this.x;
            _loc2_ = this.y;
            centerWithinStage(Zlab.mainStage);
            if(this.x < 0 || this.y < 0)
            {
               this.x = _loc1_;
               this.y = _loc2_;
            }
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:ZGameButton = null;
         var _loc9_:Object = null;
         var _loc10_:ZGameButton = null;
         var _loc11_:String = null;
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.accept_bt.visible = false;
         this.manager = QuestManager.getInstance() as ZGameQuestManager;
         this.quest = ZGameQuest(QuestSettingsInit.getInstance().getItemByName(QUEST_ID));
         this.textObj = new Object();
         this.quest.getTextObject(this.textObj,this.quest.createTasks());
         this.manager.addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
         this.manager.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q4_Title"));
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q4_Desc_1"));
         TextFieldUtil.compactTextField(this.screen.accept_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q4_Button_2"));
         TextFieldUtil.compactTextField(this.screen.itemName_tf,(ZGlobal.gameSettings.getItemByCode("B874",GameItem) as GameItem).getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         if(this.m_questActive)
         {
            _loc3_ = this.manager.getQuestTasks(QUEST_ID);
            this.m_dialogButtons = new Array();
            _loc4_ = String(0);
            _loc5_ = Boolean(this.textObj.taskComplete[0]);
            _loc6_ = !_loc5_ && Boolean(this.textObj.taskBuyable[0]);
            _loc7_ = !_loc5_ && Boolean(this.textObj.taskFeeds[0]);
            TextFieldUtil.compactTextField(this.screen.count_tf,this.textObj.taskProgress[0]);
            ZGameTask.applyDiscountText(this.screen.buy_bt,0);
            this.screen.ask_bt.visible = _loc7_;
            if(_loc6_)
            {
               _loc8_ = new ZGameButton(this.screen.buy_bt,this.onBuy);
               _loc9_ = _loc3_[0].getDynamicSkipCost();
               ZGameTask.applyDiscountText(this.screen.buy_bt,_loc9_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_DISCOUNT]);
               _loc8_.text = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc9_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
               _loc8_.buttonValue = _loc4_;
               this.m_dialogButtons.push({
                  "taskIndex":0,
                  "button":_loc8_
               });
            }
            if(_loc7_)
            {
               _loc10_ = new ZGameButton(this.screen.ask_bt,this.onFeed);
               _loc11_ = ZGameUtils.ZlocTP("Feeds",this.textObj.taskFeeds[0].button);
               _loc10_.compactText(_loc11_,{
                  "maxLines":1,
                  "minScale":0.4,
                  "onFail":"return"
               });
               _loc10_.buttonValue = _loc4_;
               this.m_dialogButtons.push({
                  "taskIndex":0,
                  "button":_loc10_
               });
            }
            if(_loc5_)
            {
               this.screen.ask_bt.visible = false;
               this.screen.buy_bt.visible = false;
            }
         }
         else
         {
            this.screen.ask_bt.visible = false;
            this.screen.buy_bt.visible = false;
            this.screen.count_tf.visible = false;
         }
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(this.textObj.taskIcons[0]),this.screen.icon);
         _loc1_.smooth = true;
         (this.screen.generic_tf as TextField).height = 50;
         TextFieldUtil.compactTextField(this.screen.generic_tf,this.textObj.taskText[0],{"minScale":0.7});
         var _loc2_:ImageLoader = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode(QuestBuildableManager.GOLDEN_STATUE,GameItem) as GameItem).getCachedImage("screenicon").url,this.screen.bigIcon);
         _loc2_.smooth = true;
      }
      
      private function onNextClicked(param1:MouseEvent) : void
      {
         this.m_eventDispatcher.dispatchEvent(new Event(COMPLETE));
         this.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:Object = null;
         super.deinitDialog();
         this.m_initialised = false;
         if(this.manager != null)
         {
            this.manager.removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress);
            this.manager.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         }
         if(this.m_questActive)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.QUEST_POPUP_CONTINUE,QUEST_ID));
            for each(_loc1_ in this.m_dialogButtons)
            {
               if(Boolean(_loc1_) && _loc1_.button != null)
               {
                  _loc1_.button.dispose();
               }
            }
            this.m_dialogButtons = null;
         }
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         this.screen.ask_bt.visible = false;
         this.screen.buy_bt.visible = false;
         this.screen.count_tf.visible = false;
         this.close();
      }
      
      protected function onQuestProgress(param1:WorldEvent) : void
      {
         this.quest.getTextObject(this.textObj,this.quest.createTasks());
         TextFieldUtil.compactTextField(this.screen.count_tf,this.textObj.taskProgress[0]);
         if(this.textObj.taskComplete[0])
         {
            this.clearButtonsForTask(0);
            this.screen.buy_bt.visible = false;
            this.screen.ask_bt.visible = false;
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.deinitDialog();
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
      
      private function clearButtonsForTask(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.m_dialogButtons)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_dialogButtons.length)
            {
               _loc3_ = this.m_dialogButtons[_loc2_];
               if(_loc3_.taskIndex == param1)
               {
                  if(_loc3_.button)
                  {
                     _loc3_.button.dispose();
                     _loc3_.button = null;
                  }
                  this.m_dialogButtons.splice(_loc2_,1);
               }
               else
               {
                  _loc2_++;
               }
            }
         }
      }
      
      protected function onFeed(param1:MouseEvent) : void
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
      
      protected function onBuy(param1:MouseEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         var _loc2_:String = param1.currentTarget.buttonValue;
         var _loc3_:int = int(_loc2_);
         var _loc4_:Array = this.manager.getQuestTasks(QUEST_ID);
         if(_loc3_ >= 0 && _loc3_ < _loc4_.length)
         {
            _loc5_ = int(_loc4_[_loc3_].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            if(ZGlobal.player.canBuyCash(_loc5_,true,"",false))
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc5_))
               {
                  _loc6_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc5_));
                  _loc7_ = new Array("EmpirePointsConfirm","","","");
                  this.m_buyPopup = GenericPopup2B.NewYesNo(_loc6_,null,this.onBuyConfirmed,_loc7_);
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
         var _loc3_:int = 0;
         var _loc4_:TBuyQuestTask = null;
         var _loc2_:Array = this.manager.getQuestTasks(QUEST_ID);
         if(param1 < _loc2_.length)
         {
            _loc3_ = int(_loc2_[param1].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            ZGlobal.player.cash -= _loc3_;
            _loc2_[param1].buyCompletion();
            _loc4_ = new TBuyQuestTask(QUEST_ID,param1,_loc3_);
            TransactionManager.addTransaction(_loc4_,true);
            _loc4_ = null;
         }
      }
   }
}

