package core.player
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import dispatchers.EnergyDispatcher;
   import events.EnergyUpdatedEvent;
   
   public class PlayerAmmo
   {
      
      private static const AMMO_MAX_VAR3_SPECIAL_CASE:int = 40;
      
      private var m_ammo:Number;
      
      private var m_ammoMax:Number;
      
      private var m_ammoTimer:AmmoTimer;
      
      public function PlayerAmmo()
      {
         super();
      }
      
      public static function variantAmmoMasterOn() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AMMO_MASTER) >= ExperimentsManager.VARIANT_AMMO_MASTER_ON;
      }
      
      public function init(param1:Object) : void
      {
         this.m_ammoTimer = new AmmoTimer(param1.lastAmmoCheck);
      }
      
      public function get ammoMax() : int
      {
         return this.m_ammoMax;
      }
      
      public function get ammoTimer() : AmmoTimer
      {
         return this.m_ammoTimer;
      }
      
      public function set ammo(param1:int) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AMMO_MASTER) == ExperimentsManager.VARIANT_AMMO_MASTER_ON)
         {
            param1 = Math.min(param1,AMMO_MAX_VAR3_SPECIAL_CASE);
         }
         else
         {
            param1 = Math.min(param1,this.GetMaxAmmoClamp());
         }
         var _loc2_:int = this.m_ammo;
         this.m_ammo = param1;
         EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.AMMO,_loc2_,param1));
      }
      
      public function checkAmmo(param1:int) : Boolean
      {
         var _loc2_:int = this.ammo;
         return _loc2_ >= param1;
      }
      
      private function GetMaxAmmoClamp() : int
      {
         return ExperimentsManager.instance.getExperimentValue(ExperimentsManager.EXPERIMENT_AMMO_MASTER,ZGlobal.gameSettings.getAmmoExperimentValues("ammo_maxcap_max"),30);
      }
      
      public function canAcceptAmmo(param1:int) : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AMMO_MASTER) == ExperimentsManager.VARIANT_AMMO_MASTER_ON && this.m_ammo == 0 && param1 == AMMO_MAX_VAR3_SPECIAL_CASE)
         {
            return true;
         }
         return this.m_ammo + param1 <= this.GetMaxAmmoClamp();
      }
      
      public function set ammoMax(param1:int) : void
      {
         param1 = Math.min(param1,this.GetMaxAmmoClamp());
         var _loc2_:int = this.m_ammoMax;
         this.m_ammoMax = param1;
         EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.MAX_AMMO,_loc2_,param1));
      }
      
      public function get ammo() : int
      {
         return this.m_ammo;
      }
      
      public function updateMaxAmmo(param1:int) : void
      {
         var _loc2_:int = ExperimentsManager.instance.getExperimentValue(ExperimentsManager.EXPERIMENT_AMMO_MASTER,ZGlobal.gameSettings.getAmmoExperimentValues("ammo_maxcap_start"),30);
         this.ammoMax = _loc2_ + ZGlobal.gameSettings.getNumber("ammoGainedPerLevel",1) * (param1 - 1);
      }
   }
}

