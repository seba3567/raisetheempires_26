package core.entities.components.utils
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gamemode.mission.GMDeployMission;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.SuperOreManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.dooberManager.DooberManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.resource.WorldResource;
   import core.ui.PlayerFeedbackManager;
   import core.ui.actionfeedback.ActionFeedback;
   import core.ui.actionfeedback.EnergyActionFeedback;
   import core.ui.actionfeedback.ItemActionFeedback;
   import core.ui.actionfeedback.ResourceActionFeedback;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.MissionCompletePopup;
   import events.MarketEvent;
   import flash.utils.Dictionary;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.utils.StringUtils;
   
   public class YieldHelper
   {
      
      public static const REQUIREMENT_SUCCESS:int = 0;
      
      public static const REQUIREMENT_ENERGY:int = 1 << 0;
      
      public static const REQUIREMENT_CASH:int = 1 << 1;
      
      public static const REQUIREMENT_RESOURCES:int = 1 << 2;
      
      private const DISPLACEMENT_STEP:int = 16;
      
      private var m_cashYield:Number;
      
      private var m_energyYield:Number;
      
      private var m_xpYield:Number;
      
      private var m_socialXpGoodYield:Number;
      
      private var m_socialXpBadYield:Number;
      
      private var m_resourceYield:Dictionary;
      
      private var m_populationYield:int;
      
      private var m_buildable:Boolean = false;
      
      private var m_upgrade:Boolean = false;
      
      private var m_powerup:Boolean = false;
      
      private var m_mission:Boolean = false;
      
      private var m_pvpInfuencePropRef:PropertyReference;
      
      private var m_dooberActionType:String = null;
      
      private var m_item:String = null;
      
      private var m_rand:Number = 0;
      
      private var m_xpBuffRand:Number = 0;
      
      private var m_resourceUnlock:Boolean = false;
      
      private var m_energyMaxDeduct:int = 0;
      
      public function YieldHelper()
      {
         super();
         this.m_pvpInfuencePropRef = new PropertyReference("@pillageable.underPVPInfluence");
      }
      
      public function get xpYield() : Number
      {
         return isNaN(this.m_xpYield) ? 0 : Math.max(0,this.m_xpYield);
      }
      
      public function get socialXpGoodYield() : Number
      {
         return isNaN(this.m_socialXpGoodYield) ? 0 : Math.max(0,this.m_socialXpGoodYield);
      }
      
      public function get socialXpBadYield() : Number
      {
         return isNaN(this.m_socialXpBadYield) ? 0 : Math.max(0,this.m_socialXpBadYield);
      }
      
      public function getEnergyYield(param1:IEntity) : Number
      {
         var _loc2_:Number = Number(this.getEnergyRequirement(param1).energy);
         return Math.max(0,_loc2_);
      }
      
      public function getResourceYield(param1:String) : Number
      {
         var _loc2_:Number = NaN;
         if(this.m_resourceYield[param1])
         {
            _loc2_ = Number(this.m_resourceYield[param1].amount);
            if(!isNaN(_loc2_))
            {
               return Math.max(0,_loc2_);
            }
         }
         return 0;
      }
      
      public function saveXPBuffRandom(param1:Number) : void
      {
         this.m_xpBuffRand = param1;
      }
      
      public function saveRandomFloat(param1:Number) : void
      {
         this.m_rand = param1;
      }
      
      public function initFromData(param1:XML, param2:Number = 1) : void
      {
         var _loc3_:WorldResource = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         if(param1..@cash != undefined)
         {
            this.m_cashYield = param2 * parseInt(param1..@cash.toString());
         }
         if(param1..@xp != undefined)
         {
            _loc4_ = param1..@xp.toString();
            _loc5_ = _loc4_.split("|");
            if(ZGlobal.isVisiting() && Boolean(_loc5_[1]))
            {
               this.m_xpYield = param2 * parseInt(_loc5_[1]);
            }
            else
            {
               this.m_xpYield = param2 * parseInt(_loc5_[0]);
            }
         }
         if(param1..@socialXpGood != undefined)
         {
            _loc6_ = param1..@socialXpGood.toString();
            _loc7_ = _loc6_.split("|");
            if(ZGlobal.isVisiting() && Boolean(_loc7_[1]))
            {
               this.m_socialXpGoodYield = param2 * parseInt(_loc7_[1]);
            }
            else
            {
               this.m_socialXpGoodYield = param2 * parseInt(_loc7_[0]);
            }
         }
         if(param1..@socialXpBad != undefined)
         {
            _loc8_ = param1..@socialXpBad.toString();
            _loc9_ = _loc8_.split("|");
            if(ZGlobal.isVisiting() && Boolean(_loc9_[1]))
            {
               this.m_socialXpBadYield = param2 * parseInt(_loc9_[1]);
            }
            else
            {
               this.m_socialXpBadYield = param2 * parseInt(_loc9_[0]);
            }
         }
         if(param1..@energy != undefined)
         {
            _loc10_ = param1..@energy.toString();
            _loc11_ = _loc10_.split("|");
            if(ZGlobal.isVisiting() && Boolean(_loc11_[1]))
            {
               this.m_energyYield = param2 * parseInt(_loc11_[1]);
            }
            else
            {
               this.m_energyYield = param2 * parseInt(_loc11_[0]);
            }
         }
         this.m_buildable = false;
         if(param1..@buildable != undefined && parseInt(param1..@buildable) == 1)
         {
            this.m_buildable = true;
         }
         this.m_upgrade = false;
         if(param1..@upgrade != undefined && parseInt(param1..@upgrade) == 1)
         {
            this.m_upgrade = true;
         }
         this.m_resourceUnlock = false;
         if(param1..@unlockResource != undefined && param1..@unlockResource == "true")
         {
            this.m_resourceUnlock = true;
         }
         this.m_powerup = false;
         if(param1..@powerup != undefined && parseInt(param1..@powerup) == 1)
         {
            this.m_powerup = true;
         }
         this.m_mission = false;
         if(param1..@mission != undefined && parseInt(param1..@mission) == 1)
         {
            this.m_mission = true;
         }
         this.m_resourceYield = WorldResourceManager.instance.findResourceTypesInXML(param1,ZGlobal.hostPlayer.rareResourceType);
         for each(_loc3_ in this.m_resourceYield)
         {
            _loc3_.amount *= param2;
         }
         if(param1..@dooberType != undefined)
         {
            this.m_dooberActionType = param1..@dooberType.toString();
         }
         if(param1..@item != undefined)
         {
            this.m_item = param1..@item;
         }
         if(param1..@energyMaxDeduct != undefined)
         {
            this.m_energyMaxDeduct = parseInt(param1..@energyMaxDeduct);
         }
         if(param1..@elementZ != undefined)
         {
            this.m_item = param1..@elementZ;
         }
      }
      
      public function usesEnergy(param1:IEntity) : Boolean
      {
         var _loc2_:Number = Number(this.getEnergyRequirement(param1).energy);
         return _loc2_ < 0;
      }
      
      public function get numWorkers() : int
      {
         if(this.m_resourceYield)
         {
            if(null != this.m_resourceYield["workers"])
            {
               return this.m_resourceYield["workers"].amount;
            }
         }
         return 0;
      }
      
      public function getResourceValuesText() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = "";
         if(this.m_resourceYield)
         {
            for(_loc2_ in this.m_resourceYield)
            {
               if(Math.abs(this.m_resourceYield[_loc2_].amount) > 0)
               {
                  if(_loc1_.length > 0)
                  {
                     _loc1_ += ", " + Math.abs(this.m_resourceYield[_loc2_].amount) + " " + _loc2_;
                  }
                  else
                  {
                     _loc1_ += Math.abs(this.m_resourceYield[_loc2_].amount) + " " + _loc2_;
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function getLackingRequirementsText(param1:IEntity) : String
      {
         var _loc4_:String = null;
         var _loc2_:String = "";
         var _loc3_:Number = Number(this.getEnergyRequirement(param1).energy);
         if(Boolean(_loc3_) && ZGlobal.player.m_energy.unreservedEnergy + _loc3_ < 0)
         {
            _loc2_ += "energy";
         }
         if(this.m_resourceYield)
         {
            for(_loc4_ in this.m_resourceYield)
            {
               if(!ZGlobal.player.resources.checkResourceAmount(_loc4_,this.m_resourceYield[_loc4_].amount))
               {
                  if(_loc2_.length > 0)
                  {
                     _loc2_ += ", ";
                  }
                  _loc2_ += WorldResourceManager.instance.getResourceFriendlyNameFromType(_loc4_,GameItem.SENTENCE_FRIENDLYNAME,true);
               }
            }
         }
         return _loc2_;
      }
      
      public function getLackingRequirementsTypes(param1:IEntity) : String
      {
         var _loc4_:String = null;
         var _loc2_:String = "";
         var _loc3_:Number = Number(this.getEnergyRequirement(param1).energy);
         if(Boolean(_loc3_) && ZGlobal.player.m_energy.unreservedEnergy + _loc3_ < 0)
         {
            _loc2_ += "energy";
         }
         if(this.m_resourceYield)
         {
            for(_loc4_ in this.m_resourceYield)
            {
               if(!ZGlobal.player.resources.checkResourceAmount(_loc4_,this.m_resourceYield[_loc4_].amount))
               {
                  if(this.m_resourceYield[_loc4_].isRare)
                  {
                     if(_loc2_.length > 0)
                     {
                        _loc2_ = this.m_resourceYield[_loc4_].type + ", " + _loc2_;
                     }
                     else
                     {
                        _loc2_ = this.m_resourceYield[_loc4_].type;
                     }
                  }
                  else
                  {
                     if(_loc2_.length > 0)
                     {
                        _loc2_ += ", ";
                     }
                     _loc2_ += _loc4_;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function isPVPInfluenced(param1:IEntity) : Boolean
      {
         if(param1)
         {
            if(param1.doesPropertyExist(this.m_pvpInfuencePropRef))
            {
               return param1.getProperty(this.m_pvpInfuencePropRef);
            }
         }
         return false;
      }
      
      public function getEnergyRequirement(param1:IEntity) : Object
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = isNaN(this.m_energyYield) ? 0 : this.m_energyYield;
         var _loc3_:int = ZGlobal.player.level;
         if(_loc2_ > 0)
         {
            return {"energy":_loc2_};
         }
         if(this.isPVPInfluenced(param1))
         {
            if(_loc2_)
            {
               _loc4_ = ZGlobal.gameSettings.getNumber("PVPActionPenaltyEnergyMult",2);
               return {
                  "energy":_loc2_ * _loc4_,
                  "pvp":true
               };
            }
         }
         return {"energy":_loc2_};
      }
      
      public function checkRequirements(param1:IEntity) : int
      {
         var _loc4_:String = null;
         var _loc2_:int = REQUIREMENT_SUCCESS;
         if(ZGlobal.isVisiting())
         {
            return _loc2_;
         }
         var _loc3_:Number = Number(this.getEnergyRequirement(param1).energy);
         if(Boolean(_loc3_) && !ZGlobal.player.m_energy.checkEnergy(-_loc3_,true))
         {
            _loc2_ |= REQUIREMENT_ENERGY;
         }
         if(this.m_cashYield < 0 && ZGlobal.player.cash + this.m_cashYield < 0)
         {
            _loc2_ |= REQUIREMENT_CASH;
         }
         if(this.m_resourceYield)
         {
            for(_loc4_ in this.m_resourceYield)
            {
               if(!ZGlobal.player.resources.checkResourceAmount(_loc4_,this.m_resourceYield[_loc4_].amount))
               {
                  _loc2_ |= REQUIREMENT_RESOURCES;
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      private function shouldYield(param1:Boolean, param2:Number) : Boolean
      {
         return !param1 || param2 > 0;
      }
      
      public function executionSubjectToPVPPenalty(param1:IEntity) : Boolean
      {
         if(this.isPVPInfluenced(param1))
         {
            return this.getEnergyRequirement(param1).energy < 0;
         }
         return false;
      }
      
      public function holdReserves() : void
      {
         if(!isNaN(this.m_energyYield) && this.m_energyYield < 0)
         {
            ZGlobal.player.m_energy.reservedEnergy -= this.m_energyYield;
         }
      }
      
      public function releaseReserves() : void
      {
         if(!isNaN(this.m_energyYield) && this.m_energyYield < 0)
         {
            ZGlobal.player.m_energy.reservedEnergy += this.m_energyYield;
         }
      }
      
      private function getEffectiveResourceAmount(param1:String, param2:Object, param3:int) : int
      {
         if(!param2 || !param2.amount || !param2.resources || !(param2.resources as Array))
         {
            return param3;
         }
         if(param2.resources.indexOf(param1) < 0)
         {
            return param3;
         }
         var _loc4_:Number = (100 + param2.amount) / 100;
         return Math.floor(param3 * _loc4_);
      }
      
      public function execute(param1:BehaviorStateMachine, param2:XML, param3:Boolean = false, param4:Boolean = false, param5:IEntity = null, param6:Object = null) : void
      {
         var _loc12_:ActionFeedback = null;
         var _loc13_:GameItem = null;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:ActionFeedback = null;
         var _loc17_:FeedPopup = null;
         var _loc18_:Object = null;
         var _loc19_:ActionFeedback = null;
         var _loc20_:GameItem = null;
         var _loc21_:String = null;
         var _loc22_:String = null;
         var _loc23_:GameItem = null;
         var _loc24_:MissionCompletePopup = null;
         var _loc25_:Array = null;
         var _loc26_:GameItem = null;
         var _loc27_:Object = null;
         var _loc28_:GameItem = null;
         var _loc7_:IEntity = param1 ? param1.propertyBag as IEntity : null;
         if(!_loc7_)
         {
            _loc7_ = param5;
         }
         if(!param4 && this.checkRequirements(_loc7_) != REQUIREMENT_SUCCESS)
         {
            return;
         }
         var _loc8_:* = 0;
         var _loc9_:GameItem = null;
         if(Boolean(param1) && Boolean(param1.referenceItemName))
         {
            _loc9_ = ZGlobal.gameSettings.getItemByName(param1.referenceItemName,GameItem) as GameItem;
         }
         RewardPickupManager.instance.startLootCreationScope(true);
         var _loc10_:Number = Number(this.getEnergyRequirement(_loc7_).energy);
         if(!isNaN(_loc10_) && _loc10_ != 0 && this.shouldYield(param4,_loc10_))
         {
            ZGlobal.player.resources.updateResourceAmount("energy",_loc10_);
            _loc12_ = new EnergyActionFeedback(_loc7_,_loc10_,_loc8_++);
         }
         if(!isNaN(this.m_cashYield) && this.shouldYield(param4,this.m_cashYield))
         {
            ZGlobal.player.cash += this.m_cashYield;
         }
         if(!isNaN(this.m_xpYield))
         {
            if(this.m_xpYield > 0)
            {
               this.m_xpYield = PrisonCampManager.instance.applyXPMultiplier(this.m_xpYield,this.m_xpBuffRand);
               RewardPickupManager.instance.addXpReward(_loc7_,this.m_xpYield);
            }
         }
         if(!isNaN(this.m_socialXpGoodYield))
         {
            if(this.m_socialXpGoodYield > 0)
            {
               RewardPickupManager.instance.addSocialXpGoodReward(_loc7_,this.m_socialXpGoodYield);
            }
         }
         if(!isNaN(this.m_socialXpBadYield))
         {
            if(this.m_socialXpBadYield > 0)
            {
               RewardPickupManager.instance.addSocialXpBadReward(_loc7_,this.m_socialXpBadYield);
            }
         }
         var _loc11_:Number = 0;
         if(!ZGlobal.isVisiting() && MayhemManager.instance.isParliamentDestroyed)
         {
            _loc13_ = param1.propertyBag.getProperty(new PropertyReference("@Data.gameData"),null) as GameItem;
            if(_loc13_.subType == "civic" || _loc13_.subType == "residential")
            {
               _loc11_ = 10;
            }
         }
         if(this.m_resourceYield)
         {
            for(_loc14_ in this.m_resourceYield)
            {
               if(_loc14_ != "energy")
               {
                  if(this.m_resourceYield[_loc14_].amount != 0)
                  {
                     if(this.m_resourceYield[_loc14_].amount > 0)
                     {
                        _loc15_ = this.getEffectiveResourceAmount(_loc14_,param6,this.m_resourceYield[_loc14_].amount);
                        if(_loc14_ == "coins")
                        {
                           _loc15_ = Math.floor(_loc15_ * (1 - _loc11_ / 100));
                        }
                        if(param1.multiplier != 0)
                        {
                           _loc15_ *= param1.multiplier;
                        }
                        RewardPickupManager.instance.addResourceReward(_loc7_,_loc14_,_loc15_);
                     }
                     else if(!param4)
                     {
                        ZGlobal.player.resources.updateResourceAmount(_loc14_,this.m_resourceYield[_loc14_].amount);
                        _loc16_ = new ResourceActionFeedback(_loc7_,_loc14_,this.m_resourceYield[_loc14_].amount,_loc8_++);
                     }
                  }
               }
            }
            if(_loc9_)
            {
               WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ITEM_HARVESTED,_loc9_.code));
            }
         }
         if(param1)
         {
            if(this.m_buildable)
            {
               if(_loc9_)
               {
                  if(!WarehouseExperimentManager.instance.masterOn || !_loc9_.isUnit() || _loc9_ is UnitItem && (_loc9_ as UnitItem).hasType("mega"))
                  {
                     ZGlobal.player.addToInventory(_loc9_.code);
                     if(this.placeImmediately(_loc9_))
                     {
                        GameModeManager.instance.addGameMode(new GMObjectPlace(_loc9_.name,MarketEvent.SOURCE_INVENTORY,true));
                     }
                  }
                  else if(WarehouseExperimentManager.instance.masterOn && _loc9_.builtFromStructure != null && _loc9_.builtFromStructure.code == "MF1" || !_loc9_.isUnit() || _loc9_ is UnitItem && (_loc9_ as UnitItem).hasType("mega"))
                  {
                     _loc20_ = ZGlobal.gameSettings.getItemByName(param1.referenceItemName,GameItem) as GameItem;
                     ZGlobal.player.addToInventory(_loc9_.code);
                     _loc21_ = _loc20_.name + "_menuName";
                     _loc22_ = ZGameUtils.ZlocT("Items",_loc21_);
                     PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":_loc22_}),null);
                  }
                  _loc19_ = new ItemActionFeedback(_loc7_,_loc9_.code,1,_loc8_++);
               }
            }
            if(Boolean(this.m_upgrade && _loc9_) && Boolean(param1.researchItemName) && param1.researchItemName.length > 0)
            {
               _loc23_ = ZGlobal.gameSettings.getItemByName(param1.researchItemName,UnitItem) as UnitItem;
               WorldUpgradeManager.instance.addUpgrade(_loc23_.code,_loc9_.code);
               _loc17_ = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","upgrade_complete"),ZGameUtils.ZlocT("FeedPopups","upgrade_complete_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onUpgradeCompleteDialogClosed,ZGlobal.gameSettings.getImageByName(param1.referenceItemName,"icon"),FeedPopup.LARGE_IMAGE,null,_loc9_.isMegaBuilding() || Boolean(_loc23_) && Boolean(UnitItem(_loc23_).hasType(UnitItem.MEGA_UNIT)) ? _loc9_ : null);
               _loc18_ = new Object();
               _loc18_.name = _loc23_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
               _loc18_.subType = _loc9_.subType;
               _loc17_.userData = _loc18_;
               PopupManager.instance.push(_loc17_);
               param1.referenceItemName = null;
               param1.researchItemName = null;
            }
            if(Boolean(this.m_resourceUnlock && param1.referenceItemName) && Boolean(param1.resourceType) && param1.resourceType.length > 0)
            {
               if(SuperOreManager.instance.lastUnlockResource() == param1.resourceType)
               {
                  SuperOreManager.instance.unlockResource(0);
               }
            }
            if(this.m_powerup && Boolean(_loc9_))
            {
               _loc17_ = new FeedPopup(StringUtils.upperCaseFirstChar(ZGameUtils.ZlocT("FeedPopups","powerup_complete",{"powerupname":_loc9_.getSentenceNameLocalizationObject("singular")})),ZGameUtils.ZlocT("FeedPopups","powerup_complete_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onPowerupCompleteDialogClosed,ZGlobal.gameSettings.getImageByName(param1.referenceItemName,"icon"));
               _loc18_ = new Object();
               _loc18_.name = _loc9_.name;
               _loc18_.itemCode = _loc9_.code;
               _loc17_.userData = _loc18_;
               PopupManager.instance.push(_loc17_);
               param1.referenceItemName = null;
            }
            if(this.m_mission && Boolean(_loc9_))
            {
               _loc24_ = new MissionCompletePopup(_loc9_);
               PopupManager.instance.push(_loc24_);
               param1.referenceItemName = null;
            }
         }
         if(this.m_dooberActionType)
         {
            _loc25_ = DooberManager.instance.getRandomRewards(this.m_rand,DooberManager.instance.getHarvestActionType(),this.m_dooberActionType);
            for each(_loc27_ in _loc25_)
            {
               _loc26_ = ZGlobal.gameSettings.getItemByCode(_loc27_.item,GameItem) as GameItem;
               RewardPickupManager.instance.addItemReward(_loc7_,_loc26_);
            }
         }
         if(this.m_item)
         {
            _loc28_ = ZGlobal.gameSettings.getItemByCode(this.m_item,GameItem) as GameItem;
            RewardPickupManager.instance.addItemReward(_loc7_,_loc28_);
         }
         RewardPickupManager.instance.startLootCreationScope(false);
      }
      
      private function onPowerupCompleteDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "powerup_complete";
            ViralsManager.instance.sendFeed(_loc2_,{
               "itemCode":param1.userData.itemCode,
               "ITEMTOKitem":param1.userData.name + "|"
            });
         }
      }
      
      private function onMissionCompleteDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            GameModeManager.instance.addGameMode(new GMDeployMission(param1.userData.itemCode));
         }
      }
      
      private function onUpgradeCompleteDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "upgrade_complete_";
            _loc2_ += param1.userData.subType;
            ViralsManager.instance.sendFeed(_loc2_,{"type":param1.userData.name});
         }
      }
      
      private function placeImmediately(param1:GameItem) : Boolean
      {
         if(param1.subType == UnitItem.AIR || param1.subType == UnitItem.ARMY || param1.subType == UnitItem.NAVY)
         {
            if(!param1.notPlaceable)
            {
               return true;
            }
         }
         return false;
      }
      
      public function initResourceData(param1:XML, param2:String) : void
      {
         var _loc3_:int = 0;
         if(param1..@nrare != undefined && parseInt(param1..@nrare) > 0)
         {
            _loc3_ = parseInt(param1..@nrare);
         }
         if(_loc3_ != 0)
         {
            if(this.m_resourceYield == null)
            {
               this.m_resourceYield = new Dictionary();
            }
            if(this.m_resourceYield[param2] == null)
            {
               this.m_resourceYield[param2] = WorldResourceManager.instance.createResource(param2,_loc3_);
            }
         }
      }
   }
}

