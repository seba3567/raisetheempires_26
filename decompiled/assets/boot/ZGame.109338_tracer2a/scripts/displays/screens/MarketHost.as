package displays.screens
{
   import ZLocalization.LocalizationObjectToken;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.InventoryList;
   import core.managers.WorldResourceManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.resource.ResourceInfo;
   import dispatchers.MessageDispatcher;
   import displays.ImageLoader;
   import displays.popups.CommentSharePopup;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.battlebase.BattleBasePopup;
   import events.ResourceMarketEvent;
   import events.ResourceUpdatedEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MarketHost extends Market
   {
      
      private var m_marketPosition:String;
      
      public function MarketHost(param1:IEntity, param2:String = null, param3:String = null)
      {
         super("assets/displays/screens/Market.swf",param1,param2,false);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("MarketSell");
         var _loc3_:MovieClip = new _loc2_();
         m_marketWindow = _loc3_.marketWindow_mc;
         TextFieldUtil.processTextField(m_marketWindow.selectionDialog_mc.forSale_mc.inventoryTitle_tf,ZGameUtils.ZlocT("Dialogs","MarketHostInventoryTitle"));
         TextFieldUtil.processTextField(m_marketWindow.selectionDialog_mc.cart_mc.sellingTitle_tf,ZGameUtils.ZlocT("Dialogs","MarketHostForSaleTitle"));
         TextFieldUtil.processTextField(m_marketWindow.subtitle_tf,ZGameUtils.ZlocT("Dialogs","MarketHostInstructions"));
         m_worldResourceAmounts = this.copyDictionary(ZGlobal.player.resources.resourceAmounts);
         m_playerInventory = this.copyDictionary(ZGlobal.player.inventory);
         m_availableWorldUnits = this.copyDictionary(WorldUnitManager.instance.availableUnits);
         m_unavailableWorldUnits = WorldUnitManager.instance.getUnavailableUnits(WorldUnitManager.UNIT_IN_MARKET);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.RESOURCE_DIALOG_UPDATE,this.onMarketUpdate,false,0,true);
         super.onLoadComplete(param1);
      }
      
      override protected function isMarketHost() : Boolean
      {
         return true;
      }
      
      override public function onList(param1:Object) : void
      {
         if(!m_marketWindow)
         {
            m_serverData = param1;
            return;
         }
         super.onList(param1);
      }
      
      override protected function addComponent(param1:int, param2:int = 0) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:ImageLoader = null;
         var _loc7_:int = 0;
         var _loc8_:ResourceInfo = null;
         if(Boolean(m_tiles) && Boolean(m_tiles[param1]) && m_data.length > param1 + param2)
         {
            m_tiles[param1].visible = true;
            m_tiles[param1].itemCard_mc.highlightSelect.visible = false;
            m_tiles[param1].itemCard_mc.itemName_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.cost_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.units_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.buttonMode = true;
            m_tiles[param1].itemCard_mc.useHandCursor = true;
            m_tiles[param1].itemCard_mc.addEventListener(MouseEvent.ROLL_OVER,onRollOver,false,0,true);
            m_tiles[param1].itemCard_mc.addEventListener(MouseEvent.ROLL_OUT,onRollOut,false,0,true);
            m_buttonSounds.addButton(m_tiles[param1].itemCard_mc.select_bt,ButtonSound.DEFAULT);
            _loc5_ = m_data[param2 + param1].type;
            if(_loc5_ == TYPE_RESOURCE)
            {
               _loc7_ = int(m_data[param2 + param1].item);
               _loc8_ = WorldResourceManager.instance.resourceInfo[m_data[param2 + param1].item];
               _loc4_ = {
                  "type":TYPE_RESOURCE,
                  "units":int(m_worldResourceAmounts[_loc8_.type]),
                  "item":m_data[param2 + param1].item
               };
            }
            else if(_loc5_ == TYPE_BUILDABLE)
            {
               _loc4_ = {
                  "type":TYPE_BUILDABLE,
                  "units":this.numAvailableItems(m_data[param2 + param1].item),
                  "item":m_data[param2 + param1].item
               };
            }
            _loc6_ = populateCard(_loc4_,m_tiles[param1].itemCard_mc);
            if(_loc6_ != null)
            {
               m_iconLoaders.push(_loc6_);
            }
            m_tiles[param1].data = _loc4_;
         }
         else if(Boolean(m_tiles) && Boolean(m_tiles[param1]))
         {
            m_tiles[param1].visible = false;
         }
      }
      
      override protected function updateCurrentCardsAfterAddRemoveActions() : void
      {
         var _loc2_:String = null;
         var _loc1_:int = 0;
         while(_loc1_ < m_tiles.length)
         {
            if(m_tiles[_loc1_].data)
            {
               if(m_tiles[_loc1_].data.type == TYPE_RESOURCE)
               {
                  _loc2_ = _loc2_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_tiles[_loc1_].data.item);
                  m_tiles[_loc1_].data.units = m_worldResourceAmounts[_loc2_];
                  TextFieldUtil.processTextField(m_tiles[_loc1_].itemCard_mc.units_tf,m_worldResourceAmounts[_loc2_]);
               }
               else if(m_tiles[_loc1_].data.type == TYPE_BUILDABLE)
               {
                  m_tiles[_loc1_].data.units = this.numAvailableItems(m_tiles[_loc1_].data.item);
                  TextFieldUtil.processTextField(m_tiles[_loc1_].itemCard_mc.units_tf,m_tiles[_loc1_].data.units);
               }
               if(m_buildButtons[_loc1_] != null)
               {
                  if(m_tiles[_loc1_].data.units > 0)
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
         var _loc5_:ResourceInfo = null;
         var _loc6_:String = null;
         var _loc7_:GameItem = null;
         m_data = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < WorldResourceManager.instance.resourceInfo.length)
         {
            _loc5_ = WorldResourceManager.instance.resourceInfo[_loc2_];
            if(m_worldResourceAmounts[_loc5_.type] >= RESOURCE_INCREMENT && _loc5_.type != "coins" && _loc5_.type != "energy" || Boolean(m_proposedSale) && Boolean(m_proposedSale.item == _loc2_))
            {
               m_data.push({
                  "type":TYPE_RESOURCE,
                  "item":_loc2_
               });
            }
            _loc2_++;
         }
         var _loc3_:Array = InventoryList.instance.itemsByEffectiveness;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc4_];
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_,GameItem) as GameItem;
            if(this.shouldShowItem(_loc7_))
            {
               if(this.numAvailableItems(_loc6_) >= BUILDABLE_INCREMENT || Boolean(m_proposedSale) && Boolean(m_proposedSale.item == _loc6_))
               {
                  m_data.push({
                     "type":TYPE_BUILDABLE,
                     "item":_loc6_
                  });
               }
            }
            _loc4_++;
         }
         if(m_data.length <= param1 * NUM_SLOTS)
         {
            param1--;
            m_tileSet = Math.max(0,param1);
         }
         removeTiles();
         addAllComponents(m_tileSet * NUM_SLOTS);
         fixArrows();
      }
      
      override protected function onAdd(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(!m_confirmBtn.enabled)
         {
            return;
         }
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject) + m_tileSet * NUM_SLOTS;
         if(m_proposedSale)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               if(m_proposedSale.item != m_data[_loc2_].item)
               {
                  _loc3_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
                  m_worldResourceAmounts[_loc3_] += m_proposedSale.units;
                  m_proposedSale = null;
               }
               else
               {
                  this.incrementAmount();
               }
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               if(m_proposedSale.item != m_data[_loc2_].item)
               {
                  _loc4_ = 0;
                  while(_loc4_ < m_proposedSale.units)
                  {
                     this.returnInventoryItem(m_proposedSale.item);
                     _loc4_++;
                  }
                  m_proposedSale = null;
               }
               else
               {
                  this.incrementAmount();
               }
            }
         }
         if(m_proposedSale == null)
         {
            m_proposedSale = new Object();
            m_proposedSale.type = m_data[_loc2_].type;
            if(m_data[_loc2_].type == TYPE_RESOURCE)
            {
               _loc5_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_data[_loc2_].item);
               m_worldResourceAmounts[_loc5_] -= RESOURCE_INCREMENT;
               m_proposedSale.item = m_data[_loc2_].item;
               m_proposedSale.units = RESOURCE_INCREMENT;
            }
            else if(m_data[_loc2_].type == TYPE_BUILDABLE)
            {
               this.removeInventoryItem(m_data[_loc2_].item);
               m_proposedSale.item = m_data[_loc2_].item;
               m_proposedSale.units = BUILDABLE_INCREMENT;
            }
            m_keypad.userSet = false;
         }
         doPostAddRemoveActions();
      }
      
      protected function incrementAmount() : void
      {
         var _loc1_:String = null;
         if(m_proposedSale)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               _loc1_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
               if(m_worldResourceAmounts[_loc1_] >= RESOURCE_INCREMENT)
               {
                  m_worldResourceAmounts[_loc1_] -= RESOURCE_INCREMENT;
                  m_proposedSale.units += RESOURCE_INCREMENT;
               }
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               if(this.numAvailableItems(m_proposedSale.item) >= RESOURCE_INCREMENT)
               {
                  this.removeInventoryItem(m_proposedSale.item);
                  m_proposedSale.units += BUILDABLE_INCREMENT;
               }
            }
            m_keypad.userSet = false;
         }
      }
      
      override protected function onKeypadUpdate() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(m_proposedSale)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               _loc1_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
               if(m_keypad.value <= m_worldResourceAmounts[_loc1_] + m_proposedSaleQuantity)
               {
                  m_worldResourceAmounts[_loc1_] = m_worldResourceAmounts[_loc1_] + m_proposedSaleQuantity - m_keypad.value;
                  m_proposedSale.units = m_keypad.value;
               }
               else
               {
                  m_keypad.value = m_proposedSaleQuantity;
               }
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               _loc2_ = this.numAvailableItems(m_proposedSale.item);
               if(m_keypad.value <= _loc2_ + m_proposedSaleQuantity)
               {
                  _loc3_ = m_proposedSaleQuantity - m_keypad.value;
                  if(_loc3_ < 0)
                  {
                     this.removeInventoryItem(m_proposedSale.item,int(Math.abs(_loc3_)));
                  }
                  else
                  {
                     this.returnInventoryItem(m_proposedSale.item,_loc3_);
                  }
                  m_proposedSale.units = m_keypad.value;
               }
               else
               {
                  m_keypad.value = m_proposedSaleQuantity;
               }
            }
            doPostAddRemoveActions();
         }
      }
      
      override protected function onAddAll(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(m_proposedSale)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               _loc2_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
               m_proposedSale.units += m_worldResourceAmounts[_loc2_];
               m_worldResourceAmounts[_loc2_] = 0;
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               _loc3_ = this.numAvailableItems(m_proposedSale.item);
               m_proposedSale.units += _loc3_;
               this.removeInventoryItem(m_proposedSale.item,_loc3_);
            }
            doPostAddRemoveActions();
         }
      }
      
      override protected function onRemove(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(m_proposedSale) && m_proposedSale.units >= 1)
         {
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               _loc2_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
               m_worldResourceAmounts[_loc2_] += m_proposedSale.units;
               m_proposedSale.units = 0;
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               this.returnInventoryItem(m_proposedSale.item,m_proposedSale.units);
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
         var _loc2_:Object = null;
         if(Boolean(m_proposedSale) && m_proposedSale.units > 0)
         {
            _loc2_ = m_proposedSale;
            dispatchEvent(new ResourceMarketEvent(ResourceMarketEvent.ADD,_loc2_,this));
            QuestManager.getInstance().dispatchEvent(new WorldEvent(ResourceMarketEvent.ADD,{
               "type":"market",
               "data":m_proposedSale
            }));
            disableTransactionButtons();
         }
         else if(Boolean(m_currentlySelling) && m_currentlySelling.units > 0)
         {
            _loc2_ = m_currentlySelling;
            dispatchEvent(new ResourceMarketEvent(ResourceMarketEvent.REMOVE,_loc2_,this));
            disableTransactionButtons();
         }
         else
         {
            this.onCloseClick(null);
         }
      }
      
      override public function onSuccess() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:CommentSharePopup = null;
         var _loc8_:String = null;
         var _loc9_:GameItem = null;
         var _loc10_:String = null;
         var _loc11_:LocalizationObjectToken = null;
         dispatchEvent(new ResourceMarketEvent(ResourceMarketEvent.ITEM,m_proposedSale));
         setResourceListeners(false);
         LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_IGNORE_TRANSACTIONS,true));
         ZGlobal.player.inventory = this.copyDictionary(m_playerInventory);
         ZGlobal.player.resources.resourceAmounts = this.copyDictionary(m_worldResourceAmounts);
         this.updateWorldUnits();
         LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_IGNORE_TRANSACTIONS,false));
         if(Boolean(m_proposedSale) && m_proposedSale.units > 0)
         {
            _loc3_ = null;
            if(m_proposedSale.type == TYPE_RESOURCE)
            {
               _loc2_ = WorldResourceManager.instance.getResourceImageURL(m_proposedSale.item,WorldResourceManager.XTRA_LARGE_ICON);
               _loc1_ = _loc8_ = WorldResourceManager.instance.getResourceTypeFromIndex(m_proposedSale.item);
               _loc5_ = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",_loc8_ + "_sentenceName","plural"));
               _loc3_ = {
                  "count":m_proposedSale.units,
                  "item":ZGameUtils.ZlocTk("Items",_loc8_ + "_sentenceName","plural")
               };
               _loc4_ = _loc4_ = ZGameUtils.ZlocT("FeedPopups","market_item_for_sale_object",_loc3_);
            }
            else if(m_proposedSale.type == TYPE_BUILDABLE)
            {
               _loc9_ = ZGlobal.gameSettings.getItemByCode(m_proposedSale.item,GameItem) as GameItem;
               _loc2_ = ZGlobal.gameSettings.getImageByName(_loc9_.name,"icon");
               _loc1_ = _loc9_.name;
               _loc5_ = _loc9_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
               _loc10_ = m_proposedSale.units > 1 ? "plural" : "singular";
               _loc11_ = _loc9_.getSentenceNameLocalizationObject(_loc10_,true);
               if(_loc11_)
               {
                  _loc3_ = {
                     "count":m_proposedSale.units,
                     "item":_loc11_
                  };
                  _loc4_ = ZGameUtils.ZlocT("FeedPopups","market_item_for_sale_object",_loc3_);
               }
               else
               {
                  _loc3_ = {
                     "count":m_proposedSale.units,
                     "item":_loc9_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                     "unit":ZGameUtils.ZlocTk("Objects","unit","",m_proposedSale.units)
                  };
                  _loc4_ = ZGameUtils.ZlocT("FeedPopups","market_item_for_sale",_loc3_);
               }
            }
            _loc6_ = new Object();
            _loc6_.replacements = _loc3_;
            _loc6_.itemName = _loc1_;
            _loc6_.sentenceName = _loc5_;
            _loc7_ = new CommentSharePopup(_loc4_,ZGameUtils.ZlocT("FeedPopups","market_item_for_sale_title"),ZGameUtils.ZlocT("Dialogs","AskFriends"),_loc2_,FeedPopup.LARGE_IMAGE,this.onItemForSalePopupClosed,_loc6_);
            PopupManager.instance.push(_loc7_);
         }
         this.onCloseClick(null);
      }
      
      override public function onFail() : void
      {
         this.onCloseClick(null);
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","MarketRemoveFailMessage")));
      }
      
      override protected function onCloseClick(param1:MouseEvent) : void
      {
         removeTiles();
         m_worldResourceAmounts = null;
         m_playerInventory = null;
         m_proposedSale = null;
         m_currentlySelling = null;
         m_unavailableWorldUnits = null;
         m_availableWorldUnits = null;
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.RESOURCE_DIALOG_UPDATE,this.onMarketUpdate);
         super.onCloseClick(param1);
      }
      
      private function onMarketUpdate(param1:WorldEvent) : void
      {
         this.onCloseClick(null);
      }
      
      private function onItemForSalePopupClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         if(param1.button == BattleBasePopup.AUTOSHARE_COMMENT)
         {
            _loc2_ = null;
            if(param1.userData.replacements.item is LocalizationObjectToken)
            {
               _loc2_ = "market_item_feed_item_object";
            }
            else
            {
               _loc2_ = "market_item_feed_item";
            }
            _loc3_ = ZGameUtils.ZlocT("FeedPopups",_loc2_,param1.userData.replacements);
            _loc4_ = "market_item_for_sale_" + param1.userData.itemName;
            _loc5_ = ZGlobal.gameSettings.getViralXMLByName(_loc4_);
            _loc6_ = null;
            if(Boolean(param1.userData) && param1.userData.comment != null)
            {
               _loc6_ = param1.userData.comment as String;
            }
            if(_loc5_)
            {
               ViralsManager.instance.sendFeedWithComment(_loc4_,{
                  "URLstartVisitingCameraPos":this.m_marketPosition,
                  "URLvisitId":ZGlobal.hostPlayer.uid,
                  "URLvisitMarket":1,
                  "item":_loc3_,
                  "itemName":param1.userData.sentenceName
               },_loc6_);
            }
            else
            {
               ViralsManager.instance.sendFeedWithComment("market_item_for_sale",{
                  "URLstartVisitingCameraPos":this.m_marketPosition,
                  "URLvisitId":ZGlobal.hostPlayer.uid,
                  "URLvisitMarket":1,
                  "item":_loc3_,
                  "itemName":param1.userData.sentenceName
               },_loc6_);
            }
         }
      }
      
      private function suppressed(param1:GameItem) : Boolean
      {
         var _loc3_:Object = null;
         if(!param1.marketSellable)
         {
            return true;
         }
         var _loc2_:Array = ZGlobal.gameSettings.getMarketItemFilters();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.type == param1.type)
            {
               if(_loc3_.subtype == null)
               {
                  return true;
               }
               if(_loc3_.subtype == param1.subType)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function shouldShowItem(param1:GameItem) : Boolean
      {
         if(Boolean(param1) && !this.suppressed(param1))
         {
            return true;
         }
         return false;
      }
      
      protected function copyDictionary(param1:Dictionary) : Dictionary
      {
         var _loc3_:Object = null;
         var _loc2_:Dictionary = new Dictionary();
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      private function updateWorldUnits() : void
      {
         var _loc1_:String = null;
         var _loc2_:Dictionary = null;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         for(_loc1_ in m_unavailableWorldUnits)
         {
            _loc3_ = int(m_unavailableWorldUnits[_loc1_]);
            while(_loc3_ > 0)
            {
               WorldUnitManager.instance.holdUnit(_loc1_,WorldUnitManager.UNIT_IN_MARKET);
               _loc3_--;
            }
         }
         _loc2_ = WorldUnitManager.instance.availableUnits;
         for(_loc1_ in m_availableWorldUnits)
         {
            _loc4_ = int(m_availableWorldUnits[_loc1_] - _loc2_[_loc1_]);
            while(_loc4_ > 0)
            {
               WorldUnitManager.instance.releaseUnit(_loc1_,WorldUnitManager.UNIT_IN_MARKET);
               _loc4_--;
            }
         }
      }
      
      private function returnInventoryItem(param1:Object, param2:int = 1) : void
      {
         var _loc3_:int = 0;
         if(m_unavailableWorldUnits[param1])
         {
            _loc3_ = 0;
            if(m_unavailableWorldUnits[param1] < param2)
            {
               _loc3_ = param2 - m_unavailableWorldUnits[param1];
               this.addDictionaryItem(m_availableWorldUnits,param1,m_unavailableWorldUnits[param1]);
               m_unavailableWorldUnits[param1] = 0;
            }
            else
            {
               m_unavailableWorldUnits[param1] -= param2;
               this.addDictionaryItem(m_availableWorldUnits,param1,param2);
            }
            param2 = _loc3_;
         }
         if(param2 > 0)
         {
            this.addDictionaryItem(m_playerInventory,param1,param2);
         }
      }
      
      private function numAvailableItems(param1:String) : int
      {
         var _loc2_:int = m_playerInventory[param1] ? int(m_playerInventory[param1]) : 0;
         var _loc3_:int = m_availableWorldUnits[param1] ? int(m_availableWorldUnits[param1]) : 0;
         return _loc2_ + _loc3_;
      }
      
      private function removeInventoryItem(param1:String, param2:int = 1) : void
      {
         var _loc3_:int = 0;
         if(m_availableWorldUnits[param1])
         {
            _loc3_ = 0;
            if(m_availableWorldUnits[param1] < param2)
            {
               _loc3_ = param2 - m_availableWorldUnits[param1];
               this.addDictionaryItem(m_unavailableWorldUnits,param1,m_availableWorldUnits[param1]);
               m_availableWorldUnits[param1] = 0;
            }
            else
            {
               m_availableWorldUnits[param1] -= param2;
               this.addDictionaryItem(m_unavailableWorldUnits,param1,param2);
            }
            param2 = _loc3_;
         }
         if(Boolean(param2 > 0) && Boolean(m_playerInventory[param1]) && m_playerInventory[param1] >= param2)
         {
            m_playerInventory[param1] -= param2;
         }
      }
      
      private function addDictionaryItem(param1:Dictionary, param2:Object, param3:int) : void
      {
         param1[param2] = (param1[param2] ? param1[param2] : 0) + param3;
      }
      
      override protected function onResourceUpdated(param1:ResourceUpdatedEvent) : void
      {
         if(m_worldResourceAmounts)
         {
            m_worldResourceAmounts[param1.type] += param1.newAmount - param1.oldAmount;
            this.loadCards(m_tileSet);
         }
      }
   }
}

