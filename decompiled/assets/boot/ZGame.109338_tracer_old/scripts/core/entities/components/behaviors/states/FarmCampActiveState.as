package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.FarmCampManager;
   import entity.GameDataComponent;
   
   public class FarmCampActiveState extends SimpleAutoState
   {
      
      public function FarmCampActiveState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:GameDataComponent = null;
         super.performEnterActions();
         if(!ZGlobal.isVisiting())
         {
            if(FarmCampManager.instance.isInited == false)
            {
               _loc1_ = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
               if(_loc1_)
               {
                  FarmCampManager.instance.init(_loc1_);
               }
            }
            FarmCampManager.instance.setCurrentState(FarmCampManager.STATE_ACTIVE);
         }
      }
   }
}

