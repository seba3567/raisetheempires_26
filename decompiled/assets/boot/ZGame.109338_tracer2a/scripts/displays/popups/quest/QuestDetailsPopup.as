package displays.popups.quest
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.StrategicDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.requests.RequestAskPartsDialog;
   import displays.screens.requests.RequestNeighborDialog;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import transactions.TBuyItem;
   import transactions.TBuyQuestTask;
   import transactions.TSpend;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class QuestDetailsPopup extends QuestPopup
   {
      
      protected var m_dialogButtons:Array = null;
      
      private var m_buyPopup:GenericPopup;
      
      public function QuestDetailsPopup(param1:String)
      {
         super(param1,false);
      }
      
      protected function getTasks() : Array
      {
         var _loc1_:MovieClip = this.screen;
         return [_loc1_.requirement1_mc,_loc1_.requirement2_mc,_loc1_.requirement3_mc];
      }
      
      override protected function getAcceptButtonPackageAndLabel(param1:ZGameQuest) : Object
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         if(param1)
         {
            _loc2_ = param1.dialogAcceptButtonOverride;
            if(_loc2_)
            {
               _loc3_ = _loc2_.split(":");
               if(_loc3_.length == 2)
               {
                  return {
                     "pkg":_loc3_[0],
                     "label":_loc3_[1]
                  };
               }
            }
         }
         return super.getAcceptButtonPackageAndLabel(param1);
      }
      
      override protected function setUpQuestUI() : void
      {
         var _loc2_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
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
         var _loc21_:ZGameButton = null;
         var _loc22_:String = null;
         var _loc23_:ZGameButton = null;
         var _loc24_:String = null;
         var _loc25_:Array = null;
         var _loc26_:ZGameButton = null;
         var _loc27_:String = null;
         var _loc28_:Array = null;
         var _loc29_:MovieClip = null;
         var _loc30_:ZGameButton = null;
         var _loc31_:Array = null;
         var _loc32_:MovieClip = null;
         var _loc33_:ZGameButton = null;
         var _loc34_:ZGameButton = null;
         var _loc35_:int = 0;
         var _loc36_:int = 0;
         var _loc37_:ZGameButton = null;
         var _loc38_:String = null;
         var _loc39_:ZGameButton = null;
         var _loc40_:Array = null;
         var _loc41_:String = null;
         var _loc42_:ZGameButton = null;
         var _loc43_:Array = null;
         var _loc44_:String = null;
         var _loc45_:ZGameButton = null;
         var _loc46_:ImageLoader = null;
         if(null == textObj.taskText)
         {
            this.close();
            return;
         }
         super.setUpQuestUI();
         var _loc1_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         _loc1_.addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
         _loc1_.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
         _loc2_ = this.screen;
         _loc2_.visible = true;
         this.addTitleText(_loc2_);
         this.updateDate();
         if(_loc2_.title2_tf)
         {
            _loc2_.title2_tf.visible = false;
         }
         this.m_dialogButtons = new Array();
         var _loc3_:Array = this.getTasks();
         _loc4_ = 0;
         var _loc5_:Array = _loc1_.getQuestTasks(m_id);
         for each(_loc6_ in textObj.taskText)
         {
            if(_loc4_ < _loc3_.length)
            {
               _loc7_ = String(_loc4_);
               _loc8_ = Boolean(textObj.taskComplete[_loc4_]);
               _loc9_ = !_loc8_ && Boolean(textObj.taskBuyable[_loc4_]);
               _loc10_ = !_loc8_ && Boolean(textObj.taskRequestable[_loc4_]);
               _loc11_ = !_loc8_ && Boolean(textObj.taskFeeds[_loc4_]);
               _loc12_ = !_loc8_ && Boolean(textObj.taskBattle[_loc4_]);
               _loc13_ = !_loc8_ && Boolean(textObj.taskSurvivalBattle[_loc4_]);
               _loc14_ = !_loc8_ && Boolean(textObj.taskInvites[_loc4_]);
               _loc15_ = !_loc8_ && Boolean(textObj.taskSpendButton[_loc4_]);
               _loc16_ = !_loc8_ && Boolean(textObj.taskPan[_loc4_]);
               _loc17_ = !_loc8_ && Boolean(textObj.taskBuild[_loc4_]);
               _loc18_ = false;
               if(!_loc9_)
               {
                  _loc18_ = !_loc8_ && Boolean(textObj.taskItemBuyable[_loc4_]);
               }
               _loc3_[_loc4_].visible = true;
               (_loc3_[_loc4_].name_tf as TextField).height = 50;
               TextFieldUtil.compactTextField(_loc3_[_loc4_].name_tf,_loc6_,{"minScale":0.7});
               TextFieldUtil.compactTextField(_loc3_[_loc4_].progress_tf,textObj.taskProgress[_loc4_]);
               _loc3_[_loc4_].check_mc.visible = _loc8_;
               if(_loc3_[_loc4_].accept_bt2)
               {
                  if(Boolean(_loc3_[_loc4_].accept_bt) && _loc3_[_loc4_].accept_bt != _loc3_[_loc4_].accept_bt2)
                  {
                     _loc3_[_loc4_].accept_bt2.visible = _loc3_[_loc4_].accept_bt.visible;
                     _loc3_[_loc4_].accept_bt.parent.removeChild(_loc3_[_loc4_].accept_bt);
                     _loc3_[_loc4_]["accept_bt"] = _loc3_[_loc4_].accept_bt2;
                  }
               }
               ZGameTask.applyDiscountText(_loc3_[_loc4_].accept_bt,0);
               _loc3_[_loc4_].accept_bt.visible = _loc9_ || _loc18_;
               if(_loc3_[_loc4_].fight_bt)
               {
                  _loc3_[_loc4_].fight_bt.visible = _loc12_ || _loc15_ || _loc13_;
                  _loc3_[_loc4_].ask_bt.visible = _loc10_ || _loc11_ || _loc14_ || _loc16_ || _loc17_;
               }
               else
               {
                  _loc3_[_loc4_].ask_bt.visible = _loc10_ || _loc11_ || _loc12_ || _loc14_ || _loc16_ || _loc17_;
               }
               if(_loc9_)
               {
                  _loc19_ = new ZGameButton(_loc3_[_loc4_].accept_bt,this.onBuy);
                  _loc20_ = _loc5_[_loc4_].getDynamicSkipCost();
                  ZGameTask.applyDiscountText(_loc3_[_loc4_].accept_bt,_loc20_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_DISCOUNT]);
                  _loc19_.text = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc20_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
                  _loc19_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc19_
                  });
               }
               else if(_loc18_)
               {
                  _loc21_ = new ZGameButton(_loc3_[_loc4_].accept_bt,this.onBuyItem);
                  _loc22_ = ZGameUtils.ZlocT("Dialogs","BuildingPartBuyPartButton",{"amount":textObj.taskItemBuyAmountCash[_loc4_]});
                  _loc21_.compactText(_loc22_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc21_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc21_
                  });
               }
               if(_loc10_)
               {
                  _loc23_ = new ZGameButton(_loc3_[_loc4_].ask_bt,this.onRequest);
                  if(textObj.requestButtonText[_loc4_] == null)
                  {
                     _loc24_ = ZGameUtils.ZlocT("Dialogs","BuildingPartAskPartButton");
                  }
                  else
                  {
                     _loc25_ = textObj.requestButtonText[_loc4_].split(":");
                     _loc24_ = ZGameUtils.ZlocT(_loc25_[0],_loc25_[1]);
                  }
                  _loc23_.compactText(_loc24_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc23_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc23_
                  });
               }
               else if(_loc11_)
               {
                  _loc26_ = new ZGameButton(_loc3_[_loc4_].ask_bt,this.onFeed);
                  _loc27_ = ZGameUtils.ZlocTP("Feeds",textObj.taskFeeds[_loc4_].button);
                  _loc26_.compactText(_loc27_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc26_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc26_
                  });
               }
               else if(_loc12_)
               {
                  _loc28_ = textObj.taskBattle[_loc4_].button.split(":");
                  _loc29_ = _loc3_[_loc4_].fight_bt ? _loc3_[_loc4_].fight_bt : _loc3_[_loc4_].ask_bt;
                  _loc30_ = new ZGameButton(_loc29_,this.onBattle);
                  _loc30_.text = ZGameUtils.ZlocT(_loc28_[0],_loc28_[1]);
                  _loc30_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc30_
                  });
                  BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleStart);
               }
               else if(_loc13_)
               {
                  _loc31_ = textObj.taskSurvivalBattle[_loc4_].button.split(":");
                  _loc32_ = _loc3_[_loc4_].fight_bt ? _loc3_[_loc4_].fight_bt : _loc3_[_loc4_].ask_bt;
                  _loc32_.visible = true;
                  _loc33_ = new ZGameButton(_loc32_,this.onSurvivalBattle);
                  _loc33_.compactText(ZGameUtils.ZlocT(_loc31_[0],_loc31_[1]),{
                     "maxLines":1,
                     "minScale":0.4,
                     "fontSize":14,
                     "onFail":"return"
                  });
                  _loc33_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc33_
                  });
               }
               else if(_loc14_)
               {
                  _loc34_ = new ZGameButton(_loc3_[_loc4_].ask_bt,this.onInvite);
                  _loc34_.text = ZGameUtils.ZlocTP("Dialogs",textObj.taskInvites[_loc4_].button);
                  _loc34_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc34_
                  });
               }
               else if(_loc15_)
               {
                  _loc35_ = 0;
                  _loc36_ = parseInt(textObj.taskTotal[_loc4_]);
                  _loc37_ = new ZGameButton(_loc3_[_loc4_].fight_bt,this.onSpend);
                  _loc38_ = ZGameUtils.ZlocTP("Dialogs",textObj.taskSpendButton[_loc4_].button);
                  if(_loc38_.indexOf("{total}") != -1)
                  {
                     _loc38_ = ZGameUtils.ZlocTP("Dialogs",textObj.taskSpendButton[_loc4_].button,{"total":_loc36_});
                  }
                  _loc37_.compactText(_loc38_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc37_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc37_
                  });
                  if(textObj.taskSpendButton[_loc4_].type == "item")
                  {
                     _loc35_ = ZGlobal.player.getNumberOfInventoryItems(textObj.taskItem[_loc4_]);
                  }
                  else
                  {
                     _loc35_ = int(ZGlobal.player.resources.resourceAmounts[WorldResourceManager.instance.resourceFromRareResource(textObj.taskSpendButton[_loc4_].type)]);
                  }
                  if(_loc35_ < _loc36_)
                  {
                     _loc37_.disableWithTooltip(ZGameUtils.ZlocTP("QuestTrees",textObj.taskSpendButton[_loc4_].tooltip,{
                        "num":_loc35_,
                        "total":_loc36_
                     }));
                  }
               }
               else if(_loc16_)
               {
                  _loc39_ = new ZGameButton(_loc3_[_loc4_].ask_bt,this.onPan);
                  _loc40_ = textObj.panButtonText[_loc4_].split(":");
                  _loc41_ = ZGameUtils.ZlocTP(_loc40_[0],_loc40_[1]);
                  _loc39_.compactText(_loc41_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc39_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc39_
                  });
               }
               else if(_loc17_)
               {
                  _loc42_ = new ZGameButton(_loc3_[_loc4_].ask_bt,this.onBuild);
                  _loc43_ = textObj.buildButtonText[_loc4_].split(":");
                  _loc44_ = ZGameUtils.ZlocTP(_loc43_[0],_loc43_[1]);
                  _loc42_.compactText(_loc44_,{
                     "maxLines":1,
                     "minScale":0.4,
                     "onFail":"return"
                  });
                  _loc42_.buttonValue = _loc7_;
                  this.m_dialogButtons.push({
                     "taskIndex":_loc4_,
                     "button":_loc42_
                  });
               }
               if(Boolean(_loc3_[_loc4_].hasOwnProperty("tooltip_mc")) && Boolean(_loc3_[_loc4_].hasOwnProperty("tooltipBtn")))
               {
                  _loc3_[_loc4_].tooltip_mc.visible = false;
                  if(textObj.taskHint != undefined && textObj.taskHint[_loc4_] != null)
                  {
                     TextFieldUtil.compactTextField(_loc3_[_loc4_].tooltip_mc.hint_tf,textObj.taskHint[_loc4_]);
                     _loc45_ = new ZGameButton(_loc3_[_loc4_].tooltipBtn,this.onHintShow,1.1,false,this.onHintHide,this.onHintShow);
                     _loc45_.compactText("?",null);
                     _loc45_.buttonValue = _loc7_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc4_,
                        "button":_loc45_
                     });
                  }
                  else
                  {
                     _loc3_[_loc4_].tooltipBtn.visible = false;
                  }
               }
               if(textObj.taskIcons[_loc4_].length > 0)
               {
                  _loc46_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(textObj.taskIcons[_loc4_]),_loc3_[_loc4_].icon_mc);
                  _loc46_.smooth = true;
               }
               else
               {
                  _loc3_[_loc4_].icon_mc.unload();
               }
            }
            _loc4_++;
         }
      }
      
      private function onHintShow(param1:Event) : void
      {
         var _loc2_:Array = this.getTasks();
         _loc2_[param1.currentTarget.buttonValue].tooltip_mc.visible = true;
      }
      
      private function onHintHide(param1:Event) : void
      {
         var _loc2_:Array = this.getTasks();
         _loc2_[param1.currentTarget.buttonValue].tooltip_mc.visible = false;
      }
      
      protected function addTitleText(param1:MovieClip) : void
      {
         var _loc2_:Object = {
            "minScale":0.7,
            "filter":"ignore"
         };
         if(param1.hasOwnProperty("hint_tf"))
         {
            TextFieldUtil.compactTextField(param1.hint_tf,textObj.hint,_loc2_);
         }
         if(param1.hasOwnProperty("desc_tf"))
         {
            TextFieldUtil.compactTextField(param1.desc_tf,textObj.desc,_loc2_);
         }
         if(param1.hasOwnProperty("hintTitle_tf"))
         {
            TextFieldUtil.compactTextField(param1.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"),_loc2_);
         }
      }
      
      protected function onBuyItem(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:int = int(textObj.taskItemBuyAmountCash[param1.currentTarget.buttonValue]);
         if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmAllPartsBuyMessage",_loc4_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,_loc3_,this.buyItemConfirmed);
               this.m_buyPopup.userData = {
                  "item":textObj.taskItem[param1.currentTarget.buttonValue],
                  "amount":textObj.taskItemBuyAmount[param1.currentTarget.buttonValue]
               };
               PopupManager.instance.push(this.m_buyPopup);
            }
            else
            {
               this.buyItem(textObj.taskItem[param1.currentTarget.buttonValue],textObj.taskItemBuyAmount[param1.currentTarget.buttonValue]);
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
      
      protected function updateDate() : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(_loc3_)
         {
            _loc1_ = _loc3_.hasDate;
            _loc2_ = _loc3_.hasLifeTime;
            if(_loc1_)
            {
               TextFieldUtil.processTextField(this.screen.limited_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionBanner"));
               _loc4_ = new Object();
               _loc5_ = ZGameTimeUtil.instance.getDateStatus(_loc4_,_loc3_.xml);
               if(_loc5_ == ZGameTimeUtil.DATE_STATUS_LATE)
               {
                  QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_COMPLETE,{"name":_loc3_.name}));
               }
               else
               {
                  TextFieldUtil.processTextField(this.screen.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionCountdown",{"time":_loc4_.string}));
                  this.startDateTimer();
               }
            }
            if(_loc2_)
            {
               _loc6_ = ZGameTimeUtil.instance.getClockString(_loc3_.getTimeRemaining());
               TextFieldUtil.processTextField(this.screen.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionCountdown",{"time":_loc6_}));
               this.startDateTimer();
            }
         }
         if(this.screen.limited_tf)
         {
            this.screen.daysLeft_tf.visible = _loc1_ || _loc2_;
            this.screen.limited_tf.visible = _loc1_;
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
      
      override protected function get screen() : MovieClip
      {
         return m_window;
      }
      
      override protected function getTextObject(param1:String) : Object
      {
         return (QuestManager.getInstance() as ZGameQuestManager).getTextObject(param1);
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         if(id == param1.eventData.name)
         {
            this.close();
         }
      }
      
      protected function onQuestProgress(param1:WorldEvent) : void
      {
         textObj = this.getTextObject(id);
         var _loc2_:Array = this.getTasks();
         var _loc3_:int = Math.min(textObj.taskProgress.length,_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            TextFieldUtil.compactTextField(_loc2_[_loc4_].progress_tf,textObj.taskProgress[_loc4_]);
            if(textObj.taskComplete[_loc4_])
            {
               this.clearButtonsForTask(_loc4_);
               _loc2_[_loc4_].accept_bt.visible = false;
               _loc2_[_loc4_].ask_bt.visible = false;
               _loc2_[_loc4_].check_mc.visible = true;
               if(_loc2_[_loc4_].fight_bt)
               {
                  _loc2_[_loc4_].fight_bt.visible = false;
               }
            }
            _loc4_++;
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc2_:Object = null;
         super.deinitDialog();
         this.stopDateTimer();
         var _loc1_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         _loc1_.removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress);
         _loc1_.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleStart);
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.QUEST_POPUP_CONTINUE,id));
         for each(_loc2_ in this.m_dialogButtons)
         {
            if(Boolean(_loc2_) && _loc2_.button != null)
            {
               _loc2_.button.dispose();
            }
         }
         this.m_dialogButtons = null;
      }
      
      protected function onPan(param1:MouseEvent) : void
      {
         this.close();
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         var _loc3_:IEntity = ZGameUtils.getBuildingByCode(textObj.taskPan[_loc2_]);
         if(!_loc3_)
         {
            Logger.print(this,"Warning, Pan Item data incorrect or does not exist in task Text Object! #");
            return;
         }
         var _loc4_:AutoActionPanToEntity = new AutoActionPanToEntity();
         _loc4_.data = {"target":_loc3_};
         _loc4_.startAction();
      }
      
      protected function onBuild(param1:MouseEvent) : void
      {
         this.close();
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         var _loc3_:Array = textObj.taskBuild[_loc2_].split(",");
         this.showStore(_loc3_[0],_loc3_[1],_loc3_[2]);
      }
      
      private function showStore(param1:String, param2:String = null, param3:String = null) : void
      {
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.DISPLAYING_LEADERBOARD_SCREEN));
         var _loc4_:Object = {
            "tab":param1,
            "genus":param3
         };
         if(param2.length > 1)
         {
            _loc4_.focusGameItemCode = param2;
         }
         UI.instance.displayStoreDialog(_loc4_);
      }
      
      protected function onFeed(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:GameItem = null;
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         if(Boolean(textObj.taskFeeds) && Boolean(_loc2_ >= 0) && _loc2_ < textObj.taskFeeds.length)
         {
            _loc3_ = textObj.taskFeeds[_loc2_];
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
         var _loc3_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc4_:Array = _loc3_.getQuestTasks(id);
         var _loc5_:ZGameTask = _loc4_[_loc2_];
         GMBattle.createStaticBattleFromQuest({
            "id":id,
            "index":_loc2_,
            "quest":id,
            "allies":_loc5_.combatAllies
         },_loc5_.fleetName,null,_loc5_);
      }
      
      private function onSurvivalBattle(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         var _loc3_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc4_:Array = _loc3_.getQuestTasks(id);
         var _loc5_:ZGameTask = _loc4_[_loc2_];
         QuestSurvivalModeManager.instance.createQuestSurvivalBattle({
            "id":id,
            "index":_loc2_,
            "quest":id,
            "allies":_loc5_.combatAllies
         },_loc5_.fleetName,null,_loc5_);
         this.close();
      }
      
      protected function onInvite(param1:MouseEvent) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST),0,false);
         }
         else
         {
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST,"nonapp",null,null,true);
         }
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
         if(_loc3_ >= 0 && _loc3_ < textObj.taskRequestAction.length && _loc3_ < textObj.taskItem.length)
         {
            _loc4_ = textObj.taskRequestAction[_loc3_];
            _loc5_ = textObj.taskItem[_loc3_];
            if(_loc5_ != null && _loc5_.length > 0)
            {
               _loc6_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem));
               if(WindowManager.isFullScreen())
               {
                  WindowManager.toggleFullScreen();
               }
               _loc7_ = ZGlobal.player.questTrees.isQuestTreeQuest(id) ? "mini_series" : "quest";
               _loc4_ += _loc6_.name + "&source=" + _loc7_ + "&quest=" + id + "&task=" + _loc3_;
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
               {
                  _loc8_ = new Array();
                  _loc8_["source"] = _loc7_;
                  _loc8_["quest"] = id;
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
         if(_loc3_ >= 0 && _loc3_ < textObj.taskItem.length)
         {
            _loc5_ = null;
            _loc6_ = textObj.taskSpendButton[_loc3_].type;
            if(_loc6_ == "item")
            {
               _loc5_ = textObj.taskItem[_loc3_];
               if(_loc5_)
               {
                  _loc4_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem));
                  if(_loc4_)
                  {
                     ZGlobal.player.removeInventoryItem(_loc4_.code,textObj.taskTotal[_loc3_]);
                  }
               }
            }
            else
            {
               ZGlobal.player.resources.updateResourceAmount(WorldResourceManager.instance.resourceFromRareResource(textObj.taskSpendButton[_loc3_].type),-textObj.taskTotal[_loc3_]);
            }
            if(_loc6_ != null)
            {
               TransactionManager.addTransaction(new TSpend(_loc6_,_loc5_,textObj.taskTotal[_loc3_]));
               _loc7_ = 0;
               while(_loc7_ < this.m_dialogButtons.length)
               {
                  if(this.m_dialogButtons[_loc7_].taskIndex == _loc3_)
                  {
                     this.m_dialogButtons[_loc7_].button.disable();
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
      
      protected function onBuy(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         var _loc2_:String = param1.currentTarget.buttonValue;
         var _loc3_:int = int(_loc2_);
         var _loc4_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         var _loc5_:Array = _loc4_.getQuestTasks(m_id);
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
         var _loc3_:Array = _loc2_.getQuestTasks(m_id);
         if(param1 < _loc3_.length)
         {
            _loc4_ = int(_loc3_[param1].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            ZGlobal.player.cash -= _loc4_;
            _loc3_[param1].buyCompletion();
            _loc5_ = new TBuyQuestTask(id,param1,_loc4_);
            TransactionManager.addTransaction(_loc5_,true);
            _loc5_ = null;
         }
      }
      
      override protected function onAcceptClicked() : void
      {
         super.onAcceptClicked();
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(Boolean(_loc1_) && Boolean(_loc1_.onDialogClosedShowInviteTabView))
         {
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST,_loc1_.onDialogClosedShowInviteTabView,null,null,true);
         }
      }
      
      override protected function shouldShowAcceptButton() : Boolean
      {
         return !m_isQuestTree;
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc3_:GameItem = null;
         this.closeBuyConfirmation();
         super.close();
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(_loc2_)
         {
            if(Boolean(_loc2_.placeObjectOnQuestDialogClosed) && ZGlobal.isHome())
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.placeObjectOnQuestDialogClosed,GameItem) as GameItem;
               if(_loc3_)
               {
                  if(ZGlobal.player.getNumberOfInventoryItems(_loc2_.placeObjectOnQuestDialogClosed) > 0)
                  {
                     GameModeManager.instance.addGameMode(new GMObjectPlace(_loc3_.name,MarketEvent.SOURCE_INVENTORY,true));
                  }
               }
            }
         }
         if(Boolean(_loc2_) && (_loc2_.firstArmyResearchQuest || _loc2_.firstNavyResearchQuest || _loc2_.firstAirResearchQuest))
         {
            ZGlobal.player.setSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG);
         }
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
      
      override protected function getWindowClass(param1:SWFResource) : Class
      {
         var _loc2_:uint = 1;
         if(textObj.taskText)
         {
            _loc2_ = uint(textObj.taskText.length);
         }
         switch(_loc2_)
         {
            case 1:
               return param1.getAssetClass("quest01_mc");
            case 2:
               return param1.getAssetClass("quest02_mc");
            case 3:
               return param1.getAssetClass("quest03_mc");
            default:
               Logger.error(this,"getWindowClass","no window class for " + _loc2_ + " tasks in quest " + m_id);
               return null;
         }
      }
      
      private function onBattleStart(param1:Event) : void
      {
         this.close();
      }
   }
}

