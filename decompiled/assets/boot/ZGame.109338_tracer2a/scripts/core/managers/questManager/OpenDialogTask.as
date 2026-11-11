package core.managers.questManager
{
   import Engine.Managers.TransactionManager;
   import core.managers.tutorialManager.TutorialManager;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   import transactions.TOpenDialog;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class OpenDialogTask extends ZGameTask
   {
      
      public function OpenDialogTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function onSetActive(param1:Boolean) : void
      {
         if(param1)
         {
            WindowManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         }
         else
         {
            WindowManager.instance.removeEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen);
         }
      }
      
      private function onShowScreen(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:TOpenDialog = null;
         Logger.info(this,"OnShowScreen","m_complete:" + m_complete);
         if(!m_complete)
         {
            _loc2_ = m_xml.@dialog;
            _loc2_ = _loc2_.toLowerCase();
            _loc3_ = getQualifiedClassName(param1.eventData);
            _loc3_ = _loc3_.toLowerCase();
            Logger.info(this,"OnShowScreen","className: " + _loc3_ + " dialog: " + _loc2_);
            if(_loc3_.indexOf(_loc2_) > 0)
            {
               _loc4_ = new TOpenDialog(_loc3_);
               TransactionManager.addTransaction(_loc4_);
               _loc4_ = null;
               Logger.info(this,"OnShowScreen","Dispatching DIALOG_CONTINUE event");
               TutorialManager.instance.dispatchEvent(new Event(TutorialManager.DIALOG_CONTINUE));
            }
         }
      }
   }
}

