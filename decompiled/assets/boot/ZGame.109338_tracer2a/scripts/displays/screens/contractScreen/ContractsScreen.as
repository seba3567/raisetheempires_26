package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.ResourceDispatcher;
   import displays.popups.zgamepopup.ZGamePopUp;
   import entity.GameDataComponent;
   import events.ExperienceUpdatedEvent;
   import events.MarketEvent;
   import events.ResourceUpdatedEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class ContractsScreen extends ZGamePopUp
   {
      
      protected var m_entity:IEntity = null;
      
      protected var m_type:String = null;
      
      protected var m_subType:String = null;
      
      protected var m_resource:SWFResource = null;
      
      protected var m_grid:ContractGrid = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function ContractsScreen(param1:IEntity, param2:String, param3:String, param4:String)
      {
         this.m_entity = param1;
         this.m_type = param2;
         this.m_subType = param3;
         super(ZGlobal.getAssetURL(param4));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CONTRACT_MARKET_CONTINUE));
         var _loc2_:Class = param1.getAssetClass("dialog");
         m_window = new _loc2_();
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         addChild(m_window);
         initDialog();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated,false,0,true);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked,false,0,true);
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         addEventListener(ContractSlot.CONTRACT_SLOT_PURCHASE,this.onContractSlotPurchase,false,0,true);
         var _loc3_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         TextFieldUtil.compactTextField(m_window.title_tf,_loc3_.gameData.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(m_window.subtitle_tf,_loc3_.gameData.getSubtitle());
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.COINS,this.onResourcesUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.OIL,this.onResourcesUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.WOOD,this.onResourcesUpdated,false,0,true);
         var _loc4_:Array = WorldResourceManager.instance.rareCompares;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            ResourceDispatcher.instance.addEventListener(WorldResourceManager.instance.resourceFromRareResource(_loc4_[_loc5_]),this.onResourcesUpdated,false,0,true);
            _loc5_++;
         }
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_grid)
         {
            this.m_grid.dispose();
            this.m_grid = null;
         }
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         removeEventListener(ContractSlot.CONTRACT_SLOT_PURCHASE,this.onContractSlotPurchase);
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.COINS,this.onResourcesUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.OIL,this.onResourcesUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.WOOD,this.onResourcesUpdated);
         var _loc1_:Array = WorldResourceManager.instance.rareCompares;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            ResourceDispatcher.instance.removeEventListener(WorldResourceManager.instance.resourceFromRareResource(_loc1_[_loc2_]),this.onResourcesUpdated);
            _loc2_++;
         }
         super.deinitDialog();
      }
      
      private function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.m_grid.updateCards();
      }
      
      protected function onContractSlotPurchase(param1:WorldEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc2_:GameItem = param1.eventData as GameItem;
         if(_loc2_)
         {
            _loc3_ = false;
            _loc4_ = false;
            if(_loc2_.usesCashOnly())
            {
               _loc3_ = ZGlobal.player.canBuyCash(_loc2_.cash,true);
               _loc4_ = !_loc3_;
            }
            else
            {
               _loc3_ = ZGlobal.player.canBuy(_loc2_,true);
            }
            if(_loc3_)
            {
               dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONTRACT,_loc2_.name,MarketEvent.SOURCE_NONE));
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CONTRACT_MARKET_BUY_CONTINUE));
               WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ITEM_PURCHASED,_loc2_.code));
               this.onCloseClicked();
            }
            else if(_loc4_)
            {
               this.onCloseClicked();
            }
         }
      }
      
      protected function onCloseClicked(param1:MouseEvent = null) : void
      {
         close();
      }
      
      protected function onResourcesUpdated(param1:ResourceUpdatedEvent) : void
      {
         if(this.m_grid)
         {
            this.m_grid.updateCards();
         }
      }
   }
}

