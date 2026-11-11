package core.views
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class ViewManager extends EventDispatcher
   {
      
      private static var m_instance:ViewManager;
      
      public static const ACTIVATE:String = "viewActivate";
      
      public static const DEACTIVATE:String = "viewDeactivate";
      
      public static const RELOAD:String = "viewReload";
      
      public static const CURRENT_VIEW:String = "viewManagerCurrentView";
      
      public static const VIEW_GROUP_NAME:String = "ViewGroups";
      
      private var m_views:Dictionary = new Dictionary();
      
      private var m_currentView:IEntity;
      
      private var m_previousView:String;
      
      private var displayObjectPropRef:PropertyReference = new PropertyReference("@ViewData.renderer");
      
      public function ViewManager()
      {
         super();
      }
      
      public static function get instance() : ViewManager
      {
         if(m_instance == null)
         {
            m_instance = new ViewManager();
         }
         return m_instance;
      }
      
      public function addView(param1:IEntity) : void
      {
         var _loc2_:String = param1.name;
         param1.eventDispatcher.addEventListener("EntityDestroyed",this.onRemoveView,false,0,true);
         this.m_views[_loc2_] = param1;
      }
      
      public function get views() : Dictionary
      {
         return this.m_views;
      }
      
      public function goToView(param1:String) : IEntity
      {
         if(!this.m_views[param1])
         {
            throw new Error("Sorry, View " + param1 + " doesnt exsist in view manager");
         }
         if(this.m_currentView)
         {
            this.m_previousView = this.m_currentView.name;
            this.m_currentView.eventDispatcher.dispatchEvent(new WorldEvent(DEACTIVATE,param1));
         }
         this.m_currentView = this.m_views[param1];
         this.m_currentView.eventDispatcher.dispatchEvent(new Event(ACTIVATE));
         return this.m_currentView;
      }
      
      public function goToPreviousView() : void
      {
         this.goToView(this.m_previousView);
      }
      
      public function getPreviousViewName() : String
      {
         return this.m_previousView;
      }
      
      public function getComponentFromView(param1:String, param2:Class) : IEntityComponent
      {
         if(param1 == CURRENT_VIEW)
         {
            param1 = this.currentViewName;
         }
         var _loc3_:IEntity = this.getView(param1);
         return _loc3_.lookupComponentByType(param2);
      }
      
      public function getComponentFromName(param1:String, param2:String) : IEntityComponent
      {
         if(param1 == CURRENT_VIEW)
         {
            param1 = this.currentViewName;
         }
         var _loc3_:IEntity = this.getView(param1);
         return _loc3_.lookupComponentByName(param2);
      }
      
      public function getView(param1:String) : IEntity
      {
         return this.m_views[param1];
      }
      
      public function get currentViewName() : String
      {
         return this.m_currentView.name;
      }
      
      public function getCurrentView() : IEntity
      {
         return this.m_currentView;
      }
      
      public function get currentView() : IEntity
      {
         return this.getCurrentView();
      }
      
      public function getRendererFromView(param1:IEntity) : DisplayObject
      {
         return param1.getProperty(this.displayObjectPropRef);
      }
      
      public function get currentRenderer() : DisplayObject
      {
         if(this.m_currentView)
         {
            return this.getRendererFromView(this.m_currentView);
         }
         return null;
      }
      
      public function viewRendererByName(param1:String) : DisplayObject
      {
         var _loc2_:IEntity = this.getView(param1);
         if(_loc2_)
         {
            return this.getRendererFromView(_loc2_);
         }
         return null;
      }
      
      private function onRemoveView(param1:Event) : void
      {
         var _loc2_:String = IEntity(param1.target).name;
         this.removeView(_loc2_);
      }
      
      public function removeView(param1:String) : Boolean
      {
         var _loc2_:IEntity = null;
         if(this.m_views[param1])
         {
            _loc2_ = this.m_views[param1];
            _loc2_.eventDispatcher.removeEventListener("EntityDestroyed",this.onRemoveView);
            _loc2_.destroy();
            this.m_views[param1] = null;
            return true;
         }
         return false;
      }
      
      public function removeAllViews() : void
      {
         var _loc1_:IEntity = null;
         for each(_loc1_ in this.m_views)
         {
            this.removeView(_loc1_.name);
         }
      }
      
      public function dispose() : void
      {
         this.m_currentView = null;
         this.removeAllViews();
         this.m_views = null;
      }
   }
}

