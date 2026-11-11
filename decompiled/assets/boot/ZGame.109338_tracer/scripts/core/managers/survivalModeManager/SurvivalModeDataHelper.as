package core.managers.survivalModeManager
{
   import core.managers.ExperimentsManager;
   
   public class SurvivalModeDataHelper
   {
      
      private var m_setName:String = null;
      
      private var m_xml:XML = null;
      
      private var m_lastWaveIndex:int = -1;
      
      private var m_ultimateReward:String = null;
      
      public function SurvivalModeDataHelper(param1:String)
      {
         super();
         this.m_setName = param1;
         this.m_xml = SurvivalModeManager.instance.getXMLForSet(this.m_setName);
      }
      
      public function get lastWaveIndex() : int
      {
         var _loc1_:XML = null;
         if(this.m_lastWaveIndex < 0)
         {
            for each(_loc1_ in this.m_xml.wave)
            {
               if(_loc1_.@index != undefined && _loc1_.@index > this.m_lastWaveIndex)
               {
                  this.m_lastWaveIndex = _loc1_.@index;
               }
            }
         }
         return this.m_lastWaveIndex;
      }
      
      public function rewardUnitNameForTier(param1:int) : String
      {
         var _loc2_:XML = null;
         var _loc3_:XMLList = null;
         var _loc4_:XML = null;
         for each(_loc2_ in this.m_xml.wave)
         {
            if(_loc2_.@rewardTier != undefined && _loc2_.@rewardTier == param1)
            {
               _loc3_ = SurvivalModeManager.instance.isInExperimentReward && !SurvivalModeManager.instance.bIsInBattle ? _loc2_.experimentalrewards.reward : _loc2_.reward;
               for each(_loc4_ in _loc3_)
               {
                  if(_loc4_.@rewardFeature != undefined && _loc4_.@rewardFeature == "true")
                  {
                     return _loc4_.@item;
                  }
               }
            }
         }
         return null;
      }
      
      public function get ultimateRewardUnitName() : String
      {
         var _loc1_:Number = ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh");
         if(_loc1_ > 2 && !SurvivalModeManager.instance.isEliteMode)
         {
            return SurvivalModeManager.instance.survivalModeRewards[2];
         }
         return this.rewardUnitNameForTier(3);
      }
   }
}

