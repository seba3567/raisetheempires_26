package core.managers
{
   import core.ZGlobal;
   import displays.screens.RUXInitScreen;
   import displays.screens.RUXQuestPopUp;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import zlabs.managers.PopupManager;
   
   public class RUXManager extends EventDispatcher
   {
      
      public static const instance:RUXManager = new RUXManager();
      
      public static const questPrefix:String = ZGlobal.gameSettings.getString("ruxQuestPrefix","QRUX");
      
      public static const finalQuest:String = ZGlobal.gameSettings.getString("ruxFinalQuest","QRUX3");
      
      public static const questAsset:String = "assets/displays/dialogs/PU_RUXQuests.swf";
      
      public function RUXManager(param1:IEventDispatcher = null)
      {
         super();
      }
      
      public function showRUXInitScreen() : void
      {
         if(ZGlobal.player.showRUXInit)
         {
            PopupManager.instance.push(new RUXInitScreen());
         }
      }
      
      public function showQuest(param1:String) : void
      {
         PopupManager.instance.push(new RUXQuestPopUp(param1));
      }
   }
}

