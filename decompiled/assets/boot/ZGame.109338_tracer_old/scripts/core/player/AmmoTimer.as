package core.player
{
   import core.ZGlobal;
   import dispatchers.EnergyDispatcher;
   import events.EnergyUpdatedEvent;
   import zlabs.Zlab;
   import zlabs.core.IAnimatedObject;
   
   public class AmmoTimer implements IAnimatedObject
   {
      
      private var m_lastAmmoCheck:Number = 0;
      
      private var m_regenSeconds:Number = 0;
      
      private var m_regenAmount:Number = 0;
      
      private var m_timeout:Number = 0;
      
      private var m_active:Boolean = false;
      
      public function AmmoTimer(param1:Number)
      {
         super();
         this.m_lastAmmoCheck = param1;
         this.m_regenSeconds = ZGlobal.gameSettings.getNumber("ammoRegenerationSeconds",60);
         this.m_regenAmount = ZGlobal.gameSettings.getNumber("ammoRegenerationAmount",1);
         EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.AMMO,this.onAmmoUpdated);
      }
      
      public function set lastAmmoCheck(param1:Number) : void
      {
         this.m_timeout -= param1 - this.m_lastAmmoCheck;
         this.m_lastAmmoCheck = param1;
      }
      
      public function start() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!this.m_active)
         {
            _loc1_ = GlobalEngine.getTimer() / 1000;
            _loc2_ = _loc1_ - this.m_lastAmmoCheck;
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
         var _loc3_:PlayerAmmo = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.m_timeout += param1;
         var _loc2_:int = Math.floor(this.m_timeout / this.m_regenSeconds);
         if(_loc2_ > 0)
         {
            this.m_timeout -= _loc2_ * this.m_regenSeconds;
            this.m_lastAmmoCheck += _loc2_ * this.m_regenSeconds;
            _loc3_ = ZGlobal.player.m_ammo;
            _loc4_ = Math.max(0,_loc3_.ammoMax - _loc3_.ammo);
            _loc5_ = Math.min(_loc2_ * this.m_regenAmount,_loc4_);
            if(_loc5_ > 0)
            {
               EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.AMMO_REGEN,_loc3_.ammo,_loc3_.ammo + _loc5_));
               _loc3_.ammo += _loc5_;
            }
         }
      }
      
      private function onAmmoUpdated(param1:EnergyUpdatedEvent) : void
      {
         if(param1.newAmount < ZGlobal.player.m_ammo.ammoMax)
         {
            this.start();
            if(param1.oldAmount == ZGlobal.player.m_ammo.ammoMax)
            {
               this.m_timeout = 0;
               this.m_lastAmmoCheck = GlobalEngine.getTimer() / 1000;
            }
         }
         else
         {
            this.stop();
         }
      }
   }
}

