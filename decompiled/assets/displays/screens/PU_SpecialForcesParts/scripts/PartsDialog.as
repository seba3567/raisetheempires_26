package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol64")]
   public dynamic class PartsDialog extends MovieClip
   {
      
      public var icon:UILoader;
      
      public var slots_mc:MovieClip;
      
      public var back_bt:MovieClip;
      
      public var instructions_tf:TextField;
      
      public var green_bt:MovieClip;
      
      public var bg_mc:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var description_tf:TextField;
      
      public var buyAll_bt:MovieClip;
      
      public var title_tf:TextField;
      
      public function PartsDialog()
      {
         super();
      }
   }
}

