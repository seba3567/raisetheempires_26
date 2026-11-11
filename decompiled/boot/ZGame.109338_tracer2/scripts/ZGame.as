package
{
   import Cache.Init.ZCacheInit;
   import Engine.Classes.ZEngineOptions;
   import Engine.Events.TransactionEvent;
   import Engine.Events.TransactionFaultEvent;
   import Engine.Init.InitializationManager;
   import Engine.Interfaces.IEngineComponent;
   import Engine.Managers.FreezeManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Managers.ZaspManager;
   import Engine.Transactions.Transaction;
   import ZQuest.Classes.QuestComponent;
   import ZQuest.Classes.QuestComponentOptions;
   import com.lia.utils.SWFProfiler;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.ZlingshotEmpires;
   import core.gamemode.GameModeManager;
   import core.managers.AlliancesManager;
   import core.managers.DebugManager;
   import core.managers.ExperimentsManager;
   import core.managers.FlashFeedManager;
   import core.managers.GameZaspManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.PVPManager;
   import core.managers.SurveyManager;
   import core.managers.assetLoadTracker.AssetLoadTracker;
   import core.managers.domination.DominationModeManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameQuestUtility;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitTestManager.UnitTestManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UI;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.strategicWorld.StrategicToggler;
   import dispatchers.MessageDispatcher;
   import dispatchers.UIDispatcher;
   import displays.cinema.IntroCinematics;
   import displays.popups.EpisodePopup;
   import displays.popups.GenericPopup;
   import displays.popups.LetterPopup;
   import displays.popups.PVPSlotMachinePopup;
   import displays.popups.SpeechPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.requests.RequestAskPartsDialog;
   import displays.screens.requests.RequestCrewDialog;
   import displays.screens.requests.RequestDialog;
   import displays.screens.requests.RequestGiftDialog;
   import displays.screens.requests.RequestGiftsSelectDialog;
   import displays.screens.requests.RequestInvasionHelpDialog;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.ui.ContextMenu;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import init.AssetLoadingInit;
   import init.ChallengeListInit;
   import init.FontMapperInit;
   import init.GameSettingsInit;
   import init.GlobalsInit;
   import init.LocalizationInit;
   import init.PreloaderInit;
   import init.SNAPIInit;
   import init.TerrainInit;
   import init.TransactionsInit;
   import init.UIInit;
   import interfaces.IGame;
   import rendering.road.RoadRendererComponent;
   import transactions.TClearFlashFeedTokens;
   import transactions.TFriendFlashSendThankYou;
   import transactions.TGetTargetingData;
   import transactions.TGetTargetingGroups;
   import transactions.TInitRequestFriends;
   import transactions.TSeenPrisonCampNotification;
   import transactions.TStreamPublishWithCallback;
   import transactions.TWorldLoad;
   import transactions.clans.TGetNeighborsClanInfo;
   import utils.ConnectionStatus;
   import utils.Watch2EarnHandler;
   import utils.ZGameUtils;
   import zlabs.ZConfig;
   import zlabs.ZGameBase;
   import zlabs.Zlab;
   import zlabs.debug.Console;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   [SWF(width="500", height="375", backgroundColor="#2d5c87", frameRate="30")]
   public class ZGame extends ZGameBase implements IGame
   {
      
      public static var m_instance:ZGame;
      
      private var layerPVP:Sprite;
      
      private var m_doZasp:Boolean;
      
      protected var m_feedOpenTime:Number;
      
      private var preloadInit:Boolean = false;
      
      private var preloaderInit:PreloaderInit = null;
      
      public function ZGame(param1:Object = null)
      {
         m_instance = this;
         GlobalEngine.initializationManager = new InitializationManager();
         GlobalEngine.engineOptions = new ZEngineOptions();
         GlobalEngine.engineOptions.zaspManagerClass = GameZaspManager;
         super(param1);
      }
      
      public static function get instance() : ZGame
      {
         return m_instance;
      }
      
      public function setupGame(param1:Object) : void
      {
      }
      
      public function startPreloaderInit() : void
      {
      }
      
      public function initQuest(param1:*) : void
      {
         ZGlobal.questData = param1;
         if(this.preloaderInit)
         {
            this.preloaderInit.dispatchEvent(new Event(PreloaderInit.QUEST_DATA_RECEIVED));
         }
      }
      
      public function initLocale(param1:*, param2:ApplicationDomain) : void
      {
         ZGlobal.localeData = param1;
         ZGlobal.localeAppDomain = param2;
         if(this.preloaderInit)
         {
            this.preloaderInit.dispatchEvent(new Event(PreloaderInit.LOCALE_DATA_RECEIVED));
         }
      }
      
      public function initGameSettings(param1:*) : void
      {
         ZGlobal.settingsData = param1;
         if(this.preloaderInit)
         {
            this.preloaderInit.dispatchEvent(new Event(PreloaderInit.SETTINGS_DATA_RECEIVED));
         }
      }
      
      public function initTInit(param1:*) : void
      {
         ZGlobal.initUserData = param1;
         if(this.preloaderInit)
         {
            this.preloaderInit.dispatchEvent(new Event(PreloaderInit.TINIT_COMPLETE));
         }
      }
      
      override protected function init() : void
      {
         var _loc3_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc1_:InitializationManager = GlobalEngine.initializationManager;
         if(parameters.splitLoader)
         {
            ZGlobal.splitLoader = true;
         }
         Config.usingIndexedSettings = parameters.settings_format == "true";
         ZGameQuestManager.init();
         var _loc2_:QuestComponentOptions = new QuestComponentOptions();
         _loc2_.questClass = ZGameQuest;
         _loc2_.questManager = ZGameQuestManager;
         _loc2_.questUtility = ZGameQuestUtility;
         _loc2_.compressedXML = Boolean(parameters) && Boolean(parameters.quest_url) && parameters.quest_url.toString().indexOf(".phpgz") > 0;
         _loc2_.preloaderData = ZGlobal.questData;
         if(!this.preloadInit)
         {
            GlobalEngine.engineOptions.addComponent(new QuestComponent(_loc2_));
         }
         if(GlobalEngine.engineOptions.zaspManagerClass)
         {
            GlobalEngine.zaspManager = new GlobalEngine.engineOptions.zaspManagerClass(GlobalEngine.stage) as ZaspManager;
         }
         if(Config.usingIndexedSettings)
         {
            _loc3_ = ZConfig.GAME_SETTINGS_PATH + "gameSettingsIndexed.xml";
         }
         else
         {
            _loc3_ = ZConfig.GAME_SETTINGS_PATH + "gameSettings.xml";
         }
         var _loc4_:String = ZConfig.BASE_PATH + "en_US.xml";
         if(parameters.game_config_url)
         {
            _loc3_ = parameters.game_config_url;
         }
         if(parameters.localization_url)
         {
            _loc4_ = parameters.localization_url;
         }
         if(parameters.URLvisitId)
         {
            ZGlobal.startupId = parameters.URLvisitId;
         }
         if(parameters.URLvisitMarket)
         {
            ZGlobal.visitMarket = Number(parameters.URLvisitMarket) != 0;
         }
         if(parameters.URLstartVisitingCameraPos)
         {
            ZGlobal.setStartVisitingCameraPos(parameters.URLstartVisitingCameraPos);
         }
         if(parameters.invader)
         {
            ZGlobal.PVPdefendOnStart = parameters.invader;
         }
         if(parameters.interstitial)
         {
            ZGlobal.interstitial = parameters.interstitial;
         }
         Logger.info(this,"init","Game Config URL: " + _loc3_);
         Logger.info(this,"init","Locale XML URL: " + _loc4_);
         var _loc5_:Boolean = parameters.skipFacebook == true;
         if(parameters.zcache)
         {
            _loc7_ = GlobalEngine.getFlashVar("sn_app_url").toString().split("/")[3];
            if(_loc7_ == null || _loc7_.length <= 0)
            {
               _loc7_ = "empiresandallies";
            }
            _loc1_.add(new ZCacheInit(parameters.zcache_url,_loc7_));
         }
         if(!this.preloadInit)
         {
            _loc1_.add(new GameSettingsInit(_loc3_));
            _loc1_.add(new LocalizationInit(_loc4_));
         }
         else
         {
            this.preloaderInit = new PreloaderInit(_loc2_,parameters);
            _loc1_.add(this.preloaderInit);
         }
         if(parameters.userPreload)
         {
            this.preloaderInit = new PreloaderInit(_loc2_,parameters);
            _loc1_.add(this.preloaderInit);
         }
         _loc1_.add(new SNAPIInit(_loc5_));
         _loc1_.add(new TransactionsInit(_loc5_,parameters.userPreload));
         _loc1_.add(new GlobalsInit(_loc5_));
         _loc1_.add(new AssetLoadingInit());
         _loc1_.add(new ChallengeListInit());
         _loc1_.add(new FontMapperInit());
         _loc1_.add(new UIInit());
         _loc1_.add(new TerrainInit());
         _loc1_.addEventListener(ProgressEvent.PROGRESS,this.onInitProgress,false,0,true);
         _loc1_.addEventListener(Event.COMPLETE,this.onAllInitComplete,false,0,true);
         PlayerStatsUIItem.initTransactionTracker();
         var _loc6_:Vector.<IEngineComponent> = GlobalEngine.engineOptions.engineComponents;
         if(_loc6_ != null)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc6_.length)
            {
               _loc6_[_loc8_].initialize();
               _loc8_++;
            }
         }
         _loc1_.execute();
         StrategicToggler.init();
         if(ZGameStats.active)
         {
            Logger.info(this,"init","Stats tracking enabled.");
         }
         ConnectionStatus.resetSessionTimer(ConnectionStatus.SESSION_DURATION_DEFAULT);
      }
      
      override protected function parametersLoaded() : void
      {
         super.parametersLoaded();
         GlobalEngine.parseFlashVars(this.parameters);
         InitializationManager.trackTime = getTimer() / 1000;
         if(parameters.trackTime)
         {
            ExternalInterface.call("statTracker.logLoadApp",parameters.trackTime.toString());
         }
         if(Boolean(parameters.is_staging) || Config.DEBUG_MODE)
         {
            Config.verboseLogging = Config.DEBUG_MODE;
         }
         else
         {
            Zlab.IS_SHIPPING_BUILD = true;
            Logger.disable();
            Config.verboseLogging = false;
         }
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         super.onAddedToStage(param1);
         this.layerPVP = new Sprite();
         Zlab.mainClass.addChild(this.layerPVP);
         PVPManager.instance.initialize(this.layerPVP);
         var _loc2_:ContextMenu = new ContextMenu();
         _loc2_.builtInItems.forwardAndBack = false;
         _loc2_.builtInItems.loop = false;
         _loc2_.builtInItems.play = false;
         _loc2_.builtInItems.rewind = false;
         _loc2_.builtInItems.zoom = false;
         _loc2_.builtInItems.quality = true;
      }
      
      private function onInitProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
      
      public function preloaderDone(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         if(param2)
         {
            StatsManager.count("zcache","preloader_optin","view");
         }
         if(param3)
         {
            StatsManager.count("zcache","preloader_optin","yes");
         }
         if(param1)
         {
            StatsManager.count("zcache","preloader_optin","enable");
         }
      }
      
      private function makeProfiler() : void
      {
         SWFProfiler.init(stage,this);
      }
      
      private function onAllInitComplete(param1:Event) : void
      {
         var initManager:InitializationManager;
         var dispatcher:EventDispatcher;
         var experimentManager:ExperimentsManager;
         var jsTargetingExperiment:String;
         var jsTargetingVariant:int;
         var fluidCanvasVariant:int;
         var kateLoader:URLLoader = null;
         var kateSig:Object = null;
         var kateReq:URLRequest = null;
         var kateParams:URLVariables = null;
         var currentTimeMS:Number = NaN;
         var diffTimeMS:Number = NaN;
         var dominance:Boolean = false;
         var ev:Event = param1;
         Logger.info(this,"onAllinitComplete","Completed all init commands!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
         ExternalInterface.call("statTracker.logInitActions",GlobalEngine.initializationManager.initTimes);
         if(Config.DEBUG_MODE)
         {
            this.makeProfiler();
         }
         if(parameters.is_kate_bot)
         {
            kateLoader = new URLLoader();
            kateSig = GlobalEngine.zyParams;
            kateReq = new URLRequest(Config.BASE_PATH + "keynote.php");
            kateParams = new URLVariables();
            kateParams.zySnid = kateSig.zySnid;
            kateParams.zyAuthHash = kateSig.zyAuthHash;
            kateParams.zySig = kateSig.zySig;
            kateReq.data = kateParams;
            try
            {
               kateLoader.load(kateReq);
            }
            catch(error:Error)
            {
               Logger.error(this,"onAllinitComplete","Unable to send request to the KATE web service");
            }
         }
         dispatchEvent(new Event(Event.COMPLETE));
         this.createLoggerCommands();
         initManager = ev.target as InitializationManager;
         initManager.removeEventListener(ProgressEvent.PROGRESS,this.onInitProgress);
         initManager.removeEventListener(Event.COMPLETE,this.onAllInitComplete);
         dispatcher = ev.target as EventDispatcher;
         dispatcher.removeEventListener(ProgressEvent.PROGRESS,this.onInitProgress);
         dispatcher.removeEventListener(Event.COMPLETE,this.onAllInitComplete);
         this.showWorldGamesSpeech();
         if(parameters.trackTime)
         {
            currentTimeMS = new Date().getTime();
            diffTimeMS = currentTimeMS - Number(parameters.trackTime) / 1000000;
            ExternalInterface.call("statTracker.logInteractive",parameters.trackTime.toString(),parameters.xTrackTime.toString());
            Logger.info(this,"T5","trackTime=" + parameters.trackTime.toString() + ",currentTime=" + currentTimeMS + ",diff=" + diffTimeMS);
            AssetLoadTracker.GlobalDispatcher.addEventListener(AssetLoadTracker.GLOBAL_ASSETS_LOADED,this.onAssetLoadComplete);
         }
         TransactionManager.getInstance().addEventListener(TransactionFaultEvent.FAULT,this.onTransactionFault,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionEvent.QUEUE_LIMIT_EXCEEDED,this.onTransactionQueueLimitExceeded,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionEvent.QUEUE_LIMIT_NORMAL,this.onTransactionQueueLimitNormal,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionEvent.VERSION_MISMATCH,this.onTransactionVersionMismatch,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionEvent.RETRY_SUCCESS,this.onTransactionRetrySuccess,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionFaultEvent.RETRY,this.onTransactionRetry,false,0,true);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("enableAllInput",this.enableAllInput);
               ExternalInterface.addCallback("disableAllInput",this.disableAllInput);
               ExternalInterface.addCallback("logShowFeedDialog",this.logShowFeedDialog);
               ExternalInterface.addCallback("logCloseFeedDialog",this.logCloseFeedDialog);
               ExternalInterface.addCallback("permissionDialogClosed",this.permissionDialogClosed);
               ExternalInterface.addCallback("visitNeighbor",this.visitNeighbor);
               ExternalInterface.addCallback("inAppPurchaseCallback",this.inAppPurchaseCallback);
               ExternalInterface.addCallback("inAppPurchaseCompleted",this.inAppPurchaseCompleted);
               ExternalInterface.addCallback("openStarterPack",this.openStarterPack);
               ExternalInterface.addCallback("openPayerPack",this.openPayerPack);
               ExternalInterface.addCallback("exportScreenshot",this.exportScreenshot);
               ExternalInterface.addCallback("request2Complete",this.request2Complete);
               ExternalInterface.addCallback("inviteTabDialog",this.inviteTabDialog);
               ExternalInterface.addCallback("giftsTabDialog",this.giftsTabDialog);
               ExternalInterface.addCallback("creditsPurchaseComplete",this.creditsPurchaseComplete);
               ExternalInterface.addCallback("mute",function():void
               {
                  Zlab.soundManager.muted = true;
               });
               ExternalInterface.addCallback("unmute",function():void
               {
                  Zlab.soundManager.muted = false;
               });
               TStreamPublishWithCallback.init();
            }
            else
            {
               StatsManager.count("errors","external_interface_not_supported");
            }
         }
         catch(error:Error)
         {
            StatsManager.count("errors","external_interface_threw_error");
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SPLIT_LOADER) == ExperimentsManager.EXPERIMENT_SPLIT_LOADER_VARIANT_7)
         {
            dominance = Zlab.getFlashVar("dominance") == "true" ? true : false;
            TransactionManager.addTransaction(new TInitRequestFriends(dominance));
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_WTE_TARGETING) == ExperimentsManager.WTE_BOUNTY_ENABLED_VARIANT)
         {
            TransactionManager.addTransaction(new TGetTargetingGroups());
         }
         experimentManager = ExperimentsManager.instance;
         jsTargetingExperiment = ExperimentsManager.EXPERIMENT_WTE_JS_TARGETING;
         jsTargetingVariant = experimentManager.getExperimentVariant(jsTargetingExperiment);
         if(jsTargetingVariant === 1)
         {
            TransactionManager.addTransaction(new TGetTargetingData());
         }
         else
         {
            Logger.print(this,"W2E: Client targeting data experiment disabled. Experiment variant: " + jsTargetingVariant);
         }
         Logger.info(this,"ViralsManager","initializing survey");
         SurveyManager.getInstance().initializeSurveyOverlay(ZGlobal.overlaySurveyURL);
         ViralsManager.instance;
         if(GlobalEngine.zaspManager)
         {
            GlobalEngine.zaspManager.zaspInteractive();
         }
         if(parameters.mute)
         {
            Zlab.soundManager.muted = true;
         }
         new ZlingshotEmpires();
         fluidCanvasVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FLUID_CANVAS);
         Logger.debug(this,"onAllInitComplete","Experiment variant for fluid canvas is " + fluidCanvasVariant);
         ExternalInterface.call("onGameLoaded",!ZGlobal.player.getSeenFlag(IntroCinematics.INTRO),parameters.zsc_autopop != null,fluidCanvasVariant);
         if(AlliancesManager.isExperimentEnabled())
         {
            AlliancesManager.instance.showConfirmationPopup();
            TransactionManager.addTransaction(new TGetNeighborsClanInfo());
         }
         Watch2EarnHandler.initW2e();
         if(ExperimentsManager.instance.getExperimentVariant(FlashFeedManager.EXPERIMENT_FLASHFEED_NEW) >= 1)
         {
            TransactionManager.addTransaction(new TClearFlashFeedTokens());
         }
      }
      
      private function onAssetLoadComplete(param1:Event) : void
      {
         ExternalInterface.call("statTracker.logLoadComplete",parameters.trackTime.toString());
      }
      
      public function onCinematicOpen(param1:Event) : void
      {
         param1.target.removeEventListener(Event.OPEN,this.onCinematicOpen);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function performVisitNeighbor(param1:String, param2:Boolean, param3:int, param4:Boolean) : void
      {
         TransactionManager.addTransaction(new TWorldLoad(param1,PVPManager.VISIT_MODE_NONE,{"dbg":param3},param2),true);
      }
      
      public function visitNeighbor(param1:String, param2:int) : void
      {
         this.performVisitNeighbor(param1,false,param2,ZGlobal.player.isNewPlayer);
      }
      
      public function showWorldGamesSpeech() : void
      {
         if(ZGlobal.player.showWorldGamesSpeech == 1)
         {
            PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_03",this.onSpeechClose),0,true,false);
         }
         else if(ZGlobal.player.showWorldGamesSpeech == 2)
         {
            PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_04",this.onSpeechClose),0,true,false);
         }
      }
      
      public function onSpeechClose(param1:Event) : void
      {
      }
      
      public function inAppPurchaseCallback(param1:Object) : void
      {
         var response:Object = param1;
         var status:String = "FAILED: ";
         try
         {
            if(response.success)
            {
               status = "SUCCEEDED";
            }
            else
            {
               status += "error code: " + response.error_code + ", msg: " + response.error_message;
            }
         }
         catch(e:Error)
         {
         }
         Logger.info(this,"inAppPurchaseCallback",status);
      }
      
      public function inAppPurchaseCompleted(param1:Object) : void
      {
         var response:Object = param1;
         var status:String = "FAILED: ";
         var success:Boolean = false;
         try
         {
            if(response.status != undefined)
            {
               status = "SUCCESS: order_id: " + response.order_id + "status: " + response.status;
               success = true;
            }
            else
            {
               status += "error_code: " + response.error_code + " error_message: " + response.error_message;
            }
         }
         catch(e:Error)
         {
         }
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_IN_APP_PURCHASE_COMPLETE,{"success":success}));
         Logger.info(this,"inAppPurchaseCompleted",status);
      }
      
      public function openStarterPack() : void
      {
         var _loc1_:String = "none";
         if(PromoManager.instance.meetsCriteriaStarterPack(false))
         {
            PromoManager.instance.openStarterPackPopup();
         }
         StatsManager.count("dialog","BannerBuyPage_starter_pack","yes");
         Logger.info(this,"openStarterPack",_loc1_);
      }
      
      public function openPayerPack() : void
      {
         var _loc1_:String = "none";
         if(PromoManager.instance.meetsCriteriaRepeatPayerPack(false))
         {
            PromoManager.instance.openRepeatPayerPackPopup();
         }
         StatsManager.count("dialog","BannerBuyPage_payer_pack","yes");
         Logger.info(this,"openPayerPack",_loc1_);
      }
      
      private function onTransactionFault(param1:TransactionFaultEvent) : void
      {
         if(Config.DEBUG_MODE)
         {
            ConnectionStatus.showTransactionFaultDialog("errorData: " + param1.errorData,GenericPopup.MOOD_SURPRISED);
         }
         else if(param1.errorType == Transaction.OUTDATED_GAME_VERSION)
         {
            this.onTransactionVersionMismatch(param1);
         }
         else
         {
            ConnectionStatus.showTransactionFaultDialog(ZGameUtils.ZlocT("Main","TransactionFault"),GenericPopup.MOOD_SURPRISED);
         }
      }
      
      private function onTransactionVersionMismatch(param1:Event) : void
      {
         var _loc2_:String = ZGameUtils.ZlocT("Main","OutdatedGameVersion");
         ConnectionStatus.showTransactionFaultDialog(_loc2_,GenericPopup.MOOD_HAPPY);
      }
      
      private function onTransactionRetrySuccess(param1:TransactionEvent) : void
      {
         ConnectionStatus.stopTimeout();
      }
      
      private function onTransactionRetry(param1:TransactionFaultEvent) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("gameConnectionMaxTimeout",30) * 1000;
         ConnectionStatus.startTimeout(ConnectionStatus.TIMEOUT_CONNECTION_LOST,_loc2_);
      }
      
      private function onTransactionQueueLimitExceeded(param1:TransactionEvent) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("gameSaveMaxTimeout",25) * 1000;
         ConnectionStatus.startTimeout(ConnectionStatus.TIMEOUT_SAVE_GAME,_loc2_);
      }
      
      private function onTransactionQueueLimitNormal(param1:TransactionEvent) : void
      {
         ConnectionStatus.stopTimeout();
      }
      
      override public function disableAllInput() : void
      {
         super.disableAllInput();
         this.m_doZasp = GlobalEngine.zaspManager.zaspIsGameActive();
         GlobalEngine.zaspManager.zaspGameStateDeactivate(null);
         Logger.print(ZGame,"disableAllInput() set fps=1");
         Zlab.mainStage.frameRate = 30;
      }
      
      override public function enableAllInput() : void
      {
         super.enableAllInput();
         Logger.print(ZGame,"enableAllInput() set fps=30");
         Zlab.mainStage.frameRate = 30;
         if(this.m_doZasp)
         {
            GlobalEngine.zaspManager.zaspGameStateActivate(null);
         }
      }
      
      public function logShowFeedDialog() : void
      {
         this.m_feedOpenTime = getTimer();
         StatsManager.count("farm_world_action","Feed_Open");
      }
      
      public function permissionDialogClosed(param1:Boolean) : void
      {
         GlobalEngine.socialNetwork.onPermissionDialogClosed(param1);
      }
      
      public function logCloseFeedDialog(param1:Object = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:Number = getTimer();
         var _loc3_:int = _loc2_ - this.m_feedOpenTime;
         _loc3_ = int(_loc3_ / 10000);
         if(_loc3_ > 6)
         {
            _loc4_ = ">1 minute";
         }
         else
         {
            _loc4_ = Number(_loc3_ + 1).toString() + "0 seconds";
         }
         if(param1 != null && param1 is String)
         {
            _loc5_ = param1 as String;
            switch(_loc5_)
            {
               case "posted":
                  StatsManager.count("farm_world_action","Feed_Published",_loc4_);
                  break;
               case "closed":
                  StatsManager.count("farm_world_action","Feed_Closed",_loc4_);
                  break;
               case "skipped":
                  StatsManager.count("farm_world_action","Feed_Skipped",_loc4_);
                  break;
               default:
                  StatsManager.count("farm_world_action","Feed_Unknown",_loc4_);
            }
         }
         else
         {
            StatsManager.count("farm_world_action","Feed_Close",_loc4_);
         }
      }
      
      public function createLoggerCommands() : void
      {
         Console.registerCommand("sorthud",function():void
         {
            PromoManager.instance.sortIcons();
         },"Sort HUD icons");
         Console.registerCommand("isodebug",function():void
         {
            Zlab.RENDER_DEBUG_MODE = !Zlab.RENDER_DEBUG_MODE;
            if(Zlab.RENDER_DEBUG_MODE)
            {
               Logger.print(Console,"Enabled ISO debug display.");
            }
            UIDispatcher.instance.dispatchEvent(new Event("ISOdebugDisplay"));
         },"Show ISO volumes cubes");
         Console.registerCommand("build",function(param1:int):void
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent("cycleBuildIcons",param1));
         },"Cycle BuildManager buildability areas.");
         Console.registerCommand("debugtext",function():void
         {
            UIDispatcher.instance.dispatchEvent(new Event("toggleDebugText"));
         },"Toggle debug text.");
         Console.registerCommand("place",function(param1:String):void
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DebugManager.DEBUG_PLACEITEM,param1));
         },"Place something.");
         Console.registerCommand(DebugManager.DEBUG_MULTIITEM,function():void
         {
            UIDispatcher.instance.dispatchEvent(new Event(DebugManager.DEBUG_MULTIITEM));
         },"Add multiple objects of same type (toggle).");
         Console.registerCommand(DebugManager.DEBUG_OVERLAYS,function(param1:String):void
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DebugManager.DEBUG_OVERLAYS,param1.toLowerCase() == "on"));
         },"Set overlay active state.");
         Console.registerCommand(DebugManager.DEBUG_CAMPAIGNDEBUG,function():void
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DebugManager.DEBUG_CAMPAIGNDEBUG,null));
         },"Set campaign debug mode.");
         Console.registerCommand("playIntro",function():void
         {
            var _loc1_:IntroCinematics = new IntroCinematics(true);
            WindowManager.instance.playCinematics(_loc1_);
         },"Plays intro cinematics.");
         Console.registerCommand("clearroads",function():void
         {
            var _loc1_:RoadRendererComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
            _loc1_.clearAllRoads();
         },"Clears all roads on islandWorld");
         Console.registerCommand(DebugManager.DEBUG_ABCOMBAT,function():void
         {
            UIDispatcher.instance.dispatchEvent(new Event(DebugManager.DEBUG_ABCOMBAT));
         },"Toggle AB Combat.");
         Console.registerCommand("doUnitTest",function(param1:String):void
         {
            UnitTestManager.instance.dispatchEvent(new WorldEvent(UnitTestManager.START_UNIT_TESTS,param1));
         },"Runs specified unit test or all for all tests");
         Console.registerCommand("setTutorialStep",function(param1:String):void
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.SET_TUTORIAL_STEP,param1));
         },"Sets the tutorial to a specific step by string name.  Note only works on steps that have a text field set.");
         Console.registerCommand("debugTemplate",function():void
         {
            Logger.print(ZGame,"Downloading index.template.html...");
            ExternalInterface.call("debugTemplate");
         },"Gets new debug index.template.html from server (call this when running on canvas!)");
         Console.registerCommand("zid",function():void
         {
            Logger.print(ZGame,"Your ZID: " + ZGlobal.player.uid);
         },"Prints out your ZID");
         Console.registerCommand("hostzid",function():void
         {
            Logger.print(ZGame,"Host ZID: " + ZGlobal.hostPlayer.uid);
         },"Prints out the current host ZID");
         Console.registerCommand("flashdump",function():void
         {
            DebugManager.instance.flashDump();
         },"Test");
         Console.registerCommand("showDossier",function(param1:String):void
         {
            PopupManager.instance.push(new LetterPopup(param1));
         },"Displays the dossier popup with the given id");
         Console.registerCommand("showSpeech",function(param1:String):void
         {
            PopupManager.instance.push(new SpeechPopup(param1));
         },"Displays the speech popup with the given id");
         Console.registerCommand("showEpisode",function(param1:String):void
         {
            PopupManager.instance.push(new EpisodePopup(param1));
         },"Dispalys the episode popup with the given id");
         Console.registerCommand("poolfx",function():void
         {
            var _loc1_:Boolean = DebugManager.instance.togglePoolfx();
            Logger.print(ZGame,"pool fx value: " + _loc1_);
         },"Toggle 2D FX pooling");
         Console.registerCommand("vegas",function():void
         {
            WindowManager.instance.push(new PVPSlotMachinePopup());
         },"Display Global PVP Slot Machine");
         Console.registerCommand("gifts",function():void
         {
            PopupManager.instance.push(new RequestGiftsSelectDialog());
         },"Display Gifts Select Dialog");
         Console.registerCommand("showTransactionFaultDialog",function():void
         {
            ConnectionStatus.showTransactionFaultDialog(ZGameUtils.ZlocT("Main","RefreshGame"),GenericPopup.MOOD_SURPRISED);
         },"Displays a connection error dialog that will have \'refresh\' and \'report bug\' buttons if experiment empire_report_bug_popup is set to variant 3 (ON).");
         Console.registerCommand("simulateMOTDHudClick",function():void
         {
            MessageOfTheDayManager.instance.hudOpenMOTD();
         },"Simulates opening the MOTD from menu button click.");
         Console.registerCommand("showConnectionError",function(param1:String = null):void
         {
            var _loc2_:String = null;
            switch(param1)
            {
               case ConnectionStatus.TIMEOUT_CONNECTION_LOST:
                  _loc2_ = ZGameUtils.ZlocT("Main","ConnectionLostTimeout");
                  break;
               case ConnectionStatus.TIMEOUT_SAVE_GAME:
                  _loc2_ = ZGameUtils.ZlocT("Main","SaveGameTimeout");
                  break;
               default:
                  _loc2_ = ZGameUtils.ZlocT("Main","RefreshGame");
            }
            var _loc3_:String = ZGameUtils.ZlocT("Main","RefreshButtonAction");
            var _loc4_:String = _loc2_ + "\n\n" + _loc3_;
            var _loc5_:GenericPopup = GenericPopup1B.NewRefresh(_loc4_,null,GenericPopup.MOOD_SURPRISED);
            PopupManager.instance.push(_loc5_);
         },"Displays a connection error dialog with the given type");
         Console.registerCommand("gpvpw",function():void
         {
            PVPManager.instance.cheatGPVPWin();
         },"Locally advance # of GPVP wins within a fight batch.");
         Console.registerCommand("gpvpc",function():void
         {
            PVPManager.instance.awardClaimed();
         },"Locally advance # of GPVP wins within a fight batch.");
         Console.registerCommand("qtr",function():void
         {
            ZGlobal.player.questTrees.resetQuestTree("QT01");
         },"");
         Console.registerCommand("lowQuality",function():void
         {
            ZGlobal.lowQualityMode = true;
            Zlab.mainStage.quality = "MEDIUM";
            UIDispatcher.instance.dispatchEvent(new WorldEvent(ZGlobal.LOW_QUALITY_MODE));
         },"Enable low-quality rendering mode");
         Console.registerCommand("highQuality",function():void
         {
            ZGlobal.lowQualityMode = false;
            Zlab.mainStage.quality = "HIGH";
            UIDispatcher.instance.dispatchEvent(new WorldEvent(ZGlobal.LOW_QUALITY_MODE));
         },"Disable low-quality rendering mode");
         Console.registerCommand(Player.HAS_SEEN_TITAN_BATTLE,function():void
         {
            ZGlobal.player.setSeenFlag(Player.HAS_SEEN_TITAN_BATTLE);
            ZGlobal.player.setSeenFlag(Player.HAS_SEEN_TITAN_BATTLE_QT057);
         },"Simulate the player having used a Titan in a fight");
         Console.registerCommand("dlp1",function():void
         {
            UI.displayDominanceLevelUpDialog(1);
         },"");
         Console.registerCommand("dlp2",function():void
         {
            UI.displayDominanceLevelUpDialog(2);
         },"");
         Console.registerCommand("dlp3",function():void
         {
            UI.displayDominanceLevelUpDialog(3);
         },"");
         Console.registerCommand("dlp4",function():void
         {
            UI.displayDominanceLevelUpDialog(4);
         },"");
         Console.registerCommand("domchat",function():void
         {
            var _loc1_:String = "31015344831";
            DominationModeManager.instance.getDominationModeChatHistory(_loc1_);
         },"Displays the domination mode chat dialog");
         Console.registerCommand("jc",function(param1:String):void
         {
            var _loc2_:TFriendFlashSendThankYou = new TFriendFlashSendThankYou("20120474510","msg");
            TransactionManager.addTransaction(_loc2_,true);
         },"Displays the domination mode chat dialog");
         Console.registerCommand("blowupParliament",function():void
         {
            MayhemManager.instance.blowUpParliament();
         },"Blowup Parliament");
         Console.registerCommand("launchMissile",function():void
         {
            MayhemManager.instance.saveParliament();
         },"Launch Anti-Missile Missile");
         Console.registerCommand("seen",function(param1:String, param2:String):void
         {
            TransactionManager.addTransaction(new TSeenPrisonCampNotification(param1,param2));
         },"Remove Prison Camp Notification");
      }
      
      public function getZaspDetailString() : String
      {
         var _loc4_:String = null;
         var _loc1_:* = PopupManager.instance.displayedWindow;
         if(_loc1_ != null)
         {
            return getQualifiedClassName(_loc1_);
         }
         var _loc2_:IWindow = WindowManager.instance.displayedWindow;
         if(_loc2_ != null)
         {
            return getQualifiedClassName(_loc2_);
         }
         var _loc3_:Array = GameModeManager.instance.getActiveGameModes();
         var _loc5_:Array = new Array();
         var _loc6_:Number = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc4_ = getQualifiedClassName(_loc3_[_loc6_]);
            _loc5_.push(_loc4_.substring(_loc4_.lastIndexOf("::") + 2));
            _loc6_++;
         }
         return _loc5_.join(",");
      }
      
      public function exportScreenshot() : String
      {
         var retval:String = null;
         try
         {
            retval = FreezeManager.getInstance().exportScreenshot();
         }
         catch(e:Error)
         {
            retval = null;
         }
         return retval;
      }
      
      public function request2Complete(param1:Array, param2:String) : void
      {
         var _loc3_:String = null;
         if(param1 != null)
         {
            switch(param2)
            {
               case RequestDialog.TYPE_RECENTLY_PLAYED:
                  ZGlobal.player.addActiveGiftRequest(param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestGiftDialog.DIALOG_TOASTER,{"count":param1.length});
                  break;
               case RequestDialog.TYPE_GIFT:
                  ZGlobal.player.addActiveGiftRequest(param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestGiftDialog.DIALOG_TOASTER,{"count":param1.length});
                  break;
               case RequestDialog.TYPE_CREW:
                  ZGlobal.player.addActiveRequest(RequestDialog.REQUEST_CREW,param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestCrewDialog.DIALOG_TOASTER,{"count":param1.length});
                  break;
               case RequestDialog.TYPE_GIFT_REQUEST:
                  ZGlobal.player.addActiveHelpRequest(param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestAskPartsDialog.DIALOG_TOASTER,{"count":param1.length});
                  break;
               case RequestDialog.TYPE_NEIGHBOR:
                  ZGlobal.player.addActiveRequest(RequestDialog.REQUEST_NEIGHBOR_REQUEST,param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestNeighborDialog.DIALOG_TOASTER,{"count":param1.length});
                  break;
               case RequestDialog.TYPE_INVASION_HELP:
                  ZGlobal.player.addActiveRequest(RequestDialog.REQUEST_REPEL_INVASION,param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestInvasionHelpDialog.DIALOG_TOASTER,{"count":param1.length});
                  break;
               case RequestDialog.TYPE_ALLIANCE:
                  ZGlobal.player.addActiveRequest(RequestDialog.REQUEST_ALLIANCE_REQUEST,param1);
                  _loc3_ = ZGameUtils.ZlocT("Dialogs",RequestNeighborDialog.DIALOG_TOASTER,{"count":param1.length});
                  AlliancesManager.instance.updateJoinRequest(param1);
            }
            if(_loc3_ != null)
            {
               PlayerFeedbackManager.instance.displayFeedback(_loc3_);
            }
         }
      }
      
      public function inviteTabDialog() : void
      {
         if(!RequestNeighborDialog.instanceExists())
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_INVITE_TAB,ExperimentsManager.EXPERIMENT_REQUEST2_MFS,RequestDialog.SUBTYPE_TAB));
         }
      }
      
      public function giftsTabDialog() : void
      {
         if(!RequestGiftsSelectDialog.instanceExists())
         {
            PopupManager.instance.push(new RequestGiftsSelectDialog());
         }
      }
      
      public function creditsPurchaseComplete(param1:String) : void
      {
         Logger.print(this,"**** creditsPurchaseComplete(), status is " + param1 + " (success == \'settled\')");
         if(param1 == "settled")
         {
            MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.GRANT_FACEBOOK_CREDIT_OFFER1));
         }
      }
   }
}

