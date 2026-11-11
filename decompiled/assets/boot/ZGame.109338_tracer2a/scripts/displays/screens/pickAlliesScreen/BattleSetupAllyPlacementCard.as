package displays.screens.pickAlliesScreen
{
   import core.player.IAlly;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class BattleSetupAllyPlacementCard extends BattleSetupAllyCard
   {
      
      public static const ALLY_PLACEMENT_CARD_SELECTED:String = "allyPlacementCardSelected";
      
      private static const FRAME_BLUR:String = "_blur";
      
      private static const FRAME_FOCUS:String = "focus";
      
      private var m_eventDispatcher:EventDispatcher = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function BattleSetupAllyPlacementCard(param1:MovieClip, param2:EventDispatcher)
      {
         this.m_eventDispatcher = param2;
         super(param1);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         m_clip.remove_bt.addEventListener(MouseEvent.CLICK,this.onRemove,false,0,true);
         TextFieldUtil.processTextField(m_clip.fill_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupUnfilledAllySlot"));
         this.m_buttonSounds.addButton(m_clip.remove_bt,ButtonSound.DEFAULT);
      }
      
      override public function dispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         m_clip.remove_bt.removeEventListener(MouseEvent.CLICK,this.onRemove);
         this.m_eventDispatcher = null;
         super.dispose();
      }
      
      override public function displayAlly(param1:IAlly, param2:Boolean = false) : void
      {
         m_clip.gotoAndPlay(FRAME_BLUR);
         super.displayAlly(param1);
         if(param1 == null || param2)
         {
            m_clip.remove_bt.visible = false;
            m_clip.name_tf.visible = false;
            m_clip.fill_tf.visible = true;
         }
         else
         {
            TextFieldUtil.processTextField(m_clip.name_tf,param1.firstName);
            m_clip.remove_bt.visible = true;
            m_clip.name_tf.visible = true;
            m_clip.fill_tf.visible = false;
         }
      }
      
      public function setFocused() : void
      {
         m_clip.gotoAndPlay(FRAME_FOCUS);
      }
      
      private function onRemove(param1:MouseEvent) : void
      {
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(ALLY_PLACEMENT_CARD_SELECTED,this));
      }
   }
}

