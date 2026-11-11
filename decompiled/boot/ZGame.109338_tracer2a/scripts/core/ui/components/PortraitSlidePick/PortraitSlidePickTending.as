package core.ui.components.PortraitSlidePick
{
   import ZLocalization.LocalizationName;
   import com.greensock.TweenMax;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class PortraitSlidePickTending extends PortraitSlidePick
   {
      
      private var m_acceptButton:ZGameButton;
      
      private var m_rejectButton:ZGameButton;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function PortraitSlidePickTending(param1:IPVPPlayer, param2:Number)
      {
         super(param1,param2);
      }
      
      public function actionFeedback(param1:Number) : void
      {
         TweenMax.to(portraitBubble,param1 * 0.5,{
            "y":"-25",
            "yoyo":true,
            "repeat":1
         });
      }
      
      override protected function onDispose() : void
      {
         super.onDispose();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
            this.m_acceptButton = null;
         }
         if(this.m_rejectButton)
         {
            this.m_rejectButton.dispose();
            this.m_rejectButton = null;
         }
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         super.onCreatePickAsset(param1);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_acceptButton = new ZGameButton(slideCard.accept_bt,this.onAccept);
         this.m_buttonSounds.addButton(this.m_acceptButton.m_overlay,ButtonSound.DEFAULT);
         this.m_rejectButton = new ZGameButton(slideCard.reject_bt,this.onReject);
         this.m_buttonSounds.addButton(this.m_rejectButton.m_overlay,ButtonSound.DEFAULT);
         this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","AcceptButton");
         this.m_rejectButton.text = ZGameUtils.ZlocT("Dialogs","RejectButton");
         var _loc2_:LocalizationName = ZLoc.tn(param1.firstName,param1.genderTag);
         TextFieldUtil.processTextField(slideCard.popupBox_tf,ZGameUtils.ZlocT("Dialogs","AcceptHelpPrompt",{"name":_loc2_}));
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         if(status == PortraitSlidePick.PICK_STATUS_SHOWING)
         {
            dispatchEvent(new Event(PortraitSlidePick.ACCEPTED));
            hide();
            hidePick(param1);
         }
      }
      
      private function onReject(param1:MouseEvent) : void
      {
         if(status == PortraitSlidePick.PICK_STATUS_SHOWING)
         {
            dispatchEvent(new Event(PortraitSlidePick.REJECTED));
            hidePick(param1);
            status = PortraitSlidePick.PICK_STATUS_REJECTED;
         }
      }
   }
}

