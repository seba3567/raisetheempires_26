package init
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Init.InitializationAction;
   import com.zynga.zap.w2e.WatchToEarnService;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.player.Player;
   import dispatchers.NeighborsDispatcher;
   import events.NeighborsEvent;
   import flash.events.Event;
   import utils.WatchToEarnGameFacade;
   
   public class GlobalsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "GlobalsInit";
      
      private var m_skipSocial:Boolean;
      
      public function GlobalsInit(param1:Boolean = false)
      {
         super(INIT_ID);
         this.m_skipSocial = param1;
         addDependency(SocialNetworkInit.INIT_ID);
         addDependency(TerrainInit.INIT_ID);
         NeighborsDispatcher.instance.addEventListener(NeighborsEvent.SETUP_COMPLETE,this.onFriendSetupComplete,false,0,true);
      }
      
      override public function execute() : void
      {
         var _loc1_:WatchToEarnGameFacade = null;
         if(!this.m_skipSocial && ZGlobal.player == null)
         {
            ZGlobal.player = new Player(GlobalEngine.socialNetwork ? GlobalEngine.socialNetwork.getLoggedInUser() : null);
            ZGlobal.player.initLocalPlayer();
         }
         if(ZGlobal.watchToEarn == null)
         {
            _loc1_ = new WatchToEarnGameFacade();
            ZGlobal.watchToEarn = new WatchToEarnService(_loc1_);
         }
         ZGlobal.game = new ZGameManager();
         ZGlobal.game.addEventListener(Event.COMPLETE,this.onGameWorldInitialized,false,0,true);
         ZGlobal.game.initialize();
      }
      
      private function onFriendSetupComplete(param1:NeighborsEvent) : void
      {
         if(ZGlobal.player == null)
         {
            ZGlobal.player = new Player(GlobalEngine.socialNetwork ? GlobalEngine.socialNetwork.getLoggedInUser() : null);
            ZGlobal.player.initLocalPlayer();
         }
         ZGlobal.player.setFriends(GlobalEngine.socialNetwork.getFriendUsers());
         ZGlobal.player.friendsLoaded = true;
         ZGlobal.player.appFriends = GlobalEngine.socialNetwork.getAppFriendsIds();
         NeighborsDispatcher.instance.removeEventListener(NeighborsEvent.SETUP_COMPLETE,this.onFriendSetupComplete);
         NeighborsDispatcher.instance.dispatchEvent(new NeighborsEvent(NeighborsEvent.FRIENDS_LOADED,null));
      }
      
      protected function onGameWorldInitialized(param1:Event = null) : void
      {
         ZGlobal.game.removeEventListener(Event.COMPLETE,this.onGameWorldInitialized);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

