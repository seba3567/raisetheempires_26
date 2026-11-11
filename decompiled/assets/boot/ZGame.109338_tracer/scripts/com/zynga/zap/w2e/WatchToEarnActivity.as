package com.zynga.zap.w2e
{
   import com.zynga.zap.w2e.json.JSON;
   
   use namespace w2e_internal;
   
   public class WatchToEarnActivity implements IWatchToEarnActivity
   {
      
      w2e_internal static const VERSION:String = "2.2.5-21-g9ffba2e";
      
      private var _networkId:String;
      
      private var _gameId:int;
      
      private var _id:String;
      
      private var _completed:Boolean;
      
      private var _algorithm:String;
      
      private var _payload:String;
      
      private var _signature:String;
      
      private var _loaded:Boolean;
      
      private var _loadStart:Date;
      
      private var _loadEnd:Date;
      
      public function WatchToEarnActivity(param1:String, param2:int, param3:String, param4:Boolean, param5:String, param6:String, param7:String, param8:Boolean, param9:Date, param10:Date)
      {
         super();
         this._networkId = param1;
         this._gameId = param2;
         this._id = param3;
         this._completed = param4;
         this._algorithm = param5;
         this._payload = param6;
         this._signature = param7;
         this._loaded = param8;
         this._loadStart = param9;
         this._loadEnd = param10;
      }
      
      public static function fromJSON(param1:String) : IWatchToEarnActivity
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:* = com.zynga.zap.w2e.json.JSON.decode(param1);
         return new WatchToEarnActivity(_loc2_.networkId,_loc2_.gameId,_loc2_.id,_loc2_.completed,_loc2_.algorithm,_loc2_.payload,_loc2_.signature,_loc2_.loaded,parseISO8601(_loc2_.loadStart),parseISO8601(_loc2_.loadEnd));
      }
      
      private static function parseISO8601(param1:String) : Date
      {
         var _loc3_:Date = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:String = param1;
         _loc2_ = _loc2_.replace(/\-/g,"/");
         _loc2_ = _loc2_.replace("T"," ");
         _loc2_ = _loc2_.replace(/\.\d{3}/,"");
         _loc2_ = _loc2_.replace("Z"," UTC-0000");
         return new Date(Date.parse(_loc2_));
      }
      
      private static function toISO8601(param1:Date) : String
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:Array = [zp(param1.getUTCFullYear(),4),"-",zp(param1.getUTCMonth() + 1,2),"-",zp(param1.getUTCDate(),2),"T",zp(param1.getUTCHours(),2),":",zp(param1.getUTCMinutes(),2),":",zp(param1.getUTCSeconds(),2),".","000","Z"];
         return _loc2_.join("");
      }
      
      private static function zp(param1:uint, param2:uint) : String
      {
         var _loc3_:String = param1.toString();
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      public function get networkId() : String
      {
         return this._networkId;
      }
      
      public function get gameId() : int
      {
         return this._gameId;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get completed() : Boolean
      {
         return this._completed;
      }
      
      public function get algorithm() : String
      {
         return this._algorithm;
      }
      
      public function get payload() : String
      {
         return this._payload;
      }
      
      public function get signature() : String
      {
         return this._signature;
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
      }
      
      public function get loadStart() : Date
      {
         return this._loadStart;
      }
      
      public function get loadEnd() : Date
      {
         return this._loadEnd;
      }
      
      public function toString() : String
      {
         var _loc1_:Array = ["[WatchToEarnActivity ","networkId: ",this.networkId,", ","gameId: ",this.gameId,", ","id: ",this.id,", ","completed: ",this.completed,", ","algorithm: ",this.algorithm || "null",", ","payload: ",this.payload || "null",", ","signature: ",this.signature || "null",", ","loaded: ",this.loaded,", ","loadStart: ",this.loadStart || "null",", ","loadEnd: ",this.loadEnd || "null","]"];
         return _loc1_.join("");
      }
      
      public function get valid() : Boolean
      {
         if(this.loaded)
         {
            if(!this.loadStart || !this.loadEnd)
            {
               return false;
            }
            if(this.loadStart.getTime() > this.loadEnd.getTime())
            {
               return false;
            }
         }
         return true;
      }
      
      public function toJSON() : String
      {
         var _loc1_:Object = {};
         _loc1_.networkId = this.networkId;
         _loc1_.gameId = this.gameId;
         _loc1_.id = this.id;
         _loc1_.completed = this.completed;
         _loc1_.algorithm = this.algorithm;
         _loc1_.payload = this.payload;
         _loc1_.signature = this.signature;
         _loc1_.loaded = this.loaded;
         _loc1_.loadStart = toISO8601(this.loadStart);
         _loc1_.loadEnd = toISO8601(this.loadEnd);
         return com.zynga.zap.w2e.json.JSON.encode(_loc1_);
      }
   }
}

