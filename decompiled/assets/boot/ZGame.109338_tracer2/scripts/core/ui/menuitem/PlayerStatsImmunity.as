package core.ui.menuitem
{
   import core.managers.PVPManager;
   import core.ui.Tooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class PlayerStatsImmunity
   {
      
      private var m_clip:MovieClip = null;
      
      private var m_enabled:Boolean = false;
      
      public function PlayerStatsImmunity(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         TextFieldUtil.processTextField(this.m_clip.label_tf,"");
         this.m_clip.visible = false;
         PVPManager.instance.addEventListener(PVPManager.IMMUNITY_STARTED,this.immunityStarted,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.IMMUNITY_UPDATED,this.immunityStarted,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.IMMUNITY_EXPIRED,this.immunityExpired,false,0,true);
         this.m_clip.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.m_clip.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      public function dispose() : void
      {
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_STARTED,this.immunityStarted);
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_UPDATED,this.immunityStarted);
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_EXPIRED,this.immunityExpired);
         this.m_clip.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_clip.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.m_clip.visible = false;
         this.m_clip = null;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:String = ZGameUtils.ZlocT("Main","Immunity_Tooltip");
         Tooltip.show(_loc2_,null,this.m_clip);
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_clip))
         {
            Tooltip.hide();
         }
      }
      
      private function immunityStarted(param1:Event) : void
      {
         this.enable(true);
      }
      
      private function immunityExpired(param1:Event) : void
      {
         this.enable(false);
      }
      
      public function enable(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.m_enabled = param1;
         _loc2_ = this.m_enabled && PVPManager.instance.isImmune;
         this.m_clip.visible = _loc2_;
         if(_loc2_)
         {
            _loc3_ = PVPManager.instance.immunityEndTime;
            _loc4_ = Math.max(0,_loc3_ - GlobalEngine.getTimer() / 1000);
            this.updateText(_loc4_);
            PVPManager.instance.addEventListener(PVPManager.IMMUNITY_TIMER_UPDATED,this.onImmunityTimerUpdated,false,0,true);
         }
         else
         {
            PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_TIMER_UPDATED,this.onImmunityTimerUpdated);
         }
      }
      
      private function updateText(param1:int) : void
      {
         var _loc2_:String = ZGameTimeUtil.instance.getClockString(param1,true);
         TextFieldUtil.processTextField(this.m_clip.label_tf,_loc2_);
      }
      
      private function onImmunityTimerUpdated(param1:WorldEvent) : void
      {
         var _loc2_:int = int(param1.eventData.remaining);
         this.updateText(_loc2_);
      }
   }
}

