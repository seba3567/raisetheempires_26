package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.WorldGamesDialogState;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import core.ui.ZGameHoverButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.quest.WorldGamesQuestDetails;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestAskPartsDialog;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import transactions.TBuyItem;
   import transactions.TBuyQuestTask;
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
   
   public class WorldGamesPopUp extends ZGamePopUp
   {
      
      private static var ACTIVESTATE:int = 0;
      
      public static const EXCHANGEBOMBER:String = "exchangebomber";
      
      public static const EXCHANGETANK:String = "exchangetank";
      
      public static const EXCHANGESUBMARINE:String = "exchangesubmarine";
      
      public static const DUMMYTXN:String = "dummytxn";
      
      public static const GIFTBUILDING:String = "giftbuilding";
      
      public static const QUEST_PROGRESS:String = "wquestprogress";
      
      public static const QUEST_COMPLETE:String = "wquestcomplete";
      
      public static const WORLDGAMES_GOLDMEDAL:String = "WGM";
      
      public static const BUILDING_CODE:String = "WGS1";
      
      private var m_initialised:Boolean = false;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var gbt_btn:ZGameButton;
      
      protected var ghb_btn:ZGameButton;
      
      protected var gvs_btn:ZGameButton;
      
      protected var ok_btn1:ZGameButton;
      
      protected var ok_btn2:ZGameButton;
      
      protected var questID:String;
      
      protected var dayText:String;
      
      protected var swfPath:String = "";
      
      protected var questDetails:WorldGamesQuestDetails;
      
      protected var tasks:Array;
      
      protected var m_dialogButtons:Array = null;
      
      private var m_buyPopup:GenericPopup;
      
      private var m_clock:MOTDCountdownClock = null;
      
      private var m_clock2:GenericCountdownClock = null;
      
      private var daysLeftForStadium:int;
      
      private var hoursLeftForQuest:int;
      
      private var minutesLeftForQuest:int;
      
      private var secondsLeftForQuest:int;
      
      protected var manager:ZGameQuestManager;
      
      protected var m_timer:Timer = null;
      
      public function WorldGamesPopUp(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null)
      {
         this.m_eventDispatcher = param1;
         if(timeRemaining / 86400 >= 2)
         {
            this.swfPath = "PU_WorldGamesMain.swf";
            if(timeRemaining / 86400 < 3)
            {
               if(ZGlobal.player.didCompleteQuest("QWG017"))
               {
                  this.swfPath = "PU_WorldGamesFinalDialog.swf";
               }
            }
         }
         else
         {
            this.swfPath = "PU_WorldGamesFinalDialog.swf";
         }
         super(ZGlobal.getAssetURL("assets/displays/dialogs/" + this.swfPath));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null) : void
      {
         if(timeRemaining > 0)
         {
            WindowManager.instance.push(new WorldGamesPopUp(param1,param2,param3,param4,param5,param6));
         }
         else
         {
            param1.dispatchEvent(new Event(GIFTBUILDING));
         }
      }
      
      public static function get timeRemaining() : int
      {
         var _loc1_:XML = ZGlobal.gameSettings.getXML().worldGames[0];
         var _loc2_:Object = {"stringNotUsed":true};
         var _loc3_:int = ZGameTimeUtil.instance.getDateStatus(_loc2_,_loc1_);
         if(_loc3_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return _loc2_.delta;
         }
         return 0;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.sreen_mc;
      }
      
      private function setupWindow() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.initState();
            this.m_initialised = true;
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
      
      protected function initState() : void
      {
         if(timeRemaining / 86400 >= 2)
         {
            this.daysLeftForStadium = timeRemaining / 86400;
            switch(this.daysLeftForStadium)
            {
               case 2:
                  this.questID = "QWG017";
                  break;
               case 3:
                  this.questID = "QWG016";
                  break;
               case 4:
                  this.questID = "QWG015";
                  break;
               case 5:
                  this.questID = "QWG014";
                  break;
               case 6:
                  this.questID = "QWG013";
                  break;
               case 7:
                  this.questID = "QWG012";
                  break;
               case 8:
                  this.questID = "QWG011";
                  break;
               case 9:
                  this.questID = "QWG010";
                  break;
               case 10:
                  this.questID = "QWG009";
                  break;
               case 11:
                  this.questID = "QWG008";
                  break;
               case 12:
                  this.questID = "QWG007";
                  break;
               case 13:
                  this.questID = "QWG006";
                  break;
               case 14:
                  this.questID = "QWG005";
                  break;
               case 15:
                  this.questID = "QWG004";
                  break;
               case 16:
                  this.questID = "QWG003";
                  break;
               case 17:
                  this.questID = "QWG002";
                  break;
               case 18:
                  this.questID = "QWG001";
            }
            ACTIVESTATE = 0;
            this.dayText = "QWG_day" + Number(this.questID.substr(4,2)).toString();
            this.questDetails = new WorldGamesQuestDetails(this.questID);
            this.manager = QuestManager.getInstance() as ZGameQuestManager;
            if(ZGameQuestManager.instance.getQuestProgressByName(this.questID) != null && !ZGlobal.player.didCompleteQuest(this.questID))
            {
               ACTIVESTATE = 1;
            }
            if(timeRemaining / 86400 < 3 && ZGlobal.player.didCompleteQuest(this.questID))
            {
               ACTIVESTATE = 2;
            }
         }
         else
         {
            ACTIVESTATE = 2;
         }
      }
      
      override protected function initDialog() : void
      {
         var _loc4_:XML = null;
         var _loc5_:ZGameQuest = null;
         var _loc6_:XML = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
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
         var _loc21_:ZGameButton = null;
         var _loc22_:String = null;
         var _loc23_:ZGameButton = null;
         var _loc24_:String = null;
         var _loc25_:Array = null;
         var _loc26_:ZGameButton = null;
         var _loc27_:String = null;
         var _loc28_:Array = null;
         var _loc29_:ZGameButton = null;
         var _loc30_:ZGameButton = null;
         var _loc31_:ZGameButton = null;
         var _loc32_:ImageLoader = null;
         m_window.screen_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         TextFieldUtil.compactTextField(m_window.screen_mc.card0.unitName_tf,ZGameUtils.ZlocT("Items","Gold_Bull_Tank_menuName"));
         TextFieldUtil.compactTextField(m_window.screen_mc.card1.unitName_tf,ZGameUtils.ZlocT("Items","Golden_Varun_Submarine_menuName"));
         TextFieldUtil.compactTextField(m_window.screen_mc.card2.unitName_tf,ZGameUtils.ZlocT("Items","Golden_Horten_Bomber_menuName"));
         TextFieldUtil.compactTextField(m_window.screen_mc.card0.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","WGM_exchange"));
         TextFieldUtil.compactTextField(m_window.screen_mc.card1.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","WGM_exchange"));
         TextFieldUtil.compactTextField(m_window.screen_mc.card2.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","WGM_exchange"));
         TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("MessageOfTheDay","motd_WorldGames_Title"));
         TextFieldUtil.compactTextField(m_window.screen_mc.subtitle_tf,ZGameUtils.ZlocT("Dialogs","WGM_goldmedalcount",{"x":ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL)}));
         TextFieldUtil.compactTextField(m_window.screen_mc.time_tf,ZGameUtils.ZlocT("Dialogs","WGM_questtime"));
         if(ACTIVESTATE == 2)
         {
            if(timeRemaining / 86400 > 2.5)
            {
               this.daysLeftForStadium = 3;
            }
            else if(timeRemaining / 86400 > 1.5)
            {
               this.daysLeftForStadium = 2;
            }
            else if(timeRemaining / 86400 > 0.5)
            {
               this.daysLeftForStadium = 1;
            }
            else
            {
               this.daysLeftForStadium = 0;
            }
            TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Quests","QWG_hurry",{"x":this.daysLeftForStadium}));
            if(this.m_clock)
            {
               this.m_clock.dispose();
               this.m_clock = null;
            }
            _loc4_ = ZGlobal.gameSettings.getXML().worldGames[0];
            _loc4_.m_clock = new MOTDCountdownClock(m_window.screen_mc.clock_mc,_loc4_,true,false,false);
         }
         else
         {
            _loc5_ = QuestSettingsInit.getInstance().getItemByName(this.questID) as ZGameQuest;
            if(_loc5_)
            {
               if(this.m_clock)
               {
                  this.m_clock.dispose();
                  this.m_clock = null;
               }
               _loc6_ = _loc5_.xml;
               this.m_clock = new MOTDCountdownClock(m_window.screen_mc.clock_mc,_loc6_,true,false,true);
            }
            TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Quests","quest_QWG001_desc"));
            TextFieldUtil.compactTextField(m_window.screen_mc.today_tf,ZGameUtils.ZlocT("Quests",this.dayText));
            if(ACTIVESTATE == 1)
            {
               m_window.screen_mc.message_tf.visible = false;
               this.manager.addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
               this.manager.addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete,false,0,true);
               _loc7_ = this.manager.getQuestTasks(this.questID);
               this.m_dialogButtons = new Array();
               this.tasks = [m_window.screen_mc.requirement1_mc,m_window.screen_mc.requirement2_mc,m_window.screen_mc.requirement3_mc];
               _loc8_ = 0;
               for each(_loc9_ in this.questDetails.wtextObj.taskText)
               {
                  _loc10_ = String(_loc8_);
                  _loc11_ = Boolean(this.questDetails.wtextObj.taskComplete[_loc8_]);
                  _loc12_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskBuyable[_loc8_]);
                  _loc13_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskRequestable[_loc8_]);
                  _loc14_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskFeeds[_loc8_]);
                  _loc15_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskBattle[_loc8_]);
                  _loc16_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskInvites[_loc8_]);
                  _loc17_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskSpendButton[_loc8_]);
                  _loc18_ = false;
                  if(!_loc12_)
                  {
                     _loc18_ = !_loc11_ && Boolean(this.questDetails.wtextObj.taskItemBuyable[_loc8_]);
                  }
                  (this.tasks[_loc8_].name_tf as TextField).height = 50;
                  TextFieldUtil.compactTextField(this.tasks[_loc8_].name_tf,_loc9_,{"minScale":0.7});
                  TextFieldUtil.compactTextField(this.tasks[_loc8_].progress_tf,this.questDetails.wtextObj.taskProgress[_loc8_]);
                  this.tasks[_loc8_].check_mc.visible = _loc11_;
                  ZGameTask.applyDiscountText(this.tasks[_loc8_].skip_bt,0);
                  this.tasks[_loc8_].ask_bt.visible = _loc13_ || _loc14_ || _loc15_ || _loc16_;
                  if(_loc12_)
                  {
                     _loc19_ = new ZGameButton(this.tasks[_loc8_].skip_bt,this.onBuy);
                     _loc20_ = _loc7_[_loc8_].getDynamicSkipCost();
                     ZGameTask.applyDiscountText(this.tasks[_loc8_].skip_bt,_loc20_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_DISCOUNT]);
                     _loc19_.text = ZGameUtils.ZlocT("Dialogs","QuestTaskSkipButtonLabel",{"amount":_loc20_[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]});
                     _loc19_.buttonValue = _loc10_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc8_,
                        "button":_loc19_
                     });
                  }
                  else if(_loc18_)
                  {
                     _loc21_ = new ZGameButton(this.tasks[_loc8_].skip_bt,this.onBuyItem);
                     _loc22_ = ZGameUtils.ZlocT("Dialogs","BuildingPartBuyPartButton",{"amount":this.questDetails.wtextObj.taskItemBuyAmountCash[_loc8_]});
                     _loc21_.compactText(_loc22_,{
                        "maxLines":1,
                        "minScale":0.4,
                        "onFail":"return"
                     });
                     _loc21_.buttonValue = _loc10_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc8_,
                        "button":_loc21_
                     });
                  }
                  if(_loc13_)
                  {
                     _loc23_ = new ZGameButton(this.tasks[_loc8_].ask_bt,this.onRequest);
                     if(this.questDetails.wtextObj.requestButtonText[_loc8_] == null)
                     {
                        _loc24_ = ZGameUtils.ZlocT("Dialogs","BuildingPartAskPartButton");
                     }
                     else
                     {
                        _loc25_ = this.questDetails.wtextObj.requestButtonText[_loc8_].split(":");
                        _loc24_ = ZGameUtils.ZlocT(_loc25_[0],_loc25_[1]);
                     }
                     _loc23_.compactText(_loc24_,{
                        "maxLines":1,
                        "minScale":0.4,
                        "onFail":"return"
                     });
                     _loc23_.buttonValue = _loc10_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc8_,
                        "button":_loc23_
                     });
                  }
                  else if(_loc14_)
                  {
                     _loc26_ = new ZGameButton(this.tasks[_loc8_].ask_bt,this.onFeed);
                     _loc27_ = ZGameUtils.ZlocTP("Feeds",this.questDetails.wtextObj.taskFeeds[_loc8_].button);
                     _loc26_.compactText(_loc27_,{
                        "maxLines":1,
                        "minScale":0.4,
                        "onFail":"return"
                     });
                     _loc26_.buttonValue = _loc10_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc8_,
                        "button":_loc26_
                     });
                  }
                  else if(_loc15_)
                  {
                     _loc28_ = this.questDetails.wtextObj.taskBattle[_loc8_].button.split(":");
                     _loc29_ = new ZGameButton(this.tasks[_loc8_].ask_bt,this.onBattle);
                     _loc29_.text = ZGameUtils.ZlocT(_loc28_[0],_loc28_[1]);
                     _loc29_.buttonValue = _loc10_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc8_,
                        "button":_loc29_
                     });
                     BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleStart);
                  }
                  else if(_loc16_)
                  {
                     _loc30_ = new ZGameButton(this.tasks[_loc8_].ask_bt,this.onInvite);
                     _loc30_.text = ZGameUtils.ZlocTP("Dialogs",this.questDetails.wtextObj.taskInvites[_loc8_].button);
                     _loc30_.buttonValue = _loc10_;
                     this.m_dialogButtons.push({
                        "taskIndex":_loc8_,
                        "button":_loc30_
                     });
                  }
                  if(Boolean(this.tasks[_loc8_].hasOwnProperty("tooltip_mc")) && Boolean(this.tasks[_loc8_].hasOwnProperty("tooltipBtn")))
                  {
                     this.tasks[_loc8_].tooltip_mc.visible = false;
                     if(this.questDetails.wtextObj.taskHint != undefined && this.questDetails.wtextObj.taskHint[_loc8_] != null)
                     {
                        TextFieldUtil.compactTextField(this.tasks[_loc8_].tooltip_mc.hint_tf,this.questDetails.wtextObj.taskHint[_loc8_]);
                        _loc31_ = new ZGameHoverButton(this.tasks[_loc8_].tooltipBtn,this.onHintShow,1.1,false,this.onHintHide,this.onHintShow);
                        _loc31_.compactText("?",null);
                        _loc31_.buttonValue = _loc10_;
                        this.m_dialogButtons.push({
                           "taskIndex":_loc8_,
                           "button":_loc31_
                        });
                     }
                     else
                     {
                        this.tasks[_loc8_].tooltipBtn.visible = false;
                     }
                  }
                  if(this.questDetails.wtextObj.taskIcons[_loc8_].length > 0)
                  {
                     _loc32_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(this.questDetails.wtextObj.taskIcons[_loc8_]),this.tasks[_loc8_].icon_mc);
                     _loc32_.smooth = true;
                  }
                  else
                  {
                     this.tasks[_loc8_].icon_mc.unload();
                  }
                  if(_loc8_ != 0)
                  {
                     TextFieldUtil.compactTextField(this.tasks[_loc8_].footnote_tf,ZGameUtils.ZlocT("Quests","QWG_task_info"));
                  }
                  else
                  {
                     this.tasks[_loc8_].footnote_tf.visible = false;
                  }
                  if(_loc11_)
                  {
                     this.tasks[_loc8_].ask_bt.visible = false;
                     this.tasks[_loc8_].skip_bt.visible = false;
                  }
                  _loc8_++;
               }
            }
            else
            {
               m_window.screen_mc.message_tf.visible = true;
               m_window.screen_mc.requirement1_mc.visible = false;
               m_window.screen_mc.requirement2_mc.visible = false;
               m_window.screen_mc.requirement3_mc.visible = false;
               TextFieldUtil.compactTextField(m_window.screen_mc.message_tf,ZGameUtils.ZlocT("Quests","QWG_quest_completed"));
            }
         }
         ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked("assets/game/units/Units_Land_Icons.swf/Unit_Land_SF_BullTank_Gold_SW_icon.png"),m_window.screen_mc.card0.icon);
         ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked("assets/game/units/Units_Sea_Icons.swf/Unit_Sea_SF_VarunUUV2_Sub_01_Gold_SW_icon.png"),m_window.screen_mc.card1.icon);
         ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked("assets/game/units/Units_Air_Icons.swf/Unit_Air_HortenBomber_Gold_SW_icon.png"),m_window.screen_mc.card2.icon);
         var _loc1_:int = (ZGlobal.gameSettings.getItemByCode(WorldGamesDialogState.reward_golden_bull_tank,UnitItem) as UnitItem).getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(WorldGamesDialogState.reward_golden_bull_tank));
         TextFieldUtil.processTextField(m_window.screen_mc.card0.strength_mc.strength_tf,_loc1_.toString());
         this.resizeStrengthText(m_window.screen_mc.card0.strength_mc,_loc1_);
         m_window.screen_mc.card0.strength_mc.visible = true;
         var _loc2_:int = (ZGlobal.gameSettings.getItemByCode(WorldGamesDialogState.reward_golden_varun_submarine,UnitItem) as UnitItem).getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(WorldGamesDialogState.reward_golden_varun_submarine));
         TextFieldUtil.processTextField(m_window.screen_mc.card1.strength_mc.strength_tf,_loc2_.toString());
         this.resizeStrengthText(m_window.screen_mc.card1.strength_mc,_loc2_);
         m_window.screen_mc.card1.strength_mc.visible = true;
         var _loc3_:int = (ZGlobal.gameSettings.getItemByCode(WorldGamesDialogState.reward_golden_horten_bomber,UnitItem) as UnitItem).getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(WorldGamesDialogState.reward_golden_horten_bomber));
         TextFieldUtil.processTextField(m_window.screen_mc.card2.strength_mc.strength_tf,_loc3_.toString());
         this.resizeStrengthText(m_window.screen_mc.card2.strength_mc,_loc3_);
         m_window.screen_mc.card2.strength_mc.visible = true;
         this.gbt_btn = new ZGameButton(m_window.screen_mc.card0.buy_bt,this.ongbtClicked);
         this.gvs_btn = new ZGameButton(m_window.screen_mc.card1.buy_bt,this.ongvsClicked);
         this.ghb_btn = new ZGameButton(m_window.screen_mc.card2.buy_bt,this.onghbClicked);
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function resizeStrengthText(param1:MovieClip, param2:int) : void
      {
         var _loc3_:TextFormat = null;
         if(param2 >= 1000)
         {
            _loc3_ = new TextFormat();
            _loc3_.size = 12;
            param1.value_tf.setTextFormat(_loc3_);
         }
      }
      
      protected function onTimer(param1:Event) : void
      {
         if(timeRemaining <= 0)
         {
            this.m_eventDispatcher.dispatchEvent(new Event(GIFTBUILDING));
            this.close();
         }
         else if(timeRemaining % 86400 == 0)
         {
            if(timeRemaining / 86400 >= 2)
            {
               this.m_eventDispatcher.dispatchEvent(new Event(DUMMYTXN));
               this.close();
            }
            else
            {
               TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Quests","QWG_hurry",{"x":int(timeRemaining / 86400)}));
            }
         }
      }
      
      protected function onQuestComplete(param1:WorldEvent) : void
      {
         this.close();
      }
      
      protected function onQuestProgress(param1:WorldEvent) : void
      {
         this.questDetails = new WorldGamesQuestDetails(this.questID);
         var _loc2_:int = 0;
         while(_loc2_ < this.questDetails.wtextObj.taskProgress.length)
         {
            TextFieldUtil.compactTextField(this.tasks[_loc2_].progress_tf,this.questDetails.wtextObj.taskProgress[_loc2_]);
            if(this.questDetails.wtextObj.taskComplete[_loc2_])
            {
               this.clearButtonsForTask(_loc2_);
               this.tasks[_loc2_].skip_bt.visible = false;
               this.tasks[_loc2_].ask_bt.visible = false;
               this.tasks[_loc2_].check_mc.visible = true;
            }
            _loc2_++;
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:Object = null;
         super.deinitDialog();
         this.m_initialised = false;
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         if(ACTIVESTATE != 2)
         {
            this.questDetails = null;
            this.manager.removeEventListener(QUEST_PROGRESS,this.onQuestProgress);
            this.manager.removeEventListener(QUEST_COMPLETE,this.onQuestComplete);
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,this.onBattleStart);
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.QUEST_POPUP_CONTINUE,this.questID));
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
      
      private function ongbtClicked(param1:MouseEvent) : void
      {
         if(ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL) >= 5)
         {
            this.m_eventDispatcher.dispatchEvent(new Event(EXCHANGETANK));
            ZGlobal.player.removeInventoryItem(WORLDGAMES_GOLDMEDAL,5);
            TextFieldUtil.compactTextField(m_window.screen_mc.subtitle_tf,ZGameUtils.ZlocT("Dialogs","WGM_goldmedalcount",{"x":ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL)}));
         }
         else
         {
            PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_02",this.onSpeechClose),0,true,false);
         }
      }
      
      private function ongvsClicked(param1:MouseEvent) : void
      {
         if(ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL) >= 5)
         {
            this.m_eventDispatcher.dispatchEvent(new Event(EXCHANGESUBMARINE));
            ZGlobal.player.removeInventoryItem(WORLDGAMES_GOLDMEDAL,5);
            TextFieldUtil.compactTextField(m_window.screen_mc.subtitle_tf,ZGameUtils.ZlocT("Dialogs","WGM_goldmedalcount",{"x":ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL)}));
         }
         else
         {
            PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_02",this.onSpeechClose),0,true,false);
         }
      }
      
      private function onghbClicked(param1:MouseEvent) : void
      {
         if(ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL) >= 5)
         {
            this.m_eventDispatcher.dispatchEvent(new Event(EXCHANGEBOMBER));
            ZGlobal.player.removeInventoryItem(WORLDGAMES_GOLDMEDAL,5);
            TextFieldUtil.compactTextField(m_window.screen_mc.subtitle_tf,ZGameUtils.ZlocT("Dialogs","WGM_goldmedalcount",{"x":ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL)}));
         }
         else
         {
            PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_02",this.onSpeechClose),0,true,false);
         }
      }
      
      private function onok1Clicked(param1:MouseEvent) : void
      {
         this.m_eventDispatcher.dispatchEvent(new Event(GIFTBUILDING));
         this.close();
      }
      
      private function onok2Clicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onSpeechClose(param1:Event) : void
      {
      }
      
      private function onHintShow(param1:Event) : void
      {
         this.tasks[param1.currentTarget.buttonValue].tooltip_mc.visible = true;
      }
      
      private function onHintHide(param1:Event) : void
      {
         this.tasks[param1.currentTarget.buttonValue].tooltip_mc.visible = false;
      }
      
      protected function addTitleText(param1:MovieClip) : void
      {
         var _loc2_:Object = {
            "minScale":0.7,
            "filter":"ignore"
         };
         if(param1.hasOwnProperty("hint_tf"))
         {
            TextFieldUtil.compactTextField(param1.hint_tf,this.questDetails.wtextObj.hint,_loc2_);
         }
         if(param1.hasOwnProperty("desc_tf"))
         {
            TextFieldUtil.compactTextField(param1.desc_tf,this.questDetails.wtextObj.desc,_loc2_);
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
         var _loc2_:int = int(this.questDetails.wtextObj.taskItemBuyAmountCash[param1.currentTarget.buttonValue]);
         if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmAllPartsBuyMessage",_loc4_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,_loc3_,this.buyItemConfirmed);
               this.m_buyPopup.userData = {
                  "item":this.questDetails.wtextObj.taskItem[param1.currentTarget.buttonValue],
                  "amount":this.questDetails.wtextObj.taskItemBuyAmount[param1.currentTarget.buttonValue]
               };
               PopupManager.instance.push(this.m_buyPopup);
            }
            else
            {
               this.buyItem(this.questDetails.wtextObj.taskItem[param1.currentTarget.buttonValue],this.questDetails.wtextObj.taskItemBuyAmount[param1.currentTarget.buttonValue]);
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
      
      protected function onFeed(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:GameItem = null;
         var _loc2_:int = int(param1.currentTarget.buttonValue);
         if(Boolean(this.questDetails.wtextObj.taskFeeds) && Boolean(_loc2_ >= 0) && _loc2_ < this.questDetails.wtextObj.taskFeeds.length)
         {
            _loc3_ = this.questDetails.wtextObj.taskFeeds[_loc2_];
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
         var _loc3_:Array = this.manager.getQuestTasks(this.questID);
         var _loc4_:ZGameTask = _loc3_[_loc2_];
         GMBattle.createStaticBattleFromQuest({
            "id":this.questID,
            "index":_loc2_,
            "quest":this.questID,
            "allies":_loc4_.combatAllies
         },_loc4_.fleetName,null,_loc4_);
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
         if(_loc3_ >= 0 && _loc3_ < this.questDetails.wtextObj.taskRequestAction.length && _loc3_ < this.questDetails.wtextObj.taskItem.length)
         {
            _loc4_ = this.questDetails.wtextObj.taskRequestAction[_loc3_];
            _loc5_ = this.questDetails.wtextObj.taskItem[_loc3_];
            if(_loc5_ != null && _loc5_.length > 0)
            {
               _loc6_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem));
               if(WindowManager.isFullScreen())
               {
                  WindowManager.toggleFullScreen();
               }
               _loc7_ = ZGlobal.player.questTrees.isQuestTreeQuest(this.questID) ? "mini_series" : "quest";
               _loc4_ += _loc6_.name + "&source=" + _loc7_ + "&quest=" + this.questID + "&task=" + _loc3_;
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
               {
                  _loc8_ = new Array();
                  _loc8_["source"] = _loc7_;
                  _loc8_["quest"] = this.questID;
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
         var _loc4_:Array = this.manager.getQuestTasks(this.questID);
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
         var _loc2_:Array = this.manager.getQuestTasks(this.questID);
         if(param1 < _loc2_.length)
         {
            _loc3_ = int(_loc2_[param1].getDynamicSkipCost()[ZGameTask.DYNAMIC_DISCOUNT_OBJECT_COST]);
            ZGlobal.player.cash -= _loc3_;
            _loc2_[param1].buyCompletion();
            _loc4_ = new TBuyQuestTask(this.questID,param1,_loc3_);
            TransactionManager.addTransaction(_loc4_,true);
            _loc4_ = null;
         }
      }
      
      protected function onAcceptClicked() : void
      {
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.questID) as ZGameQuest;
         if(Boolean(_loc1_) && Boolean(_loc1_.onDialogClosedShowInviteTabView))
         {
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST,_loc1_.onDialogClosedShowInviteTabView,null,null,true);
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
   }
}

