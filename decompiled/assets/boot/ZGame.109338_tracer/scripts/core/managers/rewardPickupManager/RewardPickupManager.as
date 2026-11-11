package core.managers.rewardPickupManager
{
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.resource.ResourceInfo;
   import core.resource.WorldResource;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ResourceDispatcher;
   import events.ResourceRewardEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import sound.SoundEvent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class RewardPickupManager
   {
      
      public static var instance:RewardPickupManager = new RewardPickupManager();
      
      private var m_isoView:IsoView = null;
      
      private var m_isoScene:IsoScene = null;
      
      private var m_activePickups:Dictionary = null;
      
      private var m_displayObjects:Dictionary = null;
      
      private var m_2DFloatingTextSizeMultiplier:Number = 1.5;
      
      private var m_3DFloatingTextSizeMultiplier:Number = 1.5;
      
      private var m_pulseGlow:Boolean = false;
      
      private var m_lootCreationScope:Boolean = false;
      
      public function RewardPickupManager()
      {
         super();
         this.m_2DFloatingTextSizeMultiplier = ZGlobal.gameSettings.getNumber("loot2DFloatingTextSizeMultiplier",1.5);
         this.m_3DFloatingTextSizeMultiplier = ZGlobal.gameSettings.getNumber("loot3DFloatingTextSizeMultiplier",1.5);
      }
      
      public function get activePickups() : Dictionary
      {
         return this.m_activePickups;
      }
      
      public function get floatingTextSizeMultiplier2D() : Number
      {
         return this.m_2DFloatingTextSizeMultiplier;
      }
      
      public function get floatingTextSizeMultiplier3D() : Number
      {
         return this.m_3DFloatingTextSizeMultiplier;
      }
      
      public function get anyActivePickups() : Boolean
      {
         var _loc1_:Array = null;
         for each(_loc1_ in this.m_activePickups)
         {
            if(_loc1_.length > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function set pulseGlow(param1:Boolean) : void
      {
         this.m_pulseGlow = param1;
      }
      
      public function init(param1:IsoView, param2:IsoScene) : void
      {
         var _loc3_:ResourceInfo = null;
         this.m_isoView = param1;
         this.m_isoScene = param2;
         this.m_activePickups = new Dictionary();
         this.m_activePickups["xp"] = new Array();
         this.m_activePickups["socialXpGood"] = new Array();
         this.m_activePickups["socialXpBad"] = new Array();
         this.m_activePickups["energy"] = new Array();
         this.m_activePickups["ammo"] = new Array();
         this.m_activePickups["mana"] = new Array();
         this.m_activePickups["item"] = new Array();
         this.m_activePickups["cash"] = new Array();
         this.m_activePickups["scrap"] = new Array();
         this.m_activePickups["mysteryitem"] = new Array();
         for each(_loc3_ in WorldResourceManager.instance.resourceInfo)
         {
            this.m_activePickups[_loc3_.type] = new Array();
         }
         this.m_displayObjects = new Dictionary();
      }
      
      public function clear() : void
      {
         var _loc1_:String = null;
         var _loc2_:RewardPickup = null;
         for(_loc1_ in this.m_activePickups)
         {
            for each(_loc2_ in this.m_activePickups[_loc1_])
            {
               _loc2_.removeEventListener(Event.REMOVED,this.onPickupRemoved);
               _loc2_.dispose();
            }
            this.m_activePickups[_loc1_].length = 0;
         }
      }
      
      public function startLootCreation() : void
      {
         SoundEvent.getSoundEvent("LootDrop").play();
      }
      
      public function startLootCreationScope(param1:Boolean) : void
      {
         this.m_lootCreationScope = param1;
      }
      
      public function registerUIElement(param1:MovieClip, param2:Number, param3:String) : void
      {
         this.m_displayObjects[param3] = {
            "displayObject":param1,
            "offset":param2
         };
      }
      
      public function unregisterUIElement(param1:String) : void
      {
         this.m_displayObjects[param1] = null;
      }
      
      public function getUIPosition(param1:String) : Point
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Point = null;
         var _loc4_:DisplayObject = null;
         if(this.m_displayObjects[param1])
         {
            _loc2_ = this.m_displayObjects[param1].displayObject;
            _loc3_ = new Point(_loc2_.x + this.m_displayObjects[param1].offset,_loc2_.y);
            _loc4_ = _loc2_.parent;
            while(_loc4_ != null)
            {
               _loc3_.x += _loc4_.x;
               _loc3_.y += _loc4_.y;
               _loc4_ = _loc4_.parent;
            }
            return _loc3_;
         }
         return new Point(0,0);
      }
      
      private function getRandomDistribution(param1:int, param2:int) : Array
      {
         var _loc3_:Array = new Array();
         var _loc4_:int = param1;
         _loc3_.push(_loc4_);
         return _loc3_;
      }
      
      public function addXpReward(param1:IEntity, param2:int) : void
      {
         var _loc3_:Array = this.getRandomDistribution(param2,3);
         for each(param2 in _loc3_)
         {
            this.initReward(new XpRewardPickup(param2,this.m_pulseGlow),"xp",param1);
         }
      }
      
      public function addEnergyRewardAtGridPos(param1:Pt, param2:int, param3:int = 0) : void
      {
         if(ZGlobal.player.m_energy.canAcceptEnergy(param2))
         {
            this.initRewardAtGridPos(new EnergyRewardPickup(param2,this.m_pulseGlow),"energy",param1);
         }
      }
      
      public function addSocialXpGoodReward(param1:IEntity, param2:int) : void
      {
         var _loc3_:Array = this.getRandomDistribution(param2,3);
         for each(param2 in _loc3_)
         {
            this.initReward(new SocialXpGoodRewardPickup(param2,this.m_pulseGlow),"socialXpGood",param1);
         }
      }
      
      public function addSocialXpBadReward(param1:IEntity, param2:int) : void
      {
         var _loc3_:Array = this.getRandomDistribution(param2,3);
         for each(param2 in _loc3_)
         {
            this.initReward(new SocialXpBadRewardPickup(param2,this.m_pulseGlow),"socialXpBad",param1);
         }
      }
      
      public function addItemReward(param1:IEntity, param2:GameItem) : void
      {
         this.initReward(new ItemRewardPickup(param2),"item",param1);
      }
      
      public function addCashReward(param1:IEntity, param2:int) : void
      {
         this.initReward(new CashRewardPickup(param2),"cash",param1);
      }
      
      public function add2DXpReward(param1:Pt, param2:int, param3:int) : void
      {
         this.init2DReward(new XpRewardPickup(param2,this.m_pulseGlow),"xp",param1,param3);
      }
      
      public function add2DEnergyReward(param1:Pt, param2:int, param3:int = 0) : void
      {
         if(ZGlobal.player.m_energy.canAcceptEnergy(param2))
         {
            this.init2DReward(new EnergyRewardPickup(param2,this.m_pulseGlow),"energy",param1,param3);
         }
      }
      
      public function add2DAmmoReward(param1:Pt, param2:int, param3:int) : void
      {
         if(ZGlobal.player.m_ammo.canAcceptAmmo(param2))
         {
            this.init2DReward(new AmmoRewardPickup(param2,this.m_pulseGlow),"ammo",param1,param3);
         }
      }
      
      public function add2DScrapReward(param1:Pt, param2:int, param3:int) : void
      {
         this.init2DReward(new ScrapRewardPickup(param2,this.m_pulseGlow),"scrap",param1,param3);
      }
      
      public function add2DManaReward(param1:Pt, param2:int, param3:int) : void
      {
         if(ZGlobal.player.mana.allowGive(param2))
         {
            this.init2DReward(new ManaRewardPickup(param2,this.m_pulseGlow),"mana",param1,param3);
         }
      }
      
      public function add2DItemReward(param1:Pt, param2:GameItem, param3:int) : void
      {
         this.init2DReward(new ItemRewardPickup(param2),"item",param1,param3);
      }
      
      public function add2DMysteryItemReward(param1:Pt, param2:GameItem, param3:int, param4:Object) : void
      {
         this.init2DReward(new MysteryItemRewardPickup(param2,param4),"mysteryitem",param1,param3);
      }
      
      public function addResourceReward(param1:IEntity, param2:String, param3:int) : void
      {
         param2 = this.getResourceName(param2);
         var _loc4_:Array = this.getRandomDistribution(param3,3);
         for each(param3 in _loc4_)
         {
            this.initReward(new ResourceRewardPickup(param2,param3,this.m_pulseGlow),param2,param1);
         }
         this.addResource(param2);
      }
      
      public function addRec98sourceReward(param1:IEntity, param2:String, param3:int) : void
      {
         param2 = this.getResourceName(param2);
         var _loc4_:Array = this.getRandomDistribution(param3,3);
         for each(param3 in _loc4_)
         {
            this.initReward(new ResourceRewardPickup(param2,param3,this.m_pulseGlow),param2,param1);
         }
         this.addResource(param2);
      }
      
      public function add2DResourceReward(param1:Pt, param2:String, param3:int, param4:int) : void
      {
         param2 = this.getResourceName(param2);
         this.init2DReward(new ResourceRewardPickup(param2,param3,this.m_pulseGlow),param2,param1,param4);
         this.addResource(param2);
      }
      
      private function getResourceName(param1:String) : String
      {
         var _loc2_:WorldResource = WorldResourceManager.instance.createResource(param1,1);
         return _loc2_.type;
      }
      
      private function addResource(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc2_:ResourceInfo = WorldResourceManager.instance.getResourceInfoByType(param1);
         var _loc3_:String = _loc2_.isRare ? "rare" : param1;
         if(PlayerStatsUIItem.SLIDING_RESOURCE_NAMES.indexOf(_loc3_) >= 0)
         {
            _loc4_ = _loc3_ + "Reward";
            ResourceDispatcher.instance.dispatchEvent(new ResourceRewardEvent(_loc4_));
         }
      }
      
      private function init2DReward(param1:RewardPickup, param2:String, param3:Pt, param4:int) : void
      {
         param1.init2D(param3,param4);
         this.initStandardReward(param1,param2);
      }
      
      private function initReward(param1:RewardPickup, param2:String, param3:IEntity) : void
      {
         param1.init3D(this.m_isoView,this.m_isoScene,param3);
         this.initStandardReward(param1,param2);
      }
      
      private function initRewardAtGridPos(param1:RewardPickup, param2:String, param3:Pt) : void
      {
         param1.initRewardAtGridPos(param3,this.m_isoView,this.m_isoScene);
         this.initStandardReward(param1,param2);
      }
      
      private function initStandardReward(param1:RewardPickup, param2:String) : void
      {
         if(this.m_lootCreationScope)
         {
            this.startLootCreation();
            this.m_lootCreationScope = false;
         }
         param1.addEventListener(Event.REMOVED,this.onPickupRemoved,false,0,true);
         this.m_activePickups[param2].push(param1);
      }
      
      private function onPickupRemoved(param1:WorldEvent) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:RewardPickup = null;
         var _loc2_:RewardPickup = RewardPickup(param1.eventData);
         _loc2_.removeEventListener(Event.REMOVED,this.onPickupRemoved);
         var _loc3_:int = int(this.m_activePickups[_loc2_.type].indexOf(_loc2_));
         if(_loc3_ >= 0)
         {
            this.m_activePickups[_loc2_.type].splice(_loc3_,1);
            _loc5_ = false;
            for(_loc6_ in this.m_activePickups)
            {
               var _loc10_:int = 0;
               var _loc11_:* = this.m_activePickups[_loc6_];
               for each(_loc7_ in _loc11_)
               {
                  _loc5_ = true;
               }
            }
            if(!_loc5_)
            {
               TutorialManager.instance.dispatchEvent(new Event(TutorialManager.REWARDPICKUP_CONTINUE));
            }
         }
         var _loc4_:String = _loc2_.pickupName + "Pickup";
         ResourceDispatcher.instance.dispatchEvent(new ResourceRewardEvent(_loc4_));
      }
   }
}

