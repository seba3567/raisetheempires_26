package displays.popups.survivalMode
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class SurvivalModeIntroPopup extends GallantPopup
   {
      
      private var m_imageLoader:ImageLoader;
      
      private var m_acceptButton:ZGameButton = null;
      
      public function SurvivalModeIntroPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SurvivalModeIntro.swf"));
      }
      
      private function get mc() : MovieClip
      {
         return m_window.intro_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height + 50;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         if(this.mc.exit_bt)
         {
            this.mc.exit_bt.visible = false;
         }
         if(ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh") > 2)
         {
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(SurvivalModeManager.instance.questIconName),this.mc.icon);
         }
         else
         {
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_0.swf/PVP01_96.png"),this.mc.icon);
         }
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeIntroTitle"));
         TextFieldUtil.processTextField(this.mc.body_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeIntroBody"));
         TextFieldUtil.processTextField(this.mc.questName_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeIntroMessage"));
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Accept");
         this.m_acceptButton = new ZGameButton(this.mc.accept_bt,this.onAcceptClicked,1.1,true);
         this.m_acceptButton.compactText(_loc1_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_acceptButton.show();
         this.m_acceptButton.enable();
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
            this.m_acceptButton = null;
         }
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
         super.deinitDialog();
      }
      
      private function onAcceptClicked(param1:MouseEvent) : void
      {
         close();
      }
   }
}

