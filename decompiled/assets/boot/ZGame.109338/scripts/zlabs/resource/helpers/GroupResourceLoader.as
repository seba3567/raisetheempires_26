package zlabs.resource.helpers
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.Resource;
   import zlabs.resource.SWFResource;
   
   public class GroupResourceLoader extends EventDispatcher
   {
      
      private var m_resource:SWFResource;
      
      public var m_items:Array;
      
      public function GroupResourceLoader(param1:String, ... rest)
      {
         super();
         Zlab.resourceManager.load(param1,SWFResource,this.onLoadComplete,this.onLoadFailed);
         this.m_items = rest;
      }
      
      public function onLoadComplete(param1:Resource) : void
      {
         this.m_resource = param1 as SWFResource;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function get resource() : SWFResource
      {
         return this.m_resource;
      }
      
      public function get items() : Array
      {
         return this.m_items;
      }
      
      public function onLoadFailed(param1:Resource) : void
      {
         Logger.error(this,"onLoadFailed","Failed to load Group Resource Loader");
      }
      
      public function destroy() : void
      {
         this.m_resource = null;
         this.m_items = null;
      }
   }
}

