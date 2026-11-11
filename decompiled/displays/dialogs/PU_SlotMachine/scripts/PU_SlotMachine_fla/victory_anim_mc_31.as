package PU_SlotMachine_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol110")]
   public dynamic class victory_anim_mc_31 extends MovieClip
   {
      
      public var text_mc1:MovieClip;
      
      public var text_mc2:MovieClip;
      
      public var text_mc3:MovieClip;
      
      public function victory_anim_mc_31()
      {
         super();
         addFrameScript(0,this.frame1,79,this.frame80);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame80() : *
      {
         visible = false;
         stop();
      }
   }
}

