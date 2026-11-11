package BattleSetupHudOverlay_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol8")]
   public dynamic class UnitPlacementgrid_126 extends MovieClip
   {
      
      public var SelectUnitInd:MovieClip;
      
      public function UnitPlacementgrid_126()
      {
         super();
         addFrameScript(0,this.frame1,7,this.frame8,19,this.frame20);
      }
      
      internal function frame8() : *
      {
         stop();
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame20() : *
      {
         gotoAndStop(1);
      }
   }
}

