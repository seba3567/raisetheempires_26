package PU_SlotMachine_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol40")]
   public dynamic class SotMachineSign_12 extends MovieClip
   {
      
      public var sunburst:MovieClip;
      
      public function SotMachineSign_12()
      {
         super();
         addFrameScript(0,this.frame1,69,this.frame70,161,this.frame162);
      }
      
      internal function frame162() : *
      {
         gotoAndStop(1);
         dispatchEvent(new Event("rewardMarqueeAnimOver"));
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame70() : *
      {
         gotoAndStop(1);
         dispatchEvent(new Event("rewardMarqueeAnimOver"));
      }
   }
}

