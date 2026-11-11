package core.entities.components.utils
{
   import zlabs.core.ITickedObject;
   
   public class ServerTimeProgressionHelper implements ITickedObject
   {
      
      protected var m_actionStartTime:Number;
      
      protected var m_actionDuration:Number;
      
      protected var m_onComplete:Function;
      
      protected var m_onProgress:Function;
      
      protected var m_active:Boolean;
      
      public function ServerTimeProgressionHelper(param1:Number = 0, param2:Number = 0, param3:Function = null, param4:Function = null)
      {
         super();
         if(isNaN(param1) || param1 == 0)
         {
            this.m_actionStartTime = GlobalEngine.getTimer();
         }
         else
         {
            this.m_actionStartTime = param1;
         }
         this.m_actionDuration = param2 * 1000;
         this.m_onComplete = param3;
         this.m_onProgress = param4;
         this.m_active = true;
      }
      
      public function onTick(param1:Number) : void
      {
         if(this.m_active == false)
         {
            return;
         }
         var _loc2_:Number = this.currentProgress;
         if(_loc2_ > 1)
         {
            this.m_active = false;
            if(this.m_onComplete != null)
            {
               this.m_onComplete();
            }
         }
         else if(this.m_onProgress != null)
         {
            this.m_onProgress(_loc2_);
         }
      }
      
      public function get currentProgress() : Number
      {
         return this.elapsedTime / this.m_actionDuration;
      }
      
      public function get remainingDuration() : Number
      {
         return this.m_actionDuration - this.elapsedTime;
      }
      
      public function get startTime() : Number
      {
         return this.m_actionStartTime;
      }
      
      public function get elapsedTime() : Number
      {
         return Math.max(0,GlobalEngine.getTimer() - this.m_actionStartTime);
      }
      
      public function get actionDuration() : Number
      {
         return this.m_actionDuration;
      }
      
      public function setProgress(param1:Number) : void
      {
         var _loc2_:Number = param1 * this.m_actionDuration;
         this.m_actionStartTime = GlobalEngine.getTimer() - _loc2_;
      }
   }
}

