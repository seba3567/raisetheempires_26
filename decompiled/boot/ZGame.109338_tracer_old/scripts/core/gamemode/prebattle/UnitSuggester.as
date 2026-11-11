package core.gamemode.prebattle
{
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class UnitSuggester extends EventDispatcher
   {
      
      public static const BUY_UNITS:String = "buyunits";
      
      public static const EXIT:String = "exit";
      
      private var m_clip:MovieClip = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function UnitSuggester(param1:MovieClip, param2:String)
      {
         super();
         this.m_clip = param1;
         this.m_clip.visible = true;
         TextFieldUtil.processTextField(this.m_clip.info_tf,ZGameUtils.ZlocT("Combat",param2));
         this.m_button = new ZGameButton(this.m_clip.buy_mc,this.onClick);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","BuyUnits");
         this.m_clip.exit_mc.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_clip.exit_mc,ButtonSound.DEFAULT);
      }
      
      public function dispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_clip.exit_mc.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_button.dispose();
         this.m_button = null;
         this.m_clip.visible = false;
         this.m_clip = null;
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(EXIT));
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(BUY_UNITS));
      }
   }
}

