package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol39")]
   public dynamic class errorDialog extends MovieClip
   {
      
      public var icon:UILoader;
      
      public var add_bt:MovieClip;
      
      public var panel_mc:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var description_tf:TextField;
      
      public var title_tf:TextField;
      
      public function errorDialog()
      {
         super();
      }
   }
}

