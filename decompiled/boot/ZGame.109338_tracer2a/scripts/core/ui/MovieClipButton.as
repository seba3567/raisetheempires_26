package core.ui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import utils.ZGameUtils;
   
   public class MovieClipButton
   {
      
      private static const UPFRAME:int = 1;
      
      private static const OVERFRAME:int = 2;
      
      private static const DOWNFRAME:int = 3;
      
      private var m_target:MovieClip = null;
      
      private var m_callback:Function = null;
      
      private var m_upFrame:int = 1;
      
      private var m_overFrame:int = 2;
      
      private var m_downFrame:int = 3;
      
      private var m_enabled:Boolean = true;
      
      public function MovieClipButton(param1:MovieClip, param2:Function = null)
      {
         super();
         this.m_target = param1;
         if(Boolean(this.m_target) && Boolean(this.m_target.hit_mc))
         {
            this.m_target.hit_mc.alpha = 0;
            this.addEventListeners();
         }
         if(param2 != null)
         {
            this.m_callback = param2;
         }
      }
      
      public function get enabled() : Boolean
      {
         return this.m_enabled;
      }
      
      public function set enable(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_target.filters = null;
            this.addEventListeners();
         }
         else
         {
            this.m_target.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            this.removeEventListeners();
         }
         this.m_enabled = param1;
      }
      
      public function dispose() : void
      {
         if(Boolean(this.m_target) && Boolean(this.m_target.hit_mc))
         {
            this.removeEventListeners();
         }
      }
      
      protected function get upFrame() : int
      {
         return this.m_upFrame;
      }
      
      protected function get overFrame() : int
      {
         return this.m_overFrame;
      }
      
      protected function get downFrame() : int
      {
         return this.m_downFrame;
      }
      
      private function gotoFrame(param1:int) : void
      {
         this.m_target.gotoAndStop(param1);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.gotoFrame(this.overFrame);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.gotoFrame(this.upFrame);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.gotoFrame(this.downFrame);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this.gotoFrame(this.overFrame);
      }
      
      private function addEventListeners() : void
      {
         this.m_target.hit_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this.m_target.hit_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         this.m_target.hit_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.m_target.hit_mc.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this.m_target.hit_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.m_target.hit_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.m_target.hit_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.m_target.hit_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
   }
}

