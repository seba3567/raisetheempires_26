package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol24")]
   public dynamic class waveTransition_mc extends MovieClip
   {
      
      public var rewards_mc:MovieClip;
      
      public var bar_mc:MovieClip;
      
      public var background_mc:MovieClip;
      
      public var title_mc:MovieClip;
      
      public function waveTransition_mc()
      {
         super();
         addFrameScript(31,this.frame32,39,this.frame40);
      }
      
      internal function frame40() : *
      {
         stop();
      }
      
      internal function frame32() : *
      {
         stop();
      }
   }
}

