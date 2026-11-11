package init
{
   import Engine.Classes.SNAPISocialNetwork;
   import Engine.Events.SocialNetworkEvent;
   import dispatchers.NeighborsDispatcher;
   import events.NeighborsEvent;
   import flash.events.Event;
   
   public class SNAPIInit extends SocialNetworkInit
   {
      
      protected var m_sn:SNAPISocialNetwork;
      
      protected var m_snClass:Class = null;
      
      public function SNAPIInit(param1:Boolean, param2:Class = null)
      {
         if(param2 == null)
         {
            param2 = SNAPISocialNetwork;
         }
         this.m_snClass = param2;
         super(param1);
      }
      
      override public function execute() : void
      {
         if(m_skipSN)
         {
            super.execute();
         }
         else
         {
            GlobalEngine.socialNetwork = this.m_sn = new this.m_snClass();
            this.m_sn.addEventListener(SocialNetworkEvent.GET_USER_COMPLETE,this.onGetUserComplete);
            this.m_sn.getUser();
         }
      }
      
      private function onGetUserComplete(param1:SocialNetworkEvent) : void
      {
         this.m_sn.removeEventListener(SocialNetworkEvent.GET_USER_COMPLETE,this.onGetUserComplete);
         dispatchEvent(new Event(Event.COMPLETE));
         this.m_sn.addEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.onGetFriendsComplete);
         this.m_sn.getFriendList();
      }
      
      private function onGetFriendsComplete(param1:SocialNetworkEvent) : void
      {
         this.m_sn.removeEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.onGetFriendsComplete);
         this.m_sn.addEventListener(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE,this.onGetAppFriendsComplete);
         this.m_sn.getAppFriends();
      }
      
      private function onGetAppFriendsComplete(param1:SocialNetworkEvent) : void
      {
         this.m_sn.removeEventListener(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE,this.onGetAppFriendsComplete);
         this.setupOnFriendsComplete();
      }
      
      protected function setupOnFriendsComplete() : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new NeighborsEvent(NeighborsEvent.SETUP_COMPLETE,null));
      }
   }
}

