package core.gamemode.battle.consumable
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import core.managers.FXManager.FXManager;
   import core.managers.animationManager.FireAndForgetAnimation;
   import core.managers.weaponManager.WeaponManager;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleUnit;
   import core.worlds.battleWorld.BattleWorld;
   import flash.geom.Point;
   import sound.SoundEvent;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class ApplyWeaponToFleet implements IConsumableEffect
   {
      
      private var m_consumable:ConsumableItem = null;
      
      private var m_attackingUnit:BattleObject = null;
      
      private var m_ally:Boolean = false;
      
      private var m_playerTurn:Boolean = false;
      
      public function ApplyWeaponToFleet(param1:ConsumableItem, param2:BattleObject, param3:Boolean)
      {
         super();
         this.m_consumable = param1;
         this.m_attackingUnit = param2;
         this.m_ally = param3;
      }
      
      public function init(param1:Boolean) : void
      {
         this.m_playerTurn = param1;
      }
      
      public function update() : Boolean
      {
         return false;
      }
      
      public function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.m_consumable = null;
      }
      
      protected function get ally() : Boolean
      {
         return this.m_ally;
      }
      
      protected function onUnitSelected(param1:WorldEvent) : void
      {
         this.unitSelected(param1.eventData as BattleObject);
      }
      
      protected function unitSelected(param1:BattleObject) : Boolean
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_POWER_USED,{"consumableItem":this.m_consumable}));
         if(this.m_consumable.secondary)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_FIRE,{
               "attacker":this.m_attackingUnit,
               "target":param1,
               "subType":"sa"
            }));
         }
         if(param1.fleet.addConsumable(this.m_consumable.code,param1.unit.id,this.ally,this.m_playerTurn,param1))
         {
            this.doWeapon(param1);
            return true;
         }
         return false;
      }
      
      private function doWeapon(param1:BattleObject) : void
      {
         param1.fleet.startConsumables();
         param1.fleet.triggerDIConsumables(param1.group,this.m_attackingUnit,param1.unit.id,this.m_consumable);
         if(!this.m_consumable.secondary || this.m_consumable.singleHit)
         {
            this.doFiringFX(param1);
         }
         var _loc2_:Number = this.m_consumable.postWait * 1000;
         if(_loc2_ > 0)
         {
            Zlab.processManager.schedule(_loc2_,this,this.onContinue);
         }
         else
         {
            this.onContinue();
         }
      }
      
      private function getFX(param1:Object, param2:BattleObject) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = param1.id;
         if(this.m_consumable.appendWeaponDirection)
         {
            _loc4_ += this.m_playerTurn ? "NE" : "SW";
         }
         if(this.m_consumable.singleHit)
         {
            _loc3_ = WeaponManager.instance.getHitFX(_loc4_,null);
         }
         else
         {
            _loc3_ = WeaponManager.instance.getFiringFX(_loc4_);
         }
         return _loc3_;
      }
      
      private function doFiringFX(param1:BattleObject) : void
      {
         var _loc4_:Object = null;
         var _loc5_:BattleRendererComponent = null;
         var _loc6_:BattleUnit = null;
         var _loc7_:Point = null;
         var _loc2_:Object = {
            "id":this.m_consumable.diWeapon,
            "delay":0
         };
         var _loc3_:String = this.getFX(_loc2_,param1);
         if(null != _loc3_)
         {
            _loc4_ = new Object();
            _loc4_.anim = FXManager.instance.getFXAnim(_loc3_);
            _loc4_.sound = FXManager.instance.getFXSound(_loc3_);
            if(null != _loc4_.anim && _loc4_.anim.length > 0)
            {
               _loc4_.color = this.m_consumable.color;
               _loc5_ = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
               _loc6_ = _loc5_.getBattleUnit(param1);
               if(this.m_consumable.affectsAll)
               {
                  _loc4_.anchor = _loc5_.getSidePosition(_loc6_.side);
               }
               else
               {
                  _loc7_ = new Point(_loc6_.x + _loc6_.artWidth * 0.5,_loc6_.y + _loc6_.artHeight * 0.5);
                  _loc4_.anchor = _loc7_;
               }
               FireAndForgetAnimation.execute2D(_loc5_.getSurface(_loc6_.side),_loc4_);
            }
            else if(null != _loc4_.sound)
            {
               SoundEvent.getSoundEvent(_loc4_.sound).play();
            }
         }
      }
      
      private function onContinue() : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONTINUE_FROM_CONSUMABLE,this.m_consumable));
      }
   }
}

