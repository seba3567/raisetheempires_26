package events
{
   import flash.events.Event;
   
   public class ProgressBarEvent extends Event
   {
      
      public static const TYPE_PLAIN:int = 0;
      
      public static const TYPE_HOMECONTRACT:int = 1;
      
      public static const TYPE_FINISHBUILDING:int = 2;
      
      public static const UPDATE_PROGRESS:String = "updateProgress";
      
      public static const START_PROGRESS_BAR:String = "startProgressBar";
      
      public static const STOP_PROGRESS_BAR:String = "stopProgressBar";
      
      public static const PROGRESS_BAR_ICON:String = "progressBarIcon";
      
      public static const PROGRESS_BAR_DRAWN:String = "progressBarDrawn";
      
      public var message:String;
      
      public var progress:Number;
      
      public var timeRemaining:String;
      
      public var isPercent:Boolean = false;
      
      public var barType:int = 0;
      
      public function ProgressBarEvent(param1:String)
      {
         super(param1);
      }
   }
}

