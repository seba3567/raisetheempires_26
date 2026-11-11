package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol30")]
   public dynamic class survivalModeIntro_mc extends MovieClip
   {
      
      public var icon:UILoader;
      
      public var questName_tf:TextField;
      
      public var background_mc:MovieClip;
      
      public var accept_bt:MovieClip;
      
      public var body_tf:TextField;
      
      public var exit_bt:SimpleButton;
      
      public var title_tf:TextField;
      
      public function survivalModeIntro_mc()
      {
         super();
      }
   }
}

