package displays.screens.pickAlliesScreen
{
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   
   public class BattleSetupInviteCard
   {
      
      private var m_clip:MovieClip = null;
      
      private var m_inviteBtn:ZGameButton = null;
      
      private var m_callback:Function = null;
      
      public function BattleSetupInviteCard(param1:MovieClip, param2:Function = null)
      {
         super();
         this.m_clip = param1;
         this.m_callback = param2;
         this.m_inviteBtn = new ZGameButton(this.m_clip.card_mc.buy_bt,this.m_callback);
         this.m_inviteBtn.text = ZGameUtils.ZlocT("Dialogs","AddAllies");
         if(this.m_callback != null)
         {
            this.m_clip.card_mc.addEventListener(MouseEvent.CLICK,this.m_callback,false,0,true);
         }
         this.m_clip.card_mc.buttonMode = true;
         this.m_clip.card_mc.useHandCursor = true;
      }
      
      public function dispose() : void
      {
         if(this.m_inviteBtn)
         {
            this.m_inviteBtn.dispose();
            this.m_inviteBtn = null;
         }
         if(this.m_callback != null)
         {
            this.m_clip.card_mc.removeEventListener(MouseEvent.CLICK,this.m_callback);
            this.m_callback = null;
         }
      }
   }
}

