package init
{
   import Engine.Init.InitializationAction;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ActionQueue extends EventDispatcher
   {
      
      public static var instance:ActionQueue = new ActionQueue();
      
      protected var m_theQ:Array;
      
      private var m_currentAction:InitializationAction;
      
      public function ActionQueue()
      {
         super();
         this.m_theQ = new Array();
      }
      
      public function add(param1:InitializationAction) : void
      {
         this.m_theQ.push(param1);
      }
      
      public function execute() : void
      {
         if(!this.doNextAction())
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function cancel() : void
      {
         this.m_theQ = new Array();
      }
      
      protected function onActionCompleted(param1:Event = null) : void
      {
         this.m_currentAction.removeEventListener(Event.COMPLETE,this.onActionCompleted);
         this.m_currentAction = null;
         this.execute();
      }
      
      protected function doNextAction() : Boolean
      {
         if(this.m_theQ.length > 0)
         {
            this.m_currentAction = this.m_theQ.shift();
            this.m_currentAction.addEventListener(Event.COMPLETE,this.onActionCompleted);
            this.m_currentAction.execute();
            return true;
         }
         return false;
      }
   }
}

