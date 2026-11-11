package core.ui
{
   import core.ui.actionfeedback.GenericActionFeedback;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class PlayerFeedbackManager extends EventDispatcher
   {
      
      public static const DISPLAY_FEEDBACK:String = "displayFeedback";
      
      private static var m_instance:PlayerFeedbackManager = null;
      
      public function PlayerFeedbackManager()
      {
         super();
      }
      
      public static function get instance() : PlayerFeedbackManager
      {
         if(!m_instance)
         {
            m_instance = new PlayerFeedbackManager();
         }
         return m_instance;
      }
      
      public function displayFeedback(param1:String, param2:Object = null, param3:String = null, param4:String = null, param5:String = null) : void
      {
         var _loc6_:GenericActionFeedback = null;
         if(param2 != null)
         {
            _loc6_ = new GenericActionFeedback(param2,param1);
         }
         if(null == param3)
         {
            param3 = param1;
         }
         this.displayToaster(param3,param4,true,param5);
      }
      
      public function displayToaster(param1:String, param2:String = null, param3:Boolean = false, param4:String = null) : void
      {
         var _loc5_:Object = new Object();
         _loc5_.message = param1;
         _loc5_.targetId = param2;
         _loc5_.doesQueue = param3;
         _loc5_.imgURL = param4;
         dispatchEvent(new WorldEvent(DISPLAY_FEEDBACK,_loc5_));
      }
   }
}

