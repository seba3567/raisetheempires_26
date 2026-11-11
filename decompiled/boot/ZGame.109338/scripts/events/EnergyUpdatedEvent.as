package events
{
   public class EnergyUpdatedEvent extends UpdateEvent
   {
      
      public static const ENERGY:String = "ENERGY_UPDATED";
      
      public static const MAX_ENERGY:String = "MAX_ENERGY_UPDATED";
      
      public static const ENERGY_REGEN:String = "ENERGY_UPDATED_REGEN";
      
      public static const AMMO:String = "AMMO_UPDATED";
      
      public static const MAX_AMMO:String = "MAX_AMMO_UPDATED";
      
      public static const AMMO_REGEN:String = "AMMO_UPDATED_REGEN";
      
      public function EnergyUpdatedEvent(param1:String, param2:int, param3:int)
      {
         super(param1,param2,param3);
      }
   }
}

