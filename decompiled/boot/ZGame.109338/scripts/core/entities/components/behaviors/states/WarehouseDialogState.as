package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gamemode.GMObjectPlace;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.ui.PlayerFeedbackManager;
   import displays.screens.warehouseScreen.WarehouseUnitScreen;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import events.CloseEvent;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import transactions.TUnitPlaceFromWarehouse;
   import transactions.TWarehouseAdd;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class WarehouseDialogState extends DialogState
   {
      
      private var controllerTooltip:PropertyReference = new PropertyReference("@controller.toolTip");
      
      private var overlayIconNameProperty:PropertyReference = new PropertyReference("@Overlay.iconName");
      
      private var m_activeImageName:String = null;
      
      private var m_inactiveTooltip:String = null;
      
      private var m_actionTooltip:String = null;
      
      private var m_inactiveIconUrl:String = null;
      
      private var m_actionIconUrl:String = null;
      
      private var m_window:IWindow;
      
      public function WarehouseDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@activeImageType.toString().length > 0)
         {
            this.m_activeImageName = m_data.@activeImageType.toString();
         }
         if(m_data.@tooltip.toString().length > 0)
         {
            this.m_inactiveTooltip = m_data.@tooltip.toString();
         }
         if(m_data.@actionTooltip.toString().length > 0)
         {
            this.m_actionTooltip = m_data.@actionTooltip.toString();
         }
         if(m_data.@inactiveIcon.toString().length > 0)
         {
            this.m_inactiveIconUrl = m_data.@inactiveIcon.toString();
         }
         if(m_data.@actionIcon.toString().length > 0)
         {
            this.m_actionIconUrl = m_data.@actionIcon.toString();
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         if(this.isActive())
         {
         }
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverDefenseTower,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutDefenseTower,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(WarehouseComponent.EVENT_WAREHOUSE_ADD,this.onItemAdded);
         stateMachine.propertyBag.eventDispatcher.addEventListener(WarehouseComponent.EVENT_WAREHOUSE_REMOVE,this.onItemRemoved);
         stateMachine.propertyBag.eventDispatcher.addEventListener(WarehouseComponent.EVENT_WAREHOUSE_UPGRADE,this.onUpgraded);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:SWFResource = null;
         var _loc3_:EventDispatcher = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:IEntity = null;
         var _loc12_:GameItem = null;
         if(ZGlobal.isHome())
         {
            Logger.print(this,"JMR: about to show InventoryDialog");
            _loc12_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc10_ = _loc12_.warehouseType;
            Logger.print(this,"JMR: type: " + _loc10_);
            _loc11_ = IEntity(stateMachine.propertyBag);
            _loc3_ = EventDispatcher(stateMachine.propertyBag.eventDispatcher);
            this.m_window = new WarehouseUnitScreen(_loc3_,_loc10_,_loc11_,_loc12_);
            WindowManager.instance.push(this.m_window);
            Logger.print(this,"JMR: entity: " + (stateMachine.propertyBag as IEntity));
         }
         else
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackPVPAreaImmunityBlocked"),owner);
         }
      }
      
      private function onItemAdded(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1.eventData.item);
         GMObjectPlace.placeItem(_loc2_.gameData,param1.eventData.source);
         TransactionManager.addTransaction(new TWarehouseAdd(stateMachine.propertyBag as IEntity,param1.eventData.item,param1.eventData.itemCode,param1.eventData.source),true);
         if(param1.eventData.source != MarketEvent.SOURCE_BUILDING)
         {
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED_CLIENT,param1.eventData.itemCode));
         }
         else
         {
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED_CLIENT,"warehouse"));
         }
      }
      
      private function onItemRemoved(param1:WorldEvent) : void
      {
         TransactionManager.addTransaction(new TUnitPlaceFromWarehouse(param1.eventData.entity,param1.eventData.warehouseId));
      }
      
      private function onUpgraded(param1:WorldEvent) : void
      {
         stateMachine.storeReferenceData(param1.eventData.upgradeItem.name);
         clickNextState();
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(WarehouseComponent.EVENT_WAREHOUSE_ADD,this.onItemAdded);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(WarehouseComponent.EVENT_WAREHOUSE_REMOVE,this.onItemRemoved);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(WarehouseComponent.EVENT_WAREHOUSE_UPGRADE,this.onUpgraded);
      }
      
      override protected function get imageName() : String
      {
         if(this.isActive())
         {
            return this.m_activeImageName;
         }
         return super.imageName;
      }
      
      private function updateAnimation() : void
      {
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         setImage(_loc1_,this.imageName);
      }
      
      public function isActive() : Boolean
      {
         return true;
      }
      
      private function onMouseOverDefenseTower(param1:MouseEvent) : void
      {
         if(!ZGlobal.isHome())
         {
            return;
         }
         if(this.isActive())
         {
            return;
         }
      }
      
      private function onMouseOutDefenseTower(param1:MouseEvent) : void
      {
         if(!ZGlobal.isHome())
         {
            return;
         }
      }
   }
}

