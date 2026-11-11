package events
{
   import zlabs.events.WorldEvent;
   
   public class ResourceRewardEvent extends WorldEvent
   {
      
      public static const OIL_REWARD:String = "oilReward";
      
      public static const WOOD_REWARD:String = "woodReward";
      
      public static const RARE_REWARD:String = "rareReward";
      
      public static const COINS_PICKUP:String = "coinsPickup";
      
      public static const FOOD_PICKUP:String = "foodPickup";
      
      public static const EXPERIENCE_PICKUP:String = "xpPickup";
      
      public static const OIL_PICKUP:String = "oilPickup";
      
      public static const WOOD_PICKUP:String = "woodPickup";
      
      public static const RARE_PICKUP:String = "rarePickup";
      
      public static const ENERGY_PICKUP:String = "energyPickup";
      
      public static const AMMO_PICKUP:String = "ammoPickup";
      
      public static const ITEM_PICKUP:String = "itemPickup";
      
      public function ResourceRewardEvent(param1:String)
      {
         super(param1);
      }
   }
}

