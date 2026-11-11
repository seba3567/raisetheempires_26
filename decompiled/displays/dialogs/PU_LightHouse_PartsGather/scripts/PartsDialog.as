package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol70")]
   public dynamic class PartsDialog extends MovieClip
   {
      
      public var title_tf:TextField;
      
      public var unitCard_mc:MovieClip;
      
      public var slots_mc:MovieClip;
      
      public var bigIcon:UILoader;
      
      public var back_bt:MovieClip;
      
      public var panel_mc:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var description_tf:TextField;
      
      public var buyAll_bt:MovieClip;
      
      public var icon:UILoader;
      
      public var instructions_tf:TextField;
      
      public function PartsDialog()
      {
         super();
      }
   }
}

