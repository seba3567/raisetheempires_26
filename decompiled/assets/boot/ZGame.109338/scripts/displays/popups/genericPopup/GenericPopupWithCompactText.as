package displays.popups.genericPopup
{
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   
   public class GenericPopupWithCompactText extends GenericTitledPopup
   {
      
      private var m_title:String = null;
      
      public function GenericPopupWithCompactText(param1:String, param2:String, param3:int, param4:Function)
      {
         super(param1,param2,param3,param4);
         if(param2 != null)
         {
            this.m_title = new String();
            this.m_title = param2;
         }
      }
      
      override protected function setUpLook() : void
      {
         super.setUpLook();
         if(this.m_title)
         {
            this.baseMovieClip.title_tf.visible = true;
            TextFieldUtil.compactTextField(this.baseMovieClip.title_tf,this.m_title);
         }
         else
         {
            this.baseMovieClip.title_tf.visible = false;
         }
      }
      
      override protected function get baseMovieClip() : MovieClip
      {
         return m_window.popupBox_mc.generic01_mc;
      }
   }
}

