package transactions
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.gamemode.avatar.AvatarComponent;
   import core.managers.AlliancesManager;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.managers.PopulationManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Player;
   import core.ui.menuitem.FriendsBarUIItem;
   import core.ui.menuitem.OptionUIItem;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.views.ViewManager;
   import core.worlds.AbstractWorld;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.ModalPopup;
   import flash.events.Event;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class TWorldLoad extends Transaction
   {
      
      public static var DBG_RETURN:int = 0;
      
      public static var DBG_ATTACK:int = 1;
      
      public static var DBG_PILLAGE:int = 2;
      
      public static var DBG_VISIT:int = 3;
      
      public static var DBG_MARKET:int = 4;
      
      public static var DBG_ATTACKCHALLENGE:int = 5;
      
      public static var DBG_STARTUPID:int = 6;
      
      public static var DBG_ATTACK_GLOBAL_PVP:int = 7;
      
      protected var m_userId:String;
      
      protected var m_mapName:String;
      
      protected var m_showMarket:Boolean = false;
      
      protected var m_visitingPopup:ModalPopup = null;
      
      protected var m_pvpMode:int;
      
      protected var m_dbg:Object;
      
      public function TWorldLoad(param1:String, param2:int, param3:Object, param4:Boolean = false)
      {
         var _loc5_:Object = null;
         super();
         this.m_userId = param1;
         this.m_mapName = "home";
         this.m_showMarket = param4;
         this.m_pvpMode = param2;
         this.m_dbg = param3;
         if(param2 == PVPManager.VISIT_MODE_NONE && param1 != ZGlobal.player.uid && param1 != Player.FAKE_PLAYER_ID)
         {
            if(ZGlobal.player.neighbors[param1])
            {
               _loc5_ = ZGlobal.player.neighbors[param1];
               if(_loc5_.pvpInfo)
               {
                  this.m_dbg.pvp = _loc5_.pvpInfo;
               }
            }
         }
         UIDispatcher.instance.dispatchEvent(new Event(AvatarComponent.CANCEL_AVATAR_ORDERS));
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.loadWorld",this.m_userId.toString(),this.m_mapName,this.m_pvpMode,this.m_dbg);
      }
      
      override public function preAddTransaction() : void
      {
         var _loc5_:int = 0;
         var _loc1_:Object = this.getMessageData();
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs",_loc1_.label,_loc1_.data);
         var _loc3_:String = this.getPopupAsset();
         var _loc4_:Object = AlliancesManager.instance.neighborInfo(this.m_userId);
         if((Boolean(_loc4_)) && Boolean(AlliancesManager.instance.members))
         {
            _loc5_ = AlliancesManager.instance.members.indexOf(this.m_userId);
            if(_loc5_ > -1)
            {
               _loc4_.crestId = AlliancesManager.instance.crestId;
            }
         }
         this.m_visitingPopup = new ModalPopup(_loc2_,null,_loc3_,_loc4_);
         PopupManager.instance.push(this.m_visitingPopup,0,false,true);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Player = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:GenericPopup = null;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc15_:SocialNetworkUser = null;
         var _loc16_:Object = null;
         if(param1.gf)
         {
            return;
         }
         this.m_visitingPopup.pop();
         this.m_visitingPopup = null;
         if(param1.pvpMode != this.m_pvpMode || Boolean(param1.novisit))
         {
            switch(this.m_pvpMode)
            {
               case PVPManager.VISIT_MODE_NONE:
                  _loc8_ = "PVPCannotVisitNeighbor";
                  break;
               case PVPManager.VISIT_MODE_PILLAGE:
                  _loc8_ = "PVPCannotVisitNeighborPillage";
                  break;
               case PVPManager.VISIT_MODE_ATTACK:
                  _loc8_ = "PVPCannotVisitNeighborAttack";
            }
            _loc9_ = ZGameUtils.ZlocT("Dialogs",_loc8_);
            _loc10_ = GenericPopup1B.NewOk(_loc9_,null);
            PopupManager.instance.push(_loc10_);
            return;
         }
         param1.world.yimf = new XML(param1.yimf);
         PVPManager.instance.setCurrentVisitInfo(param1,this.m_userId,param1.globalPVP);
         ZGlobal.player.storeNonFriendInfo(param1.nonFriendInfo);
         VisitorManager.instance.worldVisited(param1.untendableObjIDs);
         var _loc5_:SpeechPopup = null;
         var _loc6_:String = null;
         if(this.m_userId == ZGlobal.player.uid)
         {
            _loc2_ = ZGlobal.player;
            ZGlobal.setHost(_loc2_);
            PopulationManager.instance.reset();
            _loc2_.preLoadObject(param1);
            if(TutorialManager.instance.active)
            {
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.RETURN_HOME_CONTINUE));
            }
         }
         else if(ZGlobal.player.findFriendById(this.m_userId) != null && (Boolean(ZGlobal.player.neighbors[this.m_userId] != null) || Boolean(AlliancesManager.instance.isAllianceMember(this.m_userId))))
         {
            _loc2_ = ZGlobal.player.findFriendById(this.m_userId);
            ZGlobal.setHost(_loc2_);
            if(!PVPManager.instance.isNormalVisit() && !PVPManager.instance.isPillageVisit() && !PVPManager.instance.isVisitBattleContinue())
            {
               _loc6_ = ZGlobal.gameSettings.getString("PVPInitialInvasionSpeechPopupID");
               if(_loc6_)
               {
                  _loc5_ = new SpeechPopup(_loc6_);
                  PopupManager.instance.push(_loc5_,0,true,false);
               }
            }
            _loc3_ = ZGlobal.player.getFriendFirstName(this.m_userId);
            _loc4_ = ZGlobal.player.findFriendById(this.m_userId).snUser.gender;
            if(_loc3_ == null)
            {
               _loc3_ = ZGameUtils.ZlocT("Main","Friend");
            }
            if(ZGlobal.player.neighbors[this.m_userId])
            {
               _loc11_ = ZGlobal.player.neighbors[this.m_userId];
            }
            else
            {
               _loc11_ = AlliancesManager.instance.memberInfo(this.m_userId);
            }
            _loc12_ = new Object();
            _loc12_.player = new Object();
            _loc12_.player.playerResourceType = _loc11_.resource;
            _loc12_.player.expansions = param1.expansions;
            _loc12_.world = param1.world;
            _loc2_.preLoadObject(_loc12_);
         }
         else
         {
            _loc13_ = PVPManager.instance.getGlobalPVPStrangerInfo(this.m_userId);
            if(_loc13_)
            {
               _loc14_ = {
                  "name":_loc13_.friendInfo.m_name,
                  "image":_loc13_.friendInfo.m_profilePic,
                  "gender":_loc13_.playerInfo.snUser.gender,
                  "resourceType":_loc13_.friendInfo.m_resourceType
               };
            }
            _loc15_ = new SocialNetworkUser(parseInt(this.m_userId));
            _loc16_ = new Object();
            _loc16_.player = new Object();
            _loc16_.player.expansions = param1.expansions;
            _loc16_.world = param1.world;
            if(Boolean(_loc14_) && Boolean(_loc15_))
            {
               _loc15_.firstName = _loc14_.name;
               _loc15_.picture = _loc14_.image;
               _loc15_.gender = _loc14_.gender;
               _loc3_ = _loc14_.name;
               _loc4_ = _loc15_.gender;
               _loc16_.player.playerResourceType = _loc14_.resourceType;
            }
            _loc2_ = new Player(_loc15_);
            ZGlobal.setHost(_loc2_);
            if(!PVPManager.instance.isNormalVisit() && !PVPManager.instance.isPillageVisit() && !PVPManager.instance.isVisitBattleContinue())
            {
               _loc6_ = "Speech_GPVP_Initial_Invasion";
               if(_loc6_)
               {
                  _loc5_ = new SpeechPopup(_loc6_);
                  PopupManager.instance.push(_loc5_,0,true,false);
               }
            }
            _loc2_.preLoadObject(_loc16_);
         }
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).setRareStatsItem();
         if(param1.hasOwnProperty("rsyncEnergy"))
         {
            ZGlobal.player.m_energy.energy = param1.rsyncEnergy as int;
         }
         if(param1.hasOwnProperty("rsyncAmmo"))
         {
            ZGlobal.player.m_ammo.ammo = param1.rsyncAmmo as int;
         }
         if(!param1.hasOwnProperty("worldName"))
         {
            param1.worldName == null;
         }
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.PLAYER_NAME_LOADED,param1.worldName));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.TITAN_NAME_LOADED,param1.titanName));
         param1.world.ownerId = this.m_userId.toString();
         var _loc7_:AbstractWorld = ZGlobal.game.getWorld(IslandWorld.ID);
         _loc7_.releaseObjects();
         ZGlobal.player.initVisitorEnergy(param1.visitorEnergy != null ? int(param1.visitorEnergy) : 0);
         _loc7_.loadObjects(param1.world);
         VisitorManager.instance.dispatchEvent(new Event(VisitorManager.WORLD_LOADED));
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.WORLD_LOADED_CONTINUE,this.m_userId));
         }
         OptionUIItem.worldLoaded();
         if(_loc2_.fleets)
         {
            _loc2_.fleets.setupExistingBattles();
         }
         ViewManager.instance.goToView(ViewManager.instance.currentViewName);
         if(this.m_showMarket)
         {
            FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).showMarket();
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
      }
      
      private function onVisitDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:XMLList = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = ZGlobal.gameSettings.getXML().defaultAlly;
            if(ZGlobal.hostPlayer.uid != _loc2_.uid)
            {
               ViralsManager.instance.sendFeed("friend_visit",{});
            }
         }
      }
      
      private function getMessageData() : Object
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc1_:Object = new Object();
         var _loc2_:Boolean = true;
         if(this.m_userId == ZGlobal.player.uid)
         {
            _loc1_.label = "ReturningHomeMessage";
            _loc2_ = false;
         }
         else if(this.m_pvpMode == PVPManager.VISIT_MODE_PILLAGE)
         {
            _loc1_.label = "LoadingWorldAttackMessage";
         }
         else if(this.m_pvpMode == PVPManager.VISIT_MODE_ATTACK)
         {
            if(PVPManager.instance.isInInitialCombat(this.m_userId))
            {
               _loc1_.label = "LoadingWorldContinueAttackMessage";
            }
            else
            {
               _loc1_.label = "LoadingWorldInvadeMessage";
            }
         }
         else
         {
            _loc3_ = PVPManager.instance.getNeighborAssist(this.m_userId);
            if(_loc3_ != null && ChallengeModeManager.instance.isChallengeIDInProgress(_loc3_.chID))
            {
               _loc1_.label = "LoadingWorldRepelMessage";
            }
            else
            {
               _loc1_.label = "LoadingWorldMessage";
            }
         }
         if(_loc2_)
         {
            _loc4_ = ZGlobal.player.findFriendById(this.m_userId);
            if(!_loc4_)
            {
               _loc4_ = PVPManager.instance.getPVPPlayer(this.m_userId) as Player;
            }
            if(_loc4_)
            {
               _loc1_.data = {"world":Player.GetWorldName(_loc4_.firstName,_loc4_.snUser.gender)};
            }
         }
         return _loc1_;
      }
      
      private function getPopupAsset() : String
      {
         if(PVPManager.instance.getStrangerSlotIndex(this.m_userId) != -1 || PVPManager.instance.getStrangerSlotIndex(ZGlobal.hostPlayer.uid) != -1 && this.m_userId == ZGlobal.player.uid)
         {
            return "assets/displays/dialogs/PU_ModalPopUp_BattleBlitz.swf";
         }
         if(this.m_userId != ZGlobal.player.uid && this.m_pvpMode != PVPManager.VISIT_MODE_NONE)
         {
            return "assets/displays/screens/PVP_ModalPopUp.swf";
         }
         if(AlliancesManager.isExperimentEnabled() && this.m_userId != ZGlobal.player.uid && this.m_pvpMode == PVPManager.VISIT_MODE_NONE && Boolean(AlliancesManager.instance.neighborInfo(this.m_userId)))
         {
            return "assets/displays/dialogs/PU_AllianceLoader.swf";
         }
         return "assets/displays/dialogs/PU_ModalPopUp.swf";
      }
   }
}

