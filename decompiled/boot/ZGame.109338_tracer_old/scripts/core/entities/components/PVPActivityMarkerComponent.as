package core.entities.components
{
   import core.ZGlobal;
   import core.gamemode.IsoOutlineRect;
   import core.managers.PVPManager;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import utils.TileUtil;
   import zlabs.entity.EntityComponent;
   import zlabs.rendering.renderingISO.ISpatialObjectISO;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class PVPActivityMarkerComponent extends EntityComponent
   {
      
      private var m_rect:IsoOutlineRect;
      
      private var m_root:Point;
      
      private var m_size:int;
      
      public function PVPActivityMarkerComponent()
      {
         super();
         this.m_size = PVPManager.pvpInvasionAreaSize;
      }
      
      public function set activityMarkerRoot(param1:Point) : void
      {
         this.m_root = param1;
      }
      
      public function set isoOutlineRectSize(param1:int) : void
      {
         this.m_size = param1;
         if(!this.m_rect)
         {
            this.m_rect = new IsoOutlineRect(param1,param1);
         }
         else
         {
            this.m_rect.setSize(ZGlobal.cellSize * param1,ZGlobal.cellSize * param1,0);
         }
      }
      
      protected function get activityAreaSize() : int
      {
         return this.m_size;
      }
      
      protected function get rectColor() : int
      {
         return 0;
      }
      
      protected function get shouldOutline() : Boolean
      {
         return false;
      }
      
      final public function createOrUpdateRect() : void
      {
         if(this.m_root)
         {
            if(!this.m_rect)
            {
               this.m_rect = new IsoOutlineRect(this.m_size,this.m_size);
            }
            else
            {
               this.m_rect.setSize(ZGlobal.cellSize * this.m_size,ZGlobal.cellSize * this.m_size,0);
            }
            this.m_rect.setPosition(this.m_root);
            this.m_rect.setColor(this.rectColor,this.shouldOutline);
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.createOrUpdateRect();
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.spriteMoved,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.disposeRect();
         owner.eventDispatcher.removeEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.spriteMoved);
      }
      
      private function spriteMoved(param1:Event) : void
      {
         var _loc2_:ISpatialObjectISO = ISpatialObjectISO(owner.lookupComponentByType(ISpatialObjectISO));
         var _loc3_:Vector3D = TileUtil.worldToTile(_loc2_.position,true);
         var _loc4_:Point = PVPManager.instance.activityAreaCenterToRoot(new Point(_loc3_.x,_loc3_.y),this.m_size);
         this.activityMarkerRoot = _loc4_;
         this.m_rect.setPosition(_loc4_);
      }
      
      protected function disposeRect() : void
      {
         if(this.m_rect)
         {
            this.m_rect.dispose();
            this.m_rect = null;
         }
      }
   }
}

