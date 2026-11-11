package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import dispatchers.UIDispatcher;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.screens.contractScreen.ContractsScreen;
   import displays.screens.contractScreen.MasteryUnitContractGrid;
   import displays.screens.contractScreen.MasteryUnitContractSlot;
   import events.MarketEvent;
   import events.ResourceUpdatedEvent;
   import flash.events.Event;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MasteryFactoryContractsScreen extends ContractsScreen
   {
      
      public function MasteryFactoryContractsScreen(param1:IEntity, param2:String, param3:String)
      {
         super(param1,param2,param3,"assets/displays/screens/PU_MasteryContract.swf");
         m_origOffsetX = 0;
         m_origOffsetY = 60;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:int = ZGlobal.player.getNumberOfInventoryItems("VTK") ? ZGlobal.player.getNumberOfInventoryItems("VTK") : 0;
         m_window.tokenTotal_mc.value_tf.text = _loc2_.toString();
         m_window.errorMsg_tf.visible = false;
         this.createGrid();
         if(m_grid.numCards <= 0)
         {
            TextFieldUtil.processTextField(m_window.errorMsg_tf,ZGameUtils.ZlocT("Dialogs","MasteryFactory_NoUnitsError"));
            m_window.errorMsg_tf.visible = true;
         }
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CONTRACT_SCREEN_LOADED));
         }
         UIDispatcher.instance.addEventListener(MasteryUnitContractSlot.BUY_MASTERY_UNIT,this.onBuyMasteryUnit,false,0,true);
      }
      
      private function onTokenCountUpdate(param1:Event) : void
      {
         var _loc2_:int = ZGlobal.player.getNumberOfInventoryItems("VTK") ? ZGlobal.player.getNumberOfInventoryItems("VTK") : 0;
         m_window.tokenTotal_mc.value_tf.text = _loc2_.toString();
      }
      
      protected function createGrid() : void
      {
         m_grid = new MasteryUnitContractGrid(m_window.grid_mc,m_resource,this,m_entity,m_type,m_subType) as MasteryUnitContractGrid;
      }
      
      override protected function onResourcesUpdated(param1:ResourceUpdatedEvent) : void
      {
         super.onResourcesUpdated(param1);
      }
      
      override protected function onContractSlotPurchase(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = param1.eventData as GameItem;
         var _loc3_:int = ZGlobal.player.getNumberOfInventoryItems("VTK") ? ZGlobal.player.getNumberOfInventoryItems("VTK") : 0;
         if(Boolean(_loc2_) && _loc3_ - _loc2_.masteryTokenCost >= 0)
         {
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY_WITH_MASTERY_TOKENS,MarketEvent.CONTRACT,_loc2_.name,MarketEvent.SOURCE_NONE));
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ITEM_PURCHASED,_loc2_.code));
            this.doPurchaseFeed(param1);
         }
         this.close();
      }
      
      protected function onBuyMasteryUnit(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         if(ZGlobal.player.canBuyCash(param1.eventData.unitItem.cash,true))
         {
            if(param1.eventData.unitItem.placeable)
            {
               _loc2_ = {"screen":"campaign_mastery"};
               ZGlobal.player.buyPremiumGameItem(param1.eventData.unitItem,true,true,_loc2_,this.onBuyMasteryUnitConfirmed);
            }
         }
      }
      
      private function onBuyMasteryUnitConfirmed(param1:Object = null) : void
      {
         this.close();
      }
      
      private function doPurchaseFeed(param1:WorldEvent) : void
      {
         var _loc3_:FeedPopup = null;
         var _loc4_:Object = null;
         var _loc2_:GameItem = param1.eventData as GameItem;
         _loc3_ = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","gold_villain_unit_complete",{"unitname":_loc2_.getSentenceNameLocalizationObject("singular")}),ZGameUtils.ZlocT("FeedPopups","gold_villain_unit_complete_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onPurchaseFeedDialogClose,ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon"));
         _loc4_ = new Object();
         _loc4_.name = _loc2_.name;
         _loc4_.itemCode = _loc2_.code;
         _loc3_.userData = _loc4_;
         PopupManager.instance.push(_loc3_);
      }
      
      private function onPurchaseFeedDialogClose(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "gold_villain_unit_complete";
            ViralsManager.instance.sendFeed(_loc2_,{
               "itemCode":param1.userData.itemCode,
               "ITEMTOKitem":param1.userData.name,
               "IMGCODE":param1.userData.itemCode
            });
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         UIDispatcher.instance.removeEventListener(MasteryUnitContractSlot.BUY_MASTERY_UNIT,this.onBuyMasteryUnit);
         super.close();
      }
   }
}

