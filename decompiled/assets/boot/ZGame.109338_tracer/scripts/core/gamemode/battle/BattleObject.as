package core.gamemode.battle
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.FXManager.FXManager;
   import sound.SoundEvent;
   import zlabs.debug.Logger;
   
   public class BattleObject
   {
      
      private var m_unit:Unit = null;
      
      private var m_fleet:Fleet = null;
      
      private var m_group:Array = null;
      
      private var m_unitItem:UnitItem = null;
      
      public function BattleObject(param1:Unit, param2:Fleet, param3:Array)
      {
         super();
         this.m_unit = param1;
         this.m_fleet = param2;
         this.m_group = param3;
         this.m_unitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
      }
      
      public function dispose() : void
      {
         this.m_unit = null;
         this.m_fleet = null;
         this.m_group = null;
         this.m_unitItem = null;
      }
      
      public function get unit() : Unit
      {
         return this.m_unit;
      }
      
      public function get fleet() : Fleet
      {
         return this.m_fleet;
      }
      
      public function get group() : Array
      {
         return this.m_group;
      }
      
      public function set group(param1:Array) : void
      {
         this.m_group = param1;
      }
      
      public function get unitItem() : UnitItem
      {
         return this.m_unitItem;
      }
      
      public function get dead() : Boolean
      {
         return this.m_unit.dead;
      }
      
      public function get canCounter() : Boolean
      {
         if(!this.m_unit.dead && !this.stunned)
         {
            if(this.m_unitItem.counter)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get stunned() : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:ConsumableItem = null;
         var _loc1_:Array = this.m_fleet.getConsumables(this.m_unit.id);
         if(_loc1_ != null)
         {
            for each(_loc2_ in _loc1_)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,ConsumableItem) as ConsumableItem;
               if(_loc3_.stuns)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function playSelectionSound() : void
      {
         var _loc2_:String = null;
         var _loc1_:String = this.m_unitItem.getFX(UnitItem.FX_SELECTION);
         if(null != _loc1_)
         {
            _loc2_ = FXManager.instance.getFXSound(_loc1_);
            if(null != _loc2_)
            {
               SoundEvent.getSoundEvent(_loc2_).play();
            }
            else
            {
               Logger.error(this,"playSelectionSound","no sound found for FX " + _loc1_);
            }
         }
      }
   }
}

