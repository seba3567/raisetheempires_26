package core.ui.components.PortraitSlidePick
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import transactions.TAcceptDefenseTowerRepel;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class PortraitSlidePickPVPDefenseTowerRepel extends PortraitSlidePickPVP
   {
      
      private var m_invaderID:String;
      
      private var m_invaderName:String;
      
      private var m_towerItem:GameItem;
      
      private var m_towerIcon:String = "assets/game/buildings/Buildings_Icons.swf/Bldg_Civ_DefensiveTower_Lvl01_Activated_SW_icon_notrans.png";
      
      public function PortraitSlidePickPVPDefenseTowerRepel(param1:IEntity, param2:Player, param3:IPVPPlayer, param4:Number, param5:Class, param6:Object)
      {
         var _loc7_:int = 0;
         if(Boolean(param6) && param6.dCode != undefined)
         {
            this.m_towerItem = GameItem(ZGlobal.gameSettings.getItemByCode(param6.dCode,GameItem));
            if(this.m_towerItem)
            {
               _loc7_ = 0;
               while(_loc7_ < this.m_towerItem.xml.image.length())
               {
                  if(this.m_towerItem.xml.image[_loc7_].@name == "repel")
                  {
                     this.m_towerIcon = this.m_towerItem.xml.image[_loc7_].@url;
                  }
                  _loc7_++;
               }
            }
         }
         this.m_invaderID = param3.uid;
         this.m_invaderName = param3.firstName;
         super(param1,param2,param4,param5,param6);
      }
      
      override protected function getCommentListenerType() : String
      {
         return PVPManager.UPDATE_COMMENT;
      }
      
      override protected function getPortraitURL(param1:IPVPPlayer) : String
      {
         return ZGlobal.getAssetURL(this.m_towerIcon);
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         super.onCreatePickAsset(param1);
         if(this.m_towerItem)
         {
            TextFieldUtil.processTextField(slideCard.title_tf,this.m_towerItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         }
         else
         {
            TextFieldUtil.processTextField(slideCard.title_tf,ZGameUtils.ZlocT("Dialogs","defenseTowerRepelTitle"));
         }
         TextFieldUtil.processTextField(portraitBubble.generic_tf,ZGameUtils.ZlocT("Dialogs","defenseTowerRepelPortrait"));
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
         m_askForHelpButton.disable_visual();
      }
      
      override protected function onRepel(param1:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TAcceptDefenseTowerRepel(this.m_invaderID),true);
         PVPManager.instance.acceptRepelLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         PVPManager.instance.rejectDefenseTowerDefendedLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
      
      override protected function setPickText() : void
      {
         m_repelButton.text = ZGameUtils.ZlocT("Dialogs","Accept");
         m_askForHelpButton.text = ZGameUtils.ZlocT("Dialogs","AcceptShare");
         TextFieldUtil.processTextField(slideCard.title01_tf,ZGameUtils.ZlocT("Dialogs","defenseTowerRepelText"));
      }
      
      override protected function setupIcon() : void
      {
      }
      
      override protected function getCommentText() : String
      {
         return null;
      }
   }
}

