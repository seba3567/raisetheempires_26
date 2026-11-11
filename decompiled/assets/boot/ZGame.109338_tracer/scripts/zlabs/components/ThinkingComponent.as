package zlabs.components
{
   import zlabs.Zlab;
   import zlabs.core.IQueuedObject;
   import zlabs.entity.EntityComponent;
   
   public class ThinkingComponent extends EntityComponent implements IQueuedObject
   {
      
      protected var _nextThinkTime:int;
      
      protected var _nextThinkCallback:Function;
      
      public function ThinkingComponent()
      {
         super();
      }
      
      public function think(param1:Function, param2:int) : void
      {
         this._nextThinkTime = Zlab.processManager.virtualTime + param2;
         this._nextThinkCallback = param1;
         Zlab.processManager.queueObject(this);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this._nextThinkCallback = null;
      }
      
      public function get nextThinkTime() : Number
      {
         return this._nextThinkTime;
      }
      
      public function get nextThinkCallback() : Function
      {
         return this._nextThinkCallback;
      }
      
      public function get priority() : int
      {
         return -this._nextThinkTime;
      }
      
      public function set priority(param1:int) : void
      {
         throw new Error("Unimplemented.");
      }
   }
}

