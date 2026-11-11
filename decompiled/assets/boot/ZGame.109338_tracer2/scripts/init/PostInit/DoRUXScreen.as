package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.managers.RUXManager;
   
   public class DoRUXScreen extends InitializationAction
   {
      
      private static const ID:String = "DoRUXScreen";
      
      public function DoRUXScreen()
      {
         super(ID);
      }
      
      override public function execute() : void
      {
         RUXManager.instance.showRUXInitScreen();
      }
   }
}

