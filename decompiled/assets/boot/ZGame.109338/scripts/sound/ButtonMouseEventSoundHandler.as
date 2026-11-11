package sound
{
   import core.ZGlobal;
   import core.gameobjects.SoundItem;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ButtonMouseEventSoundHandler
   {
      
      private var m_button:DisplayObject = null;
      
      private var m_buttonSound:SoundItem;
      
      private var m_buttonVisibleOnRelease:Boolean = false;
      
      public function ButtonMouseEventSoundHandler(param1:DisplayObject, param2:String)
      {
         super();
         this.m_button = param1;
         this.m_buttonSound = ZGlobal.gameSettings.getButtonSoundByName(param2,SoundItem) as SoundItem;
         this.m_button.addEventListener(MouseEvent.MOUSE_DOWN,this.onClick,false,0,true);
         this.m_button.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
      }
      
      public function Release() : void
      {
         this.m_button.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClick);
         this.m_button.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_buttonVisibleOnRelease = this.m_button.visible;
         this.m_button = null;
      }
      
      public function Controls(param1:DisplayObject) : Boolean
      {
         return this.m_button == param1;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.playSound(ButtonSound.ON_CLICK);
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         this.playSound(ButtonSound.ON_ROLLOVER);
      }
      
      private function playSound(param1:int) : void
      {
         var _loc2_:Boolean = false;
         if(this.m_button != null)
         {
            _loc2_ = this.m_button.visible;
         }
         else
         {
            _loc2_ = this.m_buttonVisibleOnRelease;
         }
         if(_loc2_ && Boolean(this.m_buttonSound))
         {
            ButtonSound.getButtonSound(this.m_buttonSound.name).play(param1);
         }
      }
   }
}

