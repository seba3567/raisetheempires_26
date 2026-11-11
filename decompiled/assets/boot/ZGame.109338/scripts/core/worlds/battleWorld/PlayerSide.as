package core.worlds.battleWorld
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.UnitItem;
   import core.worlds.battleWorld.megaUnit.PlayerMegaUnit;
   import flash.display.Sprite;
   import flash.geom.Point;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class PlayerSide extends BattleSide
   {
      
      private var m_owner:IEntity = null;
      
      private var m_dc:Class = null;
      
      private var m_revivesLeft:int = 0;
      
      public function PlayerSide(param1:IEntity)
      {
         super();
         this.m_owner = param1;
         m_direction = PLAYER;
         this.m_owner.eventDispatcher.addEventListener(BattleWorld.REGISTER_PLAYER_UNIT,onUnitRegistered);
      }
      
      override public function init(param1:Sprite) : void
      {
         super.init(param1);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,onUnitHighlighted);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.REVIVE_UNITS,this.onReviveUnit);
      }
      
      override public function dispose(param1:Sprite) : void
      {
         super.dispose(param1);
         this.m_owner.eventDispatcher.removeEventListener(BattleWorld.REGISTER_PLAYER_UNIT,onUnitRegistered);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,onUnitHighlighted);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.REVIVE_UNITS,this.onReviveUnit);
      }
      
      override protected function createBattleUnit(param1:int, param2:BattleObject) : BattleUnit
      {
         if(param2.unitItem.secondaryAbility)
         {
            return new PlayerSupportUnit(param1,param2);
         }
         if(param2.unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            return new PlayerMegaUnit(param1,param2);
         }
         return new PlayerUnit(param1,param2);
      }
      
      protected function onReviveUnit(param1:WorldEvent) : void
      {
         var _loc5_:int = 0;
         var _loc7_:Point = null;
         var _loc8_:Object = null;
         var _loc2_:BattleObject = param1.eventData as BattleObject;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            this.m_revivesLeft = _loc2_.fleet.units.length;
            BattleDispatcher.instance.addEventListener(BattleDispatcher.READD_REREGISTERED_TITAN_PARTS,this.onReviveTitanUnit);
            for each(_loc8_ in super.units)
            {
               this.m_dc = _loc8_.battleUnit.damageClass;
               _loc8_.battleUnit.dispose(super.middleEarth);
            }
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.REREGISTER_TITAN_PARTS,_loc2_.fleet));
            return;
         }
         var _loc3_:int = _loc2_.fleet.units.indexOf(_loc2_.unit);
         var _loc4_:Array = super.units;
         var _loc6_:int = _loc4_.length + 1;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            _loc7_ = getPosition(_loc5_,_loc6_,_loc2_.unitItem);
            _loc4_[_loc5_].battleUnit.slideTo = _loc7_;
            _loc5_++;
         }
         _loc5_ = _loc3_ + 1;
         while(_loc5_ < _loc6_)
         {
            _loc7_ = getPosition(_loc5_,_loc6_,_loc2_.unitItem);
            _loc4_[_loc5_ - 1].battleUnit.slideTo = _loc7_;
            _loc5_++;
         }
         Zlab.processManager.schedule(2000,this,this.addRevivedUnitUI,_loc2_,_loc3_);
      }
      
      private function addRevivedUnitUI(param1:BattleObject, param2:int) : void
      {
         var _loc6_:Point = null;
         var _loc3_:Array = super.units;
         var _loc4_:Class = _loc3_[0].battleUnit.damageClass;
         var _loc5_:int = _loc3_.length + 1;
         _loc6_ = getPosition(param2,_loc5_,param1.unitItem);
         var _loc7_:BattleUnit = this.createBattleUnit(m_direction,param1);
         _loc7_.init(super.middleEarth,param1,_loc6_.x,_loc6_.y);
         _loc7_.damageClass = _loc4_;
         _loc7_.addMouseEvents();
         _loc3_.splice(param2,0,{
            "battleObject":param1,
            "battleUnit":_loc7_
         });
         super.units = _loc3_;
      }
      
      private function onReviveTitanUnit(param1:WorldEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         --this.m_revivesLeft;
         if(this.m_revivesLeft <= 0)
         {
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.READD_REREGISTERED_TITAN_PARTS,this.onReviveTitanUnit);
            _loc2_ = super.units;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc2_[_loc3_].battleUnit.damageClass = this.m_dc;
               _loc3_++;
            }
            super.units = _loc2_;
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,{"active":true}));
         }
      }
   }
}

