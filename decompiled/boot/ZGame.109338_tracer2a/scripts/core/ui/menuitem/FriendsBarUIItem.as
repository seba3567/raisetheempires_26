package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.gameobjects.GameItem;
   import core.managers.AllianceQuestManager;
   import core.managers.AlliancesManager;
   import core.managers.BountyCenterManager;
   import core.managers.PVPManager;
   import core.managers.PopulationManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.assetLoadTracker.AssetLoadTracker;
   import core.managers.domination.DominationModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Friend;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UIManager;
   import dispatchers.MessageDispatcher;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.AllianceQuestMain;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.alliancePopup.AllianceMemberSelect;
   import displays.popups.alliancePopup.allianceComingSoon;
   import displays.popups.journalPopup.JournalPopup;
   import displays.screens.neighborScreen.ControlNeighborGrid;
   import displays.screens.neighborScreen.INeighborsReceiver;
   import displays.screens.neighborScreen.NeighborGrid;
   import displays.screens.neighborScreen.Varient1NeighborGrid;
   import displays.screens.requests.RequestAllianceInviteDialog;
   import displays.screens.requests.RequestDialog;
   import entity.GameDataComponent;
   import events.FriendBarEvent;
   import events.FriendBarSlotEvent;
   import events.NeighborsEvent;
   import events.PopulationEvent;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import init.ActionQueue;
   import transactions.TNeighborRecommendations;
   import transactions.TNeighborSuggestions;
   import transactions.TRequestAllianceInvite;
   import transactions.TRequestAllianceJoin;
   import transactions.TWorldLoad;
   import transactions.clans.TClearNotifications;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.FriendBarMenu;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class FriendsBarUIItem extends UsersBarUIItem implements INeighborsReceiver
   {
      
      public static const SUGGESTED_NEIGHBORS_RECEIVED:String = "suggestedNeighborsReceived";
      
      private static var m_recommendedNeighborOffset:int = 0;
      
      private static var m_suggestedNeighborOffset:int = 0;
      
      public static const ITEM_ID:String = "friendsBar";
      
      private static const RESERVED_NON_NEIGHBORGRID_WIDTH:int = 300;
      
      private static const MAX_FRIENDBAR_WIDTH:int = 1000;
      
      private var m_neighborGrid:NeighborGrid = null;
      
      private var m_displayObject:FriendBarMenu;
      
      private var m_neighbors:Array;
      
      private var m_recommendedNeighbors:Array = null;
      
      private var m_suggestedNeighbors:Array = null;
      
      private var m_friendsLoaded:Boolean = false;
      
      private var m_varient:int = 0;
      
      private var m_slots:Array = [];
      
      private var m_originalWidth:Number = 0;
      
      private var m_loadCardImagesOnCreation:Boolean = false;
      
      private var m_allianceManager:AlliancesManager;
      
      public function FriendsBarUIItem()
      {
         super(ITEM_ID);
         this.m_displayObject = new FriendBarMenu();
         addChild(this.m_displayObject);
         this.m_originalWidth = this.m_displayObject.width;
         this.m_allianceManager = AlliancesManager.instance;
         NeighborsDispatcher.instance.addEventListener(NeighborsEvent.FRIENDS_LOADED,this.onFriendsLoaded);
         NeighborsDispatcher.instance.addEventListener(NeighborsEvent.NEW_NEIGHBOR_ADDED,this.onNeighborsUpdated);
         this.hideUnusedElements();
         this.loadCrestIcon();
         this.hideAllianceFlag();
         MessageDispatcher.instance.addEventListener(MessageDispatcher.LEVEL_UP,this.onNeighborLeveledUp);
         NeighborsDispatcher.instance.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onSlotClick,false,0,true);
         PopulationManager.instance.addEventListener(PopulationEvent.MAX_POPULATION_CHANGE,this.onPlayerWorkersUpdated,false,0,true);
         PopulationManager.visitInstance.addEventListener(PopulationEvent.MAX_POPULATION_CHANGE,this.onPlayerWorkersUpdated,false,0,true);
         VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onVisitWorldLoaded,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestCompleteEvent,false,0,true);
         BountyCenterManager.instance.addEventListener(BountyCenterManager.EVENT_STATE_CHANGE,this.onBountyCenterStatusChange,false,0,true);
         AssetLoadTracker.GlobalDispatcher.addEventListener(AssetLoadTracker.GLOBAL_ASSETS_LOADED,this.onWorldLoaded);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_FRIENDBAR_RESIZE,this.onResize,false,0,true);
         UIDispatcher.instance.addEventListener(AlliancesManager.UPDATE_CREST_ICON,this.loadCrestIcon);
         UIDispatcher.instance.addEventListener(AlliancesManager.SHOW_ALLIANCES_NOTIFICATION,this.showAllianceNotification);
         UIDispatcher.instance.addEventListener(AlliancesManager.HIDE_ALLIANCES_NOTIFICATION,this.hideAllianceNotification);
         AllianceQuestManager.instance.addEventListener(AllianceQuestManager.SHOW_FLAG,this.showAllianceFlag);
         AllianceQuestManager.instance.addEventListener(AllianceQuestManager.HIDE_FLAG,this.hideAllianceFlag);
         ActionQueue.instance.addEventListener(Event.COMPLETE,this.onPostActionComplete,false,0,true);
      }
      
      public static function getFriendsBar() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(ITEM_ID);
      }
      
      public static function get recommendedNeighborOffset() : int
      {
         return m_recommendedNeighborOffset;
      }
      
      public static function set recommendedNeighborOffset(param1:int) : void
      {
         m_recommendedNeighborOffset = param1;
      }
      
      public static function get suggestedNeighborOffset() : int
      {
         return m_suggestedNeighborOffset;
      }
      
      public static function set suggestedNeighborOffset(param1:int) : void
      {
         m_suggestedNeighborOffset = param1;
      }
      
      private function loadCrestIcon(param1:Event = null) : void
      {
         var _loc2_:String = null;
         if(param1 == null)
         {
            _loc2_ = ZGlobal.getAssetURL(this.m_allianceManager.getPath(9999,48));
         }
         else if(AlliancesManager.isValid())
         {
            _loc2_ = ZGlobal.getAssetURL(this.m_allianceManager.getPath(this.m_allianceManager.crestId,48));
         }
         else
         {
            _loc2_ = ZGlobal.getAssetURL(this.m_allianceManager.getPath(9999,48));
         }
         if(this.m_displayObject.shield_bt)
         {
            this.m_displayObject.m_crest = ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_displayObject.shield_bt.icon);
            this.m_displayObject.m_crest.smooth = true;
         }
      }
      
      private function showAllianceFlag(param1:Event = null) : void
      {
         if(this.m_displayObject.AQFlag_mc)
         {
            this.m_displayObject.AQFlag_mc.visible = true;
            this.m_displayObject.AQFlag_mc.useHandCursor = true;
            this.m_displayObject.AQFlag_mc.addEventListener(MouseEvent.CLICK,this.onAllianceFlagClick);
         }
      }
      
      private function onAllianceFlagClick(param1:Event) : void
      {
         AllianceQuestManager.instance.showQuest();
      }
      
      private function hideAllianceFlag(param1:Event = null) : void
      {
         if(this.m_displayObject.AQFlagIcon_mc)
         {
            this.m_displayObject.AQFlagIcon_mc.visible = false;
         }
         if(this.m_displayObject.AQFlag_mc)
         {
            this.m_displayObject.AQFlag_mc.visible = false;
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         AssetLoadTracker.GlobalDispatcher.removeEventListener(AssetLoadTracker.GLOBAL_ASSETS_LOADED,this.onWorldLoaded);
         this.m_loadCardImagesOnCreation = true;
         if(this.m_neighborGrid)
         {
            this.m_neighborGrid.loadCardImages();
         }
      }
      
      override protected function onUserGridScrolled(param1:FriendBarEvent) : void
      {
         if(this.m_loadCardImagesOnCreation)
         {
            this.m_neighborGrid.loadCardImages();
         }
      }
      
      private function onFriendsLoaded(param1:NeighborsEvent) : void
      {
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.FRIENDS_LOADED,this.onFriendsLoaded);
         this.m_friendsLoaded = true;
         this.tryToCreateGrid();
         updateWorldName(ZGlobal.player.worldName);
      }
      
      override protected function onNeighborsLoaded(param1:NeighborsEvent) : void
      {
         this.m_neighbors = param1.friends;
         this.m_varient = param1.varient;
         this.tryToCreateGrid();
         super.onNeighborsLoaded(param1);
      }
      
      private function tryToCreateGrid() : void
      {
         var _loc1_:Boolean = ZGlobal.player.hasFriendsSNData();
         Logger.print(this,new Error().getStackTrace());
         Logger.print(this,"tryToCreateGrid");
         Logger.print(this,"m_friendsLoaded = " + (this.m_friendsLoaded ? "true" : "false"));
         Logger.print(this,"hasFriendsSNData = " + (_loc1_ ? "true" : "false"));
         if((Boolean(this.m_friendsLoaded || ZGlobal.player.hasFriendsSNData())) && Boolean(this.m_neighbors) && this.m_neighbors.length > 0)
         {
            if(this.m_varient == 2)
            {
               this.m_neighborGrid = new Varient1NeighborGrid(this.m_displayObject.grid_mc,this.m_neighbors,this);
            }
            else if(this.m_varient == 1)
            {
               this.m_neighborGrid = new ControlNeighborGrid(this.m_displayObject.grid_mc,this.m_neighbors,this);
            }
            else
            {
               this.m_neighborGrid = new ControlNeighborGrid(this.m_displayObject.grid_mc,this.m_neighbors,this);
            }
            if(this.m_loadCardImagesOnCreation)
            {
               this.m_neighborGrid.loadCardImages();
            }
         }
      }
      
      private function onResize(param1:RepositionEvent) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = Math.min(param1.width,MAX_FRIENDBAR_WIDTH);
         this.x = Math.floor((param1.width - _loc2_) * 0.5);
         this.m_displayObject.bg_mc.width = _loc2_;
         this.m_displayObject.floatR_mc.x = _loc2_;
         if(this.m_neighborGrid)
         {
            this.m_neighborGrid.onResize();
            this.m_displayObject.grid_mc.x = Math.max(Math.round((_loc2_ - RESERVED_NON_NEIGHBORGRID_WIDTH - this.m_neighborGrid.uiWidth() - 4) * 0.5),0);
            if(this.m_loadCardImagesOnCreation)
            {
               this.m_neighborGrid.loadCardImages();
            }
         }
      }
      
      public function get neighbors() : Array
      {
         if(this.m_neighborGrid != null)
         {
            return this.m_neighborGrid.neighbors;
         }
         return new Array();
      }
      
      public function get originalWidth() : Number
      {
         return this.m_originalWidth;
      }
      
      public function get uiHeight() : Number
      {
         return this.m_displayObject.bg_mc.height;
      }
      
      public function get neighborGridWidth() : Number
      {
         return this.m_displayObject.bg_mc.width - RESERVED_NON_NEIGHBORGRID_WIDTH;
      }
      
      public function get neighborGrid() : NeighborGrid
      {
         return this.m_neighborGrid;
      }
      
      public function get friendBarVarient() : int
      {
         return this.m_varient;
      }
      
      override public function removeItem() : void
      {
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.FRIENDS_LOADED,this.onFriendsLoaded);
         NeighborsDispatcher.instance.removeEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onSlotClick);
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.NEW_NEIGHBOR_ADDED,this.onNeighborsUpdated);
         PopulationManager.instance.removeEventListener(PopulationEvent.MAX_POPULATION_CHANGE,this.onPlayerWorkersUpdated);
         PopulationManager.visitInstance.removeEventListener(PopulationEvent.MAX_POPULATION_CHANGE,this.onPlayerWorkersUpdated);
         VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onVisitWorldLoaded);
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.LEVEL_UP,this.onNeighborLeveledUp);
         AssetLoadTracker.GlobalDispatcher.removeEventListener(AssetLoadTracker.GLOBAL_ASSETS_LOADED,this.onWorldLoaded);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_FRIENDBAR_RESIZE,this.onResize);
         UIDispatcher.instance.removeEventListener(AlliancesManager.SHOW_ALLIANCES_NOTIFICATION,this.showAllianceNotification);
         UIDispatcher.instance.removeEventListener(AlliancesManager.HIDE_ALLIANCES_NOTIFICATION,this.hideAllianceNotification);
         this.m_displayObject.parent.removeChild(this.m_displayObject);
         this.m_displayObject = null;
         super.removeItem();
      }
      
      private function hideUnusedElements() : void
      {
         this.m_displayObject.grid_mc.slot_0.visible = false;
         this.m_displayObject.grid_mc.slot_7.visible = false;
         this.m_displayObject.grid_mc.arrowSingleLtVarient_bt.visible = false;
         this.m_displayObject.grid_mc.arrowLtVarient_bt.visible = false;
         this.m_displayObject.grid_mc.mask_mc.visible = false;
         this.m_displayObject.grid_mc.maskVarient_mc.visible = false;
         this.m_displayObject.info_bt.visible = false;
      }
      
      private function onVisitWorldLoaded(param1:Event) : void
      {
         var _loc2_:Player = ZGlobal.hostPlayer;
         if(Number(_loc2_.uid) >= 0 && _loc2_.uid != ZGlobal.player.uid && ZGlobal.player.getNeighborVisitTime(_loc2_.uid) < 0)
         {
            ZGlobal.player.setNeighborVisitTime(_loc2_.uid,0);
         }
         this.m_neighborGrid.updateCardStatus();
      }
      
      private function onQuestCompleteEvent(param1:Event) : void
      {
         this.m_neighborGrid.updateCardRareIcon();
      }
      
      private function onBountyCenterStatusChange(param1:Event) : void
      {
         this.m_neighborGrid.updateCardBountyIcon();
      }
      
      protected function onSlotClick(param1:FriendBarSlotEvent) : void
      {
         var _loc2_:Player = null;
         var _loc3_:Friend = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:FeedPopup = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(!param1.slot.empty && param1.slot.uid != ZGlobal.player.uid)
         {
            if(param1.buttonType == FriendBarSlotEvent.BUTTON_ATTACK || param1.buttonType == FriendBarSlotEvent.BUTTON_CONTINUE_ATTACK)
            {
               this.visitNeighbor(param1.slot.uid,PVPManager.VISIT_MODE_ATTACK,TWorldLoad.DBG_ATTACK,false,param1.debugContext);
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_PILLAGE)
            {
               this.visitNeighbor(param1.slot.uid,PVPManager.VISIT_MODE_PILLAGE,TWorldLoad.DBG_PILLAGE,false,param1.debugContext);
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_VISIT)
            {
               if(param1.slot.uid != ZGlobal.hostPlayer.uid)
               {
                  this.visitNeighbor(param1.slot.uid,PVPManager.VISIT_MODE_NONE,TWorldLoad.DBG_VISIT,false,param1.debugContext);
               }
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_MARKET)
            {
               if(param1.slot.uid == ZGlobal.hostPlayer.uid)
               {
                  this.showMarket();
               }
               else
               {
                  this.visitNeighbor(param1.slot.uid,PVPManager.VISIT_MODE_NONE,TWorldLoad.DBG_MARKET,true,param1.debugContext);
               }
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_GIFT)
            {
               if(param1.slot.uid != ZGlobal.hostPlayer.uid)
               {
                  ZGlobal.switchToTab("gifts");
               }
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_CHALLENGE)
            {
               this.visitNeighbor(param1.slot.uid,PVPManager.VISIT_MODE_ATTACK,TWorldLoad.DBG_ATTACKCHALLENGE,false,param1.debugContext);
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_REQ_RESOURCE)
            {
               if(param1.slot.uid != ZGlobal.player.uid)
               {
                  _loc2_ = ZGlobal.player.findFriendById(param1.slot.uid);
                  _loc3_ = this.findNeighborById(param1.slot.uid);
                  _loc4_ = WorldResourceManager.instance.getResourceFriendlyNameFromIndex(_loc3_.m_resourceType,GameItem.SENTENCE_FRIENDLYNAME);
                  _loc5_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc3_.m_resourceType);
                  _loc6_ = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","request_resource",{
                     "resource":ZGameUtils.ZlocTk("Items",_loc5_ + "_sentenceName","plural"),
                     "friend":_loc2_.firstName
                  }),ZGameUtils.ZlocT("FeedPopups","request_resource_title",{"resource":ZGameUtils.ZlocTk("Items",_loc5_ + "_sentenceName","plural")}),ZGameUtils.ZlocT("FeedPopups","feed_request_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onRequestResourcesClick,WorldResourceManager.instance.getResourceImageURL(_loc3_.m_resourceType,WorldResourceManager.XTRA_LARGE_ICON));
                  _loc7_ = new Object();
                  _loc7_.uid = param1.slot.uid;
                  _loc7_.name = _loc5_;
                  _loc7_.localized = _loc4_;
                  _loc6_.userData = _loc7_;
                  PopupManager.instance.push(_loc6_);
               }
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_ALLIANCE)
            {
               StatsManager.count("alliances","invite","friend_bar");
               PopupManager.instance.push(new RequestAllianceInviteDialog());
               AlliancesManager.instance.addJoinRequest(param1.slot.uid);
               _loc8_ = {
                  "player":ZGlobal.player.name,
                  "allianceName":AlliancesManager.instance.clanName
               };
               TransactionManager.addTransaction(new TRequestAllianceInvite([param1.slot.uid],RequestDialog.TYPE_ALLIANCE,_loc8_));
            }
            else if(param1.buttonType == FriendBarSlotEvent.BUTTON_JOIN_ALLIANCE)
            {
               StatsManager.count("alliances","join","friend_bar");
               AlliancesManager.instance.addJoinRequest(param1.slot.uid);
               _loc9_ = ZGlobal.player.neighbors[param1.slot.uid];
               _loc10_ = {
                  "player":ZGlobal.player.name,
                  "allianceName":_loc9_.clanName
               };
               TransactionManager.addTransaction(new TRequestAllianceJoin([param1.slot.uid],RequestDialog.TYPE_ALLIANCE,_loc9_.clanId,_loc10_));
            }
         }
      }
      
      private function visitNeighbor(param1:String, param2:int, param3:int, param4:Boolean = false, param5:String = null) : void
      {
         TransactionManager.addTransaction(new TWorldLoad(param1,param2,{
            "dbg":param3,
            "ctx":param5
         },param4),true);
      }
      
      public function returnToHomeIsland() : Boolean
      {
         TransactionManager.addTransaction(new TWorldLoad(ZGlobal.player.uid,PVPManager.VISIT_MODE_NONE,{"dbg":TWorldLoad.DBG_RETURN},false),true);
         return true;
      }
      
      public function showMarket() : void
      {
         var _loc3_:IEntity = null;
         var _loc4_:GameDataComponent = null;
         var _loc5_:GameItem = null;
         var _loc6_:BuildingFSMComponent = null;
         var _loc1_:Boolean = false;
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","production");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
            _loc5_ = _loc4_.gameData;
            if((Boolean(_loc5_)) && _loc5_.name == "Market")
            {
               _loc6_ = BuildingFSMComponent(_loc3_.lookupComponentByType(BuildingFSMComponent));
               if(_loc6_)
               {
                  _loc1_ = _loc6_.forceClick();
                  if(_loc1_)
                  {
                     break;
                  }
               }
            }
         }
         if(!_loc1_)
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","NoMarket",{"user":ZLoc.tn("",ZGlobal.hostPlayer.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)}),GenericPopup.TYPE_OK));
         }
      }
      
      private function onRequestResourcesClick(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendResourceRequest(param1.userData.name,param1.userData.uid);
         }
      }
      
      public function findNeighborById(param1:String) : Friend
      {
         var _loc4_:Object = null;
         var _loc2_:Friend = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.neighbors.length)
         {
            if(this.neighbors[_loc3_].id == param1)
            {
               _loc2_ = this.neighbors[_loc3_];
            }
            _loc3_++;
         }
         if(_loc2_ == null)
         {
            if(AlliancesManager.isPhase4Enabled() && Boolean(AlliancesManager.instance.isAllianceMember(param1)))
            {
               _loc4_ = AlliancesManager.instance.memberInfo(param1);
               if(_loc4_.image == null || _loc4_.image == "")
               {
                  _loc4_.image = ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
               }
               _loc2_ = new Friend(_loc4_.uid,_loc4_.coins,_loc4_.xp,_loc4_.level,_loc4_.socialXpGood,_loc4_.socialLevelGood,_loc4_.socialXpBad,_loc4_.socialLevelBad,_loc4_.resource,_loc4_.image,_loc4_.name,0);
            }
         }
         return _loc2_;
      }
      
      public function set recommendedNeighbors(param1:Array) : void
      {
         this.m_recommendedNeighbors = param1;
         if(Boolean(this.m_neighborGrid) && this.m_neighborGrid is Varient1NeighborGrid)
         {
            ControlNeighborGrid(this.m_neighborGrid).startRotation();
         }
      }
      
      public function get recommendedNeighbors() : Array
      {
         return this.m_recommendedNeighbors;
      }
      
      public function set suggestedNeighbors(param1:Array) : void
      {
         this.m_suggestedNeighbors = param1;
         if(this.m_suggestedNeighbors == null)
         {
            this.m_suggestedNeighbors = new Array();
         }
         NeighborsDispatcher.instance.dispatchEvent(new Event(SUGGESTED_NEIGHBORS_RECEIVED));
      }
      
      public function get suggestedNeighbors() : Array
      {
         return this.m_suggestedNeighbors;
      }
      
      override protected function get flagText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Journal_Title");
      }
      
      override protected function onFlagMove(param1:MouseEvent) : void
      {
         if(!this.m_displayObject.flag.useHandCursor)
         {
            if(this.m_displayObject.flag.mouseY < 35)
            {
               activateFlag();
            }
         }
         else if(this.m_displayObject.flag.mouseY > 35)
         {
            if(this.m_displayObject.flag.useHandCursor)
            {
               onFlagOut(null);
            }
         }
      }
      
      override protected function onFlagClick(param1:MouseEvent) : void
      {
         super.onFlagClick(param1);
         PopupManager.instance.push(new JournalPopup());
      }
      
      override protected function onAllianceMove(param1:MouseEvent) : void
      {
      }
      
      override protected function onAllianceClick(param1:Event) : void
      {
         if(AlliancesManager.instance.m_motdActive)
         {
            AlliancesManager.instance.m_motdActive = false;
            TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
            TutorialManager.instance.sendEvent(TutorialManager.UI_DISABLE);
            TutorialManager.instance.sendEvent(TutorialManager.UI_ENABLE);
         }
         if(this.m_displayObject.alliancesClose_btn.visible)
         {
            this.m_displayObject.alliancesClose_btn.visible = false;
            this.m_displayObject.alliancesOpen_btn.visible = true;
         }
         if(AlliancesManager.instance.hasNewRival())
         {
            DominationModeManager.instance.launchDominationScreen("rivals");
         }
         else if(AlliancesManager.isValid())
         {
            if(this.m_allianceManager.isInitialised())
            {
               PopupManager.instance.push(new AllianceMemberSelect(this.m_displayObject,this.x,this.y,this.changeUpDown));
            }
            else
            {
               PopupManager.instance.push(new AllianceQuestMain());
            }
         }
         else
         {
            PopupManager.instance.push(new allianceComingSoon(this.m_displayObject,this.x,this.y));
         }
         if(!ZGlobal.player.getSeenFlag(AlliancesManager.ALLIANCE_SEEN_FLAG) && AlliancesManager.isValid())
         {
            ZGlobal.player.setSeenFlag(AlliancesManager.ALLIANCE_SEEN_FLAG);
         }
         UIDispatcher.instance.dispatchEvent(new Event(AlliancesManager.HIDE_ALLIANCES_NOTIFICATION));
      }
      
      public function showAllianceUI() : void
      {
         this.onAllianceClick(null);
      }
      
      public function changeUpDown() : void
      {
         this.m_displayObject.alliancesClose_btn.visible = true;
         this.m_displayObject.alliancesOpen_btn.visible = false;
      }
      
      private function onNeighborsUpdated(param1:WorldEvent) : void
      {
         Logger.print(this,"onNeighborsUpdated");
         if(this.m_neighborGrid)
         {
            this.m_neighborGrid.dispose();
            this.m_neighborGrid = null;
         }
         var _loc2_:Object = param1.eventData;
         var _loc3_:Friend = new Friend(_loc2_.uid,_loc2_.coins,_loc2_.xp,_loc2_.level,_loc2_.socialXpGood,_loc2_.socialLevelGood,_loc2_.socialXpBad,_loc2_.socialLevelBad,_loc2_.resource,_loc2_.profilePic,_loc2_.name,_loc2_.dominanceRank);
         _loc3_.tendInfo = _loc2_.tending;
         this.m_neighbors.push(_loc3_);
         this.m_neighbors.sortOn("xp",Array.NUMERIC,Array.DESCENDING);
         this.m_neighbors.reverse();
         this.tryToCreateGrid();
      }
      
      private function onNeighborLeveledUp(param1:WorldEvent) : void
      {
         var _loc2_:Player = ZGlobal.player.findFriendById(param1.eventData.player);
         if(_loc2_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackLevelUp",{
               "user":_loc2_.localizationName,
               "level":param1.eventData.level
            }),null,null,_loc2_.uid);
         }
      }
      
      private function onPostActionComplete(param1:Event) : void
      {
         Zlab.processManager.schedule(15000,this,this.doSuggestedNeighborTransaction);
      }
      
      private function doSuggestedNeighborTransaction() : void
      {
         TransactionManager.addTransaction(new TNeighborSuggestions(this));
         NeighborsDispatcher.instance.addEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.doRecommendedNeighborTransaction,false,0,true);
      }
      
      private function doRecommendedNeighborTransaction(param1:Event) : void
      {
         NeighborsDispatcher.instance.removeEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.doRecommendedNeighborTransaction);
         if(this.friendBarVarient == ZGlobal.EXPERIMENT_FRIENDSBAR_SHOW_RECOMMENDED_NEIGHBORS)
         {
            TransactionManager.addTransaction(new TNeighborRecommendations(this));
         }
      }
      
      public function forceSuggestedNeighborTransaction() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         TransactionManager.addTransaction(new TNeighborSuggestions(this));
      }
      
      override protected function get displayObject() : MovieClip
      {
         return this.m_displayObject;
      }
      
      override protected function get localizedTabSubtitleLabel() : String
      {
         return ZGameUtils.ZlocT("Main","PopulationCount");
      }
      
      override protected function get tabSubtitleNumerator() : int
      {
         return PopulationManager.instance.maxWorkers;
      }
      
      override protected function get tabSubtitleDenominator() : int
      {
         return PopulationManager.instance.maxWorkersCap;
      }
      
      private function onPlayerWorkersUpdated(param1:PopulationEvent) : void
      {
         updateTabSubtitleDigits();
      }
      
      override protected function get populationTF() : TextField
      {
         return this.displayObject.population_tf;
      }
      
      private function showAllianceNotification(param1:Event) : void
      {
         this.m_displayObject.info_bt.visible = true;
      }
      
      private function hideAllianceNotification(param1:Event) : void
      {
         if(this.m_displayObject.info_bt.visible)
         {
            TransactionManager.addTransaction(new TClearNotifications(),true);
            AlliancesManager.instance.clearNewRival();
         }
         this.m_displayObject.info_bt.visible = false;
      }
   }
}

