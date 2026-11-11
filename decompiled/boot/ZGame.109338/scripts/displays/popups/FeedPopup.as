package displays.popups
{
   import core.gameobjects.GameItem;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   
   public class FeedPopup extends GenericPopup
   {
      
      public static const SMALL_IMAGE:int = 0;
      
      public static const LARGE_IMAGE:int = 1;
      
      private var m_title:String = null;
      
      private var m_loader:ImageLoader = null;
      
      private var m_shareButtonText:String = null;
      
      private var m_imageUrl:String = null;
      
      private var m_fallbackImageUrl:String = null;
      
      private var m_imageSize:int;
      
      public function FeedPopup(param1:String, param2:String, param3:String = null, param4:int = 0, param5:Function = null, param6:String = null, param7:int = 1, param8:Array = null, param9:GameItem = null)
      {
         var _loc10_:String = null;
         if(param9)
         {
            _loc10_ = "assets/displays/dialogs/PU_GenericPopUp_Titan.swf";
         }
         else
         {
            _loc10_ = "assets/displays/dialogs/PU_GenericPopUp.swf";
         }
         super(param1,param4,param5,param8,_loc10_);
         this.m_title = param2;
         this.m_shareButtonText = param3;
         this.m_imageUrl = param6;
         this.m_imageSize = param7;
      }
      
      public function set fallbackImage(param1:String) : void
      {
         this.m_fallbackImageUrl = param1;
      }
      
      override protected function setUpLook() : void
      {
         super.setUpLook();
         m_window.popupBox_mc.popupBox_tf.visible = false;
         m_window.popupBox_mc.genericBox.visible = false;
         m_window.popupBox_mc.welcomeBox_mc.visible = false;
         this.baseMovieClip.visible = true;
      }
      
      override protected function setUpScreen() : void
      {
         var _loc1_:TextField = null;
         super.setUpScreen();
         if(setupComplete)
         {
            if(this.m_title != null)
            {
               TextFieldUtil.processTextField(this.baseMovieClip.feedTitle_tf,this.m_title);
            }
            if(m_message != null)
            {
               _loc1_ = this.baseMovieClip.feed_tf;
               TextFieldUtil.processTextField(_loc1_,m_message);
               if(this.baseMovieClip.feedAnchor_mc != null)
               {
               }
            }
            this.LoadImage(this.m_imageUrl,this.onImageFailed);
            if(this.m_shareButtonText)
            {
               TextFieldUtil.processTextField(this.baseMovieClip.accept_bt.generic_tf,this.m_shareButtonText);
            }
            m_window.popupBox_mc.accept_bt.visible = false;
         }
      }
      
      private function LoadImage(param1:String, param2:Function) : void
      {
         if(param1)
         {
            if(this.m_loader)
            {
               this.m_loader.destroy();
               this.m_loader = null;
            }
            this.m_loader = ImageLoaderFactory.CreateImageLoader(param1,this.baseMovieClip.feedImage_mc,null,param2);
            this.baseMovieClip.feedImage_mc.scaleContent = false;
            this.baseMovieClip.feedImage_mc.x = this.m_imageSize == SMALL_IMAGE ? this.baseMovieClip.feed_tf.x - 80 : this.baseMovieClip.feed_tf.x - 105;
            this.m_loader.smooth = true;
         }
      }
      
      private function onImageFailed() : void
      {
         this.LoadImage(this.m_fallbackImageUrl,null);
      }
      
      override protected function getOkButtonClip() : DisplayObject
      {
         return this.baseMovieClip.accept_bt;
      }
      
      override protected function getCancelButtonClip() : DisplayObject
      {
         return this.baseMovieClip.cancel_bt;
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.baseMovieClip.accept_bt.removeEventListener(MouseEvent.CLICK,onAccept);
         this.baseMovieClip.cancel_bt.removeEventListener(MouseEvent.CLICK,onCancel);
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
      }
      
      protected function get baseMovieClip() : MovieClip
      {
         return m_window.popupBox_mc.feed_mc;
      }
   }
}

