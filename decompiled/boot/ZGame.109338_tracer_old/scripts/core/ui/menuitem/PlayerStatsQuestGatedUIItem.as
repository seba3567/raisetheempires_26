package core.ui.menuitem
{
   import ZQuest.Managers.QuestManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuestManager;
   import flash.display.MovieClip;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class PlayerStatsQuestGatedUIItem
   {
      
      private static const CLIP_TWEEN_TIME:Number = 0.6;
      
      private static const PULSE_DURATION:Number = 5000;
      
      protected var m_clip:MovieClip = null;
      
      protected var m_quest:String = null;
      
      protected var m_homeClip:MovieClip = null;
      
      protected var m_altClip:MovieClip = null;
      
      public function PlayerStatsQuestGatedUIItem(param1:MovieClip, param2:String, param3:MovieClip, param4:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.m_quest = param2;
         this.m_homeClip = param3;
         this.m_altClip = param4;
         if(this.isHidden)
         {
            if(Boolean(this.m_clip) && Boolean(this.m_altClip))
            {
               this.m_clip.x = this.m_altClip.x;
               this.m_clip.y = this.m_altClip.y;
            }
            QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestEvent,false,100,true);
         }
         else if(Boolean(this.m_clip) && Boolean(this.m_homeClip))
         {
            this.m_clip.x = this.m_homeClip.x;
            this.m_clip.y = this.m_homeClip.y;
         }
         this.stopPulse();
      }
      
      public function dispose() : void
      {
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestEvent);
      }
      
      public function get isHidden() : Boolean
      {
         return !(ZGlobal.player.questGatesComplete || ZGlobal.player.didCompleteQuest(this.m_quest) || ZGlobal.player.level > 7);
      }
      
      public function get currentPositionAnchor() : MovieClip
      {
         return this.isHidden ? this.m_altClip : this.m_homeClip;
      }
      
      private function startPulse() : void
      {
         if(this.m_clip.pulse_mc)
         {
            this.m_clip.pulse_mc.gotoAndPlay(1);
            this.m_clip.pulse_mc.visible = true;
            Zlab.processManager.schedule(PULSE_DURATION,this,this.stopPulse);
         }
      }
      
      private function stopPulse() : void
      {
         if(this.m_clip.pulse_mc)
         {
            this.m_clip.pulse_mc.gotoAndStop(1);
            this.m_clip.pulse_mc.visible = false;
         }
      }
      
      private function onQuestEvent(param1:WorldEvent) : void
      {
         if(this.m_quest == param1.eventData.name)
         {
            if(Boolean(this.m_clip) && Boolean(this.m_homeClip))
            {
               this.startPulse();
               TweenLite.to(this.m_clip,CLIP_TWEEN_TIME,{
                  "x":this.m_homeClip.x,
                  "y":this.m_homeClip.y
               });
            }
         }
      }
   }
}

