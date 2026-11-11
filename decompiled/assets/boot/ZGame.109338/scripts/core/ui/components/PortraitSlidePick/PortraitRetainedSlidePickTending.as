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
   import zgame.assets.ui.NeighborPickDismiss;
   
   public class PortraitRetainedSlidePickTending extends PortraitSlidePick
   {
      
      protected static const PICK_STATUS_GIFTANDDISSMISS:int = 4;
      
      private var m_acceptButton:ZGameButton;
      
      private var m_rejectButton:ZGameButton;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function PortraitRetainedSlidePickTending(param1:IPVPPlayer, param2:Number)
      {
         super(param1,param2);
      }
      
      override protected function getPickClass() : Class
      {
         return NeighborPickDismiss;
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
         this.m_acceptButton = new ZGameButton(slideCard.visit_bt,this.onVisit);
         this.m_buttonSounds.addButton(this.m_acceptButton.m_overlay,ButtonSound.DEFAULT);
         this.m_rejectButton = new ZGameButton(slideCard.dismiss_bt,this.onDismissAndGift);
         this.m_buttonSounds.addButton(this.m_rejectButton.m_overlay,ButtonSound.DEFAULT);
         this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","Visit");
         this.m_rejectButton.text = ZGameUtils.ZlocT("Dialogs","GiftAndDismiss");
         var _loc2_:LocalizationName = ZLoc.tn(param1.firstName,param1.genderTag);
         TextFieldUtil.processTextField(slideCard.popupBox_tf,ZGameUtils.ZlocT("Dialogs","RetainVisit",{"name":_loc2_}));
      }
      
      private function onVisit(param1:MouseEvent) : void
      {
         if(status == PICK_STATUS_SHOWING)
         {
            dispatchEvent(new Event(PortraitRetainedSlidePick.VISIT));
            hide();
            hidePick(param1);
         }
      }
      
      private function onDismissAndGift(param1:MouseEvent) : void
      {
         if(status == PICK_STATUS_SHOWING)
         {
            dispatchEvent(new Event(PortraitRetainedSlidePick.GiftAndDismiss));
            hidePick(param1);
            status = PICK_STATUS_GIFTANDDISSMISS;
         }
      }
   }
}

