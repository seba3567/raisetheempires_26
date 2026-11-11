package core.gamemode.battle.consumable.suggester.algorithms
{
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggesterUtils;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.Fleet;
   import core.managers.ConsumableSuggestionManager;
   
   public class HunkerDownSuggestionAlgorithm extends AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const ALGORITHM_HUNKER_DOWN:String = "hunkerDownAlgorithm";
      
      private var m_suggestionPercent:Number;
      
      private var m_suggestionWeight:Number;
      
      private var m_revenuePercent:Number;
      
      private var m_revenueWeight:Number;
      
      private var m_hunkerDownCancelIfTheseConsumablesInUse:String;
      
      private var m_hunkerDownStrengthMaximumThreshold:Number;
      
      public function HunkerDownSuggestionAlgorithm(param1:Fleet, param2:Fleet)
      {
         super(false);
         m_playerFleet = param1;
         m_enemyFleet = param2;
         this.initVars();
      }
      
      override public function get algorithmName() : String
      {
         return ALGORITHM_HUNKER_DOWN;
      }
      
      override public function calculateSuggestionWeight() : void
      {
         m_weight = 0;
         if(ConsumableSuggesterUtils.fleetCurrentlyUsingArrayOfConsumables(m_playerFleet,this.m_hunkerDownCancelIfTheseConsumablesInUse.split(",")) == false && (ConsumableSuggesterUtils.getAverageTier(m_playerFleet) < ConsumableSuggesterUtils.getAverageTier(m_playerFleet) || ConsumableSuggesterUtils.getFleetStrengthRemainingFraction(m_playerFleet) <= this.m_hunkerDownStrengthMaximumThreshold))
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

