package PU_Victory_fla
{
   import flash.display.MovieClip;
   
   [SWF(width="760", height="640", backgroundColor="#999999", frameRate="30")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var popupBox_mc:MovieClip;
      
      public var victory_solo:MovieClip;
      
      public var victory_pvp:MovieClip;
      
      public function MainTimeline()
      {
         super();
         this.__setTab_victory_pvp_Scene1_victory_pvp_0();
      }
      
      internal function __setTab_victory_pvp_Scene1_victory_pvp_0() : *
      {
         this.victory_pvp.tabIndex = 0;
      }
   }
}

