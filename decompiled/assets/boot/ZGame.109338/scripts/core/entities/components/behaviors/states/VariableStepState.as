package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   
   public class VariableStepState extends SimpleClickState
   {
      
      public function VariableStepState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function get defaultClickNextStateIndex() : String
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(m_data.@varStep != undefined && m_data.@varStepStates != undefined)
         {
            _loc1_ = m_data.@varStepStates.toString().split(",");
            _loc2_ = int(m_data.@varStep);
            if(_loc2_ >= 0 && _loc2_ < _loc1_.length)
            {
               return _loc1_[_loc2_];
            }
         }
         return super.defaultClickNextStateIndex;
      }
   }
}

