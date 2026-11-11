package displays.popups
{
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.mission.GMDeployMission;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MissionCompletePopup extends ZGamePopUp
   {
      
      private var m_mission:GameItem = null;
      
      private var m_loader:ImageLoader = null;
      
      private var m_deployButton:ZGameButton = null;
      
      private var m_greenButton:ZGameButton = null;
      
      public function MissionCompletePopup(param1:GameItem)
      {
         this.m_mission = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SpecialForces_MissionReady.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         if(Boolean(param1) && !m_window)
         {
            m_window = param1.clip as MovieClip;
         }
         PopupManager.instance.notifyLoadComplete(this);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      override public function onShow() : void
      {
         super.onShow();
         if(m_window != null)
         {
            m_window.x = 0;
            m_window.y = 0;
            addChild(m_window);
            this.contentWidth = m_window.width;
            this.contentHeight = m_window.height;
            m_origOffsetX = m_window.x;
            m_origOffsetY = m_window.y;
            this.initDialog();
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.initIcon();
         this.initText();
         this.initButtons();
      }
      
      private function initIcon() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getImageByName(this.m_mission.name,"icon");
         this.m_loader = ImageLoaderFactory.CreateImageLoader(_loc1_,this.screen.icon,null,null);
      }
      
      private function initText() : void
      {
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","MissionCompleteTitle"));
         TextFieldUtil.processTextField(this.screen.description_tf,ZGameUtils.ZlocT("Dialogs","MissionCompleteDescription",{"missionname":this.m_mission.getSentenceNameLocalizationObject("singular")}));
      }
      
      private function initButtons() : void
      {
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_deployButton = new ZGameButton(this.screen.red_bt,this.onDeploy);
         this.m_deployButton.text = ZGameUtils.ZlocT("Dialogs","MissionSelectionDeployButtonText");
         this.m_greenButton = new ZGameButton(this.screen.green_bt,this.onExit);
         this.m_greenButton.text = ZGameUtils.ZlocT("Dialogs","OkButton");
         if(PVPManager.instance.numOccupiedInvaders > 0)
         {
            this.m_deployButton.show();
            this.m_greenButton.hide();
         }
         else
         {
            this.m_deployButton.hide();
            this.m_greenButton.show();
         }
      }
      
      override protected function deinitDialog() : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
         if(this.m_deployButton)
         {
            this.m_deployButton.dispose();
            this.m_deployButton = null;
         }
         if(this.m_greenButton)
         {
            this.m_greenButton.dispose();
            this.m_greenButton = null;
         }
      }
      
      private function onDeploy(param1:MouseEvent) : void
      {
         GameModeManager.instance.addGameMode(new GMDeployMission(this.m_mission.code));
         close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         close();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
   }
}

