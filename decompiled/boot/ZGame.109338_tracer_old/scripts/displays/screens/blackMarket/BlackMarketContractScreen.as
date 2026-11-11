package displays.screens.blackMarket
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.BlackMarketManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.BlackMarketTooltip;
   import events.MarketEvent;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BlackMarketContractScreen extends ZGamePopUp
   {
      
      public static const BLACKMARKET_CONTRACT:String = "blackmarket_contract";
      
      public static const BLACKMARKET_CLOSEDIALOG:String = "blackmarket_close";
      
      public static const BLACKMARKET_COUNTER:String = "blackmarket";
      
      public static const SCRAPCODE:String = "SC01";
      
      public static const BUILDINGCODE:String = "R99";
      
      protected var m_xml:XML;
      
      protected var m_item:Object;
      
      protected var m_itemName:String;
      
      protected var m_grid:BlackMarketContractGrid = null;
      
      protected var m_resource:SWFResource = null;
      
      private var m_helpActive:Boolean;
      
      protected var m_scrapIconLoader:ImageLoader;
      
      private var m_itemTooltip:BlackMarketTooltip = null;
      
      public function BlackMarketContractScreen(param1:IEntity, param2:String, param3:String)
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/PU_BlackMarket.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         var _loc2_:Class = param1.getAssetClass("dialog");
         m_window = new _loc2_();
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         this.m_scrapIconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(BlackMarketTradeScreen.SCRAP_ICON_PATH),m_window.icon_mc);
         addEventListener(BLACKMARKET_CONTRACT,this.onContractSlotPurchase,false,0,true);
         addEventListener(BLACKMARKET_CLOSEDIALOG,this.onCloseClicked,false,0,true);
         this.createGrid();
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked,false,0,true);
         this.initDialog();
         addChild(m_window);
         StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,"UI");
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","BlackMarket"));
         TextFieldUtil.compactTextField(m_window.subtitle_tf,ZGameUtils.ZlocT("Dialogs","BlackMarket_Building_Select"));
         TextFieldUtil.compactTextField(m_window.hints_mc.hint1_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketContract_Hint1Text"));
         TextFieldUtil.compactTextField(m_window.hints_mc.hint2_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketContract_Hint2Text"));
         TextFieldUtil.compactTextField(m_window.hints_mc.hint3_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketContract_Hint3Text"));
         var _loc1_:int = Math.floor(Math.random() * 9) + 1;
         TextFieldUtil.compactTextField(m_window.character_tf,ZGameUtils.ZlocT("Dialogs","BlackMarketContrack_Dialoge" + _loc1_ + "Text"));
         m_window.tooltipBtn.addEventListener(MouseEvent.CLICK,this.onHelpClicked,false,0,true);
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(SCRAPCODE,GameItem) as GameItem;
         m_window.scrapCount_tf.text = ZGlobal.player.getNumberOfInventoryItems(SCRAPCODE).toString() + " / " + _loc2_.inventoryCap;
         this.hideHelp();
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
         removeEventListener(BLACKMARKET_CONTRACT,this.onContractSlotPurchase);
         m_window.tooltipBtn.removeEventListener(MouseEvent.CLICK,this.onHelpClicked);
         this.m_scrapIconLoader.destroy();
         this.m_scrapIconLoader = null;
      }
      
      protected function createGrid() : void
      {
         var _loc1_:Object = BlackMarketManager.instance.blackMarketData;
         this.m_grid = new BlackMarketContractGrid(m_window.grid_mc,this.m_resource,this,BlackMarketDataHelper.instance.getItemList(_loc1_)) as BlackMarketContractGrid;
      }
      
      protected function onContractSlotPurchase(param1:WorldEvent) : void
      {
         var _loc2_:Object = param1.eventData as Object;
         var _loc3_:Array = _loc2_.arr;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc2_.code,GameItem) as GameItem;
         this.removeParts(_loc3_);
         dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONTRACT,_loc4_.name,MarketEvent.SOURCE_NONE));
         StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),"contract");
         this.onCloseClicked();
      }
      
      protected function showToolTip(param1:MouseEvent) : void
      {
         this.m_itemTooltip = new BlackMarketTooltip(BlackMarketTradeSlot.SCRAP);
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
      
      protected function removeParts(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:uint = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = param1[_loc3_] as Object;
            ZGlobal.player.removeInventoryItem(_loc2_.code,_loc2_.count);
            _loc3_++;
         }
      }
   }
}

