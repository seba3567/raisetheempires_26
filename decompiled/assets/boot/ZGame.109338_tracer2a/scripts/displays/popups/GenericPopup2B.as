package displays.popups
{
   import displays.popups.genericPopup.GenericTitledPopup;
   import flash.display.MovieClip;
   
   public class GenericPopup2B extends GenericTitledPopup
   {
      
      public function GenericPopup2B(param1:String, param2:String, param3:int, param4:Function, param5:Array = null)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      public static function NewYesNo(param1:String, param2:String, param3:Function, param4:Array = null) : GenericPopup2B
      {
         return new GenericPopup2B(param1,param2,TYPE_YESNO,param3,param4);
      }
      
      public static function NewAcceptCancel(param1:String, param2:String, param3:Function, param4:Array = null) : GenericPopup2B
      {
         return new GenericPopup2B(param1,param2,TYPE_ACCEPTCANCEL,param3,param4);
      }
      
      public static function NewGoReturn(param1:String, param2:String, param3:Function, param4:Array = null) : GenericPopup2B
      {
         return new GenericPopup2B(param1,param2,TYPE_GORETURN,param3,param4);
      }
      
      public static function NewSellSkip(param1:String, param2:String, param3:Function, param4:Array = null) : GenericPopup2B
      {
         return new GenericPopup2B(param1,param2,TYPE_SELL,param3,param4);
      }
      
      public static function NewReportRefresh(param1:String, param2:String, param3:String, param4:Function, param5:Array = null) : GenericPopup2B
      {
         var _loc6_:GenericPopup2B = new GenericPopup2B(param1,param2,TYPE_REPORTREFRESH,param4,param5);
         _loc6_.setAdvisorMood(param3);
         return _loc6_;
      }
      
      override protected function get baseMovieClip() : MovieClip
      {
         return m_window.popupBox_mc.generic03_mc;
      }
   }
}

