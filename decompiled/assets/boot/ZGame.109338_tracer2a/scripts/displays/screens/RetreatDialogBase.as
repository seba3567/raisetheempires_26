package displays.screens
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class RetreatDialogBase extends ZGamePopUp
   {
      
      private var m_ransomDialog:MovieClip = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_itemIconLoader:ImageLoader;
      
      protected var m_battleClass:String = "none";
      
      protected var m_battleFamily:String = "none";
      
      public function RetreatDialogBase()
      {
         this.determineBattleMode();
         super(ZGlobal.getAssetURL(this.assetUrl));
      }
      
      protected function get dialogMC() : MovieClip
      {
         return this.m_ransomDialog;
      }
      
      protected function determineBattleMode() : void
      {
      }
      
      protected function get assetUrl() : String
      {
         return "assets/displays/dialogs/PU_Ransom_DialogBubble.swf";
      }
      
      protected function get ransomString() : String
      {
         return "";
      }
      
      protected function get ransomTitle() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Ransom_Title");
      }
      
      protected function get ransomButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Ransom_RetreatButton");
      }
      
      protected function get iconUrl() : String
      {
         return "";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("RansomDialog");
         this.m_ransomDialog = new _loc2_();
         contentWidth = this.m_ransomDialog.width;
         contentHeight = this.m_ransomDialog.height;
         this.initDialog();
         TextFieldUtil.processTextField(this.m_ransomDialog.generic01_mc.title_tf,this.ransomTitle);
         TextFieldUtil.processTextField(this.m_ransomDialog.generic01_mc.message_tf,this.ransomString);
         this.m_button = new ZGameButton(this.m_ransomDialog.generic01_mc.accept_bt,this.onClicked);
         this.m_button.compactText(this.ransomButtonText,null);
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_ransomDialog.generic01_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_buttonSounds.addButton(this.m_ransomDialog.generic01_mc.exit_bt,ButtonSound.DEFAULT);
         var _loc3_:String = this.iconUrl;
         if(_loc3_)
         {
            this.m_itemIconLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,this.m_ransomDialog.generic01_mc.icon);
            this.m_itemIconLoader.smooth = true;
         }
         addChild(this.m_ransomDialog);
      }
      
      override protected function initDialog() : void
      {
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         super.initDialog();
         StatsManager.count("dialog","ransom","view",this.m_battleClass,this.m_battleFamily);
      }
      
      protected function handlePayRansom() : Boolean
      {
         return false;
      }
      
      protected function get ransomFailureString() : String
      {
         return "";
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = this.handlePayRansom();
         if(_loc2_)
         {
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RANSOM_PAID));
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(this.ransomFailureString,GenericPopup.TYPE_OK));
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RANSOM_CANCELLED));
         }
         StatsManager.count("dialog","ransom","yes",this.m_battleClass,this.m_battleFamily);
         close();
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RANSOM_CANCELLED));
         StatsManager.count("dialog","ransom","no",this.m_battleClass,this.m_battleFamily);
         close();
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         removeChild(this.m_ransomDialog);
      }
   }
}

