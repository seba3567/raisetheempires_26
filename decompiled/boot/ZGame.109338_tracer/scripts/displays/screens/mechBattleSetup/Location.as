package displays.screens.mechBattleSetup
{
   import core.gamemode.prebattle.TitanUI;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   
   public class Location
   {
      
      private static const SELECTED_FRAME:int = 2;
      
      private var m_clip:MovieClip = null;
      
      private var m_index:int = -1;
      
      private var m_cancel:Function = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function Location(param1:int, param2:MovieClip, param3:Function)
      {
         super();
         this.m_clip = param2;
         this.m_index = param1;
         this.m_cancel = param3;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_clip.exit_bt.addEventListener(MouseEvent.CLICK,this.onClick);
         this.m_clip.exit_bt.visible = false;
         this.m_buttonSounds.addButton(this.m_clip.exit_bt,ButtonSound.DEFAULT);
         this.m_clip.gotoAndStop(1);
      }
      
      public function dispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_clip.exit_bt.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_cancel = null;
         this.m_clip = null;
      }
      
      public function updateUIState(param1:TitanUI) : void
      {
         if(this.m_index == TitanUI.HEAD && param1.AnyLimbOccupied())
         {
            this.m_clip.gotoAndStop(SELECTED_FRAME);
            this.m_clip.exit_bt.visible = false;
         }
         else if(param1.getOccupiedAt(this.m_index))
         {
            this.m_clip.gotoAndStop(SELECTED_FRAME);
            this.m_clip.exit_bt.visible = true;
         }
         else
         {
            this.m_clip.gotoAndStop(1);
            this.m_clip.exit_bt.visible = false;
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.m_cancel(this.m_index);
      }
   }
}

