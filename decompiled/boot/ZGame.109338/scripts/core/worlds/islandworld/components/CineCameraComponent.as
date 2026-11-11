package core.worlds.islandworld.components
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.easing.Sine;
   import core.ZGlobal;
   import core.views.ViewManager;
   import flash.events.Event;
   import zlabs.entity.EntityComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class CineCameraComponent extends EntityComponent
   {
      
      public static var MOVETO_DONE:String = "moveToDone";
      
      private var m_start:Pt = null;
      
      private var m_end:Pt = null;
      
      public function CineCameraComponent()
      {
         super();
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         TweenLite.killTweensOf(this);
      }
      
      public function moveTo(param1:Pt) : void
      {
         var _loc2_:IsoViewComponent = owner.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         this.m_end = MathUtils.tileToWorld(param1.x,param1.y,param1.z,ZGlobal.cellSize);
         this.m_start = IsoMath.screenToIso(_loc2_.currentPt);
         var _loc3_:Number = Pt.distance(this.m_end,this.m_start);
         _loc3_ /= ZGlobal.cellSize;
         _loc3_ /= 20;
         TweenLite.to(this,_loc3_,{
            "percent":1,
            "ease":Sine.easeInOut,
            "onComplete":this.onComplete
         });
      }
      
      public function get percent() : Number
      {
         return 0;
      }
      
      public function set percent(param1:Number) : void
      {
         var _loc2_:Pt = Pt.interpolate(this.m_start,this.m_end,param1);
         var _loc3_:IsoViewComponent = owner.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         _loc3_.centerOnPt(_loc2_);
      }
      
      private function onComplete() : void
      {
         ViewManager.instance.dispatchEvent(new Event(MOVETO_DONE));
      }
   }
}

