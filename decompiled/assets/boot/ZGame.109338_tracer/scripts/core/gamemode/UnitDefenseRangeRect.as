package core.gamemode
{
   import as3isolib.display.IsoView;
   import as3isolib.display.primitive.IsoRectangle;
   import as3isolib.geom.Pt;
   import as3isolib.graphics.SolidColorFill;
   import as3isolib.graphics.Stroke;
   import core.ZGlobal;
   import core.entities.components.AreaImmuneComponent;
   import core.entities.components.PVPAreaImmuneMarkerComponent;
   import core.entities.components.ProtectableComponent;
   import core.managers.BuildManager;
   import core.managers.PVPManager;
   import entity.GameDataComponent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class UnitDefenseRangeRect extends IsoRectangle
   {
      
      private static var m_isoView:IsoView;
      
      private var m_originalBounds:Pt = null;
      
      private var m_color:int = 255;
      
      private var m_shouldOutline:Boolean = true;
      
      private var m_defenseRangeX:int;
      
      private var m_defenseRangeY:int;
      
      private var m_offsetX:int;
      
      private var m_offsetY:int;
      
      private var m_entity:IEntity;
      
      public function UnitDefenseRangeRect(param1:Pt, param2:int, param3:int, param4:IEntity)
      {
         super();
         this.m_defenseRangeX = param2;
         this.m_defenseRangeY = param3;
         this.m_entity = param4;
         renderAsOrphan = true;
         width = ZGlobal.cellSize * this.m_defenseRangeX;
         length = ZGlobal.cellSize * this.m_defenseRangeY;
         container.visible = true;
         this.m_originalBounds = new Pt(param1.x,param1.y);
         this.m_offsetX = Math.floor(this.m_originalBounds.x * 0.5) - Math.floor(width * 0.5);
         this.m_offsetY = Math.floor(this.m_originalBounds.y * 0.5) - Math.floor(length * 0.5);
         m_isoView.backgroundContainer.addChild(container);
         var _loc5_:GameDataComponent = GameDataComponent.getGameDataComponent(param4);
         if(_loc5_.gameData.type == "building")
         {
            this.m_color = PVPAreaImmuneMarkerComponent.AOE_COLOR;
         }
         this.setColor(this.m_color,this.m_shouldOutline);
      }
      
      public static function init(param1:IsoView) : void
      {
         m_isoView = param1;
      }
      
      public static function isUnit(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         return _loc2_.gameData.isUnit();
      }
      
      public static function isImmunityBuilding(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         return _loc2_.gameData.isAreaImmunityBuilding();
      }
      
      public function dispose() : void
      {
         var _loc1_:Pt = new Pt(this.x,this.y);
         PVPManager.instance.dispatchEvent(new WorldEvent(ProtectableComponent.DEFENSE_DEACTIVATED));
         PVPManager.instance.dispatchEvent(new WorldEvent(AreaImmuneComponent.AREA_IMMUNITY_DEACTIVATED));
         if(container.parent)
         {
            container.parent.removeChild(container);
         }
      }
      
      public function setPosition(param1:Vector3D) : void
      {
         var _loc2_:Pt = new Pt();
         _loc2_.x = param1.x + this.m_offsetX;
         _loc2_.y = param1.y + this.m_offsetY;
         if(isImmunityBuilding(this.m_entity))
         {
            PVPManager.instance.dispatchEvent(new WorldEvent(AreaImmuneComponent.AREA_IMMUNITY_DEACTIVATED));
            moveTo(_loc2_.x,_loc2_.y,0);
            this.dispatchObjectEvent(_loc2_,AreaImmuneComponent.AREA_IMMUNITY_ACTIVATED);
         }
         else
         {
            PVPManager.instance.dispatchEvent(new WorldEvent(ProtectableComponent.DEFENSE_DEACTIVATED));
            moveTo(_loc2_.x,_loc2_.y,0);
            this.dispatchObjectEvent(_loc2_,ProtectableComponent.DEFENSE_ACTIVATED);
         }
         render();
      }
      
      private function dispatchObjectEvent(param1:Pt, param2:String, param3:Object = null) : void
      {
         var _loc8_:String = null;
         var _loc9_:IEntity = null;
         var _loc10_:WorldEvent = null;
         var _loc4_:Point = new Point(this.m_defenseRangeX,this.m_defenseRangeY);
         var _loc5_:Pt = MathUtils.worldToTile(param1,ZGlobal.cellSize);
         var _loc6_:Point = MathUtils.convertPtToPoint(_loc5_);
         var _loc7_:Array = BuildManager.instance.getObjectsOverlappingVolume(_loc6_,_loc4_);
         for each(_loc8_ in _loc7_)
         {
            _loc9_ = Zlab.nameManager.lookup(_loc8_);
            if(_loc9_)
            {
               _loc10_ = new WorldEvent(param2,param3);
               _loc9_.eventDispatcher.dispatchEvent(_loc10_);
            }
         }
      }
      
      public function setColor(param1:uint, param2:Boolean) : void
      {
         this.m_color = param1;
         var _loc3_:SolidColorFill = new SolidColorFill(param1,0.25);
         fill = _loc3_;
         this.m_shouldOutline = param2;
         var _loc4_:Stroke = new Stroke(4,param1,param2 ? 0.5 : 0);
         stroke = _loc4_;
      }
   }
}

