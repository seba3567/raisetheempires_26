package core.managers.mayhemManager
{
   import Engine.Classes.TimerUtil;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.ui.menuitem.PlayerStatsUIItem;
   import displays.popups.GenericCountdownClock;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class MayhemClock extends EventDispatcher
   {
      
      public static var instance:MayhemClock = new MayhemClock();
      
      public static const CLOCK_FINISHED:String = "CLOCK_FINISHED";
      
      private var m_clip:MovieClip = null;
      
      private var m_clock:GenericCountdownClock = null;
      
      private var m_endTime:int = 0;
      
      private var m_callbackFunc:Function;
      
      public function MayhemClock()
      {
         super(null);
      }
      
      public function init(param1:int, param2:Function) : void
      {
         this.m_endTime = param1;
         this.m_callbackFunc = param2;
         addEventListener(CLOCK_FINISHED,this.m_callbackFunc);
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/ui/WorldEvent.swf"),SWFResource,this.onLoadComplete,this.onLoadFail);
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         this.m_clip = param1.clip.mayhemTimer_mc;
         TextFieldUtil.processTextField(this.m_clip.time_tf,ZGameUtils.ZlocT("Dialogs","Mayhem_Clock_Text"));
         this.m_clock = new GenericCountdownClock(this.m_clip.clock_mc,this.m_endTime - MayhemManager.instance.offset - ZGlobal.player.timeWarpSeconds,this.onUpdate);
         this.addClip();
         this.show();
         this.onUpdate();
      }
      
      public function set secondClockMC(param1:MovieClip) : void
      {
      }
      
      private function onLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load \'" + param1.filename + "\'");
      }
      
      protected function addClip() : void
      {
         this.m_clip.x = 150;
         this.m_clip.y = 0;
         this.m_clip.visible = false;
         PlayerStatsUIItem.getPlayerStats().addChild(this.m_clip);
      }
      
      public function show() : void
      {
         var _loc1_:int = GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds;
         if(Boolean(this.m_clip) && this.m_endTime > _loc1_)
         {
            this.m_clip.visible = true;
            TweenLite.to(this.m_clip,2,{
               "y":90,
               "onComplete":this.showComplete
            });
         }
      }
      
      public function hide() : void
      {
         if(this.m_clip)
         {
            TweenLite.to(this.m_clip,1,{
               "y":-this.m_clip.height,
               "onComplete":this.hideComplete
            });
         }
      }
      
      protected function hideComplete() : void
      {
         TweenLite.killTweensOf(this.m_clip);
         this.m_clip.visible = false;
      }
      
      protected function showComplete() : void
      {
         TweenLite.killTweensOf(this.m_clip);
         TimerUtil.callLater(this.hide,10000);
      }
      
      public function deInit() : void
      {
         this.m_clip = null;
         this.m_clock = null;
         removeEventListener(CLOCK_FINISHED,this.m_callbackFunc);
         this.m_callbackFunc = null;
      }
      
      private function onUpdate() : void
      {
         if(this.m_endTime - GlobalEngine.serverTime / 1000 - MayhemManager.instance.offset - ZGlobal.player.timeWarpSeconds < 2)
         {
            this.hide();
            dispatchEvent(new Event(CLOCK_FINISHED));
         }
      }
   }
}

