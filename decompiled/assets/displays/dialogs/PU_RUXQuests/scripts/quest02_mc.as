package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol99")]
   public dynamic class quest02_mc extends MovieClip
   {
      
      public var title_tf:TextField;
      
      public var panel:MovieClip;
      
      public var requirement2_mc:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var daysLeft_tf:TextField;
      
      public var requirement1_mc:MovieClip;
      
      public var accept_bt:MovieClip;
      
      public var hint_tf:TextField;
      
      public var limited_tf:TextField;
      
      public var popupBox_tf:TextField;
      
      public var uiloader_mc:UILoader;
      
      public var title2_tf:TextField;
      
      public function quest02_mc()
      {
         super();
      }
   }
}

