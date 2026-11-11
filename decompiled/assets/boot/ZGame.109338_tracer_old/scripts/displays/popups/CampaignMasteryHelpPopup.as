package displays.popups
{
   import core.ZGlobal;
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
   
   public class CampaignMasteryHelpPopup extends ZGamePopUp
   {
      
      public static const SHARE_TOKEN:String = "sharetoken";
      
      private var m_closeBtn:ZGameButton = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_amount:uint = 0;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function CampaignMasteryHelpPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/PU_MasteryHelp.swf"));
      }
      
      public static function display() : void
      {
         WindowManager.instance.push(new CampaignMasteryHelpPopup());
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         initDialog();
         var _loc2_:Class = param1.getAssetClass("GlobalReminder_mc");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.panel_mc.width;
         this.contentHeight = m_window.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","MasteryHelpTitle"));
         TextFieldUtil.processTextField(m_window.generic_tf,ZGameUtils.ZlocT("Dialogs","MasteryHelpDescription"));
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
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
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.dispose();
         super.close(param1);
      }
   }
}

