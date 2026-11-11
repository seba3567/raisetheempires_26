package displays.popups.bomberGame
{
   import core.ZGlobal;
   import core.managers.miniGameManager.BomberGameManager;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class BomberGameTutorialPopup extends ZGamePopUp
   {
      
      public function BomberGameTutorialPopup(param1:String)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/minigameDialog.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip.screen_mc;
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","bomber_tutorial_header"));
         TextFieldUtil.compactTextField(m_window.note_tf,ZGameUtils.ZlocT("Dialogs","bomber_tutorial_desc"));
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         m_window.start_bt.mouseEnabled = true;
         m_window.start_bt.buttonMode = true;
         m_window.start_bt.mouseChildren = false;
         m_window.start_bt.addEventListener(MouseEvent.CLICK,this.onStartClicked);
         TextFieldUtil.compactTextField(m_window.start_bt.generic_tf,ZGameUtils.ZlocT("MessageOfTheDay","motd_bombingRunAccept"));
         ZGlobal.player.setSeenFlag("bombergametutorial");
         centerWithinStage(Zlab.mainStage);
         addChild(m_window);
      }
      
      public function onStartClicked(param1:MouseEvent = null) : void
      {
         close();
         BomberGameManager.instance.startBomberGame();
      }
      
      public function onExit(param1:MouseEvent = null) : void
      {
         close();
      }
   }
}

