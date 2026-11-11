package zlabs.debug
{
   import flash.events.KeyboardEvent;
   import zlabs.Zlab;
   import zlabs.core.InputKey;
   
   public class UIAppender implements ILogAppender
   {
      
      protected static var _hotKey:uint;
      
      protected var _logViewer:LogViewer;
      
      public function UIAppender()
      {
         super();
         Zlab.inputManager.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         _hotKey = InputKey.TILDE.keyCode;
         this._logViewer = new LogViewer();
      }
      
      public static function set hotKey(param1:uint) : void
      {
         Logger.print(UIAppender,"Setting hotKey to: " + param1);
         _hotKey = param1;
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode != _hotKey)
         {
            return;
         }
         if(this._logViewer)
         {
            if(this._logViewer.parent)
            {
               this._logViewer.parent.removeChild(this._logViewer);
               this._logViewer.deactivate();
            }
            else
            {
               Zlab.mainStage.addChild(this._logViewer);
               this._logViewer.activate();
            }
         }
      }
      
      public function addLogMessage(param1:String, param2:String, param3:String) : void
      {
         if(this._logViewer)
         {
            this._logViewer.addLogMessage(param1,param2,param3);
         }
      }
   }
}

