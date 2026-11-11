package core.ui.interactiveClip
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   
   public class InteractiveClip
   {
      
      private var m_clip:MovieClip = null;
      
      private var m_callback:Function = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function InteractiveClip(param1:MovieClip, param2:Function)
      {
         super();
         this.m_clip = param1;
         this.m_callback = param2;
         this.m_clip.buttonMode = true;
         this.m_clip.useHandCursor = true;
         this.m_clip.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_clip.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.m_clip.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_clip,ButtonSound.DEFAULT);
      }
      
      public function dispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_clip.removeEventListener(MouseEvent.CLICK,this.onClicked);
         this.m_clip.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_clip.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.m_clip = null;
      }
      
      protected function onClicked(param1:MouseEvent) : void
      {
         this.m_callback();
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         this.m_clip.filters = [ZGameUtils.HighlightFilter];
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         this.m_clip.filters = [];
      }
   }
}

