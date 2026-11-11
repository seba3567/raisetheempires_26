package core.ui.menuitem
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.MegaseriesManager;
   import core.managers.RUXManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.questTrees.QuestTree;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.AllianceQuestsDialog;
   import displays.popups.QuestRestartPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.megaseries.MegaseriesDetailsPopup;
   import displays.popups.quest.QuestDetailsPopup;
   import displays.popups.quest.QuestManagerPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.utils.Dictionary;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import rendering.rendering2d.MovieController;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TAcceptAllianceQuest;
   import transactions.TQuestMarkStarred;
   import transactions.TQuestNotificationSeen;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Constants;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class QuestButtonUIItem extends Sprite
   {
      
      public static const FOCUS_THIS:String = "QuestButtonUIItem.FOCUS_THIS";
      
      private static const ARROW_LT_MARGIN:int = 20;
      
      private static const ARROW_RT_MARGIN:int = 15;
      
      private static const ARROW_MIN_WIDTH:int = 120;
      
      private var m_questButton:new_task_arrow = null;
      
      public var m_quest:ZGameQuest = null;
      
      private var m_loader:ImageLoader = null;
      
      private var m_parent:DisplayObjectContainer = null;
      
      private var m_movieController:MovieController = null;
      
      private var m_glowFilter:GlowFilter = null;
      
      private var m_highlightFilter:GlowFilter = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_delay:Number = 0;
      
      private var m_introMode:Boolean = false;
      
      private var m_offScreen:Boolean = false;
      
      private var m_imageShowing:Boolean = false;
      
      private var m_fromInit:Boolean = false;
      
      private var m_questTimerID:uint = 0;
      
      private var m_remindersShown:Object = null;
      
      private var m_hoverInfo:QuestHoverInfo = null;
      
      public var btnHandle:DisplayObject = null;
      
      private var questBarV2:Boolean = true;
      
      private var unStarButton:ZGameButton;
      
      private var starButton:ZGameButton;
      
      private var superStarNotification:MovieClip = null;
      
      private var isStarred:Boolean = false;
      
      private var m_questBarV2:Boolean = true;
      
      private var m_questsWithNotifications:Dictionary = new Dictionary();
      
      public function QuestButtonUIItem(param1:Object, param2:DisplayObjectContainer, param3:uint, param4:uint, param5:Boolean, param6:MovieClip = null)
      {
         super();
         this.m_quest = QuestSettingsInit.getInstance().getItemByName(param1 as String) as ZGameQuest;
         this.m_parent = param2;
         this.m_fromInit = param5;
         buttonMode = true;
         this.m_questButton = new new_task_arrow();
         addChild(this.m_questButton);
         if(param6)
         {
            this.btnHandle = param6;
            param6.circle.addChild(this);
            this.unStarButton = new ZGameButton(param6.star_bt,this.onUnStar);
            this.starButton = new ZGameButton(param6.unstar_bt,this.onStar);
            this.unStarButton.hide();
            this.m_parent.addChild(param6);
         }
         else
         {
            this.btnHandle = this;
            this.m_parent.addChildAt(this,0);
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(this.m_quest.campaignName)
         {
            if(this.m_quest.campaignName == "camp002")
            {
               this.m_questButton.questIcon_campV2.visible = true;
            }
         }
         else
         {
            this.m_questButton.questIcon_campV2.visible = false;
         }
         this.m_questButton.timer_mc.visible = this.m_quest.shouldShowTimer;
         this.m_questButton.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,false);
         this.m_questButton.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,false);
         this.m_questButton.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,false);
         this.m_buttonSounds.addButton(this.m_questButton,ButtonSound.DEFAULT);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_RESTARTED,this.onQuestRestarted,false,0,true);
         if(ExperimentsManager.instance.getExperimentVariant("empire_quest_manager") > 1)
         {
            TutorialManager.instance.addEventListener(TutorialManager.TUTORIAL_COMPLETE,this.onTutorialComplete,false,0,true);
         }
         this.m_glowFilter = new GlowFilter(16777215,1,4,4,20);
         this.m_highlightFilter = new GlowFilter(Constants.COLOR_HIGHLIGHT,1,8,8,20);
         this.btnHandle.visible = false;
         var _loc7_:ZGameQuestManager = QuestManager.getInstance() as ZGameQuestManager;
         if(Boolean(this.m_quest.introIcon) && !ZGlobal.player.hasSeenSpeech(this.m_quest.introSpeech))
         {
            this.m_introMode = true;
            this.m_loader = ImageLoaderFactory.CreateImageLoader(_loc7_.getIntroButtonIconPath(this.m_quest.name),this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc,this.onImageLoaded,this.onImageFailed);
            if(this.m_loader)
            {
               this.m_loader.smooth = true;
            }
            if(this.m_quest.introTooltip)
            {
               Tooltip.subscribe(this.m_questButton,ZGameUtils.ZlocT("Quests",this.m_quest.introTooltip));
            }
         }
         else
         {
            this.m_loader = ImageLoaderFactory.CreateImageLoader(this.buttonURL,this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc,this.onImageLoaded,this.onImageFailed);
            if(this.m_loader)
            {
               this.m_loader.smooth = true;
            }
            if(!isQuestManagerActive())
            {
               Tooltip.subscribe(this.m_questButton,_loc7_.getTooltip(this.m_quest.name));
            }
         }
         if(this.m_quest.shouldShowTimer)
         {
            this.startQuestTimer();
         }
         this.m_questButton.goldStar_mc.visible = false;
         if(ZGameTimeUtil.instance.isLimitedEdition(this.m_quest.xml))
         {
            this.startQuestTimer();
         }
         this.setIndex(param3,param4,true);
         this.m_delay = param3 * 1;
         TutorialManager.instance.registerUIItem(this.m_questButton.task_arrow_mc,"QuestList");
         if(ExperimentsManager.instance.getExperimentVariant("empire_quest_manager") > 1)
         {
            this.m_hoverInfo = new QuestHoverInfo(this);
         }
         if(this.isQuestBar2())
         {
            this.superStarNotification = param6.superstar as MovieClip;
            this.hideStarNotificationIcon();
            if(ZGlobal.player.isNotifyQuest(this.m_quest.name))
            {
               this.showStarNotificationIcon();
            }
            this.isStarred = ZGlobal.player.isStarredQuest(this.m_quest.name);
            if(this.isStarred)
            {
               this.starButton.hide();
               this.unStarButton.show();
            }
            else
            {
               this.starButton.hide();
               this.unStarButton.hide();
               this.btnHandle.addEventListener(MouseEvent.MOUSE_OVER,this.onShowStarIcon);
               this.btnHandle.addEventListener(MouseEvent.MOUSE_OUT,this.onHideStarIcon);
            }
         }
      }
      
      public static function isQuestManagerActive() : Boolean
      {
         return true;
      }
      
      private function isQuestBar2() : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_V2) == ExperimentsManager.VARIANT_QUEST_BAR_V2_ON && ZGlobal.player.level >= QuestsUIItem.questUnlockLevel)
         {
            return true;
         }
         return false;
      }
      
      private function showStarNotificationIcon() : void
      {
         this.superStarNotification.visible = true;
      }
      
      public function hideStarNotificationIcon() : void
      {
         this.superStarNotification.visible = false;
      }
      
      private function onShowStarIcon(param1:MouseEvent) : void
      {
         if(!this.isStarred)
         {
            this.starButton.show();
         }
      }
      
      private function onHideStarIcon(param1:MouseEvent) : void
      {
         if(!this.isStarred)
         {
            this.starButton.hide();
         }
         else
         {
            this.btnHandle.removeEventListener(MouseEvent.MOUSE_OVER,this.onShowStarIcon);
            this.btnHandle.removeEventListener(MouseEvent.MOUSE_OUT,this.onHideStarIcon);
         }
      }
      
      private function onStar(param1:MouseEvent) : void
      {
         this.removeNotifyIconOnClick(this.id);
         var _loc2_:TQuestMarkStarred = new TQuestMarkStarred(this.id,true);
         TransactionManager.addTransaction(_loc2_);
         this.isStarred = true;
         this.starButton.hide();
         this.unStarButton.show();
         ZGlobal.player.doStarQuest(this.id);
      }
      
      private function onUnStar(param1:MouseEvent) : void
      {
         this.removeNotifyIconOnClick(this.id);
         var _loc2_:TQuestMarkStarred = new TQuestMarkStarred(this.id,false);
         TransactionManager.addTransaction(_loc2_);
         this.isStarred = false;
         this.btnHandle.addEventListener(MouseEvent.MOUSE_OVER,this.onShowStarIcon);
         this.btnHandle.addEventListener(MouseEvent.MOUSE_OUT,this.onHideStarIcon);
         this.starButton.show();
         this.unStarButton.hide();
         ZGlobal.player.doUnstarQuest(this.id);
      }
      
      private function get buttonURL() : String
      {
         var _loc1_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_quest.name);
         if(_loc1_)
         {
            return ZGlobal.player.questTrees.getTreeIconURL(_loc1_);
         }
         return ZGameQuestManager.instance.getButtonIconPath(this.m_quest.name);
      }
      
      public function get id() : String
      {
         return this.m_quest.name;
      }
      
      public function get isFromQuestTree() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.m_quest.xml.hasOwnProperty("requires"))
         {
            _loc1_ = this.m_quest.xml.requires.@type == "questTree";
         }
         return _loc1_;
      }
      
      public function get isTimedQuest() : Boolean
      {
         return this.m_quest.shouldShowTimer;
      }
      
      public function get isLimitedEdition() : Boolean
      {
         return ZGameTimeUtil.instance.isLimitedEdition(this.m_quest.xml);
      }
      
      public function get forced() : Boolean
      {
         return this.m_quest.forced;
      }
      
      public function get timeRemaining() : Number
      {
         var _loc1_:Number = -1;
         if(this.m_quest.hasDate && !this.m_quest.shouldShowTimer)
         {
            if(this.m_quest.getTimeRemaining() > 0)
            {
               _loc1_ = this.m_quest.getTimeRemaining();
            }
            else if(this.m_quest.getLETimeRemaining() > 0)
            {
               _loc1_ = this.m_quest.getLETimeRemaining();
            }
            else
            {
               _loc1_ = 5184000000;
            }
         }
         else if(this.m_quest.shouldShowTimer)
         {
            _loc1_ = this.m_quest.getTimeRemaining() != 0 ? this.m_quest.getTimeRemaining() : this.m_quest.getEndSeconds();
         }
         return _loc1_;
      }
      
      public function setIndex(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:Number = param1 * -QuestsUIItem.iconSpacing;
         TweenLite.killTweensOf(this.btnHandle);
         TweenLite.killTweensOf(this);
         if(this.btnHandle.y != _loc4_)
         {
            if(param3)
            {
               this.btnHandle.y = _loc4_;
            }
            else
            {
               TweenLite.to(this.btnHandle,0.5,{"y":_loc4_});
            }
         }
         if(param1 < 0 || param1 > param2 - 1)
         {
            this.m_offScreen = true;
            mouseEnabled = false;
            mouseChildren = false;
            if(param3)
            {
               visible = false;
               this.btnHandle.visible = false;
            }
            else
            {
               TweenLite.to(this.btnHandle,0.25,{
                  "alpha":0,
                  "onComplete":this.makeInvisible
               });
            }
         }
         else
         {
            this.m_offScreen = false;
            if(this.m_imageShowing)
            {
               if(ZGlobal.player.isRUXQuestActive && this.id.toString().indexOf(RUXManager.questPrefix) != 0)
               {
                  visible = false;
                  this.btnHandle.visible = false;
               }
               else
               {
                  visible = true;
                  this.btnHandle.visible = true;
               }
               TweenLite.to(this.btnHandle,0.25,{
                  "alpha":1,
                  "onComplete":this.enableMouse
               });
            }
         }
         this.m_delay = param1 * 1;
      }
      
      private function enableMouse() : void
      {
         mouseEnabled = true;
         mouseChildren = true;
      }
      
      private function makeInvisible() : void
      {
         this.btnHandle.y;
         this.btnHandle.visible = false;
      }
      
      public function dispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_questButton.removeEventListener(MouseEvent.CLICK,this.onClicked);
         this.m_questButton.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.m_questButton.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.onQuestProgress);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_RESTARTED,this.onQuestRestarted);
         if(ExperimentsManager.instance.getExperimentVariant("empire_quest_manager") > 1)
         {
            TutorialManager.instance.removeEventListener(TutorialManager.TUTORIAL_COMPLETE,this.onTutorialComplete);
         }
         this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc.filters = [];
         this.m_glowFilter = null;
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
         TweenLite.killTweensOf(this);
         TweenLite.killTweensOf(this.m_questButton);
         TweenLite.killTweensOf(this.btnHandle);
         if(this.m_movieController != null)
         {
            this.m_movieController.dispose();
            this.m_movieController = null;
         }
         if(this.m_questTimerID)
         {
            clearInterval(this.m_questTimerID);
         }
         if(this.m_remindersShown)
         {
            this.m_remindersShown = null;
         }
         this.m_questButton = null;
         this.m_parent.removeChild(this.btnHandle);
         if(ExperimentsManager.instance.getExperimentVariant("empire_quest_manager") > 1)
         {
            this.m_hoverInfo.dispose();
            this.m_hoverInfo = null;
         }
      }
      
      public function showDetails() : void
      {
         this.onClicked(null);
      }
      
      public function removeNotifyIconOnClick(param1:String) : void
      {
         var _loc3_:TQuestNotificationSeen = null;
         var _loc2_:Array = new Array();
         if(ZGlobal.player.isNotifyQuest(this.m_quest.name))
         {
            _loc2_.push(this.m_quest.name);
            _loc3_ = new TQuestNotificationSeen(_loc2_);
            TransactionManager.addTransaction(_loc3_);
            ZGlobal.player.addToSeenQuestNotifications(this.m_quest.name);
            ZGlobal.player.removeQuestNotification(this.m_quest.name);
            this.hideStarNotificationIcon();
         }
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc3_:ZGameQuestManager = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:ZGamePopUp = null;
         var _loc7_:TAcceptAllianceQuest = null;
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.QUEST_TASK_CLICKED,this.m_quest.name));
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_V2) == ExperimentsManager.VARIANT_QUEST_BAR_V2_ON)
         {
            this.removeNotifyIconOnClick(this.m_quest.name);
         }
         var _loc2_:Boolean = false;
         if(this.m_quest.hasLifeTime && this.m_quest.getTimeRemaining() <= 0 && !isQuestManagerActive())
         {
            PopupManager.instance.push(new QuestRestartPopup(this.m_quest));
         }
         else if(Boolean(this.m_quest.introIcon) && this.m_introMode)
         {
            _loc3_ = QuestManager.getInstance() as ZGameQuestManager;
            this.m_loader = ImageLoaderFactory.CreateImageLoader(this.buttonURL,this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc);
            this.m_loader.smooth = true;
            if(!isQuestManagerActive())
            {
               Tooltip.subscribe(this.m_questButton,_loc3_.getTooltip(this.m_quest.name));
            }
            if(Boolean(this.m_quest.introSpeech) && !ZGlobal.player.hasSeenSpeech(this.m_quest.introSpeech))
            {
               PopupManager.instance.push(new SpeechPopup(this.m_quest.introSpeech,this.onSpeechClosed),0,true,false);
               if(isQuestManagerActive())
               {
                  Tooltip.unsubscribe(this.m_questButton);
               }
            }
            else
            {
               _loc2_ = true;
            }
            this.m_introMode = false;
         }
         else
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            _loc4_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_quest.name);
            _loc5_ = MegaseriesManager.instance.isMegaseriesQuest(this.m_quest.name);
            if(this.m_quest.name.indexOf(RUXManager.questPrefix) == 0)
            {
               RUXManager.instance.showQuest(this.m_quest.name);
            }
            else if(_loc4_)
            {
               QuestTree.showScreen(_loc4_,"questBar");
            }
            else if(_loc5_)
            {
               MegaseriesDetailsPopup.show(this.m_quest.name,_loc5_);
            }
            else if(isQuestManagerActive())
            {
               if(this.m_quest.isAllianceQuest && ZGlobal.player.hasAcceptedAllianceQuest(this.m_quest.name))
               {
                  if(AlliancesManager.instance.isInitialised() && !AlliancesManager.instance.acceptedQuest(this.m_quest.name))
                  {
                     AlliancesManager.instance.setAcceptedQuest(this.m_quest.name);
                     _loc7_ = new TAcceptAllianceQuest(this.m_quest.name);
                     TransactionManager.addTransaction(_loc7_);
                  }
                  _loc6_ = new AllianceQuestsDialog(this.m_quest);
                  PopupManager.instance.push(_loc6_);
               }
               else
               {
                  PopupManager.instance.push(new QuestManagerPopup(this.m_quest.name));
               }
            }
            else
            {
               PopupManager.instance.push(new QuestDetailsPopup(this.m_quest.name));
            }
         }
         this.hideTaskArrow();
      }
      
      private function onSpeechClosed(param1:Event) : void
      {
         if(!ZGlobal.player.didCompleteQuest(this.m_quest.name))
         {
            if(this.m_quest.name.indexOf(RUXManager.questPrefix) == 0)
            {
               RUXManager.instance.showQuest(this.m_quest.name);
            }
            else if(isQuestManagerActive())
            {
               PopupManager.instance.push(new QuestManagerPopup(this.m_quest.name));
            }
            else
            {
               PopupManager.instance.push(new QuestDetailsPopup(this.m_quest.name));
            }
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this.m_questButton != null && this.m_questButton.arrowRt_bt != null && this.m_questButton.task_arrow_mc != null && this.m_questButton.task_arrow_mc.visible == false)
         {
            this.m_questButton.arrowRt_bt.gotoAndStop(15);
         }
         filters = [this.m_highlightFilter];
         if(isQuestManagerActive())
         {
            if(!this.m_quest.introSpeech || ZGlobal.player.hasSeenSpeech(this.m_quest.introSpeech))
            {
               if(this.m_hoverInfo)
               {
                  this.m_hoverInfo.show();
               }
            }
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.m_questButton != null && this.m_questButton.arrowRt_bt != null && this.m_questButton.task_arrow_mc != null && this.m_questButton.task_arrow_mc.visible == false)
         {
            this.m_questButton.arrowRt_bt.gotoAndStop(10);
         }
         filters = [];
         if(isQuestManagerActive())
         {
            if(this.m_hoverInfo)
            {
               this.m_hoverInfo.hide();
            }
         }
      }
      
      public function showTaskArrow(param1:String, param2:int) : void
      {
         this.hideTaskArrow();
         TextFieldUtil.processSingleLineTextField(this.m_questButton.task_arrow_mc.arrow_mc.task_arrow_tf,param1);
         this.updateArrowWidthDynamic();
         this.m_questButton.task_arrow_mc.mouseEnabled = false;
         this.m_questButton.task_arrow_mc.mouseChildren = false;
         this.m_questButton.task_arrow_mc.visible = true;
         Zlab.processManager.schedule(param2,this,this.hideTaskArrow);
         this.m_movieController = new MovieController(this.m_questButton);
         this.m_movieController.fps = 15;
      }
      
      private function updateArrowWidthDynamic() : void
      {
         var _loc1_:Number = Math.max(Math.round(this.m_questButton.task_arrow_mc.arrow_mc.task_arrow_tf.textWidth + 0.5) + ARROW_LT_MARGIN + ARROW_RT_MARGIN,ARROW_MIN_WIDTH);
         this.m_questButton.task_arrow_mc.arrow_mc.arrow_mc.width = _loc1_;
      }
      
      private function hideTaskArrow() : void
      {
         if(this.m_movieController != null)
         {
            this.m_movieController.dispose();
            this.m_movieController = null;
         }
         if(this.m_questButton != null)
         {
            if(this.m_questButton.task_arrow_mc != null)
            {
               this.m_questButton.task_arrow_mc.visible = false;
               this.m_questButton.task_arrow_mc.gotoAndStop(1);
            }
            if(this.m_questButton.arrowRt_bt != null)
            {
               this.m_questButton.arrowRt_bt.gotoAndStop(10);
            }
         }
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(this.m_delay > 0)
         {
            Zlab.processManager.schedule(this.m_delay * 750,this,this.onShow);
         }
         else
         {
            this.onShow();
         }
      }
      
      private function onShow() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         this.m_imageShowing = true;
         if(this.m_questButton)
         {
            if(this.m_fromInit)
            {
               this.hideTaskArrow();
               this.m_fromInit = false;
               dispatchEvent(new Event(FOCUS_THIS));
            }
            else
            {
               _loc1_ = ZGlobal.gameSettings.getString("newTaskArrowDuration");
               _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,0.03);
               _loc3_ = int(_loc2_ * 1000);
               _loc4_ = ZGameUtils.ZlocT("Quests","quest_arrow_text");
               this.showTaskArrow(_loc4_,_loc3_);
            }
            this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc.filters = [this.m_glowFilter];
            if(!this.m_offScreen)
            {
               alpha = 1;
               if(ZGlobal.player.isRUXQuestActive && this.id.toString().indexOf(RUXManager.questPrefix) != 0)
               {
                  visible = false;
                  this.btnHandle.visible = false;
               }
               else
               {
                  visible = true;
                  this.btnHandle.visible = true;
               }
               this.enableMouse();
               this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc.source.smoothing = true;
               TweenLite.from(this.btnHandle,1.5,{"y":"-" + Zlab.mainStage.stageHeight.toString()});
               TweenLite.from(this.m_questButton,0.75,{
                  "x":(Zlab.mainStage.stageWidth * 0.5).toString(),
                  "overwrite":false
               });
            }
         }
      }
      
      private function onImageFailed() : void
      {
         this.m_loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl),this.m_questButton.arrowRt_bt.button_mc.ui_loader_mc,this.onImageLoaded);
      }
      
      private function onQuestProgress(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         if(visible && param1.eventData == this.m_quest.name)
         {
            _loc2_ = ZGlobal.gameSettings.getString("questExpiredArrowDuration");
            _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_,2);
            _loc4_ = int(_loc3_ * 1000);
            this.showTaskArrow(ZGameUtils.ZlocT("Quests","quest_arrow_progress"),_loc4_);
         }
      }
      
      private function onQuestExpired() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         if(visible)
         {
            _loc1_ = ZGlobal.gameSettings.getString("questExpiredArrowDuration");
            _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,2);
            _loc3_ = int(_loc2_ * 1000);
            this.showTaskArrow(ZGameUtils.ZlocT("Quests","quest_arrow_updated"),_loc3_);
         }
      }
      
      private function startQuestTimer() : void
      {
         if(this.m_questTimerID)
         {
            clearInterval(this.m_questTimerID);
         }
         this.m_questTimerID = setInterval(this.updateQuestTimer,1000);
         if(!this.m_remindersShown)
         {
            this.m_remindersShown = new Object();
            this.m_remindersShown["first"] = false;
            this.m_remindersShown["second"] = false;
            this.m_remindersShown["final"] = false;
         }
      }
      
      private function stopQuestTimer() : void
      {
         if(this.m_questTimerID)
         {
            clearInterval(this.m_questTimerID);
         }
         if(this.m_remindersShown)
         {
            this.m_remindersShown = null;
         }
      }
      
      public function notifyQuest(param1:String) : void
      {
         this.m_questsWithNotifications[param1.toString()] = true;
      }
      
      public function removeQuestNotification(param1:String) : void
      {
         if(this.m_questsWithNotifications[param1.toString()] != undefined)
         {
            delete this.m_questsWithNotifications[param1.toString()];
         }
      }
      
      public function isNotifyQuest(param1:String) : Boolean
      {
         if(this.m_questsWithNotifications[param1] != undefined)
         {
            return true;
         }
         return false;
      }
      
      private function updateQuestTimer() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         if(this.m_questButton)
         {
            _loc1_ = 0;
            if(this.m_quest.shouldShowTimer)
            {
               _loc1_ = this.m_quest.getTimeRemaining();
               _loc5_ = Math.round(_loc1_ / 86400);
               if(_loc5_ > 1)
               {
                  TextFieldUtil.processTextField(this.m_questButton.timer_mc.counter_tf,ZGameUtils.ZlocT("Dialogs","ExpiresInDays",{"amount":_loc5_}));
               }
               else
               {
                  _loc6_ = ZGameTimeUtil.instance.getClockString(_loc1_,true,true);
                  TextFieldUtil.processTextField(this.m_questButton.timer_mc.counter_tf,_loc6_);
               }
            }
            else if(this.m_quest.hasDate)
            {
               _loc1_ = this.m_quest.getLETimeRemaining();
            }
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_SORTING) == ExperimentsManager.VARIANT_VALUE_QUEST_BAR_SORTING_ON)
            {
               if(this.m_quest.shouldShowTimer)
               {
                  _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("timerQuestFirstReminder"),60 * 60 * 60);
                  _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("timerQuestSecondReminder"),12 * 60 * 60);
                  _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("timerQuestFinalReminder"),1 * 60 * 60);
               }
               else
               {
                  if(!this.m_quest.hasDate)
                  {
                     return;
                  }
                  _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("starredQuestFirstReminder"),36 * 60 * 60);
                  _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("starredQuestSecondReminder"),12 * 60 * 60);
                  _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("starredQuesttFinalReminder"),1 * 60 * 60);
               }
            }
            else
            {
               if(!this.m_quest.shouldShowTimer)
               {
                  return;
               }
               _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("questFirstReminder"),24 * 60 * 60);
               _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("questSecondReminder"),12 * 60 * 60);
               _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(ZGlobal.gameSettings.getString("questFinalReminder"),1 * 60 * 60);
            }
            if(_loc1_ <= _loc2_ && _loc1_ > _loc3_ && !this.m_remindersShown["first"])
            {
               if(this.onQuestReminder())
               {
                  this.m_remindersShown["first"] = true;
               }
            }
            else if(_loc1_ <= _loc3_ && _loc1_ > _loc4_ && !this.m_remindersShown["second"])
            {
               if(this.onQuestReminder())
               {
                  this.m_remindersShown["second"] = true;
               }
            }
            else if(_loc1_ <= _loc4_ && !this.m_remindersShown["final"])
            {
               if(this.onQuestReminder())
               {
                  this.m_remindersShown["final"] = true;
               }
            }
            if(this.m_quest.shouldShowTimer && this.m_quest.isExpired())
            {
               this.stopQuestTimer();
               this.onQuestExpired();
            }
         }
      }
      
      private function onQuestReminder() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(visible && (!this.m_quest.isExpired() || this.m_quest.hasDate && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_BAR_SORTING) == ExperimentsManager.VARIANT_VALUE_QUEST_BAR_SORTING_ON))
         {
            _loc1_ = ZGlobal.gameSettings.getString("questReminderArrowDuration");
            _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,2);
            _loc3_ = int(_loc2_ * 1000);
            if(this.m_quest.hasDate)
            {
               _loc4_ = ZGameTimeUtil.instance.getTimeString(this.m_quest.getLETimeRemaining());
            }
            else
            {
               _loc4_ = ZGameTimeUtil.instance.getTimeString(this.m_quest.getTimeRemaining());
            }
            this.showTaskArrow(ZGameUtils.ZlocT("Quests","quest_arrow_reminder",{"time":_loc4_}),_loc3_);
            return true;
         }
         return false;
      }
      
      private function onQuestRestarted(param1:WorldEvent) : void
      {
         if(visible && param1.eventData == this.m_quest.name)
         {
            this.startQuestTimer();
         }
      }
      
      private function onTutorialComplete(param1:WorldEvent) : void
      {
         Tooltip.unsubscribe(this.m_questButton);
      }
      
      public function hideBtn() : void
      {
         this.btnHandle.visible = false;
      }
      
      public function showBtn() : void
      {
         this.btnHandle.visible = true;
      }
      
      public function simulateClick() : void
      {
         this.onClicked(null);
      }
   }
}

