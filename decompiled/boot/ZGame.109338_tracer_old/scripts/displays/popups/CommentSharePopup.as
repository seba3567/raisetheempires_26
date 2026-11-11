package displays.popups
{
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class CommentSharePopup extends CommentPopup
   {
      
      private var m_message:String = null;
      
      private var m_title:String = null;
      
      private var m_okButtonText:String = null;
      
      private var m_imageURL:String = null;
      
      private var m_imageSize:int = 0;
      
      public function CommentSharePopup(param1:String, param2:String, param3:String = null, param4:String = null, param5:int = 1, param6:Function = null, param7:Object = null, param8:String = "assets/displays/dialogs/PU_ShareComment.swf")
      {
         super(param6,param7,param8);
         this.m_message = param1;
         this.m_title = param2;
         this.m_okButtonText = param3;
         this.m_imageURL = param4;
         this.m_imageSize = param5;
      }
      
      override protected function setUpScreen() : void
      {
         var _loc1_:ImageLoader = null;
         if(!m_window || m_initialized)
         {
            return;
         }
         super.setUpScreen();
         m_sendBtn.compactText(this.m_okButtonText,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         if(m_window.popup_mc.feedImage_mc)
         {
            _loc1_ = ImageLoaderFactory.CreateImageLoader(this.m_imageURL,m_window.popup_mc.feedImage_mc);
            m_window.popup_mc.feedImage_mc.scaleContent = false;
            m_window.popup_mc.feedImage_mc.x = this.m_imageSize == FeedPopup.SMALL_IMAGE ? m_window.popup_mc.feed_tf.x - 80 : m_window.popup_mc.feed_tf.x - 130;
            _loc1_.smooth = true;
            m_loaders.push(_loc1_);
         }
      }
      
      override protected function setupText() : void
      {
         TextFieldUtil.processTextField(m_window.popup_mc.title_tf,this.m_title);
         TextFieldUtil.processTextField(m_window.popup_mc.title01_tf,ZGameUtils.ZlocT("Dialogs","CommentTitle"));
         TextFieldUtil.processTextField(m_window.popup_mc.feed_tf,this.m_message);
         TextFieldUtil.processTextField(m_window.popup_mc.description_tf,ZGameUtils.ZlocT("Dialogs","CommentDesc",{"num":m_maxChars}));
      }
   }
}

