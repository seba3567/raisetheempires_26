package core.player
{
   import core.ZGlobal;
   
   public class Friend implements IAlly
   {
      
      public var m_coins:int = 0;
      
      public var m_xp:int = 0;
      
      public var m_level:int = 0;
      
      public var m_socialXpGood:int = 0;
      
      public var m_socialLevelGood:int = 0;
      
      public var m_socialXpBad:int = 0;
      
      public var m_socialLevelBad:int = 0;
      
      public var m_resourceType:int = 0;
      
      public var m_profilePic:String = "";
      
      public var m_name:String = "";
      
      public var m_uid:String = "";
      
      private var m_tendInfo:Object = null;
      
      public var m_fake:Boolean;
      
      public var m_empty:Boolean;
      
      public var m_dominanceRank:int = -1;
      
      public var m_mmFriend:Boolean = false;
      
      public function Friend(param1:String, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:String, param11:String, param12:int, param13:Boolean = false, param14:Boolean = false, param15:Boolean = false)
      {
         super();
         this.m_coins = param2;
         this.m_xp = param3;
         this.m_level = param4;
         this.m_socialXpGood = param5;
         this.m_socialLevelGood = param6;
         this.m_socialXpBad = param7;
         this.m_socialLevelBad = param8;
         this.m_resourceType = param9;
         this.m_profilePic = param10;
         this.m_name = param11;
         this.m_uid = param1;
         this.m_dominanceRank = param12;
         this.m_fake = param14;
         this.m_empty = param15;
         this.m_mmFriend = param13;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function get xp() : int
      {
         return this.m_xp;
      }
      
      public function get fake() : Boolean
      {
         return this.m_fake;
      }
      
      public function get empty() : Boolean
      {
         return this.m_empty;
      }
      
      public function get id() : String
      {
         return this.uid;
      }
      
      public function get imageUrl() : String
      {
         var _loc1_:String = "";
         var _loc2_:Player = ZGlobal.player.findFriendById(this.uid);
         if(_loc2_)
         {
            _loc1_ = _loc2_.snUser.picture;
         }
         return _loc1_;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function get firstName() : String
      {
         var _loc1_:String = ZGlobal.player.getFriendFirstName(this.uid);
         if(_loc1_)
         {
            return _loc1_;
         }
         return this.m_name;
      }
      
      public function get gender() : String
      {
         var _loc1_:String = "";
         var _loc2_:Player = ZGlobal.player.findFriendById(this.uid);
         if(_loc2_)
         {
            _loc1_ = _loc2_.snUser.gender;
         }
         return _loc1_;
      }
      
      public function set tendInfo(param1:Object) : void
      {
         this.m_tendInfo = param1;
      }
      
      public function get tendInfo() : Object
      {
         return this.m_tendInfo;
      }
      
      public function get matchMakingFriend() : Boolean
      {
         return this.m_mmFriend;
      }
   }
}

