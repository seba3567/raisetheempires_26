package displays.popups.battlewon
{
   import core.ZGlobal;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class VillainTokenAwardedPopup extends ZGamePopUp
   {
      
      private var m_closeBtn:ZGameButton = null;
      
      private var m_shareBtn:ZGameButton = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_amount:uint = 0;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function VillainTokenAwardedPopup(param1:uint)
      {
         this.m_amount = param1;
         super(ZGlobal.getAssetURL("assets/displays/screens/PU_MasteryToken.swf"));
      }
      
      public static function display(param1:uint) : void
      {
         WindowManager.instance.push(new VillainTokenAwardedPopup(param1));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         initDialog();
         var _loc2_:Class = param1.getAssetClass("MasteryToken_mc");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.panel_mc.width;
         this.contentHeight = m_window.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","VillainTokenRewardTitle"));
         TextFieldUtil.processTextField(m_window.value_tf,"x1");
         TextFieldUtil.processTextField(m_window.generic_tf,ZGameUtils.ZlocT("Dialogs","VillainTokenRewardDescription"));
         TextFieldUtil.processTextField(m_window.ask_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","ShareCampaignWon"));
         this.m_shareBtn = new ZGameButton(m_window.ask_bt,this.onShare);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_shareBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         m_window.exit_bt.visible = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function dispose() : void
      {
         deinitDialog();
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.close);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_shareBtn.dispose();
         this.m_shareBtn = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.dispose();
         super.close(param1);
      }
      
      protected function onShare(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeed("villain_token_earned",{
            "itemCode":"VTK",
            "ITEMTOKitem":"campaignmasterytoken" + "|"
         });
         this.close();
      }
   }
}

