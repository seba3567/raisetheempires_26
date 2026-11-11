package core.managers.assetLoadTracker
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import utils.ZGameTimeUtil;
   import zlabs.debug.Logger;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class AssetLoadTracker extends EventDispatcher
   {
      
      public static var GlobalDispatcher:EventDispatcher = new EventDispatcher();
      
      public static const GLOBAL_ASSETS_LOADED:String = "assetgloballoaded";
      
      public static const RELEASE_OBJECTS:String = "assetloadnewworld";
      
      public static const ENTITYDESTROYED:String = "EntityDestroyed";
      
      private var m_refCount:int = 0;
      
      private var m_list:Array = null;
      
      private var m_startTime:Number = 0;
      
      public function AssetLoadTracker()
      {
         super();
         this.m_list = new Array();
         this.m_startTime = GlobalEngine.getTimer() / 1000;
         GlobalDispatcher.addEventListener(RELEASE_OBJECTS,this.onObjectsReleased);
      }
      
      public function addRef(param1:EventDispatcher) : void
      {
         ++this.m_refCount;
         param1.addEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onEntityLoaded);
         param1.addEventListener(ENTITYDESTROYED,this.onEntityDestroyed);
         this.m_list.push(param1);
      }
      
      private function onEntityLoaded(param1:Event) : void
      {
         var _loc3_:Number = NaN;
         this.releaseObject(param1.target as EventDispatcher);
         var _loc2_:int = this.m_list.indexOf(param1.target);
         if(_loc2_ >= 0)
         {
            this.m_list.splice(_loc2_,1);
            --this.m_refCount;
            if(this.m_refCount < 0)
            {
               this.m_refCount = 0;
               Logger.error(this,"onEntityLoaded","ref count gone negative");
            }
            if(this.m_refCount == 0)
            {
               this.dispose();
               dispatchEvent(new Event(Event.COMPLETE));
               GlobalDispatcher.dispatchEvent(new Event(GLOBAL_ASSETS_LOADED));
               _loc3_ = GlobalEngine.getTimer() / 1000;
               Logger.info(this,"onEntityLoaded","Tracked load complete: time = " + ZGameTimeUtil.instance.getTimeString(_loc3_ - this.m_startTime));
            }
         }
         else
         {
            Logger.error(this,"onEntityLoaded","dispatcher not found");
         }
      }
      
      private function onEntityDestroyed(param1:Event) : void
      {
         this.onEntityLoaded(param1);
      }
      
      private function onObjectsReleased(param1:Event) : void
      {
         var _loc2_:EventDispatcher = null;
         if(this.m_list)
         {
            for each(_loc2_ in this.m_list)
            {
               this.releaseObject(_loc2_);
            }
            this.dispose();
         }
      }
      
      private function releaseObject(param1:EventDispatcher) : void
      {
         param1.removeEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onEntityLoaded);
         param1.removeEventListener(ENTITYDESTROYED,this.onEntityDestroyed);
      }
      
      private function dispose() : void
      {
         GlobalDispatcher.removeEventListener(RELEASE_OBJECTS,this.onObjectsReleased);
         this.m_list = null;
         this.m_refCount = 0;
      }
   }
}

