package displays.screens.pickConsumableScreen
{
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.Tooltip;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class CombatConsumablesScreen extends SWFPopUp
   {
      
      private var m_eventDispatcher:EventDispatcher = null;
      
      private var m_resource:SWFResource = null;
      
      private var m_panel:MovieClip = null;
      
      private var m_grid:CombatConsumablesGrid = null;
      
      private var m_controlsDisable:Boolean = false;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function CombatConsumablesScreen(param1:EventDispatcher, param2:Boolean = false)
      {
         this.m_eventDispatcher = param1;
         this.m_controlsDisable = param2;
         super(ZGlobal.getAssetURL("assets/displays/screens/CombatConsumableScreen.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:Boolean = false) : void
      {
         WindowManager.instance.push(new CombatConsumablesScreen(param1,param2));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         m_window = param1.clip;
         addChild(m_window);
         this.m_panel = m_window.ConsumablesComponent;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_panel.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         this.m_buttonSounds.addButton(this.m_panel.exit_bt,ButtonSound.DEFAULT);
         addEventListener(ConsumableSlot.CLICKED,this.onConsumableSelected,false,0,true);
         this.m_grid = new CombatConsumablesGrid(this.m_panel.grid_mc,this.m_resource,this);
         this.positionScreen();
         m_window.gotoAndPlay("_show");
         TextFieldUtil.processTextField(this.m_panel.caption_tf,ZGameUtils.ZlocT("Dialogs","PickConsumableHeader"));
         this.m_panel.buy_bt.addEventListener(MouseEvent.CLICK,this.onBuyButton,false,0,true);
         this.m_buttonSounds.addButton(this.m_panel.buy_bt,ButtonSound.DEFAULT);
         if(this.m_controlsDisable)
         {
            ZGameUtils.disableButton(this.m_panel.buy_bt,this.onBuyButton);
            ZGameUtils.disableButton(this.m_panel.exit_bt,this.onExitButton);
         }
         else
         {
            Tooltip.subscribe(this.m_panel.buy_bt,ZGameUtils.ZlocT("Dialogs","ImpulseCashButton"));
         }
         dispatchEvent(new Event(Event.COMPLETE));
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_SPECIALPOWERS_SCREEN_PRE_ANIM));
            Zlab.processManager.schedule(750,this,this.onLoadCompleteDelay);
         }
      }
      
      private function onLoadCompleteDelay() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_SPECIALPOWERS_SCREEN));
      }
      
      public function dispose() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_controlsDisable)
         {
            ZGameUtils.enableButton(this.m_panel.buy_bt,this.onBuyButton);
            ZGameUtils.enableButton(this.m_panel.exit_bt,this.onExitButton);
         }
         this.m_grid.dispose();
         Tooltip.unsubscribe(this.m_panel.buy_bt);
         removeEventListener(ConsumableSlot.CLICKED,this.onConsumableSelected);
         this.m_panel.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         this.m_panel.buy_bt.removeEventListener(MouseEvent.CLICK,this.onBuyButton);
         this.m_panel = null;
         m_window = null;
         this.m_resource = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close();
      }
      
      override public function centerWithinStage(param1:Stage) : void
      {
         this.positionScreen();
      }
      
      private function onConsumableSelected(param1:WorldEvent) : void
      {
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(param1.type,param1.eventData));
         this.onExitButton();
      }
      
      private function onExitButton(param1:MouseEvent = null) : void
      {
         this.dispose();
         this.close();
      }
      
      private function onBuyButton(param1:MouseEvent) : void
      {
         ZGlobal.switchToTab("money");
      }
      
      private function positionScreen() : void
      {
         if(!m_window)
         {
            return;
         }
         m_window.bounds_mc.visible = false;
         var _loc1_:Rectangle = MovieClip(m_window.bounds_mc).getBounds(m_window.bounds_mc.parent);
         m_window.x = (Zlab.mainStage.stageWidth - _loc1_.width) * 0.5;
         m_window.y = Zlab.mainStage.stageHeight - _loc1_.height - _loc1_.top;
      }
   }
}

