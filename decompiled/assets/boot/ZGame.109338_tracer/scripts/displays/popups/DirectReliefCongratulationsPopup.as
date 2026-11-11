package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.DirectReliefPromoUIItem;
   import displays.screens.InventoryDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.managers.PopupManager;
   
   public class DirectReliefCongratulationsPopup extends GallantPopup
   {
      
      public static const FLAG_DIRECT_RELIEF_CONGRATS_POPUP:String = "DirectReliefCongratulationsPopup";
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      private var m_sendButton:ZGameButton;
      
      public function DirectReliefCongratulationsPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Gift.swf"));
      }
      
      public static function show() : void
      {
         var _loc1_:IWindow = null;
         if(!ZGlobal.player.getSeenFlag(DirectReliefCongratulationsPopup.FLAG_DIRECT_RELIEF_CONGRATS_POPUP))
         {
            _loc1_ = new DirectReliefCongratulationsPopup();
            PopupManager.instance.push(_loc1_);
            ZGlobal.player.setSeenFlag(DirectReliefCongratulationsPopup.FLAG_DIRECT_RELIEF_CONGRATS_POPUP);
         }
      }
      
      override protected function initializeScreen() : void
      {
         if(this.clip.giftIcon_mc)
         {
            this.clip.giftIcon_mc.visible = false;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.clip.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         this.m_buttonSounds.addButton(this.clip.exit_bt,ButtonSound.DEFAULT);
         this.m_sendButton = new ZGameButton(this.clip.green_bt,this.onSendClicked);
         this.m_sendButton.text = ZGameUtils.ZlocT("FeedPopups","DirectReliefCongratulationsShare");
         this.m_buttonSounds.addButton(this.m_sendButton.m_overlay,ButtonSound.DEFAULT);
         var _loc1_:String = ZGameUtils.ZlocT("FeedPopups","DirectReliefCongratulationsBody");
         TextFieldUtil.processTextField(this.clip.description_tf,_loc1_);
         TextFieldUtil.compactTextField(this.clip.title_tf,ZGameUtils.ZlocT("FeedPopups","DirectReliefCongratulationsTitle"));
         contentWidth = this.clip.panel_mc.width;
         contentHeight = this.clip.panel_mc.height;
         super.initializeScreen();
      }
      
      private function get clip() : MovieClip
      {
         return m_window.gift_mc;
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_sendButton)
         {
            this.m_sendButton.dispose();
            this.m_sendButton = null;
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.clip.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         super.deinitDialog();
      }
      
      private function showInventoryDialog() : void
      {
         var _loc3_:String = null;
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(DirectReliefPromoUIItem.DEFENSETOWER_3_ITEM_CODE,GameItem) as GameItem;
         var _loc2_:Object = new Object();
         var _loc4_:String = InventoryDialog.getTabLabelString(_loc1_);
         if(_loc4_)
         {
            _loc2_.tab = _loc4_;
            _loc3_ = "BuildingPlacedIntoInventoryTab";
         }
         else
         {
            _loc3_ = "BuildingPlacedIntoInventory";
         }
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs",_loc3_,_loc2_)),100);
         ZGlobal.player.m_showAnnoyingInventoryDialog[_loc1_.subType] = false;
      }
      
      private function onExitButton(param1:MouseEvent) : void
      {
         this.showInventoryDialog();
         close();
      }
      
      private function onSendClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = "direct_pay_share_4:138";
         ViralsManager.instance.sendFeed(_loc2_,{});
         this.showInventoryDialog();
         close();
      }
   }
}

