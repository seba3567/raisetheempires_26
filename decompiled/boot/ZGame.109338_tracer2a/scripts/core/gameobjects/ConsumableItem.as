package core.gameobjects
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Player;
   import core.ui.FloatingImage;
   import transactions.TAssignConsumable;
   import utils.ZGameRandom;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.utils.MathUtils;
   
   public class ConsumableItem extends PartsPowerupItem
   {
      
      public static const MERC_CONSUMABLE_ITEM_CODE:String = "A0A";
      
      public static const DOUBLE_SHOT_ITEM_CODE:String = "N74";
      
      public static const HEAL_ALL_ITEM_CODE:String = "N83";
      
      public function ConsumableItem(param1:XML)
      {
         super(param1);
      }
      
      public static function getRandomConsumableForMercenary(param1:String, param2:String, param3:String) : ConsumableItem
      {
         var _loc4_:MercenaryItem = ZGlobal.gameSettings.getItemByCode(param1,MercenaryItem) as MercenaryItem;
         return getRandomConsumableForLevel(_loc4_.level,param1,param2,param3);
      }
      
      public static function getRandomConsumableForPlayer(param1:String, param2:String, param3:String) : ConsumableItem
      {
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         if(param1 == Player.FAKE_PLAYER_ID)
         {
            _loc4_ = ZGlobal.player.level + 5;
         }
         else
         {
            _loc5_ = ZGlobal.player.neighbors[param1];
            if(_loc5_ == null)
            {
               if(AlliancesManager.isPhase4Enabled() && Boolean(AlliancesManager.instance.isAllianceMember(param1)))
               {
                  _loc5_ = AlliancesManager.instance.memberInfo(param1);
               }
            }
            if(_loc5_)
            {
               _loc4_ = int(_loc5_.level);
            }
         }
         return getRandomConsumableForLevel(_loc4_,param1,param2,param3);
      }
      
      private static function getRandomConsumableForLevel(param1:int, param2:String, param3:String, param4:String) : ConsumableItem
      {
         var _loc8_:Boolean = false;
         var _loc9_:Array = null;
         var _loc10_:XML = null;
         var _loc11_:ConsumableItem = null;
         var _loc12_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Array = new Array();
         var _loc7_:ConsumableItem = TutorialManager.instance.getAllyConsumableOverride();
         if(_loc7_)
         {
            _loc6_.push(_loc7_);
         }
         else
         {
            _loc8_ = Fleet.getFleet(param4).damaged;
            _loc9_ = ZGlobal.gameSettings.getArrayOfItemXMLByType(GameItem.TYPE_CONSUMABLE,GameItem.TYPE_CONSUMABLE);
            for each(_loc10_ in _loc9_)
            {
               _loc11_ = ZGlobal.gameSettings.getItemByCode(_loc10_.@code,ConsumableItem) as ConsumableItem;
               if(_loc11_.validFor(param1,_loc8_))
               {
                  _loc6_.push(_loc11_);
               }
            }
         }
         if(_loc6_.length > 0)
         {
            _loc12_ = ZGameRandom.instance.randBetween(0,_loc6_.length - 1);
            _loc5_ = int(Math.round(_loc12_));
            Logger.info(null,"getRandomConsumableForLevel","randomNumber " + _loc12_ + " index " + _loc5_);
            Logger.info(null,"getRandomConsumableForLevel","numValidConsumables " + _loc6_.length + " choosing (" + _loc6_[_loc5_].code + ") from list");
            TransactionManager.addTransaction(new TAssignConsumable(param2,MERC_CONSUMABLE_ITEM_CODE,_loc5_,param1,param3),true);
            return _loc6_[_loc5_];
         }
         return null;
      }
      
      public function isBattleConsumable() : Boolean
      {
         if(type == GameItem.TYPE_CONSUMABLE)
         {
            if(m_xml.consumable.length() > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getBattleValue(param1:String, param2:Number = 0) : Number
      {
         var _loc3_:Number = param2;
         var _loc4_:String = m_xml.consumable.attribute(param1);
         if(_loc4_.length > 0)
         {
            return parseFloat(_loc4_);
         }
         return _loc3_;
      }
      
      private function isBattleValue(param1:String, param2:String) : Boolean
      {
         var _loc3_:String = m_xml.consumable.attribute(param1);
         if(_loc3_.length > 0)
         {
            return _loc3_ == param2;
         }
         return false;
      }
      
      public function get stuns() : Boolean
      {
         return this.isBattleValue("disable","stun");
      }
      
      public function get targetsEnemy() : Boolean
      {
         return this.isBattleValue("target","enemy");
      }
      
      public function get affectsAll() : Boolean
      {
         return this.isBattleValue("type","all");
      }
      
      public function get duration() : int
      {
         return this.getBattleValue("duration");
      }
      
      public function get damageBonus() : Number
      {
         return this.getBattleValue("damage");
      }
      
      public function get dot() : Number
      {
         return this.getBattleValue("dot");
      }
      
      public function get di() : Number
      {
         return this.getBattleValue("di");
      }
      
      public function get damageIsPercent() : Boolean
      {
         return m_xml.consumable.@dp != undefined;
      }
      
      public function get str() : Number
      {
         return this.getBattleValue("str");
      }
      
      public function get shieldBonus() : Number
      {
         return this.getBattleValue("shield");
      }
      
      public function get attackBonus() : Number
      {
         return this.getBattleValue("attack");
      }
      
      public function get hasChipDamage() : Boolean
      {
         return this.isBattleValue("type","chip");
      }
      
      public function get chipDamageFactor() : Number
      {
         return this.getBattleValue("chipFactor");
      }
      
      public function get givesShield() : Boolean
      {
         return this.isBattleValue("givesAbility","shield");
      }
      
      public function get givesFlameAbilty() : Boolean
      {
         return this.isBattleValue("givesAbility","flame");
      }
      
      public function get defenseBonus() : Number
      {
         return this.getBattleValue("defend");
      }
      
      public function get strengthBonus() : Number
      {
         return this.getBattleValue("strength");
      }
      
      public function get postWait() : Number
      {
         return this.getBattleValue("postWait");
      }
      
      public function get useTurn() : Boolean
      {
         return m_xml.consumable.@useTurn != "0";
      }
      
      public function useOnItem(param1:IEntity) : void
      {
         var _loc2_:ItemImage = getCachedImage("icon");
         var _loc3_:FloatingImage = new FloatingImage(_loc2_.url,param1);
      }
      
      public function get energy() : int
      {
         return int(this.getBattleValue("energy",1));
      }
      
      public function get mana() : int
      {
         return int(this.getBattleValue("mana",0));
      }
      
      public function get diWeapon() : String
      {
         return m_xml.consumable.attribute("diweapon");
      }
      
      public function get experimentAllowed() : Boolean
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(m_xml.requiredExperiment.@name != undefined)
         {
            if(m_xml.requiredExperiment.@variants != undefined)
            {
               _loc1_ = xml.requiredExperiment.@variants.split(",");
               _loc2_ = ExperimentsManager.instance.getExperimentVariant(xml.requiredExperiment.@name);
               if(_loc1_.indexOf(_loc2_.toString()) == -1)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function get version() : Number
      {
         if(m_xml.@version != undefined)
         {
            return parseInt(m_xml.@version);
         }
         return 0;
      }
      
      public function get dotWeapon() : String
      {
         return m_xml.consumable.attribute("dotweapon");
      }
      
      public function get againstList() : XMLList
      {
         return m_xml.consumable.against;
      }
      
      public function get heals() : Boolean
      {
         return !this.targetsEnemy && this.di < 0;
      }
      
      public function get secondary() : Boolean
      {
         return m_xml.consumable.@secondary != undefined;
      }
      
      public function get singleHit() : Boolean
      {
         return m_xml.consumable.@singleHit != undefined;
      }
      
      public function get castPercent() : Number
      {
         if(this.secondary)
         {
            return m_xml.consumable.@castpercent;
         }
         return 0;
      }
      
      public function get percent() : Number
      {
         if(m_xml.consumable.@percent != undefined)
         {
            return parseFloat(m_xml.consumable.@percent) / 100;
         }
         return 1;
      }
      
      public function get randomHitDelay() : Number
      {
         var _loc1_:Number = NaN;
         if(m_xml.consumable.@randomhitdelay != undefined)
         {
            _loc1_ = Number(m_xml.consumable.@randomhitdelay);
            return MathUtils.randBetween(0,_loc1_);
         }
         return 0;
      }
      
      public function get appendWeaponDirection() : Boolean
      {
         return m_xml.consumable.@appendWeaponDirection != undefined;
      }
      
      public function get color() : Array
      {
         if(m_xml.consumable.@color != undefined)
         {
            return m_xml.consumable.@color.toString().split(",");
         }
         return null;
      }
      
      public function get allyPower() : Boolean
      {
         if(m_xml.consumable.@allypower != undefined)
         {
            return m_xml.consumable.@allypower != "false";
         }
         return true;
      }
      
      private function validFor(param1:int, param2:Boolean) : Boolean
      {
         if(m_xml.consumable.@secondary != undefined)
         {
            return false;
         }
         if(requiredLevel > param1)
         {
            return false;
         }
         if(!param2 && this.heals)
         {
            return false;
         }
         if(Boolean(m_xml.requiredDate) && m_xml.requiredDate != undefined)
         {
            return false;
         }
         if(!this.allyPower)
         {
            return false;
         }
         return true;
      }
      
      public function get tier() : int
      {
         if(m_xml.@tier != undefined)
         {
            return m_xml.@tier;
         }
         return 1;
      }
      
      public function get requiredTierVariants() : Array
      {
         if(m_xml.@tierVariants != undefined)
         {
            return m_xml.@tierVariants.toString().split(",");
         }
         return [];
      }
   }
}

