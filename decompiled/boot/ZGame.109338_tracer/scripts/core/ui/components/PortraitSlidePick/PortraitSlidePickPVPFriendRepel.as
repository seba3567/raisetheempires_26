package core.ui.components.PortraitSlidePick
{
   import Engine.Managers.TransactionManager;
   import core.managers.PVPManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import displays.popups.CommentPopup;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import transactions.TAcceptFriendRepel;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   
   public class PortraitSlidePickPVPFriendRepel extends PortraitSlidePickPVP
   {
      
      private var m_invaderID:String;
      
      private var m_neighborName:String;
      
      private var m_invaderName:String;
      
      public function PortraitSlidePickPVPFriendRepel(param1:IEntity, param2:Player, param3:IPVPPlayer, param4:Number, param5:Class, param6:Object)
      {
         super(param1,param2,param4,param5,param6);
         this.m_invaderID = param3.uid;
         this.m_invaderName = param3.firstName;
         this.m_neighborName = param2.firstName;
      }
      
      override protected function getCommentListenerType() : String
      {
         return PVPManager.UPDATE_COMMENT;
      }
      
      override public function dispose() : void
      {
         if(slideCard.exit_bt1)
         {
            slideCard.exit_bt1.removeEventListener(MouseEvent.CLICK,this.onExit);
         }
         super.dispose();
      }
      
      override protected function setButtons() : void
      {
         super.setButtons();
         if(slideCard.exit_bt0)
         {
            slideCard.exit_bt0.visible = false;
         }
         if(slideCard.exit_bt1)
         {
            slideCard.exit_bt1.addEventListener(MouseEvent.CLICK,this.onExit);
            m_buttonSounds.addButton(slideCard.exit_bt1,ButtonSound.DEFAULT);
         }
      }
      
      override protected function onRepel(param1:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TAcceptFriendRepel(this.m_invaderID),true);
         PVPManager.instance.acceptRepelLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
      
      override protected function onAskForHelp(param1:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TAcceptFriendRepel(this.m_invaderID),true);
         var _loc2_:Object = {
            "target":neighborID,
            "invader":this.m_invaderName,
            "defender":this.m_neighborName,
            "recipientIcon":m_neighbor.portraitURL
         };
         PopupManager.instance.push(new CommentPopup(ViralsManager.instance.onThankDefenderCommentClosed,_loc2_));
         PVPManager.instance.acceptRepelLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         PVPManager.instance.rejectFriendDefendedLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
      
      override protected function setPickText() : void
      {
         m_repelButton.text = ZGameUtils.ZlocT("Dialogs","Accept");
         m_askForHelpButton.text = ZGameUtils.ZlocT("Dialogs","AcceptShare");
         TextFieldUtil.processTextField(slideCard.title01_tf,ZGameUtils.ZlocT("Dialogs","friendRepelText"));
      }
      
      override protected function setupIcon() : void
      {
      }
      
      override protected function getCommentText() : String
      {
         if(Boolean(m_invader) && Boolean(m_invader.dTxt))
         {
            return m_invader.dTxt;
         }
         return null;
      }
   }
}

