package PU_SurvivalModeEnd_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol34")]
   public dynamic class countdown_mc_13 extends MovieClip
   {
      
      public var gradient_mc:MovieClip;
      
      public var seconds_mc:MovieClip;
      
      public function countdown_mc_13()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.gradient_mc.mask = this.seconds_mc;
      }
   }
}

