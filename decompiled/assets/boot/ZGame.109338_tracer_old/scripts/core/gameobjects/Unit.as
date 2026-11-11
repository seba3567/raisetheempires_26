package core.gameobjects
{
   import core.ZGlobal;
   import zlabs.debug.Logger;
   
   public class Unit
   {
      
      private var m_code:String = null;
      
      private var m_strength:Number = 0;
      
      private var m_shields:Number = 0;
      
      private var m_id:int = 0;
      
      private var m_source:int = 0;
      
      private var m_efficiency:uint = 0;
      
      private var m_shieldHit:Number = 0;
      
      public function Unit(param1:Object, param2:int, param3:Fleet)
      {
         var _loc4_:UnitItem = null;
         super();
         var _loc5_:String = this.getData(param1,0);
         this.m_code = _loc5_;
         _loc5_ = this.getData(param1,1);
         if(_loc5_)
         {
            this.m_strength = parseFloat(_loc5_);
         }
         else
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(this.m_code,UnitItem) as UnitItem;
            if(null == _loc4_)
            {
               Logger.error(this,"Unit","No such unit with code " + this.m_code);
            }
            this.m_strength = _loc4_.getStrength(param3);
         }
         _loc5_ = this.getData(param1,2);
         if(_loc5_)
         {
            this.m_shields = parseFloat(_loc5_);
         }
         else
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(this.m_code,UnitItem) as UnitItem;
            if(null == _loc4_)
            {
               Logger.error(this,"Unit","No such unit with code " + this.m_code);
            }
            this.m_shields = _loc4_.getShields(param3);
         }
         _loc5_ = this.getData(param1,3);
         if(_loc5_)
         {
            this.m_id = parseInt(_loc5_);
         }
         else
         {
            this.m_id = param2;
         }
         _loc5_ = this.getData(param1,4);
         if(_loc5_)
         {
            this.m_efficiency = 100 / parseInt(_loc5_);
         }
         else
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(this.m_code,UnitItem) as UnitItem;
            if(null == _loc4_)
            {
               Logger.error(this,"Unit","No such unit with code " + this.m_code);
            }
            this.m_efficiency = _loc4_.unitEfficiency();
         }
      }
      
      public function get code() : String
      {
         return this.m_code;
      }
      
      public function get shields() : Number
      {
         return this.m_shields;
      }
      
      public function set shields(param1:Number) : void
      {
         this.m_shields = param1;
      }
      
      public function get strength() : Number
      {
         return this.m_strength;
      }
      
      public function set strength(param1:Number) : void
      {
         this.m_strength = param1;
      }
      
      public function set source(param1:int) : void
      {
         this.m_source = param1;
      }
      
      public function set shieldHit(param1:Number) : void
      {
         this.m_shieldHit = param1;
      }
      
      public function get shieldHit() : Number
      {
         return this.m_shieldHit;
      }
      
      public function get source() : int
      {
         return this.m_source;
      }
      
      public function get id() : int
      {
         return this.m_id;
      }
      
      public function set id(param1:int) : void
      {
         this.m_id = param1;
      }
      
      public function get efficiency() : uint
      {
         return this.m_efficiency;
      }
      
      public function set efficiency(param1:uint) : void
      {
         this.m_efficiency = param1;
      }
      
      public function get dead() : Boolean
      {
         return this.m_strength <= 0;
      }
      
      private function getData(param1:Object, param2:int) : String
      {
         var _loc3_:Array = String(param1).split(",");
         if(param2 >= 0)
         {
            return _loc3_[param2];
         }
         return null;
      }
      
      public function serialisableObject(param1:Number = -1) : Object
      {
         var _loc2_:Number = this.m_shields;
         if(-1 != param1)
         {
            _loc2_ = param1;
         }
         this.m_efficiency = 0;
         return this.m_code + "," + this.m_strength + "," + _loc2_ + "," + this.m_id + "," + this.m_efficiency;
      }
   }
}

