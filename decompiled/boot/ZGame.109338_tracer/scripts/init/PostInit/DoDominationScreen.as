package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.domination.DominationModeManager;
   
   public class DoDominationScreen extends InitializationAction
   {
      
      private static const ID:String = "DoDominationScreen";
      
      private var m_currentTab:String = "";
      
      public function DoDominationScreen(param1:String = "")
      {
         this.m_currentTab = param1;
         super(ID);
         MessageOfTheDayManager.instance.setPlayer(ZGlobal.player);
      }
      
      override public function execute() : void
      {
         DominationModeManager.instance.launchDominationScreen(this.m_currentTab);
      }
   }
}

