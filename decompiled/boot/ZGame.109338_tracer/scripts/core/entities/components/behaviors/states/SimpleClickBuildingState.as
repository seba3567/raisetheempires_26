package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.managers.warehouseManager.WarehouseHoverManager;
   import displays.popups.CancelPlacementPopup;
   import events.MarketEvent;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class SimpleClickBuildingState extends SimpleClickState
   {
      
      private var m_showWarehouseDialog:Boolean = false;
      
      public function SimpleClickBuildingState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function handleClick() : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:GMObjectPlace = null;
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         this.m_showWarehouseDialog = false;
         if(WarehouseExperimentManager.instance.masterOn && _loc1_.makesDepotStorableItems)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
            WarehouseHoverManager.instance.source = stateMachine.propertyBag as IEntity;
            this.m_showWarehouseDialog = true;
            _loc3_ = new GMObjectPlace(_loc2_.name,MarketEvent.SOURCE_BUILDING,true);
            _loc3_.showInventoryPopup = false;
            GameModeManager.instance.addGameMode(_loc3_);
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlaced);
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onObjectCanceled);
         }
         else
         {
            this.continueStateTransition();
         }
      }
      
      override protected function shouldSendSetStateTransaction() : Boolean
      {
         if(WarehouseExperimentManager.instance.masterOn)
         {
            if(Boolean(WarehouseHoverManager.instance.cachedState) && Boolean(WarehouseHoverManager.instance.cachedState.validWarehousePlacement))
            {
               return false;
            }
         }
         return super.shouldSendSetStateTransaction();
      }
      
      protected function onObjectPlaced(param1:WorldEvent) : void
      {
         Logger.print(this,"JMR onObjectPlaced");
         this.removePlacementListeners();
         this.continueStateTransition();
      }
      
      private function onObjectCanceled(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:String = null;
         Logger.print(this,"JMR onObjectCanceled");
         this.removePlacementListeners();
         if(this.m_showWarehouseDialog)
         {
            _loc2_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            if(WarehouseExperimentManager.atRequiredLevelForType(_loc2_.referenceSubtype) && WarehouseExperimentManager.instance.warehouseExperimentOnForType(_loc2_.referenceSubtype))
            {
               CancelPlacementPopup.display("CancelUnitPlacementPopupWarehouseDescription",true,ZGlobal.gameSettings.getImageByName(WarehouseExperimentManager.getWarehouseItemByType(_loc2_.referenceSubtype).name,"icon"),_loc2_.referenceSubtype,_loc2_);
            }
            else
            {
               CancelPlacementPopup.display("CancelUnitPlacementPopupNoWarehouseDescription",false,ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon"),_loc2_.referenceSubtype,_loc2_);
            }
         }
      }
      
      private function continueStateTransition() : void
      {
         Logger.print(this,"JMR continueStateTransition");
         clicked();
      }
      
      private function removePlacementListeners() : void
      {
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlaced);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onObjectCanceled);
      }
   }
}

