package core.managers.worldUnitManager
{
   import Engine.Utilities;
   import core.ZGlobal;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.WorldUnitComponent;
   import core.gamemode.battle.BattleDispatcher;
   import flash.utils.Dictionary;
   import zlabs.events.WorldEvent;
   
   public class WorldUnitManager
   {
      
      public static var instance:WorldUnitManager = new WorldUnitManager();
      
      public static const UNIT_AVAILABLE:uint = 0;
      
      public static const UNIT_IN_FLEET:uint = 1;
      
      public static const UNIT_IN_MARKET:uint = 2;
      
      public static const UNIT_UNCLAIMED:uint = 3;
      
      private var m_localUnits:Dictionary;
      
      private var m_homeWorldUnits:Dictionary;
      
      public function WorldUnitManager()
      {
         super();
      }
      
      public function init() : void
      {
         if(ZGlobal.isHome() && this.m_homeWorldUnits)
         {
            this.m_homeWorldUnits = null;
         }
         this.m_localUnits = new Dictionary();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
      }
      
      public function preInit() : void
      {
         if(this.m_localUnits && !this.m_homeWorldUnits && !ZGlobal.isHome())
         {
            this.m_homeWorldUnits = Utilities.clone(this.m_localUnits) as Dictionary;
         }
      }
      
      public function get availableUnits() : Dictionary
      {
         var _loc3_:* = null;
         var _loc4_:Object = null;
         var _loc1_:Dictionary = this.allUnits;
         var _loc2_:Dictionary = new Dictionary();
         for(_loc3_ in _loc1_)
         {
            trace("Raise the empires inner trace WorldUnitManager.availableUnits allunit: " + _loc3_);
            _loc2_[_loc3_] = 0;
            for each(_loc4_ in _loc1_[_loc3_])
            {
               if(!_loc4_.active)
               {
                  ++_loc2_[_loc3_];
                  trace("Raise the empires inner trace WorldUnitManager.availableUnits available inactive: " + _loc3_ + " l:" + _loc2_[_loc3_]);
               }
               else
               {
                  trace("Raise the empires inner trace WorldUnitManager.availableUnits was unavailable active: " + _loc3_ + "");
               }
            }
         }
         trace("Raise the empires inner trace WorldUnitManager.availableUnits: done ");
         return _loc2_;
      }
      
      public function getUnavailableUnits(param1:uint) : Dictionary
      {
         var _loc4_:* = null;
         var _loc5_:Object = null;
         var _loc2_:Dictionary = this.allUnits;
         var _loc3_:Dictionary = new Dictionary();
         for(_loc4_ in _loc2_)
         {
            _loc3_[_loc4_] = 0;
            for each(_loc5_ in _loc2_[_loc4_])
            {
               if(_loc5_.active && _loc5_.component.type == param1)
               {
                  ++_loc3_[_loc4_];
               }
            }
         }
         return _loc3_;
      }
      
      public function get allUnits() : Dictionary
      {
         return this.m_homeWorldUnits ? this.m_homeWorldUnits : this.m_localUnits;
      }
      
      public function registerUnit(param1:String, param2:WorldUnitComponent) : void
      {
         if(null == this.m_localUnits[param1])
         {
            this.m_localUnits[param1] = new Array();
         }
         this.m_localUnits[param1].push({
            "component":param2,
            "active":false
         });
         trace("Raise the empires inner trace WorldUnitManager.registerUnit: " + param1);
      }
      
      public function unRegisterUnit(param1:String, param2:WorldUnitComponent) : void
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_localUnits[param1])
         {
            if(_loc4_.component == param2)
            {
               this.m_localUnits[param1].splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
      
      public function numUnits(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Dictionary = this.allUnits;
         if(null != _loc3_[param1])
         {
            _loc2_ = int(_loc3_[param1].length);
         }
         return _loc2_;
      }
      
      public function holdUnitByComponent(param1:WorldUnitComponent, param2:String, param3:uint) : Boolean
      {
         var _loc5_:Object = null;
         var _loc4_:Dictionary = this.allUnits;
         for each(_loc5_ in _loc4_[param2])
         {
            if(!_loc5_.active && _loc5_.component == param1)
            {
               _loc5_.active = true;
               _loc5_.component.type = param3;
               if(ZGlobal.isHome() && param3 != WorldUnitManager.UNIT_UNCLAIMED)
               {
                  _loc5_.component.owner.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_GHOST_ON));
               }
               return true;
            }
         }
         return false;
      }
      
      public function holdUnit(param1:String, param2:uint) : Boolean
      {
         var _loc4_:Object = null;
         var _loc3_:Dictionary = this.allUnits;
         for each(_loc4_ in _loc3_[param1])
         {
            if(!_loc4_.active)
            {
               _loc4_.active = true;
               _loc4_.component.type = param2;
               if(ZGlobal.isHome() && param2 != WorldUnitManager.UNIT_UNCLAIMED)
               {
                  _loc4_.component.owner.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_GHOST_ON));
               }
               return true;
            }
         }
         return false;
      }
      
      public function releaseUnitByComponent(param1:WorldUnitComponent, param2:String) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Dictionary = this.allUnits;
         for each(_loc4_ in _loc3_[param2])
         {
            if(_loc4_.active && _loc4_.component == param1)
            {
               _loc4_.active = false;
               _loc4_.component.type = WorldUnitManager.UNIT_AVAILABLE;
               if(ZGlobal.isHome())
               {
                  _loc4_.component.owner.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_GHOST_OFF));
               }
               return;
            }
         }
      }
      
      public function releaseUnit(param1:String, param2:uint) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Dictionary = this.allUnits;
         for each(_loc4_ in _loc3_[param1])
         {
            if(_loc4_.active && _loc4_.component.type == param2)
            {
               _loc4_.active = false;
               _loc4_.component.type = WorldUnitManager.UNIT_AVAILABLE;
               if(ZGlobal.isHome())
               {
                  _loc4_.component.owner.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_GHOST_OFF));
               }
               return;
            }
         }
      }
      
      public function destroyUnit(param1:String, param2:int) : void
      {
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         if(ZGlobal.isHome())
         {
            _loc3_ = this.allUnits;
            for each(_loc4_ in _loc3_[param1])
            {
               if(_loc4_.active && _loc4_.component.type == param2)
               {
                  _loc4_.component.owner.destroy();
                  break;
               }
            }
         }
      }
      
      private function onUnitKilled(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         if(!param1.eventData.enemy)
         {
            _loc2_ = param1.eventData.target.unitItem.code;
            this.destroyUnit(_loc2_,UNIT_IN_FLEET);
         }
      }
   }
}

