package core.entities.components
{
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.gamemode.GameModeManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import events.IsoViewEvent;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import rendering.rendering2d.particles.Particle;
   import zlabs.entity.EntityComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class UnitDropRevealComponent extends EntityComponent
   {
      
      private var m_sprite:Sprite = null;
      
      private var m_bitmap:Bitmap = null;
      
      public function UnitDropRevealComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         var _loc1_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc2_:IsoScene = IsoScene(_loc1_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
         var _loc3_:IsoView = _loc1_.isoView;
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         var _loc4_:BuildingSpatialComponent = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc5_:Pt = Pt.toPt(_loc4_.position);
         _loc3_.isoToLocal(_loc5_);
         this.m_bitmap = new Bitmap();
         this.m_sprite = new Sprite();
         this.m_sprite.addChild(this.m_bitmap);
         this.m_sprite.x = _loc5_.x;
         this.m_sprite.y = _loc5_.y;
         this.setScale(_loc3_.currentZoom);
         _loc3_.foregroundContainer.addChild(this.m_sprite);
         var _loc6_:* = 10;
         while(_loc6_ > 0)
         {
            Particle.Create(new Pt(this.m_sprite.x + MathUtils.randBetween(0,this.m_sprite.width),this.m_sprite.y + MathUtils.randBetween(0,this.m_sprite.height)),this.m_sprite.parent);
            _loc6_--;
         }
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         this.setScale(param1.value);
      }
      
      private function setScale(param1:Number) : void
      {
         if(param1 < 0.5)
         {
            param1 *= 1 + (0.5 - param1) / 0.25 * 1;
         }
         this.m_sprite.scaleX = this.m_sprite.scaleY = 1 / param1;
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.dispose();
      }
      
      private function dispose() : void
      {
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         this.m_sprite.parent.removeChild(this.m_sprite);
      }
   }
}

