package displays.popups.genericPopup
{
   import displays.popups.GenericPopup;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   
   public class GenericTitledPopup extends GenericPopup
   {
      
      private var m_title:String = null;
      
      public function GenericTitledPopup(param1:String, param2:String, param3:int, param4:Function, param5:Array = null)
      {
         super(param1,param3,param4,param5);
         if(param2 != null)
         {
            this.m_title = new String();
            this.m_title = param2;
         }
      }
      
      protected function get baseMovieClip() : MovieClip
      {
         return null;
      }
      
      override protected function advisorClip() : MovieClip
      {
         return this.baseMovieClip ? this.baseMovieClip.scarlett_mc.advisor_mc : null;
      }
      
      override protected function get messageTextField() : TextField
      {
         return this.baseMovieClip.message_tf;
      }
      
      override protected function get messageAnchor() : MovieClip
      {
         return this.baseMovieClip.messageAnchor_mc;
      }
      
      override protected function setUpLook() : void
      {
         super.setUpLook();
         m_window.popupBox_mc.welcomeBox_mc.visible = false;
         m_window.popupBox_mc.popupBox_tf.visible = false;
         m_window.popupBox_mc.accept_bt.visible = false;
         this.baseMovieClip.visible = true;
         if(this.m_title)
         {
            this.baseMovieClip.title_tf.visible = true;
            TextFieldUtil.processTextField(this.baseMovieClip.title_tf,this.m_title);
         }
         else
         {
            this.baseMovieClip.title_tf.visible = false;
         }
      }
      
      override protected function deinitButtons() : void
      {
         removeButtonClickListeners(this.baseMovieClip.accept_bt,this.baseMovieClip.cancel_bt);
      }
      
      override protected function initButtons() : void
      {
         setupButtons(this.baseMovieClip.accept_bt,this.baseMovieClip.cancel_bt);
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_title = null;
      }
   }
}

