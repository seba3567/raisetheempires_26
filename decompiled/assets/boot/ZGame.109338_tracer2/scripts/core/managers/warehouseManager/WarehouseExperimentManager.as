package core.managers.warehouseManager
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.tutorialManager.TutorialHighlighter;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class WarehouseExperimentManager
   {
      
      public static var instance:WarehouseExperimentManager = new WarehouseExperimentManager();
      
      private var m_masterOn:Boolean = false;
      
      private var warehouses:Dictionary = new Dictionary();
      
      public var m_guideArrows:Array = [];
      
      public function WarehouseExperimentManager()
      {
         super();
      }
      
      public static function getWarehouseItemByType(param1:String) : GameItem
      {
         var _loc2_:GameItem = null;
         var _loc3_:String = "Warehouse Air 01";
         if(param1 == "air")
         {
            _loc3_ = "Warehouse Air 01";
         }
         else if(param1 == "navy")
         {
            _loc3_ = "Warehouse Navy 01";
         }
         else if(param1 == "army")
         {
            _loc3_ = "Warehouse Army 01";
         }
         return ZGlobal.gameSettings.getItemByName(_loc3_,GameItem) as GameItem;
      }
      
      public static function atRequiredLevelForType(param1:String) : Boolean
      {
         return ZGlobal.player.level >= getWarehouseItemByType(param1).requiredLevel;
      }
      
      public function initExperimentVars() : void
      {
      }
      
      public function get masterOn() : Boolean
      {
         return this.m_masterOn;
      }
      
      public function warehouseExperimentOnForType(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if((param1 == "air" || param1 == "navy" || param1 == "army") && this.m_masterOn)
         {
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function registerWarehouse(param1:IEntity, param2:WarehouseComponent) : void
      {
         this.m_masterOn = true;
         this.warehouses[param1] = param2;
      }
      
      public function unregisterWarehouse(param1:IEntity) : void
      {
         delete this.warehouses[param1];
      }
      
      public function addArrowToAvailableWarehouseIfValid(param1:IEntity) : void
      {
         var _loc2_:WarehouseComponent = null;
         var _loc3_:IEntity = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:* = undefined;
         var _loc7_:GameDataComponent = null;
         var _loc8_:TutorialHighlighter = null;
         var _loc9_:IsoSpriteRenderer = null;
         var _loc10_:Point = null;
         var _loc4_:int = 0;
         _loc7_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         this.clearArrows();
         if(_loc7_.gameData.isUnit() && this.warehouseExperimentOnForType(_loc7_.gameData.subType) && WarehouseHoverManager.instance.objectValidForStorage(param1))
         {
            for(_loc6_ in this.warehouses)
            {
               _loc3_ = _loc6_ as IEntity;
               _loc2_ = this.warehouses[_loc3_];
               if(_loc2_.type == _loc7_.gameData.subType && !_loc2_.atLimit() && _loc2_.acceptsUnits())
               {
                  _loc5_ = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
                  _loc9_ = _loc3_.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
                  _loc10_ = new Point();
                  _loc8_ = new TutorialHighlighter();
                  _loc8_.setMovieClip(_loc9_.displayObject as MovieClip,true,true,false,_loc10_);
                  this.m_guideArrows.push(_loc8_);
               }
            }
         }
      }
      
      public function clearArrows() : void
      {
         var _loc1_:TutorialHighlighter = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this.m_guideArrows.length)
         {
            _loc1_ = this.m_guideArrows[_loc2_];
            _loc1_.dispose();
            _loc2_++;
         }
         this.m_guideArrows = [];
      }
   }
}

