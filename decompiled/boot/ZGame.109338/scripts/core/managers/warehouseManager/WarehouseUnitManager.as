package core.managers.warehouseManager
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   
   public class WarehouseUnitManager
   {
      
      public static var instance:WarehouseUnitManager = new WarehouseUnitManager();
      
      private var m_allUnits:Dictionary = null;
      
      private var m_heldUnits:Dictionary = null;
      
      public function WarehouseUnitManager()
      {
         super();
         this.m_allUnits = new Dictionary();
         this.m_heldUnits = new Dictionary();
      }
      
      public function getAvailableUnits() : Dictionary
      {
         var _loc2_:String = null;
         var _loc1_:Dictionary = new Dictionary();
         for(_loc2_ in this.m_allUnits)
         {
            _loc1_[_loc2_] = this.getNumAvailable(_loc2_);
         }
         return _loc1_;
      }
      
      public function numUnits(param1:String) : int
      {
         return this.m_allUnits[param1];
      }
      
      public function modifyUnits(param1:String, param2:int) : void
      {
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(!this.m_allUnits[param1])
            {
               this.m_allUnits[param1] = 0;
            }
            this.m_allUnits[param1] += param2;
         }
      }
      
      public function remove(param1:String) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:WarehouseComponent = null;
         var _loc4_:int = 0;
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            _loc2_ = this.getAllWarehouseComponents();
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = _loc3_.getItemCount(param1);
               if(_loc4_ > 0)
               {
                  if(_loc3_.remove(param1))
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public function isSlotInCombat(param1:IEntity, param2:int, param3:String) : Boolean
      {
         var _loc6_:WarehouseComponent = null;
         var _loc7_:int = 0;
         var _loc4_:int = this.m_heldUnits[param3] ? int(this.m_heldUnits[param3]) : 0;
         var _loc5_:Array = this.getAllWarehouseComponents();
         for each(_loc6_ in _loc5_)
         {
            _loc7_ = _loc6_.getItemCount(param3);
            if(_loc6_.owner == param1)
            {
               return param2 < _loc4_;
            }
            _loc4_ -= _loc7_;
            if(_loc4_ <= 0)
            {
               break;
            }
         }
         return false;
      }
      
      public function getAllWarehouseComponents() : Array
      {
         var _loc3_:IEntity = null;
         var _loc4_:WarehouseComponent = null;
         var _loc1_:Array = new Array();
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType(GameItem.TYPE_BUILDING,"military");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.lookupComponentByType(WarehouseComponent) as WarehouseComponent;
            if(_loc4_)
            {
               _loc1_.push(_loc4_);
            }
         }
         _loc1_.sort(this.warehouseSorter);
         return _loc1_;
      }
      
      private function warehouseSorter(param1:WarehouseComponent, param2:WarehouseComponent) : int
      {
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(param1.owner);
         var _loc4_:GameDataComponent = GameDataComponent.getGameDataComponent(param2.owner);
         var _loc5_:int = _loc3_.id;
         var _loc6_:int = _loc4_.id;
         if(_loc5_ > _loc6_)
         {
            return 1;
         }
         return -1;
      }
      
      public function clearHeldUnits() : void
      {
         this.m_heldUnits = new Dictionary();
      }
      
      public function clearAllUnits() : void
      {
         this.m_allUnits = new Dictionary();
      }
      
      public function holdUnit(param1:String, param2:Boolean) : Boolean
      {
         if(param2 || this.getNumAvailable(param1) > 0)
         {
            if(!this.m_heldUnits[param1])
            {
               this.m_heldUnits[param1] = 0;
            }
            this.m_heldUnits[param1] += 1;
            return true;
         }
         return false;
      }
      
      public function releaseUnit(param1:String) : void
      {
         this.m_heldUnits[param1] = this.m_heldUnits[param1] - 1;
      }
      
      private function getNumAvailable(param1:String) : int
      {
         var _loc2_:int = int(this.m_allUnits[param1]);
         if(this.m_heldUnits[param1])
         {
            _loc2_ -= this.m_heldUnits[param1];
         }
         return _loc2_;
      }
   }
}

