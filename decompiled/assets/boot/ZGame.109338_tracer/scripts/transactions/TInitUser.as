package transactions
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.AllianceQuestManager;
   import core.managers.AlliancesManager;
   import core.managers.BlackMarketManager;
   import core.managers.BookmarksIncentiveManager;
   import core.managers.BuyBackManager;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.managers.FightMeterManager;
   import core.managers.FlamingUnitManager;
   import core.managers.FlashFeedManager;
   import core.managers.FriendManager;
   import core.managers.LEUnitDiscountManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.MatchMakingManager;
   import core.managers.MechLabDailyRewardManager;
   import core.managers.MegaseriesManager;
   import core.managers.PVPManager;
   import core.managers.PriceTestManager;
   import core.managers.ScrapManager;
   import core.managers.SuperOreManager;
   import core.managers.TierSurfacingManager;
   import core.managers.TreasureVaultManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.ZRTManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.grantEpManager.GrantEpManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.managers.promoManager.LowEPPromotion;
   import core.managers.promoManager.PromoManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralSurfacingManager.ViralSurfacingManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.permission.PermissionTypes;
   import core.player.Friend;
   import core.player.Player;
   import core.worlds.AbstractWorld;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.UIDispatcher;
   import displays.cinema.IntroCinematics;
   import displays.popups.BookmarkFavoriteIncentivePopup;
   import displays.popups.BookmarkFavoriteInstallPopup;
   import displays.popups.DailyBonusPopup;
   import displays.popups.IncentivePopup;
   import displays.popups.LocalePopup;
   import displays.popups.ReactivationGiftPopup;
   import displays.popups.TOSPPPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.oreInviteScreen.OreInvite;
   import events.NeighborsEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import init.ActionQueue;
   import init.PostInit.DoDisplayDialog;
   import init.PostInit.DoDominationScreen;
   import init.PostInit.DoLeaderboards;
   import init.PostInit.DoMessageOfTheDay;
   import init.PostInit.DoPlayCinematics;
   import init.PostInit.DoRUXScreen;
   import init.PostInit.DoStartEpisode;
   import init.PostInit.DoStartMusic;
   import init.PostInit.DoStartPromoManager;
   import init.PostInit.DoStartQuests;
   import init.PostInit.DoStartTutorial;
   import init.PostInit.DoStartViralSurfacingManager;
   import init.PostInit.DoStartWorldEvents;
   import init.PostInit.DoSubscriptionsClickTest;
   import resources.PostLoadManager;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class TInitUser extends Transaction
   {
      
      public static const EVENT_COMPLETE:String = "eventComplete";
      
      private static var m_initComplete:Boolean = false;
      
      protected var m_firstName:String;
      
      private const NUM_SEEN_EXPAND_FARM:int = 2;
      
      private const SHOW_EXPAND_FARM_SIZE:int = 14;
      
      private const SHOW_EXPAND_MIN_LEVEL:int = 4;
      
      private var m_bookmarkCash:int = 0;
      
      public function TInitUser(param1:String)
      {
         super();
         this.m_firstName = param1;
      }
      
      public static function get initComplete() : Boolean
      {
         return m_initComplete;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.initUser",this.m_firstName);
      }
      
      public function amfComplete(param1:Object) : void
      {
         Logger.info(this,"amfComplete","amf Complete");
         onAmfComplete(param1);
         Logger.info(this,"amfComplete","amf complete");
      }
      
      public function complete(param1:Object) : void
      {
         this.onComplete(param1);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var s:String = null;
         var t:TLogClientString = null;
         var result:Object = param1;
         if(Config.DEBUG_MODE)
         {
            Logger.info(this,"onComplete"," Do internalInitUser");
            this.internalInitUser(result);
            Logger.info(this,"onComplete"," Done internalInitUser");
         }
         else
         {
            try
            {
               Logger.info(this,"onComplete"," Do internalInitUser");
               this.internalInitUser(result);
               Logger.info(this,"onComplete"," Done internalInitUser");
            }
            catch(error:Error)
            {
               s = error.getStackTrace();
               Logger.info(this,"onComplete","Failure " + s);
               t = new TLogClientString(s);
               TransactionManager.addTransaction(t,true);
            }
         }
      }
      
      private function getFeed(param1:Object) : void
      {
         Logger.info(this,"getFeed","Getting an in-game feed");
      }
      
      private function internalInitUser(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Boolean = false;
         var _loc7_:Number = NaN;
         var _loc8_:Boolean = false;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:AbstractWorld = null;
         var _loc15_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc17_:Timer = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:Dictionary = null;
         var _loc24_:String = null;
         var _loc25_:SWFPopUp = null;
         var _loc26_:Object = null;
         var _loc27_:String = null;
         var _loc28_:Array = null;
         var _loc29_:Boolean = false;
         var _loc30_:Array = null;
         var _loc31_:String = null;
         var _loc32_:XML = null;
         var _loc33_:String = null;
         var _loc34_:Boolean = false;
         var _loc35_:String = null;
         var _loc36_:int = 0;
         var _loc37_:int = 0;
         var _loc38_:GameItem = null;
         var _loc39_:Number = NaN;
         var _loc40_:Date = null;
         var _loc41_:Number = NaN;
         Logger.info(this,"onComplete","1");
         if(param1 != null)
         {
            GlobalEngine.updateTimers();
            _loc2_ = param1;
            if(ZGlobal.player != null)
            {
               if(param1.userInfo.player.lastTrackingTimestamp + 24 * 60 * 60 < GlobalEngine.serverTime / 1000)
               {
                  _loc17_ = new Timer(30000 + Math.random() * 90000,1);
                  _loc17_.addEventListener(TimerEvent.TIMER,ZGameStats.doDeferredTracking);
                  _loc17_.start();
               }
               _loc3_ = Zlab.getFlashVar("dominance") == "true" ? true : false;
               Logger.info(this,"internalInitUser","Dominance flash var is: " + Zlab.getFlashVar("dominance"));
               Logger.info(this,"internalInitUser","Dominance value is: " + _loc3_);
               _loc4_ = _loc3_ ? Zlab.getFlashVar("dominanceTab").toString() : "";
               Logger.info(this,"internalInitUser","DominanceTab value is: " + _loc4_);
               _loc5_ = param1.neighbors;
               ZGlobal.player.setUnlockedResource(param1.unlockedResource);
               if(_loc5_)
               {
                  Logger.info(this,"internalInitUser","hasNeighbors Length: " + _loc5_.length);
                  _loc18_ = WorldResourceManager.instance.firstRareResourceIndex;
                  _loc19_ = WorldResourceManager.instance.numRareResources;
                  _loc20_ = _loc18_ + _loc19_;
                  while(_loc21_ < _loc5_.length)
                  {
                     ZGlobal.player.neighbors[_loc5_[_loc21_].uid] = _loc5_[_loc21_];
                     _loc22_ = parseInt(_loc5_[_loc21_].resource);
                     if(_loc5_[_loc21_].uid != Player.FAKE_PLAYER_ID && _loc22_ >= _loc18_ && _loc22_ < _loc20_)
                     {
                        _loc23_ = ZGlobal.player.oreNeighbors;
                        if(_loc23_[_loc22_] == null)
                        {
                           _loc23_[_loc22_] = new Array();
                        }
                        _loc23_[_loc22_].push(String(_loc5_[_loc21_].uid));
                     }
                     _loc21_++;
                  }
               }
               _loc6_ = Boolean(param1.showBookmark);
               _loc7_ = -1;
               _loc8_ = Boolean(param1.firstDay);
               ViralSurfacingManager.instance.setSeenFlags(param1.userInfo.player.viralSurfacing.seen);
               ViralSurfacingManager.instance.setSeenCounts(param1.userInfo.player.viralSurfacing.counts);
               ZGlobal.immunityTimeVariant = _loc2_.immunityTimeVariant;
               ExperimentsManager.instance.setExperiments(_loc2_.experiments);
               ExperimentsManager.instance.dispatchEvent(new Event(ExperimentsManager.EXPERIMENTS_LOADED));
               SurvivalModeManager.instance.init(param1);
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POPUP_BLOCKER) == 1)
               {
                  WindowManager.blockAllPopups();
               }
               if(param1.prisonerInfo)
               {
                  PrisonCampManager.instance.setInfo(param1.prisonerInfo);
               }
               PVPManager.instance.init(param1);
               DominationModeManager.instance.initData(param1.pvp);
               VisitorManager.instance.storeCrewAutoFilledBuildings(param1.autoFilledCrewBuildings);
               CrewManager.instance.initUser(param1);
               ZGlobal.init(param1);
               PriceTestManager.instance.init(param1.priceTestSettings);
               BuyBackManager.instance.init(param1.buyBackSettings);
               if(ExperimentsManager.instance.getExperimentVariant("empire_deathmatch_master") == 3)
               {
                  DeathMatchManager.instance.init(param1.userInfo.player.dm_band,param1.userInfo.player.dm_endTS,param1.pvp.dm_roomInfo,param1.userInfo.world.deathMatch);
                  DeathMatchManager.instance.setDeathMatchConstants(param1.DEATHMATCH_FRAG_LIMITS,param1.DEATHMATCH_CACHE_TTL,param1.DEATHMATCH_OPP_COOLDOWN,param1.DEATHMATCH_STANDARD_REWARDS,param1.DEATHMATCH_GRAND_REWARDS,param1.DEATHMATCH_START_TIME,param1.DEATHMATCH_DURATION);
                  DeathMatchManager.instance.clearOpponentCache();
               }
               _loc9_ = param1.clansInfo;
               param1 = param1.userInfo;
               _loc10_ = Player.isProgressNewPlayer(param1.player.tutorialProgress);
               ZGlobal.player.setIsCIP(param1.isCIP);
               if(param1.player)
               {
                  if(_loc2_.completedQuests)
                  {
                     MegaseriesManager.instance.setCompletedQuest(_loc2_.completedQuests);
                  }
                  ZGlobal.player.preLoadObject(param1);
               }
               _loc11_ = ZGlobal.player.isRUXActive;
               _loc12_ = ZGlobal.player.isRUXQuestActive;
               _loc13_ = ZGlobal.player.showRUXInit;
               Logger.info(this,"internalInitUser","RUXStatus: " + _loc11_ + "RUXQuest: " + _loc12_ + "RUXInit: " + _loc13_);
               ZRTManager.instance.init(_loc2_);
               DecorationsManager.instance.init(_loc2_);
               MessageOfTheDayManager.instance.initExperimentVars();
               PriceTestManager.instance.initExperimentVars();
               WarehouseExperimentManager.instance.initExperimentVars();
               TreasureVaultManager.instance.initHighlights(_loc2_);
               TierSurfacingManager.instance.initExperimentVars();
               FlamingUnitManager.instance.initExperimentVars();
               ScrapManager.instance.initExperimentVars();
               DominationModeManager.instance.initExperimentVars();
               DominationModeManager.instance.setDefaultFleets(param1.dominanceDefaultFleets);
               ZGlobal.crewSlotCostExperiment = _loc2_.crewSlotCostExperiment;
               ZGlobal.combatAllyGatingVarient = _loc2_.combatAllyGatingVarient;
               ZGlobal.cashOnLevelUpVarient = _loc2_.cashOnLevelUpVarient;
               ZGlobal.immunityViralVarient = _loc2_.immunityViralVarient;
               ZGlobal.autopublishFeedVarient = _loc2_.autopublishFeedVarient;
               ZGlobal.autopublishFeedMessageVarient = _loc2_.autopublishFeedMessageVarient;
               ZGlobal.publishFeedPermissionVarient = _loc2_.publishFeedPermissionVarient;
               ZGlobal.autopublishAllFeedVarient = _loc2_.autopublishAllFeedVarient;
               ZGlobal.researchPartsVariantArmy = _loc2_.researchPartsVariantArmy;
               ZGlobal.researchPartsVariantNavy = _loc2_.researchPartsVariantNavy;
               ZGlobal.researchPartsVariantAir = _loc2_.researchPartsVariantAir;
               ZGlobal.noIntroCineVariant = _loc2_.noIntroCineVariant;
               ZGlobal.energyRewardVariant_v2 = _loc2_.energyRewardVariant_v2;
               ZGlobal.energyRewardVariant_v3 = _loc2_.energyRewardVariant_v3;
               ZGlobal.allyTimeoutVariant = _loc2_.allyTimeoutVariant;
               ZGlobal.speedUpViralVarient = _loc2_.speedUpViralVarient;
               ZGlobal.pricetestEarlyUnitUnlockVariant = _loc2_.pricetestEarlyUnitUnlockVariant;
               ZGlobal.starterBundleVariant = _loc2_.starterBundleVariant;
               ZGlobal.meetsCriteriaStarterPack = _loc2_.meetsCriteriaStarterPack;
               ZGlobal.energyRewardModVariant = _loc2_.energyRewardModVariant;
               ZGlobal.enhancedProgressBarVariant = _loc2_.enhancedProgressBarVariant;
               ZGlobal.epSpendConfirmation = _loc2_.epSpendConfirmation;
               ZGlobal.leaderboardsVariant = _loc2_.leaderboardsVariant;
               ZGlobal.survivalModeMaster = _loc2_.survivalModeMaster;
               ZGlobal.survivalModeContinueCost = _loc2_.survivalModeContinueCost;
               ZGlobal.survivalModeCardAccess = _loc2_.survivalModeCardAccess;
               ZGlobal.interstitialGiftingRewards = _loc2_.INTERSTITIAL_GIFTING_REWARDS;
               ZGlobal.freeGiftPartsBuildingData = _loc2_.FREE_GIFT_PARTS_BUILDING_DATA;
               ZGlobal.snid = _loc2_.snid;
               ZGlobal.snuid = _loc2_.snuid;
               ZGlobal.clientID = 1;
               ZGlobal.setHost(ZGlobal.player);
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_ZFEED) == ExperimentsManager.EXPERIMENT_ZFEED_VARIANT_ENABLED)
               {
                  TransactionManager.addTransaction(new TGetFeed(this.getFeed));
               }
               if(ZGlobal.startupId != null)
               {
                  if(ZGlobal.startupId != ZGlobal.player.uid && !_loc3_ && !_loc12_)
                  {
                     if(ZGlobal.player.neighbors[ZGlobal.startupId] != null)
                     {
                        if(ZGlobal.neighborReactivationNeeded(ZGlobal.startupId))
                        {
                           ReactivationGiftPopup.show(ZGlobal.startupId);
                        }
                        else if(PVPManager.instance.canVisitNeighbor(ZGlobal.startupId))
                        {
                           ZGame.instance.performVisitNeighbor(ZGlobal.startupId,ZGlobal.visitMarket,TWorldLoad.DBG_STARTUPID,_loc10_);
                        }
                        else
                        {
                           _loc24_ = ZGameUtils.ZlocT("Dialogs","PVPCannotVisitNeighbor");
                           _loc25_ = GenericPopup1B.NewOk(_loc24_,"");
                           PopupManager.instance.push(_loc25_,0,true);
                        }
                     }
                  }
                  else if(ZGlobal.isStartVisitingCameraPosSet())
                  {
                     ZGlobal.setStartCameraPos(ZGlobal.getStartVisitingCameraPos());
                     ZGlobal.setStartVisitingCameraPos(null);
                  }
                  ZGlobal.startupId = null;
               }
               WorldUpgradeManager.instance.loadUpgrades(param1.world.research);
               WorldUpgradeManager.instance.loadResearch2(param1.world.research2);
               SuperOreManager.instance.resourceOrder = param1.world.resourceOrder;
               param1.world.ownerId = GlobalEngine.socialNetwork.getLoggedInUserId();
               _loc14_ = ZGlobal.game.getWorld(IslandWorld.ID);
               _loc14_.loadObjects(param1.world);
               VisitorManager.instance.storeVisitorRequests(_loc2_.visitorHelpRequests);
               ZGameRandom.rewardInstance.init(param1.world.rewardRandSeedW,param1.world.rewardRandSeedZ);
               ZGameRandom.ransomInstance.init(param1.world.ransomRandSeedW,param1.world.ransomRandSeedZ);
               ZGameRandom.scrapInstance.init(param1.world.scrapRandSeedW,param1.world.scrapRandSeedZ);
               if(param1.player)
               {
                  ZGlobal.player.loadObject(param1);
                  if(Boolean(param1.player.fightMeter) && Boolean(param1.player.fightMeter.lastActivated) && Boolean(param1.player.fightsPerDay) && Boolean(param1.player.fightMeter.lastInitWeek))
                  {
                     FightMeterManager.instance.init(param1.player.fightMeter.lastActivated,param1.player.fightsPerDay,param1.player.fightMeter.lastInitWeek,param1.player.fightMeter.weekInitTarget);
                  }
                  if(_loc2_.completedQuests)
                  {
                     ZGlobal.player.setCompletedQuestNames(_loc2_.completedQuests);
                  }
                  if(ZGlobal.player.fleets)
                  {
                     ZGlobal.player.fleets.setupExistingBattles();
                  }
                  ViralsManager.instance.loadActiveVirals(param1.player.activeVirals);
                  UIDispatcher.instance.dispatchEvent(new Event(UIDispatcher.PLAYER_LEVEL_LOADED));
               }
               if(ZGlobal.leaderboardsVariant == LeaderboardManager.LEADERBOARDS_EXPERIMENT_ACTIVE)
               {
                  LeaderboardManager.instance.register(_loc2_,param1);
               }
               _loc15_ = false;
               _loc16_ = false;
               if(Zlab.getFlashVar("frMsg") != null)
               {
                  _loc26_ = null;
                  if(Zlab.getFlashVar("frIconItem") != null)
                  {
                     _loc26_ = ZGlobal.gameSettings.getItemByName(Zlab.getFlashVar("frIconItem") as String,GameItem);
                  }
                  if(_loc26_)
                  {
                     _loc27_ = String(Zlab.getFlashVar("frParams"));
                     _loc28_ = _loc27_.split(":");
                  }
               }
               else if(Zlab.getFlashVar("initMsg") == null)
               {
                  if(ZGlobal.isVisiting() == false)
                  {
                     _loc29_ = Boolean(ZGlobal.player.getSeenFlag(IntroCinematics.INTRO));
                     if(!_loc29_)
                     {
                        TutorialManager.instance.newUser = true;
                        if(ZGlobal.noIntroCineVariant != ZGlobal.EXPERIMENT_NO_INTRO_CINE && Zlab.getFlashVar("mute") == null)
                        {
                           _loc16_ = true;
                           ActionQueue.instance.add(new DoPlayCinematics(new IntroCinematics(false)));
                        }
                        else
                        {
                           ZGlobal.player.setSeenFlag(IntroCinematics.INTRO);
                        }
                        ActionQueue.instance.add(new DoStartEpisode());
                     }
                     else
                     {
                        this.checkLocaleFlow();
                        TutorialManager.instance.newUser = false;
                     }
                  }
               }
               if(!_loc16_)
               {
                  PostLoadManager.instance.start();
               }
               if(!_loc3_ && !_loc12_)
               {
                  if(_loc29_ && _loc2_.isTOSPPUpToDate != null && int(_loc2_.isTOSPPUpToDate) == 0)
                  {
                     ActionQueue.instance.add(new DoDisplayDialog(new TOSPPPopup()));
                  }
                  if(Boolean(param1.player) && Boolean(param1.player.incentiveDialog))
                  {
                     this.checkIncentiveDisplay(param1.player.incentiveDialog);
                  }
                  if(ZGlobal.player.enableOnetimePopup)
                  {
                     if(BookmarksIncentiveManager.isEnabled() && (Boolean(_loc2_.bookmarksFavInstallReward) || Boolean(_loc2_.bookmarksFavDailyReward)))
                     {
                        this.checkBookmarksIncentive(_loc2_);
                     }
                     else
                     {
                        this.checkDailyReturnBonus(_loc2_);
                     }
                  }
               }
               MechLabDailyRewardManager.instance.sequentialLogins = _loc2_.userInfo.player.sequentialLogins - _loc2_.userInfo.player.mechDailyRewardOffset;
               MechLabDailyRewardManager.instance.onInitUser(_loc2_.userInfo.player.sequentialLogins - _loc2_.userInfo.player.mechDailyRewardOffset);
               if(param1.bookmarkReward > 0)
               {
                  this.m_bookmarkCash = param1.bookmarkReward;
               }
               else if(_loc6_ && !_loc10_)
               {
               }
               if(param1.iconCodes)
               {
                  _loc30_ = param1.iconCodes;
               }
               if(!_loc3_ && !_loc12_)
               {
                  PromoManager.instance.setReceivedEPInfo(_loc2_.receivedEP);
                  PromoManager.instance.setReceivedEPThankYouInfo(_loc2_.receivedEPThankYou);
                  PromoManager.instance.setUnlimitedEnergyExpireTime(_loc2_.UNLIMITED_ENERGY_SALE_EXPIRE_TIME);
                  if(PromoManager.instance.getAutoPromotionExperimentVariant() <= PromoManager.AUTOPROMO_EXP_OFF_VARIANT)
                  {
                     PromoManager.instance.setFriendFlashExpireTime(_loc2_.FRIENDFLASH_EXPIRE_TIME);
                     PromoManager.instance.setFlashSaleExpireTime(_loc2_.FLASH_SALE_EXPIRE_TIME,PromoManager.PROMO_FLASH_SALE_CONTROLLED);
                     PromoManager.instance.setFlashSaleExpireTime(_loc2_.FLASH_SALE_EXPIRE_TIME_NEW_BUYER,PromoManager.PROMO_FLASH_SALE_NEW_BUYER);
                     PromoManager.instance.setFlashSaleExpireTime(_loc2_.FLASH_SALE_EXPIRE_TIME_DEAD_BUYER,PromoManager.PROMO_FLASH_SALE_DEAD_BUYER);
                     PromoManager.instance.setPayerBundleExpireTime(_loc2_.PAYER_BUNDLE_EXPIRE_TIME);
                     PromoManager.instance.promoOverrides = _loc2_.PROMO_OVERRIDES;
                     PromoManager.instance.setPickYourOwnVariables(_loc2_);
                  }
                  else
                  {
                     _loc31_ = ZGlobal.player.getOnGoingAutopromoExpireTime();
                     _loc32_ = PromoManager.instance.getCurrentAutopromotion();
                     if(_loc32_ != null)
                     {
                        _loc33_ = _loc32_.@type;
                        switch(_loc33_)
                        {
                           case PromoManager.AUTOPROMO_TYPE_FLASH:
                              PromoManager.instance.setFlashSaleExpireTime(_loc31_,PromoManager.PROMO_FLASH_SALE_AUTOPROMO);
                              break;
                           case PromoManager.AUTOPROMO_TYPE_FRIENDFLASH:
                              PromoManager.instance.setFriendFlashExpireTime(_loc31_);
                              break;
                           case PromoManager.AUTOPROMO_TYPE_FGWP:
                              PromoManager.instance.setPayerBundleExpireTime(_loc31_);
                              PromoManager.instance.promoOverrides = _loc2_.PROMO_OVERRIDES;
                              break;
                           case PromoManager.AUTOPROMO_TYPE_PYOB:
                              PromoManager.instance.setBundleExpireTime(PromoManager.PROMO_PICK_YOUR_OWN,_loc31_);
                              PromoManager.instance.setPickYourOwnVariables(_loc2_);
                        }
                     }
                  }
                  PromoManager.instance.setBundleExpireTime("ep_sink",_loc2_.EP_SINK_EXPIRE_TIME);
                  PromoManager.instance.buildableDiscounts = _loc2_.BUILDABLE_DISCOUNTS;
                  PromoManager.instance.impulsePurchases = _loc2_.IMPULSE_PURCHASES;
                  PromoManager.instance.unlimitedEnergyData = _loc2_.UNLIMITED_ENERGY_DATA;
                  PromoManager.instance.recentCashPurchase = _loc2_.recentCashPurchase;
                  PromoManager.instance.postInit();
               }
               LEUnitDiscountManager.instance.setLEUnitDiscounts(_loc2_.LE_DISCOUNT_SALE);
               LowEPPromotion.instance.zrtObject = _loc2_.LOW_EP_POPUP;
               ZGlobal.player.setZRTValue("COMBAT_NO_ENERGY",_loc2_.COMBAT_NO_ENERGY);
               ZGlobal.player.setZRTValue("COMBAT_DOUBLE_XP",_loc2_.COMBAT_DOUBLE_XP);
               ZGlobal.player.setZRTValue("COMBAT_HALF_RANSOM",_loc2_.COMBAT_HALF_RANSOM);
               if(ExperimentsManager.instance.getExperimentVariant("empire_subscriptions_click_test") == 2 && !ZGlobal.player.getSeenFlag(DoSubscriptionsClickTest.CLICK_TEST_FLAG) && ZGlobal.player.level >= 5)
               {
                  ActionQueue.instance.add(new DoSubscriptionsClickTest());
               }
               if(!_loc3_ && !_loc12_ && ZGlobal.player.enableOnetimePopup)
               {
                  ActionQueue.instance.add(new DoStartPromoManager(_loc2_.acceptedCrossPromos,_loc2_.availableCrossPromos));
               }
               GrantEpManager.instance.initialize();
               if(!_loc3_ && !_loc12_ && ZGlobal.leaderboardsVariant == LeaderboardManager.LEADERBOARDS_EXPERIMENT_ACTIVE)
               {
                  ActionQueue.instance.add(new DoLeaderboards());
               }
               if(!_loc3_ && !_loc12_ && ZGlobal.player.enableOnetimePopup)
               {
                  _loc34_ = _loc29_ && Boolean(ZGlobal.player);
                  if(_loc2_.neighborGainReward)
                  {
                     _loc35_ = _loc2_.neighborGainRewardCode;
                     _loc36_ = int(_loc2_.neighborGainRewardQuantity);
                     _loc37_ = ZGlobal.gameSettings.getInt("NeighborGainRequired",5);
                     _loc38_ = ZGlobal.gameSettings.getItemByCode(_loc35_,GameItem) as GameItem;
                     if(_loc38_)
                     {
                        IncentivePopup.createIncentivePopup(_loc34_,[_loc38_.code],null,"incentiveDescNeighborGain",{"numNeighbors":_loc37_},true,_loc36_);
                     }
                  }
                  else if(_loc2_.sentGiftsReceivedReward != null && int(_loc2_.sentGiftsReceivedReward) > 0)
                  {
                     IncentivePopup.createSentGiftRewardPopup(_loc34_,_loc2_.sentGiftsReceivedReward,ZGlobal.gameSettings.getXML().sentGiftsReceivedRewards[0]);
                  }
                  if(_loc34_ == true)
                  {
                     ActionQueue.instance.add(new DoMessageOfTheDay(ZGlobal.player));
                  }
               }
               ZGlobal.overlaySurveyURL = _loc2_.overlaySurveyURL;
               Logger.info(this,"internalInitUser","Neighbors count: " + _loc5_.length);
               this.parseNeighbors(_loc5_,_loc2_.friendBarVarient);
               VisitorManager.instance.createAvatars();
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SPLIT_LOADER) != ExperimentsManager.EXPERIMENT_SPLIT_LOADER_VARIANT_7)
               {
                  TransactionManager.addTransaction(new TInitRequestFriends(_loc3_));
               }
               ZGlobal.player.initRequestTracker(_loc2_.requestTracker);
               ZGlobal.player.initActiveRequest(_loc2_.activeRequests);
               ZGlobal.player.initActiveGiftRequest(_loc2_.activeGiftRequests);
               ZGlobal.player.initActiveHelpRequest(_loc2_.activeHelpRequests);
               ZGlobal.player.initPendingNeighbors(_loc2_.allPendingNeighbors);
               if(_loc2_.hasOwnProperty("playerAsn"))
               {
                  ZGlobal.player.asn = _loc2_.playerAsn;
               }
               if(_loc2_.hasOwnProperty("questInitAsn"))
               {
                  ZGlobal.player.initQuestInitAsn(_loc2_.questInitAsn);
               }
               if(_loc2_.hasOwnProperty("partsGatherInitAsn"))
               {
                  ZGlobal.player.initPartsGatherInitAsn(_loc2_.partsGatherInitAsn);
               }
               if(_loc2_.hasOwnProperty("blackmarketItems"))
               {
                  BlackMarketManager.instance.init(_loc2_.blackmarketItems);
               }
               AlliancesManager.instance.init(_loc9_);
               DominationModeManager.instance.postInit();
               if(!MatchMakingManager.instance.initialized)
               {
                  MatchMakingManager.instance.showPick();
               }
               ActionQueue.instance.add(new DoStartTutorial(ZGlobal.player.tutorialProgress));
               ActionQueue.instance.add(new DoStartQuests());
               ActionQueue.instance.add(new DoStartMusic());
               ActionQueue.instance.add(new DoStartViralSurfacingManager());
               ActionQueue.instance.add(new DoStartWorldEvents(_loc2_.worldEvents));
               FriendManager.instance.addEventListener(FriendManager.FRIEND_INFO_RECEIVED,OreInvite.onFriendInfoLoaded,false,0,true);
               FriendManager.instance.startQueryTimer();
               if(ExperimentsManager.instance.getExperimentVariant(FlashFeedManager.EXPERIMENT_FLASHFEED_NEW) >= 1)
               {
                  _loc39_ = GlobalEngine.serverTime;
                  _loc40_ = new Date(_loc2_.FLASHFEED_EXPIRE_TIME);
                  _loc41_ = _loc40_.getTime() - _loc39_;
                  if(_loc41_ > 0)
                  {
                     FlashFeedManager.getInstance().init(_loc2_.FLASHFEED_ITEMCODE,_loc2_.FLASHFEED_ITEMS_GRID,_loc2_.FLASHFEED_EXPIRE_TIME);
                  }
               }
               if(_loc11_)
               {
                  ActionQueue.instance.add(new DoRUXScreen());
               }
               else if(_loc3_)
               {
                  ActionQueue.instance.add(new DoDominationScreen(_loc4_));
               }
               PermissionTypes.setPermissionsForGDP(_loc2_.FB_REQ_PERMS);
               dispatchEvent(new Event(Event.COMPLETE));
            }
            else
            {
               Logger.error(this,"onComplete","InitUser global state is invalid ERROR_REMOTEOBJECT_FAULT");
            }
         }
         else
         {
            Logger.error(this,"onComplete","InitUser result is null ErrorManager.ERROR_REMOTEOBJECT_FAULT");
         }
         AllianceQuestManager.instance.init();
         dispatchEvent(new Event(Event.COMPLETE));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(EVENT_COMPLETE));
         m_initComplete = true;
      }
      
      private function checkIncentiveDisplay(param1:String) : void
      {
         var _loc2_:Object = {"incentiveCode":param1};
         ActionQueue.instance.add(new DoDisplayDialog(new IncentivePopup(_loc2_),false));
      }
      
      private function checkLocaleFlow() : void
      {
         if(Zlab.getFlashVar("localeMessageA1") as String != null || Zlab.getFlashVar("localeMessageB1") as String != null)
         {
            ActionQueue.instance.add(new DoDisplayDialog(new LocalePopup(Zlab.getFlashVar("localeMessageA1") as String,Zlab.getFlashVar("localeMessageA2") as String,Zlab.getFlashVar("localeMessageB1") as String,Zlab.getFlashVar("localeMessageB2") as String,parseInt(Zlab.getFlashVar("localeCount") as String)),false));
         }
      }
      
      private function checkDailyReturnBonus(param1:Object) : void
      {
         if(null != param1.loginReward)
         {
            ZGlobal.newDayThisSession = true;
            ActionQueue.instance.add(new DoDisplayDialog(new DailyBonusPopup(param1.userInfo.player.dailyReward,param1.userInfo.player.sequentialLogins),false));
         }
      }
      
      private function checkBookmarksIncentive(param1:Object) : void
      {
         if(param1.loginReward)
         {
            ZGlobal.newDayThisSession = true;
         }
         if(param1.bookmarksFavInstallReward)
         {
            ActionQueue.instance.add(new DoDisplayDialog(new BookmarkFavoriteInstallPopup(param1.userInfo.player.sequentialLogins),false));
         }
         else if(param1.bookmarksFavDailyReward)
         {
            ActionQueue.instance.add(new DoDisplayDialog(new BookmarkFavoriteIncentivePopup(param1.userInfo.player.sequentialLogins),false));
         }
      }
      
      protected function parseNeighbors(param1:Array, param2:int) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:Friend = null;
         var _loc3_:Array = [];
         Logger.info(this,"internalInitUser","Got neighbors data: " + param1.lenght);
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_].hasOwnProperty("isMatchMadeNeighbor") ? Boolean(param1[_loc4_].isMatchMadeNeighbor) : false;
            _loc6_ = new Friend(param1[_loc4_].uid,param1[_loc4_].coins,param1[_loc4_].xp,param1[_loc4_].level,param1[_loc4_].socialXpGood,param1[_loc4_].socialLevelGood,param1[_loc4_].socialXpBad,param1[_loc4_].socialLevelBad,param1[_loc4_].resource,param1[_loc4_].profilePic,param1[_loc4_].name,param1[_loc4_].dominanceRank,_loc5_);
            _loc6_.tendInfo = param1[_loc4_].tending;
            _loc3_.push(_loc6_);
            _loc4_++;
         }
         _loc3_.sortOn("xp",Array.NUMERIC,Array.DESCENDING);
         _loc3_.reverse();
         NeighborsDispatcher.instance.dispatchEvent(new NeighborsEvent(NeighborsEvent.NEIGHBORS_LOADED,_loc3_,param2));
      }
      
      protected function onBookmarkReward(param1:Event) : void
      {
      }
      
      override public function isInitTransaction() : Boolean
      {
         return true;
      }
   }
}

