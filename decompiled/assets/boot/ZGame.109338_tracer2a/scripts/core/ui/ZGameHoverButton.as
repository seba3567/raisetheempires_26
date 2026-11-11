package core.ui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ZGameHoverButton extends ZGameButton
   {
      
      private var m_onMouseOverCallback:Function = null;
      
      public function ZGameHoverButton(param1:MovieClip, param2:Function = null, param3:Number = 1.1, param4:Boolean = false, param5:Function = null, param6:Function = null)
      {
         super(param1,param2,param3,param4,param5);
         this.m_onMouseOverCallback = param6;
      }
      
      override protected function onOver(param1:MouseEvent) : void
      {
         if(this.m_onMouseOverCallback != null)
         {
            this.m_onMouseOverCallback(param1);
         }
         super.onOver(param1);
      }
   }
}

