package PU_SlotMachine_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol72")]
   public dynamic class slot1_mc_15 extends MovieClip
   {
      
      public var icon:MovieClip;
      
      public function slot1_mc_15()
      {
         super();
         addFrameScript(0,this.frame1,65,this.frame66,76,this.frame77,90,this.frame91);
      }
      
      internal function frame1() : *
      {
      }
      
      internal function frame91() : *
      {
         gotoAndStop(1);
      }
      
      internal function frame77() : *
      {
         stop();
      }
      
      internal function frame66() : *
      {
         gotoAndPlay("_loop");
      }
   }
}

