package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.EnergiserManager;
   import dispatchers.EnergyDispatcher;
   import dispatchers.UIDispatcher;
   import displays.screens.energiser.EnergiserDialog;
   import events.EnergyUpdatedEvent;
   import flash.events.EventDispatcher;
   import transactions.TEnergizerSetup;
   import utils.ZGameTimeUtil;
   import zlabs.events.WorldEvent;
   
   public class EnergiserDialogState extends DialogState
   {
      
      public static const ENERGY_MAX:int = 60;
      
      public function EnergiserDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         if(ZGlobal.isHome() && Boolean(EnergiserManager.instance.energyRefill))
         {
            _loc1_ = "";
            if(updateHelper)
            {
               _loc3_ = updateHelper.remainingDuration / 1000;
               _loc1_ = ZGameTimeUtil.instance.getClockString(_loc3_ + 1);
            }
            stateMachine.propertyBag.eventDispatcher.addEventListener(EnergiserDialog.ENERGIZER_ACTIVATED,this.onActivationSelected,false,0,true);
            _loc2_ = false;
            if(Boolean(stateMachine.activatedState) && parseInt(stateMachine.activatedState) == parseInt(name))
            {
               _loc2_ = true;
            }
            EnergiserDialog.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),owner,_loc2_,false,_loc1_);
         }
      }
      
      protected function onActivationSelected(param1:WorldEvent) : void
      {
         ZGlobal.player.m_energy.energizerMax = ENERGY_MAX;
         ZGlobal.player.m_energy.energyMax = ENERGY_MAX;
         var _loc2_:int = ZGlobal.player.m_energy.energy;
         EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.ENERGY,_loc2_,_loc2_));
         clickNextState();
         TransactionManager.addTransaction(new TEnergizerSetup());
      }
      
      override protected function autoNextState() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = this.getEnergyMaxDeduction();
         var _loc2_:int = ZGlobal.player.m_energy.energyMax - _loc1_;
         if(_loc1_ > 0 && _loc2_ >= ZGlobal.gameSettings.getInt("maxEnergy",100))
         {
            if(ZGlobal.player.m_energy.energy > _loc2_)
            {
               ZGlobal.player.m_energy.energy = _loc2_;
            }
            ZGlobal.player.m_energy.energizerMax = _loc2_;
            ZGlobal.player.m_energy.energyMax = _loc2_;
            _loc3_ = ZGlobal.player.m_energy.energy;
            EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.ENERGY,_loc3_,_loc3_));
            UIDispatcher.instance.dispatchEvent(new WorldEvent(EnergiserManager.DEDUCT_ENERGY_TOASTER));
         }
         super.autoNextState();
      }
      
      private function getEnergyMaxDeduction() : int
      {
         if(m_data.@energyMaxDeduct)
         {
            return parseInt(m_data.@energyMaxDeduct);
         }
         return 0;
      }
   }
}

