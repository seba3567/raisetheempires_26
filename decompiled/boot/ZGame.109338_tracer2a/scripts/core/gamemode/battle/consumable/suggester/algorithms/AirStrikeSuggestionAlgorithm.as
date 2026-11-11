package core.gamemode.battle.consumable.suggester.algorithms
{
   import core.ZGlobal;
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggesterUtils;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.UnitItem;
   import core.managers.ConsumableSuggestionManager;
   
   public class AirStrikeSuggestionAlgorithm extends AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const ALGORITHM_AIR_STRIKE:String = "airStrikeAlgorithm";
      
      private var m_suggestionPercent:Number;
      
      private var m_suggestionWeight:Number;
      
      private var m_revenuePercent:Number;
      
      private var m_revenueWeight:Number;
      
      private var m_enemyFleetSizeMaximumThreshold:Number;
      
      public function AirStrikeSuggestionAlgorithm(param1:Fleet)
      {
         super(false);
         m_enemyFleet = param1;
         this.initVars();
      }
      
      override public function get algorithmName() : String
      {
         return ALGORITHM_AIR_STRIKE;
      }
      
      override public function calculateSuggestionWeight() : void
      {
         var _loc1_:Number = NaN;
         m_weight = 0;
         if(m_enemyFleet.units.length <= this.m_enemyFleetSizeMaximumThreshold)
         {
            if(m_enemyFleet.type == UnitItem.AIR)
            {
               m_weight = ConsumableSuggesterUtils.calculateTotalWeight(this.m_suggestionPercent,this.m_suggestionWeight,this.m_revenuePercent,this.m_revenueWeight);
            }
            else
            {
               _loc1_ = (ZGlobal.gameSettings.getItemByCode(consumableCode,ConsumableItem) as ConsumableItem).di;
               if(ConsumableSuggesterUtils.getFleetCurrentStrength(m_enemyFleet) <= _loc1_)
               {
                  m_weight = ConsumableSuggesterUtils.calculateTotalWeight(this.m_suggestionPercent,this.m_suggestionWeight,this.m_revenuePercent,this.m_revenueWeight);
               }
            }
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

