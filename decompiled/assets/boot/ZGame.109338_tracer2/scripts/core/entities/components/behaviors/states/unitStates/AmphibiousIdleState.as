package core.entities.components.behaviors.states.unitStates
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import entity.GameDataComponent;
   import zlabs.entity.IEntity;
   
   public class AmphibiousIdleState extends IdleState
   {
      
      private var m_gameData:GameDataComponent = null;
      
      public function AmphibiousIdleState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      public static function getImageName(param1:GameDataComponent, param2:String) : String
      {
         if(param1.inWater)
         {
            return "water_" + param2;
         }
         return param2;
      }
      
      override public function enter(param1:IMachine) : void
      {
         this.m_gameData = IEntity(param1.propertyBag).lookupComponentByType(GameDataComponent) as GameDataComponent;
         super.enter(param1);
      }
      
      override public function exit(param1:IMachine) : void
      {
         super.exit(param1);
         this.m_gameData = null;
      }
      
      override protected function get imageName() : String
      {
         return getImageName(this.m_gameData,m_imageName);
      }
   }
}

