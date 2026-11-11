package core.managers.warehouseManager
{
   import as3isolib.bounds.IBounds;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.WorldUnitComponent;
   import core.gamemode.helpers.PlacementProxy;
   import core.managers.BuildManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.geom.Point;
   import zlabs.entity.IEntity;
   import zlabs.utils.MathUtils;
   
   public class WarehouseHoverManager
   {
      
      public static var instance:WarehouseHoverManager = new WarehouseHoverManager();
      
      private var m_cachedState:Object;
      
      private var m_gameDataComponent:GameDataComponent;
      
      private var m_sourceId:int = -1;
      
      public function WarehouseHoverManager()
      {
         super();
      }
      
      public function update(param1:Boolean, param2:Pt, param3:Point, param4:PlacementProxy) : void
      {
         var _loc9_:IEntity = null;
         var _loc10_:GameDataComponent = null;
         var _loc11_:WarehouseComponent = null;
         var _loc5_:IBounds = param4.isoBounds();
         var _loc6_:IEntity = param4.getMapResource();
         this.m_gameDataComponent = GameDataComponent(_loc6_.lookupComponentByType(GameDataComponent));
         this.m_cachedState = {};
         this.m_cachedState.componentName = this.m_gameDataComponent.name;
         this.m_cachedState.itemName = this.m_gameDataComponent.gameData.name;
         this.m_cachedState.itemCode = this.m_gameDataComponent.gameData.code;
         this.m_cachedState.itemType = this.m_gameDataComponent.gameData.type;
         this.m_cachedState.gdc = this.m_gameDataComponent;
         var _loc7_:Array = new Array();
         BuildManager.instance.getObjectIDsOverlappingVolume(MathUtils.worldToTile(param2,ZGlobal.cellSize),new Point(_loc5_.width / ZGlobal.cellSize,_loc5_.length / ZGlobal.cellSize),_loc7_);
         this.m_cachedState.warehouseEntity = null;
         this.m_cachedState.validWarehousePlacement = false;
         this.m_cachedState.atLimit = false;
         this.m_cachedState.noAccept = false;
         this.m_cachedState.invalidUnit = false;
         var _loc8_:Boolean = this.objectValidForStorage(_loc6_);
         for each(_loc9_ in _loc7_)
         {
            _loc10_ = GameDataComponent.getGameDataComponent(_loc9_);
            if((Boolean(_loc10_)) && Boolean(_loc10_.gameData) && Boolean(this.m_gameDataComponent.gameData))
            {
               this.m_cachedState.validWarehousePlacement = _loc10_.gameData.warehouseType != "" && _loc10_.gameData.warehouseType == this.m_gameDataComponent.gameData.subType && this.m_gameDataComponent.gameData.isUnit();
               this.m_cachedState.targetType = _loc10_.gameData.warehouseType;
               this.m_cachedState.currentType = this.m_gameDataComponent.gameData.subType;
               if(this.m_cachedState.validWarehousePlacement)
               {
                  if(!_loc8_)
                  {
                     this.m_cachedState.validWarehousePlacement = false;
                     this.m_cachedState.invalidUnit = true;
                  }
                  else
                  {
                     _loc11_ = WarehouseComponent(_loc9_.lookupComponentByType(WarehouseComponent));
                     if(!_loc11_.acceptsUnits())
                     {
                        this.m_cachedState.validWarehousePlacement = false;
                        this.m_cachedState.noAccept = true;
                     }
                     else
                     {
                        if(_loc10_.id == this.sourceId || !_loc11_.atLimit())
                        {
                           this.m_cachedState.warehouseEntity = _loc9_;
                           this.m_cachedState.warehouseComponent = _loc11_;
                           break;
                        }
                        this.m_cachedState.validWarehousePlacement = false;
                        this.m_cachedState.atLimit = true;
                     }
                  }
               }
            }
         }
      }
      
      public function get cachedState() : Object
      {
         return this.m_cachedState;
      }
      
      public function set source(param1:IEntity) : void
      {
         var _loc2_:GameDataComponent = null;
         if(param1)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(param1);
            this.m_sourceId = _loc2_.id;
         }
         else
         {
            this.m_sourceId = -1;
         }
      }
      
      public function get sourceId() : int
      {
         return this.m_sourceId;
      }
      
      public function clearCache() : void
      {
         this.m_cachedState = {};
         this.m_gameDataComponent = null;
         this.m_sourceId = -1;
      }
      
      public function objectValidForStorage(param1:IEntity) : Boolean
      {
         var _loc2_:WorldUnitComponent = param1.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
         if(_loc2_)
         {
            if(_loc2_.type != WorldUnitManager.UNIT_AVAILABLE)
            {
               return false;
            }
         }
         return true;
      }
   }
}

