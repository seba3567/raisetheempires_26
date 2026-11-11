package BattleSetupHudOverlay_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol277")]
   public dynamic class bigRedGlowAnime_mc_72 extends MovieClip
   {
      
      public var glow_mc:MovieClip;
      
      public function bigRedGlowAnime_mc_72()
      {
         super();
         addFrameScript(0,this.frame1,12,this.frame13);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame13() : *
      {
         gotoAndPlay(2);
      }
   }
}

