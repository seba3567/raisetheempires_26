package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
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
   
   public class GoldenStatuePopUp1 extends ZGamePopUp
   {
      
      public static const COMPLETE:String = "qbcompleted1";
      
      public static const QUEST_ID:String = "QB003";
      
      private var m_questActive:Boolean = false;
      
      private var m_initialised:Boolean = false;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var manager:ZGameQuestManager;
      
      protected var quest:ZGameQuest;
      
      protected var textObj:Object;
      
      protected var tasks:Array;
      
      private var m_buyPopup:GenericPopup;
      
      protected var m_dialogButtons:Array = null;
      
      public function GoldenStatuePopUp1(param1:EventDispatcher)
      {
         this.m_eventDispatcher = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_QuestBuildable.swf"));
      }
      
      public static function display(param1:EventDispatcher) : void
      {
         WindowManager.instance.push(new GoldenStatuePopUp1(param1));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      private function get screen() : MovieClip
      {
         return m_window.quest2_mc;
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
            m_window.quest2_mc.visible = true;
            m_window.quest3_mc.visible = false;
            m_window.quest4_mc.visible = false;
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
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:ZGameButton = null;
         var _loc11_:Object = null;
         var _loc12_:ZGameButton = null;
         var _loc13_:String = null;
         var _loc14_:Array = null;
         var _loc15_:ZGameButton = null;
         var _loc16_:String = null;
         var _loc17_:Array = null;
         var _loc18_:ZGameButton = null;
         var _loc19_:ImageLoader = null;
         var _loc20_:int = 0;
         var _loc21_:ImageLoader = null;
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.accept_bt.visible = false;
         this.tasks = [this.screen.requirement1_mc,this.screen.requirement2_mc,this.screen.requirement3_mc];
         this.manager = QuestManager.getInstance() as ZGameQuestManager;
         this.quest = ZGameQuest(QuestSettingsInit.getInstance().getItemByName(QUEST_ID));
         this.textObj = new Object();
         this.quest.getTextObject(this.textObj,this.quest.createTasks());
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Quests","quest_QB003_title"));
         TextFieldUtil.compactTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q3_Desc_1"));
         TextFieldUtil.compactTextField(this.screen.accept_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q3_Button_1"));
         if(this.m_questActive)
         {
            this.manager.addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
            this.manager.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
            _loc1_ = this.manager.getQuestTasks(QUEST_ID);
            this.m_dialogButtons = new Array();
            _loc2_ = 0;
            for each(_loc3_ in this.textObj.taskText)
            {
               _loc4_ = String(_loc2_);
               _loc5_ = Boolean(this.textObj.taskComplete[_loc2_]);
               _loc6_ = !_loc5_ && Boolean(this.textObj.taskBuyable[_loc2_]);
               _loc7_ = !_loc5_ && Boolean(this.textObj.taskRequestable[_loc2_]);
               _loc8_ = !_loc5_ && Boolean(this.textObj.taskFeeds[_loc2_]);
               _loc9_ = !_loc5_ && Boolean(this.textObj.taskBattle[_loc2_]);
               (this.tasks[_loc2_].name_tf as TextField).height = 50;
               TextFieldUtil.compactTextField(this.tasks[_loc2_].name_tf,_loc3_,{"minScale":0.7});
               TextFieldUtil.compactTextField(this.tasks[_loc2_].progress_tf,this.textObj.taskProgress[_loc2_]);
               this.tasks[_loc2_].check_mc.visible = _loc5_;
               ZGameTask.applyDiscountText(this.tasks[_loc2_].accept_bt,0);
               this.tasks[_loc2_].ask_bt.visible = _loc7_ || _loc8_ || _loc9_;
               this.tasks[_loc2_].accept_bt.visible = _loc6_;
               if(_loc6_)
               {
                  _loc10_ = new ZGameButton(this.tasks[_loc2_].accept_bt,this.onBuy);
                  _loc11_ = _loc1_[_loc2_].getDynamicSkipCost();
                  ZGameTask.applyDiscountText(this.tasks[_loc2_].accept_bt,_loc11_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_DISCOUNT]);
                  _loc10_.text = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc11_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
                  _loc10_.buttonValue = _loc4_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc2_,
                     "button":_loc10_
                  });
               }
               if(_loc7_)
               {
                  _loc12_ = new ZGameButton(this.tasks[_loc2_].ask_bt,this.onRequest);
                  if(this.textObj.requestButtonText[_loc2_] == null)
                  {
                     _loc13_ = ZGameUtils.ZlocT("Dialogs","BuildingPartAskPartButton");
                  }
                  else
                  {
                     _loc14_ = this.textObj.requestButtonText[_loc2_].split(":");
                     _loc13_ = ZGameUtils.ZlocT(_loc14_[0],_loc14_[1]);
                  }
                  _loc12_.compactText(_loc13_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc12_.buttonValue = _loc4_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc2_,
                     "button":_loc12_
                  });
               }
               else if(_loc8_)
               {
                  _loc15_ = new ZGameButton(this.tasks[_loc2_].ask_bt,this.onFeed);
                  _loc16_ = ZGameUtils.ZlocTP("Feeds",this.textObj.taskFeeds[_loc2_].button);
                  _loc15_.compactText(_loc16_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc15_.buttonValue = _loc4_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc2_,
                     "button":_loc15_
                  });
               }
               else if(_loc9_)
               {
                  _loc17_ = this.textObj.taskBattle[_loc2_].button.split(":");
                  _loc18_ = new ZGameButton(this.tasks[_loc2_].ask_bt,this.onBattle);
                  _loc18_.text = ZGameUtils.ZlocT(_loc17_[0],_loc17_[1]);
                  _loc18_.buttonValue = _loc4_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc2_,
                     "button":_loc18_
                  });
                  BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleStart);
               }
               if(this.textObj.taskIcons[_loc2_].length > 0)
               {
                  _loc19_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(this.textObj.taskIcons[_loc2_]),this.tasks[_loc2_].icon_mc);
                  _loc19_.smooth = true;
               }
               else
               {
                  this.tasks[_loc2_].icon_mc.unload();
               }
               if(_loc5_)
               {
                  this.tasks[_loc2_].ask_bt.visible = false;
                  this.tasks[_loc2_].accept_bt.visible = false;
               }
               _loc2_++;
            }
         }
         else
         {
            _loc20_ = 0;
            while(_loc20_ < 3)
            {
               this.tasks[_loc20_].ask_bt.visible = false;
               this.tasks[_loc20_].accept_bt.visible = false;
               this.tasks[_loc20_].check_mc.visible = true;
               (this.tasks[_loc20_].name_tf as TextField).height = 50;
               TextFieldUtil.compactTextField(this.tasks[_loc20_].name_tf,this.textObj.taskText[_loc20_],{"minScale":0.7});
               _loc21_ = ImageLoaderFactory.CreateImageLoader(this.textObj.taskIcons[_loc20_],this.tasks[_loc20_].icon_mc);
               _loc21_.smooth = true;
               _loc20_++;
            }
         }
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
         if(this.m_questActive)
         {
            this.manager.removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress);
            this.manager.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleStart);
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
         this.close();
      }
      
      protected function onQuestProgress(param1:WorldEvent) : void
      {
         this.quest.getTextObject(this.textObj,this.quest.createTasks());
         var _loc2_:int = 0;
         while(_loc2_ < this.textObj.taskProgress.length)
         {
            TextFieldUtil.compactTextField(this.tasks[_loc2_].progress_tf,this.textObj.taskProgress[_loc2_]);
            if(this.textObj.taskComplete[_loc2_])
            {
               this.clearButtonsForTask(_loc2_);
               this.tasks[_loc2_].accept_bt.visible = false;
               this.tasks[_loc2_].ask_bt.visible = false;
               this.tasks[_loc2_].check_mc.visible = true;
            }
            _loc2_++;
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
      
      private function onBattleStart(param1:Event) : void
      {
         this.close();
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
      
      protected function onBattle(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         var _loc3_:Array = this.manager.getQuestTasks(QUEST_ID);
         var _loc4_:ZGameTask = _loc3_[_loc2_];
         GMBattle.createStaticBattleFromQuest({
            "id":QUEST_ID,
            "index":_loc2_,
            "quest":QUEST_ID,
            "allies":_loc4_.combatAllies
         },_loc4_.fleetName,null,_loc4_);
      }
      
      protected function onRequest(param1:MouseEvent) : void
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
               _loc7_ = ZGlobal.player.questTrees.isQuestTreeQuest(QUEST_ID) ? "mini_series" : "quest";
               _loc4_ += _loc6_.name + "&source=" + _loc7_ + "&quest=" + QUEST_ID + "&task=" + _loc3_;
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
               {
                  _loc8_ = new Array();
                  _loc8_["source"] = _loc7_;
                  _loc8_["quest"] = QUEST_ID;
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

