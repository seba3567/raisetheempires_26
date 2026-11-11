package core
{
   import Engine.Managers.AssetUrlManager;
   import ZLocalization.Localizer;
   import com.zynga.ads.w2e.IService;
   import com.zynga.zap.w2e.WatchToEarnService;
   import core.gameobjects.UnitItem;
   import core.permission.IPermissionGate;
   import core.permission.PermissionGate;
   import core.player.Player;
   import flash.external.ExternalInterface;
   import flash.system.ApplicationDomain;
   import init.GameSettingsInit;
   import zlabs.ZConfig;
   import zlabs.debug.Logger;
   import zlabs.managers.WindowManager;
   
   public class ZGlobal
   {
      
      public static var mapSizeX:int;
      
      public static var mapSizeY:int;
      
      public static var gameSettings:GameSettingsInit;
      
      public static var game:ZGameManager;
      
      public static var player:Player;
      
      public static var hostPlayer:Player;
      
      public static var watchToEarn:WatchToEarnService;
      
      public static var newWatchToEarn:IService;
      
      public static var snid:Number;
      
      public static var snuid:Number;
      
      public static var clientID:Number;
      
      public static var startupId:String;
      
      private static var startCameraPos:String;
      
      private static var startVisitingCameraPos:String;
      
      public static var localizer:Localizer;
      
      public static var seenPVPActionPenalty:Boolean;
      
      public static var splitLoader:Boolean;
      
      public static var localeAppDomain:ApplicationDomain;
      
      public static var initUserData:Object;
      
      public static var trackTime:Number;
      
      public static const GAME_ID:Number = 81;
      
      public static const MODE_HOME:uint = 0;
      
      public static const MODE_VISIT:uint = 1;
      
      public static const LOADING_STAGE_NONE:int = 0;
      
      public static const LOADING_STAGE_OBJECTS:int = 1;
      
      public static const LOW_QUALITY_MODE:String = "lowquality";
      
      private static const EXPERIMENT_FRIENDSBAR_CONTROL:uint = 0;
      
      private static const EXPERIMENT_FRIENDSBAR_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_FRIENDSBAR_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_FRIENDSBAR_SHOW_RECOMMENDED_NEIGHBORS:uint = EXPERIMENT_FRIENDSBAR_VARIANT_2;
      
      private static const EXPERIMENT_ALLY_GATING_CONTROL:uint = 0;
      
      private static const EXPERIMENT_ALLY_GATING_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_ALLY_GATING_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_ALLY_GATING_START_TIMERS_WHEN_USED:uint = EXPERIMENT_ALLY_GATING_VARIANT_2;
      
      private static const EXPERIMENT_CASH_ON_LEVEL_UP_CONTROL:uint = 0;
      
      private static const EXPERIMENT_CASH_ON_LEVEL_UP_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_CASH_ON_LEVEL_UP_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_NO_CASH_ON_LEVEL_UP:uint = EXPERIMENT_CASH_ON_LEVEL_UP_VARIANT_2;
      
      private static const EXPERIMENT_IMMUNITY_VIRAL_CONTROL:uint = 0;
      
      private static const EXPERIMENT_IMMUNITY_VIRAL_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_IMMUNITY_VIRAL_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_IMMUNITY_VIRAL_FEEDS:uint = EXPERIMENT_IMMUNITY_VIRAL_VARIANT_2;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_CONTROL:uint = 0;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_2:uint = 2;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_3:uint = 3;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_4:uint = 4;
      
      public static const EXPERIMENT_AUTOPUBLISH_FEED_DISABLED:uint = EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_2;
      
      public static const EXPERIMENT_AUTOPUBLISH_W2W:uint = EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_3;
      
      public static const EXPERIMENT_MANUALPUBLISH_W2W:uint = EXPERIMENT_AUTOPUBLISH_FEED_VARIANT_4;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_MESSAGE_CONTROL:uint = 0;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_MESSAGE_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_AUTOPUBLISH_FEED_MESSAGE_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_AUTOPUBLISH_FEED_MESSAGE_ON:uint = EXPERIMENT_AUTOPUBLISH_FEED_MESSAGE_VARIANT_2;
      
      public static const EXPERIMENT_AUTOPUBLISH_ALL_FEED_CONTROL:uint = 0;
      
      public static const EXPERIMENT_AUTOPUBLISH_ALL_FEED_VARIANT_1:uint = 1;
      
      public static const EXPERIMENT_AUTOPUBLISH_ALL_FEED_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_AUTOPUBLISH_ALL_FEED_ON:uint = 2;
      
      private static const EXPERIMENT_QUEST_START_CONTROL:uint = 0;
      
      private static const EXPERIMENT_QUEST_START_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_QUEST_START_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_NEW_FTUE_QUEST_START:uint = EXPERIMENT_QUEST_START_VARIANT_2;
      
      public static const EXPERIMENT_RESEARCH_PARTS_V2_CONTROL:uint = 0;
      
      public static const EXPERIMENT_RESEARCH_PARTS_V2_VARIANT_1:uint = 1;
      
      public static const EXPERIMENT_RESEARCH_PARTS_V2_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_RESEARCH_PARTS_V2_VARIANT_3:uint = 3;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_CONTROL:uint = 0;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_1:uint = 1;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_3:uint = 3;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_4:uint = 4;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_5:uint = 5;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_6:uint = 6;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_7:uint = 7;
      
      public static const EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_8:uint = 8;
      
      private static const EXPERIMENT_NO_INTRO_CINE_CONTROL:uint = 0;
      
      private static const EXPERIMENT_NO_INTRO_CINE_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_NO_INTRO_CINE_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_NO_INTRO_CINE:uint = EXPERIMENT_NO_INTRO_CINE_VARIANT_2;
      
      public static const EXPERIMENT_ENERGY_REWARD_V2:String = "empire_energy_reward_v2";
      
      public static const EXPERIMENT_ENERGY_V2_CONTROL:uint = 0;
      
      public static const EXPERIMENT_ENERGY_V2_VARIANT_1:uint = 1;
      
      public static const EXPERIMENT_ENERGY_V2_VARIANT_2:uint = 2;
      
      public static const EXPERIMENT_ENERGY_V2_VARIANT_3:uint = 3;
      
      public static const EXPERIMENT_ENERGY_V2_VARIANT_4:uint = 4;
      
      public static const EXPERIMENT_INERT_PLAYER_REACTIVATION_CONTROL:int = 0;
      
      public static const EXPERIMENT_INERT_PLAYER_REACTIVATION_1:int = 1;
      
      public static const EXPERIMENT_INERT_PLAYER_REACTIVATION_NEEDED:int = 2;
      
      public static const EXPERIMENT_PVP_IMMUNITY_BEHAVIOR:String = "empire_pvp_immunity_behavior";
      
      public static const EXPERIMENT_SPEEDUP_VIRAL_CONTROL:uint = 0;
      
      public static const EXPERIMENT_SPEEDUP_VIRAL_v1:uint = 1;
      
      public static const EXPERIMENT_SPEEDUP_VIRAL_v2:uint = 2;
      
      public static const EXPERIMENT_SPEEDUP_VIRAL_v3:uint = 3;
      
      public static const EXPERIMENT_SPEEDUP_VIRAL_FEED:uint = EXPERIMENT_SPEEDUP_VIRAL_v3;
      
      public static const EXPERIMENT_INVASION_MARKER_CONTROL:uint = 0;
      
      public static const EXPERIMENT_INVASION_MARKER_v1:uint = 1;
      
      public static const EXPERIMENT_INVASION_MARKER_v2:uint = 2;
      
      public static const EXPERIMENT_INVASION_MARKER_EXCLUDE_DEFENDED:uint = EXPERIMENT_INVASION_MARKER_v2;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_CONTROL:uint = 0;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_V1:uint = 1;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_V2:uint = 2;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_V3:uint = 3;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_V4:uint = 4;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_V5:uint = 5;
      
      public static const EXPERIMENT_BUILDING_BUILDABLE_PARTS_V6:uint = 6;
      
      public static const EXPERIMENT_SUPPORT_UNITS:String = "empires_support_units";
      
      public static const EXPERIMENT_SUPPORT_UNITS_ACTIVE:int = 3;
      
      public static const EXPERIMENT_POWERUP_BUILDABLE_PARTS_CONTROL:uint = 0;
      
      public static const EXPERIMENT_POWERUP_BUILDABLE_PARTS_V1:uint = 1;
      
      public static const EXPERIMENT_POWERUP_BUILDABLE_PARTS_V2:uint = 2;
      
      public static const EXPERIMENT_POWERUP_BUILDABLE_PARTS_V3:uint = 3;
      
      public static const EXPERIMENT_POWERUP_BUILDABLE_PARTS_V4:uint = 4;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_CONTROL:uint = 0;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_V1:uint = 1;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_V2:uint = 2;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_V3:uint = 3;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_V4:uint = 4;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_V5:uint = 5;
      
      public static const EXPERIMENT_MISSION_BUILDABLE_PARTS_V6:uint = 6;
      
      public static const EXPERIMENT_CAMPAIGN_MASTERY_ENABLED:uint = 2;
      
      public static const EXPERIMENT_CAMPAIGN_MASTERY_UNIT_TIER_HARD_VARIANT:uint = 2;
      
      public static const EXPERIMENT_EXPANSION_CREW_ENABLED:uint = 3;
      
      public static var visitMarket:Boolean = false;
      
      public static var interstitial:String = null;
      
      public static var PVPdefendOnStart:String = null;
      
      public static var autoPublishEnabled:Boolean = false;
      
      public static var marketExpirationTime:Number = NaN;
      
      public static var cellSize:int = 64;
      
      public static var cellSizeM:Number = 0.015625;
      
      private static var startingInChallengeMode:Boolean = false;
      
      private static var challengeFleetName:String = null;
      
      private static var m_ineligibleGiftRecipients:Array = new Array();
      
      public static var visitingNotification:String = null;
      
      public static var visitMode:uint = MODE_HOME;
      
      public static var loadingStage:uint = LOADING_STAGE_NONE;
      
      public static var overlaySurveyURL:String = null;
      
      public static var stencilActive:Boolean = false;
      
      public static var newDayThisSession:Boolean = false;
      
      public static var immunityTimeVariant:int = 0;
      
      public static var crewSlotCostMult:int = 1;
      
      public static var crewSlotCostExperiment:int = 0;
      
      public static var combatAllyGatingVarient:int = 0;
      
      public static var cashOnLevelUpVarient:int = 0;
      
      public static var immunityViralVarient:int = 0;
      
      public static var autopublishFeedVarient:int = 0;
      
      public static var autopublishFeedMessageVarient:int = 0;
      
      public static var autopublishAllFeedVarient:int = 0;
      
      public static var researchPartsVariantArmy:int = 0;
      
      public static var researchPartsVariantNavy:int = 0;
      
      public static var researchPartsVariantAir:int = 0;
      
      public static var noIntroCineVariant:int = 0;
      
      public static var energyRewardVariant_v2:int = 0;
      
      public static var energyRewardVariant_v3:int = 0;
      
      public static var allyTimeoutVariant:int = 0;
      
      public static var speedUpViralVarient:int = 0;
      
      public static var pricetestEarlyUnitUnlockVariant:int = 0;
      
      public static var starterBundleVariant:int = 0;
      
      public static var meetsCriteriaStarterPack:Boolean = false;
      
      public static var energyRewardModVariant:int = 0;
      
      public static var enhancedProgressBarVariant:int = 0;
      
      public static var epSpendConfirmation:int = 0;
      
      public static var leaderboardsVariant:int = 0;
      
      public static var survivalModeMaster:int = 0;
      
      public static var survivalModeContinueCost:int = 0;
      
      public static var survivalModeCardAccess:int = 0;
      
      public static var ftvXpromoPtHudVariant:int = 0;
      
      public static var ftvXpromoPtMOTDVariant:int = 0;
      
      public static var defenseTower3Variant:int = 0;
      
      public static var defenseTowerPricingVariant:int = 0;
      
      public static var directReliefHudVariant:int = 0;
      
      public static var interstitialGiftingRewards:String = "";
      
      public static var freeGiftPartsBuildingData:String = "";
      
      public static var hasPublishPermission:Number = 1;
      
      public static var questData:* = null;
      
      public static var settingsData:* = null;
      
      public static var localeData:* = null;
      
      public static var publishFeedPermissionVarient:int = 0;
      
      public static var permissionGate:IPermissionGate = new PermissionGate();
      
      public static var lowQualityMode:Boolean = false;
      
      public function ZGlobal()
      {
         super();
      }
      
      public static function init(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1.ineligibleGiftRecipients as Array))
         {
            initIneligibleGiftRecipients(param1.ineligibleGiftRecipients);
         }
      }
      
      public static function initIneligibleGiftRecipients(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            for each(_loc2_ in param1)
            {
               m_ineligibleGiftRecipients.push(_loc2_);
            }
         }
      }
      
      public static function isEligibleGiftRecipient(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         if(m_ineligibleGiftRecipients)
         {
            _loc2_ = m_ineligibleGiftRecipients.indexOf(param1);
            return _loc2_ < 0;
         }
         return true;
      }
      
      public static function setHost(param1:Player) : void
      {
         hostPlayer = param1;
         if(hostPlayer.uid == ZGlobal.player.uid)
         {
            visitMode = MODE_HOME;
         }
         else
         {
            visitMode = MODE_VISIT;
         }
      }
      
      public static function getTransactionId() : String
      {
         if(ZGlobal.isHome())
         {
            return null;
         }
         return hostPlayer.uid;
      }
      
      public static function setStartCameraPos(param1:String) : void
      {
         ZGlobal.startCameraPos = param1;
      }
      
      public static function setStartVisitingCameraPos(param1:String) : void
      {
         ZGlobal.startVisitingCameraPos = param1;
      }
      
      public static function getAssetURL(param1:String) : String
      {
         if(!param1)
         {
            Logger.error(null,"getAssetURL","invalid url");
            return param1;
         }
         return AssetUrlManager.instance.lookUpUrl(ZConfig.ASSET_BASE_PATH + param1);
      }
      
      public static function getAssetURLChecked(param1:String) : String
      {
         if(param1.indexOf(ZConfig.ASSET_BASE_PATH) == 0)
         {
            return param1;
         }
         return getAssetURL(param1);
      }
      
      public static function isHome() : Boolean
      {
         return ZGlobal.visitMode == MODE_HOME;
      }
      
      public static function isVisiting() : Boolean
      {
         return ZGlobal.visitMode == MODE_VISIT;
      }
      
      public static function getStartCameraPos() : String
      {
         return ZGlobal.startCameraPos;
      }
      
      public static function getStartVisitingCameraPos() : String
      {
         return ZGlobal.startVisitingCameraPos;
      }
      
      public static function isStartingInChallengeMode() : Boolean
      {
         return ZGlobal.startingInChallengeMode;
      }
      
      public static function getChallengeFleetName() : String
      {
         return ZGlobal.challengeFleetName;
      }
      
      public static function isStartCameraPosSet() : Boolean
      {
         return ZGlobal.startCameraPos != null;
      }
      
      public static function isStartVisitingCameraPosSet() : Boolean
      {
         return ZGlobal.startVisitingCameraPos != null;
      }
      
      public static function switchToTab(param1:String) : void
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         ExternalInterface.call("ZYFrameManager.switchToTab",param1);
      }
      
      public static function navigateImmediatelyTo(param1:String, param2:String = null) : void
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         ExternalInterface.call("ZYFrameManager.navigateTo",param1,param2,true);
      }
      
      public static function openURLInNewWindow(param1:String, param2:String = null) : void
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         ExternalInterface.call("ZYFrameManager.openTab",param1,param2,true);
      }
      
      public static function neighborReactivationNeeded(param1:String) : Boolean
      {
         return false;
      }
      
      public static function getResearchPartsExperimentVariantByType(param1:String) : int
      {
         var _loc2_:int = 0;
         if(param1 == UnitItem.ARMY)
         {
            _loc2_ = researchPartsVariantArmy;
         }
         else if(param1 == UnitItem.NAVY)
         {
            _loc2_ = researchPartsVariantNavy;
         }
         else
         {
            if(param1 != UnitItem.AIR)
            {
               return 0;
            }
            _loc2_ = researchPartsVariantAir;
         }
         return _loc2_;
      }
   }
}

