package events
{
   import zlabs.events.WorldEvent;
   
   public class PopulationEvent extends WorldEvent
   {
      
      public static const MAX_POPULATION_CHANGE:String = "MaxPopulationChange";
      
      public var newAmount:int;
      
      public var newAmountCap:int;
      
      public function PopulationEvent(param1:String, param2:int, param3:int, param4:Object = null)
      {
         super(param1,param4);
         this.newAmount = param2;
         this.newAmountCap = param3;
      }
   }
}

