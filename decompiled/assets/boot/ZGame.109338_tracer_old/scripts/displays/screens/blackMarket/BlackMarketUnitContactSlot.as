package displays.screens.blackMarket
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldObjectManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class BlackMarketUnitContactSlot extends GridSlot
   {
      
      protected var m_item:Object = null;
      
      protected var m_gameItemForItem:GameItem;
      
      protected var m_imageLoaders:Array = null;
      
      protected var requiresArr:Array;
      
      protected var m_buildButton:ZGameButton;
      
      protected var m_buyButton:ZGameButton;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var unit:UnitItem = null;
      
      private var m_itemTooltip:ItemTooltip = null;
      
      protected var m_listener:EventDispatcher = null;
      
      public function BlackMarketUnitContactSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:Object)
      {
         this.m_item = param7;
         super(param1,param2,param3);
         slot.x = param5 * slot.sizer_mc.width;
         slot.y = param6 * slot.sizer_mc.height;
         this.m_listener = param4;
         this.m_gameItemForItem = ZGlobal.gameSettings.getItemByCode(this.m_item.code,GameItem) as GameItem;
         if(this.m_gameItemForItem.tooltipType == GameItem.UNIT_TOOLTIP)
         {
            this.m_gameItemForItem = ZGlobal.gameSettings.getItemByCode(this.m_item.code,UnitItem) as UnitItem;
         }
         this.populateCard();
         this.setButtons();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("ResourceCard");
         return new _loc2_();
      }
      
      protected function populateCard() : void
      {
         this.m_imageLoaders = new Array();
         var _loc1_:XML = ZGlobal.gameSettings.getItemXMLByCode(this.m_item.code);
         var _loc2_:String = ZGlobal.gameSettings.getImageByName(_loc1_.@name,"icon");
         this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_,slot.icon));
         var _loc3_:String = _loc1_.@name;
         TextFieldUtil.compactTextField(slot.itemName_tf,this.m_gameItemForItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.icon.addEventListener(MouseEvent.MOUSE_OVER,this.showToolTip,false,0,true);
         slot.icon.addEventListener(MouseEvent.MOUSE_OUT,this.removeToolTip,false,0,true);
      }
      
      protected function showToolTip(param1:MouseEvent, param2:String = null) : void
      {
         if(param2 == null)
         {
            param2 = param1.currentTarget.name;
         }
         this.m_itemTooltip = new ItemTooltip(this.m_gameItemForItem.tooltipType,this.m_gameItemForItem,ItemTooltip.SOURCE_INVENTORY);
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
      
      protected function setButtons() : void
      {
         var _loc1_:Dictionary = null;
         var _loc2_:Object = null;
         var _loc3_:GameDataComponent = null;
         var _loc4_:BuildingFSMComponent = null;
         this.m_buyButton = new ZGameButton(slot.buy_bt,this.onBuyClicked);
         this.m_buyButton.text = ZGameUtils.ZlocT("Dialogs","BlackMarketTradeButtonText");
         this.m_buildButton = new ZGameButton(slot.build_bt,this.onBuildClicked);
         this.m_buildButton.text = ZGameUtils.ZlocT("Dialogs","Place");
         if(this.m_gameItemForItem.type != "undefined" && String(this.m_item.type).toLowerCase() != "building")
         {
            this.m_buildButton.hide();
         }
         else
         {
            _loc1_ = WorldObjectManager.instance.getObjectsBySubType(this.m_gameItemForItem.type,this.m_gameItemForItem.subType);
            for each(_loc2_ in _loc1_)
            {
               _loc3_ = GameDataComponent(_loc2_.lookupComponentByType(GameDataComponent));
               if(Boolean(_loc3_) && Boolean(_loc3_.gameData))
               {
                  _loc4_ = BuildingFSMComponent(_loc2_.lookupComponentByType(BuildingFSMComponent));
                  if(_loc3_.gameData.code == this.m_item.code)
                  {
                     this.m_buildButton.disable();
                  }
                  if(Boolean(_loc3_.gameData.code == this.m_item.code) && Boolean(_loc4_) && _loc4_.isBuilt)
                  {
                     this.m_buyButton.disable();
                  }
               }
            }
            if(ZGlobal.player.getNumberOfInventoryItems(this.m_item.code) < 1)
            {
               this.m_buildButton.disable();
            }
         }
      }
      
      protected function onBuyClicked(param1:MouseEvent) : void
      {
         StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,this.m_gameItemForItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         PopupManager.instance.push(new BlackMarketTradeScreen(this.m_item,this.m_listener));
      }
      
      protected function onBuildClicked(param1:MouseEvent) : void
      {
         StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,"placebutton");
         this.m_listener.dispatchEvent(new MouseEvent(BlackMarketContractScreen.BLACKMARKET_CLOSEDIALOG));
         if(ZGlobal.player.getNumberOfInventoryItems(this.m_item.code) >= 1)
         {
            GameModeManager.instance.addGameMode(new GMObjectPlace(this.m_gameItemForItem.name,MarketEvent.SOURCE_INVENTORY,true));
         }
         else
         {
            GameModeManager.instance.addGameMode(new GMObjectPlace(this.m_gameItemForItem.name,MarketEvent.SOURCE_BUILDING,false,null));
         }
      }
      
      override public function dispose() : void
      {
         this.disposeImageLoaders();
         this.m_buyButton.dispose();
         this.m_buildButton.dispose();
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

