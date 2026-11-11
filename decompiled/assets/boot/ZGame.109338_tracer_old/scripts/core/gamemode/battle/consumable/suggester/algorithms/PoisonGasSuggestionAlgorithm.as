package core.gamemode.battle.consumable.suggester.algorithms
{
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggesterUtils;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.Fleet;
   import core.managers.ConsumableSuggestionManager;
   
   public class PoisonGasSuggestionAlgorithm extends AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const ALGORITHM_POISON_GAS:String = "poisonGasAlgorithm";
      
      private var m_poisonGasStrengthThresholdPercent:Number;
      
      private var m_suggestionPercent:Number;
      
      private var m_suggestionWeight:Number;
      
      private var m_revenuePercent:Number;
      
      private var m_revenueWeight:Number;
      
      public function PoisonGasSuggestionAlgorithm(param1:Fleet)
      {
         super(false);
         m_enemyFleet = param1;
         this.initVars();
      }
      
      override public function get algorithmName() : String
      {
         return ALGORITHM_POISON_GAS;
      }
      
      override public function calculateSuggestionWeight() : void
      {
         m_weight = 0;
         if(ConsumableSuggesterUtils.fleetCurrentlyUsingArrayOfConsumables(m_enemyFleet,m_consumableCode.split(",")) == false && m_enemyFleet.units.length > 3 && ConsumableSuggesterUtils.getFleetCurrentStrength(m_enemyFleet) / ConsumableSuggesterUtils.getFleetStartingStrength(m_enemyFleet) > this.m_poisonGasStrengthThresholdPercent)
         {
            m_weight = ConsumableSuggesterUtils.calculateTotalWeight(this.m_suggestionPercent,this.m_suggestionWeight,this.m_revenuePercent,this.m_revenueWeight);
         }
      }
      
      private function initVars() : void
      {
         cycleThroughAttributesAndSetMemberVars(ConsumableSuggestionManager.instance.getConsumableSuggestionDataXML(this.algorithmName));
      }
      
      override protected function setMemberVar(param1:String, param2:Object) : void
      {
         this[param1] = param2;
      }
   }
}

