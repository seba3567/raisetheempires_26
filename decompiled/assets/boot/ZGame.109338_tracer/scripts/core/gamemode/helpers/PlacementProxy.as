package core.gamemode.helpers
{
   import as3isolib.bounds.IBounds;
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.geom.Pt;
   import core.entities.components.behaviors.states.PurchaseState;
   import core.gamemode.GridPointer;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.geom.Vector3D;
   import rendering.renderingIso.QuadSpatialComponent;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.ISpatialObjectISO;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class PlacementProxy
   {
      
      protected var m_entity:IEntity;
      
      private var m_originalBounds:Pt = null;
      
      private var m_islandID:String;
      
      public function PlacementProxy(param1:IEntity)
      {
         super();
         this.m_entity = param1;
         if(this.m_entity)
         {
            this.m_originalBounds = new Pt(this.isoBounds().width,this.isoBounds().length);
            GridPointer.instance.hide = true;
            GridPointer.instance.visibilityLocked = true;
         }
      }
      
      public function get isoDisplayObject() : IIsoDisplayObject
      {
         var _loc1_:IsoSpriteComponent = this.m_entity.lookupComponentByType(IsoSpriteComponent) as IsoSpriteComponent;
         return _loc1_.isoSprite;
      }
      
      public function moveTo(param1:Vector3D, param2:Boolean = false) : void
      {
         var _loc3_:Number = this.isoSpatial.position.z;
         this.isoSpatial.position = param1;
         GridPointer.instance.hide = true;
         if(param2)
         {
            this.onObjectDrop();
         }
      }
      
      public function set islandID(param1:String) : void
      {
         this.m_islandID = param1;
      }
      
      public function get islandID() : String
      {
         return this.m_islandID;
      }
      
      public function isoBounds() : IBounds
      {
         return this.isoDisplayObject.isoBounds;
      }
      
      public function get originalBounds() : Pt
      {
         return this.m_originalBounds;
      }
      
      public function placementArray() : Array
      {
         var _loc1_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         return _loc1_.gameData.placementArray;
      }
      
      public function get canBuildOn() : String
      {
         var _loc1_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         var _loc2_:String = _loc1_.gameData.canBuildOn;
         return _loc2_.length > 0 ? _loc2_ : null;
      }
      
      public function get isoSpatial() : ISpatialObjectISO
      {
         return this.m_entity.lookupComponentByType(QuadSpatialComponent) as ISpatialObjectISO;
      }
      
      public function conditionallyReattach(param1:Boolean = false) : void
      {
      }
      
      public function getPosition() : Vector3D
      {
         var _loc1_:Vector3D = null;
         var _loc2_:ISpatialObjectISO = null;
         if(this.m_entity)
         {
            _loc2_ = this.isoSpatial;
            _loc1_ = _loc2_.position;
         }
         return _loc1_;
      }
      
      public function getSize() : IBounds
      {
         return this.isoDisplayObject.isoBounds;
      }
      
      public function getMapResource() : IEntity
      {
         return this.m_entity;
      }
      
      public function onObjectDrop(param1:Vector3D = null) : void
      {
         this.releaseEntity();
      }
      
      public function dispose() : void
      {
         if(this.m_entity)
         {
            this.m_entity.destroy();
         }
         this.releaseEntity();
      }
      
      public function onPurchased() : void
      {
         this.m_entity.eventDispatcher.dispatchEvent(new Event(PurchaseState.PURCHASED));
         this.releaseEntity();
      }
      
      protected function releaseEntity() : void
      {
         if(null != this.m_entity)
         {
            this.m_entity = null;
            GridPointer.instance.visibilityLocked = false;
            GridPointer.instance.hide = false;
         }
      }
   }
}

