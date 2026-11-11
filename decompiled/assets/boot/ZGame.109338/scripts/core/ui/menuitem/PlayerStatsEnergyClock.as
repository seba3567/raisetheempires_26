package core.ui.menuitem
{
   import core.ZGlobal;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class PlayerStatsEnergyClock
   {
      
      private var m_clip:MovieClip = null;
      
      public function PlayerStatsEnergyClock(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.activate();
      }
      
      public function dispose() : void
      {
         this.deactivate();
         this.m_clip = null;
      }
      
      public function activate() : void
      {
         this.show();
         this.updateTime();
      }
      
      public function deactivate() : void
      {
         this.hide();
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function show() : void
      {
         this.m_clip.more_tf.visible = true;
         this.m_clip.timer_frame_lt.visible = true;
         this.m_clip.timer_frame_md.visible = true;
         this.m_clip.timer_frame_rt.visible = true;
      }
      
      private function hide() : void
      {
         this.m_clip.more_tf.visible = false;
         this.m_clip.timer_frame_lt.visible = false;
         this.m_clip.timer_frame_md.visible = false;
         this.m_clip.timer_frame_rt.visible = false;
      }
      
      protected function checkDisplayTime() : Boolean
      {
         return ZGlobal.player.m_energy.energy < ZGlobal.player.m_energy.energyMax;
      }
      
      protected function getTimerDelta() : int
      {
         return ZGlobal.player.m_energy.energyTimer.delta;
      }
      
      private function updateTime() : void
      {
         var _loc1_:int = 0;
         if(this.checkDisplayTime())
         {
            _loc1_ = this.getTimerDelta();
            TextFieldUtil.processTextField(this.m_clip.more_tf,ZGameUtils.ZlocT("Dialogs","MoreEnergyIn",{"time":ZGameTimeUtil.instance.getClockString(_loc1_ + 1)}));
            this.m_clip.timer_frame_md.width = Math.round(this.m_clip.more_tf.textWidth - 6.5);
            this.m_clip.timer_frame_rt.x = this.m_clip.timer_frame_md.x + this.m_clip.timer_frame_md.width;
            this.show();
         }
         else
         {
            this.hide();
         }
         Zlab.processManager.schedule(200,this,this.updateTime);
      }
   }
}

