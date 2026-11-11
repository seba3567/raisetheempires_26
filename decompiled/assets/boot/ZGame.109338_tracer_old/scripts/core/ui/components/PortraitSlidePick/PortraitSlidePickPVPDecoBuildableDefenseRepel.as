package core.ui.components.PortraitSlidePick
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import flash.events.MouseEvent;
   import transactions.TAcceptDecoBuildableDefenseRepel;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class PortraitSlidePickPVPDecoBuildableDefenseRepel extends PortraitSlidePickPVPDefenseTowerRepel
   {
      
      private var m_invaderID:String;
      
      private var m_invaderName:String;
      
      private var m_towerItem:GameItem;
      
      private var m_decoBuildableIcon:String = "assets/game/buildables/Buildables_Icons_0.swf/AmityNavalStation_01_96.png";
      
      public function PortraitSlidePickPVPDecoBuildableDefenseRepel(param1:IEntity, param2:Player, param3:IPVPPlayer, param4:Number, param5:Class, param6:Object)
      {
         this.m_invaderID = param3.uid;
         this.m_invaderName = param3.firstName;
         if(Boolean(param6) && param6.dCode != undefined)
         {
            this.m_towerItem = GameItem(ZGlobal.gameSettings.getItemByCode(param6.dCode,GameItem));
         }
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function getPortraitURL(param1:IPVPPlayer) : String
      {
         return ZGlobal.getAssetURL(this.m_decoBuildableIcon);
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         super.onCreatePickAsset(param1);
         if(this.m_towerItem)
         {
            TextFieldUtil.compactTextField(slideCard.title_tf,this.m_towerItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         }
         else
         {
            TextFieldUtil.compactTextField(slideCard.title_tf,ZGameUtils.ZlocT("Items","Amity Naval Station_menuName"));
         }
         TextFieldUtil.compactTextField(portraitBubble.generic_tf,ZGameUtils.ZlocT("Items","Amity Naval Station_menuName"));
      }
      
      override protected function setPickText() : void
      {
         m_repelButton.text = ZGameUtils.ZlocT("Dialogs","Accept");
         m_askForHelpButton.text = ZGameUtils.ZlocT("Dialogs","AcceptShare");
         TextFieldUtil.compactTextField(slideCard.title01_tf,ZGameUtils.ZlocT("Dialogs","AmityNavalStationRepelText"));
      }
      
      override protected function setButtons() : void
      {
         super.setButtons();
         m_askForHelpButton.enable();
      }
      
      override protected function onRepel(param1:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TAcceptDecoBuildableDefenseRepel(this.m_invaderID),true);
         PVPManager.instance.acceptRepelLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
      
      override protected function onAskForHelp(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeed("amity_repel",{"invader":this.m_invaderName});
         this.onRepel(param1);
      }
      
      override protected function onExit(param1:MouseEvent) : void
      {
         PVPManager.instance.rejectDecoBuildableDefendedLocal(this.m_invaderID);
         onStopPropagation(param1);
         pickExited();
         hide();
      }
   }
}

