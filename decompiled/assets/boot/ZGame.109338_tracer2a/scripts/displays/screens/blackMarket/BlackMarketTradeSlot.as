package displays.screens.blackMarket
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import core.ui.ZGameBuyButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.BlackMarketTooltip;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BlackMarketTradeSlot extends GridSlot
   {
      
      public static const BLACKMARKET_PART_PURCHASE:String = "blackmarket_part_purchase";
      
      public static const ICON:String = "icon";
      
      public static const ASK:String = "ask";
      
      public static const BUY:String = "buy";
      
      public static const PLACE:String = "place";
      
      public static const SCRAP:String = "scrap";
      
      public static const TRADE:String = "trade";
      
      protected const TOTAL_REQUIREMENT_CARDS:uint = 4;
      
      protected var m_item:Object = null;
      
      protected var m_imageLoaders:Array = null;
      
      protected var m_requiresArr:Array;
      
      protected var m_tradeButton:ZGameButton;
      
      protected var m_askButton:ZGameButton;
      
      protected var m_buyButton:ZGameBuyButton;
      
      protected var partItem:GameItem;
      
      private var m_itemTooltip:BlackMarketTooltip = null;
      
      protected var m_listener:EventDispatcher = null;
      
      public function BlackMarketTradeSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:Object, param7:EventDispatcher)
      {
         super(param1,param2,param3);
         this.m_item = param6;
         this.m_listener = param7;
         slot.x = param4 * slot.width;
         slot.y = param5 * slot.height;
         this.partItem = ZGlobal.gameSettings.getItemByCode(this.m_item.code,GameItem) as GameItem;
         this.populateCard();
         this.setButtons();
         this.update();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("TradeCard");
         return new _loc2_();
      }
      
      protected function populateCard() : void
      {
         this.m_imageLoaders = new Array();
         TextFieldUtil.setMouseEnabled([slot.partCount_tf,slot.ask_bt.generic_tf,slot.buy_bt.generic_tf,slot.item1_mc.count_tf,slot.item2_mc.count_tf,slot.item3_mc.count_tf,slot.item4_mc.count_tf],false);
         slot.buttonMode = false;
         slot.useHandCursor = false;
         this.m_requiresArr = BlackMarketDataHelper.instance.getRequirementList(this.m_item);
         var _loc1_:XML = ZGlobal.gameSettings.getItemXMLByCode(this.m_item.code);
         var _loc2_:String = ZGlobal.gameSettings.getImageByName(_loc1_.@name,"icon");
         this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_,slot.icon));
         slot.icon.addEventListener(MouseEvent.MOUSE_OVER,this.showToolTip,false,0,true);
         slot.icon.addEventListener(MouseEvent.MOUSE_OUT,this.removeToolTip,false,0,true);
         var _loc3_:uint = 0;
         while(_loc3_ < this.TOTAL_REQUIREMENT_CARDS)
         {
            if(this.m_requiresArr[_loc3_] != null && this.m_requiresArr[_loc3_] != undefined && this.m_requiresArr[_loc3_].type != null)
            {
               if(this.m_requiresArr[_loc3_].type == "scrap")
               {
                  _loc2_ = ZGlobal.getAssetURL(BlackMarketTradeScreen.SCRAP_ICON_PATH);
                  slot["item" + (_loc3_ + 1) + "_mc"].addEventListener(MouseEvent.ROLL_OVER,this.showToolTip,false,0,true);
                  slot["item" + (_loc3_ + 1) + "_mc"].addEventListener(MouseEvent.ROLL_OUT,this.removeToolTip,false,0,true);
               }
               else if(String(this.m_requiresArr[_loc3_].type).indexOf("nrare") != -1)
               {
                  _loc2_ = WorldResourceManager.instance.getResourceImageURLByType(WorldResourceManager.instance.resourceFromRareResource(this.m_requiresArr[_loc3_].type),WorldResourceManager.XTRA_LARGE_ICON);
               }
               else
               {
                  _loc2_ = WorldResourceManager.instance.getResourceImageURLByType(this.m_requiresArr[_loc3_].type,WorldResourceManager.XTRA_LARGE_ICON);
               }
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_,slot["item" + (_loc3_ + 1) + "_mc"].icon));
            }
            else
            {
               slot["item" + (_loc3_ + 1) + "_mc"].visible = false;
            }
            _loc3_++;
         }
      }
      
      protected function setButtons() : void
      {
         this.m_tradeButton = new ZGameButton(slot.trade_bt,this.onTradeClicked,1.1,false,this.removeToolTip,this.doTradeOver);
         TextFieldUtil.compactTextField(slot.trade_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketTradeButtonText"));
         m_buttonSounds.addButton(this.m_tradeButton.m_overlay,ButtonSound.DEFAULT);
         this.m_askButton = new ZGameButton(slot.ask_bt,this.onAskClicked,1.1,false,this.removeToolTip,this.doAskOver);
         TextFieldUtil.compactTextField(slot.ask_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketAskButtonText"));
         m_buttonSounds.addButton(this.m_askButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buyButton = new ZGameBuyButton(slot.buy_bt,this.generateBuyButtonData(),this.onBuyClicked,1.1,false,this.removeToolTip,this.doBuyOver);
         TextFieldUtil.compactTextField(slot.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketBuyButtonText",{"count":this.partItem.cash}));
         m_buttonSounds.addButton(this.m_buyButton.m_overlay,ButtonSound.DEFAULT);
      }
      
      public function update() : void
      {
         this.updatePartCount();
         this.updateRequirementCountText();
         this.updateBuyBttonState();
         this.updateTradeButtonState();
         this.updateAskButtonState();
      }
      
      protected function onTradeClicked(param1:MouseEvent) : void
      {
         this.removeParts();
         ZGlobal.player.addToInventory(this.m_item.code);
         this.m_listener.dispatchEvent(new WorldEvent(BLACKMARKET_PART_PURCHASE,this.m_item.code));
      }
      
      protected function onAskClicked(param1:MouseEvent) : void
      {
         var _loc2_:uint = 0;
         if(this.partItem != null)
         {
            _loc2_ = uint(ZGlobal.getResearchPartsExperimentVariantByType(this.partItem.subType));
            ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts",{
               "itemCode":this.partItem.code,
               "unitName":this.partItem.name,
               "ITEMTOKOVERRIDEitemPart":this.partItem.name + "|singular",
               "ITEMTOKitemParts":this.partItem.name + "|plural"
            },null);
         }
      }
      
      protected function onBuyClicked(param1:MouseEvent) : void
      {
         ZGlobal.player.buyGameItem(this.partItem);
         this.m_listener.dispatchEvent(new WorldEvent(BLACKMARKET_PART_PURCHASE));
      }
      
      protected function generateBuyButtonData() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.cash = this.partItem.cash;
         _loc1_.confirmationData = new Object();
         _loc1_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc2_:Object = ZGameUtils.CashTokenReplacements(this.partItem.cash);
         _loc2_.item = this.partItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         _loc1_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc2_);
         return _loc1_;
      }
      
      protected function updateTradeButtonState() : void
      {
         if(!this.hasEnoughPart() && this.checkHasAllItems())
         {
            this.m_tradeButton.enable();
         }
         else
         {
            this.m_tradeButton.disable_visual();
         }
      }
      
      protected function updatePartCount() : void
      {
         var _loc1_:String = null;
         if(ZGlobal.player.inventory[this.m_item.code] == undefined || ZGlobal.player.inventory[this.m_item.code] == null)
         {
            _loc1_ = "0";
         }
         else
         {
            _loc1_ = ZGlobal.player.inventory[this.m_item.code].toString();
         }
         if(_loc1_ > this.m_item.count)
         {
            TextFieldUtil.processTextField(slot.partCount_tf,this.m_item.count + " / " + this.m_item.count);
         }
         else
         {
            TextFieldUtil.processTextField(slot.partCount_tf,_loc1_ + " / " + this.m_item.count);
         }
      }
      
      public function updateRequirementCountText() : void
      {
         var _loc1_:uint = this.m_requiresArr.length;
         var _loc2_:uint = 0;
         while(_loc2_ < _loc1_)
         {
            if(this.m_requiresArr[_loc2_].type == "scrap")
            {
               this.m_requiresArr[_loc2_].inventoryCount = ZGlobal.player.getNumberOfInventoryItems("SC01");
            }
            else if(String(this.m_requiresArr[_loc2_].type).indexOf("nrare") != -1)
            {
               this.m_requiresArr[_loc2_].inventoryCount = ZGlobal.player.resources.resourceAmounts[WorldResourceManager.instance.resourceFromRareResource(this.m_requiresArr[_loc2_].type)];
            }
            else
            {
               this.m_requiresArr[_loc2_].inventoryCount = ZGlobal.player.resources.resourceAmounts[this.m_requiresArr[_loc2_].type];
            }
            if(this.m_requiresArr[_loc2_].inventoryCount > this.m_requiresArr[_loc2_].count)
            {
               TextFieldUtil.processTextField(slot["item" + (_loc2_ + 1) + "_mc"].count_tf,this.m_requiresArr[_loc2_].count + " / " + this.m_requiresArr[_loc2_].count);
            }
            else
            {
               TextFieldUtil.processTextField(slot["item" + (_loc2_ + 1) + "_mc"].count_tf,this.m_requiresArr[_loc2_].inventoryCount + " / " + this.m_requiresArr[_loc2_].count);
            }
            if(this.m_requiresArr[_loc2_].inventoryCount < this.m_requiresArr[_loc2_].count)
            {
               slot["item" + (_loc2_ + 1) + "_mc"].tick_mc.visible = false;
            }
            else
            {
               slot["item" + (_loc2_ + 1) + "_mc"].tick_mc.visible = true;
            }
            _loc2_++;
         }
      }
      
      protected function updateBuyBttonState() : void
      {
         if(!this.hasEnoughPart())
         {
            this.m_buyButton.enable();
         }
         else
         {
            this.m_buyButton.disable_visual();
         }
      }
      
      protected function updateAskButtonState() : void
      {
         if(!this.hasEnoughPart())
         {
            this.m_askButton.enable();
         }
         else
         {
            this.m_askButton.disable_visual();
         }
      }
      
      protected function removeParts() : void
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.m_requiresArr.length)
         {
            if(this.m_requiresArr[_loc1_].type == "scrap")
            {
               ZGlobal.player.removeInventoryItem("SC01",this.m_requiresArr[_loc1_].count);
            }
            else if(String(this.m_requiresArr[_loc1_].type).indexOf("nrare") != -1)
            {
               ZGlobal.player.resources.updateResourceAmount(WorldResourceManager.instance.resourceFromRareResource(this.m_requiresArr[_loc1_].type),-1 * this.m_requiresArr[_loc1_].count);
            }
            else
            {
               ZGlobal.player.resources.updateResourceAmount(this.m_requiresArr[_loc1_].type,-1 * this.m_requiresArr[_loc1_].count);
            }
            _loc1_++;
         }
      }
      
      protected function doTradeOver(param1:MouseEvent) : void
      {
         this.showToolTip(param1,"trade_bt");
      }
      
      protected function doAskOver(param1:MouseEvent) : void
      {
         this.showToolTip(param1,"ask_bt");
      }
      
      protected function doBuyOver(param1:MouseEvent) : void
      {
         this.showToolTip(param1,"buy_bt");
      }
      
      protected function showToolTip(param1:MouseEvent, param2:String = null) : void
      {
         var _loc3_:String = null;
         if(param2 == null)
         {
            param2 = param1.currentTarget.name;
         }
         switch(param2)
         {
            case "icon":
               _loc3_ = ICON;
               break;
            case "ask_bt":
               _loc3_ = ASK;
               break;
            case "buy_bt":
               _loc3_ = BUY;
               break;
            case "trade_bt":
               _loc3_ = TRADE;
               break;
            default:
               _loc3_ = SCRAP;
         }
         this.m_itemTooltip = new BlackMarketTooltip(_loc3_,this.partItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.m_itemTooltip.x = param1.currentTarget.x + param1.currentTarget.parent.x + parent.x + param1.currentTarget.width * 0.5;
         this.m_itemTooltip.y = param1.currentTarget.y + param1.currentTarget.parent.y + parent.y;
         this.m_itemTooltip.mouseEnabled = false;
         this.m_itemTooltip.mouseChildren = false;
         screen.addChild(this.m_itemTooltip);
      }
      
      protected function removeToolTip(param1:MouseEvent) : void
      {
         if(Boolean(this.m_itemTooltip) && screen.contains(this.m_itemTooltip))
         {
            screen.removeChild(this.m_itemTooltip);
            this.m_itemTooltip.destroy();
         }
         this.m_itemTooltip = null;
      }
      
      protected function checkHasAllItems() : Boolean
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.m_requiresArr.length)
         {
            if(this.m_requiresArr[_loc1_].inventoryCount < this.m_requiresArr[_loc1_].count)
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      protected function hasEnoughPart() : Boolean
      {
         if(ZGlobal.player.inventory[this.m_item.code] >= this.m_item.count)
         {
            return true;
         }
         return false;
      }
      
      override public function dispose() : void
      {
         this.disposeImageLoaders();
         this.m_tradeButton.dispose();
         this.m_buyButton.dispose();
         this.m_askButton.dispose();
         super.dispose();
      }
      
      protected function disposeImageLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_imageLoaders = null;
      }
   }
}

