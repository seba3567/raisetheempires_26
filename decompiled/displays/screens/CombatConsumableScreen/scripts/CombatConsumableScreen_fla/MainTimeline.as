package CombatConsumableScreen_fla
{
   import flash.display.MovieClip;
   
   [SWF(width="760", height="640", backgroundColor="#6c6c6c", frameRate="24")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var bounds_mc:MovieClip;
      
      public var ConsumablesComponent:MovieClip;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1,5,this.frame6,13,this.frame14);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame6() : *
      {
         stop();
      }
      
      internal function frame14() : *
      {
         stop();
      }
   }
}

