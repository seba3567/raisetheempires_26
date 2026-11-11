package core.gamemode.unitMove
{
   import core.gamemode.GMObjectEditMove;
   import core.gamemode.GameModeManager;
   import zlabs.entity.IEntity;
   
   public class GMUnitMove extends GMObjectEditMove
   {
      
      private var m_targetUnit:IEntity = null;
      
      public function GMUnitMove(param1:IEntity)
      {
         super();
         this.m_targetUnit = param1;
         m_highlightedObject = param1;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         m_highlightedObject = this.m_targetUnit;
         this.m_targetUnit = null;
         doHandleClick(null);
      }
      
      override protected function moveComplete() : void
      {
         GameModeManager.instance.removeGameMode(this);
         GameModeManager.instance.getTopGameMode().updatePointer();
      }
   }
}

