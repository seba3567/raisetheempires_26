package init
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.player.Player;
   import flash.events.Event;
   import networks.NullSocialNetwork;
   
   public class SocialNetworkInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "SocialNetworkInit";
      
      protected var m_skipSN:Boolean = false;
      
      public function SocialNetworkInit(param1:Boolean)
      {
         super(INIT_ID);
         this.m_skipSN = param1;
         addDependency(GameSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         if(this.m_skipSN)
         {
            GlobalEngine.socialNetwork = new NullSocialNetwork();
            ZGlobal.player = new Player(null);
            ZGlobal.player.initNonSocial();
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

