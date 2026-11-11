package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol89")]
   public dynamic class SeaTopForeground extends MovieClip
   {
      
      public var PlaneShadow01:MovieClip;
      
      public var PlaneShadow02:MovieClip;
      
      public function SeaTopForeground()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.PlaneShadow01.gotoAndPlay(31);
         this.PlaneShadow02.gotoAndPlay(66);
      }
   }
}

