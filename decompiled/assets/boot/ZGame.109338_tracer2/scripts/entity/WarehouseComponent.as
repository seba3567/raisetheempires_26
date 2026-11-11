package entity
{
   import Engine.Managers.StatsManager;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.states.FSMComponent;
   import core.gameobjects.GameItem;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class WarehouseComponent extends EntityComponent
   {
      
      public static const EVENT_WAREHOUSE_ADD:String = "warehouseAdd";
      
      public static const EVENT_WAREHOUSE_REMOVE:String = "warehouseRemove";
      
      public static const EVENT_WAREHOUSE_UPGRADE:String = "warehouseUpgrade";
      
      private var m_items:Object = {};
      
      private var m_limit:int;
      
      private var m_tier:int = 1;
      
      private var m_itemCount:int = 0;
      
      private var m_type:String;
      
      private var m_gameItem:GameItem;
      
      public function WarehouseComponent(param1:EntityInit, param2:Array = null)
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:* = undefined;
         super();
         this.m_gameItem = param1.m_item as GameItem;
         var _loc3_:Object = param1.m_object;
         if(_loc3_)
         {
            this.m_limit = param1.m_object.limit != null ? int(param1.m_object.limit) : 0;
            this.m_tier = param1.m_object.tier != null ? int(param1.m_object.tier) : 1;
            _loc4_ = param1.m_object.items;
            if(_loc4_ == null)
            {
               _loc4_ = {};
            }
            for(_loc6_ in _loc4_)
            {
               _loc5_ = int(_loc4_[_loc6_]);
               this.modifyUnits(_loc6_,_loc5_);
               Logger.print(this,"JMR: i: " + _loc6_ + ", m_items[" + _loc6_ + "]: " + this.m_items[_loc6_]);
            }
         }
         this.updateLimitByTier();
      }
      
      public static function getWarehouseComponent(param1:IEntity) : WarehouseComponent
      {
         return param1.lookupComponentByType(WarehouseComponent) as WarehouseComponent;
      }
      
      public function remove(param1:String) : Boolean
      {
         return this.modifyUnits(param1,-1);
      }
      
      public function acceptsUnits() : Boolean
      {
         var _loc1_:FSMComponent = owner.lookupComponentByType(FSMComponent) as FSMComponent;
         if(!(_loc1_.stateMachine as BehaviorStateMachine).isCurrentStateBuilt())
         {
            return false;
         }
         return true;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(EVENT_WAREHOUSE_ADD,this.onItemAdded);
         owner.eventDispatcher.addEventListener(EVENT_WAREHOUSE_REMOVE,this.onItemRemoved);
         owner.eventDispatcher.addEventListener(EVENT_WAREHOUSE_UPGRADE,this.onUpgraded);
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         this.m_type = _loc1_.gameData.warehouseType;
         WarehouseExperimentManager.instance.registerWarehouse(owner,this);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(EVENT_WAREHOUSE_ADD,this.onItemAdded);
         owner.eventDispatcher.removeEventListener(EVENT_WAREHOUSE_REMOVE,this.onItemRemoved);
         owner.eventDispatcher.removeEventListener(EVENT_WAREHOUSE_UPGRADE,this.onUpgraded);
         WarehouseExperimentManager.instance.unregisterWarehouse(owner);
      }
      
      private function onItemAdded(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         _loc2_ = param1.eventData.itemCode;
         Logger.print(this,"JMR, onItemAdded item: " + _loc2_);
         if(!this.atLimit())
         {
            if(this.modifyUnits(_loc2_,1))
            {
               StatsManager.count("depot",this.m_type,"add");
               Logger.print(this,"JMR: item added: " + _loc2_);
            }
         }
         else
         {
            Logger.print(this,"JMR: item not added: " + _loc2_);
         }
         Logger.print(this,"JMR: m_items[itemCode]: " + this.m_items[_loc2_]);
      }
      
      private function onItemRemoved(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:GameDataComponent = GameDataComponent(IEntity(param1.eventData.entity).lookupComponentByType(GameDataComponent));
         _loc2_ = _loc3_.gameData.code;
         Logger.print(this,"JMR, onItemRemoved item" + _loc2_);
         if(this.modifyUnits(_loc2_,-1))
         {
            StatsManager.count("depot",this.m_type,"remove");
            Logger.print(this,"JMR: m_items[itemCode]: " + this.m_items[_loc2_]);
         }
         else
         {
            Logger.print(this,"JMR: no items to decrement");
         }
      }
      
      private function modifyUnits(param1:String, param2:int) : Boolean
      {
         if(this.m_items[param1] == null)
         {
            this.m_items[param1] = 0;
         }
         var _loc3_:int = this.m_items[param1] + param2;
         if(_loc3_ >= 0)
         {
            WarehouseUnitManager.instance.modifyUnits(param1,param2);
            this.m_items[param1] = _loc3_;
            this.m_itemCount += param2;
            return true;
         }
         return false;
      }
      
      public function upgradeBycyber() : void
      {
         var _loc1_:WorldEvent = null;
         if(this.m_tier < this.numTiers)
         {
            this.onUpgraded(_loc1_);
         }
      }
      
      private function onUpgraded(param1:WorldEvent) : void
      {
         if(this.m_tier < this.numTiers)
         {
            ++this.m_tier;
            StatsManager.count("depot",this.m_type,"upgrade","tier" + this.m_tier);
            this.updateLimitByTier();
         }
      }
      
      private function updateLimitByTier() : void
      {
         this.m_limit = this.getCapacityAtTier(this.m_tier);
      }
      
      public function getCapacityAtTier(param1:int) : int
      {
         return int(this.m_gameItem.warehouseTiersAsArray[param1 - 1]);
      }
      
      public function get numTiers() : int
      {
         return this.m_gameItem.warehouseTiersAsArray.length;
      }
      
      public function get items() : Object
      {
         return this.m_items;
      }
      
      public function get tier() : int
      {
         return this.m_tier;
      }
      
      public function get spaceReport() : String
      {
         return ZGameUtils.ZlocT("Main","Capacity_ratio",{
            "current":this.m_itemCount,
            "total":this.m_limit
         });
      }
      
      public function getItemCount(param1:String) : int
      {
         return this.m_items[param1] != null ? int(this.m_items[param1]) : 0;
      }
      
      public function atMaxTier() : Boolean
      {
         return this.m_tier >= this.numTiers;
      }
      
      public function geTier() : int
      {
         return this.m_tier;
      }
      
      public function atLimit() : Boolean
      {
         return this.m_itemCount >= this.m_limit;
      }
      
      public function get totalItemCount() : int
      {
         return this.m_itemCount;
      }
      
      public function get slotsLeft() : int
      {
         return this.m_limit - this.m_itemCount;
      }
      
      public function get slotsLeftToUnlock() : int
      {
         return this.getCapacityAtTier(this.numTiers) - this.m_limit;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get parentItem() : GameItem
      {
         return this.m_gameItem;
      }
   }
}

