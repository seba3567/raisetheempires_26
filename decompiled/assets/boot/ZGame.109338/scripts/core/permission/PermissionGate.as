package core.permission
{
   import core.ZGlobal;
   import flash.utils.Dictionary;
   
   public class PermissionGate implements IPermissionGate
   {
      
      private var m_permReqs:Dictionary = new Dictionary();
      
      public function PermissionGate()
      {
         super();
      }
      
      public function attempt(param1:String, param2:Function, param3:Function = null) : void
      {
         var _loc4_:PermissionRequest = null;
         if(!ZGlobal.player.permissionsManager.hasPermissionsByType(param1))
         {
            _loc4_ = new PermissionRequest(param1);
            this.m_permReqs[_loc4_] = {
               "onSuccess":param2,
               "onFailure":param3
            };
            _loc4_.addEventListener(PermissionEvent.GRANTED,this.onPermGranted);
            _loc4_.addEventListener(PermissionEvent.DISMISSED,this.onPermDismissed);
            _loc4_.send();
         }
         else
         {
            param2.apply();
         }
      }
      
      private function onPermGranted(param1:PermissionEvent) : void
      {
         var _loc2_:PermissionRequest = PermissionRequest(param1.target);
         _loc2_.removeEventListener(PermissionEvent.GRANTED,this.onPermGranted);
         _loc2_.removeEventListener(PermissionEvent.DISMISSED,this.onPermDismissed);
         var _loc3_:Object = this.m_permReqs[_loc2_];
         _loc3_.onSuccess.apply();
         ZGlobal.player.permissionsManager.addPermissionsByType(param1.permType);
         delete this.m_permReqs[_loc2_];
      }
      
      private function onPermDismissed(param1:PermissionEvent) : void
      {
         var _loc2_:PermissionRequest = PermissionRequest(param1.target);
         _loc2_.removeEventListener(PermissionEvent.GRANTED,this.onPermGranted);
         _loc2_.removeEventListener(PermissionEvent.DISMISSED,this.onPermDismissed);
         var _loc3_:Object = this.m_permReqs[_loc2_];
         if(_loc3_.onFailure)
         {
            _loc3_.onFailure.apply();
         }
         delete this.m_permReqs[_loc2_];
      }
   }
}

