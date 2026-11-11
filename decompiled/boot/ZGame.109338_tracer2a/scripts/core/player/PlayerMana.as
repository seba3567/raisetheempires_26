package core.player
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.ManaDispatcher;
   import events.ExperienceUpdatedEvent;
   import zlabs.events.WorldEvent;
   
   public class PlayerMana
   {
      
      private static const EXPERIMENT_SUPPORT_UNITS_MANA_MAXCAP:String = "empires_support_units_mana_maxcap";
      
      private static const MAXCAP_START_INDEX:int = 0;
      
      private static const MAXCAP_MAX_INDEX:int = 1;
      
      private var m_value:int = -1;
      
      private var m_cap:int = 0;
      
      public function PlayerMana(param1:Object)
      {
         super();
         this.updateValue(param1.mana.value);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated);
      }
      
      public function get percent() : Number
      {
         return Number(this.m_value / this.m_cap);
      }
      
      public function get value() : int
      {
         return this.m_value;
      }
      
      public function get cap() : int
      {
         return this.m_cap;
      }
      
      public function allow(param1:int) : Boolean
      {
         if(param1 == 0)
         {
            return true;
         }
         return this.m_value >= param1;
      }
      
      public function allowGive(param1:int) : Boolean
      {
         return this.m_value < this.m_cap;
      }
      
      public function spend(param1:int) : Boolean
      {
         if(this.allow(param1))
         {
            this.updateValue(-param1);
            ManaDispatcher.instance.dispatchEvent(new WorldEvent(ManaDispatcher.AMOUNT_USED,param1));
            return true;
         }
         return false;
      }
      
      public function give(param1:int) : Boolean
      {
         if(this.allowGive(param1))
         {
            this.updateValue(param1);
            return true;
         }
         return false;
      }
      
      private function updateValue(param1:int) : void
      {
         if(this.m_value < 0)
         {
            this.m_value = param1;
         }
         else
         {
            this.m_value += param1;
         }
         ManaDispatcher.instance.dispatchEvent(new WorldEvent(ManaDispatcher.VALUE_UPDATED,this.m_value));
      }
      
      private function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.updateCap(param1.newAmount);
      }
      
      private function updateCap(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = ZGlobal.gameSettings.getInt("manaStartingLevel");
         var _loc3_:int = param1;
         if(_loc3_ >= _loc2_)
         {
            _loc4_ = ExperimentsManager.instance.getExperimentValue(EXPERIMENT_SUPPORT_UNITS_MANA_MAXCAP,ZGlobal.gameSettings.getManaExperimentValues("exp_su_mana_maxcap_start"),5,MAXCAP_START_INDEX);
            _loc5_ = ZGlobal.gameSettings.getInt("manaCapLevelJump");
            _loc6_ = ZGlobal.gameSettings.getInt("manaCapLevelIncrease");
            _loc7_ = ExperimentsManager.instance.getExperimentValue(EXPERIMENT_SUPPORT_UNITS_MANA_MAXCAP,ZGlobal.gameSettings.getManaExperimentValues("exp_su_mana_maxcap_max"),15,MAXCAP_MAX_INDEX);
            _loc3_ -= _loc2_;
            this.m_cap = _loc3_ / _loc5_;
            this.m_cap *= _loc6_;
            this.m_cap += _loc4_;
            this.m_cap = Math.min(_loc7_,this.m_cap);
            if(this.m_value < 0)
            {
               this.updateValue(this.m_cap);
            }
         }
      }
   }
}

