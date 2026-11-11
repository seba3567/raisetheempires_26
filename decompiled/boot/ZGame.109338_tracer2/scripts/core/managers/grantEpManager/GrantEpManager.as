package core.managers.grantEpManager
{
   import core.ZGlobal;
   import core.ui.PlayerFeedbackManager;
   import dispatchers.MessageDispatcher;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class GrantEpManager extends EventDispatcher
   {
      
      private static var m_instance:GrantEpManager;
      
      public static const EVENT_SHOWN_ALL_MESSAGES:String = "grantEpShownAllMessages";
      
      private var m_initUnixTimeStamp:Number;
      
      public function GrantEpManager()
      {
         super();
         var _loc1_:Date = new Date();
         this.m_initUnixTimeStamp = Math.round(_loc1_.getTime() / 1000);
      }
      
      public static function get instance() : GrantEpManager
      {
         if(!m_instance)
         {
            m_instance = new GrantEpManager();
         }
         return m_instance;
      }
      
      public function initialize() : void
      {
         MessageDispatcher.instance.addEventListener(MessageDispatcher.GRANT_EP,this.onGrantEp);
      }
      
      public function onGrantEp(param1:WorldEvent) : void
      {
         if(param1.eventData == null)
         {
            Logger.debug(this,"onGrantEp","No data received!!!");
            return;
         }
         if(param1.eventData.ep)
         {
            ZGlobal.player.cash += parseInt(param1.eventData.ep);
            this.toasterDisplayResourceUpdate("Cash",param1.eventData.ep);
         }
      }
      
      private function toasterDisplayResourceUpdate(param1:String, param2:Number) : void
      {
         var _loc3_:String = ZGameUtils.ZlocT("Main",param1);
         PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackResourcesEpReceived",{
            "item":_loc3_,
            "amount":param2
         }),null,true);
      }
   }
}