import ZQuest.Init.QuestSettingsInit;
import ZQuest.Managers.QuestManager;
import core.ZGlobal;
import core.managers.questManager.ZGameQuest;
import core.managers.questManager.ZGameQuestManager;
import core.ui.menuitem.QuestButtonUIItem;
import displays.ImageLoader;
import displays.ImageLoaderFactory;
import flash.display.MovieClip;
import utils.TextFieldUtil;
import utils.ZGameUtils;
import zlabs.Zlab;
import zlabs.debug.Logger;
import zlabs.resource.SWFResource;

class QuestHoverInfo
{
   
   private var m_class:Class;
   
   private var m_hoverInfo:MovieClip = null;
   
   private var m_quest:QuestButtonUIItem;
   
   private var m_loaders:Vector.<ImageLoader> = null;
   
   private var m_textObj:Object;
   
   private var m_rewardsTextObj:Object;
   
   private var m_loaded:Boolean = false;
   
   private const OFFSET_X:Number = 80;
   
   private const OFFSET_Y:Number = 0;
   
   public function QuestHoverInfo(param1:QuestButtonUIItem)
   {
      super();
      this.m_quest = param1;
      var _loc2_:String = ZGlobal.getAssetURL("assets/ui/QuestTooltip.swf");
      if(Zlab.resourceManager.validUrl(_loc2_))
      {
         Zlab.resourceManager.load(_loc2_,SWFResource,this.onLoadComplete,this.onLoadFail);
      }
   }
   
