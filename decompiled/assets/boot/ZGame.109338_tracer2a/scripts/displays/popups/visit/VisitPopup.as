package displays.popups.visit
{
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.MatchMakingManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class VisitPopup extends GallantPopup
   {
      
      private var m_loaders:Array = null;
      
      private var m_visitBonus:Object = null;
      
      private var m_acceptButton:ZGameButton = null;
      
      private var m_hostPlayer:Player = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function VisitPopup(param1:Player, param2:Object)
      {
         this.m_hostPlayer = param1;
         this.m_visitBonus = param2;
         var _loc3_:String = "assets/displays/screens/NeighborVisit.swf";
         super(ZGlobal.getAssetURL(_loc3_));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      private function get screen() : MovieClip
      {
         return m_window.popupBox_mc;
      }
      
      private function get titleTextLabel() : String
      {
         if(this.m_hostPlayer.uid == Player.FAKE_PLAYER_ID)
         {
            return "friend_visit_reward_title_advisor";
         }
         return "friend_visit_reward_title";
      }
      
      override protected function initializeScreen() : void
      {
         var _loc2_:String = null;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         this.m_loaders = new Array();
         this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(this.m_hostPlayer.snUser.picture,this.screen.icon));
         this.screen.rewardText_01.text = "";
         TextFieldUtil.processTextField(this.screen.rewardText_02,ZGameUtils.ZlocT("Main","EnergyAction",{"num":this.m_visitBonus.energy}));
         this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/EnergyBattery01_96.png"),this.screen.rewardIcon_02));
         this.screen.rewardText_03.text = "";
         var _loc1_:String = "FeedPopups";
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            _loc1_ = "Dialogs";
            _loc2_ = "MM_FriendVisitRewardTitle";
         }
         else
         {
            _loc2_ = this.titleTextLabel;
         }
         TextFieldUtil.processTextField(this.screen.VisitTitle,ZGameUtils.ZlocT(_loc1_,_loc2_,{"neighbor":ZLoc.tn(this.m_hostPlayer.firstName,this.m_hostPlayer.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)}));
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            if(MatchMakingManager.IsAddFBButtonExpON())
            {
               this.m_acceptButton = new ZGameButton(this.screen.accept_bt,this.onAddFriend);
               this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","MM_AddFBFriendButton");
            }
            else
            {
               this.m_acceptButton = new ZGameButton(this.screen.accept_bt,this.onOkay);
               this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","Okay");
            }
         }
         else if(Boolean(AlliancesManager.instance.isAllianceMember(ZGlobal.hostPlayer.uid)) && !ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid])
         {
            this.m_acceptButton = new ZGameButton(this.screen.accept_bt,this.onOkay);
            this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","Okay");
         }
         else
         {
            this.m_acceptButton = new ZGameButton(this.screen.accept_bt,this.onShareClicked);
            if(this.m_hostPlayer.uid == Player.FAKE_PLAYER_ID)
            {
               this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","Okay");
            }
            else
            {
               this.m_acceptButton.text = ZGameUtils.ZlocT("Dialogs","Share");
            }
         }
         this.m_buttonSounds.addButton(this.m_acceptButton.m_overlay,ButtonSound.DEFAULT);
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked,false,0,true);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         if(this.screen.VisitBody)
         {
            this.screen.VisitBody.visible = false;
         }
         super.initializeScreen();
      }
      
      protected function onAddFriend(param1:MouseEvent) : void
      {
         MatchMakingManager.ShowFBFriendRequestDialog(ZGlobal.hostPlayer.uid);
         close();
      }
      
      private function onOkay(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onShareClicked(param1:MouseEvent) : void
      {
         if(this.m_hostPlayer.uid != Player.FAKE_PLAYER_ID)
         {
            ViralsManager.instance.sendFeed("friend_helped",{},this.m_hostPlayer.uid);
         }
         close();
      }
      
      private function onCloseClicked(param1:MouseEvent = null) : void
      {
         close();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         super.deinitDialog();
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_acceptButton.dispose();
         this.m_acceptButton = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
      }
   }
}

