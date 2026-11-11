package core.gameobjects
{
   import Engine.Helpers.Vector3;
   import ZLocalization.LocalizationObjectToken;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.BuildManager;
   import core.managers.EarlyUnitUnlockManager;
   import core.managers.ExperimentsManager;
   import core.managers.ItemCostOverridesManager;
   import core.managers.LEUnitDiscountManager;
   import core.managers.PriceTestManager;
   import core.managers.UnitContractUnlockManager;
   import core.managers.UnitPriceExperimentManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.player.Player;
   import core.resource.WorldResource;
   import dispatchers.UIDispatcher;
   import displays.popups.DirectReliefCongratulationsPopup;
   import events.ResourceUpdatedEvent;
   import flash.events.EventDispatcher;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import utils.BitArray;
   import utils.CriteriaUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.core.ObjectType;
   import zlabs.events.WorldEvent;
   import zlabs.utils.StringUtils;
   
   public class GameItem extends EventDispatcher implements IItem
   {
      
      public static const TYPE_BUILDING:String = "building";
      
      public static const TYPE_BUILDABLE:String = "Buildable";
      
      public static const TYPE_EXPANSION:String = "expansion";
      
      public static const TYPE_ROAD:String = "road";
      
      public static const TYPE_CONSUMABLE:String = "consumable";
      
      public static const TYPE_MERCENARY:String = "mercenary";
      
      public static const TYPE_NPC:String = "npc";
      
      public static const TYPE_RESOURCE:String = "resource";
      
      public static const TYPE_PART:String = "buildablepart";
      
      public static const TYPE_DECORATION:String = "decoration";
      
      public static const TYPE_GLOBALPVP_SLOTTOKEN:String = "gpvpslottoken";
      
      public static const TYPE_MANA:String = "mana";
      
      public static const TYPE_MECHPART:String = "mechpart";
      
      public static const TYPE_BUILDMENUPROXY:String = "buildmenuproxy";
      
      public static const SUBTYPE_BUILDMENU_PROXY_STARTERPACK:String = "starterpack";
      
      public static const SUBTYPE_DECORATION:String = "decoration";
      
      public static const SUBTYPE_PRODUCTION:String = "production";
      
      public static const SUBTYPE_RESIDENTIAL:String = "residential";
      
      public static const SUBTYPE_UNIT_ARMY:String = "army";
      
      public static const SUBTYPE_UNIT_NAVY:String = "navy";
      
      public static const SUBTYPE_UNIT_AIR:String = "air";
      
      public static const SUBTYPE_RESOURCE:String = "resource";
      
      public static const SUBTYPE_EXPANSION:String = "expansion";
      
      public static const SUBTYPE_CREW_EXPANSION:String = "crewExpansion";
      
      public static const SUBTYPE_CASH_EXPANSION:String = "cashExpansion";
      
      public static const SUBTYPE_UNITPART:String = "unitpart";
      
      public static const SUBTYPE_BUILDINGPART:String = "buildingpart";
      
      public static const SUBTYPE_SUPPORTBUILDINGPART:String = "supportbuildingpart";
      
      public static const SUBTYPE_TREASUREVAULTPART:String = "treasurevaultpart";
      
      public static const SUBTYPE_PALACEPART:String = "palacepart";
      
      public static const SUBTYPE_DEFENSEPART:String = "defensepart";
      
      public static const SUBTYPE_POWERUPPART:String = "poweruppart";
      
      public static const SUBTYPE_VILLAINTOKEN:String = "villaintoken";
      
      public static const SUBTYPE_MEGA_UNIT:String = "mega";
      
      public static const SUBTYPE_QUESTPART:String = "questpart";
      
      public static const SUBTYPE_MECHPART:String = "mechpart";
      
      public static const SUBTYPE_FARMCAMPPART:String = "FarmCampPart";
      
      public static const SUBTYPE_DRONEPART:String = "dronepart";
      
      public static const SUBTYPE_VOLCANOPOWERPART:String = "volcanoPowerPart";
      
      public static const SUBTYPE_VRTRAININGSIMULATORPART:String = "VRTrainingSimulatorPart";
      
      public static const SUBTYPE_AMITYLIGHTHOUSEPART:String = "AmityLighthousePart";
      
      public static const SUBTYPE_HOOK:String = "hook";
      
      public static const DIRECTION_NAMES:Array = ["sw","nw","ne","se","w","n","e","s"];
      
      public static const DIRECTION_ANGLES:Array = new Array(8);
      
      public static const DIRECTION_SW:int = 0;
      
      public static const DIRECTION_NW:int = 1;
      
      public static const DIRECTION_NE:int = 2;
      
      public static const DIRECTION_SE:int = 3;
      
      public static const DIRECTION_W:int = 4;
      
      public static const DIRECTION_N:int = 5;
      
      public static const DIRECTION_E:int = 6;
      
      public static const DIRECTION_S:int = 7;
      
      public static const DIRECTION_DEFAULT:int = DIRECTION_SW;
      
      public static const NO_TOOLTIP:String = "none";
      
      public static const DEFAULT_TOOLTIP:String = "default";
      
      public static const RESOURCE_TOOLTIP:String = "resource";
      
      public static const STORE_RESOURCE_TOOLTIP:String = "store_resource";
      
      public static const HOUSE_TOOLTIP:String = "house";
      
      public static const UNIT_TOOLTIP:String = "unit";
      
      public static const SUPPORT_UNIT_TOOLTIP:String = "support_unit";
      
      public static const UPGRADE_TOOLTIP:String = "upgrade";
      
      public static const CONSUMABLE_TOOLTIP:String = "consumable";
      
      public static const DECORATION_TOOLTIP:String = "decoration";
      
      public static const DECORATION_MEANINGFUL_TOOLTIP:String = "decoration_meaningful";
      
      public static const ISLAND_TOOLTIP:String = "island";
      
      public static const EXPANSION_TOOLTIP:String = "expansion";
      
      public static const ENERGY_TOOLTIP:String = "energy";
      
      public static const AMMO_TOOLTIP:String = "ammo";
      
      public static const MANA_TOOLTIP:String = "mana";
      
      public static const BASIC_TOOLTIP:String = "basic";
      
      public static const CIVIC_TOOLTIP:String = "civic";
      
      public static const BONUS_AGAINST_TOOLTIP:String = "bonusAgainst";
      
      public static const BONUS_AGAINST_WITH_UPGRADES_TOOLTIP:String = "bonusAgainstWithUpgrades";
      
      public static const SPARSE_TOOLTIP:String = "sparse";
      
      public static const TITAN_TOOLTIP:String = "titan";
      
      public static const WORLDGAMES_TOOLTIP:String = "worldgamesdeco_tooltip";
      
      public static const MENU_FRIENDLYNAME:int = 0;
      
      public static const SENTENCE_FRIENDLYNAME:int = 1;
      
      public static const SENTENCE_OVERRIDENAME:int = 2;
      
      public static const LIMIT_UNLIMITED:int = -1;
      
      public static const CATEGORY_LIMIT_UNDEFINED:String = "categoryLimitUndefined";
      
      private static var m_directionRays:Array = null;
      
      protected static var m_loadedAssets:Array = [];
      
      private static var popupTypes:Array = [DirectReliefCongratulationsPopup];
      
      public var m_cachedImages:Array = [];
      
      private var m_cachedStateMachineValuesAsString:String = null;
      
      protected var m_collisionData:Array = [];
      
      protected var m_xml:XML = null;
      
      private var m_pillageType:String = "-1";
      
      private var m_defenseRangeX:int = -1;
      
      private var m_defenseRangeY:int = -1;
      
      private var m_resourceType:String = null;
      
      public function GameItem(param1:XML)
      {
         super();
         this.m_xml = param1;
         this.loadImages();
      }
      
      public static function initDirectionRays() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Matrix = null;
         var _loc5_:Point = null;
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < 4)
         {
            DIRECTION_ANGLES[_loc2_] = _loc1_;
            DIRECTION_ANGLES[_loc2_ + 4] = _loc1_ + Math.PI * 0.25;
            _loc2_++;
            _loc1_ += Math.PI * 0.5;
         }
         m_directionRays = [];
         for each(_loc3_ in DIRECTION_ANGLES)
         {
            _loc4_ = new Matrix();
            _loc4_.rotate(_loc3_);
            _loc5_ = _loc4_.transformPoint(new Point(0,1));
            m_directionRays.push(new Vector3(_loc5_.x,_loc5_.y));
         }
      }
      
      public static function getDirectionRay(param1:int) : Vector3
      {
         return m_directionRays[param1];
      }
      
      public static function getDirectionFromAngle(param1:Number) : int
      {
         var _loc8_:Vector3 = null;
         var _loc9_:Number = NaN;
         var _loc2_:Matrix = new Matrix();
         _loc2_.rotate(param1);
         var _loc3_:Point = _loc2_.transformPoint(new Point(0,1));
         var _loc4_:Vector3 = new Vector3(_loc3_.x,_loc3_.y);
         var _loc5_:Number = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         for each(_loc8_ in m_directionRays)
         {
            _loc9_ = _loc4_.dot(_loc8_);
            if(_loc9_ > _loc5_)
            {
               _loc6_ = _loc7_;
               _loc5_ = _loc9_;
            }
            _loc7_++;
         }
         return _loc6_;
      }
      
      public static function createItemFromCode(param1:String, param2:XMLList) : GameItem
      {
         var matchingList:XMLList = null;
         var itemXml:XML = null;
         var codeStr:String = param1;
         var itemList:XMLList = param2;
         matchingList = itemList.(@code == codeStr);
         itemXml = null;
         if(matchingList.length())
         {
            itemXml = matchingList[0];
         }
         if(itemXml != null)
         {
            if(itemXml.unit.length() > 0)
            {
               return ZGlobal.gameSettings.getItemByCode(codeStr,UnitItem) as UnitItem;
            }
            if(itemXml.consumable.length() > 0)
            {
               return ZGlobal.gameSettings.getItemByCode(codeStr,ConsumableItem) as ConsumableItem;
            }
            if(itemXml.@type == GameItem.TYPE_MERCENARY)
            {
               return ZGlobal.gameSettings.getItemByCode(codeStr,MercenaryItem) as MercenaryItem;
            }
            return ZGlobal.gameSettings.getItemByCode(codeStr,GameItem) as GameItem;
         }
         return null;
      }
      
      private function loadImages() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         if(this.m_xml.image != null)
         {
            this.m_cachedImages = new Array();
            _loc1_ = 0;
            while(_loc1_ < this.m_xml.image.length())
            {
               _loc2_ = ZGlobal.getAssetURL(this.m_xml.image[_loc1_].@url);
               _loc3_ = this.createImage(this.m_xml.image[_loc1_]);
               this.m_cachedImages.push(_loc3_);
               _loc1_++;
            }
         }
         if(this.m_xml.additionalImage != null)
         {
            _loc4_ = this.m_xml.additionalImage.length();
            if(_loc4_ > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  _loc6_ = this.createImage(this.m_xml.additionalImage[_loc5_]);
                  _loc7_ = _loc6_.name;
                  if(_loc6_.addRare == "true")
                  {
                     _loc9_ = _loc7_.search("_");
                     _loc7_ = _loc7_.substr(0,_loc9_);
                  }
                  if(_loc6_.profilePic == "true")
                  {
                     UIDispatcher.instance.addEventListener(UIDispatcher.PLAYER_NAME_LOADED,this.onHostPlayerChange,false,0,true);
                     if(ZGlobal.isVisiting())
                     {
                        _loc6_.url = ZGlobal.hostPlayer.portraitURL;
                     }
                     else
                     {
                        _loc6_.url = ZGlobal.player.portraitURL;
                     }
                  }
                  _loc8_ = this.getItemIndex(_loc7_);
                  if(_loc8_ >= 0)
                  {
                     _loc10_ = this.m_cachedImages[_loc8_];
                     if(null == _loc10_.additionalImages)
                     {
                        _loc10_.additionalImages = new Array();
                     }
                     _loc10_.additionalImages.push(_loc6_);
                  }
                  _loc5_++;
               }
            }
         }
      }
      
      private function onHostPlayerChange(param1:WorldEvent) : void
      {
         this.loadImages();
      }
      
      private function createImage(param1:XML) : Object
      {
         var _loc7_:Point = null;
         var _loc8_:Array = null;
         var _loc2_:String = ZGlobal.getAssetURL(param1.@url);
         var _loc3_:Object = new Object();
         _loc3_.url = _loc2_;
         _loc3_.bitmapData = null;
         _loc3_.loader = null;
         _loc3_.loaded = false;
         _loc3_.width = int(param1.@width);
         _loc3_.height = int(param1.@height);
         _loc3_.name = String(param1.@name);
         _loc3_.itemName = String(param1.@itemName);
         _loc3_.offset = null;
         _loc3_.skew = null;
         _loc3_.addRare = String(param1.@addRare);
         _loc3_.profilePic = String(param1.@profilePic);
         var _loc4_:String = String(param1.@offset);
         if((Boolean(_loc4_)) && _loc4_.length > 0)
         {
            _loc7_ = StringUtils.parsePoint(_loc4_);
            _loc3_.offset = new Pt(_loc7_.x,_loc7_.y);
         }
         var _loc5_:String = String(param1.@skew);
         if((Boolean(_loc5_)) && _loc5_.length > 0)
         {
            _loc8_ = _loc5_.split(",");
            _loc3_.skew = new Pt(_loc8_[0],_loc8_[1]);
         }
         var _loc6_:XMLList = param1.animation;
         if(_loc6_)
         {
            _loc3_.numAnimations = _loc6_.length();
         }
         return _loc3_;
      }
      
      public function get pillageType() : String
      {
         if(this.m_pillageType == "-1")
         {
            this.m_pillageType = ZGlobal.gameSettings.getPillageType(this);
         }
         return this.m_pillageType;
      }
      
      public function get name() : String
      {
         return this.m_xml.@name;
      }
      
      public function get uiNameOverride() : String
      {
         var _loc1_:String = this.xmlOverride("uiItemNameOverride","name");
         return _loc1_ ? _loc1_ : this.name;
      }
      
      public function xmlOverride(param1:String, param2:String) : String
      {
         var _loc4_:XML = null;
         var _loc3_:XMLList = this.m_xml.elements(param1);
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.attribute(param2) != undefined)
            {
               if(CriteriaUtil.meetsCriteria(_loc4_.criteria))
               {
                  return _loc4_.attribute(param2).toString();
               }
            }
         }
         return null;
      }
      
      public function get xml() : XML
      {
         return this.m_xml;
      }
      
      protected function getFriendlyNameLocFile() : String
      {
         if(Boolean(this.m_xml.tooltip) && this.m_xml.tooltip.@properties != undefined)
         {
            return this.m_xml.tooltip.@properties;
         }
         return "Items";
      }
      
      protected function addAdditionalParams(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = ZGameUtils.callFunctionFromXml(this.textReplacements);
         for(_loc3_ in _loc2_)
         {
            param1[_loc3_] = _loc2_[_loc3_];
         }
      }
      
      public function defaultTooltip() : String
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         if(Boolean(this.m_xml.tooltip) && this.m_xml.tooltip.@override != undefined)
         {
            _loc1_ = this.m_xml.tooltip.@override;
            _loc2_ = _loc1_.split(":");
            _loc3_ = {};
            this.addAdditionalParams(_loc3_);
            if(_loc2_.length > 1)
            {
               return ZGameUtils.ZlocT(_loc2_[0],_loc2_[1],_loc3_);
            }
            return ZGameUtils.ZlocT("Tooltips",_loc1_,_loc3_);
         }
         if(this.megaseries)
         {
            return ZGameUtils.ZlocT("Items",this.name + "_description");
         }
         return this.getFriendlyName(MENU_FRIENDLYNAME);
      }
      
      public function getSentenceNameLocalizationObject(param1:String = "singular", param2:Boolean = false) : LocalizationObjectToken
      {
         if(param2 && this.hasSentenceNameOverride())
         {
            return ZGameUtils.ZlocTk(this.getFriendlyNameLocFile(),this.uiNameOverride + "_sentenceName_override",param1);
         }
         if(this.hasSentenceName())
         {
            return ZGameUtils.ZlocTk(this.getFriendlyNameLocFile(),this.uiNameOverride + "_sentenceName",param1);
         }
         return null;
      }
      
      public function getFriendlyName(param1:int) : String
      {
         var _loc2_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc3_:Object = {};
         this.addAdditionalParams(_loc3_);
         if(param1 == MENU_FRIENDLYNAME || !this.hasSentenceName() && !this.hasSentenceNameOverride())
         {
            _loc4_ = this.xmlOverride("menuNameOverride","token");
            if(_loc4_)
            {
               _loc5_ = _loc4_.split(":");
               if(_loc5_.length > 1)
               {
                  return ZGameUtils.ZlocT(_loc5_[0],_loc5_[1]);
               }
               return ZGameUtils.ZlocT(this.getFriendlyNameLocFile(),_loc5_[0]);
            }
            return ZGameUtils.ZlocT(this.getFriendlyNameLocFile(),this.uiNameOverride + "_menuName",_loc3_);
         }
         if(param1 == SENTENCE_OVERRIDENAME && this.hasSentenceNameOverride())
         {
            return ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk(this.getFriendlyNameLocFile(),this.uiNameOverride + "_sentenceName_override","singular"));
         }
         _loc2_ = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk(this.getFriendlyNameLocFile(),this.uiNameOverride + "_sentenceName","singular"));
         if(_loc2_ == null || _loc2_ == "")
         {
            return this.name + "_friendlyName";
         }
         return _loc2_;
      }
      
      public function hasSentenceName() : Boolean
      {
         return Boolean(this.m_xml.loc) && this.m_xml.loc.@sentenceName != undefined;
      }
      
      public function hasSentenceNameOverride() : Boolean
      {
         return Boolean(this.m_xml.loc) && this.m_xml.loc.@sentenceNameOverride != undefined;
      }
      
      public function get localizeAmount() : Boolean
      {
         return Boolean(this.m_xml.loc) && this.m_xml.loc.@localizeAmount != undefined;
      }
      
      public function getImageObject() : Object
      {
         if(this.m_cachedImages.length > 0)
         {
            return this.m_cachedImages[this.m_cachedImages.length - 1];
         }
         return null;
      }
      
      public function getImageObjectFromCache() : Object
      {
         var _loc1_:Object = null;
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cachedImages.length)
         {
            _loc3_ = this.m_cachedImages[_loc2_];
            if(_loc3_.name == "static")
            {
               _loc1_ = _loc3_;
               break;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getCachedImage(param1:String) : ItemImage
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc2_:ItemImage = new ItemImage();
         var _loc3_:int = this.getItemIndex(param1);
         if(_loc3_ >= 0)
         {
            _loc4_ = this.m_cachedImages[_loc3_];
            _loc2_.url = _loc4_.url;
            _loc2_.offset = _loc4_.offset;
            if(this.hasRareAdditionalImages(_loc4_))
            {
               _loc5_ = WorldResourceManager.instance.getResourceTypeFromIndex(ZGlobal.hostPlayer.rareResourceType);
               _loc2_.additionalImages = new Array();
               for each(_loc6_ in _loc4_.additionalImages)
               {
                  if(_loc6_.addRare == "true")
                  {
                     _loc7_ = _loc6_.name;
                     _loc8_ = _loc7_.search("_" + _loc5_);
                     if(!(_loc5_.length == 0 || _loc8_ < 0))
                     {
                        _loc2_.additionalImages.push(_loc6_);
                     }
                  }
               }
            }
            else
            {
               _loc2_.additionalImages = _loc4_.additionalImages;
            }
         }
         if(_loc2_.url == null)
         {
            _loc2_ = null;
         }
         return _loc2_;
      }
      
      private function hasRareAdditionalImages(param1:Object) : Boolean
      {
         var _loc2_:Object = null;
         if(null != param1.additionalImages)
         {
            for each(_loc2_ in param1.additionalImages)
            {
               if(_loc2_.addRare == "true")
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function hasCachedImage(param1:String) : Boolean
      {
         return this.getItemIndex(param1) >= 0;
      }
      
      public function maxAnimations() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cachedImages.length)
         {
            _loc1_ = Math.max(_loc1_,this.m_cachedImages[_loc2_].numAnimations);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getAnimations(param1:String) : Array
      {
         var _loc3_:Object = null;
         var _loc4_:XMLList = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cachedImages.length)
         {
            _loc3_ = this.m_cachedImages[_loc2_];
            if(_loc3_.name == param1)
            {
               _loc4_ = this.m_xml.image[_loc2_].animation;
               if((Boolean(_loc4_)) && _loc4_.length() > 0)
               {
                  _loc5_ = new Array();
                  _loc6_ = 0;
                  while(_loc6_ < this.m_xml.image[_loc2_].animation.length())
                  {
                     _loc5_.push({
                        "name":this.m_xml.image[_loc2_].animation[_loc6_].@name.toString(),
                        "anchor":StringUtils.parsePoint(this.m_xml.image[_loc2_].animation[_loc6_].@anchorPoint)
                     });
                     _loc6_++;
                  }
                  return _loc5_;
               }
            }
            _loc2_++;
         }
         return null;
      }
      
      public function hasDirectionArt() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cachedImages.length)
         {
            if(DIRECTION_NAMES.indexOf(this.m_cachedImages[_loc2_].name) >= 0)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_ == DIRECTION_NAMES.length;
      }
      
      public function hasBouncyStates() : Boolean
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:XMLList = ZGlobal.gameSettings.getStateMachine(this.getStateMachineName(null));
         if(null != _loc1_)
         {
            for each(_loc2_ in _loc1_.state)
            {
               _loc3_ = _loc2_.@bounceOnClick.toString();
               if(_loc3_.length > 0)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function cursor(param1:String) : String
      {
         var node:XMLList;
         var cursorName:String = null;
         var type:String = param1;
         cursorName = "cursor";
         if(null != type)
         {
            cursorName += "_" + type;
         }
         node = this.m_xml.image.(@name == cursorName);
         if(node.length())
         {
            return node[0].@url;
         }
         return null;
      }
      
      public function get debugName() : String
      {
         return this.m_xml.@debugName.toString();
      }
      
      public function get workers() : String
      {
         return this.m_xml.yield..@workers;
      }
      
      public function get workersCap() : String
      {
         return this.m_xml.yield..@workersCap;
      }
      
      public function get fleetYield() : int
      {
         var _loc1_:String = this.m_xml..@fleets.toString();
         if(_loc1_.length > 0)
         {
            return parseInt(_loc1_);
         }
         return 0;
      }
      
      public function get textReplacements() : String
      {
         return this.m_xml.@textReplacements;
      }
      
      public function get placeable() : Boolean
      {
         var _loc1_:String = this.m_xml..@placeable.toString();
         return _loc1_.length > 0;
      }
      
      public function get notPlaceable() : Boolean
      {
         return this.m_xml.@placeable == "false";
      }
      
      public function get isExpansionItem() : Boolean
      {
         return this.type == TYPE_EXPANSION && (this.subType == SUBTYPE_EXPANSION || this.subType == SUBTYPE_CREW_EXPANSION || this.subType == SUBTYPE_CASH_EXPANSION);
      }
      
      public function get isResourceExpansionItem() : Boolean
      {
         return this.type == TYPE_EXPANSION && this.subType == SUBTYPE_EXPANSION;
      }
      
      public function get isCrewableExpansionItem() : Boolean
      {
         return this.type == TYPE_EXPANSION && this.subType == SUBTYPE_CREW_EXPANSION;
      }
      
      public function isResearchItem() : Boolean
      {
         var _loc1_:String = this.m_xml.@research.toString();
         return _loc1_.length > 0;
      }
      
      public function isSupportFactory() : Boolean
      {
         return this.m_xml.@supportFactory != undefined;
      }
      
      public function get buildingPartsKingdom() : String
      {
         if(this.m_xml.@buildingPartsKingdom != undefined)
         {
            return this.m_xml.@buildingPartsKingdom.toString();
         }
         return null;
      }
      
      public function get buildingPartsDialog() : String
      {
         if(this.m_xml.@buildingPartsDialog != undefined)
         {
            return this.m_xml.@buildingPartsDialog.toString();
         }
         return null;
      }
      
      public function isChallengeRequirement() : Boolean
      {
         var _loc1_:String = this.m_xml..@challengeRequirement.toString();
         return _loc1_.length > 0;
      }
      
      public function get bundleSize() : int
      {
         var _loc1_:XMLList = this.m_xml.bundle;
         return _loc1_.length();
      }
      
      public function get isBundle() : Boolean
      {
         return this.bundleSize > 0;
      }
      
      public function bundleXML(param1:int) : XML
      {
         var _loc3_:XMLList = null;
         var _loc2_:XML = null;
         if(param1 < this.bundleSize)
         {
            _loc3_ = this.m_xml.bundle;
            _loc2_ = _loc3_[param1];
         }
         return _loc2_;
      }
      
      public function setBundle(param1:int, param2:Array) : void
      {
         var _loc3_:Object = null;
         var _loc4_:XML = null;
         this.m_xml.cost = <cost/>;
         this.m_xml.cost.@cash = param1.toString();
         if(this.m_xml.bundle != undefined)
         {
            while(this.m_xml.bundle.length() > 0)
            {
               delete this.m_xml.bundle[this.m_xml.bundle.length() - 1];
            }
         }
         for each(_loc3_ in param2)
         {
            _loc4_ = <bundle/>;
            _loc4_.@item = _loc3_.code;
            _loc4_.@quantity = _loc3_.quantity;
            this.m_xml.appendChild(_loc4_);
         }
      }
      
      public function get sellable() : Boolean
      {
         var _loc1_:String = this.m_xml..@sellable.toString();
         return _loc1_.length == 0 || _loc1_ == "true";
      }
      
      public function get marketSellable() : Boolean
      {
         return this.m_xml.@marketSellable != "false";
      }
      
      public function get rotateable() : Boolean
      {
         var _loc1_:String = this.m_xml..@rotateable.toString();
         return _loc1_.length > 0;
      }
      
      public function get bonusPercent() : Number
      {
         var _loc1_:Number = 0;
         if(this.m_xml.bonusPercent.length() > 0)
         {
            _loc1_ = parseFloat(this.m_xml.bonusPercent);
         }
         return _loc1_;
      }
      
      public function get inventoryCap() : int
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         if(this.code == "xk01")
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode("x01",ExpansionItem) as ExpansionItem;
            _loc1_ = _loc2_.itemCosts["xk01"] * ZGlobal.gameSettings.getNumber("expansionItemCapScalar",1.5);
         }
         else if(this.m_xml.inventoryCapExperiment != undefined)
         {
            _loc3_ = ExperimentsManager.instance.getExperimentVariant(this.m_xml.inventoryCapExperiment.@experiment);
            _loc1_ = parseInt(this.m_xml.inventoryCapExperiment.attribute("capv" + _loc3_));
         }
         else if(this.m_xml.@inventoryCap != undefined)
         {
            _loc1_ = parseInt(this.m_xml.@inventoryCap);
         }
         else if(this.type == TYPE_CONSUMABLE && this.subType == TYPE_MANA)
         {
            _loc1_ = ExperimentsManager.instance.getExperimentValue(ManaItem.EXPERIMENT_SUPPORT_UNITS_MANA_INVENTORY,ZGlobal.gameSettings.getManaExperimentValues("exp_su_mana_inventory"),25);
         }
         return _loc1_;
      }
      
      public function getStateMachineName(param1:String) : String
      {
         var stateMachineName:String = null;
         var referenceList:XMLList = null;
         var referenceName:String = param1;
         if(!referenceName && this.m_xml.stateMachineValues.length() > 0)
         {
            stateMachineName = this.m_xml.stateMachineValues.@stateMachineName;
         }
         else if(Boolean(referenceName) && this.m_xml.referenceValues.length() > 0)
         {
            referenceList = this.m_xml.referenceValues.(@referenceName == referenceName);
            stateMachineName = referenceList.@stateMachineName;
         }
         return stateMachineName;
      }
      
      public function getStateMachineValuesAsXML(param1:String) : XMLList
      {
         var _loc2_:XMLList = null;
         if(param1 == null && this.m_xml.stateMachineValues.length() > 0)
         {
            _loc2_ = this.m_xml.stateMachineValues.define;
         }
         else if(Boolean(param1) && this.m_xml.referenceValues.length() > 0)
         {
            _loc2_ = this.m_xml.referenceValues.define;
         }
         return _loc2_;
      }
      
      public function getStateMachineValues(param1:String) : Dictionary
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:Dictionary = null;
         var _loc3_:XMLList = this.getStateMachineValuesAsXML(param1);
         if(null != _loc3_ && _loc3_.length() > 0)
         {
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = String(_loc4_.attribute("name"));
               _loc6_ = String(_loc4_.attribute("value"));
               if(Boolean(_loc5_) && Boolean(_loc6_))
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = new Dictionary();
                  }
                  _loc2_[_loc5_] = _loc6_;
               }
            }
         }
         return _loc2_;
      }
      
      public function getStateMachineValuesAsString() : String
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         if(null == this.m_cachedStateMachineValuesAsString)
         {
            this.m_cachedStateMachineValuesAsString = new String();
            _loc1_ = this.getStateMachineValuesAsXML(null);
            if(_loc1_.length() > 0)
            {
               for each(_loc2_ in _loc1_)
               {
                  if(Boolean(_loc2_.attribute("name")) && Boolean(_loc2_.attribute("value")))
                  {
                     this.m_cachedStateMachineValuesAsString += _loc2_.attribute("name").toString() + ":" + _loc2_.attribute("value").toString() + ",";
                  }
               }
            }
         }
         return this.m_cachedStateMachineValuesAsString;
      }
      
      public function getReferenceImage() : Dictionary
      {
         var _loc3_:XML = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:XMLList = new XMLList();
         if(this.m_xml.referenceImage.length() > 0)
         {
            _loc2_ = this.m_xml.referenceImage.define;
         }
         if(_loc2_.length() == 0)
         {
            return _loc1_;
         }
         for each(_loc3_ in _loc2_)
         {
            if(Boolean(_loc3_.attribute("name")) && Boolean(_loc3_.attribute("value")))
            {
               _loc1_[_loc3_.attribute("name").toString()] = _loc3_.attribute("value").toString();
            }
         }
         return _loc1_;
      }
      
      public function get referenceType() : String
      {
         var _loc1_:String = "";
         if(this.m_xml.child("stateMachineValues"))
         {
            _loc1_ = this.m_xml.stateMachineValues.@referenceType;
         }
         return _loc1_;
      }
      
      public function get referenceSubtype() : String
      {
         var _loc1_:String = "";
         if(this.m_xml.child("stateMachineValues"))
         {
            _loc1_ = this.m_xml.stateMachineValues.@referenceSubtype;
         }
         return _loc1_;
      }
      
      public function get diplomaticRequirements() : Dictionary
      {
         var _loc2_:XML = null;
         var _loc1_:Dictionary = new Dictionary();
         for each(_loc2_ in this.m_xml.diplomaticRequirements.requirement)
         {
            _loc1_[_loc2_.attribute("code").toString()] = parseInt(_loc2_.attribute("number").toString());
         }
         return _loc1_;
      }
      
      public function get hasRequiredLevel() : Boolean
      {
         return this.m_xml.requiredLevel != undefined;
      }
      
      public function get requiredLevel() : uint
      {
         return uint(this.m_xml.requiredLevel);
      }
      
      public function get starterPackPaymentCode() : String
      {
         if(this.m_xml.starterPackPayment == undefined)
         {
            return null;
         }
         return this.m_xml.starterPackPayment.toString();
      }
      
      public function get requiredNeighbors() : uint
      {
         return uint(this.m_xml.requiredNeighbors);
      }
      
      public function get requiredWorkers() : uint
      {
         return uint(this.m_xml.requiredWorkers);
      }
      
      public function get requiredDominanceRank() : uint
      {
         return uint(this.m_xml.requiredDominanceRank);
      }
      
      public function get giftLevel() : int
      {
         return this.m_xml.giftLevel != undefined ? int(this.m_xml.giftLevel) : 0;
      }
      
      public function get contractLocked() : Boolean
      {
         if(this.m_xml.@contractLocked != undefined)
         {
            return this.m_xml.@contractLocked.toString() == "true";
         }
         return false;
      }
      
      public function get requiredQuests() : String
      {
         return this.m_xml.requiredQuest;
      }
      
      public function get unlockOverrideName() : String
      {
         return this.m_xml.@unlockOverrideName.toString().length ? this.m_xml.@unlockOverrideName.toString() : null;
      }
      
      public function get unlockOverrideForcedChecks() : String
      {
         return this.m_xml.@unlockOverrideForcedChecks.toString().length ? this.m_xml.@unlockOverrideForcedChecks.toString() : null;
      }
      
      public function get components() : String
      {
         return String(this.m_xml.components);
      }
      
      public function get warehouseTiersAsArray() : Array
      {
         var _loc1_:XMLList = null;
         var _loc2_:String = null;
         var _loc3_:Array = null;
         _loc3_ = [];
         _loc1_ = this.m_xml.warehouseTiers.tier;
         if(_loc1_.length() > 0)
         {
            for each(_loc2_ in _loc1_)
            {
               _loc3_.push(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public function get warehouseUpgradesAsArray() : Array
      {
         var _loc1_:XMLList = null;
         var _loc2_:String = null;
         var _loc3_:Array = [];
         _loc1_ = this.m_xml.warehouseUpgrades.upgrade;
         if(_loc1_.length() > 0)
         {
            for each(_loc2_ in _loc1_)
            {
               _loc3_.push(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public function get type() : String
      {
         return this.m_xml.@type;
      }
      
      public function get subType() : String
      {
         return this.m_xml.@subtype;
      }
      
      public function get notifyPlacementCancel() : Boolean
      {
         return Boolean(this.m_xml.@notifyPlacementCancel) && this.m_xml.@notifyPlacementCancel == "true";
      }
      
      public function get villain() : String
      {
         return this.m_xml.@villain ? this.m_xml.@villain : "";
      }
      
      public function get terrainType() : String
      {
         return this.m_xml.terrainType;
      }
      
      public function get canBuildOn() : String
      {
         return this.m_xml.canBuildOn;
      }
      
      public function get makesDepotStorableItems() : Boolean
      {
         return this.m_xml.@makesDepotStorableItems == "true";
      }
      
      public function get canBuildOnObjectType() : ObjectType
      {
         if(this.canBuildOn.length > 0)
         {
            return new ObjectType(this.canBuildOn);
         }
         return null;
      }
      
      public function get hp() : int
      {
         if(this.m_xml.hp)
         {
            return int(this.m_xml.hp);
         }
         return 1;
      }
      
      public function get energyYield() : int
      {
         if(this.m_xml.energyYield)
         {
            return int(this.m_xml.energyYield);
         }
         return 0;
      }
      
      public function get manaYield() : int
      {
         if(this.m_xml.manaYield)
         {
            return int(this.m_xml.manaYield);
         }
         return 0;
      }
      
      public function get ammoYield() : int
      {
         if(this.m_xml.ammoYield)
         {
            return int(this.m_xml.ammoYield);
         }
         return 0;
      }
      
      public function get uiHidden() : Boolean
      {
         return this.m_xml.@uiHidden != undefined && this.m_xml.@uiHidden == true;
      }
      
      public function get buyable() : Boolean
      {
         return this.m_xml.@buyable != undefined && this.m_xml.@buyable == true;
      }
      
      public function get isBlueDevil() : Boolean
      {
         return this.m_xml.@bluedevil != undefined && this.m_xml.@bluedevil == true;
      }
      
      public function get isFlamingUnit() : Boolean
      {
         return this.m_xml.@flaming != undefined && this.m_xml.@flaming == true;
      }
      
      public function get isWhiteUnit() : Boolean
      {
         return this.m_xml.@whiteUnit != undefined && this.m_xml.@whiteUnit == true;
      }
      
      public function get directPay() : Boolean
      {
         return this.m_xml.directPay != undefined;
      }
      
      public function get directPayCode() : String
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc1_:String = null;
         if(this.directPay)
         {
            if(this.m_xml.directPay.@priceExperiment != undefined)
            {
               _loc2_ = this.m_xml.directPay.@priceExperiment.toString();
               if(_loc2_.length != 0)
               {
                  _loc3_ = ExperimentsManager.instance.getExperimentVariant(_loc2_);
                  switch(_loc3_)
                  {
                     case 0:
                        _loc1_ = this.m_xml.directPay.@codev0;
                        break;
                     case 1:
                        _loc1_ = this.m_xml.directPay.@codev1;
                        break;
                     case 2:
                        _loc1_ = this.m_xml.directPay.@codev2;
                        break;
                     case 3:
                        _loc1_ = this.m_xml.directPay.@codev3;
                        break;
                     case 4:
                        _loc1_ = this.m_xml.directPay.@codev4;
                        break;
                     case 5:
                        _loc1_ = this.m_xml.directPay.@codev5;
                  }
               }
            }
            else
            {
               _loc1_ = this.m_xml.directPay.@code;
            }
         }
         if(_loc1_ == null || _loc1_.length == 0)
         {
            throw new Error("GameItem.directPayCode() failed!");
         }
         return _loc1_;
      }
      
      public function get directPayPrice() : Number
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc1_:Number = -1;
         if(this.directPay)
         {
            if(this.m_xml.directPay.@priceExperiment != undefined)
            {
               _loc2_ = this.m_xml.directPay.@priceExperiment.toString();
               if(_loc2_.length != 0)
               {
                  _loc3_ = ExperimentsManager.instance.getExperimentVariant(_loc2_);
                  switch(_loc3_)
                  {
                     case 0:
                        _loc1_ = Number(this.m_xml.directPay.@pricev0);
                        break;
                     case 1:
                        _loc1_ = Number(this.m_xml.directPay.@pricev1);
                        break;
                     case 2:
                        _loc1_ = Number(this.m_xml.directPay.@pricev2);
                        break;
                     case 3:
                        _loc1_ = Number(this.m_xml.directPay.@pricev3);
                        break;
                     case 4:
                        _loc1_ = Number(this.m_xml.directPay.@pricev4);
                        break;
                     case 5:
                        _loc1_ = Number(this.m_xml.directPay.@pricev5);
                  }
               }
            }
            else
            {
               _loc1_ = Number(this.m_xml.directPay.@price);
            }
         }
         if(_loc1_ < 0)
         {
            throw new Error("GameItem.directPayPrice() failed!");
         }
         return _loc1_;
      }
      
      public function get directPayPhylum() : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc1_:String = null;
         if(this.directPay)
         {
            _loc2_ = 0;
            if(this.m_xml.directPay.@priceExperiment != undefined)
            {
               _loc3_ = this.m_xml.directPay.@priceExperiment.toString();
               if(_loc3_.length != 0)
               {
                  _loc2_ = ExperimentsManager.instance.getExperimentVariant(_loc3_);
               }
            }
            _loc1_ = "in_game_v" + _loc2_ + "_code" + this.directPayCode;
         }
         if(_loc1_ == null || _loc1_.length == 0)
         {
            throw new Error("GameItem.directPayPhylum() failed!");
         }
         return _loc1_;
      }
      
      public function get directPayCongratsPopup() : Class
      {
         if(this.directPay && this.m_xml.directPay.@congratsPopup != undefined)
         {
            return getDefinitionByName("displays.popups." + this.m_xml.directPay.@congratsPopup.toString()) as Class;
         }
         throw new Error("GameItem.directPayCongratsPopup() failed!");
      }
      
      public function get gatepurchase() : Boolean
      {
         var _loc1_:String = this.m_xml.@gatepurchase.toString();
         return _loc1_.length == 0 || _loc1_ == "true";
      }
      
      public function get zpoints() : Boolean
      {
         return this.m_xml.@zpoints != undefined && this.m_xml.@zpoints == true;
      }
      
      public function get unlockCost() : int
      {
         var _loc1_:int = int(this.m_xml.unlockCost);
         if(_loc1_ > 0)
         {
            return _loc1_;
         }
         var _loc2_:int = EarlyUnitUnlockManager.instance.earlyUnlockCost(this);
         if(_loc2_ > 0)
         {
            return _loc2_;
         }
         return -1;
      }
      
      public function get builtFromStructure() : GameItem
      {
         if(this.m_xml.referenceValues.@referenceName != undefined)
         {
            return ZGlobal.gameSettings.getItemByName(this.m_xml.referenceValues.@referenceName.toString(),GameItem) as GameItem;
         }
         return null;
      }
      
      public function canBeUnlocked() : Boolean
      {
         return this.unlockCost > 0 && !ZGlobal.player.isItemUnlocked(this.code);
      }
      
      public function get contractCost() : int
      {
         var _loc1_:int = UnitContractUnlockManager.instance.unlockContractCost(this);
         if(_loc1_ > 0)
         {
            return _loc1_;
         }
         return -1;
      }
      
      public function canBuyContract() : Boolean
      {
         return this.contractCost > 0 && !ZGlobal.player.hasPurchasedContract(this.code);
      }
      
      public function get marketPrice() : Number
      {
         return uint(this.m_xml.marketPrice);
      }
      
      public function get action() : String
      {
         var _loc1_:String = null;
         if(this.m_xml.action)
         {
            _loc1_ = this.m_xml.action;
         }
         return _loc1_;
      }
      
      public function get transform() : String
      {
         var _loc1_:String = null;
         if(this.m_xml.action)
         {
            _loc1_ = this.m_xml.transform;
         }
         return _loc1_;
      }
      
      public function get limit() : int
      {
         var _loc1_:int = LIMIT_UNLIMITED;
         if(this.m_xml.@limit != undefined)
         {
            _loc1_ = int(this.m_xml.@limit);
         }
         return _loc1_;
      }
      
      public function get categoryLimitName() : String
      {
         var _loc1_:String = CATEGORY_LIMIT_UNDEFINED;
         if(this.m_xml.@categoryLimit != undefined)
         {
            _loc1_ = this.m_xml.@categoryLimit;
         }
         return _loc1_;
      }
      
      public function get crewTendTemplate() : String
      {
         if(this.m_xml.@crewTendTemplate.toString().length)
         {
            return this.m_xml.@crewTendTemplate.toString();
         }
         return null;
      }
      
      public function get sortPriority() : int
      {
         var _loc1_:int = 0;
         if(this.m_xml["@sortPriority"])
         {
            _loc1_ = Number(this.m_xml["@sortPriority"]);
         }
         return _loc1_;
      }
      
      public function get className() : String
      {
         var _loc1_:String = null;
         if(this.m_xml["@className"])
         {
            _loc1_ = this.m_xml["@className"];
         }
         return _loc1_;
      }
      
      public function get actionText() : String
      {
         var _loc1_:String = null;
         if(this.m_xml.actionText)
         {
            _loc1_ = this.m_xml.actionText;
         }
         return _loc1_;
      }
      
      public function get icon() : String
      {
         return "";
      }
      
      public function get cost() : int
      {
         var _loc1_:int = 0;
         if(this.m_xml.cost.@coins != undefined)
         {
            _loc1_ = int(this.m_xml.cost.attribute("coins"));
         }
         return _loc1_;
      }
      
      public function get multiSell() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.m_xml.@multisell != undefined)
         {
            _loc1_ = Boolean(this.m_xml.attribute("multisell"));
         }
         return _loc1_;
      }
      
      public function get resourceType() : String
      {
         var _loc1_:String = null;
         if(this.m_xml.@resourceType != undefined)
         {
            _loc1_ = this.m_xml.@resourceType;
         }
         return _loc1_;
      }
      
      public function get resourceYield() : int
      {
         return int(this.m_xml.resourceYield);
      }
      
      public function get itemCosts() : Dictionary
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:XMLList = this.m_xml.itemcost.attributes();
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.name().toString();
            _loc1_[_loc4_] = this.getItemCostAmount(int(_loc3_));
            _loc1_[_loc4_] = WorldUpgradeManager.instance.getModifiedCost(WorldUpgradeManager.instance.getUpgradesByCode(this.code),_loc1_[_loc4_]);
         }
         return _loc1_;
      }
      
      public function get resourceCosts() : Array
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc1_:Array = new Array();
         var _loc2_:XMLList = this.m_xml.cost.attributes();
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.name().toString();
            if(_loc4_ != ResourceUpdatedEvent.CASH)
            {
               _loc5_ = ItemCostOverridesManager.instance.getOverride(_loc4_,_loc3_.toString(),this);
               _loc6_ = this.getResourceCostAmount(int(_loc5_));
               _loc7_ = WorldUpgradeManager.instance.getModifiedCost(WorldUpgradeManager.instance.getUpgradesByCode(this.code),_loc6_);
               _loc1_.push(WorldResourceManager.instance.createResource(_loc4_,-_loc7_));
            }
         }
         return _loc1_;
      }
      
      public function getGateFailureString(param1:BitArray) : String
      {
         var _loc2_:String = null;
         if(param1.isBitSet(Player.GATE_FAILURE_CAMPAIGN))
         {
            _loc2_ = ZLoc.t("Dialogs","LevelCampaignRequired",{"num":this.requiredLevel});
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_LEVEL))
         {
            _loc2_ = ZLoc.t("Dialogs","LevelRequired",{"num":this.requiredLevel});
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_WORKERS))
         {
            _loc2_ = ZLoc.t("Dialogs","WorkersRequired",{"num":this.requiredWorkers});
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_QUEST))
         {
            _loc2_ = ZLoc.t("Dialogs","QuestRequired");
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_NEIGHBORS))
         {
            _loc2_ = ZLoc.t("Dialogs","NeighborsRequired",{
               "num":this.requiredNeighbors,
               "neighbor":ZGameUtils.ZlocTk("Objects","neighbor","",this.requiredNeighbors)
            });
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_EXCEEDS_POPULATION))
         {
            _loc2_ = ZLoc.t("Dialogs","ExceedsPopulationCap");
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_EXCEEDS_LIMIT_IN_INVENTORY))
         {
            _loc2_ = ZLoc.t("Dialogs","ExceedsLimitCap_InInventory");
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_EXCEEDS_LIMIT))
         {
            _loc2_ = ZLoc.t("Dialogs","ExceedsLimitCap");
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_CONTRACT_LOCKED))
         {
            _loc2_ = ZLoc.t("Dialogs","ContractUnlockRequired");
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_DOMINANCE))
         {
            _loc2_ = ZLoc.t("Dialogs","DominanceRankRequired",{"num":this.requiredDominanceRank});
         }
         else if(param1.isBitSet(Player.GATE_FAILURE_TITAN_LAB))
         {
            _loc2_ = ZLoc.t("Dialogs","MechLabActive");
         }
         return _loc2_;
      }
      
      private function get priceCurveEnabled() : Boolean
      {
         if(!PriceTestManager.instance.priceCurveEnabled)
         {
            return false;
         }
         var _loc1_:Array = ZGlobal.gameSettings.getString("priceCurveSubtypes","").split(",");
         if(_loc1_.indexOf(this.subType) < 0)
         {
            return false;
         }
         return true;
      }
      
      protected function getResourceCostAmount(param1:int) : int
      {
         var _loc2_:Number = NaN;
         if(!this.priceCurveEnabled && this.m_xml.costMultiplier != undefined)
         {
            _loc2_ = Number(this.m_xml.costMultiplier.@mult);
            param1 = this.calculateCostWithMultiplier(param1,_loc2_,this.m_xml.costMultiplier.@max);
         }
         else
         {
            switch(this.subType)
            {
               case SUBTYPE_DECORATION:
                  param1 = this.calculateCostWithMultiplier(param1,PriceTestManager.instance.costMultiplierByType("decorationcostscalar"),100,true);
                  break;
               case SUBTYPE_PRODUCTION:
                  param1 = this.calculateCostWithMultiplier(param1,PriceTestManager.instance.costMultiplierByType("industrybuildingcostscalar"),100,true);
                  break;
               case SUBTYPE_RESIDENTIAL:
                  param1 = this.calculateCostWithMultiplier(param1,PriceTestManager.instance.costMultiplierByType("housecostscalar"),100,true);
                  break;
               case SUBTYPE_UNIT_AIR:
               case SUBTYPE_UNIT_ARMY:
               case SUBTYPE_UNIT_NAVY:
                  param1 = this.calculateCostWithMultiplier(param1,PriceTestManager.instance.costMultiplierByType("unitcostscalar"),100,true);
            }
         }
         return param1;
      }
      
      protected function calculateCostWithMultiplier(param1:int, param2:Number, param3:Number, param4:Boolean = false) : int
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc5_:int = param1;
         var _loc6_:* = WorldObjectManager.instance.getNumberObjectsWithCode(this.code);
         if(param2 != 1)
         {
            _loc7_ = 1;
            while(_loc6_ > 0)
            {
               _loc7_ *= param2;
               _loc6_--;
            }
            _loc5_ = int(_loc7_ * param1);
         }
         else if(this.priceCurveEnabled && Boolean(_loc6_))
         {
            _loc8_ = ZGlobal.gameSettings.getNumber("priceCurveExponent",0.7);
            _loc9_ = Math.pow(_loc6_,_loc8_);
            _loc5_ = int(_loc9_ * param1);
         }
         return int(Math.min(_loc5_,param4 ? param1 * param3 : param3));
      }
      
      protected function getItemCostAmount(param1:int) : int
      {
         return param1;
      }
      
      public function usesCash() : Boolean
      {
         if(this.m_xml.cost.@cash != undefined)
         {
            return true;
         }
         return false;
      }
      
      public function usesCashOnly() : Boolean
      {
         var _loc1_:Array = null;
         var _loc2_:WorldResource = null;
         if(this.usesCash())
         {
            _loc1_ = this.resourceCosts;
            for each(_loc2_ in _loc1_)
            {
               if(_loc2_.amount != 0)
               {
                  return false;
               }
            }
            return true;
         }
         return false;
      }
      
      public function get multiplace() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.m_xml.@multiplace != undefined)
         {
            _loc1_ = this.m_xml.attribute("multiplace") == "true";
         }
         return _loc1_;
      }
      
      public function get cash() : int
      {
         return this.getModifiedCash(1);
      }
      
      public function getModifiedCash(param1:Number, param2:Number = 1, param3:String = null) : int
      {
         var _loc6_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc4_:int = UnitPriceExperimentManager.instance.getUnitPrice(this);
         if(_loc4_ == 0)
         {
            _loc4_ = this.xmlCash;
         }
         var _loc5_:Number = Math.ceil(Number(_loc4_) * param1);
         var _loc7_:Number = PriceTestManager.instance.costMultiplierByItem(this);
         var _loc8_:Number = 1;
         var _loc9_:Number = 1;
         var _loc10_:Number = 1;
         if(param3 != null)
         {
            _loc8_ = PriceTestManager.instance.costMultiplierByType(param3);
         }
         if(ZGameTimeUtil.instance.isLimitedEdition(this.xml))
         {
            _loc11_ = ZGlobal.gameSettings.getLEUnitDiscount(this);
            if(_loc11_ > 0)
            {
               _loc9_ = 1 - _loc11_;
            }
         }
         if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(this.code))
         {
            _loc12_ = LEUnitDiscountManager.instance.getLEOverrideDiscount(this.code);
            if(_loc12_ > 0)
            {
               _loc10_ = 1 - _loc12_;
            }
         }
         return Math.ceil(_loc5_ * _loc7_ * _loc8_ * _loc9_ * _loc10_ * param2);
      }
      
      public function get xmlCash() : Number
      {
         return this.m_xml.cost.attribute("cash");
      }
      
      public function get xmlMasteryTokenCost() : Number
      {
         return this.m_xml.masteryTokenCost;
      }
      
      public function get masteryTokenCost() : Number
      {
         return this.xmlMasteryTokenCost ? this.xmlMasteryTokenCost : 0;
      }
      
      public function get count() : int
      {
         var _loc1_:int = 1;
         if(this.m_xml.count)
         {
            _loc1_ = int(this.m_xml.count);
         }
         return _loc1_;
      }
      
      public function get plantXp() : int
      {
         var _loc1_:int = 0;
         if(this.m_xml.plantXp)
         {
            _loc1_ = int(this.m_xml.plantXp);
         }
         return _loc1_;
      }
      
      public function get allowDelete() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.m_xml)
         {
            _loc1_ = this.m_xml.disallowDelete != 1;
         }
         return _loc1_;
      }
      
      public function get sellPrice() : int
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         if(this.cost > 0)
         {
            _loc1_ = ZGlobal.gameSettings.getNumber("sellBackRatio");
            return Math.floor(this.cost * _loc1_);
         }
         _loc2_ = this.cash;
         if(_loc2_ > 0)
         {
            _loc3_ = ZGlobal.gameSettings.getNumber("cashCoinsBackRatio");
            return Math.floor(_loc2_ * _loc3_);
         }
         return 0;
      }
      
      public function get hasContentTypes() : Boolean
      {
         return Boolean(this.m_xml.storageType) && Boolean(this.m_xml.storageType.itemName) && this.m_xml.storageType.itemName.length() > 0;
      }
      
      public function get storageClass() : String
      {
         var _loc1_:String = "";
         if(Boolean(this.m_xml.storageType) && this.m_xml.storageType.@itemClass != "")
         {
            _loc1_ = this.m_xml.storageType.@itemClass;
         }
         return _loc1_;
      }
      
      public function get code() : String
      {
         return this.m_xml ? this.m_xml.@code.toString() : "";
      }
      
      public function get isAdvExpUnit() : String
      {
         return this.m_xml ? this.m_xml.@isAdvExpUnit.toString() : "";
      }
      
      public function get sizeX() : Number
      {
         return Math.max(this.m_xml.sizeX,1);
      }
      
      public function get sizeY() : Number
      {
         return Math.max(this.m_xml.sizeY,1);
      }
      
      public function get sizeZ() : Number
      {
         return Math.max(this.m_xml.sizeZ,0.1);
      }
      
      public function zeroSize() : Boolean
      {
         return this.m_xml.sizeX == 0 && this.m_xml.sizeY == 0;
      }
      
      public function get defenseRangeX() : Number
      {
         if(this.m_defenseRangeX == -1)
         {
            this.m_defenseRangeX = Math.max(this.m_xml.defenseRangeX,0);
         }
         return this.m_defenseRangeX;
      }
      
      public function get defenseRangeY() : Number
      {
         if(this.m_defenseRangeY == -1)
         {
            this.m_defenseRangeY = Math.max(this.m_xml.defenseRangeY,0);
         }
         return this.m_defenseRangeY;
      }
      
      public function get imageScale() : Number
      {
         return this.m_xml.imageScale;
      }
      
      public function getSubtitle() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = "";
         if(this.m_xml.subtitle)
         {
            _loc2_ = WorldResourceManager.instance.getResourceFriendlyNameFromIndex(ZGlobal.hostPlayer.rareResourceType,GameItem.SENTENCE_FRIENDLYNAME,false);
            _loc1_ = ZGameUtils.ZlocT("Dialogs",this.m_xml.subtitle.@key.toString(),{"rare":_loc2_});
         }
         return _loc1_;
      }
      
      public function getSubtitle1() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = "";
         if(this.m_xml.subtitle1)
         {
            _loc2_ = WorldResourceManager.instance.getResourceFriendlyNameFromIndex(ZGlobal.hostPlayer.rareResourceType,GameItem.SENTENCE_FRIENDLYNAME,false);
            _loc1_ = ZGameUtils.ZlocT("Dialogs",this.m_xml.subtitle1.@key.toString(),{"rare":_loc2_});
         }
         return _loc1_;
      }
      
      public function getCollisionData(param1:int = 0) : Array
      {
         return this.m_collisionData[param1];
      }
      
      public function get placementArray() : Array
      {
         var _loc1_:String = this.m_xml.placement;
         if(_loc1_.length > 0)
         {
            return _loc1_.split(",");
         }
         return null;
      }
      
      public function getCollisionDataIndexByName(param1:String) : int
      {
         var _loc2_:int = -1;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_xml.collision.length())
         {
            if(this.m_xml.collision[_loc3_].@name == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getNumberOfParts() : int
      {
         return this.m_xml.numParts;
      }
      
      public function getProducesAmount(param1:String) : Number
      {
         var defineList:XMLList = null;
         var define:XML = null;
         var valueParts:Array = null;
         var referenceName:String = param1;
         if(this.m_xml.referenceValues)
         {
            defineList = this.m_xml.referenceValues.(@referenceName == referenceName).define;
            for each(define in defineList)
            {
               if(define.@produces != undefined)
               {
                  valueParts = define[0].@value.split("|");
                  return ZGlobal.isVisiting() && valueParts.length > 1 ? Number(valueParts[1]) : Number(valueParts[0]);
               }
            }
         }
         return 0;
      }
      
      public function getProducesCode(param1:String) : String
      {
         var defineList:XMLList = null;
         var define:XML = null;
         var referenceName:String = param1;
         if(this.m_xml.referenceValues)
         {
            defineList = this.m_xml.referenceValues.(@referenceName == referenceName).define;
            for each(define in defineList)
            {
               if(define.@produces != undefined)
               {
                  return define[0].@value;
               }
            }
         }
         return null;
      }
      
      public function getMatureDuration(param1:String) : Number
      {
         var defineList:XMLList = null;
         var define:XML = null;
         var duration:Number = NaN;
         var referenceName:String = param1;
         if(this.m_xml.referenceValues.length() > 0)
         {
            defineList = referenceName ? this.m_xml.referenceValues.(@referenceName == referenceName).define : this.m_xml.referenceValues.define;
         }
         else if(this.m_xml.stateMachineValues.length() > 0)
         {
            defineList = this.m_xml.stateMachineValues.define;
         }
         for each(define in defineList)
         {
            if(define.@maturingDuration != undefined)
            {
               duration = ZGameTimeUtil.instance.parseTimeAsSeconds(define[0].@value,0);
               return WorldUpgradeManager.instance.getModifiedDuration(WorldUpgradeManager.instance.getUpgradesByCode(this.code),duration);
            }
         }
         return 0;
      }
      
      public function get purchaseXp() : int
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         if(this.m_xml.stateMachineValues.length() > 0)
         {
            _loc1_ = this.m_xml.stateMachineValues.define;
            for each(_loc2_ in _loc1_)
            {
               if(_loc2_.@purchaseXp != undefined)
               {
                  return parseInt(_loc2_[0].@value);
               }
            }
         }
         return 0;
      }
      
      public function get foodUsed() : int
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         if(this.m_xml.stateMachineValues.length() > 0)
         {
            _loc1_ = this.m_xml.stateMachineValues.define;
            for each(_loc2_ in _loc1_)
            {
               if(_loc2_.@foodUsed != undefined)
               {
                  return parseInt(_loc2_[0].@value);
               }
            }
         }
         return 0;
      }
      
      public function get coinsYield() : int
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         if(this.m_xml.stateMachineValues.length() > 0)
         {
            _loc1_ = this.m_xml.stateMachineValues.define;
            for each(_loc2_ in _loc1_)
            {
               if(_loc2_.@coinsYield != undefined)
               {
                  return parseInt(_loc2_[0].@value);
               }
            }
         }
         return 0;
      }
      
      public function getWonderDefaultParts() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         if(this.m_xml.defaultConfiguration)
         {
            _loc1_ = new Array();
            _loc2_ = this.m_xml.defaultConfiguration.config;
            for each(_loc3_ in _loc2_)
            {
               _loc1_.push(_loc3_.toString());
            }
            _loc1_.sort();
            return _loc1_;
         }
         return null;
      }
      
      public function getWonderImages(param1:Array) : Array
      {
         var value:String = null;
         var valueParts:Array = null;
         var part:XMLList = null;
         var itemImage:ItemImage = null;
         var cat:XMLList = null;
         var off:Point = null;
         var colorId:int = 0;
         var color:XMLList = null;
         var partIds:Array = param1;
         var images:Array = new Array();
         for each(value in partIds)
         {
            valueParts = value.split(":");
            if(valueParts.length >= 2)
            {
               part = this.getWonderPart(valueParts[0],valueParts[1]);
               if(Boolean(part) && part.@image.length() > 0)
               {
                  itemImage = new ItemImage();
                  itemImage.url = ZGlobal.getAssetURL(part.@image.toString());
                  if(part.@rootPoint.length() > 0)
                  {
                     off = StringUtils.parsePoint(part.@rootPoint);
                     itemImage.offset = new Pt(off.x,off.y);
                  }
                  else
                  {
                     itemImage.offset = new Pt(0,0);
                  }
                  if(part.@anchorPoint.length() > 0)
                  {
                     off = StringUtils.parsePoint(part.@anchorPoint);
                     itemImage.anchor = new Pt(off.x,off.y);
                  }
                  else
                  {
                     itemImage.anchor = new Pt(0,0);
                  }
                  if(part.@mask.length() > 0)
                  {
                     itemImage.maskUrl = ZGlobal.getAssetURL(part.@mask.toString());
                  }
                  if(valueParts[2])
                  {
                     colorId = parseInt(valueParts[2]);
                     color = ZGlobal.gameSettings.getXML().colors.color.(@id == colorId);
                     itemImage.color = color.@value;
                  }
                  cat = this.getWonderCategory(valueParts[0]);
                  itemImage.drawOrderIndex = parseInt(cat.@drawIndex);
                  images.push(itemImage);
               }
            }
         }
         return images;
      }
      
      public function getWonderCategories() : XMLList
      {
         if(this.m_xml.parts.length() > 0 && this.m_xml.parts.category.length() > 0)
         {
            return this.m_xml.parts.category;
         }
         return null;
      }
      
      public function getWonderPart(param1:String, param2:String) : XMLList
      {
         var category:XMLList = null;
         var part:XMLList = null;
         var categoryId:String = param1;
         var partId:String = param2;
         if(this.m_xml.parts.length() > 0 && this.m_xml.parts.category.length() > 0)
         {
            category = this.m_xml.parts.category.(@id == categoryId);
            if(category.length() > 0 && category.part.length() > 0)
            {
               part = category.part.(@id == partId);
               if(part)
               {
                  return part;
               }
            }
         }
         return null;
      }
      
      public function getWonderCategory(param1:String) : XMLList
      {
         var category:XMLList = null;
         var categoryId:String = param1;
         if(this.m_xml.parts.length() > 0 && this.m_xml.parts.category.length() > 0)
         {
            category = this.m_xml.parts.category.(@id == categoryId);
            if(category.length() > 0)
            {
               return category;
            }
         }
         return null;
      }
      
      public function get xPercent() : Number
      {
         return this.m_xml.position.@xPercent;
      }
      
      public function get yPercent() : Number
      {
         return this.m_xml.position.@yPercent;
      }
      
      public function get tooltipKey() : String
      {
         var _loc1_:String = "";
         if(this.m_xml.tooltip)
         {
            return this.m_xml.tooltip.@key.toString();
         }
         return _loc1_;
      }
      
      public function givesReward() : Boolean
      {
         return this.m_xml.@dailyReward.toString() == "true";
      }
      
      public function get tooltipType() : String
      {
         var _loc1_:String = null;
         if(Boolean(this.m_xml.tooltip) && this.m_xml.tooltip.@type != undefined)
         {
            _loc1_ = this.m_xml.tooltip.@type.toString();
            if(_loc1_ == DECORATION_MEANINGFUL_TOOLTIP && !DecorationsManager.instance.enabled)
            {
               _loc1_ = NO_TOOLTIP;
            }
            if(_loc1_ == DEFAULT_TOOLTIP || _loc1_ == HOUSE_TOOLTIP || _loc1_ == UNIT_TOOLTIP || _loc1_ == SUPPORT_UNIT_TOOLTIP || _loc1_ == CONSUMABLE_TOOLTIP || _loc1_ == DECORATION_TOOLTIP || _loc1_ == DECORATION_MEANINGFUL_TOOLTIP || _loc1_ == BASIC_TOOLTIP || _loc1_ == STORE_RESOURCE_TOOLTIP || _loc1_ == ENERGY_TOOLTIP || _loc1_ == AMMO_TOOLTIP || _loc1_ == MANA_TOOLTIP || _loc1_ == EXPANSION_TOOLTIP || _loc1_ == SPARSE_TOOLTIP || _loc1_ == CIVIC_TOOLTIP || _loc1_ == TITAN_TOOLTIP)
            {
               return _loc1_;
            }
         }
         return NO_TOOLTIP;
      }
      
      public function get placeXp() : int
      {
         var _loc1_:Number = 0;
         if(this.m_xml.placeXp.length() > 0)
         {
            _loc1_ = parseInt(this.m_xml.placeXp);
         }
         return _loc1_;
      }
      
      public function get speedupCode() : String
      {
         return this.m_xml.attribute("speedUp").toString();
      }
      
      private function getItemIndex(param1:String) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cachedImages.length)
         {
            _loc3_ = this.m_cachedImages[_loc2_];
            if(_loc3_.name == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function isValidUnitItem() : Boolean
      {
         return this.type == TYPE_BUILDABLE && (this.subType == UnitItem.ARMY || this.subType == UnitItem.NAVY || this.subType == UnitItem.AIR);
      }
      
      public function isResourceItem() : Boolean
      {
         return this.type == GameItem.TYPE_RESOURCE && this.subType == GameItem.SUBTYPE_RESOURCE;
      }
      
      public function getContractImageURL(param1:int) : String
      {
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         if(this.m_xml.contractImages)
         {
            _loc2_ = this.m_xml.contractImages.resource;
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_.@index == param1)
               {
                  return ZGlobal.getAssetURL(_loc3_.@url);
               }
            }
         }
         return null;
      }
      
      public function isMultiContract() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.m_xml.@multicontract != undefined)
         {
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      public function shouldExitContractMode() : Boolean
      {
         if(this.m_xml.@exitContractMode != undefined)
         {
            return true;
         }
         return false;
      }
      
      public function get contractCursor() : String
      {
         return this.m_xml.cursor;
      }
      
      public function isUnit() : Boolean
      {
         if(this.type == "Buildable")
         {
            switch(this.subType)
            {
               case UnitItem.ARMY:
               case UnitItem.NAVY:
               case UnitItem.AIR:
                  return true;
            }
         }
         return false;
      }
      
      public function isAreaImmunityBuilding() : Boolean
      {
         if(this.type == "building" || this.type == "Buildable")
         {
            if(this.m_xml.@area_immunity != undefined)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getCrewTemplateName(param1:Boolean = false) : String
      {
         if(!param1)
         {
            if(this.m_xml.@crewTemplate.toString().length > 0)
            {
               return this.m_xml.@crewTemplate.toString();
            }
         }
         else if(this.m_xml.@rebuildCrewTemplate.toString().length > 0)
         {
            return this.m_xml.@rebuildCrewTemplate.toString();
         }
         return null;
      }
      
      public function usePavingQuadComponent() : Boolean
      {
         if(this.terrainType == BuildManager.instance.PAVING_STR)
         {
            return true;
         }
         return false;
      }
      
      public function isNewItem() : Boolean
      {
         return this.m_xml.@newItem == "true";
      }
      
      public function extensionTimeSlots() : int
      {
         var _loc1_:int = 0;
         if(Boolean(this.m_xml.extensionTimeInfo) && this.m_xml.extensionTimeInfo.@maxSlots != undefined)
         {
            _loc1_ = parseInt(this.m_xml.extensionTimeInfo.@maxSlots);
         }
         return _loc1_;
      }
      
      public function extensionTimeItem() : String
      {
         var _loc1_:String = null;
         if(Boolean(this.m_xml.extensionTimeInfo) && this.m_xml.extensionTimeInfo.@item != undefined)
         {
            _loc1_ = this.m_xml.extensionTimeInfo.@item;
         }
         return _loc1_;
      }
      
      public function extensionTimeSeconds() : Number
      {
         var _loc1_:Number = 0;
         if(this.m_xml.extensionTime)
         {
            _loc1_ = ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_xml.extensionTime,12 * 60 * 60);
         }
         return _loc1_;
      }
      
      public function get isDecorationSource() : Boolean
      {
         return this.m_xml.decoration != undefined;
      }
      
      public function get warehouseType() : String
      {
         if(this.m_xml.@warehouseType != undefined)
         {
            return this.m_xml.@warehouseType.toString();
         }
         return "";
      }
      
      public function get researchDialogBehavior() : String
      {
         if(this.m_xml.@researchDialogBehavior != undefined)
         {
            return this.m_xml.@researchDialogBehavior.toString();
         }
         return "";
      }
      
      public function get forceAnnoyingInventoryDialog() : Boolean
      {
         if(this.m_xml.@forceAnnoyingInventoryDialog != undefined)
         {
            return this.m_xml.@forceAnnoyingInventoryDialog.toString() == "true";
         }
         return false;
      }
      
      public function get DispalyGP() : Boolean
      {
         if(this.m_xml.@DisplayGP != undefined)
         {
            return this.m_xml.@DisplayGP.toString() == "true";
         }
         return false;
      }
      
      public function isMegaBuilding() : Boolean
      {
         if(this.m_xml.@mega != undefined)
         {
            return this.m_xml.@mega;
         }
         return false;
      }
      
      public function isResourceOrder() : Boolean
      {
         if(this.m_xml.@resourceOrder != undefined)
         {
            return this.m_xml.@resourceOrder;
         }
         return false;
      }
      
      public function set resourceName(param1:String) : void
      {
         this.m_resourceType = param1;
      }
      
      public function get resourceName() : String
      {
         return this.m_resourceType;
      }
      
      public function isSuperOre() : Boolean
      {
         var _loc1_:String = this.m_xml.@superore.toString();
         return _loc1_.length > 0;
      }
      
      public function get megaseries() : String
      {
         if(this.m_xml.@megaseries)
         {
            return this.m_xml.@megaseries;
         }
         return null;
      }
      
      public function get ignoreExpnasion() : Boolean
      {
         return true;
      }
      
      public function ignoreExpansionEffects() : Boolean
      {
         if(this.m_xml.@ignoreExpansionEffects != undefined && this.m_xml.@ignoreExpansionEffects == "true")
         {
            return true;
         }
         return false;
      }
      
      public function isRaffleBuilding() : Boolean
      {
         if(this.m_xml.@raffleBuilding != undefined)
         {
            return true;
         }
         return false;
      }
   }
}

