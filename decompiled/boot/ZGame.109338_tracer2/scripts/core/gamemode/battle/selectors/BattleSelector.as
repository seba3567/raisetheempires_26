package core.gamemode.battle.selectors
{
   import core.gamemode.battle.ISelectionReceiver;
   
   public class BattleSelector
   {
      
      private var m_receiver:ISelectionReceiver = null;
      
      public function BattleSelector(param1:ISelectionReceiver)
      {
         super();
         this.m_receiver = param1;
      }
      
      public function init() : void
      {
      }
      
      public function dispose() : void
      {
      }
      
      protected function get receiver() : ISelectionReceiver
      {
         return this.m_receiver;
      }
   }
}

