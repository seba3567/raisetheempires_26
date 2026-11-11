package core.worlds.strategicWorld.swf.version2
{
   import core.ZGlobal;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StrategicScopedBattlePrompt extends StrategicBattlePrompt
   {
      
      private var m_scope:IStrategicScope = null;
      
      private var m_locked:Boolean = false;
      
      private var m_blocking:Boolean = false;
      
      public function StrategicScopedBattlePrompt(param1:SWFResource, param2:String = null)
      {
         super(param1,param2);
         clip.visible = false;
      }
      
      override public function dispose() : void
      {
         this.scopeLost();
         super.dispose();
      }
      
      override protected function get pickImageUrl() : String
      {
         if(this.m_scope.home)
         {
            return ZGlobal.player.snUser.picture;
         }
         return super.pickImageUrl;
      }
      
      override protected function get pickName() : String
      {
         if(this.m_locked)
         {
            return "pickDark";
         }
         return super.pickName;
      }
      
      override protected function onExit(param1:MouseEvent) : void
      {
         if(this.blockingInput)
         {
            clip.visible = false;
         }
         super.onExit(param1);
      }
      
      private function onClipRollOut(param1:MouseEvent) : void
      {
         this.m_blocking = false;
         this.focusClip.removeEventListener(MouseEvent.ROLL_OUT,this.onClipRollOut);
      }
      
      private function onClipRollOver(param1:MouseEvent) : void
      {
         this.m_blocking = true;
         this.focusClip.removeEventListener(MouseEvent.ROLL_OVER,this.onClipRollOver);
      }
      
      override protected function onConsumeEvent(param1:MouseEvent) : void
      {
      }
      
      override public function get blockingInput() : Boolean
      {
         return this.m_blocking || super.blockingInput;
      }
      
      override protected function get pickVisible() : Boolean
      {
         return this.m_scope.home;
      }
      
      private function scopeLost() : void
      {
         this.m_blocking = false;
         this.focusClip.removeEventListener(MouseEvent.ROLL_OVER,this.onClipRollOver);
         this.focusClip.removeEventListener(MouseEvent.ROLL_OUT,this.onClipRollOut);
      }
      
      private function get focusClip() : MovieClip
      {
         return clip.panel.villain;
      }
      
      override protected function get playClipShow() : Boolean
      {
         return false;
      }
      
      override protected function onClick(param1:MouseEvent) : void
      {
         if(!this.m_locked)
         {
            super.onClick(param1);
         }
      }
      
      override protected function onIslandClicked(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = false;
         if(null != this.m_scope && this.m_scope.code == param1.eventData)
         {
            if(this.m_locked)
            {
               _loc2_ = ZGlobal.player.campaign.isAvailableInCampaign(this.m_scope.code);
               if(!_loc2_)
               {
                  floatingText(ZGameUtils.ZlocT("Main","Error_LockedIsland"));
               }
               else
               {
                  floatingText(ZGameUtils.ZlocT("Campaign","CampaignAvailableSoon"));
               }
            }
            else
            {
               super.onIslandClicked(param1);
            }
         }
      }
      
      override protected function onScopedEnter(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = false;
         if(null != clip)
         {
            this.m_scope = param1.eventData as IStrategicScope;
            if(null != this.m_scope)
            {
               this.m_locked = ZGlobal.player.campaign.isMapLocked(this.m_scope.code);
               _loc2_ = ZGlobal.player.campaign.isAvailableInCampaign(this.m_scope.code);
               if(!_loc2_)
               {
                  clip.visible = true;
               }
               setTarget(this.m_scope.clip,this.m_scope.code,this.m_scope.home);
               if(this.m_locked)
               {
                  this.focusClip.addEventListener(MouseEvent.ROLL_OVER,this.onClipRollOver);
                  this.focusClip.addEventListener(MouseEvent.ROLL_OUT,this.onClipRollOut);
               }
            }
            else
            {
               clip.visible = false;
               hidePanel();
               this.scopeLost();
            }
         }
      }
   }
}

