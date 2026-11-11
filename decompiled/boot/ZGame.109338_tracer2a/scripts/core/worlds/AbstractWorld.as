package core.worlds
{
   import core.factory.IFactory;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class AbstractWorld extends EventDispatcher
   {
      
      public static const INIT_COMPLETE:String = "worldInitComplete";
      
      public static const LOAD_OBJECTS_COMPLETE:String = "worldLoadObjects";
      
      protected var m_factory:IFactory;
      
      private var _id:String;
      
      public function AbstractWorld(param1:String)
      {
         super();
         this._id = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function initialize() : void
      {
         dispatchEvent(new Event(INIT_COMPLETE));
      }
      
      public function loadObjects(param1:Object) : void
      {
         dispatchEvent(new Event(LOAD_OBJECTS_COMPLETE));
      }
      
      public function releaseObjects() : void
      {
      }
      
      public function dispose() : void
      {
         this.m_factory.dispose();
         this.m_factory = null;
      }
   }
}

