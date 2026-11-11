package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import flash.events.Event;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   
   public class BuildFootprintComponent extends EntityComponent
   {
      
      public var volumePropertyReference:PropertyReference = null;
      
      public var positionPropertyReference:PropertyReference = null;
      
      public var directionPropertyReference:PropertyReference = null;
      
      public var gameItemPropertyReference:PropertyReference = null;
      
      private var m_cachedTerrainType:String = null;
      
      private var m_fromLoad:Boolean = true;
      
      private var m_addedToWorld:Boolean = false;
      
      private var m_terrainType:String;
      
      public function BuildFootprintComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.m_cachedTerrainType = owner.getProperty(this.gameItemPropertyReference).terrainType;
         if(this.m_fromLoad)
         {
            this.addSelfToWorld();
         }
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.START,this.onMoveStarted,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.STOP,this.onMoveComplete,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         if(this.m_addedToWorld)
         {
            this.removeSelfFromWorld();
         }
         super.onRemove();
      }
      
      public function set fromLoad(param1:Boolean) : void
      {
         this.m_fromLoad = param1;
      }
      
      private function onMoveStarted(param1:Event) : void
      {
         if(this.m_addedToWorld)
         {
            this.removeSelfFromWorld();
         }
      }
      
      private function onMoveComplete(param1:Event) : void
      {
         this.addSelfToWorld();
      }
      
      public function addSelfToWorld() : void
      {
         this.modifyWorld(true);
      }
      
      public function removeSelfFromWorld() : void
      {
         if(!BuildManager.instance.ignoringRemoves)
         {
            this.modifyWorld(false);
         }
      }
      
      private function modifyWorld(param1:Boolean) : void
      {
         var _loc2_:Pt = owner.getProperty(this.volumePropertyReference);
         var _loc3_:Pt = Pt.toPt(owner.getProperty(this.positionPropertyReference));
         var _loc4_:int = int(owner.getProperty(this.directionPropertyReference));
         var _loc5_:Object = owner;
         var _loc6_:String = this.m_terrainType != null ? this.m_terrainType : BuildManager.instance.BUILDING_STR;
         if(Boolean(this.m_cachedTerrainType) && this.m_cachedTerrainType.length > 0)
         {
            _loc6_ = this.m_cachedTerrainType;
         }
         if(_loc4_ != GameItem.DIRECTION_SW && (_loc2_.x == ZGlobal.cellSize && _loc2_.y == ZGlobal.cellSize))
         {
            _loc4_ = GameItem.DIRECTION_SW;
         }
         var _loc7_:Pt = _loc3_.clone() as Pt;
         BuildManager.instance.modifyPosForPlacement(_loc4_,_loc2_,_loc7_);
         if(param1)
         {
            BuildManager.instance.addFootprintBuildType(_loc7_,_loc2_.clone() as Pt,_loc4_,_loc5_,_loc6_);
         }
         else
         {
            BuildManager.instance.removeFootprintBuildType(_loc7_,_loc2_.clone() as Pt,_loc4_,_loc5_,_loc6_);
         }
         this.m_addedToWorld = param1;
      }
      
      public function setTerrainType(param1:String) : void
      {
         this.m_terrainType = param1;
      }
   }
}

