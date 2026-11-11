package core.player
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.promoManager.PromoManager;
   import dispatchers.EnergyDispatcher;
   import dispatchers.MessageDispatcher;
   import dispatchers.ResourceDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.UnlimitedEnergyFeedPopup;
   import events.EnergyUpdatedEvent;
   import events.ResourceUpdatedEvent;
   import flash.events.TimerEvent;
   import transactions.TUnlimitedEnergyBuy;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.IWindow;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class PlayerEnergy
   {
      
      public static const UNLIMITED_ENERGY_CHANGED:String = "unlimitedEnergy";
      
      public static const UNLIMITED_ENERGY_END:String = "unlimitedEnergyEnd";
      
      private static const ENERGY_MAX_VAR3_SPECIAL_CASE:int = 30;
      
      private static const UNLIMITED_ENERGY_INACTIVE:int = 0;
      
      private static const EXPERIMENT_ENERGY_MAXCAP_VARIANT_ENABLED:int = 2;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_NONE:int = 0;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_CONTROL1:int = 1;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_CONTROL2:int = 2;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_NONPAYERS:int = 3;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_ALL:int = 4;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_14D_LAPSED:int = 5;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_30D_LAPSED:int = 6;
      
      private static const VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_45D_LAPSED:int = 7;
      
      private var m_reservedEnergy:Number = 0;
      
      private var m_energy:Number;
      
      private var m_energyMax:Number = -1;
      
      private var m_energyTimer:EnergyTimer;
      
      private var m_unlimitedEnergyIndex:int;
      
      private var m_energizerMax:uint = 50;
      
      private var m_unlimitedEnergyTS:int = 0;
      
      private var m_serverUnlimitedEnergyTS:int = 0;
      
      public function PlayerEnergy()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         this.m_serverUnlimitedEnergyTS = param1.unlimitedEnergyTS;
         this.m_unlimitedEnergyIndex = param1.unlimitedEnergyIndex;
         this.m_energyTimer = new EnergyTimer(param1.lastEnergyCheck);
         this.unlimitedEnergyTS = param1.unlimitedEnergyTS;
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.ENERGY,this.energyResourceUpdated);
      }
      
      public function buyUnlimitedEnergyWithConfirmation(param1:int) : void
      {
         var _loc2_:Array = PromoManager.instance.unlimitedEnergyData;
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc2_[param1].cost));
         var _loc4_:Array = new Array("EmpirePointsConfirm","","","");
         var _loc5_:GenericPopup2B = GenericPopup2B.NewYesNo(_loc3_,null,this.onBuyConfirmed,_loc4_);
         _loc5_.userData = param1;
         PopupManager.instance.push(_loc5_,0,false);
      }
      
      public function get energyMax() : int
      {
         return this.m_energyMax;
      }
      
      public function get energyTimer() : EnergyTimer
      {
         return this.m_energyTimer;
      }
      
      public function energyResourceUpdated(param1:ResourceUpdatedEvent) : void
      {
         if(this.energy != param1.newAmount)
         {
            this.energy = param1.newAmount;
         }
      }
      
      public function set energy(param1:int) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AMMO_MASTER) == ExperimentsManager.VARIANT_AMMO_MASTER_ON)
         {
            param1 = Math.min(param1,ENERGY_MAX_VAR3_SPECIAL_CASE);
         }
         else
         {
            param1 = Math.min(param1,this.GetMaxEnergyClamp());
         }
         var _loc2_:int = this.m_energy;
         if(!(this.updateAndCheckUnlimitedEnergy() && param1 < _loc2_))
         {
            this.m_energy = param1;
            EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.ENERGY,_loc2_,param1));
         }
      }
      
      public function checkEnergy(param1:int, param2:Boolean = false) : Boolean
      {
         if(param1 <= 0 || this.updateAndCheckUnlimitedEnergy())
         {
            return true;
         }
         var _loc3_:int = this.energy;
         if(param2)
         {
            _loc3_ -= this.m_reservedEnergy;
         }
         return _loc3_ >= param1;
      }
      
      private function GetMaxEnergyClamp() : int
      {
         var _loc1_:int = ZGlobal.gameSettings.getInt("maxEnergy",100);
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc1_ = ExperimentsManager.instance.getExperimentValue(ExperimentsManager.EXPERIMENT_AMMO_MASTER,ZGlobal.gameSettings.getAmmoExperimentValues("energy_maxcap_max"),30);
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_ENERGYBOOSTER_MASTER) == ExperimentsManager.VARIANT_BUILDABLE_ENERGYBOOSTER_ON && this.energizerMax > _loc1_)
         {
            _loc1_ = Math.max(_loc1_,this.energizerMax);
         }
         return _loc1_;
      }
      
      public function canAcceptEnergy(param1:int) : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AMMO_MASTER) == ExperimentsManager.VARIANT_AMMO_MASTER_ON && this.m_energy == 0 && param1 == ENERGY_MAX_VAR3_SPECIAL_CASE)
         {
            return true;
         }
         return this.m_energy + param1 <= this.GetMaxEnergyClamp();
      }
      
      public function set energyMax(param1:int) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("maxEnergy",100);
         if(param1 >= _loc2_ && this.m_energizerMax > param1)
         {
            param1 = Math.max(param1,this.GetMaxEnergyClamp());
         }
         else
         {
            param1 = Math.min(param1,this.GetMaxEnergyClamp());
         }
         var _loc3_:int = this.m_energyMax;
         this.m_energyMax = param1;
         EnergyDispatcher.instance.dispatchEvent(new EnergyUpdatedEvent(EnergyUpdatedEvent.MAX_ENERGY,_loc3_,param1));
      }
      
      public function get energy() : int
      {
         return this.m_energy;
      }
      
      public function get unreservedEnergy() : int
      {
         return this.m_energy - this.m_reservedEnergy;
      }
      
      public function set reservedEnergy(param1:int) : void
      {
         this.m_reservedEnergy = param1;
      }
      
      public function get reservedEnergy() : int
      {
         return this.m_reservedEnergy;
      }
      
      public function updateMaxEnergy(param1:int) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getNumber("startingEnergyMax",25);
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc2_ = ExperimentsManager.instance.getExperimentValue(ExperimentsManager.EXPERIMENT_AMMO_MASTER,ZGlobal.gameSettings.getAmmoExperimentValues("energy_maxcap_start"),30);
         }
         this.energyMax = _loc2_ + ZGlobal.gameSettings.getNumber("energyGainedPerLevel",1) * (param1 - 1);
      }
      
      public function updateAndCheckUnlimitedEnergy() : Boolean
      {
         if(this.m_unlimitedEnergyTS == UNLIMITED_ENERGY_INACTIVE)
         {
            return false;
         }
         var _loc1_:int = GlobalEngine.serverTime / 1000;
         if(_loc1_ > this.m_unlimitedEnergyTS)
         {
            this.onUnlimitedEnergyEnd();
            return false;
         }
         return true;
      }
      
      public function get isValidUnlimitedEnergyTarget() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_unlimited_energy_target");
         switch(_loc1_)
         {
            case VARIANT_UNLIMITED_ENERGY_TARGET_NONE:
            case VARIANT_UNLIMITED_ENERGY_TARGET_CONTROL1:
            case VARIANT_UNLIMITED_ENERGY_TARGET_CONTROL2:
               break;
            case VARIANT_UNLIMITED_ENERGY_TARGET_NONPAYERS:
               if(ZGlobal.player.isPayingUser())
               {
                  return false;
               }
               break;
            case VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_ALL:
            case VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_14D_LAPSED:
            case VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_30D_LAPSED:
            case VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_45D_LAPSED:
               if(!ZGlobal.player.isPayingUser())
               {
                  return false;
               }
               if(_loc1_ != VARIANT_UNLIMITED_ENERGY_TARGET_PAYERS_ALL)
               {
                  if(!this.passesUnlimitedEnergyLapsedPayerCheck())
                  {
                     return false;
                  }
               }
         }
         return true;
      }
      
      private function passesUnlimitedEnergyLapsedPayerCheck() : Boolean
      {
         var _loc1_:XML = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         for each(_loc1_ in PromoManager.instance.unlimitedEnergyLapsedPayersTargets)
         {
            if(_loc1_.@minTimeSinceLastEPPurchase != undefined && _loc1_.@experiment != undefined && _loc1_.@variants != undefined)
            {
               _loc2_ = ExperimentsManager.instance.getExperimentVariant(_loc1_.@experiment.toString());
               _loc3_ = _loc1_.@variants.toString();
               _loc4_ = _loc3_.split(",");
               if(_loc4_.indexOf(String(_loc2_)) >= 0)
               {
                  _loc5_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_.@minTimeSinceLastEPPurchase.toString(),0);
                  _loc6_ = ZGlobal.player.secondsSinceLastEPPurchase;
                  if(_loc6_ > _loc5_)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public function canBuyUnlimitedEnergy() : Boolean
      {
         if(this.updateAndCheckUnlimitedEnergy())
         {
            return false;
         }
         if(!PromoManager.instance.meetsCriteriaUnlimitedEnergy())
         {
            return false;
         }
         return true;
      }
      
      public function onUpdateServerUnlimitedEnergyTS() : void
      {
         if(this.m_serverUnlimitedEnergyTS != this.m_unlimitedEnergyTS)
         {
            if(this.m_unlimitedEnergyTS < this.m_serverUnlimitedEnergyTS)
            {
               ++this.m_unlimitedEnergyTS;
            }
            else
            {
               --this.m_unlimitedEnergyTS;
            }
            if(this.m_serverUnlimitedEnergyTS != this.m_unlimitedEnergyTS)
            {
               Zlab.processManager.schedule(1000,this,this.onUpdateServerUnlimitedEnergyTS);
            }
         }
      }
      
      private function buyUnlimitedEnergy(param1:int) : void
      {
         var _loc4_:TUnlimitedEnergyBuy = null;
         if(!this.canBuyUnlimitedEnergy())
         {
            return;
         }
         var _loc2_:Array = PromoManager.instance.unlimitedEnergyData;
         if(!_loc2_ || param1 >= _loc2_.length)
         {
            return;
         }
         var _loc3_:int = int(_loc2_[param1].cost);
         if(ZGlobal.player.canBuyCash(_loc3_))
         {
            ZGlobal.player.cash -= _loc3_;
            _loc4_ = new TUnlimitedEnergyBuy(param1);
            TransactionManager.addTransaction(_loc4_);
            this.m_unlimitedEnergyIndex = param1;
            this.unlimitedEnergyTS = GlobalEngine.serverTime / 1000 + _loc2_[param1].duration;
            this.showUnlimitedEnergyFeedPopup(param1);
         }
      }
      
      private function onUnlimitedEnergyEnd(param1:TimerEvent = null) : void
      {
         this.unlimitedEnergyTS = UNLIMITED_ENERGY_INACTIVE;
         MessageDispatcher.instance.dispatchEvent(new WorldEvent(UNLIMITED_ENERGY_CHANGED));
      }
      
      public function get unlimitedEnergyTimeRemaining() : int
      {
         var _loc1_:int = GlobalEngine.serverTime / 1000;
         return this.m_unlimitedEnergyTS - _loc1_;
      }
      
      private function showUnlimitedEnergyFeedPopup(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:IWindow = null;
         var _loc2_:Array = PromoManager.instance.unlimitedEnergyData;
         if(param1 < _loc2_.length)
         {
            _loc3_ = _loc2_[param1].image;
            _loc4_ = new UnlimitedEnergyFeedPopup(_loc3_,param1);
            PopupManager.instance.push(_loc4_);
         }
      }
      
      private function set unlimitedEnergyTS(param1:int) : void
      {
         var _loc2_:Boolean = this.m_unlimitedEnergyTS != UNLIMITED_ENERGY_INACTIVE;
         this.m_unlimitedEnergyTS = param1;
         var _loc3_:Boolean = this.m_unlimitedEnergyTS != UNLIMITED_ENERGY_INACTIVE;
         if(_loc2_ != _loc3_)
         {
            MessageDispatcher.instance.dispatchEvent(new WorldEvent(UNLIMITED_ENERGY_CHANGED));
         }
      }
      
      public function get unlimitedEnergyPackagePurchased() : int
      {
         return this.m_unlimitedEnergyIndex;
      }
      
      public function updateUnlimitedEnergyTS(param1:int) : void
      {
         this.m_serverUnlimitedEnergyTS = param1;
         this.onUpdateServerUnlimitedEnergyTS();
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData as int;
            this.doBuyUnlimitedEnergy(_loc2_);
         }
      }
      
      private function doBuyUnlimitedEnergy(param1:int) : void
      {
         var _loc2_:Array = PromoManager.instance.unlimitedEnergyData;
         if(ZGlobal.player.canBuyCash(_loc2_[param1].cost))
         {
            this.buyUnlimitedEnergy(param1);
         }
      }
      
      public function get energizerMax() : uint
      {
         return this.m_energizerMax;
      }
      
      public function set energizerMax(param1:uint) : void
      {
         this.m_energizerMax = param1;
      }
   }
}

