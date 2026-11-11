package core.worlds.battleWorld
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Sine;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.Fleet;
   import core.gameobjects.UnitItem;
   import core.managers.ChipDamageManager;
   import core.managers.formationManager.FormationManager;
   import core.worlds.battleWorld.megaUnit.MegaUnitSelector;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import rendering.rendering2d.MovieController;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BattleSide
   {
      
      public static const PLAYER:int = 0;
      
      public static const ENEMY:int = 1;
      
      private static const NUM_LAYERS:int = 2;
      
      public static var instance:BattleSide = new BattleSide();
      
      private var m_displayObject:Sprite = null;
      
      private var m_background:Sprite = null;
      
      private var m_foreground:Sprite = null;
      
      private var m_middleEarth:Sprite = null;
      
      private var m_controllers:Array = null;
      
      protected var m_direction:int = 0;
      
      private var m_units:Array = new Array();
      
      private var m_currBackgroundChild:DisplayObject = null;
      
      private var m_currForegroundChild:DisplayObject = null;
      
      private var m_selector:BattleUnitSelector = null;
      
      private var m_numLayers:int = 0;
      
      private var m_fleetType:String = null;
      
      private var m_battleStarted:Boolean = false;
      
      private var m_groupHighlighting:Boolean = false;
      
      private var m_subGroupHighlighting:Boolean = false;
      
      private var m_startPaused:Boolean = false;
      
      public function BattleSide()
      {
         super();
      }
      
      public function set mask(param1:Sprite) : void
      {
         this.m_displayObject.mask = param1;
      }
      
      public function get background() : Sprite
      {
         return this.m_background;
      }
      
      public function get middleEarth() : Sprite
      {
         return this.m_middleEarth;
      }
      
      public function get foreground() : Sprite
      {
         return this.m_foreground;
      }
      
      public function get units() : Array
      {
         return this.m_units;
      }
      
      public function set units(param1:Array) : void
      {
         this.m_units = param1;
      }
      
      public function init(param1:Sprite) : void
      {
         this.m_controllers = new Array();
         this.m_displayObject = new Sprite();
         param1.addChild(this.m_displayObject);
         this.m_background = new Sprite();
         this.m_middleEarth = new Sprite();
         this.m_foreground = new Sprite();
         this.m_foreground.mouseEnabled = false;
         this.m_foreground.mouseChildren = false;
         this.m_displayObject.addChild(this.m_background);
         this.m_displayObject.addChild(this.m_middleEarth);
         this.m_displayObject.addChild(this.m_foreground);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_GROUP_HIGHLIGHT,this.onGroupHighlight);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SUBGROUP_HIGHLIGHT,this.onSubGroupHighlight);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onStartBattle);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_REMOVED,this.onUnitRemoved);
      }
      
      public function setFleet(param1:Fleet, param2:int, param3:Boolean) : void
      {
         this.m_numLayers = 0;
         this.m_fleetType = param1.type;
         this.m_startPaused = param3;
         this.pauseUnits(param3);
      }
      
      public function loadBackgrounds(param1:SWFResource, param2:int) : void
      {
         var _loc3_:Array = new Array();
         _loc3_["army"] = "Land";
         _loc3_["navy"] = "Sea";
         _loc3_["air"] = "Air";
         var _loc4_:Array = ["Bottom","Top"];
         var _loc5_:String = _loc3_[this.m_fleetType] + _loc4_[param2] + "Background";
         var _loc6_:Class = param1.getAssetClass(_loc5_);
         this.addBackgroundClip(new _loc6_());
         _loc5_ = _loc3_[this.m_fleetType] + _loc4_[param2] + "Foreground";
         _loc6_ = param1.getAssetClass(_loc5_);
         this.addForegroundClip(new _loc6_());
      }
      
      private function addBackgroundClip(param1:MovieClip) : void
      {
         if(this.m_fleetType)
         {
            this.clearBackgroundChild();
            this.m_currBackgroundChild = this.handleSWFLoad(param1,this.m_startPaused);
            this.m_background.addChild(this.m_currBackgroundChild);
            ++this.m_numLayers;
            this.tryStart();
         }
      }
      
      private function addForegroundClip(param1:MovieClip) : void
      {
         if(this.m_fleetType)
         {
            this.clearForegroundChild();
            this.m_currForegroundChild = this.handleSWFLoad(param1,this.m_startPaused);
            this.m_foreground.addChildAt(this.m_currForegroundChild,0);
            ++this.m_numLayers;
            this.tryStart();
         }
      }
      
      private function clearBackgroundChild() : void
      {
         if(this.m_currBackgroundChild != null)
         {
            this.m_background.removeChild(this.m_currBackgroundChild);
            this.m_currBackgroundChild = null;
         }
      }
      
      private function clearForegroundChild() : void
      {
         if(this.m_currForegroundChild != null)
         {
            this.m_foreground.removeChild(this.m_currForegroundChild);
            this.m_currForegroundChild = null;
         }
      }
      
      private function handleSWFLoad(param1:MovieClip, param2:Boolean) : MovieClip
      {
         var _loc3_:MovieController = new MovieController(param1);
         this.m_controllers.push(_loc3_);
         _loc3_.paused = param2;
         return param1;
      }
      
      public function dispose(param1:Sprite) : void
      {
         var _loc2_:Object = null;
         var _loc3_:MovieController = null;
         for each(_loc2_ in this.m_units)
         {
            _loc2_.battleUnit.dispose(this.m_middleEarth);
         }
         this.m_units = null;
         for each(_loc3_ in this.m_controllers)
         {
            _loc3_.dispose();
         }
         this.m_controllers = null;
         if(this.m_selector)
         {
            this.m_selector.dispose();
            this.m_selector = null;
         }
         this.clearBackgroundChild();
         this.clearForegroundChild();
         this.m_displayObject.removeChild(this.m_background);
         this.m_displayObject.removeChild(this.m_middleEarth);
         this.m_displayObject.removeChild(this.m_foreground);
         this.m_background = null;
         this.m_middleEarth = null;
         this.m_foreground = null;
         this.m_fleetType = null;
         TweenMax.killTweensOf(this.m_displayObject);
         param1.removeChild(this.m_displayObject);
         this.m_displayObject = null;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_GROUP_HIGHLIGHT,this.onGroupHighlight);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SUBGROUP_HIGHLIGHT,this.onSubGroupHighlight);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onStartBattle);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_REMOVED,this.onUnitRemoved);
      }
      
      public function getBattleUnit(param1:BattleObject) : BattleUnit
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_units)
         {
            if(_loc2_.battleUnit.isBattleObject(param1))
            {
               return _loc2_.battleUnit;
            }
         }
         return null;
      }
      
      protected function onUnitRegistered(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = param1.eventData as BattleObject;
         var _loc3_:Fleet = _loc2_.fleet;
         var _loc4_:Point = this.getPosition(this.m_units.length,_loc3_.units.length,_loc2_.unitItem);
         var _loc5_:BattleUnit = this.createBattleUnit(this.m_direction,_loc2_);
         _loc5_.init(this.m_middleEarth,_loc2_,_loc4_.x,_loc4_.y);
         this.m_units.push({
            "battleObject":param1.eventData,
            "battleUnit":_loc5_
         });
         if(!this.m_selector && _loc2_.unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            this.m_selector = new MegaUnitSelector(this.m_middleEarth);
         }
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.READD_REREGISTERED_TITAN_PARTS,this.m_units.length));
      }
      
      protected function createBattleUnit(param1:int, param2:BattleObject) : BattleUnit
      {
         return null;
      }
      
      protected function getPosition(param1:int, param2:int, param3:UnitItem) : Point
      {
         var _loc4_:String = null;
         if(param3.hasType(UnitItem.MEGA_UNIT))
         {
            _loc4_ = this.m_direction.toString() + "_5_mega";
            param1 = param3.formationIndex;
         }
         else
         {
            _loc4_ = this.m_direction.toString() + "_" + param2.toString();
         }
         return FormationManager.instance.getLocalOffset(_loc4_,param1,1);
      }
      
      private function getIndex(param1:BattleObject) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_units)
         {
            if(_loc3_.battleObject == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getNumberofUnits() : Number
      {
         return this.m_units.length;
      }
      
      public function getUnitIndex(param1:BattleObject) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_units)
         {
            if(_loc3_.battleObject == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function onUnitKilled(param1:WorldEvent) : void
      {
         var _loc2_:int = this.getIndex(param1.eventData.target as BattleObject);
         if(_loc2_ >= 0)
         {
            this.m_units[_loc2_].battleUnit.die(param1.eventData.attacker,param1.eventData.target,param1.eventData.weapon);
         }
      }
      
      private function onUnitRemoved(param1:WorldEvent) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Object = null;
         var _loc6_:Point = null;
         var _loc2_:BattleObject = param1.eventData.battleObject as BattleObject;
         var _loc3_:int = this.getIndex(_loc2_);
         if(_loc3_ >= 0)
         {
            if(Boolean(param1.eventData.shake) && _loc2_.unitItem.subType != UnitItem.AIR)
            {
               this.cameraShake();
            }
            _loc4_ = !_loc2_.unitItem.hasType(UnitItem.MEGA_UNIT);
            this.m_units[_loc3_].battleUnit.dispose(this.m_middleEarth);
            this.m_units.splice(_loc3_,1);
            if(_loc4_)
            {
               _loc3_ = 0;
               for each(_loc5_ in this.m_units)
               {
                  _loc6_ = this.getPosition(_loc3_,this.m_units.length,_loc2_.unitItem);
                  Logger.info(this,"BattleSideReposition BattleUnit",_loc5_.battleUnit.toString());
                  _loc5_.battleUnit.slideTo = _loc6_;
                  _loc3_++;
               }
            }
         }
      }
      
      protected function isAdjacent(param1:BattleObject, param2:BattleObject) : Boolean
      {
         var _loc3_:int = this.getIndex(param1);
         var _loc4_:int = this.getIndex(param2);
         return ChipDamageManager.instance.isAdjacent(_loc3_,_loc4_,this.m_units.length);
      }
      
      protected function onUnitHighlighted(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         if(this.m_groupHighlighting)
         {
            for each(_loc2_ in this.m_units)
            {
               if(_loc2_.battleObject != param1.eventData)
               {
                  _loc2_.battleUnit.highlight = param1.eventData != null;
               }
            }
         }
         else if(this.m_subGroupHighlighting)
         {
            for each(_loc2_ in this.m_units)
            {
               if(this.isAdjacent(_loc2_.battleObject,param1.eventData as BattleObject))
               {
                  _loc2_.battleUnit.highlight = param1.eventData != null;
               }
               else if(_loc2_.battleObject != param1.eventData)
               {
                  _loc2_.battleUnit.highlight = false;
               }
            }
         }
      }
      
      private function onGroupHighlight(param1:WorldEvent) : void
      {
         this.m_groupHighlighting = param1.eventData == true;
      }
      
      private function onSubGroupHighlight(param1:WorldEvent) : void
      {
         this.m_subGroupHighlighting = param1.eventData == true;
      }
      
      private function pauseUnits(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_units)
         {
            _loc2_.battleUnit.paused = param1;
         }
      }
      
      private function onStartBattle(param1:Event) : void
      {
         this.m_battleStarted = true;
         this.tryStart();
      }
      
      private function cameraShake() : void
      {
         this.m_displayObject.x = 0;
         this.m_displayObject.y = 0;
         TweenMax.killTweensOf(this.m_displayObject);
         TweenMax.to(this.m_displayObject,0.1,{
            "x":"2",
            "y":"6",
            "yoyo":true,
            "repeat":8,
            "ease":Sine.easeInOut,
            "ease":Sine.easeOut
         });
      }
      
      private function tryStart() : void
      {
         var _loc1_:MovieController = null;
         if(this.m_battleStarted && this.m_numLayers == NUM_LAYERS)
         {
            for each(_loc1_ in this.m_controllers)
            {
               _loc1_.paused = false;
            }
            this.pauseUnits(false);
         }
      }
   }
}

