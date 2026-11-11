package init.PostInit
{
   import Engine.Init.InitializationAction;
   import flash.events.Event;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class DoDisplayDialog extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoDialog";
      
      protected var m_dialog:PopUpBase;
      
      private var m_stall:Boolean;
      
      public function DoDisplayDialog(param1:PopUpBase, param2:Boolean = true)
      {
         super(INIT_ID);
         this.m_dialog = param1;
         this.m_stall = param2;
      }
      
      override public function execute() : void
      {
         this.m_dialog.addEventListener(GenericPopupEvent.SELECTED,this.onDialogClose);
         PopupManager.instance.push(this.m_dialog,0,true,this.m_stall);
      }
      
      protected function onDialogClose(param1:Event) : void
      {
         this.m_dialog.removeEventListener(GenericPopupEvent.SELECTED,this.onDialogClose);
         this.m_dialog = null;
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

