package core.managers.viralsManager
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.TStreamPublish;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.managers.SurveyManager;
   import core.managers.WorldObjectManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.IPVPPlayer;
   import core.ui.menuitem.FriendsBarUIItem;
   import core.ui.menuitem.UsersBarUIItem;
   import displays.popups.CommentPopup;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GlobalPVPFeedPopup;
   import displays.popups.InviteIdlePopup;
   import displays.popups.NameNationPopup;
   import displays.popups.NameTitanPopup;
   import displays.popups.ResearchIdlePopup;
   import displays.popups.ViralCountdownPopup;
   import displays.popups.battlebase.BattleBasePopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.oreInviteScreen.OreInvite;
   import displays.screens.requests.RequestAskPartsDialog;
   import displays.screens.requests.RequestCrewDialog;
   import displays.screens.requests.RequestDialog;
   import displays.screens.requests.RequestGiftDialog;
   import displays.screens.requests.RequestInvasionHelpDialog;
   import displays.screens.requests.RequestNeighborDialog;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import transactions.TAddFriendPublish;
   import transactions.TCrewZMC;
   import transactions.TRenameTitan;
   import transactions.TRenameWorld;
   import transactions.TStreamPublishWithCallback;
   import transactions.TStreamPublishWithComment;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class ViralsManager
   {
      
      public static const INVITE_REQUEST_SOURCE_UNKNOWN:uint = 0;
      
      public static const INVITE_REQUEST_SOURCE_FIRST_VICTORY:uint = 1;
      
      public static const INVITE_REQUEST_SOURCE_BATTLE_RETREAT:uint = 2;
      
      public static const INVITE_REQUEST_SOURCE_IDLE:uint = 3;
      
      public static const INVITE_REQUEST_SOURCE_IDLE_TUTORIAL:uint = 4;
      
      public static const INVITE_REQUEST_SOURCE_NEIGHBOR_SLOT:uint = 5;
      
      public static const INVITE_REQUEST_SOURCE_REC_NEIGHBOR_SLOT:uint = 6;
      
      public static const INVITE_REQUEST_SOURCE_SUG_NEIGHBOR_SLOT:uint = 7;
      
      public static const INVITE_REQUEST_SOURCE_CREW_GATHER_SLOT:uint = 8;
      
      public static const INVITE_REQUEST_SOURCE_RAREORE_INVITE:uint = 9;
      
      public static const INVITE_REQUEST_SOURCE_NEW_INSTALL_QUEST:uint = 10;
      
      public static const INVITE_REQUEST_SOURCE_VIRAL_SURFACING:uint = 11;
      
      public static const INVITE_REQUEST_SOURCE_LANDING_PAGE_NOT_NEIGHBOR:uint = 12;
      
      public static const INVITE_REQUEST_SOURCE_INVITE_TAB:uint = 13;
      
      public static const INVITE_REQUEST_SOURCE_INTERSTITIAL:uint = 14;
      
      public static const INVITE_REQUEST_SOURCE_MATCHMAKING:uint = 15;
      
      private static const IDLE_POPUP_DISMISS_LIMIT:uint = 2;
      
      private static const MAX_RANDOM_CAMPAIGN_BATTLE_WON_FEEDS:uint = 20;
      
      public static var CREW_PUBLISHED_CALLBACK_KEY:String = "crewPublishedCallbackKey";
      
      public static var instance:ViralsManager = new ViralsManager();
      
      private static const IMMUNITY_BUILDING_NAME:String = "PVPImmunityBldg";
      
      private static var m_energyFeedToggle:Boolean = true;
      
      private static var IDLE_INVITE:int = 0;
      
      private static var IDLE_GIFT:int = 1;
      
      private static var IDLE_OREINVITE:int = 2;
      
      private static var IDLE_NUM:int = 3;
      
      private var m_activeVirals:Dictionary;
      
      private var m_timer:Timer;
      
      private var m_surveyTimer:Timer;
      
      private var m_sawInput:Boolean = false;
      
      private var m_toggle:int = 0;
      
      private var m_dialogUp:Boolean = false;
      
      private var m_invitePopupDismissCount:int = 0;
      
      private var m_giftPopupDismissCount:int = 0;
      
      private var m_oreInvitePopupDismissCount:int = 0;
      
      private var m_researchIdleDismissCount:int = 0;
      
      private var m_disableInvitePopup:Boolean = false;
      
      private var m_disableGiftPopup:Boolean = false;
      
      private var m_disableOreInvitePopup:Boolean = false;
      
      private var m_disableResearchInvitePopup:Boolean = false;
      
      private var m_disableSurveyPopup:Boolean = false;
      
      private var m_startingRandomCampBattleWonIndex:int = 0;
      
      private var m_startingRandomCamp2BattleWonIndex:int = 0;
      
      private var m_startingRandomCamp3BattleWonIndex:int = 0;
      
      private var m_maxRandomCampaignBattleWonFeeds:int = 20;
      
      private var m_invitePopup:InviteIdlePopup = null;
      
      private var m_enabled:Boolean = true;
      
      public function ViralsManager()
      {
         super();
         var _loc1_:int = ZGlobal.gameSettings.getInt("viralNoActivityDelay",90000);
         this.m_timer = new Timer(_loc1_);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimeout);
         this.m_timer.start();
         var _loc2_:int = ZGlobal.gameSettings.getInt("surveyOverlayDelay",30000);
         this.m_surveyTimer = new Timer(_loc2_);
         this.m_surveyTimer.addEventListener(TimerEvent.TIMER,this.onSurveyTimeout);
         this.m_surveyTimer.start();
         Zlab.mainStage.addEventListener(KeyboardEvent.KEY_UP,this.onSawInput);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_UP,this.onSawInput);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onSawInput);
         this.m_activeVirals = new Dictionary();
         this.m_maxRandomCampaignBattleWonFeeds = ZGlobal.gameSettings.getInt("MaxRandomCampaignBattleWonFeeds",MAX_RANDOM_CAMPAIGN_BATTLE_WON_FEEDS);
         this.m_startingRandomCampBattleWonIndex = Math.round(Math.random() * (this.m_maxRandomCampaignBattleWonFeeds - 1));
      }
      
      private static function onCrewZMCPublished(param1:Object) : void
      {
         var _loc2_:TCrewZMC = new TCrewZMC(param1.feedType,param1.feedData,param1.target);
         TransactionManager.addTransaction(_loc2_,true);
      }
      
      public function loadActiveVirals(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Viral = null;
         for(_loc2_ in param1)
         {
            _loc3_ = new Viral(_loc2_,uint(param1[_loc2_].timesPosted),Number(param1[_loc2_].originTime));
            this.m_activeVirals[_loc2_] = _loc3_;
         }
      }
      
      public function getActiveViralByType(param1:String) : Viral
      {
         return this.m_activeVirals[param1];
      }
      
      public function canPost(param1:String) : Boolean
      {
         var _loc2_:Viral = this.m_activeVirals[param1];
         if(_loc2_ != null && _loc2_.hasHitPostLimit() && !_loc2_.hasReset())
         {
            return false;
         }
         return true;
      }
      
      private function viralResetTime(param1:String) : Number
      {
         var _loc2_:Viral = this.m_activeVirals[param1];
         if(_loc2_ != null)
         {
            return _loc2_.getResetTime();
         }
         return 0;
      }
      
      public function getViralResetTime(param1:String) : Number
      {
         return this.viralResetTime(param1);
      }
      
      protected function postViral(param1:String) : void
      {
         this.purgeResetVirals();
         var _loc2_:Viral = null;
         if(this.m_activeVirals.hasOwnProperty(param1))
         {
            _loc2_ = this.m_activeVirals[param1];
         }
         if(_loc2_ == null)
         {
            this.m_activeVirals[param1] = new Viral(param1,1,GlobalEngine.serverTime / 1000);
         }
         else if(_loc2_.hasHitPostLimit() == false)
         {
            ++_loc2_.timesPosted;
         }
      }
      
      protected function purgeResetVirals() : void
      {
         var _loc1_:Viral = null;
         for each(_loc1_ in this.m_activeVirals)
         {
            if(_loc1_.hasReset())
            {
               this.m_activeVirals[_loc1_.getType()] = null;
               delete this.m_activeVirals[_loc1_.getType()];
            }
         }
      }
      
      private function onSurveyTimeout(param1:Event = null) : void
      {
         if(this.m_sawInput)
         {
            this.m_sawInput = false;
         }
         else if(!this.m_dialogUp && this.m_enabled && !TutorialManager.instance.active && ZLoc.instance != null)
         {
            SurveyManager.getInstance().displaySurveyOverlay();
            this.stopSurveyTimer();
         }
      }
      
      private function onCloseIdlePopup() : void
      {
         this.m_dialogUp = false;
      }
      
      private function onTimeout(param1:Event = null) : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:IEntity = null;
         var _loc4_:IEntity = null;
         var _loc5_:Boolean = false;
         var _loc6_:Dictionary = null;
         var _loc7_:IEntity = null;
         var _loc8_:IEntity = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:GameDataComponent = null;
         var _loc12_:RequestNeighborDialog = null;
         var _loc13_:String = null;
         var _loc14_:RequestGiftDialog = null;
         if(ZGlobal.player.enableIdlePopup)
         {
            if(this.m_sawInput)
            {
               this.m_sawInput = false;
            }
            else if(!this.m_dialogUp && this.m_enabled && !TutorialManager.instance.active && ZLoc.instance != null)
            {
               if(!this.m_disableResearchInvitePopup && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SURFACING_MASTER) >= ExperimentsManager.EXPERIMENT_RESEARCH_SURFACING_ON)
               {
                  _loc2_ = null;
                  _loc3_ = null;
                  _loc4_ = null;
                  _loc5_ = false;
                  _loc6_ = WorldObjectManager.instance.getObjectsBySubType("building","military");
                  for each(_loc8_ in _loc6_)
                  {
                     if(_loc8_)
                     {
                        _loc9_ = _loc8_.name.split("_");
                        _loc10_ = int(_loc9_[1]);
                        _loc7_ = ZGlobal.game.getObjectByID(_loc10_);
                        if(_loc7_)
                        {
                           _loc11_ = GameDataComponent.getGameDataComponent(_loc7_) as GameDataComponent;
                           if(_loc2_ == null && _loc11_.gameData.referenceSubtype == "army" && _loc11_.gameData.isResearchItem() && ZGlobal.player.buildingIsReadyForResearch(_loc7_))
                           {
                              _loc2_ = _loc7_;
                              _loc5_ = true;
                           }
                           else if(_loc3_ == null && _loc11_.gameData.referenceSubtype == "air" && _loc11_.gameData.isResearchItem() && ZGlobal.player.buildingIsReadyForResearch(_loc7_))
                           {
                              _loc3_ = _loc7_;
                              _loc5_ = true;
                           }
                           else if(_loc4_ == null && _loc11_.gameData.referenceSubtype == "navy" && _loc11_.gameData.isResearchItem() && ZGlobal.player.buildingIsReadyForResearch(_loc7_))
                           {
                              _loc4_ = _loc7_;
                              _loc5_ = true;
                           }
                        }
                     }
                  }
                  if(_loc5_ && ZGlobal.player.hasAnyResearchableUnits())
                  {
                     PopupManager.instance.push(new ResearchIdlePopup(this.onResearchIdleClosed,_loc2_,_loc3_,_loc4_));
                     this.m_dialogUp = true;
                  }
               }
               else if(PromoManager.instance.meetsCriteriaStarterPack() && ZGlobal.player.getSeenSessionFlag(PromoManager.FLAG_SESSION_STARTER_PACK_POPUP) == false && ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_ON_IDLE) < 3)
               {
                  PromoManager.instance.openStarterPackPopup(this.onZGamePopUpClosed);
                  this.m_dialogUp = true;
                  ZGlobal.player.setSeenSessionFlag(PromoManager.FLAG_SESSION_STARTER_PACK_POPUP);
                  ZGlobal.player.setSeenFlag(PromoManager.FLAG_STARTER_PACK_ON_IDLE);
               }
               else if(this.m_toggle == IDLE_INVITE && !this.m_disableInvitePopup)
               {
                  if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
                  {
                     _loc12_ = new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_IDLE,ExperimentsManager.EXPERIMENT_REQUEST2_MFS,RequestDialog.SUBTYPE_IDLE,this.onCloseIdlePopup);
                     if(_loc12_.numFriends > 0)
                     {
                        PopupManager.instance.push(_loc12_);
                        this.m_disableInvitePopup = true;
                     }
                  }
                  else
                  {
                     _loc13_ = ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
                     if(Boolean(FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).suggestedNeighbors) && Boolean(FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).suggestedNeighbors.length))
                     {
                        this.m_invitePopup = new InviteIdlePopup(this.onInviteDialogClosed);
                        PopupManager.instance.push(this.m_invitePopup,0,true,false);
                     }
                     else
                     {
                        PopupManager.instance.push(new FeedPopup(ZGameUtils.ZlocT("FeedPopups","friend_invite"),ZGameUtils.ZlocT("FeedPopups","friend_invite_title"),ZGameUtils.ZlocT("FeedPopups","feed_invite_bttn"),GenericPopup.TYPE_INVITE,this.onInviteDialogClosed,_loc13_,FeedPopup.SMALL_IMAGE));
                     }
                  }
                  this.m_dialogUp = true;
               }
               else if(this.m_toggle == IDLE_GIFT && !this.m_disableGiftPopup)
               {
                  if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
                  {
                     _loc14_ = new RequestGiftDialog("mysterygift",RequestGiftDialog.RECENT_PLAYER_GIFTTYPE,RequestDialog.TYPE_RECENTLY_PLAYED,ExperimentsManager.EXPERIMENT_REQUEST2_MFS_GIFT,RequestDialog.SUBTYPE_IDLE,this.onCloseIdlePopup);
                     if(_loc14_.numFriends > 0)
                     {
                        PopupManager.instance.push(_loc14_);
                        this.m_disableGiftPopup = true;
                     }
                  }
                  else
                  {
                     PopupManager.instance.push(new FeedPopup(ZGameUtils.ZlocT("FeedPopups","gift_send"),ZGameUtils.ZlocT("FeedPopups","gift_send_title"),ZGameUtils.ZlocT("FeedPopups","feed_send_bttn"),GenericPopup.TYPE_SENDGIFTSCANCEL,this.onGiftDialogClosed,ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/GiftBag_96.png")));
                  }
                  this.m_dialogUp = true;
               }
               else if(this.m_toggle == IDLE_OREINVITE && !this.m_disableOreInvitePopup)
               {
                  if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
                  {
                     this.m_disableOreInvitePopup = true;
                  }
                  else if(OreInvite.checkQuestGate())
                  {
                     PopupManager.instance.push(new OreInvite(this.onOreDialogClosed));
                     this.m_dialogUp = true;
                  }
               }
               this.m_toggle = (this.m_toggle + 1) % IDLE_NUM;
               if(this.m_disableInvitePopup && this.m_disableGiftPopup && this.m_disableOreInvitePopup)
               {
                  this.dispose();
               }
            }
         }
      }
      
      private function onZGamePopUpClosed(param1:Event) : void
      {
         param1.currentTarget.removeEventListener(ZGamePopUp.CLOSED,this.onZGamePopUpClosed);
         this.m_dialogUp = false;
      }
      
      private function onInviteDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            if(this.m_invitePopup)
            {
               this.sendInviteRequest(INVITE_REQUEST_SOURCE_IDLE,"popup",null,this.m_invitePopup.friendZids);
            }
            else
            {
               this.sendInviteRequest(INVITE_REQUEST_SOURCE_IDLE,"all");
            }
         }
         else
         {
            ++this.m_invitePopupDismissCount;
            if(this.m_invitePopupDismissCount >= IDLE_POPUP_DISMISS_LIMIT)
            {
               this.m_disableInvitePopup = true;
            }
         }
         this.m_invitePopup = null;
         this.m_dialogUp = false;
      }
      
      public function onInviteDialogTutorialClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_IDLE_TUTORIAL));
         }
      }
      
      private function onGiftDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ZGlobal.switchToTab("gifts");
         }
         else
         {
            ++this.m_giftPopupDismissCount;
            if(this.m_giftPopupDismissCount >= IDLE_POPUP_DISMISS_LIMIT)
            {
               this.m_disableGiftPopup = true;
            }
         }
         this.m_dialogUp = false;
      }
      
      private function onOreDialogClosed(param1:Boolean) : void
      {
         if(!param1)
         {
            ++this.m_oreInvitePopupDismissCount;
            if(this.m_oreInvitePopupDismissCount >= IDLE_POPUP_DISMISS_LIMIT)
            {
               this.m_disableOreInvitePopup = true;
            }
         }
         this.m_dialogUp = false;
      }
      
      private function onResearchIdleClosed(param1:Boolean) : void
      {
         if(!param1)
         {
            ++this.m_researchIdleDismissCount;
         }
         this.m_disableResearchInvitePopup = true;
         this.m_dialogUp = false;
      }
      
      private function onSawInput(param1:Event) : void
      {
         this.m_sawInput = true;
      }
      
      public function disable() : void
      {
         this.m_enabled = false;
      }
      
      public function enable() : void
      {
         this.m_enabled = true;
      }
      
      public function idlePopupEnabled() : Boolean
      {
         return this.m_enabled;
      }
      
      public function dispose() : void
      {
         Zlab.mainStage.removeEventListener(KeyboardEvent.KEY_UP,this.onSawInput);
         Zlab.mainStage.removeEventListener(MouseEvent.MOUSE_UP,this.onSawInput);
         Zlab.mainStage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onSawInput);
         this.m_timer.stop();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimeout);
      }
      
      public function stopSurveyTimer() : void
      {
         this.m_surveyTimer.stop();
         this.m_surveyTimer.removeEventListener(TimerEvent.TIMER,this.onSurveyTimeout);
      }
      
      public function questCompleteViral(param1:String) : void
      {
         var _loc2_:int = 0;
         if(param1 != null && param1.length > 0)
         {
            _loc2_ = ZGlobal.gameSettings.getInt("newBuildingDialogDelay");
            switch(param1)
            {
               case "new_nation":
                  Zlab.processManager.schedule(_loc2_,this,this.onNewNationDialog);
                  break;
               case "new_titan":
                  Zlab.processManager.schedule(_loc2_,this,this.onNewTitanDialog);
            }
         }
      }
      
      public function firstBuiltViral(param1:GameItem) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("newBuildingDialogDelay");
         if(param1 != null)
         {
         }
      }
      
      public function onNewNationDialog() : void
      {
         PopupManager.instance.push(new NameNationPopup(ZGlobal.player.worldName,this.onRenameNationDialogClosed));
      }
      
      private function onRenameNationDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = String(param1.userData.newName);
         TransactionManager.addTransaction(new TRenameWorld(_loc2_,param1.userData.share),true);
         UsersBarUIItem.worldNameUpdated(_loc2_);
         ZGlobal.player.checkCIPRequirements();
      }
      
      public function onNewTitanDialog() : void
      {
         PopupManager.instance.push(new NameTitanPopup(ZGlobal.player.titanName,this.onRenameTitanDialogClosed));
      }
      
      private function onRenameTitanDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = String(param1.userData.newName);
         TransactionManager.addTransaction(new TRenameTitan(_loc2_,param1.userData.share),true);
      }
      
      public function sendInviteRequest(param1:uint = 0, param2:String = null, param3:String = null, param4:Array = null, param5:Boolean = false) : void
      {
         var _loc6_:RequestNeighborDialog = new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_IDLE,ExperimentsManager.EXPERIMENT_REQUEST2_MFS,RequestDialog.SUBTYPE_IDLE,this.onCloseIdlePopup);
         PopupManager.instance.push(_loc6_,0,false);
      }
      
      public function requestImmunityExtension(param1:int) : Boolean
      {
         var _loc3_:GameItem = null;
         var _loc4_:CrewTemplateWrapper = null;
         var _loc2_:Boolean = true;
         if(this.canPost("pvp_immunity_crew_invite"))
         {
            if(WindowManager.isFullScreen())
            {
               WindowManager.toggleFullScreen();
            }
            if(ZGlobal.immunityViralVarient == ZGlobal.EXPERIMENT_IMMUNITY_VIRAL_FEEDS)
            {
               this.feedPVPImmunityCrewInvite();
            }
            else
            {
               param1--;
               _loc3_ = ZGlobal.gameSettings.getItemByName(IMMUNITY_BUILDING_NAME,GameItem) as GameItem;
               _loc4_ = ZGlobal.gameSettings.getCrewTemplateWrapper(_loc3_.name);
               PopupManager.instance.push(new RequestCrewDialog(-1,_loc3_.name,_loc4_.numPositions - param1));
            }
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("FeedPopups","cannot_post"),GenericPopup.TYPE_OK));
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      public function requestRepelInvasionHelp(param1:String) : Boolean
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         var _loc2_:Boolean = true;
         if(ExperimentsManager.instance.getExperimentVariant("empire_repel_crew_viral") == 3)
         {
            this.feedPVPRepelCrewInvite(param1);
         }
         else if(this.canPost("help_repel_invasion"))
         {
            PopupManager.instance.push(new RequestInvasionHelpDialog(param1),0,false);
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("FeedPopups","cannot_post"),GenericPopup.TYPE_OK));
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      public function sendCampaignBattleWonFeed() : void
      {
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:int = this.m_maxRandomCampaignBattleWonFeeds;
         var _loc4_:int = this.m_startingRandomCampBattleWonIndex;
         var _loc5_:String = "camp_battle_won_";
         var _loc6_:String = ZGlobal.player.campaign.currentCampaignName;
         switch(_loc6_)
         {
            case "camp002":
               _loc3_ = 10;
               _loc4_ = this.m_startingRandomCamp2BattleWonIndex;
               _loc5_ = "camp2_battle_won_";
               _loc1_ = true;
               break;
            case "camp003":
               _loc3_ = 4;
               _loc4_ = this.m_startingRandomCamp3BattleWonIndex;
               _loc5_ = "camp3_battle_won_";
               _loc2_ = true;
               break;
            default:
               _loc3_ = this.m_maxRandomCampaignBattleWonFeeds;
               _loc4_ = this.m_startingRandomCampBattleWonIndex;
               _loc5_ = "camp_battle_won_";
         }
         var _loc7_:int = 0;
         while(_loc7_ < _loc3_)
         {
            _loc8_ = _loc5_ + String(_loc4_);
            _loc4_ = (_loc4_ + 1) % _loc3_;
            if(_loc1_)
            {
               this.m_startingRandomCamp2BattleWonIndex = _loc4_;
            }
            else if(_loc2_)
            {
               this.m_startingRandomCamp3BattleWonIndex = _loc4_;
            }
            else
            {
               this.m_startingRandomCampBattleWonIndex = _loc4_;
            }
            if(this.canPost(_loc8_))
            {
               _loc9_ = ZGlobal.player.campaign.currentMap.villain + "_battleWon";
               this.sendFeed(_loc8_,{"IMGCODE":_loc9_},null);
               return;
            }
            _loc7_++;
         }
         PopupManager.instance.push(new ViralCountdownPopup(this.viralResetTime(_loc8_)),100,false);
      }
      
      public function sendNeighborCrewMemberApply(param1:int, param2:GameItem) : void
      {
         var _loc3_:String = "neighbor_crew_apply";
         var _loc4_:String = ZGlobal.hostPlayer.uid;
         var _loc5_:String = param2.name + "|singular";
         var _loc6_:Object = {
            "URLapplicantId":ZGlobal.player.uid,
            "URLobjID":param1,
            "ITEMTOKbuilding":_loc5_,
            "URLhostId":ZGlobal.hostPlayer.uid
         };
         this.sendFeedWithCallback(_loc3_,_loc6_,_loc4_,CREW_PUBLISHED_CALLBACK_KEY);
      }
      
      public function sendNeighborCrewMemberRemind(param1:int) : void
      {
         var _loc2_:String = "crew_completion_reminder";
         var _loc3_:String = ZGlobal.hostPlayer.uid;
         var _loc4_:Object = {"objID":param1};
         this.sendFeedWithCallback(_loc2_,_loc4_,_loc3_,CREW_PUBLISHED_CALLBACK_KEY);
      }
      
      public function sendNeighborCrewTendRemind(param1:int, param2:GameItem, param3:String) : void
      {
         var _loc4_:String = "crew_tend_reminder";
         var _loc5_:String = param3;
         var _loc6_:String = param2.name + "|singular";
         var _loc7_:Object = {
            "objID":param1,
            "ITEMTOKbuilding":_loc6_
         };
         this.sendFeedWithCallback(_loc4_,_loc7_,_loc5_,CREW_PUBLISHED_CALLBACK_KEY);
      }
      
      public function feedGPVPVictoryTokens() : void
      {
         var _loc1_:int = ZGlobal.gameSettings.getInt("postBattleWinFeedDialogDelay");
         Zlab.processManager.schedule(_loc1_,this,this.onFeedGPVPVictoryTokensDialog);
      }
      
      public function feedGPVPDefeatTokens() : void
      {
         var _loc1_:int = ZGlobal.gameSettings.getInt("postBattleLoseFeedDialogDelay");
         Zlab.processManager.schedule(_loc1_,this,this.onFeedGPVPDefeatTokensDialog);
      }
      
      private function onFeedGPVPVictoryTokensDialog() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("FeedPopups","gpvp_win_ask_tokens_title");
         var _loc2_:String = ZGameUtils.ZlocT("FeedPopups","gpvp_win_ask_tokens");
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Share");
         var _loc4_:String = "assets/game/contracts/Contracts_Icons_0.swf/PVPToken_96.png";
         PopupManager.instance.push(new GlobalPVPFeedPopup(_loc1_,_loc2_,_loc3_,_loc4_,this.sendFeedGPVPVictoryTokens,true));
      }
      
      private function onFeedGPVPDefeatTokensDialog() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("FeedPopups","gpvp_lose_ask_tokens_title");
         var _loc2_:String = ZGameUtils.ZlocT("FeedPopups","gpvp_lose_ask_tokens");
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Share");
         var _loc4_:String = "assets/game/contracts/Contracts_Icons_0.swf/PVPToken_96.png";
         PopupManager.instance.push(new GlobalPVPFeedPopup(_loc1_,_loc2_,_loc3_,_loc4_,this.sendFeedGPVPDefeatTokens));
      }
      
      private function sendFeedGPVPVictoryTokens(param1:MouseEvent) : void
      {
         this.sendFeed("g_pvp_win_ask_for_token",{});
      }
      
      private function sendFeedGPVPDefeatTokens(param1:MouseEvent) : void
      {
         this.sendFeed("g_pvp_lose_ask_for_token",{});
      }
      
      public function feedPVPRepelCrewInvite(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:IPVPPlayer = PVPManager.instance.getPVPPlayer(param1);
         if(_loc2_)
         {
            _loc3_ = param1 == PVPManager.PVE_MARKER_KEY ? "pve_repel_crew_invite" : "pvp_repel_crew_invite";
            this.sendFeed(_loc3_,{
               "invader":_loc2_.firstName,
               "URLinvasionId":param1
            });
         }
      }
      
      public function feedPVPDefeatAttackerViaCrew(param1:String) : void
      {
         this.sendFeed("pvp_defeat_attacker_via_crew",{"invader":param1});
      }
      
      public function feedPVPThankDefender(param1:String, param2:String, param3:String, param4:String) : void
      {
         var _loc5_:FeedPopup = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","pvp_thank_defender_message"),ZGameUtils.ZlocT("FeedPopups","pvp_thank_defender_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onThankDefenderDialogClosed,param4);
         var _loc6_:Object = {
            "target":param1,
            "invader":param2,
            "defender":param3
         };
         _loc5_.userData = _loc6_;
         PopupManager.instance.push(_loc5_);
      }
      
      private function onThankDefenderDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            PopupManager.instance.push(new CommentPopup(this.onThankDefenderCommentClosed,param1.userData));
         }
      }
      
      public function onThankDefenderCommentClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1.button == BattleBasePopup.AUTOSHARE_COMMENT)
         {
            _loc2_ = null;
            if(Boolean(param1.userData) && param1.userData.comment != null)
            {
               _loc2_ = param1.userData.comment as String;
            }
            _loc3_ = null;
            _loc4_ = "pvp_thank_defender";
            if(ZGlobal.autopublishFeedVarient == ZGlobal.EXPERIMENT_AUTOPUBLISH_W2W || ZGlobal.autopublishFeedVarient == ZGlobal.EXPERIMENT_MANUALPUBLISH_W2W)
            {
               _loc3_ = String(param1.userData.target);
               _loc4_ = "pvp_thank_defender_w2w";
            }
            this.sendFeedWithComment(_loc4_,{
               "defender":param1.userData.defender,
               "invader":param1.userData.invader
            },_loc2_,_loc3_);
         }
      }
      
      public function feedPVPImmunityCrewInvite() : void
      {
         this.sendFeed("pvp_immunity_crew_invite",{});
      }
      
      public function feedStarterPackShare(param1:Object = null) : void
      {
         this.sendFeed("starter_pack_share",{});
      }
      
      public function feedRepeatPayerPackShare(param1:Object = null) : void
      {
         if(Boolean(param1) && Boolean(param1.itemCode))
         {
            this.sendFeed("payer_pack_share_" + param1.itemCode,{});
         }
         else
         {
            Logger.debug(this,"feedRepeatPayerPackShare","Not Sending Feed");
         }
      }
      
      public function feedPickYourOwnShare(param1:Object = null) : void
      {
         this.sendFeed("pick_your_own_share",{});
      }
      
      public function giftVictory(param1:String) : void
      {
         PopupManager.instance.push(new RequestGiftDialog("energy01",RequestGiftDialog.VICTORY_GIFTTYPE,RequestDialog.TYPE_GIFT));
      }
      
      public function giftFirstArmy() : void
      {
         PopupManager.instance.push(new RequestGiftDialog("energy01",RequestGiftDialog.FIRST_ARMY_GIFTTYPE));
      }
      
      public function giftFirstNavy() : void
      {
         PopupManager.instance.push(new RequestGiftDialog("energy01",RequestGiftDialog.FIRST_NAVY_GIFTTYPE));
      }
      
      public function giftFirstAir() : void
      {
         PopupManager.instance.push(new RequestGiftDialog("energy01",RequestGiftDialog.FIRST_AIR_GIFTTYPE));
      }
      
      public function giftVillainDefeat() : void
      {
         PopupManager.instance.push(new RequestGiftDialog("expansionkey01",RequestGiftDialog.VILLAIN_DEFEAT_GIFTTYPE));
      }
      
      public function giftRare(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:GameItem = null;
         var _loc4_:String = null;
         if(param1)
         {
            _loc2_ = ZGlobal.gameSettings.getGiftableRareItems();
            _loc3_ = _loc2_[_loc2_.length - 1];
            _loc4_ = _loc3_.getImageObject().url;
            PopupManager.instance.push(new RequestGiftDialog(_loc3_.name,RequestGiftDialog.RARE_GIFTTYPE));
         }
      }
      
      protected function sendItemRequest(param1:String, param2:String = null, param3:String = null) : void
      {
         PopupManager.instance.push(new RequestAskPartsDialog(param1,""));
      }
      
      public function sendEnergyRequest() : Boolean
      {
         var _loc2_:String = null;
         var _loc1_:Boolean = true;
         if(m_energyFeedToggle)
         {
            _loc2_ = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items","energy_sentenceName","singular"));
            _loc1_ = this.sendFeed("out_of_energy",{"resource":_loc2_});
         }
         else
         {
            _loc1_ = this.requestEnergy();
         }
         m_energyFeedToggle = !m_energyFeedToggle;
         return _loc1_;
      }
      
      public function requestEnergy() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.canPost("energy_request"))
         {
            this.sendItemRequest("energy","energy_request");
            this.postViral("energy_request");
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("FeedPopups","cannot_post"),GenericPopup.TYPE_OK));
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      public function sendResourceRequest(param1:String, param2:String = null) : Boolean
      {
         var _loc3_:String = "out_of_" + param1;
         this.sendItemRequest(param1,_loc3_,param2);
         this.postViral(_loc3_);
         return true;
      }
      
      public function sendFeedWithComment(param1:String, param2:Object, param3:String, param4:String = null) : Boolean
      {
         if(this.canPost(param1))
         {
            if(ZGlobal.autopublishFeedVarient == ZGlobal.EXPERIMENT_AUTOPUBLISH_FEED_DISABLED || ZGlobal.autopublishFeedVarient == ZGlobal.EXPERIMENT_MANUALPUBLISH_W2W)
            {
               TransactionManager.addTransaction(new TStreamPublish(param1,param2,param4,param3),true);
            }
            else if(ZGlobal.autopublishFeedMessageVarient == ZGlobal.EXPERIMENT_AUTOPUBLISH_FEED_MESSAGE_ON || ZGlobal.publishFeedPermissionVarient > 0 && ZGlobal.hasPublishPermission == 0)
            {
               TransactionManager.addTransaction(new TStreamPublish(param1,param2,param4,param3,true),true);
            }
            else
            {
               TransactionManager.addTransaction(new TStreamPublishWithComment(param1,param2,param3,param4),true);
            }
            this.postViral(param1);
            return true;
         }
         PopupManager.instance.push(new ViralCountdownPopup(this.viralResetTime(param1)),100,false);
         return false;
      }
      
      public function sendFeedWithTransaction(param1:String, param2:Transaction) : Boolean
      {
         if(this.canPost(param1))
         {
            TransactionManager.addTransaction(param2,true);
            this.postViral(param1);
            return true;
         }
         PopupManager.instance.push(new ViralCountdownPopup(this.viralResetTime(param1)),100,false);
         return false;
      }
      
      public function sendFeed(param1:String, param2:Object, param3:String = null) : Boolean
      {
         var _loc4_:Transaction = null;
         if(ZGlobal.autopublishAllFeedVarient == ZGlobal.EXPERIMENT_AUTOPUBLISH_ALL_FEED_ON && (ZGlobal.publishFeedPermissionVarient == 0 || ZGlobal.hasPublishPermission > 0))
         {
            _loc4_ = new TStreamPublishWithComment(param1,param2,null,param3);
         }
         else
         {
            _loc4_ = new TStreamPublish(param1,param2,param3);
         }
         return this.sendFeedWithTransaction(param1,_loc4_);
      }
      
      public function sendFeedWithLotsOfFriction(param1:String, param2:Object, param3:String = null) : Boolean
      {
         return this.sendFeedWithTransaction(param1,new TStreamPublish(param1,param2,param3));
      }
      
      public function sendFeedWithCallback(param1:String, param2:Object, param3:String, param4:String, param5:String = null) : Boolean
      {
         var _loc6_:Boolean = false;
         if(ZGlobal.autopublishAllFeedVarient == ZGlobal.EXPERIMENT_AUTOPUBLISH_ALL_FEED_ON)
         {
            _loc6_ = true;
         }
         var _loc7_:Transaction = new TStreamPublishWithCallback(param1,param2,param3,param4,param5,_loc6_);
         return this.sendFeedWithTransaction(param1,_loc7_);
      }
      
      public function sendItemFeed(param1:String) : Boolean
      {
         var _loc2_:String = "ask_for_" + param1;
         return this.sendFeed(_loc2_,{});
      }
      
      public function sendAddFriend(param1:String, param2:Object, param3:String) : Boolean
      {
         var _loc4_:Transaction = new TAddFriendPublish(param1,param2,param3);
         TransactionManager.addTransaction(_loc4_,true);
         return true;
      }
   }
}

