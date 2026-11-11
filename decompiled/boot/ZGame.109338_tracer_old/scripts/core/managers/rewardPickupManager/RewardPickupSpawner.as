package core.managers.rewardPickupManager
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.dooberManager.DooberManager;
   import zlabs.Zlab;
   import zlabs.utils.MathUtils;
   
   public class RewardPickupSpawner
   {
      
      public static const XP:int = 0;
      
      public static const COINS:int = 1;
      
      public static const RESOURCE:int = 2;
      
      public static const ENERGY:int = 3;
      
      public static const AMMO:int = 7;
      
      public static const OIL:int = 4;
      
      public static const MANA:int = 5;
      
      public static const ITEM:int = 6;
      
      public static const SCRAP:int = 8;
      
      public static const MYSTERY_ITEM:int = 7;
      
      public static const MYSTERY_DOOBER_WAITING_FOR_RESULT:Boolean = false;
      
      private var m_loot:Array = null;
      
      private var m_position:Pt = null;
      
      private var m_flags:int = RewardPickup.FLAG_NONE;
      
      private var m_delay:Number = 250;
      
      private var m_mysteryDooberResult:Object = new Object();
      
      public function RewardPickupSpawner(param1:Pt)
      {
         super();
         this.m_loot = new Array();
         this.m_position = param1;
      }
      
      public function set delay(param1:Number) : void
      {
         this.m_delay = param1;
      }
      
      public function addLoot(param1:Object) : void
      {
         this.m_loot.push(param1);
      }
      
      public function go(param1:int) : void
      {
         if(this.m_loot.length > 0)
         {
            this.m_flags = param1;
            RewardPickupManager.instance.startLootCreation();
            this.onSchedule();
         }
      }
      
      private function onSchedule() : void
      {
         var _loc1_:int = int(this.m_loot.length);
         var _loc2_:int = MathUtils.randBetween(0,_loc1_ - 1);
         var _loc3_:Object = this.m_loot[_loc2_];
         this.m_loot.splice(_loc2_,1);
         this.doLoot(_loc3_);
         if(_loc1_ > 1)
         {
            Zlab.processManager.schedule(this.m_delay,this,this.onSchedule);
         }
         else
         {
            this.dispose();
         }
      }
      
      public function setMysteryDooberResult(param1:Array, param2:String) : void
      {
         this.m_mysteryDooberResult[param2] = param1;
      }
      
      public function setMysteryDooberStatus(param1:Boolean, param2:String) : void
      {
         this.m_mysteryDooberResult[param2] = param1;
      }
      
      private function doLoot(param1:Object) : void
      {
         var _loc2_:GameItem = null;
         switch(param1.type)
         {
            case XP:
               RewardPickupManager.instance.add2DXpReward(this.m_position,param1.amount,this.m_flags);
               break;
            case COINS:
               RewardPickupManager.instance.add2DResourceReward(this.m_position,"coins",param1.amount,this.m_flags);
               break;
            case RESOURCE:
               RewardPickupManager.instance.add2DResourceReward(this.m_position,param1.rareType,param1.amount,this.m_flags);
               break;
            case ENERGY:
               RewardPickupManager.instance.add2DEnergyReward(this.m_position,param1.amount,this.m_flags);
               break;
            case AMMO:
               RewardPickupManager.instance.add2DAmmoReward(this.m_position,param1.amount,this.m_flags);
               break;
            case OIL:
               RewardPickupManager.instance.add2DResourceReward(this.m_position,"oil",param1.amount,this.m_flags);
               break;
            case MANA:
               RewardPickupManager.instance.add2DManaReward(this.m_position,param1.amount,this.m_flags);
               break;
            case SCRAP:
               RewardPickupManager.instance.add2DScrapReward(this.m_position,param1.amount,this.m_flags);
               break;
            case ITEM:
               _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.item,GameItem) as GameItem;
               if(_loc2_.type == "lootable")
               {
                  RewardPickupManager.instance.add2DMysteryItemReward(this.m_position,_loc2_,this.m_flags,DooberManager.instance.mysteryDooberResult);
               }
               else
               {
                  RewardPickupManager.instance.add2DItemReward(this.m_position,_loc2_,this.m_flags);
               }
         }
      }
      
      private function dispose() : void
      {
         this.m_loot = null;
         this.m_position = null;
      }
   }
}

