package core.managers.questManager
{
   import Engine.Managers.TransactionManager;
   import core.ui.menuitem.SettingsUIItem;
   import flash.events.Event;
   import transactions.TViewZoom;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class ZoomTask extends ZGameTask
   {
      
      public function ZoomTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function onSetActive(param1:Boolean) : void
      {
         if(param1)
         {
            Zlab.mainStage.addEventListener(SettingsUIItem.ZOOM_CHANGED,this.onZoomChanged,false,0,true);
            Zlab.mainStage.dispatchEvent(new Event(SettingsUIItem.ZOOM_TASK_ACTIVE));
         }
         else
         {
            Zlab.mainStage.removeEventListener(SettingsUIItem.ZOOM_CHANGED,this.onZoomChanged);
            Zlab.mainStage.dispatchEvent(new Event(SettingsUIItem.ZOOM_TASK_DEACTIVE));
         }
      }
      
      private function onZoomChanged(param1:WorldEvent) : void
      {
         TransactionManager.addTransaction(new TViewZoom(param1.eventData.zoom));
      }
   }
}

