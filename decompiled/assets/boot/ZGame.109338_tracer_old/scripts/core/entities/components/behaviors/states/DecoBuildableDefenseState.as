package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.PVPManager;
   import flash.events.MouseEvent;
   import zlabs.entity.IEntity;
   
   public class DecoBuildableDefenseState extends BehaviorState
   {
      
      private static const PROTECTION_ALWAYS:String = "always";
      
      public function DecoBuildableDefenseState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverDecoBuildable,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutDecoBuildable,false,0,true);
      }
      
      private function onMouseOverDecoBuildable(param1:MouseEvent) : void
      {
         var _loc2_:IEntity = null;
         if(ZGlobal.isHome())
         {
            _loc2_ = IEntity(stateMachine.propertyBag);
            PVPManager.instance.clearAreaImmunity();
            PVPManager.instance.updateAreaImmunitySingle(_loc2_);
            PVPManager.instance.updateAreaImmunityBuildings();
            PVPManager.instance.updateAreaImmunityMarkers();
         }
      }
      
      private function onMouseOutDecoBuildable(param1:MouseEvent) : void
      {
         if(ZGlobal.isHome())
         {
            PVPManager.instance.clearAreaImmunity();
         }
      }
      
      public function canProtectAlways() : Boolean
      {
         if(m_data.@protection != undefined && m_data.@protection == PROTECTION_ALWAYS)
         {
            return true;
         }
         return false;
      }
   }
}

