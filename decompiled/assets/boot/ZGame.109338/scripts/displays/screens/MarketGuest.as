package displays.screens
{
   import Engine.Managers.StatsManager;
   import ZLocalization.LocalizationObjectToken;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.AlliancesManager;
   import core.managers.MatchMakingManager;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.CommentSharePopup;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.battlebase.BattleBasePopup;
   import entity.GameDataComponent;
   import events.ResourceMarketEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MarketGuest extends Market
   {
      
      protected static const NUM_SLOTS_GUEST:int = 5;
      
      private var m_saleItems:Array = [];
      
      private var m_currentSaleItem:Object;
      
      private var m_marketPosition:String;
      
      private var m_requestCardImage:ImageLoader = null;
      
      private var m_selectBtn:ZGameButton = null;
      
      public function MarketGuest(param1:IEntity, param2:String = null, param3:String = null)
      {
         super("assets/displays/screens/Market.swf",param1,param2,true);
         var _loc4_:IEntity = param1;
         var _loc5_:GameDataComponent = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
         if(_loc5_)
         {
            this.m_marketPosition = _loc5_.userData.position;
         }
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("MarketBuy");
         var _loc3_:MovieClip = new _loc2_();
         m_marketWindow = _loc3_.marketWindow_mc;
         TextFieldUtil.processTextField(m_marketWindow.selectionDialog_mc.forSale_mc.inventoryTitle_tf,ZGameUtils.ZlocT("Dialogs","MarketGuestInventoryTitle",{"user":ZLoc.tn(ZGlobal.hostPlayer.firstName,ZGlobal.hostPlayer.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)}));
         TextFieldUtil.processTextField(m_marketWindow.selectionDialog_mc.cart_mc.sellingTitle_tf,ZGameUtils.ZlocT("Dialogs","MarketGuestCartTitle"));
         TextFieldUtil.processTextField(m_marketWindow.subtitle_tf,ZGameUtils.ZlocT("Dialogs","MarketGuestInstructions",{"user":ZLoc.tn("",ZGlobal.hostPlayer.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)}));
         super.onLoadComplete(param1);
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            this.addRequestCard_MatchMaking();
         }
         else
         {
            this.addRequestCard();
         }
      }
      
      public function addRequestCard_MatchMaking() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = m_marketWindow.selectionDialog_mc.forSale_mc.requestCard_mc;
         _loc1_.visible = true;
         _loc1_.highlightSelect.visible = false;
         TextFieldUtil.compactTextField(_loc1_.itemName_tf,ZGameUtils.ZlocT("Dialogs","MarketRequestCardTitle"));
         TextFieldUtil.compactTextField(_loc1_.text_tf,ZGameUtils.ZlocT("Dialogs","MM_MarketRequestCardMessage"));
         _loc1_.itemName_tf.mouseEnabled = false;
         _loc1_.text_tf.mouseEnabled = false;
         _loc1_.buttonMode = true;
         _loc1_.useHandCursor = true;
         var _loc2_:String = ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/RequestMarketItem_96.png");
         this.m_requestCardImage = ImageLoaderFactory.CreateImageLoader(_loc2_,_loc1_.icon);
         if(_loc1_.select_bt)
         {
            if(MatchMakingManager.IsAddFBButtonExpON())
            {
               this.m_selectBtn = new ZGameButton(_loc1_.select_bt,this.onAddFriend);
               this.m_selectBtn.text = ZGameUtils.ZlocT("Dialogs","MM_AddFBFriendButton");
               _loc1_.addEventListener(MouseEvent.CLICK,this.onAddFriend,false,0,true);
            }
            else
            {
               this.m_selectBtn = new ZGameButton(_loc1_.select_bt,close);
               this.m_selectBtn.text = ZGameUtils.ZlocT("Dialogs","Okay");
               _loc1_.addEventListener(MouseEvent.CLICK,this.onOkay,false,0,true);
            }
            this.m_selectBtn.enable();
         }
         m_buttonSounds.addButton(_loc1_,ButtonSound.DEFAULT);
         _loc1_.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverRequestCard,false,0,true);
         _loc1_.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutRequestCard,false,0,true);
      }
      
      protected function onAddFriend(param1:MouseEvent) : void
      {
         StatsManager.count("Matchingmaking","add_as_fb_friend","market");
         ViralsManager.instance.sendAddFriend("market_ask_for_item",{},ZGlobal.hostPlayer.uid);
         this.onCloseClick(null);
      }
      
      protected function onOkay(param1:MouseEvent) : void
      {
         this.onCloseClick(null);
      }
      
      override protected function updateCurrentCardsAfterAddRemoveActions() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < m_tiles.length)
         {
            _loc2_ = m_tileSet * this.getNumSlots() + _loc1_;
            if(_loc2_ < m_data.length)
            {
               _loc3_ = this.m_saleItems[m_data[_loc2_].saleItemIndex];
               TextFieldUtil.processTextField(m_tiles[_loc1_].itemCard_mc.units_tf,_loc3_.units);
               if(m_buildButtons[_loc1_] != null)
               {
                  if(_loc3_.units > 0)
                  {
                     m_buildButtons[_loc1_].enable();
                  }
                  else
                  {
                     m_buildButtons[_loc1_].disable_visual();
                  }
               }
            }
            _loc1_++;
         }
      }
      
      override protected function loadCards(param1:int) : void
      {
         m_data = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.m_saleItems.length)
         {
            if(Boolean(this.m_saleItems[_loc2_] && this.m_saleItems[_loc2_].length != 0) && Boolean(this.m_saleItems[_loc2_].units > 0) || Boolean(m_proposedSale) && Boolean(m_proposedSale.item == this.m_saleItems[_loc2_].item))
            {
               m_data.push({
                  "type":this.m_saleItems[_loc2_].type,
                  "item":this.m_saleItems[_loc2_].item,
                  "price":getMarketPrice(this.m_saleItems[_loc2_]),
                  "units":this.m_saleItems[_loc2_].units,
                  "id":this.m_saleItems[_loc2_].id,
                  "saleItemIndex":_loc2_
               });
            }
            _loc2_++;
         }
         if(m_data.length == 0)
         {
            this.displayMarketEmpty();
         }
         if(m_data.length <= param1 * this.getNumSlots())
         {
            param1--;
            m_tileSet = Math.max(0,param1);
         }
         removeTiles();
         addAllComponents(m_tileSet * this.getNumSlots());
         fixArrows();
      }
      
      override public function onList(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(!m_marketWindow)
         {
            m_serverData = param1;
            return;
         }
         this.m_saleItems = new Array();
         if(Boolean(param1) && param1.length != 0)
         {
            m_marketWindow.status_tf.visible = false;
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               this.m_saleItems[_loc2_] = param1[_loc2_];
               _loc2_++;
            }
            this.loadCards(0);
         }
         else
         {
            hideListing();
            this.displayMarketEmpty();
         }
      }
      
      private function displayMarketEmpty() : void
      {
         TextFieldUtil.processTextField(m_marketWindow.status_tf,ZGameUtils.ZlocT("Dialogs","MarketGuestEmptyMarketMessage"));
         m_marketWindow.status_tf.visible = true;
      }
      
      override protected function addComponent(param1:int, param2:int = 0) : void
      {
         var _loc3_:Object = null;
         var _loc4_:ImageLoader = null;
         if(Boolean(m_tiles) && Boolean(m_tiles[param1]) && m_data.length > param1 + param2)
         {
            m_tiles[param1].visible = true;
            m_tiles[param1].itemCard_mc.highlightSelect.visible = false;
            m_tiles[param1].itemCard_mc.itemName_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.cost_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.units_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.buttonMode = true;
            m_tiles[param1].itemCard_mc.useHandCursor = true;
            m_buttonSounds.addButton(m_tiles[param1].itemCard_mc,ButtonSound.DEFAULT);
            m_tiles[param1].itemCard_mc.addEventListener(MouseEvent.ROLL_OVER,onRollOver,false,0,true);
            m_tiles[param1].itemCard_mc.addEventListener(MouseEvent.ROLL_OUT,onRollOut,false,0,true);
            _loc3_ = {
               "type":m_data[param2 + param1].type,
               "units":m_data[param2 + param1].units,
               "item":m_data[param2 + param1].item
            };
            _loc4_ = populateCard(_loc3_,m_tiles[param1].itemCard_mc);
            if(_loc4_ != null)
            {
               m_iconLoaders.push(_loc4_);
            }
         }
         else if(Boolean(m_tiles) && Boolean(m_tiles[param1]))
         {
            m_tiles[param1].visible = false;
         }
      }
      
      private function addRequestCard() : void
      {
         var _loc1_:MovieClip = m_marketWindow.selectionDialog_mc.forSale_mc.requestCard_mc;
         _loc1_.visible = true;
         _loc1_.highlightSelect.visible = false;
         TextFieldUtil.processTextField(_loc1_.itemName_tf,ZGameUtils.ZlocT("Dialogs","MarketRequestCardTitle"));
         TextFieldUtil.processTextField(_loc1_.text_tf,ZGameUtils.ZlocT("Dialogs","MarketRequestCardMessage"));
         _loc1_.itemName_tf.mouseEnabled = false;
         _loc1_.text_tf.mouseEnabled = false;
         _loc1_.buttonMode = true;
         _loc1_.useHandCursor = true;
         var _loc2_:String = ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/RequestMarketItem_96.png");
         this.m_requestCardImage = ImageLoaderFactory.CreateImageLoader(_loc2_,_loc1_.icon);
         if(_loc1_.select_bt)
         {
            this.m_selectBtn = new ZGameButton(_loc1_.select_bt,this.onRequest);
            this.m_selectBtn.text = ZGameUtils.ZlocT("Dialogs","MarketRequestButton");
            _loc1_.addEventListener(MouseEvent.CLICK,this.onRequest,false,0,true);
            this.m_selectBtn.enable();
         }
         m_buttonSounds.addButton(_loc1_,ButtonSound.DEFAULT);
         _loc1_.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverRequestCard,false,0,true);
         _loc1_.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutRequestCard,false,0,true);
      }
      
      protected function onRollOverRequestCard(param1:MouseEvent) : void
      {
         param1.target.highlightSelect.visible = true;
      }
      
      protected function onRollOutRequestCard(param1:MouseEvent) : void
      {
         param1.target.highlightSelect.visible = false;
      }
      
      protected function onRequest(param1:MouseEvent) : void
      {
         var _loc2_:Object = {"user":ZLoc.tn(ZGlobal.hostPlayer.firstName,ZGlobal.hostPlayer.genderTag)};
         var _loc3_:CommentSharePopup = new CommentSharePopup(ZGameUtils.ZlocT("FeedPopups","market_request_item_for_sale_message",_loc2_),ZGameUtils.ZlocT("FeedPopups","market_request_item_for_sale_title"),ZGameUtils.ZlocT("Dialogs","AskFriend"),ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/RequestMarketItem_96.png"),FeedPopup.LARGE_IMAGE,this.onRequestForSalePopupClosed);
         PopupManager.instance.push(_loc3_);
      }
      
      private function onRequestForSalePopupClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == BattleBasePopup.AUTOSHARE_COMMENT)
         {
            _loc2_ = null;
            if(Boolean(param1.userData) && param1.userData.comment != null)
            {
               _loc2_ = param1.userData.comment as String;
            }
            ViralsManager.instance.sendFeedWithComment("market_ask_for_item",{},_loc2_,ZGlobal.hostPlayer.uid);
         }
      }
      
      private function getSaleItem(param1:int) : Object
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_saleItems.length)
         {
            if(this.m_saleItems[_loc2_].id == param1)
            {
               return this.m_saleItems[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      override protected function onAdd(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject) + m_tileSet * this.getNumSlots();
         var _loc3_:int = int(m_data[_loc2_].id);
         if(m_proposedSale)
         {
            if(m_proposedSale.item != m_data[_loc2_].item)
            {
               this.m_currentSaleItem.units += m_proposedSale.units;
               m_proposedSale = null;
            }
            else
            {
               this.incrementAmount();
            }
         }
         if(m_proposedSale == null)
         {
            _loc4_ = this.getSaleItem(_loc3_);
            this.m_currentSaleItem = _loc4_;
            m_proposedSale = new Object();
            m_proposedSale.type = m_data[_loc2_].type;
            m_proposedSale.price = m_data[_loc2_].price;
            if(m_data[_loc2_].type == TYPE_RESOURCE)
            {
               this.m_currentSaleItem.units -= RESOURCE_INCREMENT;
               m_proposedSale.item = m_data[_loc2_].item;
               m_proposedSale.units = RESOURCE_INCREMENT;
            }
            else if(m_data[_loc2_].type == TYPE_BUILDABLE)
            {
               this.m_currentSaleItem.units -= BUILDABLE_INCREMENT;
               m_proposedSale.item = m_data[_loc2_].item;
               m_proposedSale.units = BUILDABLE_INCREMENT;
            }
         }
         doPostAddRemoveActions();
      }
      
      override protected function onKeypadUpdate() : void
      {
         if(m_proposedSale)
         {
            if(m_keypad.value <= this.m_currentSaleItem.units + m_proposedSale.units)
            {
               this.m_currentSaleItem.units = this.m_currentSaleItem.units + m_proposedSale.units - m_keypad.value;
               m_proposedSale.units = m_keypad.value;
            }
            else
            {
               m_keypad.value = m_proposedSaleQuantity;
            }
            doPostAddRemoveActions();
         }
      }
      
      override protected function onAddAll(param1:MouseEvent) : void
      {
         if(m_proposedSale)
         {
            m_proposedSale.units += this.m_currentSaleItem.units;
            this.m_currentSaleItem.units = 0;
            doPostAddRemoveActions();
         }
      }
      
      protected function incrementAmount() : void
      {
         if(Boolean(m_proposedSale) && this.m_currentSaleItem.units >= RESOURCE_INCREMENT)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               this.m_currentSaleItem.units -= RESOURCE_INCREMENT;
               m_proposedSale.units += RESOURCE_INCREMENT;
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               this.m_currentSaleItem.units -= BUILDABLE_INCREMENT;
               m_proposedSale.units += BUILDABLE_INCREMENT;
            }
         }
      }
      
      override protected function onRemove(param1:MouseEvent) : void
      {
         if(m_proposedSale)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               this.m_currentSaleItem.units += m_proposedSale.units;
               m_proposedSale.units = 0;
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               this.m_currentSaleItem.units += m_proposedSale.units;
               m_proposedSale.units = 0;
            }
            if(m_proposedSale.units <= 0)
            {
               m_proposedSale = null;
            }
            doPostAddRemoveActions();
         }
      }
      
      override protected function onConfirm(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:BitArray = null;
         if(Boolean(m_proposedSale) && m_proposedSale.units > 0)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               if(!ZGlobal.player.resources.checkResourceAmount("coins",-(WorldResourceManager.instance.resourceInfo[m_proposedSale.item].marketPrice * m_proposedSale.units)))
               {
                  PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","MarkeNotEnoughCoinsMessage")));
                  return;
               }
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(m_proposedSale.item,GameItem) as GameItem;
               if(ZGlobal.gameSettings.getNumber("gateMarketPurchase",0) != 0)
               {
                  _loc3_ = ZGlobal.player.checkGate(_loc2_);
                  if(_loc3_.anyBitSet())
                  {
                     PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","MarketLevelFailMessage")));
                     return;
                  }
               }
               if(!ZGlobal.player.resources.checkResourceAmount("coins",-(_loc2_.marketPrice * m_proposedSale.units)))
               {
                  PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","MarkeNotEnoughCoinsMessage")));
                  return;
               }
            }
            UIDispatcher.instance.dispatchEvent(new ResourceMarketEvent(ResourceMarketEvent.BUY,m_proposedSale,this,this.m_currentSaleItem.id));
            QuestManager.getInstance().dispatchEvent(new WorldEvent(ResourceMarketEvent.BUY,{
               "type":"market",
               "data":m_proposedSale
            }));
            disableTransactionButtons();
         }
         else
         {
            this.onCloseClick(param1);
         }
      }
      
      public function onBuySuccess() : void
      {
         var _loc3_:String = null;
         var _loc5_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:GameItem = null;
         var _loc12_:String = null;
         var _loc13_:LocalizationObjectToken = null;
         var _loc1_:String = "FeedPopups";
         var _loc2_:String = "";
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            _loc1_ = "Dialogs";
            _loc2_ = "MM_";
         }
         var _loc4_:Object = null;
         if(m_proposedSale.type == TYPE_RESOURCE)
         {
            _loc8_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
            ZGlobal.player.resources.updateResourceAmount(_loc8_,m_proposedSale.units);
            _loc3_ = WorldResourceManager.instance.getResourceImageURL(m_proposedSale.item,WorldResourceManager.XTRA_LARGE_ICON);
            _loc9_ = m_proposedSale.units > 1 ? "plural" : "singular";
            _loc4_ = {
               "count":m_proposedSale.units,
               "item":ZGameUtils.ZlocTk("Items",_loc8_ + "_sentenceName",_loc9_),
               "user":ZGlobal.hostPlayer.snUser.firstName
            };
            _loc5_ = ZGameUtils.ZlocT(_loc1_,_loc2_ + "market_buy_complete_object",_loc4_);
         }
         else if(m_proposedSale.type == TYPE_BUILDABLE)
         {
            _loc10_ = 0;
            while(_loc10_ < m_proposedSale.units)
            {
               ZGlobal.player.addToInventory(m_proposedSale.item);
               _loc10_++;
            }
            _loc11_ = ZGlobal.gameSettings.getItemByCode(m_proposedSale.item,GameItem) as GameItem;
            _loc3_ = ZGlobal.gameSettings.getImageByName(_loc11_.name,"icon");
            _loc12_ = m_proposedSale.units > 1 ? "plural" : "singular";
            _loc13_ = _loc11_.getSentenceNameLocalizationObject(_loc12_,true);
            if(_loc13_)
            {
               _loc4_ = {
                  "count":m_proposedSale.units,
                  "item":_loc13_,
                  "user":ZGlobal.hostPlayer.snUser.firstName
               };
               _loc5_ = ZGameUtils.ZlocT(_loc1_,_loc2_ + "market_buy_complete_object",_loc4_);
            }
            else
            {
               _loc4_ = {
                  "count":m_proposedSale.units,
                  "item":_loc11_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                  "unit":ZGameUtils.ZlocTk("Objects","unit","",m_proposedSale.units),
                  "user":ZGlobal.hostPlayer.snUser.firstName
               };
               _loc5_ = ZGameUtils.ZlocT(_loc1_,_loc2_ + "market_buy_complete",_loc4_);
            }
         }
         ZGlobal.player.coins -= m_proposedSale.price * m_proposedSale.units;
         UIDispatcher.instance.dispatchEvent(new ResourceMarketEvent(ResourceMarketEvent.ITEM,this.m_currentSaleItem,this,this.m_currentSaleItem.id));
         this.onCloseClick(null);
         var _loc6_:String = "feed_share_bttn";
         var _loc7_:String = "FeedPopups";
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            _loc7_ = "Dialogs";
            _loc6_ = MatchMakingManager.IsAddFBButtonExpON() ? "MM_AddFBFriendButton" : "Okay";
         }
         else if(Boolean(AlliancesManager.instance.isAllianceMember(ZGlobal.hostPlayer.uid)) && !ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid])
         {
            _loc7_ = "Dialogs";
            _loc6_ = "Okay";
         }
         PopupManager.instance.push(new FeedPopup(_loc5_,ZGameUtils.ZlocT("FeedPopups","market_buy_complete_title"),ZGameUtils.ZlocT(_loc7_,_loc6_),GenericPopup.TYPE_SHARECANCEL,this.onBuyCompletePopupClosed,_loc3_));
      }
      
      public function onBuyFail(param1:int) : void
      {
         this.onCloseClick(null);
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","MarketBuyFailMessage")));
      }
      
      private function onBuyCompletePopupClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button != GenericPopup.ACCEPT)
         {
            return;
         }
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            if(MatchMakingManager.IsAddFBButtonExpON())
            {
               MatchMakingManager.ShowFBFriendRequestDialog(ZGlobal.hostPlayer.uid);
            }
         }
         else
         {
            if(Boolean(AlliancesManager.instance.isAllianceMember(ZGlobal.hostPlayer.uid)) && !ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid])
            {
               return;
            }
            ViralsManager.instance.sendFeed("market_buy_complete",{},ZGlobal.hostPlayer.uid);
         }
      }
      
      override protected function onCloseClick(param1:MouseEvent) : void
      {
         removeTiles();
         m_proposedSale = null;
         this.m_saleItems = null;
         super.onCloseClick(param1);
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS_GUEST;
      }
   }
}

