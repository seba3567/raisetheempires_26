package core.gamemode.selectionMasker
{
   import as3isolib.display.IsoSprite;
   import as3isolib.geom.Pt;
   import core.entities.components.BuildingSpatialComponent;
   import entity.GameDataComponent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class EntitySelectionMasker implements ISelectionMaskerTarget
   {
      
      private var m_entity:IEntity = null;
      
      private var m_buildingSpatialComponent:BuildingSpatialComponent = null;
      
      private var m_isoSprite:IsoSprite = null;
      
      private var m_terrainType:String = null;
      
      public function EntitySelectionMasker(param1:IEntity)
      {
         super();
         this.m_entity = param1;
         this.m_buildingSpatialComponent = BuildingSpatialComponent(this.m_entity.lookupComponentByType(BuildingSpatialComponent));
         var _loc2_:IsoSpriteComponent = IsoSpriteComponent(this.m_entity.lookupComponentByType(IsoSpriteComponent));
         this.m_isoSprite = _loc2_.isoSprite;
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(this.m_entity);
         this.m_terrainType = _loc3_.gameData.terrainType;
      }
      
      public function get parentPosition() : Point
      {
         return new Point(this.m_isoSprite.screenX,this.m_isoSprite.screenY);
      }
      
      public function get position() : Vector3D
      {
         return this.m_buildingSpatialComponent.position;
      }
      
      public function get volume() : Pt
      {
         return this.m_buildingSpatialComponent.volume;
      }
      
      public function get terrainType() : String
      {
         return this.m_terrainType;
      }
      
      public function isEqual(param1:Object) : Boolean
      {
         var _loc2_:IEntity = param1 as IEntity;
         if(_loc2_)
         {
            if(_loc2_ == this.m_entity)
            {
               return true;
            }
         }
         return false;
      }
      
      public function release() : void
      {
         this.m_entity = null;
         this.m_buildingSpatialComponent = null;
         this.m_isoSprite = null;
         this.m_terrainType = null;
      }
   }
}

