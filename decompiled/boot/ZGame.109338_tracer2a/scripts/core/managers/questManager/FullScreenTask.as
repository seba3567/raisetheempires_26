package core.managers.questManager
{
   import Engine.Managers.TransactionManager;
   import flash.events.FullScreenEvent;
   import transactions.TFullScreen;
   import zlabs.Zlab;
   
   public class FullScreenTask extends ZGameTask
   {
      
      public function FullScreenTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function onSetActive(param1:Boolean) : void
      {
         if(param1)
         {
            Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullscreen,false,0,true);
         }
         else
         {
            Zlab.mainStage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullscreen);
         }
      }
      
      private function onFullscreen(param1:FullScreenEvent) : void
      {
         if(param1.fullScreen)
         {
            TransactionManager.addTransaction(new TFullScreen());
         }
      }
   }
}

