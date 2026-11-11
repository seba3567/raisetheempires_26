package displays.screens.dominationMode
{
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class DominationScoutWarningPopup extends ZGamePopUp
   {
      
      private static const ASSETPATH:String = "assets/displays/dialogs/PU_Pvp_Ransom.swf";
      
      private static const ASSETCLASS:String = "RansomDialog";
      
      private var m_dialog:MovieClip;
      
      private var m_iconLoader:ImageLoader;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_proceedButton:ZGameButton;
      
      private var m_redoButton:ZGameButton;
      
      private var m_editorType:int;
      
      public function DominationScoutWarningPopup(param1:int)
      {
         this.m_editorType = param1;
         super(ZGlobal.getAssetURL(ASSETPATH));
      }
      
      public static function shouldShowWarning() : Boolean
      {
         return false;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass(ASSETCLASS);
         this.m_dialog = new _loc2_();
         contentWidth = this.m_dialog.width;
         contentHeight = this.m_dialog.height;
         centerWithinStage(Zlab.mainStage);
         var _loc3_:String = "assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_60.png";
         var _loc4_:String = ZGlobal.getAssetURL(_loc3_);
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.m_dialog.generic01_mc.icon);
         this.m_iconLoader.smooth = true;
         this.m_dialog.generic01_mc.accept_bt.visible = false;
         this.m_dialog.generic01_mc.exit_bt.visible = false;
         this.m_proceedButton = new ZGameButton(this.m_dialog.generic01_mc.orange_bt,this.onProceedClicked);
         this.m_redoButton = new ZGameButton(this.m_dialog.generic01_mc.red_bt,this.onRedoClicked);
         this.m_proceedButton.text = ZGameUtils.ZlocT("Dialogs","DominanceScoutWarningProceed");
         this.m_redoButton.text = ZGameUtils.ZlocT("Dialogs","DominanceScoutWarningRedo");
         this.m_buttonSounds.addButton(this.m_proceedButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_redoButton.m_overlay,ButtonSound.DEFAULT);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","DominanceScoutWarningTitle");
         TextFieldUtil.processTextField(this.m_dialog.generic01_mc.title_tf,_loc5_);
         var _loc6_:String = ZGameUtils.ZlocT("Dialogs",this.msgKey);
         TextFieldUtil.processTextField(this.m_dialog.generic01_mc.message_tf,_loc6_);
         addChild(this.m_dialog);
      }
      
      private function get msgKey() : String
      {
         if(this.m_editorType == DominationModeManager.DOMINATION_PREBATTLE_ATTACK_EDITOR)
         {
            return "DominanceScoutWarningMessage";
         }
         return "DominanceDefenseFleetWarningMessage";
      }
      
      private function onProceedClicked(param1:MouseEvent) : void
      {
         close();
         dispatchEvent(new WorldEvent(Event.CLOSE,{"proceed":true}));
      }
      
      private function onRedoClicked(param1:MouseEvent) : void
      {
         close();
         dispatchEvent(new WorldEvent(Event.CLOSE,{"proceed":false}));
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
         }
         if(this.m_proceedButton)
         {
            this.m_proceedButton.dispose();
            this.m_proceedButton = null;
         }
         if(this.m_redoButton)
         {
            this.m_redoButton.dispose();
            this.m_redoButton = null;
         }
         this.m_buttonSounds.release();
         super.deinitDialog();
      }
   }
}

