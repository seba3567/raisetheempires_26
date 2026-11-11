package displays.popups
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class EpisodePopup extends SWFPopUp
   {
      
      private var m_data:XML = null;
      
      private var m_closeCallback:Function = null;
      
      private var m_closeBt:ZGameButton = null;
      
      private var m_initialized:Boolean = false;
      
      private var m_episodeId:String = null;
      
      private var m_imageLoader:ImageLoader = null;
      
      private var m_background:Sprite = null;
      
      private var m_backgroundFadeIn:Number = 2;
      
      private var m_backgroundFadeOut:Number = 0.5;
      
      private var m_dialogFadeIn:Number = 0.25;
      
      private var m_dialogFadeOut:Number = 0.5;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function EpisodePopup(param1:String, param2:Function = null, param3:Boolean = false)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Episode.swf"));
         if(param3)
         {
            this.setBackground();
         }
         this.m_data = ZGlobal.gameSettings.getEpisodeData(param1);
         this.m_episodeId = param1;
         if(param2 != null)
         {
            this.m_closeCallback = param2;
            addEventListener(GenericPopupEvent.SELECTED,param2,false,0,true);
         }
         if(this.m_data.@backgroundFadeIn.toString().length > 0)
         {
            this.m_backgroundFadeIn = Number(this.m_data.@backgroundFadeIn.toString());
         }
         if(this.m_data.@backgroundFadeOut.toString().length > 0)
         {
            this.m_backgroundFadeOut = Number(this.m_data.@backgroundFadeOut.toString());
         }
         if(this.m_data.@dialogFadeIn.toString().length > 0)
         {
            this.m_dialogFadeIn = Number(this.m_data.@dialogFadeIn.toString());
         }
         if(this.m_data.@dialogFadeOut.toString().length > 0)
         {
            this.m_dialogFadeOut = Number(this.m_data.@dialogFadeOut.toString());
         }
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupScreen();
      }
      
      private function setupScreen() : void
      {
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         if(this.m_data)
         {
            TextFieldUtil.processTextField(m_window.window_mc.title_tf,ZGameUtils.ZlocT("Episodes",this.m_data.@title.toString()));
            TextFieldUtil.processTextField(m_window.window_mc.description_tf,ZGameUtils.ZlocT("Episodes",this.m_data.@body.toString()));
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.@icon.toString()),m_window.window_mc.iconLoader);
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         m_window.window_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onClose,false,0,true);
         this.m_buttonSounds.addButton(m_window.window_mc.exit_bt,ButtonSound.DEFAULT);
         this.m_closeBt = new ZGameButton(m_window.window_mc.close_bt,this.onClose);
         this.m_closeBt.text = ZGameUtils.ZlocT("Dialogs","Continue");
         this.m_buttonSounds.addButton(this.m_closeBt.m_overlay,ButtonSound.DEFAULT);
         initDialog();
         m_window.alpha = 0;
         addChild(m_window);
         this.startFadeIn();
      }
      
      public function startFadeIn() : void
      {
         m_manager.containerCanvas.backgroundAlpha = 0;
         TweenLite.to(m_manager.containerCanvas,this.m_backgroundFadeIn,{
            "backgroundAlpha":1,
            "onComplete":this.fadeInComplete
         });
      }
      
      public function fadeInComplete() : void
      {
         if(this.m_background)
         {
            removeChild(this.m_background);
         }
         TweenLite.to(m_window,this.m_dialogFadeIn,{"alpha":1});
      }
      
      public function fadeOutComplete() : void
      {
         this.close();
      }
      
      public function startFadeOut() : void
      {
         TweenLite.to(m_manager.containerCanvas,this.m_backgroundFadeOut,{"backgroundAlpha":0});
         TweenLite.to(m_window,this.m_dialogFadeOut,{
            "alpha":0,
            "onComplete":this.fadeOutComplete
         });
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         this.startFadeOut();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.EPISODE_CONTINUE));
         param1.stopPropagation();
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         if(ZGlobal.player)
         {
            ZGlobal.player.setSeenDialog("episode",this.m_episodeId);
         }
         this.m_closeBt.dispose();
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      private function setBackground() : void
      {
         this.m_background = new Sprite();
         addChild(this.m_background);
         var _loc1_:Graphics = this.m_background.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,1);
         _loc1_.drawRect(0,0,Zlab.mainStage.width,Zlab.mainStage.height);
         _loc1_.endFill();
      }
   }
}

