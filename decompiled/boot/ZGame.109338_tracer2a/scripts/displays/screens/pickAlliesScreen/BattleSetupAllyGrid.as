package displays.screens.pickAlliesScreen
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.prebattle.IPreBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.MercenaryItem;
   import core.managers.PVPManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Friend;
   import core.player.IAlly;
   import core.player.Player;
   import core.ui.menuitem.FriendsBarUIItem;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import transactions.TBuyItem;
   import utils.BitArray;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class BattleSetupAllyGrid extends PlayerGrid
   {
      
      public static const ALLY_SELECTED:String = "allySelected";
      
      private var m_selectionLock:String = null;
      
      private var m_forcedAllies:Array = null;
      
      private var m_preBattle:IPreBattle;
      
      public function BattleSetupAllyGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:Array, param5:int, param6:IPreBattle, param7:Array = null)
      {
         this.m_preBattle = param6;
         this.m_forcedAllies = param7;
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(4,1);
         load(param1,param2);
         buttonSounds.addButton(screen.arrowRtSingle_bt,ButtonSound.DEFAULT);
         buttonSounds.addButton(screen.arrowLtSingle_bt,ButtonSound.DEFAULT);
      }
      
      override public function dispose() : void
      {
         this.stopListening();
         this.m_selectionLock = null;
         super.dispose();
      }
      
      public function startListening() : void
      {
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         UIDispatcher.instance.addEventListener(GridSlot.PURCHASE,this.onSlotPurchase,false,0,true);
         screen.arrowRtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleRightClick,false,0,true);
         screen.arrowLtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleLeftClick,false,0,true);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.addEventListener(TutorialManager.LIMIT_ALLY_SELECTION,this.onLimitAllySelection,false,0,true);
         }
      }
      
      public function stopListening() : void
      {
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onSlotSelected);
         UIDispatcher.instance.removeEventListener(GridSlot.PURCHASE,this.onSlotPurchase);
         screen.arrowRtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleRightClick);
         screen.arrowLtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleLeftClick);
         TutorialManager.instance.addEventListener(TutorialManager.LIMIT_ALLY_SELECTION,this.onLimitAllySelection);
      }
      
      public function removeAlly(param1:IAlly) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < m_selections.length)
         {
            if(m_selections[_loc2_] == param1)
            {
               m_selections.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         this.updateCardSelectedStatus();
      }
      
      override protected function enableLeftButtons(param1:Boolean) : void
      {
         super.enableLeftButtons(param1);
         ZGameUtils.setButtonEnabled(m_screen.arrowLtSingle_bt,this.onSingleLeftClick,param1);
      }
      
      override protected function enableRightButtons(param1:Boolean) : void
      {
         super.enableRightButtons(param1);
         ZGameUtils.setButtonEnabled(m_screen.arrowRtSingle_bt,this.onSingleRightClick,param1);
      }
      
      override protected function allowDefaultAllyAsNeighbor() : Boolean
      {
         return true;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function createItemList() : void
      {
         var mercenaryItems:Array;
         var mercenary:XML = null;
         var sorter:Function = null;
         var i:int = 0;
         var friend:Friend = null;
         var player:Player = null;
         var merc:MercenaryItem = null;
         var mercCode:String = null;
         var mercenaryItem:MercenaryItem = null;
         var gate:BitArray = null;
         if(this.hasForcedAllies())
         {
            i = 0;
            while(i < this.m_forcedAllies.length)
            {
               friend = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).findNeighborById(this.m_forcedAllies[i]);
               player = ZGlobal.player.findFriendById(this.m_forcedAllies[i]);
               if(Boolean(friend) && Boolean(player))
               {
                  m_players.push(friend);
               }
               else
               {
                  merc = ZGlobal.gameSettings.getItemByCode(this.m_forcedAllies[i],MercenaryItem) as MercenaryItem;
                  if(merc)
                  {
                     m_players.push(merc);
                  }
               }
               i++;
            }
            return;
         }
         super.createItemList();
         mercenaryItems = ZGlobal.gameSettings.getArrayOfItemXMLByType(GameItem.TYPE_MERCENARY);
         for each(mercenary in mercenaryItems)
         {
            mercCode = mercenary.@code;
            if(ZGlobal.player.getNumberOfInventoryItems(mercCode) == 0)
            {
               mercenaryItem = ZGlobal.gameSettings.getItemByCode(mercCode,MercenaryItem) as MercenaryItem;
               gate = ZGlobal.player.checkGate(mercenaryItem);
               if(!gate.anyBitSet())
               {
                  m_players.push(mercenaryItem);
               }
            }
         }
         sorter = function(param1:IAlly, param2:IAlly):Number
         {
            if(Boolean(m_selectionLock) && m_selectionLock == param1.id)
            {
               return -1;
            }
            if(Boolean(m_selectionLock) && m_selectionLock == param2.id)
            {
               return 1;
            }
            var _loc3_:Boolean = ZGlobal.player.allies.isAllyValidForConsumable(param1.id);
            var _loc4_:Boolean = ZGlobal.player.allies.isAllyValidForConsumable(param2.id);
            if(_loc3_ && !_loc4_)
            {
               return -1;
            }
            if(_loc4_ && !_loc3_)
            {
               return 1;
            }
            if(param1.level > param2.level)
            {
               return -1;
            }
            if(param1.level < param2.level)
            {
               return 1;
            }
            if(param1.firstName < param2.firstName)
            {
               return -1;
            }
            if(param1.firstName > param2.firstName)
            {
               return 1;
            }
            return 0;
         };
         m_players.sort(sorter);
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function resetAnchorPosition() : void
      {
         setAnchor(screen.fixedAnchor_mc.x,screen.fixedAnchor_mc.y);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc8_:MercenarySlotV2 = null;
         var _loc9_:IAlly = null;
         var _loc10_:PlayerSlotV2 = null;
         var _loc6_:Boolean = false;
         if(this.hasForcedAllies())
         {
            _loc6_ = true;
         }
         var _loc7_:MercenaryItem = m_players[param5] as MercenaryItem;
         if((Boolean(_loc7_)) && ZGlobal.player.getNumberOfInventoryItems(_loc7_.code) == 0)
         {
            _loc8_ = new MercenarySlotV2(param1,param2,screen,param3,param4,_loc7_,this.getMultFactor());
            if(TutorialManager.instance.isLocked(_loc7_.code))
            {
               _loc8_.disable();
            }
            return _loc8_;
         }
         _loc9_ = m_players[param5];
         _loc10_ = new PlayerSlotV2(param1,param2,screen,param3,param4,_loc9_,isAllySelected(_loc9_),this.getMultFactor(),_loc6_);
         if(TutorialManager.instance.isLocked(_loc9_.id))
         {
            _loc10_.disable();
         }
         return _loc10_;
      }
      
      override protected function fillOutHeader() : void
      {
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         var _loc2_:GridSlot = null;
         var _loc3_:IAlly = null;
         if(m_selections.length < m_maxSelections)
         {
            _loc2_ = GridSlot(param1.eventData);
            _loc3_ = IAlly(_loc2_.getData());
            _loc2_.select();
            m_selections.push(_loc3_);
            m_eventDispatcher.dispatchEvent(new WorldEvent(ALLY_SELECTED));
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","TooManyAlliesMessage"),GenericPopup.TYPE_OK));
         }
      }
      
      protected function onSlotPurchase(param1:WorldEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:GenericPopup = null;
         var _loc2_:GridSlot = GridSlot(param1.eventData);
         var _loc3_:IAlly = IAlly(_loc2_.getData());
         if(ZGlobal.player.inventory[_loc3_.id] >= 1)
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","DuplicateMercenaryMessage",{"merc":_loc3_.firstName}),GenericPopup.TYPE_OK));
            return;
         }
         if(m_selections.length < m_maxSelections)
         {
            _loc4_ = MercenaryItem(_loc3_).cash;
            if(ZGlobal.player.canBuyCash(_loc4_,true))
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc4_))
               {
                  _loc5_ = ZGameUtils.CashTokenReplacements(_loc4_);
                  _loc5_.merc = ZLoc.tn(_loc3_.firstName,_loc3_.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC);
                  _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmMercenaryPurchaseMessage",_loc5_);
                  _loc7_ = GenericPopup2B.NewYesNo(_loc6_,null,this.onMercenaryPopupClose);
                  _loc7_.userData = _loc3_;
                  PopupManager.instance.push(_loc7_);
               }
               else
               {
                  this.purchasePendingMercenary(_loc3_);
               }
            }
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","TooManyAlliesMessage"),GenericPopup.TYPE_OK));
         }
      }
      
      private function onSingleRightClick(param1:MouseEvent) : void
      {
         slide(-1);
      }
      
      private function onSingleLeftClick(param1:MouseEvent) : void
      {
         slide(1);
      }
      
      private function purchasePendingMercenary(param1:IAlly) : void
      {
         this.buyMercenary(param1);
         this.updatePlayersList();
      }
      
      private function onMercenaryPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.OK)
         {
            this.purchasePendingMercenary(param1.userData as IAlly);
         }
      }
      
      private function buyMercenary(param1:IAlly) : void
      {
         var _loc2_:Boolean = true;
         ZGlobal.player.buyItem(GameItem(param1),_loc2_);
         ZGlobal.player.addToInventory(param1.id);
         var _loc3_:Boolean = this.m_preBattle.fleet.hasStatus(Fleet.QUESTTREE);
         var _loc4_:Object = {
            "gpvp":PVPManager.instance.isVisitGlobalPVP,
            "questTree":_loc3_
         };
         TransactionManager.addTransaction(new TBuyItem(param1.id,_loc2_,1,_loc4_),true);
         m_selections.push(param1);
         m_eventDispatcher.dispatchEvent(new WorldEvent(ALLY_SELECTED));
      }
      
      private function rebuildPlayersList() : void
      {
         m_players = new Array();
         this.createItemList();
         disposeCards();
         createCards(m_resource);
      }
      
      private function updatePlayersList() : void
      {
         var _loc3_:int = 0;
         var _loc4_:MercenarySlotV2 = null;
         var _loc5_:MercenaryItem = null;
         var _loc6_:IAlly = null;
         var _loc7_:GridSlot = null;
         var _loc1_:Boolean = false;
         var _loc2_:int = int(m_players.length);
         m_players = new Array();
         this.createItemList();
         if(_loc2_ != m_players.length)
         {
            _loc1_ = true;
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < m_players.length)
            {
               _loc4_ = m_cards[_loc3_] as MercenarySlotV2;
               _loc5_ = m_players[_loc3_] as MercenaryItem;
               if((Boolean(_loc5_)) && ZGlobal.player.getNumberOfInventoryItems(_loc5_.code) == 0)
               {
                  if(Boolean(_loc4_) && _loc4_.getData().code != _loc5_.code)
                  {
                     _loc1_ = true;
                     break;
                  }
               }
               else
               {
                  _loc6_ = m_players[_loc3_];
                  if(_loc4_)
                  {
                     _loc7_ = new PlayerSlotV2(m_resource,_loc4_.parent,screen,_loc4_.xIndex,_loc4_.yIndex,_loc6_,isAllySelected(_loc6_),this.getMultFactor());
                     _loc4_.dispose();
                     _loc4_ = null;
                     m_cards[_loc3_] = _loc7_;
                  }
               }
               _loc3_++;
            }
         }
         if(_loc1_)
         {
            this.rebuildPlayersList();
         }
      }
      
      private function updateCardSelectedStatus() : void
      {
         var _loc2_:PlayerSlotV2 = null;
         var _loc1_:int = 0;
         while(_loc1_ < m_cards.length)
         {
            _loc2_ = m_cards[_loc1_] as PlayerSlotV2;
            if(_loc2_)
            {
               if(isAllySelected(_loc2_.getData() as IAlly))
               {
                  _loc2_.select();
               }
               else
               {
                  _loc2_.deselect();
               }
            }
            _loc1_++;
         }
      }
      
      private function onLimitAllySelection(param1:WorldEvent) : void
      {
         m_disableRtButton = true;
         this.m_selectionLock = String(param1.eventData);
         this.rebuildPlayersList();
      }
      
      private function hasForcedAllies() : Boolean
      {
         return Boolean(this.m_forcedAllies) && this.m_forcedAllies.length > 0;
      }
      
      public function get players() : Array
      {
         return m_players;
      }
   }
}

