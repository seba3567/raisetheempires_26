package core.player
{
   import core.ZGlobal;
   import core.managers.EnergiserManager;
   import dispatchers.EnergyDispatcher;
   import dispatchers.UIDispatcher;
   import events.EnergyUpdatedEvent;
   import zlabs.Zlab;
   import zlabs.core.IAnimatedObject;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class EnergyTimer implements IAnimatedObject
   {
      
      private var m_lastEnergyCheck:Number = 0;
      
      private var m_regenSeconds:Number = 0;
      
      private var m_regenAmount:Number = 0;
      
      private var m_timeout:Number = 0;
      
      private var m_active:Boolean = false;
      
      public function EnergyTimer(param1:Number)
      {
         super();
         this.m_lastEnergyCheck = param1;
         var _loc2_:String = "energyRegenerationSeconds";
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc2_ = "energyRegenerationSeconds2";
         }
         this.m_regenSeconds = ZGlobal.gameSettings.getNumber(_loc2_,60);
         this.m_regenAmount = ZGlobal.gameSettings.getNumber("energyRegenerationAmount",1);
         EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.ENERGY,this.onEnergyUpdated);
      }
      
      public function set lastEnergyCheck(param1:Number) : void
      {
         var _loc2_:Number = param1 - this.m_lastEnergyCheck;
         if(_loc2_ != 0)
         {
            if(_loc2_ <= -this.m_regenSeconds)
            {
               Logger.error(this,"lastEnergyCheck","delta " + _loc2_ + " too large, ignoring adjustment. ");
            }
            else
            {
               this.m_timeout -= _loc2_;
               this.m_lastEnergyCheck = param1;
            }
         }
      }
      
      public function start() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!this.m_active)
         {
            _loc1_ = GlobalEngine.getTimer() / 1000;
            _loc2_ = _loc1_ - this.m_lastEnergyCheck;
            this.m_timeout = _loc2_;
            this.m_active = true;
            Zlab.processManager.addAnimatedObject(this);
         }
      }
      
      public function stop() : void
      {
         if(this.m_active)
         {
            Zlab.processManager.removeAnimatedObject(this);
            this.m_active = false;
         }
      }
      
      public function get delta() : int
      {
         return this.m_regenSeconds - this.m_timeout;
      }
      
      public function onFrame(param1:Number) : void
      {
         var _loc3_:PlayerEnergy = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.m_timeout += param1;
         var _loc2_:int = Math.floor(this.m_timeout / this.m_regenSeconds);
         if(_loc2_ > 0)
         {
            this.m_timeout -= _loc2_ * this.m_regenSeconds;
            this.m_lastEnergyCheck += _loc2_ * this.m_regenSeconds;
            _loc3_ = ZGlobal.player.m_energy;
            _loc4_ = Math.max(0,_loc3_.energyMax - _loc3_.energy);
            _loc5_ = Math.min(_loc2_ * this.m_regenAmount,_loc4_);
            if(_loc5_ > 0)
            {
               EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.ENERGY_REGEN,_loc3_.energy,_loc3_.energy + _loc5_));
               _loc3_.energy += _loc5_;
            }
         }
      }
      
      private function onEnergyUpdated(param1:EnergyUpdatedEvent) : void
      {
         if(param1.newAmount < ZGlobal.player.m_energy.energyMax || ZGlobal.player.m_energy.energyMax == -1)
         {
            this.start();
            if(param1.oldAmount == ZGlobal.player.m_energy.energyMax)
            {
               this.m_timeout = 0;
               this.m_lastEnergyCheck = GlobalEngine.getTimer() / 1000;
            }
            if(param1.newAmount <= 5 && EnergiserManager.instance.isActive())
            {
               UIDispatcher.instance.dispatchEvent(new WorldEvent(EnergiserManager.LOW_ENERGY));
            }
         }
         else
         {
            this.stop();
         }
      }
   }
}

