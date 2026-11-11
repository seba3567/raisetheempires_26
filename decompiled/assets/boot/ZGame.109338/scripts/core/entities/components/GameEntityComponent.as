package core.entities.components
{
   import core.gameobjects.GameItem;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import utils.TileUtil;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class GameEntityComponent extends EntityComponent
   {
      
      protected var m_lastPos:Point;
      
      private var m_data:GameDataComponent;
      
      private var m_posRef:PropertyReference;
      
      public function GameEntityComponent()
      {
         super();
         this.m_posRef = new PropertyReference("@IsoSpatial.position");
      }
      
      override protected function onAdd() : void
      {
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.START,this.onSpriteStart,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.STOP,this.onSpriteStop,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         owner.eventDispatcher.removeEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.START,this.onSpriteStart);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.STOP,this.onSpriteStop);
      }
      
      protected function onSpriteStart(param1:Event) : void
      {
      }
      
      protected function onSpriteStop(param1:Event) : void
      {
      }
      
      protected function get id() : int
      {
         this.initGameDataComponent();
         return this.m_data.id;
      }
      
      protected function get gameItem() : GameItem
      {
         this.initGameDataComponent();
         return this.m_data.gameData;
      }
      
      protected function get entityPos() : Point
      {
         var _loc1_:Vector3D = TileUtil.worldToTile(owner.getProperty(this.m_posRef));
         return new Point(_loc1_.x,_loc1_.y);
      }
      
      protected function onEntityTilePosChanged(param1:Point, param2:Point) : void
      {
      }
      
      private function onUpdateSprite(param1:Event) : void
      {
         var _loc2_:Point = this.entityPos;
         if(!this.m_lastPos || this.m_lastPos != this.entityPos)
         {
            this.onEntityTilePosChanged(this.m_lastPos,_loc2_);
            this.m_lastPos = _loc2_;
         }
      }
      
      private function initGameDataComponent() : void
      {
         if(!this.m_data)
         {
            this.m_data = GameDataComponent.getGameDataComponent(owner);
         }
      }
   }
}

