package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import fl.containers.UILoader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.resource.SWFResource;
   
   public class RequirementsPopup extends ZGamePopUp
   {
      
      private var m_mainButton:ZGameButton = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_info:RequirementsPopupInterface;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function RequirementsPopup(param1:RequirementsPopupInterface)
      {
         this.m_info = param1;
         addEventListener(GenericPopupEvent.SELECTED,param1.callback,false,0,true);
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_OutOfResources.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         initDialog();
         var _loc2_:Class = param1.getAssetClass("MainScreen_mc");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.frame_mc.width;
         this.contentHeight = m_window.frame_mc.height;
         centerWithinStage(Zlab.mainStage);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_mainButton = new ZGameButton(m_window.accept_bt,this.onAccept);
         this.m_mainButton.text = this.m_info.mainButtonText;
         this.m_buttonSounds.addButton(this.m_mainButton.m_overlay,ButtonSound.DEFAULT);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancel,false,0,true);
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         this.setOrHideText(m_window.title_tf,this.m_info.titleText);
         this.setOrHideText(m_window.bubble_tf,this.m_info.bubbleText);
         this.setOrHideText(m_window.desc_tf,this.m_info.descriptionText);
         this.displayIcons(this.m_info.iconArray);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function dispose() : void
      {
         deinitDialog();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_mainButton.dispose();
         this.m_mainButton = null;
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
         this.disposeLoaders();
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.dispose();
         super.close(param1);
      }
      
      private function addLoader(param1:String, param2:UILoader) : void
      {
         this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param1),param2));
      }
      
      private function displayIcons(param1:Array) : void
      {
         this.disposeLoaders();
         this.m_imageLoaders = new Array();
         m_window.steps_2_mc.visible = m_window.steps_3_mc.visible = false;
         switch(param1.length)
         {
            case 2:
               m_window.steps_2_mc.visible = true;
               this.addLoader(param1[0],m_window.steps_2_mc.icon0_mc);
               this.addLoader(param1[1],m_window.steps_2_mc.icon1_mc);
               break;
            case 3:
               m_window.steps_3_mc.visible = true;
               this.addLoader(param1[0],m_window.steps_3_mc.icon0_mc);
               this.addLoader(param1[1],m_window.steps_3_mc.icon1_mc);
               this.addLoader(param1[2],m_window.steps_3_mc.icon2_mc);
         }
      }
      
      private function disposeLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_imageLoaders = null;
      }
      
      private function setOrHideText(param1:TextField, param2:String) : void
      {
         if(Boolean(param2) && param2.length > 0)
         {
            TextFieldUtil.processTextField(param1,param2);
         }
         else
         {
            param1.visible = false;
         }
      }
      
      protected function onAccept(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         this.close();
      }
      
      protected function onCancel(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         this.close();
      }
   }
}

