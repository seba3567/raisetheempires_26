package displays.screens.oreInviteScreen
{
   import Engine.Managers.StatsManager;
   import ZLocalization.LocalizationName;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.FriendManager;
   import core.managers.WorldResourceManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import fl.containers.UILoader;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class OreInvite extends GallantPopup
   {
      
      private static var m_showing:Boolean;
      
      private var m_clip:MovieClip;
      
      private var m_inviteButton:ZGameButton;
      
      private var m_imageLoaders:Array = new Array();
      
      private var m_cardClass:Class;
      
      private var m_container:MovieClip = new MovieClip();
      
      private var m_closeCallback:Function;
      
      private var m_soundContainer:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_playersVisible:Array = new Array();
      
      private var m_invitableFriends:Array = new Array();
      
      private var m_portraitCardCenterX:int = 0;
      
      private var m_portraitCardCenterY:int = 0;
      
      private var m_portraitCardDefaultWidth:int = 0;
      
      private var m_portraitCardDefaultHeight:int = 0;
      
      private const CARD_SPACING:int = -15;
      
      public function OreInvite(param1:Function = null)
      {
         this.m_closeCallback = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_OreInvite.swf"));
         m_showing = true;
      }
      
      public static function onFriendInfoLoaded(param1:Event) : void
      {
         var _loc2_:OreInvite = null;
         if(!m_showing && shouldShowSplashScreen())
         {
            _loc2_ = new OreInvite();
            PopupManager.instance.push(_loc2_,0,true);
         }
      }
      
      public static function checkQuestGate() : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc1_:String = ZGlobal.gameSettings.getString("OreNeighborMOTDRequiredQuest","");
         if(_loc1_.length)
         {
            _loc2_ = false;
            _loc3_ = _loc1_.split(",");
            for each(_loc4_ in _loc3_)
            {
               if(ZGlobal.player.didCompleteQuest(_loc4_))
               {
                  _loc2_ = true;
                  break;
               }
            }
            if(!_loc2_)
            {
               return false;
            }
         }
         return true;
      }
      
      private static function shouldShowSplashScreen() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_splash_ore_invite");
         if(_loc1_ < 1)
         {
            return false;
         }
         if(!checkQuestGate())
         {
            return false;
         }
         return true;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_cardClass = param1.getAssetClass("OrePlayerCard");
         super.onLoadComplete(param1);
      }
      
      override protected function initializeScreen() : void
      {
         this.m_clip = m_window.oreInvite_mc;
         this.m_inviteButton = new ZGameButton(this.m_clip.green_bt,this.onInviteClicked);
         this.m_inviteButton.text = ZGameUtils.ZlocT("Dialogs","Close");
         this.m_soundContainer.addButton(this.m_inviteButton.m_overlay,ButtonSound.DEFAULT);
         this.setupStrings();
         if(FriendManager.instance.friendInfoReceived)
         {
            this.setupSlots();
            this.m_clip.status_tf.visible = false;
         }
         else
         {
            FriendManager.instance.startQueryTimerImmediate();
            FriendManager.instance.addEventListener(FriendManager.FRIEND_INFO_RECEIVED,this.onFriendInfoReceived,false,0,true);
            this.setupDelayedLoad();
         }
         this.m_clip.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked,false,0,true);
         this.m_soundContainer.addButton(this.m_clip.exit_bt,ButtonSound.DEFAULT);
         contentWidth = this.m_clip.panel_mc.width;
         contentHeight = this.m_clip.panel_mc.height;
         this.m_clip.anchor_mc.visible = false;
         super.initializeScreen();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:MovieClip = null;
         FriendManager.instance.removeEventListener(FriendManager.FRIEND_INFO_RECEIVED,this.onFriendInfoReceived);
         this.m_clip.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         if(this.m_soundContainer)
         {
            this.m_soundContainer.release();
            this.m_soundContainer = null;
         }
         if(this.m_inviteButton)
         {
            this.m_inviteButton.dispose();
            this.m_inviteButton = null;
         }
         if(this.m_imageLoaders)
         {
            for each(_loc1_ in this.m_imageLoaders)
            {
               _loc1_.destroy();
            }
            this.m_imageLoaders = null;
         }
         if(this.m_container)
         {
            if(this.m_container.parent)
            {
               this.m_container.parent.removeChild(this.m_container);
            }
            while(this.m_container.numChildren)
            {
               _loc2_ = this.m_container.getChildAt(0) as MovieClip;
               if(_loc2_)
               {
                  if(_loc2_.uiloader)
                  {
                     this.enablePortraitMouseListeners(false,_loc2_.uiloader);
                     Tooltip.unsubscribe(_loc2_.uiloader);
                  }
                  this.m_container.removeChild(_loc2_);
               }
            }
            this.m_container = null;
         }
         this.m_clip = null;
         m_showing = false;
         super.deinitDialog();
      }
      
      private function setupStrings() : void
      {
         TextFieldUtil.processTextField(this.m_clip.header_tf,ZGameUtils.ZlocT("Dialogs","OreOverviewTitle"));
         TextFieldUtil.processTextField(this.m_clip.description_tf,ZGameUtils.ZlocT("Dialogs","OreOverviewSpeech"));
         TextFieldUtil.processTextField(this.m_clip.description_tf_2,ZGameUtils.ZlocT("Dialogs","OreOverviewHint"));
      }
      
      private function onInviteClicked(param1:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(true);
         }
         this.showFriendInvite();
      }
      
      private function setupSlots() : void
      {
         var _loc1_:Player = null;
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc11_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Array = new Array();
         var _loc6_:int = WorldResourceManager.instance.firstRareResourceIndex;
         var _loc7_:int = WorldResourceManager.instance.numRareResources;
         var _loc8_:Array = FriendManager.instance.getRandomFriends(_loc7_);
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_)
         {
            _loc2_ = _loc6_ + _loc9_;
            _loc13_ = ZGlobal.player.getBestOreInvitee(_loc2_,_loc8_);
            if(_loc13_)
            {
               _loc4_ = this.setupSlot(_loc13_,_loc2_,_loc4_);
            }
            else
            {
               _loc5_.push(_loc2_);
            }
            _loc9_++;
         }
         if(_loc5_.length)
         {
            _loc14_ = this.getRandomFriends(this.m_playersVisible,_loc5_.length);
            if(_loc14_.length == _loc5_.length)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc5_.length)
               {
                  _loc4_ = this.setupSlot(_loc14_[_loc9_],_loc5_[_loc9_],_loc4_);
                  _loc9_++;
               }
            }
         }
         var _loc10_:int = 0.5 * this.m_clip.anchor_mc.width;
         _loc11_ = 0.5 * this.m_clip.anchor_mc.height;
         this.m_container.x = this.m_clip.anchor_mc.x + (_loc10_ - this.m_container.width * 0.5);
         this.m_container.y = this.m_clip.anchor_mc.y + (_loc11_ - this.m_container.height * 0.5);
         var _loc12_:String = this.m_invitableFriends.length ? "InviteIdleButton" : "Close";
         this.m_inviteButton.text = ZGameUtils.ZlocT("Dialogs",_loc12_);
         this.m_clip.addChild(this.m_container);
      }
      
      private function getRandomFriends(param1:Array, param2:int) : Array
      {
         var _loc5_:Player = null;
         var _loc3_:Array = new Array();
         var _loc4_:Array = ZGlobal.player.friends;
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.uid != Player.FAKE_PLAYER_ID)
            {
               if(param1.indexOf(_loc5_.uid) < 0)
               {
                  if(Math.random() < 0.5)
                  {
                     _loc3_.push(_loc5_);
                  }
                  else
                  {
                     _loc3_.unshift(_loc5_);
                  }
               }
            }
         }
         if(_loc3_.length >= param2)
         {
            return _loc3_.splice(0,param2);
         }
         return [];
      }
      
      private function setupSlot(param1:Object, param2:int, param3:int) : int
      {
         var _loc5_:String = null;
         var _loc4_:MovieClip = new this.m_cardClass();
         this.m_playersVisible.push(param1.uid);
         var _loc6_:Boolean = Boolean(ZGlobal.player.neighbors[param1.uid]);
         if(_loc6_)
         {
            _loc5_ = "OreInviteAlreadyNeighborsTooltip";
         }
         else
         {
            this.m_invitableFriends.push(param1.uid);
            _loc5_ = "OreInviteInviteNeighborTooltip";
         }
         var _loc7_:String = param1.genderTag;
         _loc7_ = _loc7_ == "M" ? ZGlobal.localizer.MASC : ZGlobal.localizer.FEM;
         var _loc8_:LocalizationName = ZGameUtils.ZlocTn(param1.firstName,_loc7_);
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs",_loc5_,{"user":_loc8_});
         Tooltip.subscribe(_loc4_.uiloader,_loc9_);
         this.m_portraitCardCenterX = _loc4_.uiloader.x + _loc4_.uiloader.width * 0.5;
         this.m_portraitCardCenterY = _loc4_.uiloader.y + _loc4_.uiloader.height * 0.5;
         this.m_portraitCardDefaultWidth = _loc4_.uiloader.width;
         this.m_portraitCardDefaultHeight = _loc4_.uiloader.height;
         TextFieldUtil.processTextField(_loc4_.count_tf,param1.firstName);
         var _loc10_:String = WorldResourceManager.instance.getResourceImageURL(param2,WorldResourceManager.LARGE_ICON);
         var _loc11_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc10_,_loc4_.ore_mc);
         _loc11_.smooth = true;
         if(_loc11_)
         {
            this.m_imageLoaders.push(_loc11_);
         }
         _loc11_ = ImageLoaderFactory.CreateImageLoader(param1.portraitURL,_loc4_.uiloader);
         if(!_loc6_)
         {
            this.enablePortraitMouseListeners(true,_loc4_.uiloader);
         }
         this.m_soundContainer.addButton(_loc4_.uiloader,ButtonSound.DEFAULT);
         if(_loc11_)
         {
            this.m_imageLoaders.push(_loc11_);
         }
         this.m_container.addChild(_loc4_);
         _loc4_.x = param3;
         return param3 + _loc4_.width + this.CARD_SPACING;
      }
      
      private function enablePortraitMouseListeners(param1:Boolean, param2:EventDispatcher) : void
      {
         if(param2)
         {
            if(param1)
            {
               param2.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
               param2.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
               param2.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
               param2.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
            }
            else
            {
               param2.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               param2.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               param2.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
               param2.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
            }
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.adjustUILoaderSize(param1.currentTarget as UILoader,5);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.adjustUILoaderSize(param1.currentTarget as UILoader,0);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.adjustUILoaderSize(param1.currentTarget as UILoader,-5);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this.adjustUILoaderSize(param1.currentTarget as UILoader,0);
         this.showFriendInvite();
      }
      
      private function showFriendInvite() : void
      {
         StatsManager.count("dialog","OreInvite","yes");
         var _loc1_:String = "invite.php?inviteType=rareOreInvite&track=9";
         if(this.m_invitableFriends.length)
         {
            _loc1_ += "&recipients=" + this.m_invitableFriends.join(",");
            ZGlobal.navigateImmediatelyTo(_loc1_);
         }
         close();
      }
      
      private function adjustUILoaderSize(param1:DisplayObject, param2:int) : void
      {
         param1.width = this.m_portraitCardDefaultWidth + param2;
         param1.height = this.m_portraitCardDefaultHeight + param2;
         param1.x = this.m_portraitCardCenterX - param1.width * 0.5;
         param1.y = this.m_portraitCardCenterY - param1.height * 0.5;
      }
      
      private function onCloseClicked(param1:MouseEvent) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(false);
         }
         StatsManager.count("dialog","OreInvite","no");
         close();
      }
      
      private function onFriendInfoReceived(param1:Event) : void
      {
         FriendManager.instance.removeEventListener(FriendManager.FRIEND_INFO_RECEIVED,this.onFriendInfoReceived);
         this.setupSlots();
         this.cleanupDelayedLevelLoad();
      }
      
      private function cleanupDelayedLevelLoad() : void
      {
         this.m_clip.status_tf.visible = false;
      }
      
      private function setupDelayedLoad() : void
      {
         this.m_clip.status_tf.mouseEnabled = false;
         var _loc1_:int = this.m_clip.numChildren;
         this.m_clip.setChildIndex(this.m_clip.status_tf,_loc1_ - 1);
         TextFieldUtil.processTextField(this.m_clip.status_tf,ZGameUtils.ZlocT("Dialogs","MarketGuestLoadingMessage"));
      }
   }
}

