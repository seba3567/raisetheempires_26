package rendering.rendering2d
{
   import as3isolib.display.IsoSprite;
   import as3isolib.display.scene.IsoScene;
   import core.ZGameManager;
   import core.entities.components.DestroyOnCompleteComponent;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class TemporaryRenderComponent extends DestroyOnCompleteComponent
   {
      
      private var m_isoSprite:IsoSprite = null;
      
      private var m_isoScene:IsoScene = null;
      
      public function TemporaryRenderComponent(param1:Vector3D)
      {
         super();
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc3_:IsoScene = IsoScene(_loc2_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
         this.m_isoScene = _loc3_;
         this.m_isoSprite = new IsoSprite();
         this.m_isoScene.addChild(this.m_isoSprite);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.m_isoScene.removeChild(this.m_isoSprite);
         this.m_isoSprite.sprites.length = 0;
         this.m_isoSprite = null;
         this.m_isoScene = null;
      }
      
      public function get isoSprite() : IsoSprite
      {
         return this.m_isoSprite;
      }
      
      public function get sprite() : Sprite
      {
         return this.m_isoSprite.container;
      }
   }
}

