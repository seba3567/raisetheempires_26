package displays.popups
{
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarUIItem;
   import dispatchers.NeighborsDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   
   public class InviteIdlePopup extends GallantPopup
   {
      
      private static var m_friendOffset:int = 0;
      
      private var m_callback:Function = null;
      
      private var m_acceptBtn:ZGameButton = null;
      
      private var m_delayedAccept:Boolean = false;
      
      private var m_imageLoaders:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_friendZids:Array;
      
      public function InviteIdlePopup(param1:Function = null)
      {
         this.m_callback = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_InviteIdle.swf"));
      }
      
      public function get friendZids() : Array
      {
         return this.m_friendZids;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         TextFieldUtil.processTextField(m_window.popup_mc.title_tf,ZGameUtils.ZlocT("Dialogs","InviteIdleTitle"));
         TextFieldUtil.processTextField(m_window.popup_mc.tip_tf,ZGameUtils.ZlocT("Dialogs","InviteIdleCaption"));
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_acceptBtn = new ZGameButton(m_window.popup_mc.accept_bt,this.onAcceptButton);
         this.m_acceptBtn.text = ZGameUtils.ZlocT("Dialogs","InviteIdleButton");
         this.m_buttonSounds.addButton(this.m_acceptBtn.m_overlay,ButtonSound.DEFAULT);
         m_window.popup_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         this.m_buttonSounds.addButton(m_window.popup_mc.exit_bt,ButtonSound.DEFAULT);
         if(this.m_callback != null)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_callback,false,0,true);
         }
         this.m_imageLoaders = new Array();
         this.checkFriendCards();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_imageLoaders = null;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_acceptBtn.dispose();
         m_window.popup_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         super.deinitDialog();
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
         if(this.m_delayedAccept)
         {
            dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         }
         if(this.m_callback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_callback);
         }
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.INVITE_FRIENDS_CONTINUE));
         }
         if(NeighborsDispatcher.instance.hasEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED))
         {
            NeighborsDispatcher.instance.removeEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.populateFriendCards);
         }
      }
      
      private function onAcceptButton(param1:MouseEvent) : void
      {
         this.m_delayedAccept = true;
         this.close();
      }
      
      private function onExitButton(param1:MouseEvent = null) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         this.close();
      }
      
      private function checkFriendCards() : void
      {
         var _loc1_:Array = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).suggestedNeighbors;
         if(_loc1_ == null)
         {
            NeighborsDispatcher.instance.addEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.populateFriendCards,false,0,true);
            FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).forceSuggestedNeighborTransaction();
         }
         else
         {
            this.populateFriendCards(null);
         }
      }
      
      private function populateFriendCards(param1:Event) : void
      {
         var _loc6_:int = 0;
         if(NeighborsDispatcher.instance.hasEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED))
         {
            NeighborsDispatcher.instance.removeEventListener(FriendsBarUIItem.SUGGESTED_NEIGHBORS_RECEIVED,this.populateFriendCards);
         }
         var _loc2_:Array = [m_window.popup_mc.cards_mc.card0,m_window.popup_mc.cards_mc.card1,m_window.popup_mc.cards_mc.card2];
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:Array = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).suggestedNeighbors;
         var _loc5_:* = 0;
         if(Boolean(_loc4_) && _loc4_.length > 0)
         {
            switch(_loc4_.length)
            {
               case 1:
                  m_window.popup_mc.cards_mc.x = m_window.popup_mc.anchor1_mc.x;
                  _loc3_ = 1;
                  break;
               case 2:
                  m_window.popup_mc.cards_mc.x = m_window.popup_mc.anchor2_mc.x;
                  _loc3_ = 2;
                  break;
               default:
                  m_window.popup_mc.cards_mc.x = m_window.popup_mc.anchor3_mc.x;
            }
            this.m_friendZids = new Array();
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc6_ = (FriendsBarUIItem.suggestedNeighborOffset + _loc5_) % _loc4_.length;
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc4_[_loc6_].pic_square,_loc2_[_loc5_].icon));
               this.m_friendZids.push(_loc4_[_loc6_].zid);
               TextFieldUtil.processTextField(_loc2_[_loc5_].generic_tf,_loc4_[_loc6_].first_name);
               _loc2_[_loc5_].visible = true;
               _loc5_++;
            }
            FriendsBarUIItem.suggestedNeighborOffset = (FriendsBarUIItem.suggestedNeighborOffset + _loc3_) % _loc4_.length;
         }
         else
         {
            this.onExitButton();
         }
         while(_loc5_ < _loc2_.length)
         {
            _loc2_[_loc5_++].visible = false;
         }
      }
   }
}

