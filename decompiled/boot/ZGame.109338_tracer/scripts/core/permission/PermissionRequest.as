package core.permission
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   public class PermissionRequest extends EventDispatcher
   {
      
      private var m_type:String;
      
      public function PermissionRequest(param1:String)
      {
         super();
         this.m_type = param1;
      }
      
      public function send() : void
      {
         this.onDialogConfirm(null);
      }
      
      private function onDialogConfirm(param1:Event) : void
      {
         var _loc2_:Array = null;
         if(ExternalInterface.available)
         {
            _loc2_ = PermissionTypes.getPermissionsByType(this.m_type);
            ExternalInterface.addCallback("onPermSuccess",this.onPermSuccess);
            ExternalInterface.addCallback("onPermFailure",this.onPermFailure);
            ExternalInterface.call("requestPermissions",_loc2_);
         }
      }
      
      private function onDialogDismiss(param1:Event) : void
      {
         dispatchEvent(new PermissionEvent(PermissionEvent.DISMISSED,this.m_type,false,false));
      }
      
      private function onPermSuccess() : void
      {
         dispatchEvent(new PermissionEvent(PermissionEvent.GRANTED,this.m_type,false,false));
      }
      
      private function onPermFailure() : void
      {
         dispatchEvent(new PermissionEvent(PermissionEvent.DISMISSED,this.m_type,false,false));
      }
   }
}

