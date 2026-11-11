package displays.popups.leaderboard
{
   import core.ZGlobal;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import zlabs.events.GenericPopupEvent;
   
   public class LeaderboardPopup extends GallantPopup
   {
      
      public function LeaderboardPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/PU_Leaderboard2.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.show(m_window.standings_mc,false);
         this.show(m_window.popup_mc,false);
         this.show(m_window.upgrade_mc,false);
         this.show(m_window.complete_mc,false);
         this.show(this.screen,true);
      }
      
      public function get statsData() : Object
      {
         return null;
      }
      
      protected function get screen() : MovieClip
      {
         return null;
      }
      
      private function show(param1:MovieClip, param2:Boolean) : void
      {
         param1.visible = param2;
         param1.mouseEnabled = param2;
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         close();
      }
      
      protected function updateTitleTrophies() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(this.screen.trophy0) && Boolean(this.screen.trophy1))
         {
            _loc1_ = this.screen.heading_tf.textWidth * 0.5;
            _loc2_ = this.screen.x + contentWidth * 0.5;
            this.screen.trophy0.x = _loc2_ - _loc1_ - this.screen.trophy0.width * 0.25;
            this.screen.trophy1.x = _loc2_ + _loc1_ + this.screen.trophy1.width * 0.25;
         }
      }
   }
}

