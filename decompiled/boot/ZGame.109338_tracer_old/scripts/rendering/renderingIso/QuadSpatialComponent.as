package rendering.renderingIso
{
   import as3isolib.geom.Pt;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Vector3D;
   import zlabs.managers.IAreaMapManager;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.utils.quadTree.QuadTreePositionItem;
   
   public class QuadSpatialComponent extends IsoSpatialComponent
   {
      
      private static const GRID_CENTER:Number = 0.5;
      
      private var quadItem:QuadTreePositionItem;
      
      public var quadAreaManager:IAreaMapManager;
      
      private var _spriteCache:Sprite = null;
      
      private var _gridCenterPixelOffsetY:Number = 0;
      
      private var insertOnAdd:Boolean = false;
      
      private var ignoreRemove:Boolean = false;
      
      public function QuadSpatialComponent(param1:IAreaMapManager, param2:Number, param3:Boolean = false)
      {
         this.quadAreaManager = param1;
         this.quadItem = new QuadTreePositionItem(this,param2);
         if(param3)
         {
            this.quadAreaManager.insert(this.quadItem);
         }
         super();
      }
      
      public function set noRemove(param1:Boolean) : void
      {
         this.ignoreRemove = param1;
      }
      
      override protected function onAdd() : void
      {
         if(this.insertOnAdd)
         {
         }
         super.onAdd();
         this._spriteCache = getIsoSprite().container;
      }
      
      override public function set volume(param1:Pt) : void
      {
         super.volume = param1;
         this._gridCenterPixelOffsetY = this.calcGridCenterScreenPixelOffset(GRID_CENTER);
      }
      
      private function calcGridCenterScreenPixelOffset(param1:Number) : Number
      {
         var _loc2_:Pt = volume;
         return Math.sqrt(_loc2_.x * _loc2_.x + _loc2_.y * _loc2_.y) * param1;
      }
      
      public function get screenY() : Number
      {
         return this._spriteCache.y + this._gridCenterPixelOffsetY;
      }
      
      override public function set position(param1:Vector3D) : void
      {
         if(!this.ignoreRemove)
         {
            this.quadAreaManager.removeItem(this.quadItem);
         }
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
         this.quadAreaManager.insert(this.quadItem);
         if(owner)
         {
            owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteComponent.UPDATE_SPRITE));
         }
      }
      
      override public function set x(param1:Number) : void
      {
         var _loc2_:int = this.quadAreaManager.scalar(param1);
         this.quadItem.x = _loc2_;
         super.x = param1;
      }
      
      override public function set y(param1:Number) : void
      {
         var _loc2_:int = this.quadAreaManager.scalar(param1);
         this.quadItem.y = _loc2_;
         super.y = param1;
      }
      
      override public function set z(param1:Number) : void
      {
         this.quadItem.z = param1;
         super.z = param1;
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.quadAreaManager.removeItem(this.quadItem);
         this.quadItem.destroy();
         this.quadItem = null;
         this.quadAreaManager = null;
         this._spriteCache = null;
      }
   }
}

