package Miniseries043_Quests_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   [SWF(width="760", height="640", backgroundColor="#ffffff", frameRate="60")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var quest03:quest03_mc;
      
      public function MainTimeline()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.__setPerspectiveProjection_);
      }
      
      public function __setPerspectiveProjection_(param1:Event) : void
      {
         root.transform.perspectiveProjection.fieldOfView = 55;
         root.transform.perspectiveProjection.projectionCenter = new Point(380,320);
      }
   }
}

