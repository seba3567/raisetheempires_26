package displays.popups.battleSelect
{
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   
   public class BattleSelectButton extends ZGameButton
   {
      
      private var m_text:String = null;
      
      private var m_selected:Boolean = false;
      
      private var m_current:Boolean = false;
      
      private var m_locked:Boolean = false;
      
      private var m_ready:Boolean = false;
      
      private var m_completed:Boolean = false;
      
      public function BattleSelectButton(param1:MovieClip, param2:Function = null, param3:Number = 1.1)
      {
         super(param1,param2,param3);
      }
      
      override public function set text(param1:String) : void
      {
         this.m_text = param1;
         super.text = param1;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.m_selected = param1;
         upFrame = super.getUpFrame();
      }
      
      public function set current(param1:Boolean) : void
      {
         this.m_current = param1;
         upFrame = super.getUpFrame();
      }
      
      public function set ready(param1:Boolean) : void
      {
         this.m_ready = param1;
         upFrame = super.getUpFrame();
      }
      
      public function set locked(param1:Boolean) : void
      {
         this.m_locked = param1;
         upFrame = super.getUpFrame();
      }
      
      public function set completed(param1:Boolean) : void
      {
         this.m_completed = param1;
         upFrame = super.getUpFrame();
      }
      
      override protected function getUpFrame() : int
      {
         if(this.m_selected)
         {
            return this.hitFrame;
         }
         return super.getUpFrame() + this.offset;
      }
      
      override protected function get overFrame() : int
      {
         return super.overFrame + this.offset;
      }
      
      override protected function get downFrame() : int
      {
         return super.downFrame + this.offset;
      }
      
      override protected function get hitFrame() : int
      {
         return super.hitFrame + this.offset;
      }
      
      override public function gotoFrame(param1:int) : void
      {
         super.gotoFrame(param1);
         if(null != this.m_text)
         {
            this.text = this.m_text;
         }
      }
      
      private function get offset() : int
      {
         return this.m_current ? 9 : (this.m_ready ? 3 : (this.m_locked ? 6 : (this.m_completed ? 12 : 0)));
      }
   }
}

