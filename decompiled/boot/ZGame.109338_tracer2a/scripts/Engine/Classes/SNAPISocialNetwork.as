package Engine.Classes
{
   import Engine.Constants;
   import Engine.Events.SocialNetworkEvent;
   import Engine.Managers.ErrorManager;
   import flash.display.StageDisplayState;
   import flash.external.ExternalInterface;
   
   public class SNAPISocialNetwork extends SocialNetwork
   {
      
      protected var m_snapiUser:Object;
      
      protected var m_friends:Array;
      
      protected var m_appFriends:Array;
      
      protected var m_offlineMode:Boolean;
      
      protected var m_offlineModeId:Number;
      
      protected var m_accessToken:AccessToken = null;
      
      public function SNAPISocialNetwork(param1:String = null, param2:String = null)
      {
         var _loc6_:Number = NaN;
         super();
         var _loc3_:String = null;
         var _loc4_:Object = GlobalEngine.getFlashVars();
         var _loc5_:Boolean = false;
         if(_loc4_.decouple_from_facebook)
         {
            GlobalEngine.log("SNAPI","Attempting to decouple from SNAPI");
            _loc6_ = parseFloat(_loc4_.decoupled_facebook_id);
            if(isNaN(_loc6_))
            {
               GlobalEngine.log("SNAPI","Can\'t decouple from SNAPI, invalid ID");
               _loc5_ = false;
            }
            else
            {
               this.m_offlineModeId = _loc6_;
               _loc5_ = true;
               GlobalEngine.log("SNAPI","Succesfully decoupled from SNAPI.  OfflineId: " + this.m_offlineModeId);
            }
         }
         if(_loc5_)
         {
            this.m_offlineMode = true;
         }
      }
      
      override public function getAccessToken() : AccessToken
      {
         var connections:Object = null;
         var connectionSN:Object = null;
         var snId:Object = null;
         var snIDInt:int = 0;
         if(this.m_accessToken)
         {
            return this.m_accessToken;
         }
         try
         {
            connections = ExternalInterface.call("SNAPI.getAllConnections");
            snId = ExternalInterface.call("SNAPI.getSNID");
            snIDInt = 1;
            if(Boolean(connections != null && (connectionSN = connections[snId])) && Boolean(connectionSN.hasOwnProperty("session")) && Boolean(connectionSN.session.hasOwnProperty("access_token")))
            {
               this.m_accessToken = new AccessToken();
               this.m_accessToken.token = connectionSN.session.access_token;
               this.m_accessToken.expires = connectionSN.session.expires;
            }
            else
            {
               GlobalEngine.log("SNAPI","Error parsing SNAPI.getAllConnections() object");
            }
         }
         catch(err:Error)
         {
            GlobalEngine.log("SNAPI","Error calling SNAPI.getAllConnections()");
         }
         return this.m_accessToken;
      }
      
      public function getUser() : void
      {
         var userData:Object = null;
         var key:String = null;
         try
         {
            userData = ExternalInterface.call("getUserInfo");
            if(userData != null && userData.hasOwnProperty("zid"))
            {
               this.m_snapiUser = new Object();
               for(key in userData)
               {
                  this.m_snapiUser[key] = userData[key];
               }
            }
         }
         catch(err:Error)
         {
         }
         if(this.m_snapiUser != null && this.m_snapiUser.zid == 0)
         {
            this.m_snapiUser = null;
         }
         if(this.m_snapiUser == null && !this.m_offlineMode)
         {
            GlobalEngine.error("SNAPI","Unable to load SNAPI user info from JS.");
            ErrorManager.addError("Unable to load SNAPI user info from JS.",ErrorManager.ERROR_FAILED_TO_LOAD);
         }
         dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_USER_COMPLETE));
      }
      
      protected function getExtendedPermissions() : void
      {
      }
      
      override public function getLoggedInUserId() : String
      {
         var _loc1_:String = null;
         if(this.m_snapiUser)
         {
            _loc1_ = this.m_snapiUser.zid.toString();
         }
         else if(this.m_offlineMode)
         {
            _loc1_ = this.m_offlineModeId.toString();
         }
         return _loc1_;
      }
      
      override public function getLoggedInUser() : SocialNetworkUser
      {
         return this.toSocialNetworkUser(this.m_snapiUser);
      }
      
      public function getFriendList() : void
      {
         try
         {
            this.m_friends = ExternalInterface.call("getFriendData");
         }
         catch(err:Error)
         {
         }
         if(this.m_friends == null && this.m_offlineMode == false)
         {
            GlobalEngine.error("SNAPI","Unable to load friend data from JS");
            ErrorManager.addError("Unable to load SNAPI friend data from JS.",ErrorManager.ERROR_FAILED_TO_LOAD);
         }
         dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_FRIENDS_COMPLETE));
      }
      
      public function getAppFriends() : void
      {
         try
         {
            this.m_appFriends = ExternalInterface.call("getAppFriendIds");
         }
         catch(err:Error)
         {
         }
         if(this.m_appFriends == null && this.m_offlineMode == false)
         {
            GlobalEngine.log("SNAPI","Unable to load appFriendIds from JS");
            ErrorManager.addError("Unable to load SNAPI appFriendIds from JS",ErrorManager.ERROR_FAILED_TO_LOAD);
         }
         dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE));
      }
      
      override public function getFriendUsers() : Array
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:SocialNetworkUser = null;
         var _loc1_:Array = [];
         if(this.m_friends)
         {
            _loc2_ = this.m_friends;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = this.toSocialNetworkUser(_loc2_[_loc3_]);
               _loc1_.push(_loc4_);
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      override public function getAppFriendsIds() : Array
      {
         return this.m_appFriends;
      }
      
      override public function streamPublish(param1:Object, param2:Object, param3:String, param4:String = null, param5:Function = null, param6:Boolean = false, param7:String = "") : void
      {
         throw new Error("Cannot use streamPublish with SNAPI, please use snapiStreamPublish");
      }
      
      public function snapiStreamPublish(param1:Object) : void
      {
         var data:Object = param1;
         try
         {
            if(ExternalInterface.available)
            {
               if(GlobalEngine.stage.displayState == StageDisplayState.FULL_SCREEN)
               {
                  GlobalEngine.stage.displayState = StageDisplayState.NORMAL;
               }
               ExternalInterface.call("snapiStreamPublish",data);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      override public function showStreamPermissions(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.showStreamPermissions(callback);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("showStreamPermissions");
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      override public function showBookmarkDialog() : void
      {
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("showBookmarkDialog");
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      override public function showEmailPermission(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.showEmailPermission(callback);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("showEmailPermission");
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      private function appendQueryParam(param1:String, param2:String, param3:String) : String
      {
         var _loc4_:String = "&";
         if(param1.indexOf("?") == -1)
         {
            _loc4_ = "?";
         }
         return param1 + _loc4_ + escape(param2) + "=" + escape(param3);
      }
      
      override public function sendRequest(param1:Array, param2:String, param3:String, param4:String, param5:Object = null) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("requestSend",param1,param2,param3,param4,param5);
         }
      }
      
      protected function toSocialNetworkUser(param1:Object) : SocialNetworkUser
      {
         var _loc2_:SocialNetworkUser = null;
         if(this.m_offlineMode)
         {
            _loc2_ = new SocialNetworkUser(this.m_offlineModeId,Constants.NO_NETWORK);
            _loc2_.firstName = "Decoupled";
            _loc2_.name = "Decoupled";
            _loc2_.picture = "";
         }
         else
         {
            _loc2_ = new SocialNetworkUser(param1.zid);
            _loc2_.firstName = param1.first_name;
            _loc2_.name = param1.name;
            if(this.getAccessToken())
            {
               _loc2_.picture = this.appendQueryParam(param1.pic_square,"access_token",this.getAccessToken().token);
            }
            else
            {
               _loc2_.picture = param1.pic_square;
            }
            _loc2_.gender = param1.sex;
         }
         return _loc2_;
      }
      
      public function formatFacebookProfilePicUrl(param1:String) : String
      {
         var _loc2_:String = param1;
         var _loc3_:int = param1.indexOf("?");
         if(_loc3_ > 0)
         {
            _loc2_ = param1.substring(0,_loc3_);
         }
         _loc2_ += "?type=square";
         if(this.getAccessToken())
         {
            _loc2_ += "&access_token=" + this.getAccessToken().token;
         }
         return _loc2_;
      }
   }
}

