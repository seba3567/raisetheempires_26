package displays.screens.blackMarket
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.BlackMarketTooltip;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import transactions.TBlackMarketTradePart;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BlackMarketTradeScreen extends ZGamePopUp
   {
      
      private static var m_instance:BlackMarketTradeScreen = null;
      
      public static const SCRAP_ICON_PATH:String = "assets/game/quests/Quests_Icons_1.swf/Scrap_01_96.png";
      
      public static const CONTRACT_SLOT_PURCHASE:String = "contractSlotPurchase";
      
      private var m_itemTooltip:BlackMarketTooltip = null;
      
      protected var m_listener:EventDispatcher = null;
      
      protected var m_item:Object;
      
      protected var m_itemName:String;
      
      protected var m_menuName:String;
      
      protected var m_partList:Array;
      
      protected var m_grid:BlackMarketGrid;
      
      protected var m_resource:SWFResource = null;
      
      protected var m_scrapIconLoader:ImageLoader;
      
      protected var m_itemIconLoader:ImageLoader;
      
      protected var m_placeButton:ZGameButton = null;
      
      protected var m_retunButton:ZGameButton = null;
      
      protected var m_isBuilding:Boolean;
      
      private var m_helpActive:Boolean;
      
      private var m_scrapItem:GameItem;
      
      private var m_gameItemForItem:GameItem;
      
      public function BlackMarketTradeScreen(param1:Object, param2:EventDispatcher)
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/BM_trade_dialoge.swf"));
         this.m_listener = param2;
         this.m_item = param1;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         var _loc2_:Class = param1.getAssetClass("dialog");
         m_window = new _loc2_();
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         this.m_scrapIconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(SCRAP_ICON_PATH),m_window.scrap_icon);
         this.m_gameItemForItem = ZGlobal.gameSettings.getItemByCode(this.m_item.code,GameItem) as GameItem;
         this.m_itemName = ZGlobal.gameSettings.getItemXMLByCode(this.m_item.code).@name;
         this.m_menuName = this.m_gameItemForItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         this.m_itemIconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_itemName,"icon"),m_window.item_icon);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked,false,0,true);
         addEventListener(BlackMarketTradeSlot.BLACKMARKET_PART_PURCHASE,this.onSlotPurchase,false,0,true);
         this.m_scrapItem = ZGlobal.gameSettings.getItemByCode(BlackMarketContractScreen.SCRAPCODE,GameItem) as GameItem;
         this.createGrid();
         this.initDialog();
         this.update();
         addChild(m_window);
      }
      
      override protected function initDialog() : void
      {
         var _loc2_:String = null;
         super.initDialog();
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketContract"));
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","BlackMarket_TradeScreen_Description",{"itemName":this.m_menuName});
         TextFieldUtil.compactTextField(m_window.level_tf,_loc1_);
         if(String(this.m_item.type).toLowerCase() == "building")
         {
            this.m_isBuilding = true;
            _loc2_ = ZGameUtils.ZlocT("Dialogs","BlackMarket_TradeScreen_placeText");
         }
         else
         {
            this.m_isBuilding = false;
            _loc2_ = ZGameUtils.ZlocT("Dialogs","BlackMarket_TradeScreen_collectText");
         }
         this.m_placeButton = new ZGameButton(m_window.place_bt,this.onPlaceClicked,1.1,false,this.removeToolTip,this.showToolTip);
         this.m_placeButton.text = _loc2_;
         this.m_retunButton = new ZGameButton(m_window.return_bt,this.onReturnClicked);
         this.m_retunButton.text = ZGameUtils.ZlocT("Dialogs","BlackMarket_TradeScreen_returnText");
         TextFieldUtil.compactTextField(m_window.hints_mc.hint1_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketTrade_Hint1Text"));
         TextFieldUtil.compactTextField(m_window.hints_mc.hint2_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketTrade_Hint2Text"));
         TextFieldUtil.compactTextField(m_window.hints_mc.hint3_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketTrade_Hint3Text"));
         m_window.tooltipBtn.addEventListener(MouseEvent.CLICK,this.onHelpClicked,false,0,true);
         this.hideHelp();
      }
      
      protected function update() : void
      {
         TextFieldUtil.compactTextField(m_window.scrapCount_tf,ZGlobal.player.getNumberOfInventoryItems(BlackMarketContractScreen.SCRAPCODE).toString() + " / " + this.m_scrapItem.inventoryCap);
         this.enableDisablePlaceBt();
      }
      
      protected function createGrid() : void
      {
         this.m_partList = BlackMarketDataHelper.instance.getPartList(this.m_item);
         this.m_grid = new BlackMarketGrid(m_window.grid_mc,this.m_resource,this,this.m_partList,true);
      }
      
      protected function onHelpClicked(param1:MouseEvent) : void
      {
         if(!this.m_helpActive)
         {
            this.showHelp();
         }
         else
         {
            this.hideHelp();
         }
      }
      
      protected function hideHelp() : void
      {
         m_window.hints_mc.visible = false;
         m_window.hints_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onHelpClicked);
         this.m_helpActive = false;
      }
      
      protected function showHelp() : void
      {
         m_window.hints_mc.visible = true;
         m_window.hints_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onHelpClicked);
         this.m_helpActive = true;
      }
      
      protected function enableDisablePlaceBt() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:Dictionary = null;
         var _loc3_:Object = null;
         var _loc4_:GameDataComponent = null;
         var _loc5_:BuildingFSMComponent = null;
         if(this.m_isBuilding)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_item.code,GameItem) as GameItem;
            _loc2_ = WorldObjectManager.instance.getObjectsBySubType(_loc1_.type,_loc1_.subType);
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc4_)) && Boolean(_loc4_.gameData))
               {
                  _loc5_ = BuildingFSMComponent(_loc3_.lookupComponentByType(BuildingFSMComponent));
                  if(_loc4_.gameData.code == this.m_item.code)
                  {
                     this.m_placeButton.disable();
                  }
               }
            }
            if(ZGlobal.player.getNumberOfInventoryItems(this.m_item.code) < 1)
            {
               this.m_placeButton.disable();
            }
         }
         else if(this.checkHasAllParts())
         {
            this.m_placeButton.enable();
         }
         else
         {
            this.m_placeButton.disable_visual();
         }
      }
      
      protected function onPlaceClicked(param1:MouseEvent = null) : void
      {
         var _loc2_:GameItem = null;
         if(this.m_isBuilding)
         {
            this.m_listener.dispatchEvent(new MouseEvent(BlackMarketContractScreen.BLACKMARKET_CLOSEDIALOG));
            _loc2_ = ZGlobal.gameSettings.getItemByCode(this.m_item.code,GameItem) as GameItem;
            if(ZGlobal.player.getNumberOfInventoryItems(this.m_item.code) >= 1)
            {
               GameModeManager.instance.addGameMode(new GMObjectPlace(this.m_gameItemForItem.name,MarketEvent.SOURCE_INVENTORY,true));
            }
            else
            {
               GameModeManager.instance.addGameMode(new GMObjectPlace(this.m_gameItemForItem.name,MarketEvent.SOURCE_BUILDING,false,null));
            }
         }
         else
         {
            this.m_listener.dispatchEvent(new WorldEvent(BlackMarketContractScreen.BLACKMARKET_CONTRACT,this.purchaseEventObject()));
         }
         this.onCloseClicked();
      }
      
      protected function onReturnClicked(param1:MouseEvent) : void
      {
         this.onCloseClicked();
      }
      
      protected function purchaseEventObject() : Object
      {
         var _loc3_:Object = null;
         var _loc1_:Object = new Object();
         _loc1_.code = this.m_item.code;
         var _loc2_:Array = new Array();
         var _loc4_:uint = 0;
         while(_loc4_ < this.m_partList.length)
         {
            _loc3_ = new Object();
            _loc3_.code = this.m_partList[_loc4_].code;
            _loc3_.count = this.m_partList[_loc4_].count;
            _loc2_.push(_loc3_);
            _loc4_++;
         }
         _loc1_.arr = _loc2_;
         return _loc1_;
      }
      
      protected function checkHasAllParts() : Boolean
      {
         var _loc1_:uint = this.m_partList.length;
         var _loc2_:uint = 0;
         while(_loc2_ < _loc1_)
         {
            if(ZGlobal.player.inventory[this.m_partList[_loc2_].code] < this.m_partList[_loc2_].count || ZGlobal.player.inventory[this.m_partList[_loc2_].code] == undefined)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function onSlotPurchase(param1:WorldEvent) : void
      {
         var _loc2_:String = param1.eventData as String;
         if(_loc2_ != null && _loc2_ != "undefined")
         {
            StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,this.m_itemName,"trade",_loc2_);
            TransactionManager.addTransaction(new TBlackMarketTradePart(this.m_item.code,_loc2_),true);
         }
         this.m_grid.updateCards();
         this.update();
      }
      
      protected function showToolTip(param1:MouseEvent) : void
      {
         this.m_itemTooltip = new BlackMarketTooltip(BlackMarketTradeSlot.PLACE,this.m_menuName);
         this.m_itemTooltip.x = param1.currentTarget.x + m_window.x + param1.currentTarget.width * 0.5;
         this.m_itemTooltip.y = param1.currentTarget.y + m_window.y;
         this.m_itemTooltip.mouseEnabled = false;
         this.m_itemTooltip.mouseChildren = false;
         m_window.addChild(this.m_itemTooltip);
      }
      
      protected function removeToolTip(param1:MouseEvent) : void
      {
         if(Boolean(this.m_itemTooltip) && m_window.contains(this.m_itemTooltip))
         {
            m_window.removeChild(this.m_itemTooltip);
            this.m_itemTooltip.destroy();
         }
         this.m_itemTooltip = null;
      }
      
      protected function onCloseClicked(param1:MouseEvent = null) : void
      {
         if(this.m_grid)
         {
            this.m_grid.dispose();
            this.m_grid = null;
         }
         this.dispose();
         close();
      }
      
      protected function dispose() : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         removeEventListener(BlackMarketTradeSlot.BLACKMARKET_PART_PURCHASE,this.onSlotPurchase);
         m_window.tooltipBtn.removeEventListener(MouseEvent.CLICK,this.onHelpClicked);
         this.m_scrapIconLoader.destroy();
         this.m_itemIconLoader.destroy();
         this.m_placeButton.dispose();
         this.m_scrapIconLoader = null;
         this.m_itemIconLoader = null;
      }
   }
}

