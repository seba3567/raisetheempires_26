package core.managers.autoActionsManager
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.managers.boardAnimationEffectManager.BoardAnimationEffectManager;
   import core.managers.visitorManager.VisitorManager;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class AutoActionPlayAnimationAtEntity extends AutoAction
   {
      
      private var m_offset:Pt = new Pt();
      
      private var m_anchor:Point = new Point();
      
      private var m_animId:String = "AntiBallisticMissileFire";
      
      private var m_soundId:String = "AntiBallisticMissileFire";
      
      public function AutoActionPlayAnimationAtEntity(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         if(!ZGlobal.isVisiting())
         {
            this.doAnimation();
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
            this.doAnimation();
         }
      }
      
      private function doAnimation() : void
      {
         var _loc1_:IEntity = null;
         var _loc2_:IsoSpriteRenderer = null;
         doDisableInput();
         _loc1_ = data.target;
         _loc2_ = _loc1_.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
         if(!_loc2_)
         {
            _loc1_ = (data.entityGetter as Function)();
         }
         BoardAnimationEffectManager.instance.playAnimation(_loc1_,this.m_animId,this.m_soundId,this.m_offset,this.m_anchor);
         startEndAction();
      }
      
      public function set offset(param1:Pt) : void
      {
         this.m_offset = param1;
      }
      
      public function set anchor(param1:Point) : void
      {
         this.m_anchor = param1;
      }
      
      public function set animId(param1:String) : void
      {
         this.m_animId = param1;
      }
      
      public function set soundId(param1:String) : void
      {
         this.m_soundId = param1;
      }
   }
}

