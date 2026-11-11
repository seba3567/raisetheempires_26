package displays.popups.genericPopup
{
   import flash.display.MovieClip;
   
   public class GenericPopup1B extends GenericTitledPopup
   {
      
      public function GenericPopup1B(param1:String, param2:String, param3:int, param4:Function)
      {
         super(param1,param2,param3,param4);
      }
      
      public static function NewOk(param1:String, param2:String, param3:Function = null) : GenericPopup1B
      {
         return new GenericPopup1B(param1,param2,TYPE_OK,param3);
      }
      
      public static function NewRefresh(param1:String, param2:String, param3:String, param4:Function = null) : GenericPopup1B
      {
         var _loc5_:GenericPopup1B = new GenericPopup1B(param1,param2,TYPE_REFRESH,param4);
         _loc5_.setAdvisorMood(param3);
         return _loc5_;
      }
      
      override protected function get baseMovieClip() : MovieClip
      {
         return m_window.popupBox_mc.generic01_mc;
      }
   }
}

