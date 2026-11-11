package core.managers.autoActionsManager
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.managers.visitorManager.VisitorManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import zlabs.entity.IEntity;
   import zlabs.utils.MathUtils;
   
   public class AutoActionPanToEntity extends AutoAction
   {
      
      public function AutoActionPanToEntity(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         if(!ZGlobal.isVisiting())
         {
            this.doPan();
         }
         else
         {
            VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(!ZGlobal.isVisiting())
         {
            VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
            this.doPan();
         }
      }
      
      private function doPan() : void
      {
         var _loc1_:IEntity = null;
         var _loc2_:BuildingSpatialComponent = null;
         var _loc3_:Pt = null;
         var _loc4_:CineCameraComponent = null;
         _loc1_ = data.target;
         if(!_loc1_)
         {
            return;
         }
         doDisableInput();
         ViewManager.instance.addEventListener(CineCameraComponent.MOVETO_DONE,this.onMoveDone,false,0,true);
         _loc2_ = BuildingSpatialComponent(_loc1_.lookupComponentByType(BuildingSpatialComponent));
         if(!_loc2_)
         {
            _loc1_ = (data.entityGetter as Function)();
            _loc2_ = BuildingSpatialComponent(_loc1_.lookupComponentByType(BuildingSpatialComponent));
         }
         if(_loc2_)
         {
            _loc3_ = new Pt(_loc2_.position.x,_loc2_.position.y);
            _loc3_ = MathUtils.worldToTile(_loc3_,ZGlobal.cellSize);
            _loc4_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
            _loc4_.moveTo(_loc3_);
         }
      }
      
      private function onMoveDone(param1:Event) : void
      {
         ViewManager.instance.removeEventListener(CineCameraComponent.MOVETO_DONE,this.onMoveDone);
         startEndAction();
      }
   }
}

