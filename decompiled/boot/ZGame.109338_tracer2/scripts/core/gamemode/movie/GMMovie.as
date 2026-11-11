package core.gamemode.movie
{
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.ui.Tooltip;
   import displays.cinema.Cinematics;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   
   public class GMMovie extends GameMode
   {
      
      private var m_movie:String = null;
      
      private var m_cinematics:Cinematics = null;
      
      private var m_onComplete:Function = null;
      
      public function GMMovie(param1:String)
      {
         super();
         this.m_movie = param1;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.m_cinematics = new Cinematics("movie" + this.m_movie);
         this.m_cinematics.setBackground(Zlab.mainStage.width,Zlab.mainStage.height,1,1);
         var _loc1_:XML = ZGlobal.gameSettings.getMovieXMLByName(this.m_movie);
         if(_loc1_)
         {
            this.m_cinematics.url = ZGlobal.getAssetURL(_loc1_.@url.toString());
            this.m_cinematics.addEventListener(Event.COMPLETE,this.onCinematicComplete,false,0,true);
            Zlab.mainStage.addChild(this.m_cinematics);
            this.m_cinematics.loadAndPlay();
            Tooltip.hide();
            InputManager.disableInput();
         }
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         InputManager.enableInput();
      }
      
      public function set onComplete(param1:Function) : void
      {
         this.m_onComplete = param1;
      }
      
      private function onCinematicComplete(param1:Event) : void
      {
         this.m_cinematics.removeEventListener(Event.COMPLETE,this.onCinematicComplete);
         Zlab.mainStage.removeChild(this.m_cinematics);
         this.m_cinematics = null;
         if(null != this.m_onComplete)
         {
            this.m_onComplete();
            this.m_onComplete = null;
         }
         GameModeManager.instance.removeGameMode(this);
      }
   }
}

