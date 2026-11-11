package displays.screens.neighborScreen
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.MatchMakingManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Friend;
   import core.player.Player;
   import core.ui.menuitem.HCxPromoUIItem;
   import dispatchers.NeighborsDispatcher;
   import displays.screens.gridScreen.GridSlot;
   import events.ExperienceUpdatedEvent;
   import events.FriendBarSlotEvent;
   import events.NeighborsEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class NeighborGrid extends UserGrid
   {
      
      public function NeighborGrid(param1:MovieClip, param2:Array, param3:Object)
      {
         super(param1,param2,param3);
         PromoManager.instance.addEventListener(PromoManager.XPROMO_ADD_CARD,this.onRefreshXPromoCard);
      }
      
      private function onRefreshXPromoCard(param1:WorldEvent) : void
      {
         this.refreshCards();
      }
      
      override public function onVisitClick(param1:NeighborSlot, param2:String) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_VISIT,param1,false,false,param2));
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.NEIGHBOR_VISIT_CLICKED,param1.uid));
         }
         menuClicked();
      }
      
      override public function onAttackClick(param1:NeighborSlot, param2:Boolean) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,param2 ? FriendBarSlotEvent.BUTTON_CONTINUE_ATTACK : FriendBarSlotEvent.BUTTON_ATTACK,param1));
         menuClicked();
      }
      
      override public function onPillageClick(param1:NeighborSlot) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_PILLAGE,param1));
         menuClicked();
      }
      
      override public function onGiftClick(param1:NeighborSlot) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_GIFT,param1));
         menuClicked();
      }
      
      override public function onRequestResourceClick(param1:NeighborSlot) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_REQ_RESOURCE,param1));
         menuClicked();
      }
      
      override public function onMarketClick(param1:NeighborSlot) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_MARKET,param1));
         menuClicked();
      }
      
      override public function onAllianceClick(param1:NeighborSlot) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_ALLIANCE,param1));
         menuClicked();
      }
      
      override public function onAllianceJoinClick(param1:NeighborSlot) : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_JOIN_ALLIANCE,param1));
         menuClicked();
      }
      
      override protected function startTendTimeout() : void
      {
         var _loc5_:Friend = null;
         var _loc1_:Number = 30 * 1000;
         Zlab.processManager.schedule(_loc1_,this,this.startTendTimeout);
         var _loc2_:Number = GlobalEngine.getTimer() / 1000;
         var _loc3_:int = int(m_neighbors.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = m_neighbors[_loc4_] as Friend;
            if(_loc5_)
            {
               NeighborsDispatcher.instance.dispatchEvent(new WorldEvent(NeighborsEvent.TEND_CHECK_TIMEOUT,{
                  "friend":_loc5_,
                  "currentTime":_loc2_
               }));
            }
            _loc4_++;
         }
      }
      
      override protected function createContextMenu(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         switch(param1.currentTarget.neighborSlot.uid)
         {
            case Player.FAKE_PLAYER_ID:
               if(ZGlobal.isHome() || ZGlobal.hostPlayer.uid != Player.FAKE_PLAYER_ID)
               {
                  m_contextMenu = new ContextualMenuWrapperAdvisor(param1.currentTarget.neighborSlot,this);
               }
               break;
            case ZGlobal.player.uid:
               if(ZGlobal.visitMode == ZGlobal.MODE_VISIT)
               {
                  m_contextMenu = new ContextualMenuWrapperPlayer(param1.currentTarget.neighborSlot,this);
               }
               break;
            case Player.SURVIVAL_MODE_ALY_ID:
               SurvivalModeManager.instance.launchSurvivalMode(SurvivalModeManager.ENTRY_POINT_CARD);
               break;
            case Player.MW2_XPROMO_ALLY_ID:
               _loc2_ = ZGlobal.gameSettings.getString("MW2XPromoURL");
               navigateToURL(new URLRequest(_loc2_),null);
               break;
            case Player.CASTLE_XPROMO_ALLY_ID:
               _loc2_ = ZGlobal.gameSettings.getString("CastleXPromoURL");
               navigateToURL(new URLRequest(_loc2_),null);
               break;
            case Player.HC_XPROMO_ALLY_ID:
               _loc2_ = ZGlobal.gameSettings.getString("HCXPromoURL");
               StatsManager.countSample(10,"neighbor_card","xpromo","okay",HCxPromoUIItem.GAME_ID);
               navigateToURL(new URLRequest(_loc2_),null);
               break;
            default:
               _loc3_ = PromoManager.instance.getXPromoById(param1.currentTarget.neighborSlot.uid);
               if(_loc3_ != null)
               {
                  _loc2_ = _loc3_.ui.install_url;
                  navigateToURL(new URLRequest(_loc2_),null);
                  StatsManager.countSample(10,"neighbor_card","xpromo","click","chefVille",_loc3_.id);
               }
               else
               {
                  m_contextMenu = new ContextualMenuWrapperAlly(param1.currentTarget.neighborSlot,this);
               }
         }
      }
      
      private function refreshCards() : void
      {
         var _loc1_:GridSlot = null;
         for each(_loc1_ in m_cards)
         {
            _loc1_.dispose();
         }
         m_neighbors = m_actualNeighbors;
         populateNeighbors(m_actualNeighbors);
         createCards(m_resource);
         loadCardImages();
      }
      
      override public function recreateCards(param1:ExperienceUpdatedEvent) : void
      {
         if(doesLocalPlayerChangePosition(param1.newAmount))
         {
            this.refreshCards();
         }
      }
      
      override protected function addEmptySlots(param1:Array) : void
      {
         var _loc2_:int = int(param1.length);
         while(_loc2_ < width)
         {
            param1.push(inviteNeighborToken());
            _loc2_++;
         }
      }
      
      override protected function removeUnfriendlyNeighbors(param1:Array) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Friend = null;
         var _loc6_:int = 0;
         var _loc7_:Player = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         for each(_loc4_ in param1)
         {
            _loc5_ = _loc4_ as Friend;
            if(_loc5_ as Friend)
            {
               _loc2_.push(_loc5_.uid);
            }
         }
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            _loc7_ = param1[_loc6_] is Boolean ? null : ZGlobal.player.findFriendById(param1[_loc6_].uid);
            if(_loc7_ == null && !(param1[_loc6_] is Boolean) && MatchMakingManager.instance.isMatchMadeNeighbor(param1[_loc6_].uid))
            {
               _loc6_++;
            }
            else if(!_loc7_ && param1[_loc6_].uid < 0)
            {
               _loc6_++;
            }
            else if(!_loc7_)
            {
               param1.splice(_loc6_,1);
            }
            else
            {
               _loc6_++;
            }
         }
         for each(_loc4_ in param1)
         {
            _loc5_ = _loc4_ as Friend;
            if(_loc5_ as Friend)
            {
               _loc3_.push(_loc5_.uid);
            }
         }
      }
      
      override protected function addLocalPlayerToNeighbors(param1:Array) : void
      {
         var _loc3_:Friend = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:Friend = null;
         for each(_loc2_ in param1)
         {
            if(_loc2_.uid == ZGlobal.player.uid)
            {
               return;
            }
         }
         _loc3_ = new Friend(ZGlobal.player.uid,ZGlobal.player.coins,ZGlobal.player.xp,ZGlobal.player.level,ZGlobal.player.socialXpGood,ZGlobal.player.socialLevelGood,ZGlobal.player.socialXpBad,ZGlobal.player.socialLevelBad,ZGlobal.player.rareResourceType,null,ZGlobal.player.name,DominationModeManager.instance.dominanceRank);
         _loc4_ = ZGlobal.player.xp;
         _loc5_ = 0;
         for each(_loc2_ in param1)
         {
            if(_loc4_ >= _loc2_.xp)
            {
               param1.splice(_loc5_,0,_loc3_);
               return;
            }
            _loc5_++;
         }
         param1.push(_loc3_);
      }
   }
}

