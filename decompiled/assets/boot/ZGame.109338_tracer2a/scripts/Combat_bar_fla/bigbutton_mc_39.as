package Combat_bar_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1480")]
   public dynamic class bigbutton_mc_39 extends MovieClip
   {
      
      public var cancel_bt:SimpleButton;
      
      public var deploy_bt:SimpleButton;
      
      public function bigbutton_mc_39()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         stop();
      }
   }
}

