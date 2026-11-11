package displays.screens.neighborScreen
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.BountyCenterManager;
   import core.managers.CrewManager;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Friend;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.Tooltip;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarUIItem;
   import core.ui.menuitem.HCxPromoUIItem;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.MessageDispatcher;
   import dispatchers.NeighborsDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.gridScreen.GridSlot;
   import events.ExperienceUpdatedEvent;
   import events.FriendBarSlotEvent;
   import events.NeighborsEvent;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.FriendSlot;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class NeighborSlot extends GridSlot implements IPlayerSlot
   {
      
      private static const SHOW_RARE_QUEST:String = "Q1120";
      
      protected var m_uid:String = null;
      
      protected var m_firstName:String = "";
      
      protected var m_gridIndex:int;
      
      private var m_pvpLoader:ImageLoader = null;
      
      private var m_imageRequested:Boolean = false;
      
      private var m_rareType:int = 0;
      
      private var m_rareImageLoader:ImageLoader = null;
      
      private var m_libertyBondImageLoader:ImageLoader = null;
      
      private var m_slotClass:Class;
      
      private var m_specialSlots:Dictionary = new Dictionary();
      
      public function NeighborSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:Friend, param6:Class, param7:int)
      {
         this.m_slotClass = param6;
         this.m_gridIndex = param7;
         super(param1,param2,param3);
         slot.x = param4;
         slot.y = 0;
         this.m_rareType = param5.m_resourceType;
         this.filloutStats(param5);
         slot.heartlevel_tf.mouseEnabled = false;
         slot.profilelevel_tf.mouseEnabled = false;
         slot.rareloader_mc.mouseEnabled = false;
         slot.rareloader_mc.mouseChildren = false;
         PVPManager.instance.addEventListener(PVPManager.UPDATE_NEIGHBOR_PVP_ICON,this.onUpdatePVPStatus);
         TutorialManager.instance.addEventListener(TutorialManager.UI_HIGHLIGHT_NEIGHBOR,this.onHighlightNeighbor,false,0,true);
         NeighborsDispatcher.instance.addEventListener(NeighborsEvent.TEND_CHECK_TIMEOUT,this.onCheckTendTimeout);
         VisitorManager.instance.addEventListener(VisitorManager.VISITOR_ENERGY_SPENT,this.onVisitEnergyUpdated);
         CrewManager.instance.addEventListener(CrewManager.CREW_NEIGHBORS_JOINED,this.onCrewNeighborsUpdated,false,0,true);
         CrewManager.instance.addEventListener(CrewManager.CREW_NEIGHBORS_REMOVED,this.onCrewNeighborsUpdated,false,0,true);
         CrewManager.instance.addEventListener(CrewManager.CREW_NEIGHBORS_UPDATED,this.onCrewNeighborsUpdated,false,0,true);
      }
      
      public function get empty() : Boolean
      {
         return this.m_uid == null;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function loadImage() : void
      {
         var _loc1_:Player = null;
         if(!this.m_imageRequested)
         {
            _loc1_ = this.getPlayer();
            if(_loc1_)
            {
               this.internalLoadImage(_loc1_);
            }
         }
      }
      
      override public function dispose() : void
      {
         if(this.m_uid == ZGlobal.player.uid)
         {
            ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.GOOD_LEVEL,this.onSocialLevelUpdated);
            ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.BAD_LEVEL,this.onSocialLevelUpdated);
         }
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerLevelUpdated);
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.LEVEL_UP,this.onNeighborLevelUp);
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.INFAMY,this.onInfamyUpdated);
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.HONOR,this.onHonorUpdated);
         PVPManager.instance.removeEventListener(PVPManager.UPDATE_NEIGHBOR_PVP_ICON,this.onUpdatePVPStatus);
         TutorialManager.instance.removeEventListener(TutorialManager.UI_HIGHLIGHT_NEIGHBOR,this.onHighlightNeighbor);
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.TEND_CHECK_TIMEOUT,this.onCheckTendTimeout);
         VisitorManager.instance.removeEventListener(VisitorManager.VISITOR_ENERGY_SPENT,this.onVisitEnergyUpdated);
         CrewManager.instance.removeEventListener(CrewManager.CREW_NEIGHBORS_JOINED,this.onCrewNeighborsUpdated);
         CrewManager.instance.removeEventListener(CrewManager.CREW_NEIGHBORS_REMOVED,this.onCrewNeighborsUpdated);
         CrewManager.instance.removeEventListener(CrewManager.CREW_NEIGHBORS_UPDATED,this.onCrewNeighborsUpdated);
         if(this.m_rareImageLoader)
         {
            this.m_rareImageLoader.destroy();
         }
         super.dispose();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:MovieClip = new this.m_slotClass();
         _loc2_.neighborSlot = this;
         _loc2_.popup_mc = null;
         return _loc2_;
      }
      
      override protected function onSlotCreated() : void
      {
         if(slot.new_tf)
         {
            slot.new_tf.mouseEnabled = false;
            slot.new_tf.visible = false;
         }
         if(slot.crewRemind_mc)
         {
            slot.crewRemind_mc.visible = false;
         }
         if(slot.tendEnergy_mc)
         {
            slot.tendEnergy_mc.visible = false;
         }
      }
      
      protected function get neverShowLabel() : Boolean
      {
         return false;
      }
      
      public function configureAppearance() : void
      {
         var _loc1_:Player = null;
         var _loc2_:Player = null;
         var _loc3_:FriendsBarUIItem = null;
         var _loc4_:Friend = null;
         slot.neighborVisitSlot_mc.visible = false;
         if(slot.newFriendSlot_mc)
         {
            slot.newFriendSlot_mc.visible = false;
         }
         slot.cardBack_mc.visible = false;
         if(slot.survivalModeCard_mc)
         {
            slot.survivalModeCard_mc.visible = false;
         }
         if(slot.MafiaCard_mc)
         {
            slot.MafiaCard_mc.visible = false;
         }
         if(slot.CastleCard_mc)
         {
            slot.CastleCard_mc.visible = false;
         }
         if(slot.ChroniclesCard_mc)
         {
            slot.ChroniclesCard_mc.visible = false;
         }
         if(slot.BingoCard_mc)
         {
            slot.BingoCard_mc.visible = false;
         }
         if(slot.SlingoCard_mc)
         {
            slot.SlingoCard_mc.visible = false;
         }
         if(slot.BubbleSafari_mc)
         {
            slot.BubbleSafari_mc.visible = false;
         }
         if(slot.TheVille_mc)
         {
            slot.TheVille_mc.visible = false;
         }
         if(slot.ChefVille_mc)
         {
            slot.ChefVille_mc.visible = false;
         }
         if(slot.Farmville2_mc)
         {
            slot.Farmville2_mc.visible = false;
         }
         if(slot.Cityville2_mc)
         {
            slot.Cityville2_mc.visible = false;
         }
         if(slot.CoasterVille_mc)
         {
            slot.CoasterVille_mc.visible = false;
         }
         if(slot.MafiaWars_mc)
         {
            slot.MafiaWars_mc.visible = false;
         }
         if(slot.new_tf)
         {
            slot.new_tf.visible = false;
         }
         if(Boolean(this.m_uid) && ZGlobal.player.uid != this.m_uid)
         {
            _loc1_ = ZGlobal.player;
            _loc2_ = ZGlobal.hostPlayer;
            if(ZGlobal.hostPlayer != null && ZGlobal.hostPlayer != ZGlobal.player && ZGlobal.hostPlayer.uid == this.m_uid)
            {
               slot.neighborVisitSlot_mc.visible = true;
            }
            else if(!this.neverShowLabel && ZGlobal.player.getNeighborVisitTime(this.m_uid) < 0 && Number(this.m_uid) > 0)
            {
               if(slot.newFriendSlot_mc)
               {
                  slot.newFriendSlot_mc.visible = true;
               }
               TextFieldUtil.processTextField(slot.new_tf,ZGameUtils.ZlocT("Dialogs","NewCaps"));
               slot.new_tf.visible = true;
            }
            else if(this.m_uid == Player.SURVIVAL_MODE_ALY_ID)
            {
               if(slot.newFriendSlot_mc)
               {
                  slot.newFriendSlot_mc.visible = true;
               }
               TextFieldUtil.compactTextField(slot.new_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeNeighborCardTitle1"),{
                  "minScale":0.5,
                  "filter":"scale"
               });
               slot.new_tf.visible = true;
               slot.profilelevel_tf.visible = false;
               slot.heartlevel_tf.visible = false;
               slot.rareloader_mc.visible = false;
               slot.level_mc.visible = false;
               if(slot.survivalModeCard_mc)
               {
                  slot.survivalModeCard_mc.visible = true;
               }
            }
            else if(this.m_uid == Player.MW2_XPROMO_ALLY_ID)
            {
               if(slot.newFriendSlot_mc)
               {
                  slot.newFriendSlot_mc.visible = true;
               }
               slot.profilelevel_tf.visible = false;
               slot.heartlevel_tf.visible = false;
               slot.rareloader_mc.visible = false;
               slot.level_mc.visible = false;
               if(slot.MafiaCard_mc)
               {
                  slot.MafiaCard_mc.visible = true;
               }
            }
            else if(this.m_uid == Player.CASTLE_XPROMO_ALLY_ID)
            {
               if(slot.newFriendSlot_mc)
               {
                  slot.newFriendSlot_mc.visible = true;
               }
               slot.profilelevel_tf.visible = false;
               slot.heartlevel_tf.visible = false;
               slot.rareloader_mc.visible = false;
               slot.level_mc.visible = false;
               if(slot.CastleCard_mc)
               {
                  slot.CastleCard_mc.visible = true;
               }
            }
            else if(this.m_uid == Player.HC_XPROMO_ALLY_ID)
            {
               if(slot.newFriendSlot_mc)
               {
                  slot.newFriendSlot_mc.visible = true;
               }
               slot.profilelevel_tf.visible = false;
               slot.heartlevel_tf.visible = false;
               slot.rareloader_mc.visible = false;
               slot.level_mc.visible = false;
               if(slot.ChroniclesCard_mc)
               {
                  slot.ChroniclesCard_mc.visible = true;
                  StatsManager.countSample(10,"neighbor_card","xpromo","view",HCxPromoUIItem.GAME_ID);
               }
            }
            else
            {
               slot.cardBack_mc.visible = true;
               if(this.m_uid != Player.FAKE_PLAYER_ID && this.m_uid != ZGlobal.player.uid)
               {
                  PromoManager.instance.addSpecialCard(this.m_uid,slot);
               }
            }
            _loc3_ = FriendsBarUIItem.getFriendsBar() as FriendsBarUIItem;
            _loc4_ = _loc3_.findNeighborById(this.m_uid);
            if(_loc4_)
            {
               this.updateTendInfo(_loc4_);
            }
         }
         else
         {
            slot.cardBack_mc.visible = true;
            if(this.m_uid != Player.FAKE_PLAYER_ID && this.m_uid != ZGlobal.player.uid)
            {
               PromoManager.instance.addSpecialCard(this.m_uid,slot);
            }
         }
      }
      
      public function configureRareIcon() : void
      {
         if(!this.m_rareImageLoader)
         {
            this.m_rareImageLoader = ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURL(this.m_rareType,WorldResourceManager.XTRA_SMALL_ICON),slot.ore_mc);
         }
         if(slot.ore_mc)
         {
            slot.ore_mc.visible = ZGlobal.player.didCompleteQuest(SHOW_RARE_QUEST);
            if(this.m_uid == Player.SURVIVAL_MODE_ALY_ID || this.m_uid == Player.MW2_XPROMO_ALLY_ID)
            {
               slot.ore_mc.visible = false;
            }
         }
      }
      
      public function configureBountyIcon() : void
      {
         var _loc1_:Player = null;
         if(!slot.bond_mc)
         {
            return;
         }
         if(BountyCenterManager.instance.displayLibertyHUDIcons && BountyCenterManager.instance.currentState == BountyCenterManager.STATE_ACTIVE)
         {
            _loc1_ = ZGlobal.player.findFriendById(this.m_uid);
            if(null != _loc1_ && ZGlobal.player.uid != _loc1_.uid)
            {
               if(BountyCenterManager.instance.isLevelEligible(parseInt(slot.profilelevel_tf.text)))
               {
                  slot.bond_mc.visible = true;
                  this.m_libertyBondImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BondBlue_36.png"),slot.bond_mc);
                  return;
               }
            }
         }
         slot.bond_mc.visible = false;
      }
      
      protected function filloutStats(param1:Friend) : void
      {
         var _loc2_:Player = null;
         if(null != param1)
         {
            _loc2_ = this.getPlayerByUid(param1.uid);
            if(null == _loc2_ || param1.uid == ZGlobal.player.uid)
            {
               _loc2_ = ZGlobal.player;
               ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.GOOD_LEVEL,this.onSocialLevelUpdated,false,0,true);
               ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.BAD_LEVEL,this.onSocialLevelUpdated,false,0,true);
            }
            else
            {
               MessageDispatcher.instance.addEventListener(MessageDispatcher.LEVEL_UP,this.onNeighborLevelUp);
               MessageDispatcher.instance.addEventListener(MessageDispatcher.INFAMY,this.onInfamyUpdated);
               MessageDispatcher.instance.addEventListener(MessageDispatcher.HONOR,this.onHonorUpdated);
            }
            ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerLevelUpdated,false,0,true);
            this.m_uid = _loc2_.uid;
            TextFieldUtil.processTextField(slot.profilelevel_tf,param1.level.toString());
            this.cacheFirstName(_loc2_,param1);
            if(param1.uid == Player.MW2_XPROMO_ALLY_ID || param1.uid == Player.CASTLE_XPROMO_ALLY_ID || param1.uid == Player.HC_XPROMO_ALLY_ID)
            {
               slot.profilename_tf_white.visible = true;
               slot.profilename_tf.visible = false;
               this.loadName(param1,slot.profilename_tf_white);
            }
            else
            {
               if(slot.profilename_tf_white)
               {
                  slot.profilename_tf_white.visible = false;
               }
               slot.profilename_tf.visible = true;
               this.loadName(param1,slot.profilename_tf);
            }
            this.loadSocialXPImage(param1);
            this.updatePVPStatus();
            this.configureAppearance();
            this.configureRareIcon();
            this.configureBountyIcon();
            slot.clanDataInit = false;
         }
         else
         {
            slot.profilelevel_tf.text = "";
         }
      }
      
      private function loadName(param1:Friend, param2:TextField) : void
      {
         TextFieldUtil.processTextField(param2,this.m_firstName);
         this.updateTendInfo(param1);
         this.updateCrewInfo();
      }
      
      public function updateTendInfo(param1:Friend) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc2_:Boolean = param1.uid != ZGlobal.player.uid;
         if(param1.tendInfo)
         {
            _loc3_ = ZGlobal.gameSettings.getInt("maxVisitingEnergy");
            _loc4_ = _loc3_ - param1.tendInfo.actions;
            if(_loc4_ == 0)
            {
               _loc2_ = false;
            }
         }
         if(_loc2_)
         {
            if(ZGlobal.isVisiting() && this.m_uid == ZGlobal.hostPlayer.uid && !PVPManager.instance.isNormalVisit())
            {
               _loc2_ = false;
            }
            else
            {
               _loc5_ = PVPManager.instance.getPlayerInvasionInfoForNeighbor(this.m_uid);
               if((Boolean(_loc5_)) && (_loc5_.status == PVPManager.STATUS_INCOMBAT || _loc5_.status == PVPManager.STATUS_OCCUPIED))
               {
                  _loc2_ = false;
               }
            }
         }
         if(this.m_uid == Player.SURVIVAL_MODE_ALY_ID || this.m_uid == Player.MW2_XPROMO_ALLY_ID || this.m_uid == Player.CASTLE_XPROMO_ALLY_ID || this.m_uid == Player.HC_XPROMO_ALLY_ID || parseInt(this.m_uid) < parseInt(Player.HC_XPROMO_ALLY_ID))
         {
            _loc2_ = false;
         }
         this.tendEnergyIndicatorVisible = _loc2_;
      }
      
      private function internalLoadImage(param1:Player) : void
      {
         if(null != param1.snUser.picture)
         {
            this.m_imageRequested = true;
            ImageLoaderFactory.CreateImageLoader(param1.snUser.picture,slot.profileloader_mc,this.onPlayerImageLoaded);
         }
      }
      
      private function onPlayerImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(Boolean(slot) && Boolean(slot.manIcon_mc))
         {
            slot.manIcon_mc.visible = false;
         }
      }
      
      private function loadSocialXPImage(param1:Friend) : void
      {
         this.updateSocialXPImage(param1.m_socialLevelGood,param1.m_socialLevelBad,param1.m_dominanceRank);
      }
      
      protected function get alwaysShowBadLevel() : Boolean
      {
         return false;
      }
      
      private function updateSocialXPImage(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(DominationModeManager.instance.enabled && param3 > 0)
         {
            _loc4_ = "assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_32.png";
            _loc5_ = param3.toString();
         }
         else if(this.alwaysShowBadLevel || param2 > param1)
         {
            _loc4_ = "assets/game/PvpGeneralAssetGroup_UI.swf/BlackHeart_01_36.png";
            _loc5_ = param2.toString();
         }
         else
         {
            _loc4_ = "assets/game/PvpGeneralAssetGroup_UI.swf/RedHeart_01_36.png";
            _loc5_ = param1.toString();
         }
         var _loc6_:String = ZGlobal.getAssetURL(_loc4_);
         ImageLoaderFactory.CreateImageLoader(_loc6_,slot.rareloader_mc);
         TextFieldUtil.processTextField(slot.heartlevel_tf,_loc5_);
      }
      
      private function onPlayerLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         if(this.m_uid == ZGlobal.player.uid)
         {
            TextFieldUtil.processTextField(slot.profilelevel_tf,param1.newAmount.toString());
         }
         else if(PVPManager.canLevelParticipate(param1.newAmount) && !PVPManager.canLevelParticipate(param1.oldAmount))
         {
            this.updatePVPStatus();
         }
         this.configureBountyIcon();
      }
      
      private function onNeighborLevelUp(param1:WorldEvent) : void
      {
         if(this.m_uid == param1.eventData.player)
         {
            TextFieldUtil.processTextField(slot.profilelevel_tf,param1.eventData.level.toString());
            this.configureBountyIcon();
         }
      }
      
      protected function getPlayer() : Player
      {
         return this.getPlayerByUid(this.m_uid);
      }
      
      protected function getPlayerByUid(param1:String) : Player
      {
         if(param1 == ZGlobal.player.uid)
         {
            return ZGlobal.player;
         }
         var _loc2_:Player = ZGlobal.player.findFriendById(param1);
         if(_loc2_)
         {
            return _loc2_;
         }
         var _loc3_:IPVPPlayer = PVPManager.instance.getPVPPlayer(param1);
         if(_loc3_ as Player)
         {
            return _loc3_ as Player;
         }
         return null;
      }
      
      private function onInfamyUpdated(param1:WorldEvent) : void
      {
         var _loc2_:Player = null;
         if(this.m_uid == param1.eventData.player)
         {
            _loc2_ = this.getPlayer();
            if(_loc2_)
            {
               _loc2_.socialLevelBad = param1.eventData.level;
               this.socialLevelUpdated("FeedbackInfamyLevelUp",_loc2_,param1.eventData.level);
            }
         }
      }
      
      private function onHonorUpdated(param1:WorldEvent) : void
      {
         var _loc2_:Player = null;
         if(this.m_uid == param1.eventData.player)
         {
            _loc2_ = this.getPlayer();
            if(_loc2_)
            {
               _loc2_.socialLevelGood = param1.eventData.level;
               this.socialLevelUpdated("FeedbackHonorLevelUp",_loc2_,param1.eventData.level);
            }
         }
      }
      
      private function socialLevelUpdated(param1:String, param2:Player, param3:int) : void
      {
         this.onSocialLevelUpdated(null);
         PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main",param1,{
            "user":param2.localizationName,
            "level":param3
         }),null,null,param2.uid);
      }
      
      private function onSocialLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         var _loc2_:Player = this.getPlayer();
         if(_loc2_)
         {
            this.updateSocialXPImage(_loc2_.socialLevelGood,_loc2_.socialLevelBad,DominationModeManager.instance.dominanceRank);
         }
      }
      
      private function onHighlightNeighbor(param1:WorldEvent) : void
      {
         var _loc2_:Point = null;
         if(this.m_uid == param1.eventData.id)
         {
            _loc2_ = null;
            TutorialManager.instance.addArrowToUIElement(slot,true,true);
            if(param1.eventData.stencil == true)
            {
               _loc2_ = new Point(35,55);
               TutorialManager.instance.addStencilToUIElement(slot,_loc2_,1);
            }
         }
      }
      
      private function onVisitEnergyUpdated(param1:Event) : void
      {
         var _loc2_:FriendsBarUIItem = null;
         var _loc3_:Friend = null;
         var _loc4_:int = 0;
         if(this.m_uid == ZGlobal.hostPlayer.uid)
         {
            _loc2_ = FriendsBarUIItem.getFriendsBar() as FriendsBarUIItem;
            _loc3_ = _loc2_.findNeighborById(this.m_uid);
            if(Boolean(_loc3_) && Boolean(_loc3_.tendInfo))
            {
               _loc4_ = ZGlobal.gameSettings.getInt("maxVisitingEnergy");
               if(ZGlobal.player.visitorEnergy == _loc4_ - 1)
               {
                  _loc3_.tendInfo.ts = GlobalEngine.serverTime / 1000;
               }
               _loc3_.tendInfo.actions = _loc4_ - ZGlobal.player.visitorEnergy;
               this.updateTendInfo(_loc3_);
            }
         }
      }
      
      protected function onCrewNeighborsUpdated(param1:WorldEvent) : void
      {
         if(param1.eventData == null || param1.eventData.owner == null || param1.eventData.owner == this.m_uid)
         {
            this.updateCrewInfo();
         }
      }
      
      private function onCheckTendTimeout(param1:WorldEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Friend = param1.eventData.friend;
         if(this.m_uid == _loc2_.id)
         {
            if(Boolean(_loc2_.tendInfo) && _loc2_.tendInfo.actions > 0)
            {
               _loc3_ = ZGlobal.gameSettings.getInt("friendVisitCooldown");
               if(param1.eventData.currentTime >= _loc2_.tendInfo.ts + _loc3_)
               {
                  _loc2_.tendInfo.actions = 0;
                  this.updateTendInfo(_loc2_);
               }
            }
            param1.stopImmediatePropagation();
            param1.stopPropagation();
         }
      }
      
      protected function onUpdatePVPStatus(param1:WorldEvent) : void
      {
         if(param1.eventData == this.m_uid)
         {
            this.updatePVPStatus();
         }
      }
      
      private function set tendEnergyIndicatorVisible(param1:Boolean) : void
      {
         var _loc2_:String = null;
         slot.tendEnergy_mc.visible = param1;
         if(param1)
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","EnergyIcon");
            Tooltip.subscribe(slot.tendEnergy_mc,_loc2_);
         }
         else
         {
            Tooltip.unsubscribe(slot.tendEnergy_mc);
         }
      }
      
      private function set crewIndicatorVisible(param1:Boolean) : void
      {
         var _loc2_:String = null;
         slot.crewRemind_mc.visible = param1;
         if(param1)
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","CrewIcon");
            Tooltip.subscribe(slot.crewRemind_mc,_loc2_);
         }
         else
         {
            Tooltip.unsubscribe(slot.crewRemind_mc);
         }
      }
      
      private function updatePVPStatus() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc4_:String = null;
         if(this.m_pvpLoader)
         {
            this.m_pvpLoader.destroy();
            this.m_pvpLoader = null;
            Tooltip.unsubscribe(slot.pvploader_mc);
         }
         if(!PVPManager.canLevelParticipate(ZGlobal.player.level))
         {
            return;
         }
         var _loc3_:Object = PVPManager.instance.getPlayerInvasionInfoForNeighbor(this.m_uid);
         if(Boolean(_loc3_) && (_loc3_.status == PVPManager.STATUS_INCOMBAT || _loc3_.status == PVPManager.STATUS_OCCUPIED))
         {
            _loc2_ = "assets/game/GeneralAssetGroup_UI.swf/playerOccupying_icon_24.png";
            _loc1_ = ZGameUtils.ZlocT("Dialogs","PVPPlayerOccupied");
         }
         else if(PVPManager.instance.neighborHasUnDefendedOccupiers(this.m_uid))
         {
            _loc2_ = "assets/game/GeneralAssetGroup_UI.swf/friendOccupied_icon_24.png";
            _loc1_ = ZGameUtils.ZlocT("Dialogs","PVPFriendOccupied");
         }
         else if(PVPManager.instance.isNeighborImmune(this.m_uid))
         {
            _loc2_ = "assets/game/GeneralAssetGroup_UI.swf/Immunity_24.png";
            _loc1_ = ZGameUtils.ZlocT("Dialogs","PVPImmunityOn");
         }
         if(_loc2_)
         {
            _loc4_ = ZGlobal.getAssetURL(_loc2_);
         }
         Tooltip.subscribe(slot.pvploader_mc,_loc1_);
         this.m_pvpLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,slot.pvploader_mc);
      }
      
      protected function updateCrewInfo() : void
      {
         var _loc1_:Boolean = CrewManager.instance.isCrewMemberOf(this.m_uid);
         this.crewIndicatorVisible = _loc1_;
      }
      
      private function cacheFirstName(param1:Player, param2:Friend) : void
      {
         if(Boolean(param1 && param1.snUser) && Boolean(param1.snUser.firstName) && param1.snUser.firstName.length > 0)
         {
            this.m_firstName = param1.snUser.firstName;
         }
         else if(Boolean(param2) && Boolean(param2.m_name != null) && param2.m_name.length > 0)
         {
            this.m_firstName = param2.m_name;
         }
         else if(Boolean(param1) && Boolean(param1.snUser))
         {
            this.m_firstName = param1.snUser.uid;
         }
         else
         {
            this.m_firstName = "-";
         }
      }
      
      private function get mc() : MovieClip
      {
         return slot.popup_mc;
      }
      
      public function configureTooltip(param1:String, param2:FriendSlot) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc3_:String = param1;
         var _loc4_:Object = ZGlobal.player.neighbors[_loc3_];
         if(_loc4_)
         {
            if(_loc4_.clanName)
            {
               _loc6_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Player_tooltip1",{"Aname":_loc4_.clanName});
               TextFieldUtil.compactTextField(param2.popup_mc.generic_tf,_loc6_);
               _loc5_ = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(ZGlobal.player.neighbors[this.m_uid].crestId,48));
            }
            else if(AlliancesManager.instance.clanName)
            {
               _loc5_ = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(AlliancesManager.instance.crestId,48));
               _loc7_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Player_tooltip1",{"Aname":AlliancesManager.instance.clanName});
               TextFieldUtil.compactTextField(param2.popup_mc.generic_tf,_loc7_);
            }
            else
            {
               _loc5_ = ZGlobal.getAssetURL(AlliancesManager.instance.getPath(9999,48));
               _loc7_ = ZGameUtils.ZlocT("Dialogs","Alliance_4_Create");
               TextFieldUtil.compactTextField(param2.popup_mc.title_tf,_loc7_);
               param2.popup_mc.title_tf.visible = true;
               param2.popup_mc.generic_tf.visible = false;
               param2.popup_mc.generic2_tf.visible = false;
               param2.popup_mc.add_bt.visible = false;
            }
            param2.popup_mc.visible = true;
            ImageLoaderFactory.CreateImageLoader(_loc5_,param2.popup_mc.icon);
            param2.clanDataInit = true;
            this.setupAllianceTooltip(_loc3_,param2.popup_mc);
         }
         else
         {
            param2.popup_mc.visible = false;
         }
      }
      
      private function setupAllianceTooltip(param1:String, param2:MovieClip) : void
      {
         var _loc4_:ZGameButton = null;
         var _loc5_:String = null;
         var _loc6_:ZGameButton = null;
         var _loc7_:ZGameButton = null;
         var _loc8_:ZGameButton = null;
         var _loc9_:ZGameButton = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         param2.shield_bt.visible = false;
         param2.icon.visible = false;
         var _loc3_:Object = ZGlobal.player.neighbors[param1];
         if(AlliancesManager.isLevelOk() && !AlliancesManager.instance.isAllianceMember(param1))
         {
            if(AlliancesManager.instance.isValidNeighbor(_loc3_))
            {
               if(Boolean(_loc3_.clanId && _loc3_.canAddMembers && !AlliancesManager.instance.isAllianceMember(param1)) && Boolean(!AlliancesManager.instance.clanName) && !AlliancesManager.instance.isJoinRequestSent(param1))
               {
                  _loc7_ = new ZGameButton(param2.shield_bt,this.onAllianceJoin,1);
                  _loc7_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceJoin");
                  param2.shield_bt.visible = true;
                  param2.icon.visible = true;
                  this.allianceClanIconLoad(_loc3_);
                  return;
               }
               if(!(Boolean(_loc3_.clanId) && Boolean(_loc3_.canAddMembers)))
               {
                  if(!_loc3_.clanId && Boolean(AlliancesManager.instance.clanName))
                  {
                     if(AlliancesManager.instance.canShowInvite())
                     {
                        _loc4_ = new ZGameButton(param2.shield_bt,this.onAllianceInvite,1);
                        _loc4_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceInvite");
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","Alliances_4_no_alliance",{"Aname":_loc3_.name});
                        TextFieldUtil.compactTextField(param2.generic2_tf,_loc5_);
                        param2.generic2_tf.visible = true;
                        param2.shield_bt.visible = true;
                        param2.icon.visible = true;
                        this.allianceClanIconLoad(_loc3_);
                        if(AlliancesManager.instance.isJoinRequestSent(param1))
                        {
                           _loc4_.disable_visual(true);
                        }
                        return;
                     }
                     _loc4_ = new ZGameButton(param2.shield_bt,this.onAllianceInvite,1);
                     _loc4_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceInvite");
                     _loc5_ = ZGameUtils.ZlocT("Dialogs","Alliances_4_full");
                     TextFieldUtil.compactTextField(param2.generic2_tf,_loc5_);
                     param2.generic2_tf.visible = true;
                     param2.shield_bt.visible = true;
                     param2.icon.visible = true;
                     if(AlliancesManager.instance.leaderId == ZGlobal.player.uid)
                     {
                        param2.add_bt.visible = true;
                     }
                     _loc8_ = new ZGameButton(param2.add_bt,this.onCreate,1);
                     this.allianceClanIconLoad(_loc3_);
                     _loc4_.disable_visual(true);
                     if(AlliancesManager.instance.leaderId == ZGlobal.player.uid)
                     {
                        if(AlliancesManager.instance.members.length >= AlliancesManager.ALLIANCE_MEMBER_LIMIT)
                        {
                           _loc8_.disable_visual(true);
                           param2.add_bt.visible = false;
                        }
                     }
                     else
                     {
                        _loc8_.disable_visual(true);
                        param2.add_bt.visible = false;
                     }
                     return;
                  }
                  if(Boolean(_loc3_.clanId) && Boolean(!_loc3_.canAddMembers) && !AlliancesManager.instance.clanName)
                  {
                     _loc9_ = new ZGameButton(param2.shield_bt,this.onAllianceFull,1);
                     _loc9_.disable_visual(true);
                     _loc9_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceJoin");
                     _loc10_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Player_tooltip1",{"Aname":_loc3_.clanName});
                     TextFieldUtil.compactTextField(param2.generic_tf,_loc10_);
                     _loc11_ = ZGameUtils.ZlocT("Dialogs","Alliances_4_fr_full");
                     TextFieldUtil.compactTextField(param2.generic2_tf,_loc11_);
                     param2.generic_tf.visible = true;
                     param2.generic2_tf.visible = true;
                     param2.shield_bt.visible = true;
                     param2.title_tf.visible = false;
                     param2.icon.visible = true;
                     this.allianceClanIconLoad(_loc3_);
                     return;
                  }
               }
            }
            else if(!_loc3_.clanId && Boolean(AlliancesManager.instance.clanName))
            {
               _loc4_ = new ZGameButton(param2.shield_bt,this.onAllianceInvite,1);
               _loc4_.disable_visual(true);
               _loc4_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceInvite");
               _loc5_ = ZGameUtils.ZlocT("Dialogs","Alliances_4_below_level",{"Aname":_loc3_.name});
               TextFieldUtil.compactTextField(param2.generic2_tf,_loc5_);
               param2.generic2_tf.visible = true;
               param2.shield_bt.visible = true;
               param2.icon.visible = true;
               this.allianceClanIconLoad(_loc3_);
               return;
            }
         }
         if(Boolean(_loc3_ && !_loc3_.clanName) && Boolean(!AlliancesManager.instance.clanName) && AlliancesManager.isLevelOk())
         {
            _loc6_ = new ZGameButton(param2.shield_bt,this.onCreate,1);
            _loc6_.text = ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_Create");
            param2.shield_bt.visible = true;
            param2.icon.visible = true;
            this.allianceClanIconLoad(_loc3_,9999);
         }
         else if(Boolean(_loc3_) && Boolean(_loc3_.clanName) && Boolean(AlliancesManager.instance.clanName))
         {
            _loc6_ = new ZGameButton(param2.shield_bt,this.onAllianceFull,1);
            _loc6_.disable_visual(true);
            _loc6_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceJoin");
            _loc5_ = ZGameUtils.ZlocT("Dialogs","Alliances_4_msg_5",{"Aname":_loc3_.name});
            TextFieldUtil.compactTextField(param2.title_tf,_loc5_);
            param2.title_tf.visible = true;
            param2.shield_bt.visible = true;
            param2.icon.visible = true;
            this.allianceClanIconLoad(_loc3_);
         }
         else
         {
            _loc6_ = new ZGameButton(param2.shield_bt,this.onAllianceFull,1);
            _loc6_.disable_visual(true);
            _loc6_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceJoin");
            param2.shield_bt.visible = true;
            param2.icon.visible = true;
            this.allianceClanIconLoad(_loc3_);
         }
      }
      
      private function allianceClanIconLoad(param1:Object, param2:int = -1) : void
      {
         var _loc3_:int = 0;
         if(!param1.crestId)
         {
            _loc3_ = AlliancesManager.instance.crestId;
         }
         else
         {
            _loc3_ = int(param1.crestId);
         }
         if(param2 != -1)
         {
            _loc3_ = param2;
         }
         var _loc4_:String = AlliancesManager.instance.getPath(_loc3_,48);
         _loc4_ = ZGlobal.getAssetURL(_loc4_);
         ImageLoaderFactory.CreateImageLoader(_loc4_,this.mc.icon);
      }
      
      private function onAllianceFull(param1:MouseEvent) : void
      {
      }
      
      private function onCreate(param1:MouseEvent) : void
      {
         this.mc.visible = false;
         var _loc2_:FriendsBarUIItem = UIManager.instance.getMenuItemByName(FriendsBarUIItem.ITEM_ID) as FriendsBarUIItem;
         if(_loc2_)
         {
            _loc2_.showAllianceUI();
         }
      }
      
      private function onAllianceInvite(param1:MouseEvent) : void
      {
         this.mc.visible = false;
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_ALLIANCE,this));
      }
      
      private function onAddSlot(param1:MouseEvent) : void
      {
         this.mc.visible = false;
      }
      
      private function onAllianceJoin(param1:MouseEvent) : void
      {
         this.mc.visible = false;
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_JOIN_ALLIANCE,this));
      }
   }
}

