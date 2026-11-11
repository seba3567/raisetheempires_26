package core.ui.components.PortraitSlidePick
{
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PortraitPickDissolveHelperAlpha extends PortraitPickDissolveHelper
   {
      
      public function PortraitPickDissolveHelperAlpha(param1:MovieClip)
      {
         super(param1);
         TweenLite.to(param1,0.5,{
            "alpha":0,
            "onComplete":this.onDoneFrame
         });
      }
      
      private function onDoneFrame() : void
      {
         dispatchEvent(new Event(DONE));
      }
   }
}

