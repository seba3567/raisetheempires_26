package core.managers
{
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import transactions.TFriendQuery;
   import zlabs.Zlab;
   
   public class FriendManager extends EventDispatcher
   {
      
      public static var instance:FriendManager = new FriendManager();
      
      public static var FRIEND_INFO_RECEIVED:String = "friendInfoReceived";
      
      private static var QUERY_DELAY:Number = 10000;
      
      public var m_nonAppFriendInfo:Array = new Array();
      
      private var m_tx:TFriendQuery;
      
      private var m_friendInfoReceived:Boolean;
      
      public function FriendManager()
      {
         super();
      }
      
      public function get friendInfoReceived() : Boolean
      {
         return this.m_friendInfoReceived;
      }
      
      public function startQueryTimer() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         Zlab.processManager.schedule(QUERY_DELAY,this,this.doQuery);
      }
      
      public function startQueryTimerImmediate() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.doQuery();
      }
      
      public function onFriendQueryComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         this.m_tx = null;
         if(param1.nonAppFriends)
         {
            for each(_loc2_ in param1.nonAppFriends)
            {
               _loc3_ = _loc2_.portrait;
               _loc4_ = _loc2_.first_name;
               _loc5_ = _loc2_.sex;
               _loc6_ = _loc2_.zid;
               this.m_nonAppFriendInfo.push({
                  "uid":_loc6_,
                  "firstName":_loc4_,
                  "portraitURL":_loc3_,
                  "genderTag":_loc5_
               });
            }
         }
         this.m_friendInfoReceived = true;
         dispatchEvent(new Event(FRIEND_INFO_RECEIVED));
      }
      
      public function getRandomFriends(param1:int) : Array
      {
         if(this.m_nonAppFriendInfo.length <= param1)
         {
            return this.m_nonAppFriendInfo;
         }
         var _loc2_:Array = this.m_nonAppFriendInfo.splice(0,param1);
         this.m_nonAppFriendInfo = this.m_nonAppFriendInfo.concat(_loc2_);
         return _loc2_;
      }
      
      private function doQuery() : void
      {
         if(!this.m_tx && !this.m_friendInfoReceived)
         {
            this.m_tx = new TFriendQuery();
            TransactionManager.addTransaction(this.m_tx,true);
         }
      }
   }
}

