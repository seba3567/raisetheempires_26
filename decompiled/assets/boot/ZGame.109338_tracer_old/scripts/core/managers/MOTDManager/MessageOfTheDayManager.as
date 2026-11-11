package core.managers.MOTDManager
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import as3isolib.geom.Pt;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.HookItem;
   import core.managers.ExperimentsManager;
   import core.managers.FlashFeedManager;
   import core.managers.PVPManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.autoActionsManager.AutoActionsManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Player;
   import core.ui.UI;
   import core.ui.UIDirector.CampaignV2DirectorScript;
   import core.ui.UIDirector.UIDirector;
   import core.ui.UIManager;
   import core.ui.menuitem.FriendsBarUIItem;
   import core.ui.menuitem.OptionUIItem;
   import core.ui.menuitem.QuestsUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.MOTDPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.miniSeriesDialogBubble.MiniSeriesDialogBubble;
   import displays.screens.WonderHeraquaters;
   import displays.screens.leaderboard.LeaderboardScreen;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   import sound.SoundEvent;
   import transactions.TMotdTransaction;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.utils.MathUtils;
   
   public class MessageOfTheDayManager extends EventDispatcher
   {
      
      private static var m_instance:MessageOfTheDayManager;
      
      public static const EVENT_DIALOG_ACCEPT:String = "motdDialogAccept";
      
      public static const EVENT_DIALOG_DECLINE:String = "motdDialogDecline";
      
      public static const EVENT_SHOWN_ALL_MESSAGES:String = "motdShownAllMessages";
      
      public static const EVENT_DIALOG_NEXT:String = "motdDialogNext";
      
      public static const EVENT_DIALOG_PREV:String = "motdDialogPrev";
      
      public static const SHOW_POWERUPFACTORY_DIALOG:String = "showPowerupFactoryDialog";
      
      public static const SHOW_MASTERYFACTORY_DIALOG:String = "showMasteryFactoryDialog";
      
      public static const SHOW_MECHLAB_ACTIVATION_DIALOG:String = "showMechLabActivationDialog";
      
      public static const SHOW_MECHLAB_PARTS_GATHER:String = "showMechLabPartsGather";
      
      private static var MOTD_BACKLOG_MAX:int = 1;
      
      public static const SHOW_FLASHFEED_DIALOG:String = "showFlashFeedDialog";
      
      private var m_xml:XMLList;
      
      private var m_playerData:Player;
      
      private var m_motdDataList:Vector.<MOTDData>;
      
      private var m_currentMOTD:MOTDData;
      
      private var m_initUnixTimeStamp:Number;
      
      private var m_shouldDisplayNextDialog:Boolean = true;
      
      private var m_confirmationItem:GameItem = null;
      
      private var m_addedToActionQueue:Boolean = false;
      
      private var m_addedListeners:Boolean = false;
      
      private const UNIT_TEST:String = "UNIT_TEST";
      
      private const INCLUDE:String = "INCLUDE";
      
      private const EXCLUDE:String = "EXCLUDE";
      
      private const ONLY:String = "ONLY";
      
      private var m_motdNdx:int = -1;
      
      private var m_currentMOTDPopup:MOTDPopup;
      
      private var m_scrolling:Boolean;
      
      private var m_dispatchedAllShownAfterFirstLoad:Boolean = false;
      
      private var m_firstMOTDDataLoad:Boolean = true;
      
      private var m_requiresFurtherAction:Boolean = false;
      
      private var m_pendingMOTD:Boolean = true;
      
      private var m_motdPermissionsCheckList:Vector.<Object> = new Vector.<Object>();
      
      private var m_permissionCheckComplete:Boolean = false;
      
      private var m_permissionCheckPending:Boolean = false;
      
      private var m_stickyIconClickedWhilePermissionPending:Boolean = false;
      
      private var m_speechId:String;
      
      private var m_version:int = 1;
      
      private var m_firstMOTDShown:Boolean = false;
      
      public function MessageOfTheDayManager()
      {
         super();
         this.m_motdDataList = new Vector.<MOTDData>();
         this.m_currentMOTD = null;
         var _loc1_:Date = new Date();
         this.m_initUnixTimeStamp = Math.round(_loc1_.getTime() / 1000);
         ExternalInterface.addCallback("permissionQueryComplete",this.onPermissionQueryComplete);
         MOTDMerchManager.instance.addEventListener(MOTDMerchManager.EVENT_MOTD_MERCHANDISING_BONUS_GRANTED,this.bonusItemAwarded);
         MOTDMerchManager.instance.addEventListener(MOTDMerchManager.EVENT_MOTD_MERCHANDISING_BONUS_UNLOCKED,this.bonusItemUnlocked);
      }
      
      public static function get instance() : MessageOfTheDayManager
      {
         if(!m_instance)
         {
            m_instance = new MessageOfTheDayManager();
         }
         return m_instance;
      }
      
      public function get pendingMOTD() : Boolean
      {
         return this.m_pendingMOTD;
      }
      
      public function initExperimentVars() : void
      {
         this.m_scrolling = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MOTD_SCROLLING) == ExperimentsManager.VARIANT_VALUE_MOTD_SCROLLING_ON;
         MOTD_BACKLOG_MAX = this.m_scrolling ? int.MAX_VALUE : 1;
         this.m_version = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MOTD2) == ExperimentsManager.VARIANT_VALUE_MOTD2_ON ? 2 : 1;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_xml = param1;
      }
      
      public function setPlayer(param1:Player) : void
      {
         this.m_playerData = param1;
      }
      
      public function hudOpenMOTD() : void
      {
         if(this.m_currentMOTDPopup != null)
         {
            this.m_currentMOTDPopup.forceClose();
            this.m_currentMOTDPopup = null;
         }
         if(this.m_permissionCheckPending)
         {
            this.m_stickyIconClickedWhilePermissionPending = true;
         }
         else
         {
            this.queuePopups(false);
         }
      }
      
      public function queuePopups(param1:Boolean = true) : void
      {
         if(null == this.m_xml || null == this.m_playerData)
         {
            Logger.print(this,"MessageOfTheDayManager: Not initialized. Cannot display MOTD.");
            return;
         }
         this.addListeners();
         if(this.buildCheckPermissionsList())
         {
            this.doPermissionsChecks();
         }
         else
         {
            this.buildMOTDDataListFromXML(param1);
            if(this.m_scrolling)
            {
               this.refreshCurrentPopup();
            }
            else
            {
               this.dispatchNextDialog();
            }
         }
      }
      
      private function addListeners() : void
      {
         if(!this.m_addedListeners)
         {
            if(this.m_scrolling)
            {
               addEventListener(MessageOfTheDayManager.EVENT_DIALOG_NEXT,this.onDialogNext,false,0,true);
               addEventListener(MessageOfTheDayManager.EVENT_DIALOG_PREV,this.onDialogPrev,false,0,true);
            }
            addEventListener(MessageOfTheDayManager.EVENT_DIALOG_ACCEPT,this.onDialogAccept,false,0,true);
            addEventListener(MessageOfTheDayManager.EVENT_DIALOG_DECLINE,this.onDialogDecline,false,0,true);
            this.m_addedListeners = true;
         }
      }
      
      public function set addedToActionQueue(param1:Boolean) : void
      {
         this.m_addedToActionQueue = param1;
      }
      
      public function get addedToActionQueue() : Boolean
      {
         return this.m_addedToActionQueue;
      }
      
      private function buildCheckPermissionsList() : Boolean
      {
         var _loc1_:MOTDData = null;
         var _loc2_:XML = null;
         var _loc3_:Object = null;
         if(this.m_permissionCheckComplete)
         {
            return false;
         }
         this.m_motdPermissionsCheckList = new Vector.<Object>();
         for each(_loc2_ in this.m_xml)
         {
            _loc1_ = new MOTDData(_loc2_);
            if(Boolean(_loc1_.checkPermission) && _loc1_.checkPermission.length > 0)
            {
               _loc3_ = {
                  "name":_loc1_.name,
                  "perm":_loc1_.checkPermission,
                  "hasPermission":false,
                  "performedCheck":false
               };
               this.m_motdPermissionsCheckList.push(_loc3_);
            }
         }
         return this.m_motdPermissionsCheckList.length > 0;
      }
      
      private function doPermissionsChecks() : void
      {
         var _loc1_:Object = null;
         this.m_permissionCheckPending = true;
         for each(_loc1_ in this.m_motdPermissionsCheckList)
         {
            if(GlobalEngine.getFlashVar("authBypass"))
            {
               this.testExternalCall(_loc1_.perm,ZGlobal.snuid,_loc1_.name);
            }
            else
            {
               ExternalInterface.call("hasPermission",_loc1_.perm,ZGlobal.snuid,_loc1_.name);
            }
         }
      }
      
      private function buildMOTDDataListFromXML(param1:Boolean = true) : void
      {
         var _loc2_:MOTDData = null;
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc3_:Vector.<MOTDData> = new Vector.<MOTDData>();
         this.m_motdDataList = new Vector.<MOTDData>();
         for each(_loc4_ in this.m_xml)
         {
            _loc2_ = new MOTDData(_loc4_);
            _loc2_.hideScrollBarsOnLoad = !this.m_scrolling;
            _loc2_.hasPermission = this.getHasPermission(_loc2_.name);
            if(!this.m_firstMOTDDataLoad)
            {
               _loc2_.requireUserInteract = false;
            }
            if(!this.isUnitTest(_loc2_))
            {
               if(_loc2_.isRelevant(this.m_playerData,param1))
               {
                  _loc3_.push(_loc2_);
               }
            }
         }
         _loc3_.sort(this.compareByPriorityAndStartDate);
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length && _loc5_ < MOTD_BACKLOG_MAX)
         {
            this.m_motdDataList.push(_loc3_[_loc5_]);
            _loc5_++;
         }
         if(this.m_motdDataList.length > 0)
         {
            this.m_motdNdx = 0;
         }
         this.m_firstMOTDDataLoad = false;
      }
      
      public function getAllMerchMotds() : Array
      {
         var _loc1_:MOTDData = null;
         var _loc2_:Array = null;
         var _loc3_:XML = null;
         _loc2_ = [];
         for each(_loc3_ in this.m_xml)
         {
            _loc1_ = new MOTDData(_loc3_);
            if(_loc1_.isTypeMerchandise() && _loc1_.isRelevant(this.m_playerData,false))
            {
               _loc2_.push(_loc1_);
            }
         }
         return _loc2_;
      }
      
      private function bonusItemAwarded(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         _loc4_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.itemCode,GameItem) as GameItem;
         _loc2_ = ZGameUtils.ZlocT("Main","FeedbackMOTDMerchGiftReceived",{"item":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
         _loc3_ = ZGameUtils.ZlocT("Main","FeedbackMOTDMerchGiftReceivedPopupTitle");
         if(Boolean(this.m_currentMOTDPopup) && this.m_currentMOTDPopup.isTypeMerchandise())
         {
            this.m_currentMOTDPopup.addPlopperMessage(_loc2_,false,true,true,5000);
            this.m_currentMOTDPopup.animatePurchaseAwardBar();
         }
         else
         {
            PopupManager.instance.push(GenericPopup1B.NewOk(_loc2_,_loc3_),0,false);
         }
         SoundEvent.getSoundEvent("QuestComplete").play();
      }
      
      private function bonusItemUnlocked(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         _loc4_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.itemCode,GameItem) as GameItem;
         _loc2_ = ZGameUtils.ZlocT("Main","FeedbackMOTDMerchGiftUnlocked",{"item":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
         _loc3_ = ZGameUtils.ZlocT("Main","FeedbackMOTDMerchGiftUnlockedPopupTitle");
         if(Boolean(this.m_currentMOTDPopup) && this.m_currentMOTDPopup.isTypeMerchandise())
         {
            this.m_currentMOTDPopup.addPlopperMessage(_loc2_,false,true,true,5000);
            this.m_currentMOTDPopup.animateUnlockAwardBar();
         }
         else
         {
            PopupManager.instance.push(GenericPopup1B.NewOk(_loc2_,_loc3_),0,false);
         }
         SoundEvent.getSoundEvent("QuestComplete").play();
      }
      
      private function getHasPermission(param1:String) : Boolean
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_motdPermissionsCheckList)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_.hasPermission;
            }
         }
         return false;
      }
      
      private function testExternalCall(param1:String, param2:Number, param3:String) : void
      {
         var _loc4_:Object = {
            "id":param3,
            "pass":false
         };
         this.onPermissionQueryComplete(_loc4_);
      }
      
      private function onPermissionQueryComplete(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Boolean = false;
         for each(_loc3_ in this.m_motdPermissionsCheckList)
         {
            if(param1.id == _loc3_.name)
            {
               _loc3_.hasPermission = param1.pass;
               _loc3_.performedCheck = true;
            }
            if(!_loc3_.performedCheck)
            {
               _loc2_ = true;
            }
         }
         if(!_loc2_)
         {
            this.m_permissionCheckComplete = true;
            this.m_permissionCheckPending = false;
            this.buildMOTDDataListFromXML(!this.m_stickyIconClickedWhilePermissionPending);
            if(this.m_scrolling)
            {
               this.refreshCurrentPopup();
            }
            else
            {
               this.dispatchNextDialog();
            }
         }
      }
      
      private function cullMOTDList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Vector.<MOTDData> = null;
         var _loc4_:MOTDData = null;
         _loc3_ = new Vector.<MOTDData>();
         _loc2_ = int(this.m_motdDataList.length);
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            _loc4_ = this.m_motdDataList[_loc1_];
            if(_loc4_.isRelevant(this.m_playerData,false))
            {
               _loc3_.push(_loc4_);
            }
            else if(_loc1_ < this.m_motdNdx)
            {
               --this.m_motdNdx;
            }
            _loc1_++;
         }
         this.m_motdDataList = _loc3_;
         if(this.m_motdDataList.length <= 0)
         {
            this.m_motdNdx = -1;
         }
         else if(this.m_motdNdx >= this.m_motdDataList.length)
         {
            this.m_motdNdx = this.m_motdDataList.length - 1;
         }
      }
      
      private function isRelevantMOTD(param1:MOTDData, param2:Boolean = true) : Boolean
      {
         return param1.isRelevant(this.m_playerData,param2);
      }
      
      private function compareByPriorityAndStartDate(param1:MOTDData, param2:MOTDData) : Number
      {
         if(param1.priority == param2.priority)
         {
            return ZGameTimeUtil.instance.getStartSeconds(param1.xml) - ZGameTimeUtil.instance.getStartSeconds(param2.xml);
         }
         return param1.priority - param2.priority;
      }
      
      private function dispatchNextDialog(param1:Boolean = false) : void
      {
         if(!this.shouldDisplayNextDialog())
         {
            return;
         }
         if(this.m_motdDataList.length == 0)
         {
            this.m_currentMOTD = null;
            dispatchEvent(new Event(EVENT_SHOWN_ALL_MESSAGES));
            this.m_pendingMOTD = false;
            return;
         }
         this.m_currentMOTD = this.m_motdDataList.shift();
         var _loc2_:MOTDPopup = new MOTDPopup(this.m_currentMOTD);
         this.m_currentMOTDPopup = _loc2_;
         this.m_firstMOTDShown = true;
         PopupManager.instance.push(_loc2_,0,true,true);
      }
      
      public function showNextMOTD() : void
      {
         ++this.m_motdNdx;
         if(this.m_motdNdx >= this.m_motdDataList.length)
         {
            this.m_motdNdx = 0;
         }
         this.refreshCurrentPopup();
      }
      
      public function showPreviousMOTD() : void
      {
         --this.m_motdNdx;
         if(this.m_motdNdx < 0)
         {
            this.m_motdNdx = this.m_motdDataList.length - 1;
         }
         this.refreshCurrentPopup();
      }
      
      public function refreshCurrentPopup() : void
      {
         if(this.m_currentMOTDPopup != null)
         {
            this.m_currentMOTDPopup.forceClose();
            this.m_currentMOTDPopup = null;
         }
         if(this.m_motdDataList.length > 0)
         {
            this.m_currentMOTD = this.m_motdDataList[this.m_motdNdx];
         }
         else
         {
            this.m_currentMOTD = null;
            this.checkDispatchAllShown();
         }
         if(this.m_currentMOTD != null)
         {
            Logger.print(this,"updating current popup, m_motdDataList.length: " + this.m_motdDataList.length);
            if(this.m_motdDataList.length == 1)
            {
               this.m_currentMOTD.hideScrollBarsOnLoad = true;
            }
            else
            {
               this.m_currentMOTD.hideScrollBarsOnLoad = !this.m_scrolling;
            }
            this.m_currentMOTDPopup = new MOTDPopup(this.m_currentMOTD);
            PopupManager.instance.push(this.m_currentMOTDPopup,0,true,true);
         }
      }
      
      public function openMOTDPopupByName(param1:String, param2:Boolean) : void
      {
         var _loc3_:MOTDData = this.getMOTDByName(param1);
         if(_loc3_ == null)
         {
            Logger.debug(this,"openMOTDByName","Could not find name " + param1);
            return;
         }
         if(this.m_currentMOTD != null)
         {
            Logger.debug(this,"openMOTDByName","PROBLEM: attempt to display motd " + param1 + "when " + this.m_currentMOTD.name + "is active. Ignoring " + param1);
            return;
         }
         if(param2 && !_loc3_.isRelevant(ZGlobal.player))
         {
            return;
         }
         if(!this.m_addedListeners)
         {
            removeEventListener(MessageOfTheDayManager.EVENT_DIALOG_ACCEPT,this.onDialogAccept);
            addEventListener(MessageOfTheDayManager.EVENT_DIALOG_ACCEPT,this.onHandleDialogAccept,false,0,true);
            this.m_addedListeners = true;
         }
         this.m_currentMOTD = _loc3_;
         var _loc4_:MOTDPopup = new MOTDPopup(_loc3_);
         PopupManager.instance.push(_loc4_,0,true,true);
      }
      
      private function getMOTDByName(param1:String) : MOTDData
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_xml)
         {
            if(_loc2_.attribute("name") == param1)
            {
               return new MOTDData(_loc2_);
            }
         }
         return null;
      }
      
      public function getMOTDSet(param1:String) : Array
      {
         var _loc3_:XML = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this.m_xml)
         {
            if(_loc3_.attribute("setName") == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function isRelevantMOTDByName(param1:String, param2:Boolean = true) : Boolean
      {
         var _loc3_:MOTDData = this.getMOTDByName(param1);
         if(_loc3_)
         {
            return _loc3_.isRelevant(this.m_playerData,param2);
         }
         return false;
      }
      
      private function onHandleDialogAccept(param1:WorldEvent) : void
      {
         this.setSeenFlags();
         this.logMessageInteraction(TMotdTransaction.ACTION_MSG_ACCEPTED);
         if(!(Boolean(param1.eventData) && Boolean(param1.eventData.cancelAcceptAction) && param1.eventData.cancelAcceptAction == true))
         {
            this.doAcceptAction();
         }
      }
      
      private function onDialogAccept(param1:WorldEvent) : void
      {
         this.onHandleDialogAccept(param1);
         if(!this.m_scrolling)
         {
            this.dispatchNextDialog();
         }
         else
         {
            this.checkDispatchAllShown();
         }
      }
      
      private function onDialogDecline(param1:WorldEvent) : void
      {
         this.setSeenFlags();
         this.logMessageInteraction(TMotdTransaction.ACTION_MSG_VIEWED);
         this.doDeclineAction();
         if(!this.m_scrolling)
         {
            this.dispatchNextDialog();
         }
         else
         {
            this.checkDispatchAllShown();
         }
      }
      
      private function checkDispatchAllShown() : void
      {
         if(this.m_scrolling)
         {
            if(!this.m_requiresFurtherAction)
            {
               if(!this.m_dispatchedAllShownAfterFirstLoad)
               {
                  this.m_dispatchedAllShownAfterFirstLoad = true;
                  dispatchEvent(new Event(EVENT_SHOWN_ALL_MESSAGES));
                  this.m_pendingMOTD = false;
               }
               this.m_currentMOTD = null;
            }
         }
      }
      
      private function onDialogNext(param1:WorldEvent) : void
      {
         this.setSeenFlagsViaScroll();
         this.cullMOTDList();
         this.showNextMOTD();
      }
      
      private function onDialogPrev(param1:WorldEvent) : void
      {
         this.setSeenFlagsViaScroll();
         this.cullMOTDList();
         this.showPreviousMOTD();
      }
      
      private function setSeenFlagsViaScroll() : void
      {
         this.setSeenFlags();
         this.logMessageInteraction(TMotdTransaction.ACTION_MSG_VIEWED);
      }
      
      private function setSeenFlags() : void
      {
         if(this.m_currentMOTD)
         {
            if(this.m_currentMOTD.xml.@firstArmyResearch != undefined || this.m_currentMOTD.xml.@firstNavyResearch != undefined || this.m_currentMOTD.xml.@firstAirResearch != undefined)
            {
               ZGlobal.player.setSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG);
            }
         }
      }
      
      private function shouldDisplayNextDialog() : Boolean
      {
         return this.m_shouldDisplayNextDialog;
      }
      
      private function doAcceptAction() : void
      {
         var _loc1_:WonderHeraquaters = null;
         var _loc2_:FriendsBarUIItem = null;
         if(this.m_currentMOTD == null)
         {
            Logger.debug(this,"doAcceptAction","m_currentMOTD is null");
            return;
         }
         if(this.m_currentMOTD.acceptButtonBehavior)
         {
            Logger.print(this,this.m_currentMOTD.acceptButtonBehavior);
         }
         Logger.print(this,"m_currentMOTD.acceptButtonBehavior: " + this.m_currentMOTD.acceptButtonBehavior);
         switch(this.m_currentMOTD.acceptButtonBehavior)
         {
            case MOTDData.ACCEPT_ARROW_ON_PVP_BUTTON:
               break;
            case MOTDData.ACCEPT_OPEN_BUILD_MENU:
               this.openBuildMenu();
               break;
            case MOTDData.ACCEPT_PLACE_OBJECT:
               this.placeObject();
               break;
            case MOTDData.ACCEPT_BUY_OBJECT:
               this.buyObject(this.m_currentMOTD.acceptButtonBehaviorData);
               break;
            case MOTDData.ACCEPT_REDIRECT:
               this.redirectURL();
               break;
            case MOTDData.ACCEPT_REDIRECT_NEW_TAB:
               this.openNewTabURL();
               break;
            case MOTDData.ACCEPT_OPEN_OPTION_MENU:
               this.openOptionMenu();
               break;
            case MOTDData.ACCEPT_DEFAULT:
               break;
            case MOTDData.ACCEPT_OPEN_LEADERBOARDS:
               this.openLeaderboards(this.m_currentMOTD.acceptButtonBehaviorData);
               break;
            case MOTDData.ACCEPT_BUY_OBJECT_PAYMENTS_REDIRECT:
               this.buyObjectPaymentsRedirectAndOpenStore();
               break;
            case MOTDData.ACCEPT_OPEN_BUILD_MENU_TAB:
               this.openBuildMenuTab();
               break;
            case MOTDData.ACCEPT_PAN_TO_ITEM:
               this.panToItem();
               break;
            case MOTDData.ACCEPT_PAN_OR_PLACE_ITEM:
               this.panOrPlaceObject();
               break;
            case MOTDData.ACCEPT_CUSTOM_ACTION:
               this.doCustomAction();
               break;
            case MOTDData.ACCEPT_SHOW_TUTORIAL_UI_ITEM:
               this.showTutorialUIItem();
               break;
            case MOTDData.GLOBALPVP_LEGAL_SCREEN:
               this.startGlobalPVPFlow();
               break;
            case MOTDData.DOMINATION_FTUE:
               this.startDominationFlow();
               break;
            case MOTDData.SHOW_POWERUPFACTORY_DIALOG:
               this.showPowerupFactoryDialog();
               break;
            case MOTDData.ACCEPT_OPEN_FB_PERMISSIONS_DIALOG:
               this.openFBPermissions();
               break;
            case MOTDData.SHOW_MASTERYFACTORY_DIALOG:
               this.showMasteryFactoryDialog();
               break;
            case MOTDData.SHOW_MECHLAB_ACTIVATION_DIALOG:
               this.showMechLabDialog();
               break;
            case MOTDData.SHOW_MECHLAB_PARTS_GATHER:
               this.showMechLabPartsDialog();
               break;
            case MOTDData.SHOW_FLASHFEED_DIALOG:
               this.showFlashFeedDialog();
               break;
            case MOTDData.SHOW_QUEST_TASK_ARROW:
               this.showQuestTaskArrow(this.m_currentMOTD.acceptButtonBehaviorData);
               break;
            case MOTDData.SHOW_SPEECH:
               this.showSpeech(this.m_currentMOTD.acceptButtonBehaviorData);
               break;
            case MOTDData.SHOW_WONDERS_DIALOG:
               _loc1_ = new WonderHeraquaters();
               PopupManager.instance.push(_loc1_);
               break;
            case MOTDData.SHOW_ALLIANCE_CREATE_DIALOG:
               _loc2_ = UIManager.instance.getMenuItemByName(FriendsBarUIItem.ITEM_ID) as FriendsBarUIItem;
               if(_loc2_)
               {
                  _loc2_.showAllianceUI();
               }
               break;
            case MOTDData.SHOW_SURVIVALMODE_WELCOME:
               this.showSurvivalModeWelcome();
               break;
            case MOTDData.SHOW_CAMPAIGN_ARROW:
               this.showCampaignArrow();
               break;
            case MOTDData.MOTD_TYPE_DEATHMATCH:
               DeathMatchManager.instance.onAcceptMOTD();
               break;
            default:
               Logger.debug(this,"doAcceptAction","Warning: accept button behavior " + this.m_currentMOTD.acceptButtonBehavior + "not supported!");
         }
         this.m_currentMOTDPopup = null;
      }
      
      private function doDeclineAction() : void
      {
         if(this.m_currentMOTD == null)
         {
            Logger.debug(this,"doDeclineAction","m_currentMOTD is null");
            return;
         }
         switch(this.m_currentMOTD.acceptButtonBehavior)
         {
            case MOTDData.ACCEPT_PLACE_OBJECT:
               this.placeObject();
         }
         this.m_currentMOTDPopup = null;
      }
      
      private function logMessageInteraction(param1:String) : void
      {
         if(this.m_currentMOTD != null)
         {
            TransactionManager.addTransaction(new TMotdTransaction(param1,this.m_currentMOTD.name));
            if(this.m_currentMOTD.xml.@actionAffects != undefined && this.m_currentMOTD.xml.@actionAffects != "")
            {
               TransactionManager.addTransaction(new TMotdTransaction(param1,this.m_currentMOTD.xml.@actionAffects));
            }
            if(this.m_currentMOTD.flagName)
            {
               this.m_playerData.setSeenFlag(this.m_currentMOTD.flagName);
            }
            if(param1 == TMotdTransaction.ACTION_MSG_VIEWED)
            {
               if(this.m_currentMOTD.isXPromo)
               {
                  StatsManager.count("dialog","xpromo","close",this.m_currentMOTD.xPromoGameID,this.m_currentMOTD.name);
               }
               else
               {
                  StatsManager.count("dialog",this.m_currentMOTD.name,"close");
               }
            }
            else if(param1 == TMotdTransaction.ACTION_MSG_ACCEPTED)
            {
               if(this.m_currentMOTD.isXPromo)
               {
                  StatsManager.count("dialog","xpromo","okay",this.m_currentMOTD.xPromoGameID,this.m_currentMOTD.name);
               }
               else
               {
                  StatsManager.count("dialog",this.m_currentMOTD.name,"yes",this.m_currentMOTD.acceptButtonBehavior);
               }
            }
         }
      }
      
      private function openBuildMenu() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Object = null;
         if(this.m_currentMOTD)
         {
            if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
            {
               if(this.m_currentMOTD.acceptButtonBehaviorData)
               {
                  _loc1_ = this.m_currentMOTD.acceptButtonBehaviorData.split(",");
                  _loc2_ = {};
                  if(_loc1_[1])
                  {
                     TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_ITEM,_loc1_[1]));
                     _loc2_.focusGameItemCode = _loc1_[1];
                  }
                  _loc2_.tab = _loc1_[0];
                  _loc2_.motd = true;
                  UI.instance.displayStoreDialog(_loc2_);
               }
               else
               {
                  UI.instance.displayStoreDialog();
               }
            }
         }
      }
      
      private function showCampaignArrow() : void
      {
         UIDirector.instance.runScript(new CampaignV2DirectorScript(),null);
      }
      
      private function panOrPlaceObject() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:Number = NaN;
         if(ZGlobal.isHome())
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_currentMOTD.acceptButtonBehaviorData,GameItem) as GameItem;
            if(_loc1_)
            {
               _loc2_ = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(this.m_currentMOTD.acceptButtonBehaviorData);
               if(_loc2_ > 0)
               {
                  this.onPanToItem(this.m_currentMOTD.acceptButtonBehaviorData);
               }
               else
               {
                  this.placeObject();
               }
            }
         }
      }
      
      private function placeObject() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:int = 0;
         if(ZGlobal.isHome())
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_currentMOTD.acceptButtonBehaviorData,GameItem) as GameItem;
            if(_loc1_)
            {
               _loc2_ = ZGlobal.player.getNumberOfInventoryItems(this.m_currentMOTD.acceptButtonBehaviorData);
               if(_loc2_ > 0)
               {
                  GameModeManager.instance.addGameMode(new GMObjectPlace(_loc1_.name,MarketEvent.SOURCE_INVENTORY,true));
                  WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlaced);
                  WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onObjectPlaced);
                  this.m_shouldDisplayNextDialog = false;
                  this.m_requiresFurtherAction = true;
               }
            }
         }
      }
      
      private function buyObject(param1:String, param2:Boolean = true) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:LocalizationObjectToken = null;
         var _loc9_:String = null;
         var _loc10_:Array = null;
         var _loc11_:GenericPopup = null;
         var _loc3_:Boolean = false;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(_loc4_)
         {
            _loc5_ = _loc4_.cash;
            _loc3_ = _loc4_.usesCash() ? ZGlobal.player.canBuyCash(_loc5_,param2) : ZGlobal.player.canBuy(_loc4_,param2);
            if(_loc3_)
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc5_))
               {
                  this.m_confirmationItem = _loc4_;
                  _loc7_ = ZGameUtils.CashTokenReplacements(_loc5_);
                  _loc8_ = this.m_confirmationItem.getSentenceNameLocalizationObject("singular");
                  if(_loc8_)
                  {
                     _loc7_.item = _loc8_;
                     _loc6_ = _loc4_.canBeUnlocked() ? ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage_Object",_loc7_) : ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc7_);
                  }
                  else
                  {
                     _loc7_.item = this.m_confirmationItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     _loc6_ = _loc4_.canBeUnlocked() ? ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage",_loc7_) : ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc7_);
                  }
                  _loc9_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
                  _loc10_ = new Array("EmpirePointsConfirm","","","");
                  PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc6_,_loc9_,this.onCashBuyPopupClose,_loc10_));
                  this.m_shouldDisplayNextDialog = false;
                  this.m_requiresFurtherAction = true;
                  return _loc3_;
               }
            }
            if(_loc3_ && _loc4_.energyYield > 0)
            {
               if(!ZGlobal.player.m_energy.canAcceptEnergy(_loc4_.energyYield))
               {
                  _loc11_ = new GenericPopup1B(ZGameUtils.ZlocT("Dialogs","NoAcceptEnergy_Message"),ZGameUtils.ZlocT("Dialogs","NoAcceptEnergy_Title"),GenericPopup.TYPE_OK,null);
                  _loc11_.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
                  PopupManager.instance.push(_loc11_);
                  _loc3_ = false;
               }
            }
            if(_loc3_)
            {
               this.buyItem(_loc4_);
               this.m_shouldDisplayNextDialog = false;
               this.m_requiresFurtherAction = true;
            }
         }
         return _loc3_;
      }
      
      private function buyObjectPaymentsRedirectAndOpenStore() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.behaviorDataObject(this.m_currentMOTD.acceptButtonBehaviorData);
         if(!this.buyObject(_loc1_.item,false))
         {
            ZGlobal.switchToTab("money");
            _loc2_ = new Object();
            _loc2_.focusGameItemCode = _loc1_.item;
            _loc2_.tab = _loc1_.tab;
            _loc2_.motd = true;
            UI.instance.displayStoreDialog(_loc2_);
         }
      }
      
      private function behaviorDataObject(param1:String) : Object
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc2_:Object = new Object();
         var _loc3_:Array = param1.split(",");
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = _loc4_.split(":");
            _loc2_[_loc5_[0]] = _loc5_[1];
         }
         return _loc2_;
      }
      
      private function openBuildMenuTab() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.behaviorDataObject(this.m_currentMOTD.acceptButtonBehaviorData);
         if(_loc1_.tab)
         {
            _loc2_ = {};
            _loc2_.tab = _loc1_.tab;
            _loc2_.motd = true;
            UI.instance.displayStoreDialog(_loc2_);
         }
         else
         {
            UI.instance.displayStoreDialog();
         }
      }
      
      private function showPowerupFactoryDialog() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SHOW_POWERUPFACTORY_DIALOG));
      }
      
      private function showMasteryFactoryDialog() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SHOW_MASTERYFACTORY_DIALOG));
      }
      
      private function showMechLabDialog() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SHOW_MECHLAB_ACTIVATION_DIALOG));
      }
      
      private function showMechLabPartsDialog() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SHOW_MECHLAB_PARTS_GATHER));
      }
      
      private function showFlashFeedDialog() : void
      {
         FlashFeedManager.getInstance().dispatchEvent(new WorldEvent(FlashFeedManager.SHOW_FLASHFEED_DIALOG));
         StatsManager.count("dialog","dialog_flashfeeds","motd_flashfeeds_go");
      }
      
      private function showQuestTaskArrow(param1:String) : void
      {
         var _loc2_:QuestsUIItem = UIManager.instance.getMenuItemByName("questsUIItem") as QuestsUIItem;
         _loc2_.showTaskArrowOnQuest(param1);
      }
      
      private function startGlobalPVPFlow() : void
      {
         if(!PVPManager.instance.canHideGlobalPVPBar())
         {
            PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_MOTD_DONE,this.onGlobalPVPMOTDDone,false,0,true);
            PVPManager.instance.beginGlobalPVPMOTDFlow();
            this.m_shouldDisplayNextDialog = false;
            this.m_requiresFurtherAction = true;
         }
      }
      
      private function showSpeech(param1:String) : void
      {
         this.m_speechId = param1;
         PopupManager.instance.push(new SpeechPopup(param1,this.onSpeechClose),0,true,false);
      }
      
      private function onSpeechClose(param1:Event) : void
      {
         var _loc2_:XML = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:Dictionary = null;
         var _loc7_:Object = null;
         var _loc8_:GameDataComponent = null;
         if(this.m_speechId)
         {
            _loc2_ = ZGlobal.gameSettings.getSpeech(this.m_speechId);
            if(Boolean(_loc2_) && _loc2_.@panOnClose != undefined)
            {
               _loc3_ = _loc2_.@panOnClose.split(",");
               for each(_loc4_ in _loc3_)
               {
                  _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
                  if(_loc5_)
                  {
                     _loc6_ = WorldObjectManager.instance.getObjectsBySubType(_loc5_.type,_loc5_.subType);
                     for each(_loc7_ in _loc6_)
                     {
                        _loc8_ = GameDataComponent(_loc7_.lookupComponentByType(GameDataComponent));
                        if((Boolean(_loc8_)) && _loc8_.gameData.code == _loc4_)
                        {
                           this.onPanToItem(_loc4_);
                           return;
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function onGlobalPVPMOTDDone(param1:WorldEvent) : void
      {
         PVPManager.instance.removeEventListener(PVPManager.GLOBALPVP_MOTD_DONE,this.onGlobalPVPMOTDDone);
         this.dispatchNextMOTD();
      }
      
      private function panToItem() : void
      {
         var _loc3_:MiniSeriesDialogBubble = null;
         var _loc1_:String = this.m_currentMOTD.acceptButtonBehaviorData as String;
         var _loc2_:HookItem = ZGlobal.gameSettings.getItemByCode(_loc1_,HookItem) as HookItem;
         if(_loc2_.url)
         {
            _loc3_ = new MiniSeriesDialogBubble(this.onPanToItem,_loc1_,this.m_currentMOTD.advisorId);
            PopupManager.instance.push(_loc3_);
         }
         else
         {
            this.onPanToItemDelay({"itemCode":_loc1_});
         }
      }
      
      private function doCustomAction() : void
      {
         if(this.m_currentMOTD.xml.@volcanoReskinCode.toString())
         {
            AutoActionsManager.instance[this.m_currentMOTD.acceptButtonBehaviorData as String](this.m_currentMOTD.xml.@buildingCode,this.m_currentMOTD.xml.@volcanoReskinCode);
         }
         else
         {
            AutoActionsManager.instance[this.m_currentMOTD.acceptButtonBehaviorData as String]();
         }
      }
      
      private function onPanToItem(param1:String) : void
      {
         Zlab.processManager.schedule(1000,this,this.onPanToItemDelay,{"itemCode":param1});
      }
      
      private function onPanToItemDelay(param1:Object) : void
      {
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:BuildingSpatialComponent = null;
         var _loc7_:Pt = null;
         var _loc8_:CineCameraComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1.itemCode,GameItem) as GameItem;
         if(_loc2_)
         {
            _loc3_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc5_)) && _loc5_.gameData.code == param1.itemCode)
               {
                  _loc6_ = BuildingSpatialComponent(_loc4_.lookupComponentByType(BuildingSpatialComponent));
                  if(_loc6_)
                  {
                     _loc7_ = new Pt(_loc6_.position.x,_loc6_.position.y);
                     _loc7_ = MathUtils.worldToTile(_loc7_,ZGlobal.cellSize);
                     _loc8_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
                     _loc8_.moveTo(_loc7_);
                     break;
                  }
               }
            }
         }
      }
      
      private function showTutorialUIItem() : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc1_:Object = this.behaviorDataObject(this.m_currentMOTD.acceptButtonBehaviorData);
         if(Boolean(_loc1_.item) && Boolean(_loc1_.duration))
         {
            _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_.duration,0);
            _loc3_ = _loc1_.item;
            _loc4_ = TutorialManager.instance.getUIItem(_loc3_);
            if(_loc4_)
            {
               TutorialManager.instance.addArrowToUIElement(_loc4_);
               Zlab.processManager.schedule(_loc2_ * 1000,this,this.onTutorialUIItemDone);
               this.m_shouldDisplayNextDialog = false;
               this.m_requiresFurtherAction = true;
            }
         }
      }
      
      private function onTutorialUIItemDone() : void
      {
         TutorialManager.instance.removeArrows();
         this.dispatchNextMOTD();
      }
      
      private function redirectURL() : void
      {
         var _loc1_:String = this.m_currentMOTD.acceptButtonBehaviorData;
         ZGlobal.navigateImmediatelyTo(_loc1_);
      }
      
      private function openOptionMenu() : void
      {
         var _loc1_:OptionUIItem = null;
         if(this.m_currentMOTD)
         {
            _loc1_ = UIManager.instance.getMenuItemByName(OptionUIItem.ITEM_ID) as OptionUIItem;
            if(_loc1_)
            {
               _loc1_.showAndHighlightOption(this.m_currentMOTD.acceptButtonBehaviorData);
            }
         }
      }
      
      private function openLeaderboards(param1:String = null) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"dialog",
            "kingdom":"motd_leaderboard",
            "phylum":"yes"
         }));
         WindowManager.instance.push(new LeaderboardScreen(param1));
      }
      
      private function openNewTabURL() : void
      {
         var _loc1_:String = this.m_currentMOTD.acceptButtonBehaviorData;
         navigateToURL(new URLRequest(_loc1_),null);
      }
      
      private function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyItem(this.m_confirmationItem);
         }
         this.m_confirmationItem = null;
         this.dispatchNextMOTD();
      }
      
      private function buyItem(param1:GameItem) : void
      {
         UI.instance.setupForItemPurchase();
         switch(param1.type)
         {
            case GameItem.TYPE_EXPANSION:
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.EXPAND_ISLAND,param1.code,MarketEvent.SOURCE_STORE));
               break;
            case GameItem.TYPE_BUILDING:
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.BUILDING,param1.name,MarketEvent.SOURCE_STORE));
               break;
            case GameItem.TYPE_ROAD:
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.ROADS,param1.name,MarketEvent.SOURCE_STORE));
               break;
            case GameItem.TYPE_CONSUMABLE:
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONSUMABLE,param1.name,MarketEvent.SOURCE_STORE));
               break;
            case GameItem.TYPE_BUILDABLE:
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.BUILDABLE,param1.name,MarketEvent.SOURCE_STORE));
               break;
            case GameItem.TYPE_RESOURCE:
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.RESOURCE,param1.name,MarketEvent.SOURCE_STORE));
         }
      }
      
      private function onObjectPlaced(param1:WorldEvent) : void
      {
         if(Boolean(this.m_currentMOTD) && param1.eventData as String == this.m_currentMOTD.acceptButtonBehaviorData)
         {
            this.dispatchNextMOTD();
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlaced);
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onObjectPlaced);
         }
      }
      
      private function openFBPermissions() : void
      {
         this.m_currentMOTD.acceptButtonBehaviorData;
         ExternalInterface.call("showPermissions",this.m_currentMOTD.acceptButtonBehaviorData);
      }
      
      public function runUnitTest() : void
      {
         var _loc1_:MOTDData = null;
         var _loc2_:XML = null;
         if(null == this.m_xml || null == this.m_playerData)
         {
            return;
         }
         Logger.info(this,"runUnitTest","---MOTD Unit Test Starting---");
         for each(_loc2_ in this.m_xml)
         {
            _loc1_ = new MOTDData(_loc2_);
            if(this.isUnitTest(_loc1_))
            {
               this.unitTestMOTD(_loc1_);
            }
         }
         Logger.info(this,"runUnitTest","---MOTD Unit Test Ending---");
      }
      
      private function isUnitTest(param1:MOTDData) : Boolean
      {
         return param1.name.indexOf(this.UNIT_TEST) != -1;
      }
      
      private function unitTestMOTD(param1:MOTDData) : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         if(param1.name.indexOf(this.INCLUDE) == -1 && param1.name.indexOf(this.EXCLUDE) == -1)
         {
            _loc2_ = "Malformed unit test case: " + param1.name + "\n         Must contain " + this.INCLUDE + " or " + this.EXCLUDE + " in its name";
            Logger.error(this,"unitTestMOTD",_loc2_);
            return;
         }
         _loc3_ = this.isRelevantMOTD(param1);
         if(_loc3_ == false && param1.name.indexOf(this.INCLUDE) != -1)
         {
            if(param1.name.indexOf(this.ONLY))
            {
               Logger.info(this,"unitTestMOTD","EVALUATE for correctness: " + param1.name);
            }
            else
            {
               Logger.error(this,"unitTestMOTD","Failed to include: " + param1.name);
            }
            return;
         }
         if(_loc3_ == true && param1.name.indexOf(this.EXCLUDE) != -1)
         {
            if(param1.name.indexOf(this.ONLY))
            {
               Logger.info(this,"unitTestMOTD","EVALUATE for correctness: " + param1.name);
            }
            else
            {
               Logger.error(this,"unitTestMOTD","Failed to exclude: " + param1.name);
            }
            return;
         }
         Logger.info(this,"unitTestMOTD","PASS: " + param1.name);
      }
      
      public function get version() : int
      {
         return this.m_version;
      }
      
      private function dispatchNextMOTD() : void
      {
         if(this.m_scrolling)
         {
            this.m_requiresFurtherAction = false;
            this.checkDispatchAllShown();
         }
         else
         {
            this.m_shouldDisplayNextDialog = true;
            this.dispatchNextDialog(true);
         }
      }
      
      private function startDominationFlow() : void
      {
         DominationModeManager.instance.addEventListener(DominationModeManager.DOMINATION_MOTD_DONE,this.onDominationMOTDDone,false,0,true);
         DominationModeManager.instance.beginMOTDFlow();
         this.m_shouldDisplayNextDialog = false;
         this.m_requiresFurtherAction = true;
      }
      
      private function onDominationMOTDDone(param1:Event) : void
      {
         DominationModeManager.instance.removeEventListener(DominationModeManager.DOMINATION_MOTD_DONE,this.onDominationMOTDDone);
         this.dispatchNextMOTD();
      }
      
      private function showSurvivalModeWelcome() : void
      {
         SurvivalModeManager.instance.launchSurvivalMode(SurvivalModeManager.ENTRY_POINT_BUILDING);
      }
      
      public function get currentPopup() : MOTDPopup
      {
         return this.m_currentMOTDPopup;
      }
      
      public function get firstMOTDShown() : Boolean
      {
         return this.m_firstMOTDShown;
      }
   }
}

