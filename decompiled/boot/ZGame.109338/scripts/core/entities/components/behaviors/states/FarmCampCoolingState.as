package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.FarmCampManager;
   import entity.GameDataComponent;
   import transactions.TFarmCampCoolDown;
   
   public class FarmCampCoolingState extends SimpleAutoState
   {
      
      public function FarmCampCoolingState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:TFarmCampCoolDown = null;
         var _loc2_:GameDataComponent = null;
         super.performEnterActions();
         if(!ZGlobal.isVisiting())
         {
            if(FarmCampManager.instance.isInited == false)
            {
               _loc2_ = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
               if(_loc2_)
               {
                  FarmCampManager.instance.init(_loc2_);
               }
            }
            FarmCampManager.instance.setCurrentState(FarmCampManager.STATE_COOLING);
            _loc1_ = new TFarmCampCoolDown(owner);
            TransactionManager.addTransaction(_loc1_);
         }
      }
   }
}

