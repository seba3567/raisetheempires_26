package core.managers
{
   import core.ui.PlayerFeedbackManager;
   import displays.popups.quest.QuestCompletePopup;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   
   public class DroneCommandManager extends EventDispatcher
   {
      
      public static const STATE_DOESNT_EXIST:int = 0;
      
      public static const STATE_ACCUMULATING:int = 22;
      
      public static const STATE_ACTIVE:int = 24;
      
      public static const STATE_COOLING:int = 25;
      
      public static const STATE_DURATION:int = 900;
      
      public static const COOLING_DURATION:int = 86400;
      
      public static const DRONE_COMMAND_BUILDABLE:String = "BB27";
      
      private static var m_instance:DroneCommandManager = null;
      
      protected var m_popup:QuestCompletePopup = null;
      
      private var m_currentState:int = 0;
      
      private var m_prevState:int = 0;
      
      private var m_currentStateStart:int = 0;
      
      public function DroneCommandManager()
      {
         super();
      }
      
      public static function get instance() : DroneCommandManager
      {
         if(!m_instance)
         {
            m_instance = new DroneCommandManager();
         }
         return m_instance;
      }
      
      public function setCurrentState(param1:int, param2:int = 0) : void
      {
         if(param1 == STATE_ACCUMULATING && this.m_prevState != STATE_ACCUMULATING)
         {
            this.m_prevState = STATE_ACCUMULATING;
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Drone_Command_Center_toaster1"));
         }
         if(param1 == STATE_ACTIVE && this.m_prevState != STATE_ACTIVE)
         {
            this.m_prevState = STATE_ACTIVE;
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Drone_Command_Center_toaster2"));
         }
         if(param1 == STATE_COOLING && this.m_prevState != STATE_COOLING)
         {
            this.m_prevState = STATE_COOLING;
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Drone_Command_Center_toaster3"));
         }
         if(!param2)
         {
            param2 = GlobalEngine.serverTime / 1000;
         }
         this.m_currentState = param1;
         this.m_currentStateStart = param2;
      }
      
      public function isActive() : Boolean
      {
         if(this.m_currentState == STATE_ACTIVE && GlobalEngine.serverTime / 1000 - this.m_currentStateStart < STATE_DURATION)
         {
            return true;
         }
         return false;
      }
      
      public function isAccumulating() : Boolean
      {
         if(this.m_currentState == STATE_ACCUMULATING || this.m_currentState == STATE_COOLING && GlobalEngine.serverTime / 1000 - this.m_currentStateStart >= COOLING_DURATION)
         {
            return true;
         }
         return false;
      }
   }
}

