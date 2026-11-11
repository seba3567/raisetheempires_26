package core.gamemode.battle.consumable.suggester.algorithms
{
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggesterUtils;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.Fleet;
   import core.managers.ConsumableSuggestionManager;
   
   public class EvasionSuggestionAlgorithm extends AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const ALGORITHM_EVASION:String = "evasionAlgorithm";
      
      private var m_suggestionPercent:Number;
      
      private var m_suggestionWeight:Number;
      
      private var m_revenuePercent:Number;
      
      private var m_revenueWeight:Number;
      
      private var m_evasionCancelIfTheseConsumablesInUse:String;
      
      private var m_evasionStrengthMaximumThreshold:Number;
      
      public function EvasionSuggestionAlgorithm(param1:Fleet, param2:Fleet)
      {
         super(false);
         m_playerFleet = param1;
         m_enemyFleet = param2;
         this.initVars();
      }
      
      override public function get algorithmName() : String
      {
         return ALGORITHM_EVASION;
      }
      
      override public function calculateSuggestionWeight() : void
      {
         m_weight = 0;
         var _loc1_:Array = this.m_evasionCancelIfTheseConsumablesInUse.split(",");
         if(ConsumableSuggesterUtils.fleetCurrentlyUsingArrayOfConsumables(m_playerFleet,this.m_evasionCancelIfTheseConsumablesInUse.split(",")) == false && (ConsumableSuggesterUtils.getAverageTier(m_playerFleet) < ConsumableSuggesterUtils.getAverageTier(m_enemyFleet) || ConsumableSuggesterUtils.getFleetStrengthRemainingFraction(m_playerFleet) <= this.m_evasionStrengthMaximumThreshold))
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

