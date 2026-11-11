package displays.cinema
{
   import core.ZGlobal;
   import flash.events.Event;
   import resources.PostLoadManager;
   import zlabs.Zlab;
   
   public class IntroCinematics extends Cinematics
   {
      
      public static var INTRO:String = "introCine";
      
      private var m_playingBackgroundAlpha:uint = 0;
      
      public function IntroCinematics(param1:Boolean = true)
      {
         var _loc3_:String = null;
         super(this.ID);
         mouseCloseEnabled = param1;
         setBackground(Zlab.mainStage.width,Zlab.mainStage.height,1,1);
         var _loc2_:XML = ZGlobal.gameSettings.getMovieXMLByName(this.movieUrl);
         if(_loc2_)
         {
            _loc3_ = _loc2_["@url"];
            url = ZGlobal.getAssetURL(_loc3_);
         }
         else
         {
            finished();
         }
      }
      
      protected function get ID() : String
      {
         return INTRO;
      }
      
      override protected function get movieUrl() : String
      {
         return "intro";
      }
      
      protected function set backgroundAlpha(param1:uint) : void
      {
         this.m_playingBackgroundAlpha = param1;
      }
      
      override protected function onMovieLoaded(param1:Event) : void
      {
         super.onMovieLoaded(param1);
         setBackground(Zlab.mainStage.width,Zlab.mainStage.height,1,this.m_playingBackgroundAlpha);
         this.movieLoaded();
      }
      
      protected function movieLoaded() : void
      {
         PostLoadManager.instance.start();
         ZGlobal.player.setSeenFlag(INTRO);
      }
   }
}