   protected function onLoadComplete(param1:SWFResource) : void
   {
      if(this.m_quest)
      {
         this.m_class = param1.getAssetClass("questTooltip_mc");
         param1.destroy();
         this.m_hoverInfo = new this.m_class() as MovieClip;
         this.initHoverInfo();
         this.m_hoverInfo.x = this.OFFSET_X;
         this.m_hoverInfo.y = this.OFFSET_Y;
         this.m_quest.addChild(this.m_hoverInfo);
         this.m_loaded = true;
         TextFieldUtil.processTextField(this.m_hoverInfo.rewards_tf,ZGameUtils.ZlocT("Dialogs","QuestRewards"));
      }
   }
   
   protected function onLoadFail(param1:SWFResource) : void
   {
      Logger.print(this,"Failed to load image \'" + param1.filename + "\'");
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
      var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_quest.id) as ZGameQuest;
      this.m_hoverInfo.rewards_four.visible = false;
      if(Boolean(_loc2_) && _loc2_.isAllianceQuest)
      {
         _loc1_ = [this.m_hoverInfo.rewards_four.rewardCard_01,this.m_hoverInfo.rewards_four.rewardCard_02,this.m_hoverInfo.rewards_four.rewardCard_03,this.m_hoverInfo.rewards_four.rewardCard_04];
         this.m_hoverInfo.rewards_even.visible = false;
         this.m_hoverInfo.rewards_odd.visible = false;
         this.m_hoverInfo.rewards_four.visible = true;
         this.m_hoverInfo.rewards_four.alpha = true;
         return _loc1_;
      }
      if(this.numRewards == 0)
      {
         _loc1_ = [];
         this.m_hoverInfo.rewards_even.visible = false;
         this.m_hoverInfo.rewards_odd.visible = false;
      }
      else if(this.numRewards % 2 == 0)
      {
         _loc1_ = [this.m_hoverInfo.rewards_even.rewardCard_01,this.m_hoverInfo.rewards_even.rewardCard_02];
         this.m_hoverInfo.rewards_even.visible = true;
         this.m_hoverInfo.rewards_odd.visible = false;
      }
      else
      {
         _loc1_ = [this.m_hoverInfo.rewards_odd.rewardCard_02,this.m_hoverInfo.rewards_odd.rewardCard_01,this.m_hoverInfo.rewards_odd.rewardCard_03];
         this.m_hoverInfo.rewards_even.visible = false;
         this.m_hoverInfo.rewards_odd.visible = true;
      }
      return _loc1_;
   }
   
   private function initHoverInfo() : void
   {
      var _loc3_:String = null;
      var _loc4_:ImageLoader = null;
      this.m_loaders = new Vector.<ImageLoader>();
      this.m_textObj = this.getTextObject(this.m_quest.id);
      this.m_rewardsTextObj = this.getRewardsTextObject(this.m_quest.id);
      if(this.textObj.title)
      {
         TextFieldUtil.processTextField(this.m_hoverInfo.header_tf,this.textObj.title);
      }
      var _loc1_:Array = this.getRewardClips();
      var _loc2_:int = 0;
      for each(_loc3_ in this.rewardsTextObj.rewardText)
      {
         if(_loc2_ < _loc1_.length)
         {
            _loc1_[_loc2_].visible = true;
            TextFieldUtil.processTextField(_loc1_[_loc2_].value_tf,this.m_rewardsTextObj.rewardPairs[_loc2_].count);
            if(_loc1_[_loc2_].title_tf)
            {
               TextFieldUtil.processTextField(_loc1_[_loc2_].title_tf,this.m_rewardsTextObj.rewardPairs[_loc2_].reward);
            }
            _loc4_ = ImageLoaderFactory.CreateImageLoader(this.rewardsTextObj.rewardIcons[_loc2_],_loc1_[_loc2_].icon);
            _loc4_.smooth = true;
            this.m_loaders.push(_loc4_);
         }
         _loc2_++;
      }
      while(_loc2_ < _loc1_.length)
      {
         _loc1_[_loc2_].visible = false;
         _loc2_++;
      }
      this.m_hoverInfo.visible = false;
   }
   
   public function show() : void
   {
      if(Boolean(this.m_hoverInfo != null) && Boolean(this.m_rewardsTextObj) && this.m_rewardsTextObj.rewardText.length > 0)
      {
         this.m_hoverInfo.visible = true;
      }
   }
   
   public function hide() : void
   {
      if(this.m_hoverInfo != null)
      {
         this.m_hoverInfo.visible = false;
      }
   }
   
   public function dispose() : void
   {
      var _loc1_:ImageLoader = null;
      for each(_loc1_ in this.m_loaders)
      {
         _loc1_.destroy();
      }
      this.m_loaders = null;
      this.m_hoverInfo = null;
      this.m_quest = null;
   }
}
