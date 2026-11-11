package Miniseries023_Main_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   [SWF(width="760", height="640", backgroundColor="#000000", frameRate="30")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var screen_mc:MovieClip;
      
      public function MainTimeline()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.__setPerspectiveProjection_);
      }
      
      public function __setPerspectiveProjection_(param1:Event) : void
      {
         root.transform.perspectiveProjection.fieldOfView = 75;
         root.transform.perspectiveProjection.projectionCenter = new Point(302,358);
      }
   }
}

