package Engine.Classes
{
   public class BaseIdleTask
   {
      
      public static const DEFAULT_QUEUE_COOLDOWN_MILLISECONDS:Number = 1000;
      
      public static const DEFAULT_MOUSE_MILLISECONDS:Number = 5000;
      
      public static const DEFAULT_ACTION_QUEUE_MILLISECONDS:Number = 5000;
      
      public static const DEFAULT_POPUP_QUEUE_MILLISECONDS:Number = 5000;
      
      public function BaseIdleTask()
      {
         super();
      }
      
      public function get requireMouseIdle() : Boolean
      {
         return true;
      }
      
      public function get minMouseIdleMilliseconds() : Number
      {
         return DEFAULT_MOUSE_MILLISECONDS;
      }
      
      public function get requireActionQueueIdle() : Boolean
      {
         return true;
      }
      
      public function get minActionIdleMilliseconds() : Number
      {
         return DEFAULT_ACTION_QUEUE_MILLISECONDS;
      }
      
      public function get requirePopupQueueEmpty() : Boolean
      {
         return true;
      }
      
      public function get minPopupIdleMilliseconds() : Number
      {
         return DEFAULT_POPUP_QUEUE_MILLISECONDS;
      }
      
      public function get queueCoolDownMilliseconds() : Number
      {
         return DEFAULT_QUEUE_COOLDOWN_MILLISECONDS;
      }
      
      public function get singleton() : Boolean
      {
         return true;
      }
      
      public function get singletonClobber() : Boolean
      {
         return false;
      }
      
      public function get shouldAdd() : Boolean
      {
         return true;
      }
      
      public function get canFire() : Boolean
      {
         return true;
      }
      
      public function fire() : void
      {
         throw new Error("BaseIdleTask fire() must be overwritten!");
      }
      
      final public function submit() : void
      {
         IdleTaskQueue.getInstance().addTask(this);
      }
   }
}

