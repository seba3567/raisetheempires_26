package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.ui.Tooltip;
   import displays.cinema.Cinematics;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   
   public class DoPlayCinematics extends InitializationAction
   {
      
      public static const INIT_ID:String = "playCinematics";
      
      private var m_cinema:Cinematics;
      
      public function DoPlayCinematics(param1:Cinematics)
      {
         super(INIT_ID);
         this.m_cinema = param1;
      }
      
      override public function execute() : void
      {
         Tooltip.hide();
         InputManager.disableInput();
         Zlab.mainStage.addChild(this.m_cinema);
         this.m_cinema.loadAndPlay();
         this.m_cinema.addEventListener(Event.COMPLETE,this.onCinematicComplete,false,0,true);
      }
      
      private function onCinematicComplete(param1:Event) : void
      {
         this.m_cinema.removeEventListener(Event.COMPLETE,this.onCinematicComplete);
         this.m_cinema = null;
         dispatchEvent(new Event(Event.COMPLETE));
         InputManager.enableInput();
      }
   }
}

