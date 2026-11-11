package core.permission
{
   public class PermissionManager
   {
      
      private var m_currentPerms:Array = [];
      
      private var m_rewardedPerms:Array = [];
      
      private var m_permissionsLoaded:Boolean = false;
      
      private var m_callbacksOnInit:Vector.<Function>;
      
      public function PermissionManager()
      {
         super();
      }
      
      public function permissionsLoaded() : Boolean
      {
         return this.m_permissionsLoaded;
      }
      
      public function addCallbackOnInit(param1:Function) : void
      {
         if(this.m_permissionsLoaded)
         {
            param1();
         }
         else
         {
            if(!this.m_callbacksOnInit)
            {
               this.m_callbacksOnInit = new Vector.<Function>();
            }
            this.m_callbacksOnInit.push(param1);
         }
      }
      
      public function receivePermissions(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Function = null;
         this.m_currentPerms = [];
         for(_loc2_ in param1)
         {
            if(param1[_loc2_] == 1)
            {
               this.m_currentPerms.push(_loc2_);
            }
         }
         this.m_permissionsLoaded = true;
         for each(_loc3_ in this.m_callbacksOnInit)
         {
            _loc3_();
         }
         this.m_callbacksOnInit = new Vector.<Function>();
      }
      
      public function loadObject(param1:Object) : void
      {
         this.m_rewardedPerms = param1.rewardedPerms;
      }
      
      public function typeRewardable(param1:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc2_:Boolean = true;
         var _loc3_:Array = PermissionTypes.getPermissionsByType(param1);
         for each(_loc4_ in _loc3_)
         {
            if(this.m_rewardedPerms.indexOf(_loc4_) != -1)
            {
               _loc2_ = false;
               break;
            }
         }
         return _loc2_;
      }
      
      public function hasPermissionsByType(param1:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc2_:Array = PermissionTypes.getPermissionsByType(param1);
         var _loc3_:Boolean = true;
         for each(_loc4_ in _loc2_)
         {
            if(this.m_currentPerms.indexOf(_loc4_) == -1)
            {
               _loc3_ = false;
               break;
            }
         }
         return _loc3_;
      }
      
      public function addPermissionsByType(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc2_:Array = PermissionTypes.getPermissionsByType(param1);
         var _loc3_:Array = [];
         for each(_loc4_ in _loc2_)
         {
            if(this.m_currentPerms.indexOf(_loc4_) == -1)
            {
               this.m_currentPerms.push(_loc4_);
            }
         }
      }
      
      public function flagPermissionRewarded(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = PermissionTypes.getPermissionsByType(param1);
         for each(_loc3_ in _loc2_)
         {
            if(this.m_rewardedPerms.indexOf(_loc3_) == -1)
            {
               this.m_rewardedPerms.push(_loc3_);
            }
         }
      }
   }
}

