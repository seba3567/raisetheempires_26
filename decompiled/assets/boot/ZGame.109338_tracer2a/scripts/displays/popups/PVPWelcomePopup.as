package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class PVPWelcomePopup extends GallantPopup
   {
      
      private var m_acceptBt:ZGameButton = null;
      
      private var m_loaders:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function PVPWelcomePopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/Pvp_Welcome.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         contentWidth = m_window.pvp_welcome.panel_mc.width;
         contentHeight = m_window.pvp_welcome.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         var _loc1_:MovieClip = m_window.pvp_welcome;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_acceptBt = new ZGameButton(_loc1_.accept_bt,this.onAccept);
         this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","Continue");
         this.m_buttonSounds.addButton(this.m_acceptBt.m_overlay,ButtonSound.DEFAULT);
         _loc1_.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         this.m_buttonSounds.addButton(_loc1_.exit_bt,ButtonSound.DEFAULT);
         this.m_loaders = new Array();
         this.loadIcon("assets/game/quests/Quests_Icons_0.swf/RedHeartReputation_96.png",_loc1_.icon_0);
         this.loadIcon("assets/game/quests/Quests_Icons_0.swf/ImmunityShield_96.png",_loc1_.icon_1);
         this.loadIcon("assets/game/quests/Quests_Icons_0.swf/WhiteKnight_96.png",_loc1_.icon_2);
         this.loadIcon("assets/game/quests/Quests_Icons_0.swf/BlackHeartReputation_96.png",_loc1_.icon_3);
         this.loadIcon("assets/game/quests/Quests_Icons_0.swf/InvaderPick_96.png",_loc1_.icon_4);
         this.loadIcon("assets/game/quests/Quests_Icons_0.swf/Pillage_96.png",_loc1_.icon_5);
         this.setTextSingle(_loc1_.title_tf,ZGameUtils.ZlocT("Dialogs","PVPWelcomeTitle"));
         this.setTextDescription(_loc1_.dialog_tf,ZGameUtils.ZlocT("Dialogs","PVPWelcomeMessage"));
         this.setTextSingle(_loc1_.header_tf_0,ZGameUtils.ZlocT("Dialogs","PVPWelcomeRedHeartTitle"));
         this.setText(_loc1_.description_tf_0,ZGameUtils.ZlocT("Dialogs","PVPWelcomeRedHeartBody"));
         this.setTextSingle(_loc1_.header_tf_1,ZGameUtils.ZlocT("Dialogs","PVPWelcomeImmunityTitle"));
         this.setText(_loc1_.description_tf_1,ZGameUtils.ZlocT("Dialogs","PVPWelcomeImmunityBody"));
         this.setTextSingle(_loc1_.header_tf_2,ZGameUtils.ZlocT("Dialogs","PVPWelcomeRepelTitle"));
         this.setText(_loc1_.description_tf_2,ZGameUtils.ZlocT("Dialogs","PVPWelcomeRepelBody"));
         this.setTextSingle(_loc1_.header_tf_3,ZGameUtils.ZlocT("Dialogs","PVPWelcomeBlackHeartTitle"));
         this.setText(_loc1_.description_tf_3,ZGameUtils.ZlocT("Dialogs","PVPWelcomeBlackHeartBody"));
         this.setTextSingle(_loc1_.header_tf_4,ZGameUtils.ZlocT("Dialogs","PVPWelcomeInvadingTitle"));
         this.setText(_loc1_.description_tf_4,ZGameUtils.ZlocT("Dialogs","PVPWelcomeInvadingBody"));
         this.setTextSingle(_loc1_.header_tf_5,ZGameUtils.ZlocT("Dialogs","PVPWelcomePillageTitle"));
         this.setText(_loc1_.description_tf_5,ZGameUtils.ZlocT("Dialogs","PVPWelcomePillageBody"));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc2_:ImageLoader = null;
         var _loc1_:MovieClip = m_window.pvp_welcome;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_acceptBt.dispose();
         _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         for each(_loc2_ in this.m_loaders)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
            }
         }
         super.deinitDialog();
      }
      
      private function loadIcon(param1:String, param2:UILoader) : void
      {
         this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param1),param2));
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onExitButton(param1:MouseEvent) : void
      {
         close();
      }
      
      private function setText(param1:TextField, param2:String) : void
      {
         TextFieldUtil.processTextField(param1,param2);
      }
      
      private function setTextSingle(param1:TextField, param2:String) : void
      {
         TextFieldUtil.compactTextField(param1,param2,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
      }
      
      private function setTextDescription(param1:TextField, param2:String, param3:int = 3) : void
      {
         TextFieldUtil.compactTextField(param1,param2,{
            "maxLines":param3,
            "minScale":0.8,
            "onFail":"return"
         });
      }
   }
}

