package SettingsMenu_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol784")]
   public dynamic class menuAnimation_mc_2 extends MovieClip
   {
      
      public var zoomout_bt:MovieClip;
      
      public var fullScreen_bt:MovieClip;
      
      public var graphics_bt:MovieClip;
      
      public var sfxToggle_bt:MovieClip;
      
      public var zoomin_bt:MovieClip;
      
      public var settings_bt:MovieClip;
      
      public var musicToggle_bt:MovieClip;
      
      public function menuAnimation_mc_2()
      {
         super();
         addFrameScript(0,this.frame1,7,this.frame8,15,this.frame16);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame8() : *
      {
         stop();
      }
      
      internal function frame16() : *
      {
         stop();
      }
   }
}

