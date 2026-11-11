package core.gameobjects
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import flash.geom.Point;
   import rendering.renderingIso.QuadSpatialManager;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.utils.StringUtils;
   
   public class UnitItem extends PartsUnitItem
   {
      
      public static const ARMY:String = "army";
      
      public static const NAVY:String = "navy";
      
      public static const AIR:String = "air";
      
      public static const MEGA_UNIT:String = "mega";
      
      public static const MEGA_UNIT_CONTROLLER:String = "controller";
      
      public static const MEGA_UNIT_WEAPON:String = "weapon";
      
      public static const MEGA_UNIT_ARM:String = "arm";
      
      public static const VILLAIN:String = "villain";
      
      public static const INFANTRY:String = "infantry";
      
      public static const FX_DEATH:int = 0;
      
      public static const FX_SELECTION:int = 1;
      
      public static const ATTACK_COST_ENERGY:int = 0;
      
      public static const ATTACK_COST_MANA:int = 1;
      
      private static const sFXNames:Array = ["death","sel"];
      
      public static const MECH_ICON_PATH:String = "assets/game/GeneralAssetGroup_UI.swf/class_mech_32.png";
      
      private var m_types:Array = null;
      
      private var m_efficiency:uint = 0;
      
      public function UnitItem(param1:XML)
      {
         super(param1);
      }
      
      public static function createUnit(param1:String, param2:PBGroup, param3:IsoScene, param4:QuadSpatialManager, param5:Pt) : IEntity
      {
         var _loc6_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc7_:EntityInit = new EntityInit();
         _loc7_.m_item = _loc6_;
         _loc7_.m_isoScene = param3;
         _loc7_.m_position = param5;
         _loc7_.m_fromLoad = true;
         _loc7_.m_group = param2;
         _loc7_.m_spatialComponent = param4;
         _loc7_.m_generateId = true;
         var _loc8_:IEntity = BuildingEntity.createEntity(_loc7_);
         WorldObjectManager.instance.addObjectToCodeDictionary(_loc6_.code);
         WorldObjectManager.instance.addObjectToTypeDictionary(_loc6_.type,_loc6_.subType,_loc8_.name,_loc8_);
         WorldObjectManager.instance.addObjectToBuiltDictionary(_loc6_.code);
         WorldObjectManager.instance.addObjectToCategoryDictionary(_loc6_.categoryLimitName);
         return _loc8_;
      }
      
      private static function arrayIntersection(param1:Array, param2:Array, param3:Boolean = false) : Array
      {
         var _loc5_:Object = null;
         var _loc4_:Array = new Array();
         if(Boolean(param1) && Boolean(param2))
         {
            for each(_loc5_ in param1)
            {
               if(param2.indexOf(_loc5_) >= 0)
               {
                  _loc4_.push(_loc5_);
                  if(param3)
                  {
                     break;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public static function getModifier(param1:XMLList, param2:UnitItem) : Number
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc3_:Number = 1;
         for each(_loc4_ in param1)
         {
            if(param2.hasType(_loc4_.attribute("type")))
            {
               _loc5_ = _loc4_.attribute("mod");
               _loc3_ = parseFloat(_loc5_);
               break;
            }
         }
         return _loc3_;
      }
      
      public function get validForBattle() : Boolean
      {
         return subType != "fleet";
      }
      
      public function get unitClass() : String
      {
         return m_xml.@unitClass;
      }
      
      public function get setName() : String
      {
         return m_xml.@setName;
      }
      
      public function getAttackStrength(param1:Fleet, param2:Array = null) : int
      {
         var _loc3_:int = this.getXmlStrength(param1,true);
         return this.getModifiedStrength(_loc3_,param1,param2);
      }
      
      private function getModifiedShields(param1:int, param2:Fleet, param3:Array) : int
      {
         if(param2)
         {
            param3 = param2.getUpgrades(code);
         }
         return WorldUpgradeManager.instance.getModifiedShields(param3,param1);
      }
      
      public function getShields(param1:Fleet, param2:Array = null) : int
      {
         var _loc3_:int = this.getXmlStrength(param1,false);
         return this.getModifiedShields(_loc3_,param1,param2);
      }
      
      public function getStrength(param1:Fleet, param2:Array = null) : int
      {
         var _loc3_:int = this.getXmlStrength(param1,false);
         return this.getModifiedStrength(_loc3_,param1,param2);
      }
      
      public function getUpgradedStrength(param1:Fleet = null) : int
      {
         return this.getStrength(param1,WorldUpgradeManager.instance.getUpgradesByCode(this.code));
      }
      
      private function getXmlStrength(param1:Fleet, param2:Boolean) : int
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         if(m_xml.unit.@strength != undefined)
         {
            return m_xml.unit.@strength;
         }
         if(m_xml.unit.strengths != undefined && param1 != null)
         {
            _loc3_ = param1.playerLevel;
            for each(_loc4_ in m_xml.unit.strengths.entry)
            {
               if(_loc3_ < _loc4_.@level)
               {
                  if(param2)
                  {
                     return _loc4_.@attackStrength;
                  }
                  return _loc4_.@strength;
               }
            }
         }
         Logger.error(this,"getXmlStrength","no strength defined for unit " + code);
         return 1;
      }
      
      private function getModifiedStrength(param1:int, param2:Fleet, param3:Array = null) : int
      {
         var _loc4_:int = 0;
         var _loc5_:IslandItem = null;
         var _loc6_:Number = NaN;
         if(null != param2)
         {
            if(param2.hasStatus(Fleet.CAMPAIGN))
            {
               _loc4_ = ZGlobal.player.campaign.currentMap.inReplay ? ZGlobal.player.campaign.currentMap.replayIsland : ZGlobal.player.campaign.currentMap.progressIsland;
               _loc5_ = ZGlobal.player.campaign.currentMap.getItem(_loc4_);
               _loc6_ = _loc5_.strengthMultiplier(code);
               return int(param1 * _loc6_);
            }
            param3 = param2.getUpgrades(code);
         }
         return WorldUpgradeManager.instance.getModifiedStrength(param3,param1);
      }
      
      public function get broadside() : Boolean
      {
         return parseInt(m_xml.unit.attribute("broadside")) == 1;
      }
      
      public function get tier() : int
      {
         if(m_xml.unit.@tier != undefined)
         {
            return m_xml.unit.@tier;
         }
         return 1;
      }
      
      public function get xp() : int
      {
         var _loc1_:int = 1;
         var _loc2_:String = m_xml.unit.attribute("xp");
         if(_loc2_.length > 0)
         {
            _loc1_ = parseInt(_loc2_);
         }
         return _loc1_;
      }
      
      public function get counter() : Boolean
      {
         var _loc1_:String = m_xml.unit.attribute("counter");
         if(_loc1_.length > 0)
         {
            return _loc1_ != "1";
         }
         return false;
      }
      
      public function get driftMult() : Number
      {
         var _loc1_:Number = 1;
         var _loc2_:String = m_xml.unit.attribute("driftMult");
         if(_loc2_.length > 0)
         {
            _loc1_ = parseFloat(_loc2_);
         }
         return _loc1_;
      }
      
      public function get weak() : Boolean
      {
         return parseInt(m_xml.unit.attribute("weak")) == 1;
      }
      
      public function get weaker() : Boolean
      {
         return parseInt(m_xml.unit.attribute("weaker")) == 1;
      }
      
      public function get link() : String
      {
         return m_xml.unit.@link;
      }
      
      public function get highlightByDefault() : Boolean
      {
         return this.weaker;
      }
      
      public function get attackCost() : int
      {
         if(m_xml.unit.@attackcost != undefined)
         {
            return m_xml.unit.@attackcost;
         }
         return 1;
      }
      
      public function get attackCostType() : int
      {
         if(m_xml.unit.@attackType == "1")
         {
            return ATTACK_COST_MANA;
         }
         return ATTACK_COST_ENERGY;
      }
      
      public function get isRequriedBuildingActive() : Boolean
      {
         if(Boolean(m_xml.checkBuilt) && Boolean(m_xml.checkBuilt.@code))
         {
            if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode(m_xml.checkBuilt.@code) > 0)
            {
               return true;
            }
            return false;
         }
         return true;
      }
      
      public function get secondaryAbility() : String
      {
         return m_xml.unit.attribute("secondary");
      }
      
      public function hasType(param1:String) : Boolean
      {
         this.allocTypes();
         return this.m_types.indexOf(param1) >= 0;
      }
      
      public function hasAnyType(param1:Array) : Boolean
      {
         this.allocTypes();
         var _loc2_:Array = arrayIntersection(this.m_types,param1,true);
         if(_loc2_.length)
         {
            return true;
         }
         return false;
      }
      
      public function get typeString() : String
      {
         this.allocTypes();
         return ZGameUtils.ZlocT("Items","type_" + this.m_types[0]);
      }
      
      public function get formationIndex() : int
      {
         return m_xml.unit.@formationIndex;
      }
      
      public function getWeapons(param1:String, param2:String) : Array
      {
         var _loc4_:Object = null;
         var _loc5_:XMLList = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:String = null;
         var _loc3_:int = 0;
         while(_loc3_ < m_cachedImages.length)
         {
            _loc4_ = m_cachedImages[_loc3_];
            if(_loc4_.name == param1)
            {
               _loc5_ = m_xml.image[_loc3_].weapon;
               if((Boolean(_loc5_)) && _loc5_.length() > 0)
               {
                  _loc6_ = new Array();
                  _loc7_ = new Array();
                  _loc8_ = _loc5_.length();
                  _loc9_ = 0;
                  while(_loc9_ < _loc8_)
                  {
                     _loc10_ = new Object();
                     _loc10_.id = m_xml.image[_loc3_].weapon[_loc9_].@id.toString();
                     _loc10_.anchor = StringUtils.parsePoint(m_xml.image[_loc3_].weapon[_loc9_].@anchorPoint);
                     _loc10_.delay = ZGameTimeUtil.instance.parseTimeAsSeconds(m_xml.image[_loc3_].weapon[_loc9_].@delay.toString(),0);
                     _loc10_.background = m_xml.image[_loc3_].weapon[_loc9_].@background.toString().length > 0;
                     _loc11_ = m_xml.image[_loc3_].weapon[_loc9_].@target;
                     if(_loc11_ == param2)
                     {
                        _loc7_.push(_loc10_);
                     }
                     else if(_loc11_ == "")
                     {
                        _loc6_.push(_loc10_);
                     }
                     _loc9_++;
                  }
                  if(_loc7_.length > 0)
                  {
                     return _loc7_;
                  }
                  return _loc6_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getWake(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:XMLList = null;
         var _loc2_:int = 0;
         while(_loc2_ < m_cachedImages.length)
         {
            _loc3_ = m_cachedImages[_loc2_];
            if(_loc3_.name == param1)
            {
               _loc4_ = m_xml.image[_loc2_].wake;
               if((Boolean(_loc4_)) && _loc4_.length() > 0)
               {
                  return {
                     "animation":m_xml.image[_loc2_].wake[0].@name.toString(),
                     "anchorPoint":m_xml.image[_loc2_].wake[0].@anchorPoint.toString()
                  };
               }
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getFX(param1:int) : String
      {
         return m_xml.unit.FX.attribute(sFXNames[param1]);
      }
      
      private function allocTypes() : void
      {
         var _loc1_:String = null;
         if(null == this.m_types)
         {
            _loc1_ = m_xml.unit.attribute("type");
            this.m_types = _loc1_.split(",");
         }
      }
      
      public function get researchTemplate() : String
      {
         return m_xml.researchTemplate;
      }
      
      public function get goodAgainst() : Array
      {
         var _loc2_:String = null;
         var _loc1_:UnitClass = UnitClassManager.instance.unitClassNamed(this.unitClass);
         if(_loc1_)
         {
            _loc2_ = _loc1_.getGoodAgainst();
            if(_loc2_ != "")
            {
               return _loc2_.split(",");
            }
         }
         return [];
      }
      
      public function hasUnitItemSubtype() : Boolean
      {
         return subType == ARMY || subType == NAVY || subType == AIR;
      }
      
      public function healthBarOffset(param1:int) : Point
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(m_xml.unit.@barOffset != undefined)
         {
            _loc2_ = m_xml.unit.@barOffset.toString().split(",");
            _loc3_ = 0;
            if(_loc2_.length > 2)
            {
               _loc3_ = param1 * 2;
            }
            return new Point(_loc2_[_loc3_ + 0],_loc2_[_loc3_ + 1]);
         }
         return null;
      }
      
      public function get megaUnits() : Array
      {
         if(m_xml.unit.units != undefined)
         {
            return m_xml.unit.units.toString().split(",");
         }
         return null;
      }
      
      public function get megaTemplate() : String
      {
         if(m_xml.unit.template != undefined)
         {
            return m_xml.unit.template;
         }
         return null;
      }
      
      public function templateFor(param1:String) : Boolean
      {
         if(code == param1)
         {
            return true;
         }
         if(m_xml.unit.units != undefined)
         {
            return m_xml.unit.units.toString().indexOf(param1) >= 0;
         }
         return false;
      }
      
      private function getModifiedEfficiency(param1:int, param2:Fleet, param3:Array) : int
      {
         if(param2)
         {
            param3 = param2.getUpgrades(code);
         }
         return WorldUpgradeManager.instance.getModifiedEfficiency(param3,param1);
      }
      
      public function getEfficiency(param1:Fleet, param2:String = null) : uint
      {
         if(this.hasType(MEGA_UNIT))
         {
            param2 = this.megaTemplate;
         }
         var _loc3_:uint = uint(this.getModifiedEfficiency(0,param1,WorldUpgradeManager.instance.getUpgradesByCode(param2)));
         this.m_efficiency += 1;
         if(_loc3_ > 0 && this.m_efficiency >= _loc3_)
         {
            this.m_efficiency = 0;
            return _loc3_;
         }
         return 0;
      }
      
      public function unitEfficiency() : uint
      {
         return this.m_efficiency;
      }
   }
}

