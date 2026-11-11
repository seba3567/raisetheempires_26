package zlabs.displays.zflex
{
   import flash.display.Stage;
   
   public class ZModalView extends ZCanvas
   {
      
      public function ZModalView()
      {
         super();
      }
      
      public function onLoaded() : void
      {
         this.backgroundColor = 0;
         this.backgroundAlpha = 0.5;
      }
      
      public function centerWithinStage(param1:Stage) : void
      {
         centerX = param1.stageWidth / 2;
         centerY = param1.stageHeight / 2;
      }
   }
}

