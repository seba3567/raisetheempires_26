package PU_Victory_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol17")]
   public dynamic class Check_X_animated_8 extends MovieClip
   {
      
      public function Check_X_animated_8()
      {
         super();
         addFrameScript(0,this.frame1,5,this.frame6);
      }
      
      internal function frame6() : *
      {
         stop();
      }
      
      public function onAddToStage(param1:Event) : void
      {
         gotoAndPlay(1);
      }
      
      internal function frame1() : *
      {
         if(!hasEventListener(Event.ADDED_TO_STAGE))
         {
            addEventListener(Event.ADDED_TO_STAGE,this.onAddToStage);
         }
      }
   }
}

