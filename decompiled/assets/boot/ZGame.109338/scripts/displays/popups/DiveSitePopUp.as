package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.CrewRewardGatherOwnerPartial;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import transactions.TBuyQuestTask;
   import transactions.TQuestBuildable;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class DiveSitePopUp extends CrewRewardGatherOwnerPartial
   {
      
      public static const QUEST_ID:String = "QB001";
      
      public static const COMPLETE:String = "DiveSiteCompleted";
      
      public static const DIVETIME:String = "DiveTime";
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var manager:ZGameQuestManager;
      
      protected var quest:ZGameQuest;
      
      protected var textObj:Object;
      
      protected var m_buttons:Array = [];
      
      protected var m_dialogButtons:Array = null;
      
      private var m_buyPopup:GenericPopup;
      
      private var m_questActive:Boolean = ZGameQuestManager.instance.getQuestProgressByName(QUEST_ID) != null && !ZGlobal.player.didCompleteQuest(QUEST_ID);
      
      public function DiveSitePopUp(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array, param5:Object, param6:String, param7:String, param8:String, param9:String, param10:int, param11:String)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      override protected function get dialogHeight() : int
      {
         return 572;
      }
      
      override protected function get dialogWidth() : int
      {
         return 646;
      }
      
      override protected function getGridLayout(param1:int) : Point
      {
         return new Point(4,1);
      }
      
      override protected function onConfirmFinish() : void
      {
         TransactionManager.addTransaction(new TQuestBuildable(owner,TQuestBuildable.GIVE_STATUE));
         close();
      }
      
      protected function diveSiteClose(param1:Event = null) : void
      {
         this.deinitDialog();
         super.close();
      }
      
      override protected function updateConfirmButton() : void
      {
         var _loc1_:String = getButtonTextKey();
         var _loc2_:String = ZGameUtils.ZlocTP("Dialogs",_loc1_);
         m_confirmButton.compactText(_loc2_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         if(this.quest != null)
         {
            this.quest.getTextObject(this.textObj,this.quest.createTasks());
            if(canFinishBuilding())
            {
               if(!this.textObj.taskComplete[0])
               {
                  m_confirmButton.disable_visual(false);
               }
               else
               {
                  m_confirmButton.enable();
               }
            }
         }
      }
      
      override protected function initSlotCards(param1:Point, param2:Point) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Number = -20;
         var _loc4_:Number = 350;
         var _loc5_:int = 0;
         loop0:
         while(_loc5_ < param1.y)
         {
            _loc6_ = 0;
            while(true)
            {
               if(_loc6_ >= param1.x)
               {
                  _loc4_ += param2.y + CARD_SPACING_VERTICAL;
                  _loc3_ = 0;
                  _loc5_++;
                  continue loop0;
               }
               _loc7_ = _loc6_ + param1.x * _loc5_;
               m_slotCards[_loc7_].x = _loc3_;
               m_slotCards[_loc7_].y = _loc4_;
               _loc3_ += param2.x + 10;
               if(++_loc7_ >= m_slotCards.length)
               {
                  break;
               }
               _loc6_++;
            }
            return;
         }
      }
      
      override protected function setupText() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:ZGameButton = null;
         var _loc7_:Object = null;
         var _loc8_:ZGameButton = null;
         var _loc9_:String = null;
         var _loc10_:ImageLoader = null;
         var _loc11_:ImageLoader = null;
         this.manager = QuestManager.getInstance() as ZGameQuestManager;
         this.manager.addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
         this.manager.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
         this.quest = ZGameQuest(QuestSettingsInit.getInstance().getItemByName(QUEST_ID));
         this.textObj = new Object();
         this.quest.getTextObject(this.textObj,this.quest.createTasks());
         TextFieldUtil.compactTextField(m_mc.title_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q1_Title"));
         TextFieldUtil.compactTextField(m_mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q1_Desc_0"));
         TextFieldUtil.compactTextField(m_mc.subtitle_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q1_Desc_2"));
         if(this.m_questActive)
         {
            _loc1_ = this.manager.getQuestTasks(QUEST_ID);
            this.m_dialogButtons = new Array();
            _loc2_ = String(0);
            _loc3_ = Boolean(this.textObj.taskComplete[0]);
            _loc4_ = !_loc3_ && Boolean(this.textObj.taskFeeds[0]);
            _loc5_ = !_loc3_ && Boolean(this.textObj.taskBuyable[0]);
            ZGameTask.applyDiscountText(m_mc.requirement1_mc.accept_bt,0);
            m_mc.requirement1_mc.ask_bt.visible = _loc4_;
            (m_mc.requirement1_mc.name_tf as TextField).height = 50;
            TextFieldUtil.compactTextField(m_mc.requirement1_mc.name_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Q1_Desc_1"));
            TextFieldUtil.compactTextField(m_mc.requirement1_mc.progress_tf,this.textObj.taskProgress[0]);
            m_mc.requirement1_mc.check_mc.visible = this.textObj.taskComplete[0];
            m_mc.requirement1_mc.progress_tf.visible = !this.textObj.taskComplete[0];
            if(_loc5_)
            {
               _loc6_ = new ZGameButton(m_mc.requirement1_mc.accept_bt,this.onBuy);
               _loc7_ = _loc1_[0].getDynamicSkipCost();
               ZGameTask.applyDiscountText(m_mc.requirement1_mc.accept_bt,_loc7_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_DISCOUNT]);
               _loc6_.text = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc7_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
               _loc6_.buttonValue = _loc2_;
               this.m_dialogButtons.push({
                  "taskIndex":0,
                  "button":_loc6_
               });
            }
            if(_loc4_)
            {
               _loc8_ = new ZGameButton(m_mc.requirement1_mc.ask_bt,this.onFeed);
               _loc9_ = ZGameUtils.ZlocTP("Feeds",this.textObj.taskFeeds[0].button);
               _loc8_.compactText(_loc9_,{
                  "maxLines":1,
                  "minScale":0.4,
                  "onFail":"return"
               });
               _loc8_.buttonValue = _loc2_;
               this.m_dialogButtons.push({
                  "taskIndex":0,
                  "button":_loc8_
               });
            }
            if(this.textObj.taskIcons[0].length > 0)
            {
               _loc10_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(this.textObj.taskIcons[0]),m_mc.requirement1_mc.icon_mc);
               _loc10_.smooth = true;
            }
            else
            {
               m_mc.requirement1_mc.icon_mc.unload();
            }
            if(_loc3_)
            {
               m_mc.requirement1_mc.ask_bt.visible = false;
               m_mc.requirement1_mc.accept_bt.visible = false;
            }
            this.updateConfirmButton();
         }
         else
         {
            m_mc.requirement1_mc.ask_bt.visible = false;
            m_mc.requirement1_mc.accept_bt.visible = false;
            m_mc.requirement1_mc.check_mc.visible = true;
            m_mc.requirement1_mc.progress_tf.visible = false;
            _loc11_ = ImageLoaderFactory.CreateImageLoader("assets/game/quests/Quests_Icons_0.swf/DefendVsGround01_96.png",m_mc.requirement1_mc.icon_mc);
            _loc11_.smooth = true;
            (m_mc.requirement1_mc.name_tf as TextField).height = 50;
            TextFieldUtil.compactTextField(m_mc.requirement1_mc.name_tf,ZGameUtils.ZlocT("Quests","quest_QB001_task_02"),{"minScale":0.7});
         }
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         this.m_questActive = false;
         this.diveSiteClose();
      }
      
      protected function onQuestProgress(param1:WorldEvent) : void
      {
         this.quest.getTextObject(this.textObj,this.quest.createTasks());
         TextFieldUtil.compactTextField(m_mc.requirement1_mc.progress_tf,this.textObj.taskProgress[0]);
         if(this.textObj.taskComplete[0])
         {
            this.clearButtonsForTask(0);
            m_mc.requirement1_mc.accept_bt.visible = false;
            m_mc.requirement1_mc.ask_bt.visible = false;
            m_mc.requirement1_mc.check_mc.visible = true;
            m_mc.requirement1_mc.progress_tf.visible = false;
         }
         this.updateConfirmButton();
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
      
      override protected function deinitDialog() : void
      {
         if(this.manager != null)
         {
            this.manager.removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress);
            this.manager.removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         }
         super.deinitDialog();
      }
   }
}

