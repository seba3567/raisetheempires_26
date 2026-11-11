package core.ui
{
   import as3isolib.display.IsoSprite;
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.easing.Sine;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class FloatingImage extends Sprite
   {
      
      private var m_isoSprite:IsoSprite = null;
      
      private var m_position:Vector3D = null;
      
      public function FloatingImage(param1:String, param2:Object)
      {
         var _loc3_:IEntity = null;
         var _loc4_:BuildingSpatialComponent = null;
         var _loc5_:Pt = null;
         super();
         if(param2 is IEntity)
         {
            _loc3_ = param2 as IEntity;
            _loc4_ = BuildingSpatialComponent(_loc3_.lookupComponentByType(BuildingSpatialComponent));
            this.m_position = _loc4_.position;
            _loc5_ = _loc4_.volume;
            this.m_position.x += _loc5_.x;
            this.m_position.y += _loc5_.y;
         }
         else
         {
            this.m_position = param2 as Vector3D;
         }
         ImageLoaderFactory.CreateImageLoader(param1,null,this.onImageLoaded);
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         this.m_isoSprite = new IsoSprite();
         this.m_isoSprite.sprites = [param2];
         this.m_isoSprite.x = this.m_position.x;
         this.m_isoSprite.y = this.m_position.y;
         this.m_isoSprite.setSize(ZGlobal.cellSize,ZGlobal.cellSize,ZGlobal.cellSize);
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         _loc3_.addGameChild(this.m_isoSprite);
         TweenLite.to(this.m_isoSprite,2,{
            "z":200,
            "onComplete":this.onTweenComplete
         });
         TweenLite.to(this.m_isoSprite.container,2,{
            "alpha":0,
            "ease":Sine.easeIn
         });
      }
      
      protected function onTweenComplete() : void
      {
         this.m_isoSprite.parent.removeChild(this.m_isoSprite);
         this.destroy();
      }
      
      private function destroy() : void
      {
         this.m_isoSprite = null;
      }
   }
}

