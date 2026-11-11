package core.ui.menuitem
{
   import core.ZGlobal;
   import core.managers.FlashFeedManager;
   import displays.popups.GenericCountdownClock;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class FlashFeedMenuItem extends PromoMenuItem
   {
      
      public static var instance:FlashFeedMenuItem = null;
      
      public static var m_clock:GenericCountdownClock = null;
      
      private static var colorFill:uint = 51;
      
      public static const CLOCK_FINISHED:String = "CLOCK_FINISHED";
      
      private var m_clip:MovieClip;
      
      private var m_endTime:int = 0;
      
      private var m_callbackFunc:Function;
      
      public function FlashFeedMenuItem()
      {
         swfPath = "assets/game/icons/Clock_HUD_Icon.swf";
         super("FlashFeedMenuItem",true,false,false);
         this.setUp();
         addEventListener(FlashFeedManager.ASK_FOR_TOKENS_TIMER_EXPIRED,this.playIconAnimation,false,0,true);
         addEventListener(FlashFeedManager.ASK_FOR_TOKENS_TIMER_STARTED,this.stopIconAnimation,false,0,true);
      }
      
      public static function getInstance() : FlashFeedMenuItem
      {
         if(instance == null)
         {
            instance = new FlashFeedMenuItem();
         }
         return instance;
      }
      
      override protected function setUp() : void
      {
         var _loc1_:String = null;
         if(swfPath)
         {
            _loc1_ = ZGlobal.getAssetURL(swfPath);
            Zlab.resourceManager.load(_loc1_,SWFResource,this.onSwfLoadComplete);
         }
         else
         {
            this.graphics.beginFill(colorFill,1);
            this.graphics.drawRect(0,0,64,64);
            this.graphics.endFill();
            show(false);
            colorFill += 51;
         }
         if(m_buttonSound == null)
         {
            m_buttonSound = ButtonSound.DEFAULT;
         }
         m_buttonSounds = new ButtonMouseEventSoundContainer();
         m_buttonSounds.addButton(this,m_buttonSound);
      }
      
      private function onSwfLoadComplete(param1:SWFResource) : void
      {
         this.m_clip = param1.clip.main_mc;
         this.m_clip.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_clip.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
         this.m_clip.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
         this.m_endTime = Math.round(FlashFeedManager.getInstance().m_expireDate.getTime() / 1000);
         m_clock = new GenericCountdownClock(this.m_clip.clock_mc,this.m_endTime,this.onClockUpdate,true);
         addChild(this.m_clip);
         show(false);
         this.stopIconAnimation();
      }
      
      private function onClockUpdate() : void
      {
         if(this.m_endTime < 2)
         {
            hide();
            dispatchEvent(new Event(CLOCK_FINISHED));
         }
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         FlashFeedManager.getInstance().dispatchEvent(new WorldEvent(FlashFeedManager.SHOW_FLASHFEED_DIALOG));
      }
      
      public function playIconAnimation() : void
      {
         this.m_clip.animated_mc.gotoAndPlay(0);
      }
      
      public function stopIconAnimation() : void
      {
         this.m_clip.animated_mc.gotoAndStop(1);
      }
   }
}

