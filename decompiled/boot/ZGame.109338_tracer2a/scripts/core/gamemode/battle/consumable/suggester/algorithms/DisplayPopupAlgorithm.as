package core.gamemode.battle.consumable.suggester.algorithms
{
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggesterUtils;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.Fleet;
   import core.managers.ConsumableSuggestionManager;
   
   public class DisplayPopupAlgorithm extends AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const ALGORITHM_DISPLAY_POPUP:String = "displayPopupAlgorithm";
      
      private var m_enemyHealthBuff:Number;
      
      private var m_forceDisplay:Boolean = false;
      
      public function DisplayPopupAlgorithm(param1:Fleet, param2:Fleet)
      {
         super(false);
         m_playerFleet = param1;
         m_enemyFleet = param2;
         this.initVars();
      }
      
      override public function get algorithmName() : String
      {
         return ALGORITHM_DISPLAY_POPUP;
      }
      
      override public function calculateSuggestionWeight() : void
      {
         m_weight = 0;
         if(ConsumableSuggesterUtils.getFleetCurrentStrength(m_enemyFleet) * (1 + this.m_enemyHealthBuff) >= ConsumableSuggesterUtils.getFleetCurrentStrength(m_playerFleet) || m_enemyFleet.units.length >= m_playerFleet.units.length || this.m_forceDisplay)
         {
            m_weight = 1;
            this.m_forceDisplay = false;
         }
      }
      
      public function set forceDisplay(param1:Boolean) : void
      {
         this.m_forceDisplay = param1;
      }
      
      public function get forceDisplay() : Boolean
      {
         return this.m_forceDisplay;
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

