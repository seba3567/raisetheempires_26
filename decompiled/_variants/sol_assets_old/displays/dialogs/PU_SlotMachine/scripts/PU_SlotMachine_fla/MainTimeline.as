package PU_SlotMachine_fla
{
   import flash.display.MovieClip;
   
   [SWF(width="760", height="640", backgroundColor="#ffffff", frameRate="30")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var slotMachine_mc:MovieClip;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1,34,this.frame35);
      }
      
      internal function frame1() : *
      {
      }
      
      internal function frame35() : *
      {
         stop();
      }
   }
}

