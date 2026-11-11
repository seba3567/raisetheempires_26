package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol96")]
   public dynamic class PartsDialog extends MovieClip
   {
      
      public var unitCard_mc:MovieClip;
      
      public var icon:UILoader;
      
      public var instructions_tf:TextField;
      
      public var bonus_tf:TextField;
      
      public var exit_bt:SimpleButton;
      
      public var description_tf:TextField;
      
      public var buyAll_bt:MovieClip;
      
      public var back_bt:MovieClip;
      
      public var bigIcon:UILoader;
      
      public var slots_mc:MovieClip;
      
      public var clock_mc:MovieClip;
      
      public var panel_mc:MovieClip;
      
      public var title_tf:TextField;
      
      public function PartsDialog()
      {
         super();
      }
   }
}

