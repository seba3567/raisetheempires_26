package core.worlds.strategicWorld
{
   import core.gamemode.GameModeManager;
   import core.gamemode.strategic.GMStrategic;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.StrategicDispatcher;
   import flash.events.Event;
   import zlabs.debug.Console;
   import zlabs.debug.Logger;
   
   public class StrategicToggler
   {
      
      private static var m_instance:StrategicToggler = null;
      
      private static var m_editor:Boolean = false;
      
      private var m_active:Boolean = false;
      
      public function StrategicToggler()
      {
         super();
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.TOGGLE,this.onToggle);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ENTERED,this.onEntered);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.DISPLAYING_LEADERBOARD_SCREEN,this.onLeaderboardScreen);
      }
      
      public static function toggleEditor() : Boolean
      {
         m_editor = !m_editor;
         return m_editor;
      }
      
      public static function init() : void
      {
         m_instance = new StrategicToggler();
         Console.registerCommand("campaignEdit",function():void
         {
            var _loc1_:Boolean = Boolean(StrategicToggler.toggleEditor());
            Logger.print(Console,"Campaign Edit mode " + (_loc1_ ? "enabled" : "disabled"));
         },"Toggles Campaign Edit mode (checked whenever Campaign mode is entered");
      }
      
      private function onEntered(param1:Event) : void
      {
         this.m_active = true;
      }
      
      private function onLeaderboardScreen(param1:Event) : void
      {
         if(this.m_active)
         {
            this.onToggle(param1);
         }
      }
      
      private function onToggle(param1:Event) : void
      {
         if(!this.m_active)
         {
            ViewManager.instance.goToView(StrategicWorld.ID);
            GameModeManager.instance.addGameMode(new GMStrategic());
            this.m_active = true;
         }
         else
         {
            ViewManager.instance.goToView(IslandWorld.ID);
            GameModeManager.instance.setDefaultGameMode();
            this.m_active = false;
         }
      }
   }
}

