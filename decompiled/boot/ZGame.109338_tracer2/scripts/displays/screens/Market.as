package displays.screens
{
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.resource.ResourceInfo;
   import core.ui.Style;
   import core.ui.ZGameButton;
   import dispatchers.ResourceDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.marketScreen.MarketSellingCardKeypadDisplay;
   import events.CloseEvent;
   import events.ResourceMarketEvent;
   import events.ResourceUpdatedEvent;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import transactions.TMarketList;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class Market extends SlotDialog
   {
      
      public static const TOOLTIP_POSITION:Point = new Point(75,55);
      
      public static const TYPE_RESOURCE:String = "resource";
      
      public static const TYPE_BUILDABLE:String = "buildable";
      
      private static const DEFAULT_COST_TEXTFIELD_COLOR:Object = 5457729;
      
      protected static const NUM_SLOTS:int = 6;
      
      protected static const RESOURCE_INCREMENT:Number = 1;
      
      protected static const BUILDABLE_INCREMENT:Number = 1;
      
      protected var m_iconLoaders:Array = new Array();
      
      protected var m_sellingCardCostIcon:ImageLoader = null;
      
      protected var m_worldResourceAmounts:Dictionary;
      
      protected var m_playerInventory:Dictionary;
      
      protected var m_availableWorldUnits:Dictionary;
      
      protected var m_unavailableWorldUnits:Dictionary;
      
      protected var m_currentlySelling:Object;
      
      protected var m_proposedSale:Object;
      
      protected var m_proposedSaleQuantity:int = 0;
      
      protected var m_marketWindow:MovieClip;
      
      protected var m_listTransaction:TMarketList;
      
      protected var m_listingIconLoader:ImageLoader;
      
      protected var m_serverData:Object;
      
      protected var m_entity:IEntity;
      
      protected var m_tooltip:ItemTooltip = null;
      
      protected var m_highlightedCard:MovieClip = null;
      
      protected var m_confirmBtn:ZGameButton = null;
      
      protected var m_removeBtn:ZGameButton = null;
      
      protected var m_addAllBtn:ZGameButton = null;
      
      protected var m_keypad:MarketSellingCardKeypadDisplay = null;
      
      public function Market(param1:String, param2:IEntity, param3:String, param4:Boolean = false)
      {
         super(ZGlobal.getAssetURL(param1));
         this.m_entity = param2;
         this.setResourceListeners(true);
         this.m_listTransaction = new TMarketList(this.m_entity,ZGlobal.getTransactionId(),this.onList,param4);
         TransactionManager.addTransaction(this.m_listTransaction,true);
      }
      
      protected function setResourceListeners(param1:Boolean) : void
      {
         var _loc2_:ResourceInfo = null;
         for each(_loc2_ in WorldResourceManager.instance.resourceInfo)
         {
            if(!(_loc2_.type == "coins" || _loc2_.type == "energy"))
            {
               if(param1)
               {
                  ResourceDispatcher.instance.addEventListener(_loc2_.type,this.onResourceUpdated,false,0,true);
               }
               else
               {
                  ResourceDispatcher.instance.removeEventListener(_loc2_.type,this.onResourceUpdated);
               }
            }
         }
      }
      
      protected function onResourceUpdated(param1:ResourceUpdatedEvent) : void
      {
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:MovieClip = null;
         m_window = this.m_marketWindow.selectionDialog_mc.forSale_mc;
         m_origOffsetX = this.m_marketWindow.x;
         m_origOffsetY = this.m_marketWindow.y;
         this.m_marketWindow.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         contentWidth = this.m_marketWindow.width;
         contentHeight = 412;
         this.initDialog();
         this.hideListing();
         var _loc2_:Array = [this.m_marketWindow.selectionDialog_mc.forSale_mc.card_mc_0,this.m_marketWindow.selectionDialog_mc.forSale_mc.card_mc_1,this.m_marketWindow.selectionDialog_mc.forSale_mc.card_mc_2,this.m_marketWindow.selectionDialog_mc.forSale_mc.card_mc_3,this.m_marketWindow.selectionDialog_mc.forSale_mc.card_mc_4,this.m_marketWindow.selectionDialog_mc.forSale_mc.card_mc_5];
         for each(_loc3_ in _loc2_)
         {
            addTile(_loc3_);
         }
         TextFieldUtil.processTextField(this.m_marketWindow.title_mc,ZGameUtils.ZlocT("Dialogs","MarketTitle"));
         TextFieldUtil.processTextField(this.m_marketWindow.status_tf,ZGameUtils.ZlocT("Dialogs","MarketGuestLoadingMessage"));
         m_buttonSounds.addButton(this.m_marketWindow.exit_bt,ButtonSound.DEFAULT);
         addChild(this.m_marketWindow);
         m_buildButtons = new Array();
         addAllComponents(m_tileSet * this.getNumSlots());
         fixArrows();
         if(this.m_serverData)
         {
            this.onList(this.m_serverData);
         }
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.initKeypad();
         if(this.m_marketWindow.selectionDialog_mc.cart_mc.confirm_bt)
         {
            this.m_confirmBtn = new ZGameButton(this.m_marketWindow.selectionDialog_mc.cart_mc.confirm_bt,this.onConfirm);
            this.m_confirmBtn.text = ZGameUtils.ZlocT("Dialogs","ConfirmButtonText");
            m_buttonSounds.addButton(this.m_confirmBtn.m_overlay,ButtonSound.DEFAULT);
         }
         if(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.remove_bt)
         {
            this.m_removeBtn = new ZGameButton(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.remove_bt,this.onRemove);
            this.m_removeBtn.text = ZGameUtils.ZlocT("Dialogs","RemoveButtonText");
            m_buttonSounds.addButton(this.m_removeBtn.m_overlay,ButtonSound.DEFAULT);
         }
         if(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.add_bt)
         {
            this.m_addAllBtn = new ZGameButton(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.add_bt,this.onAddAll);
            this.m_addAllBtn.text = ZGameUtils.ZlocT("Dialogs","MarketAddAllButton");
            m_buttonSounds.addButton(this.m_addAllBtn.m_overlay,ButtonSound.DEFAULT);
         }
         TextFieldUtil.processTextField(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.quantity_tf,ZGameUtils.ZlocT("Dialogs","MarketQuantityTitle"));
         TextFieldUtil.processTextField(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.totalCost_tf,ZGameUtils.ZlocT("Dialogs","MarketTotalCostTitle"));
      }
      
      protected function initKeypad() : void
      {
         this.m_keypad = new MarketSellingCardKeypadDisplay(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc,this.onKeypadUpdate);
      }
      
      protected function onKeypadUpdate() : void
      {
      }
      
      protected function isMarketHost() : Boolean
      {
         return false;
      }
      
      public function onList(param1:Object) : void
      {
         this.m_marketWindow.status_tf.visible = false;
         if(Boolean(param1) && param1.length != 0)
         {
            param1 = param1[0];
         }
         if(Boolean(param1) && (param1.item == "0" || param1.item == "8"))
         {
            dispatchEvent(new ResourceMarketEvent(ResourceMarketEvent.REMOVE,param1,this));
         }
         else if(Boolean(param1) && param1.units > 0)
         {
            this.m_proposedSale = {
               "type":param1.type,
               "units":param1.units,
               "item":param1.item
            };
            this.m_currentlySelling = {
               "type":param1.type,
               "units":param1.units,
               "item":param1.item
            };
            this.m_proposedSaleQuantity = param1.units;
            this.loadCards(0);
            this.populateCard(this.m_proposedSale,this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc,true);
            this.populateSellingCard(this.m_proposedSale);
         }
         else
         {
            this.loadCards(0);
            this.hideListing();
         }
      }
      
      override protected function preRemoveTiles() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_iconLoaders.length)
         {
            this.m_iconLoaders[_loc1_].destroy();
            _loc1_++;
         }
         this.m_iconLoaders = new Array();
         _loc1_ = 0;
         while(_loc1_ < m_buildButtons.length)
         {
            m_buildButtons[_loc1_].dispose();
            _loc1_++;
         }
         m_buildButtons = new Array();
      }
      
      override protected function postRemoveTiles(param1:int) : void
      {
         m_tiles[param1].itemCard_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         m_tiles[param1].itemCard_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         m_tiles[param1].itemCard_mc.removeEventListener(MouseEvent.CLICK,this.onAdd);
         super.postRemoveTiles(param1);
      }
      
      protected function loadCards(param1:int) : void
      {
      }
      
      protected function populateCard(param1:Object, param2:MovieClip, param3:Boolean = false) : ImageLoader
      {
         var _loc4_:String = null;
         var _loc6_:GameItem = null;
         var _loc7_:ZGameButton = null;
         param2.visible = true;
         param2.icon.visible = true;
         if(this.m_highlightedCard == param2)
         {
            param2.highlightSelect.visible = true;
         }
         if(param1.type == TYPE_RESOURCE)
         {
            TextFieldUtil.processTextField(param2.itemName_tf,WorldResourceManager.instance.getResourceFriendlyNameFromIndex(param1.item,GameItem.MENU_FRIENDLYNAME));
            if(ZGlobal.player.uid != ZGlobal.hostPlayer.uid && ZGlobal.player.coins < WorldResourceManager.instance.resourceInfo[param1.item].marketPrice)
            {
               TextFieldUtil.setTextFieldColor(param2.cost_tf,Style.COLOR_UNSUFFICIENT_FUNDS);
            }
            else
            {
               TextFieldUtil.setTextFieldColor(param2.cost_tf,DEFAULT_COST_TEXTFIELD_COLOR);
            }
            TextFieldUtil.processTextField(param2.cost_tf,WorldResourceManager.instance.resourceInfo[param1.item].marketPrice);
            _loc4_ = WorldResourceManager.instance.getResourceImageURL(param1.item,WorldResourceManager.XTRA_LARGE_ICON);
         }
         else if(param1.type == TYPE_BUILDABLE)
         {
            _loc6_ = ZGlobal.gameSettings.getItemByCode(param1.item,GameItem) as GameItem;
            TextFieldUtil.processTextField(param2.itemName_tf,_loc6_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            if(ZGlobal.player.uid != ZGlobal.hostPlayer.uid && ZGlobal.player.coins < this.getMarketPrice(param1))
            {
               TextFieldUtil.setTextFieldColor(param2.cost_tf,Style.COLOR_UNSUFFICIENT_FUNDS);
            }
            else
            {
               TextFieldUtil.setTextFieldColor(param2.cost_tf,DEFAULT_COST_TEXTFIELD_COLOR);
            }
            TextFieldUtil.processTextField(param2.cost_tf,_loc6_.marketPrice.toString());
            _loc4_ = ZGlobal.gameSettings.getImageByName(_loc6_.name,"icon");
         }
         param2.underlay_mc.visible = param2.itemName_tf.numLines > 1;
         if(param2.units_mc)
         {
            TextFieldUtil.processTextField(param2.units_mc.units_tf,param1.units);
         }
         else
         {
            TextFieldUtil.processTextField(param2.units_tf,param1.units);
         }
         if(param2.select_bt)
         {
            _loc7_ = new ZGameButton(param2.select_bt,this.onAdd);
            _loc7_.text = ZGameUtils.ZlocT("Dialogs","MarketButtonText");
            m_buildButtons.push(_loc7_);
            param2.addEventListener(MouseEvent.CLICK,this.onAdd,false,0,true);
            if(param1.units == 0)
            {
               _loc7_.disable_visual();
            }
            else
            {
               _loc7_.enable();
            }
         }
         TextFieldUtil.processTextField(param2.costHeader_tf,ZGameUtils.ZlocT("Dialogs","MarketCostTitle"));
         if(!param3)
         {
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType("coins",WorldResourceManager.XTRA_SMALL_ICON),param2.costIcon_mc));
         }
         var _loc5_:ImageLoader = null;
         if(_loc4_)
         {
            _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc4_,param2.icon);
            if(param3)
            {
               _loc5_.smooth = true;
            }
         }
         return _loc5_;
      }
      
      protected function getMarketPrice(param1:Object) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:GameItem = null;
         if(param1.type == TYPE_RESOURCE)
         {
            _loc2_ = Number(WorldResourceManager.instance.resourceInfo[param1.item].marketPrice);
         }
         else if(param1.type == TYPE_BUILDABLE)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(param1.item,GameItem) as GameItem;
            _loc2_ = _loc3_.marketPrice;
         }
         return _loc2_;
      }
      
      protected function populateSellingCard(param1:Object) : void
      {
         var _loc2_:Number = this.getMarketPrice(param1);
         this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.remove_bt.visible = true;
         this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.costIcon_mc.visible = true;
         var _loc3_:Number = param1.units * _loc2_;
         if(!this.isMarketHost() && !ZGlobal.player.resources.checkResourceAmount("coins",-_loc3_))
         {
            TextFieldUtil.setTextFieldColor(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.cost_tf,Style.COLOR_UNSUFFICIENT_FUNDS);
         }
         else
         {
            TextFieldUtil.setTextFieldColor(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.cost_tf,DEFAULT_COST_TEXTFIELD_COLOR);
         }
         TextFieldUtil.processTextField(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.cost_tf,_loc3_.toString());
         this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.totalCost_tf.visible = true;
         this.m_sellingCardCostIcon = ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType("coins",WorldResourceManager.XTRA_SMALL_ICON),this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.costIcon_mc);
         this.m_addAllBtn.enable();
         this.m_keypad.enable();
         this.m_keypad.value = param1.units;
      }
      
      protected function doPostAddRemoveActions() : void
      {
         this.m_proposedSaleQuantity = this.m_proposedSale ? int(this.m_proposedSale.units) : 0;
         if(!this.m_proposedSale || this.m_proposedSale.length == 0 || this.m_proposedSale.units <= 0)
         {
            this.hideListing();
         }
         else
         {
            if(this.m_listingIconLoader)
            {
               this.m_listingIconLoader.destroy();
            }
            this.m_listingIconLoader = this.populateCard(this.m_proposedSale,this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc,true);
            this.populateSellingCard(this.m_proposedSale);
         }
         this.updateCurrentCardsAfterAddRemoveActions();
      }
      
      protected function updateCurrentCardsAfterAddRemoveActions() : void
      {
         this.loadCards(m_tileSet);
      }
      
      protected function hideListing() : void
      {
         if(this.m_marketWindow != null)
         {
            if(!this.m_proposedSale)
            {
               this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.icon.visible = false;
               this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.itemName_tf.text = "";
               this.m_keypad.disable();
               this.m_addAllBtn.disable_visual();
            }
            if(this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.costIcon_mc)
            {
               this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.costIcon_mc.visible = false;
               this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.cost_tf.text = "";
            }
            this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.totalCost_tf.visible = false;
            this.m_marketWindow.selectionDialog_mc.cart_mc.sellingCard_mc.remove_bt.visible = false;
            if(this.m_sellingCardCostIcon)
            {
               this.m_sellingCardCostIcon.destroy();
               this.m_sellingCardCostIcon = null;
            }
            this.m_keypad.value = 0;
         }
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS;
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc7_:ResourceInfo = null;
         var _loc8_:Point = null;
         var _loc9_:Point = null;
         this.m_highlightedCard = MovieClip(param1.target);
         if(this.m_highlightedCard.alpha != 1)
         {
            return;
         }
         param1.target.highlightSelect.visible = true;
         var _loc2_:int = this.getIndexFromEvent(param1);
         var _loc3_:Object = m_data[_loc2_];
         var _loc5_:GameItem = null;
         if(_loc3_.type == TYPE_RESOURCE)
         {
            _loc6_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc3_.item);
            _loc7_ = WorldResourceManager.instance.getResourceInfoByType(_loc6_);
            _loc4_ = _loc7_.tooltipType;
         }
         else
         {
            _loc5_ = GameItem.createItemFromCode(_loc3_.item,ZGlobal.gameSettings.getItems());
            if(_loc5_)
            {
               _loc4_ = _loc5_.tooltipType;
            }
            _loc3_ = _loc5_;
         }
         if(_loc4_ == GameItem.UNIT_TOOLTIP)
         {
            this.m_tooltip = new ItemTooltip(_loc4_,_loc3_,ItemTooltip.SOURCE_MARKET);
            this.m_marketWindow.addChild(this.m_tooltip);
            _loc8_ = MovieClip(param1.currentTarget).localToGlobal(new Point(TOOLTIP_POSITION.x,TOOLTIP_POSITION.y));
            _loc9_ = this.m_marketWindow.globalToLocal(_loc8_);
            this.m_tooltip.x = _loc9_.x;
            this.m_tooltip.y = _loc9_.y;
            this.m_tooltip.alpha = 0;
            TweenLite.to(this.m_tooltip,0.5,{"alpha":1});
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         param1.target.highlightSelect.visible = false;
         this.m_highlightedCard = null;
         if(Boolean(this.m_tooltip) && this.m_marketWindow.contains(this.m_tooltip))
         {
            this.m_marketWindow.removeChild(this.m_tooltip);
            this.m_tooltip.destroy();
         }
         this.m_tooltip = null;
      }
      
      protected function onAdd(param1:MouseEvent) : void
      {
      }
      
      protected function onConfirm(param1:MouseEvent) : void
      {
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         this.onCloseClick(param1);
      }
      
      protected function onRemove(param1:MouseEvent) : void
      {
      }
      
      protected function onAddAll(param1:MouseEvent) : void
      {
      }
      
      public function onFail() : void
      {
      }
      
      public function onSuccess() : void
      {
      }
      
      protected function onCloseClick(param1:MouseEvent) : void
      {
         if(this.m_sellingCardCostIcon)
         {
            this.m_sellingCardCostIcon.destroy();
            this.m_sellingCardCostIcon = null;
         }
         this.m_listTransaction.cancel();
         this.m_listTransaction = null;
         if(this.m_listingIconLoader != null)
         {
            this.m_listingIconLoader.destroy();
            this.m_listingIconLoader = null;
         }
         deinitDialog();
         this.m_marketWindow.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_marketWindow = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      protected function getIndexFromEvent(param1:MouseEvent) : int
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1 != null)
         {
            if(param1.type == MouseEvent.ROLL_OVER)
            {
               _loc2_ = String(param1.currentTarget.parent.name).replace(/card_mc_/,"");
            }
            else
            {
               _loc2_ = String(param1.currentTarget.parent.parent.name).replace(/card_mc_/,"");
            }
            _loc3_ = int(_loc2_);
         }
         return int(_loc3_ + m_tileSet * this.getNumSlots());
      }
      
      protected function disableTransactionButtons() : void
      {
         this.m_marketWindow.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_confirmBtn.disable();
      }
      
      protected function centreWithinStage(param1:Stage) : void
      {
         centerX = param1.stageWidth / 2 + m_origOffsetX;
         centerY = param1.stageHeight / 2 + m_origOffsetY;
      }
   }
}

