package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol75")]
   public dynamic class quest01_mc extends MovieClip
   {
      
      public var requirement1_mc:MovieClip;
      
      public var accept_bt:MovieClip;
      
      public var panel:MovieClip;
      
      public var hint_tf:TextField;
      
      public var popupBox_tf:TextField;
      
      public var exit_bt:SimpleButton;
      
      public var title2_tf:TextField;
      
      public var title_tf:TextField;
      
      public var daysLeft_tf:TextField;
      
      public var uiloader_mc:UILoader;
      
      public var limited_tf:TextField;
      
      public function quest01_mc()
      {
         super();
      }
   }
}

