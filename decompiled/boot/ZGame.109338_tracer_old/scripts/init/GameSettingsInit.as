package init
{
   import Cache.Init.ZCacheInit;
   import Engine.Init.InitializationAction;
   import Engine.Managers.AssetUrlManager;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.gameobjects.IItem;
   import core.gameobjects.ManaItem;
   import core.gameobjects.UnitItem;
   import core.managers.DebugManager;
   import core.managers.ExperimentsManager;
   import core.managers.FXManager.FXManager;
   import core.managers.InventoryList;
   import core.managers.ItemCostOverridesManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.MegaseriesManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.ZRTManager;
   import core.managers.animationManager.AnimationManager;
   import core.managers.campaignManager.CampaignManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.formationManager.FormationManager;
   import core.managers.miniGameManager.MiniGameManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.resourceContractOverridesManager.ResourceContractOverridesManager;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.unitTestManager.UnitTestManager;
   import core.managers.weaponManager.WeaponManager;
   import core.managers.worldEventManager.WorldEventManager;
   import core.player.Player;
   import core.player.questTrees.PlayerQuestTrees;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import resources.PostLoadManager;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.BitArray;
   import utils.ZGameTimeUtil;
   import zlabs.ZConfig;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.Resource;
   import zlabs.resource.XMLResource;
   
   public class GameSettingsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "GameSettingsInit";
      
      public static const NUM_CREW_SLOTS:int = 12;
      
      private static const MOTD_ICON_BACKLOG_MAX:int = 3;
      
      private static var m_giftableBuildableParts:Array = new Array({
         "item":"BuildingPart01",
         "experiment":"none"
      },{
         "item":"BuildingPart02",
         "experiment":"none"
      },{
         "item":"BuildingPart03",
         "experiment":"none"
      },{
         "item":"BuildingPart04",
         "experiment":"none"
      },{
         "item":"BuildingPart05",
         "experiment":"none"
      },{
         "item":"BuildingPart06",
         "experiment":"none"
      },{
         "item":"BuildingPart07",
         "experiment":"none"
      },{
         "item":"BuildingPart289",
         "experiment":"none"
      },{
         "item":"BuildingPart286",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart280",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart287",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart285",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart281",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart284",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart282",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      },{
         "item":"BuildingPart283",
         "experiment":"empire_mech_lab_gift_parts",
         "variants":"2"
      });
      
      private static var m_topPriorityGifts:Array = new Array("BuildingPart286Pack","BuildingPart280Pack","BuildingPart287Pack","BuildingPart285Pack","BuildingPart281Pack","BuildingPart284Pack","BuildingPart282Pack","BuildingPart283Pack","BuildingPart289","BuildingPart286","BuildingPart280","BuildingPart287","BuildingPart285","BuildingPart281","BuildingPart284","BuildingPart282","BuildingPart283");
      
      private static var m_giftSubtypes:Array = new Array("energy","mana","mysterygift","buildablepart","expansion","coins","wood","oil","metal","consumable","decoration","army","navy","air");
      
      private var m_giftCategoryOrder:Dictionary = null;
      
      private var m_settingsUrl:String;
      
      private var m_xml:XMLList;
      
      private var m_rawXml:XML;
      
      private var m_cachedImageNames:Dictionary = new Dictionary();
      
      private var m_items:Dictionary = new Dictionary();
      
      private var m_crewTemplates:Dictionary = new Dictionary();
      
      private var m_itemTypes:Dictionary = null;
      
      private var m_attributes:Dictionary;
      
      private var m_marketItemFilters:Array = null;
      
      private var m_itemsXML:XMLList = null;
      
      private var m_stateMachines:XMLList = null;
      
      private var m_xmlByName:Dictionary = new Dictionary();
      
      private var m_xmlByCode:Dictionary = new Dictionary();
      
      private var m_xmlByType:Dictionary = new Dictionary();
      
      private var m_xmlBySubType:Dictionary = new Dictionary();
      
      public function GameSettingsInit(param1:String)
      {
         super(INIT_ID);
         var _loc2_:String = Zlab.getFlashVar("zcache") as String;
         if(_loc2_ != null && _loc2_.length > 0)
         {
            addDependency(ZCacheInit.INIT_ID);
         }
         this.m_settingsUrl = param1;
         this.m_attributes = new Dictionary();
         this.m_itemTypes = new Dictionary();
         this.m_giftCategoryOrder = new Dictionary();
         var _loc3_:int = 0;
         while(_loc3_ < m_giftSubtypes.length)
         {
            this.m_giftCategoryOrder[m_giftSubtypes[_loc3_]] = _loc3_;
            _loc3_++;
         }
      }
      
      public static function checkDateGate(param1:XML) : Boolean
      {
         return true;
      }
      
      override public function execute() : void
      {
         var _loc1_:ByteArray = null;
         var _loc2_:XMLResource = null;
         ZGlobal.gameSettings = this;
         if(Boolean(ZGlobal.settingsData) && ZGlobal.settingsData != "0")
         {
            _loc1_ = ZGlobal.settingsData as ByteArray;
            _loc2_ = new XMLResource();
            if(this.m_settingsUrl.lastIndexOf(".phpgz") > 0)
            {
               _loc1_.uncompress();
               _loc2_.initialize(_loc1_);
            }
            else
            {
               _loc2_.initialize(_loc1_);
            }
            ZGlobal.settingsData = null;
            this.onConfigXmlLoaded(_loc2_);
         }
         else
         {
            Zlab.resourceManager.load(this.m_settingsUrl,XMLResource,this.onConfigXmlLoaded,this.onLoadFailed);
         }
      }
      
      private function onConfigXmlLoaded(param1:XMLResource) : void
      {
         var _loc2_:XML = param1.XMLData;
         this.m_rawXml = _loc2_;
         this.m_itemsXML = this.m_rawXml.items.item;
         this.m_stateMachines = this.m_rawXml.stateMachines.*;
         if(Config.usingIndexedSettings)
         {
            this.initItems();
         }
         this.m_xml = _loc2_.gamesettings;
         if(this.m_xml.length > 0)
         {
            this.m_xml = this.m_xml[0];
         }
         this.m_marketItemFilters = null;
         if(Boolean(this.m_rawXml.assetIndex) && this.m_rawXml.assetIndex.length() > 0)
         {
            new AssetUrlManager(ZConfig.ASSET_BASE_PATH,this.m_rawXml.assetIndex.@hashedPrefix,this.m_rawXml.assetIndex.toString());
         }
         else
         {
            new AssetUrlManager(null,null,null);
         }
         DecorationsManager.instance.initFromSettings(this.m_rawXml.decorationsInfo.targets.target);
         CampaignManager.instance.initFromSettings(this.m_rawXml.campaigns);
         DebugManager.instance.register();
         WorldResourceManager.instance.setResources(this.m_rawXml.resources.resource);
         InventoryList.instance.addItems(this.getItems());
         AnimationManager.instance.initFromSettings(this.m_rawXml.animations.image);
         Zlab.soundManager.initFromSettings(this.m_rawXml.sounds.*,ZConfig.ASSET_BASE_PATH);
         SoundEvent.initFromSettings(this.m_rawXml.soundEvents.soundEvent);
         ButtonSound.initFromSettings(this.m_rawXml.buttonSounds.*);
         PostLoadManager.instance.initFromSettings(this.m_rawXml.postload);
         FXManager.instance.initFromSettings(this.m_rawXml.FXs.FX);
         WeaponManager.instance.initFromSettings(this.m_rawXml.weapons.weapon);
         FormationManager.instance.initFromSettings(this.m_rawXml.formations.formation);
         PromoManager.instance.initFromSettings(this.m_rawXml.promos);
         MessageOfTheDayManager.instance.initFromSettings(this.m_rawXml.messageOfTheDays.messageOfTheDay);
         UnitTestManager.instance.initFromSettings(this.m_rawXml.unitTests);
         UnitClassManager.instance.initFromSettings(this.m_rawXml.unitClasses);
         PlayerQuestTrees.initFromSettings(this.m_rawXml.questTrees.*);
         MegaseriesManager.instance.initFromSettings(this.m_rawXml.megaSeriesList);
         WorldEventManager.instance.initFromSettings(this.m_rawXml.worldEvents);
         WorldUpgradeManager.instance.initFromSettings(this.m_rawXml.researchTrees.researchTree);
         ResourceContractOverridesManager.instance.initFromSettings(this.m_rawXml.resourceContractOverrides.resourceContractOverride);
         ItemCostOverridesManager.instance.initFromSettings(this.m_rawXml.itemCostOverrides.itemCostOverride);
         MiniGameManager.instance.initFromSettings(this.m_rawXml.miniGames);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function initItems() : void
      {
         var _loc1_:XML = null;
         for each(_loc1_ in this.m_itemsXML)
         {
            this.m_xmlByName[_loc1_.@name.toString()] = _loc1_;
            this.m_xmlByCode[_loc1_.@code.toString()] = _loc1_;
            if(this.m_xmlByType[_loc1_.@type.toString()] != undefined)
            {
               this.m_xmlByType[_loc1_.@type.toString()] = this.m_xmlByType[_loc1_.@type.toString()] + _loc1_;
            }
            else
            {
               this.m_xmlByType[_loc1_.@type.toString()] = XMLList(_loc1_);
            }
         }
      }
      
      public function onLoadFailed(param1:Resource) : void
      {
         Logger.error(this,"onLoadFailed","Failed to load resource");
      }
      
      public function getAttribute(param1:String, param2:* = null) : *
      {
         var _loc3_:* = undefined;
         if(this.m_attributes[param1] != null && this.m_attributes[param1] != undefined)
         {
            _loc3_ = this.m_attributes[param1];
         }
         else
         {
            if(this.m_xml["@" + param1] != null && this.m_xml["@" + param1] != undefined)
            {
               _loc3_ = this.m_xml["@" + param1];
            }
            else
            {
               _loc3_ = param2;
            }
            this.m_attributes[param1] = _loc3_;
         }
         return _loc3_;
      }
      
      public function getString(param1:String, param2:String = "") : String
      {
         return this.getAttribute(param1,param2).toString();
      }
      
      public function getInt(param1:String, param2:int = 0) : int
      {
         return parseInt(this.getAttribute(param1,param2));
      }
      
      public function getNumber(param1:String, param2:Number = 0) : Number
      {
         return Number(this.getAttribute(param1,param2));
      }
      
      public function getSeconds(param1:String, param2:Number = 0) : Number
      {
         var _loc3_:String = this.getAttribute(param1,param2);
         return ZGameTimeUtil.instance.parseTimeAsSeconds(_loc3_,param2);
      }
      
      public function setAttribute(param1:String, param2:String) : void
      {
         this.m_xml["@" + param1] = param2;
      }
      
      public function get prisonCampXPBuffThresholdXML() : XML
      {
         return this.m_rawXml.prisonCampXPBuffThresholds[0];
      }
      
      public function getAttributes() : Array
      {
         var _loc2_:XMLList = null;
         var _loc3_:int = 0;
         var _loc1_:Array = [];
         if(this.m_xml)
         {
            _loc2_ = this.m_xml.@*;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length())
            {
               _loc1_.push({
                  "name":_loc2_[_loc3_].name(),
                  "value":_loc2_[_loc3_].toString()
               });
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      public function getXML() : XML
      {
         return this.m_rawXml;
      }
      
      public function getAchievements() : XMLList
      {
         return this.m_rawXml.achievements.achievement;
      }
      
      public function getMaps() : XMLList
      {
         return this.m_rawXml.maps.map;
      }
      
      public function getMovies() : XMLList
      {
         return this.m_rawXml.movies.*;
      }
      
      public function getBuyableMaps() : XMLList
      {
         return this.m_rawXml.maps.map.(@buyable == "true");
      }
      
      public function getItems() : XMLList
      {
         return this.m_itemsXML;
      }
      
      public function getCollections() : XMLList
      {
         return this.m_rawXml.collections.*;
      }
      
      public function getInventorySettings(param1:Object) : XML
      {
         var _loc5_:String = null;
         var _loc6_:Class = null;
         var _loc2_:XML = null;
         var _loc3_:XMLList = this.m_rawXml.inventory.allowedClass;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length())
         {
            _loc5_ = _loc3_[_loc4_].@type.toString();
            _loc6_ = getDefinitionByName("Classes." + _loc5_) as Class;
            if(param1 is _loc6_)
            {
               _loc2_ = _loc3_[_loc4_];
               break;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getLetter(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var id:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.letters["letter_" + id.replace("\'","")];
         }
         else
         {
            list = this.m_rawXml.letters.letter.(@id == id);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getUnitTestData() : XMLList
      {
         return this.m_rawXml.unitTests.test;
      }
      
      public function getSpeech(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var id:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.speeches["speech_" + id];
         }
         else
         {
            list = this.m_rawXml.speeches.speech.(@id == id);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getCrest(param1:String) : XML
      {
         var _loc4_:String = null;
         var _loc2_:XMLList = this.m_rawXml.clanCrests.clanCrest;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length())
         {
            _loc4_ = _loc2_[_loc3_].@crestid.toString();
            if(_loc4_ == param1)
            {
               return _loc2_[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getConversation(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var id:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.conversations["conversation_" + id];
         }
         else
         {
            list = this.m_rawXml.conversations.conversation.(@id == id);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getEpisodeData(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var id:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.episodes["episode_" + id];
         }
         else
         {
            list = this.m_rawXml.episodes.episode.(@id == id);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getStateMachine(param1:String) : XMLList
      {
         var _loc2_:XML = null;
         if(Config.usingIndexedSettings)
         {
            return this.m_rawXml.stateMachines["stateMachine_" + param1];
         }
         for each(_loc2_ in this.m_stateMachines)
         {
            if(_loc2_.@name == param1)
            {
               return XMLList(_loc2_);
            }
         }
         return null;
      }
      
      public function getArrayOfItemXMLByType(param1:String, param2:String = "") : Array
      {
         var _loc4_:XML = null;
         if(null != this.m_itemTypes[param1])
         {
            if(null != this.m_itemTypes[param1][param2])
            {
               return this.m_itemTypes[param1][param2];
            }
         }
         var _loc3_:Array = new Array();
         if(Config.usingIndexedSettings)
         {
            for each(_loc4_ in this.m_xmlByType[param1])
            {
               if(param2 == null || param2 == "" || param2 == _loc4_.@subtype || param2.toLowerCase() == "all")
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         else
         {
            for each(_loc4_ in this.m_itemsXML)
            {
               if(_loc4_.@type == param1 || _loc4_.@category == param1)
               {
                  if(param2 == null || param2 == "" || param2 == _loc4_.@subtype || param2.toLowerCase() == "all")
                  {
                     _loc3_.push(_loc4_);
                  }
               }
            }
         }
         if(null == this.m_itemTypes[param1])
         {
            this.m_itemTypes[param1] = new Dictionary();
         }
         this.m_itemTypes[param1][param2] = _loc3_;
         return _loc3_;
      }
      
      public function getItemsByType(param1:String, param2:String = "") : XMLList
      {
         var _loc3_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc4_:XMLList = new XMLList();
         if(Config.usingIndexedSettings)
         {
            for each(_loc3_ in this.m_xmlByType[param1])
            {
               if(param2 == null || param2 == "" || param2 == _loc3_.@subtype || param2.toLowerCase() == "all")
               {
                  _loc4_[_loc4_.length()] = _loc3_;
               }
            }
         }
         else
         {
            for each(_loc3_ in this.m_itemsXML)
            {
               if(_loc3_.@type == param1 || _loc3_.@category == param1)
               {
                  if(param2 == null || param2 == "" || param2 == _loc3_.@subtype || param2.toLowerCase() == "all")
                  {
                     _loc4_[_loc4_.length()] = _loc3_;
                  }
               }
               _loc5_ = _loc3_.tag.length();
               if(_loc5_ > 0)
               {
                  _loc6_ = 0;
                  while(_loc6_ < _loc5_)
                  {
                     _loc7_ = _loc3_.tag[_loc6_].split(":");
                     if(_loc7_[0] == param1)
                     {
                        if(param2.toLowerCase() == "all" || param2 == "" || param2 == _loc7_[1])
                        {
                           _loc4_[_loc4_.length()] = _loc3_;
                           break;
                        }
                     }
                     _loc6_++;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public function getSpecialItems() : XMLList
      {
         var _loc3_:XML = null;
         var _loc1_:XMLList = new XMLList();
         var _loc2_:int = 0;
         while(_loc2_ < this.m_itemsXML.length())
         {
            _loc3_ = this.m_itemsXML[_loc2_];
            if(this.isSpecialItem(_loc3_))
            {
               _loc1_[_loc1_.length()] = _loc3_;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function isSpecialItem(param1:XML) : Boolean
      {
         var _loc2_:Boolean = false;
         if(Boolean(param1.@buyable) && param1.@buyable.toString() == "true")
         {
            if(Boolean(param1.lootTable) && param1.lootTable.toString() != "")
            {
               _loc2_ = true;
            }
            else if(Boolean(param1.limitedStart) && param1.limitedStart.toString() != "")
            {
               _loc2_ = true;
            }
            else if(Boolean(param1.@marketSpecial) && param1.@marketSpecial.toString() != "")
            {
               _loc2_ = true;
            }
         }
         return _loc2_;
      }
      
      public function getMenuItems() : XMLList
      {
         if(Config.usingIndexedSettings)
         {
            return this.m_rawXml.marketmenu.*;
         }
         return this.m_rawXml.marketmenu.menuitem;
      }
      
      public function getLimitedIcons() : XMLList
      {
         if(Config.usingIndexedSettings)
         {
            return this.m_rawXml.limitedIcons;
         }
         return this.m_rawXml.marketmenu.limitedIcons;
      }
      
      public function getSubMenuItemsByMenuType(param1:String) : XMLList
      {
         var menuType:String = param1;
         if(Config.usingIndexedSettings)
         {
            return this.m_rawXml.marketmenu["menuitem_" + menuType].submenuitem;
         }
         return this.m_rawXml.marketmenu.menuitem.(@type == menuType).submenuitem;
      }
      
      public function getMissionByType(param1:String) : XMLList
      {
         var missionType:String = param1;
         if(Config.usingIndexedSettings)
         {
            return this.m_rawXml.missions["mission_" + missionType];
         }
         return this.m_rawXml.missions.mission.(@type == missionType);
      }
      
      private function createSoundItem(param1:XML, param2:Class) : IItem
      {
         if(param1 != null)
         {
            return new param2(param1);
         }
         return null;
      }
      
      public function getSoundByName(param1:String, param2:Class) : IItem
      {
         var _loc3_:IItem = this.m_items[param1];
         if(_loc3_ == null)
         {
            _loc3_ = this.createSoundItem(this.getSoundXMLByName(param1),param2);
            this.m_items[param1] = _loc3_;
         }
         return _loc3_;
      }
      
      public function getButtonSoundByName(param1:String, param2:Class) : IItem
      {
         var _loc3_:IItem = this.m_items[param1];
         if(_loc3_ == null)
         {
            _loc3_ = this.createSoundItem(this.getButtonSoundsXMLByName(param1),param2);
            this.m_items[param1] = _loc3_;
         }
         return _loc3_;
      }
      
      public function getItemByName(param1:String, param2:Class) : IItem
      {
         var _loc4_:XML = null;
         var _loc3_:IItem = this.m_items[param1];
         if(_loc3_ == null || !(_loc3_ is param2))
         {
            _loc4_ = this.getItemXMLByName(param1);
            if(_loc4_ != null)
            {
               _loc3_ = new param2(_loc4_);
               this.m_items[param1] = _loc3_;
            }
         }
         return _loc3_;
      }
      
      public function getCollectionXMLByCode(param1:String) : XML
      {
         var list:XMLList = null;
         var codeStr:String = param1;
         var result:XML = null;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.collections["collection_" + codeStr];
         }
         else
         {
            list = this.m_rawXml.collections.collection.(@code == codeStr);
         }
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getItemXMLByCode(param1:String) : XML
      {
         var _loc2_:XML = null;
         if(Config.usingIndexedSettings)
         {
            return this.m_xmlByCode[param1];
         }
         _loc2_ = this.m_xmlByCode[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         for each(_loc2_ in this.m_itemsXML)
         {
            if(_loc2_.@code == param1)
            {
               this.m_xmlByCode[param1] = _loc2_;
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getItemByCode(param1:String, param2:Class) : IItem
      {
         var _loc4_:XML = null;
         var _loc3_:IItem = null;
         if(param1 != null)
         {
            _loc3_ = this.m_items[param1];
            if(_loc3_ == null || !(_loc3_ is param2))
            {
               _loc4_ = this.getItemXMLByCode(param1);
               if(_loc4_ != null)
               {
                  _loc3_ = new param2(_loc4_);
                  this.m_items[param1] = _loc3_;
               }
            }
         }
         return _loc3_;
      }
      
      public function getItemClass(param1:String, param2:String) : Class
      {
         if(param1 == GameItem.TYPE_CONSUMABLE && param2 == GameItem.TYPE_MANA)
         {
            return ManaItem;
         }
         return GameItem;
      }
      
      public function getMasteryXMLByCode(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var codeStr:String = param1;
         list = this.m_itemsXML.(@code == codeStr);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getRoadItem() : GameItem
      {
         return this.getItemByName("Road",GameItem) as GameItem;
      }
      
      public function getLevelXML(param1:int) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var level:int = param1;
         list = this.m_rawXml.levels.level.(@num == level);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getMovieXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var nameStr:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.movies["movie_" + nameStr];
         }
         else
         {
            list = this.m_rawXml.movies.movie.(@name == nameStr);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getSoundXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var nameStr:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.sounds["sound_" + nameStr];
         }
         else
         {
            list = this.m_rawXml.sounds.sound.(@name == nameStr);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getButtonSoundsXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var nameStr:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.buttonSounds["buttonSound_" + nameStr];
         }
         else
         {
            list = this.m_rawXml.buttonSounds.buttonSound.(@name == nameStr);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getItemXMLByName(param1:String) : XML
      {
         var _loc2_:XML = null;
         if(Config.usingIndexedSettings)
         {
            return this.m_xmlByName[param1];
         }
         _loc2_ = this.m_xmlByName[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         for each(_loc2_ in this.m_itemsXML)
         {
            if(_loc2_.@name == param1)
            {
               this.m_xmlByName[param1] = _loc2_;
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getNameByTreasureName(param1:String) : String
      {
         var list:XMLList = null;
         var result:String = null;
         var a_nameStr:String = param1;
         list = this.m_itemsXML.(attribute("treasureName") == a_name);
         result = null;
         if(list.length())
         {
            result = list[0].@name;
         }
         return result;
      }
      
      public function getItemFriendlyName(param1:String, param2:int) : String
      {
         var _loc3_:GameItem = this.getItemByName(param1,GameItem) as GameItem;
         if(_loc3_)
         {
            return _loc3_.getFriendlyName(param2);
         }
         return null;
      }
      
      public function getImageByName(param1:String, param2:String, param3:int = 2) : String
      {
         var item:XML;
         var result:String;
         var images:XMLList = null;
         var resourceTypeStr:String = null;
         var itemName:String = param1;
         var imageName:String = param2;
         var size:int = param3;
         if(null != this.m_cachedImageNames[itemName])
         {
            if(null != this.m_cachedImageNames[itemName][imageName])
            {
               return this.m_cachedImageNames[itemName][imageName];
            }
         }
         item = ZGlobal.gameSettings.getItemXMLByName(itemName);
         result = null;
         if(item)
         {
            images = item.image.(@name == imageName);
            if(images.length())
            {
               result = ZGlobal.getAssetURL(images[0].@url);
            }
            if(!result)
            {
               resourceTypeStr = item.@resourceType.toString();
               if(Boolean(resourceTypeStr) && resourceTypeStr.length > 0)
               {
                  if(resourceTypeStr == "rare")
                  {
                     return WorldResourceManager.instance.getResourceImageURL(ZGlobal.hostPlayer.rareResourceType,size);
                  }
               }
            }
         }
         if(null == this.m_cachedImageNames[itemName])
         {
            this.m_cachedImageNames[itemName] = new Dictionary();
            this.m_cachedImageNames[itemName][imageName] = result;
         }
         return result;
      }
      
      public function getIconXMLByCode(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var codeStr:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.icons["icon_" + codeStr];
         }
         else
         {
            list = this.m_rawXml.icons.icon.(@code == codeStr);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getIconXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var nameStr:String = param1;
         list = this.m_rawXml.icons.icon.(@name == nameStr);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getCurrentMOTD() : Object
      {
         var _loc4_:XML = null;
         var _loc1_:Object = null;
         var _loc2_:XMLList = new XMLList();
         var _loc3_:int = 0;
         while(_loc3_ < this.m_rawXml.motd.motdItem.length())
         {
            _loc4_ = this.m_rawXml.motd.motdItem[_loc3_];
            if(checkDateGate(_loc4_))
            {
               _loc4_["version"] = _loc4_["@version"];
               _loc1_ = _loc4_;
               break;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getIconsByMOTD(param1:int, param2:int) : Array
      {
         var list:XMLList = null;
         var index:int = 0;
         var PlayerMOTD:int = param1;
         var newMOTD:int = param2;
         var result:Array = new Array();
         var motd:int = Math.max(PlayerMOTD + 1,newMOTD - MOTD_ICON_BACKLOG_MAX);
         while(motd <= newMOTD)
         {
            list = this.m_rawXml.icons.icon.(@motd == motd);
            index = 0;
            while(index < list.length())
            {
               if(list[index].@motd == newMOTD || list[index].@motd != newMOTD && list[index].@motdExpirable != "true")
               {
               }
               index++;
            }
            motd++;
         }
         return result;
      }
      
      public function checkDate(param1:String, param2:String) : Boolean
      {
         var _loc3_:Date = new Date(param1);
         var _loc4_:Date = new Date(param2);
         var _loc5_:Date = new Date();
         var _loc6_:Boolean = false;
         if(_loc3_ < _loc5_ && _loc5_ < _loc4_)
         {
            _loc6_ = true;
         }
         return _loc6_;
      }
      
      public function getNewLevelItems(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Array, param7:String = "requiredLevel", param8:Boolean = false) : void
      {
         var _loc11_:XML = null;
         var _loc12_:UnitItem = null;
         var _loc13_:BitArray = null;
         var _loc9_:Array = new Array();
         var _loc10_:XMLList = this.getItems();
         for each(_loc11_ in _loc10_)
         {
            if(_loc11_[param7] != undefined && _loc11_[param7] == param1)
            {
               if(_loc11_.@buyable == "true" && _loc11_.@uiHidden != "true" && _loc11_.descendants("limitedEnd").length() == 0 && _loc11_.@levelUpDisplay != "false" && _loc11_.@type != GameItem.TYPE_NPC)
               {
                  if(_loc11_.@subtype == "decoration")
                  {
                     this.addToLevelUpArray(param4,_loc11_,_loc9_);
                  }
                  else if(_loc11_.@subtype == "contract")
                  {
                     this.addToLevelUpArray(param6,_loc11_,_loc9_);
                  }
                  else if(_loc11_.@subtype == UnitItem.AIR || _loc11_.@subtype == UnitItem.ARMY || _loc11_.@subtype == UnitItem.NAVY)
                  {
                     if(param8)
                     {
                        this.addToLevelUpArray(param5,_loc11_,_loc9_);
                     }
                     else
                     {
                        _loc12_ = ZGlobal.gameSettings.getItemByCode(_loc11_.@code,UnitItem) as UnitItem;
                        _loc13_ = ZGlobal.player.checkGate(_loc12_,{"level":param1 - 1});
                        if(_loc13_.isBitSet(Player.GATE_FAILURE_LEVEL))
                        {
                           this.addToLevelUpArray(param5,_loc11_,_loc9_);
                        }
                     }
                  }
                  else if(_loc11_.@storable != "false")
                  {
                     this.addToLevelUpArray(param3,_loc11_,_loc9_);
                  }
               }
               if(_loc11_.@giftable == "true")
               {
                  this.addToLevelUpArray(param2,_loc11_,_loc9_);
               }
            }
         }
      }
      
      public function getGiftableRareItems() : Array
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc5_:GameItem = null;
         var _loc6_:String = null;
         var _loc1_:Array = new Array();
         var _loc2_:XMLList = this.getItems();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.@giftable == "true" && _loc3_.@rare == "1")
            {
               _loc4_ = parseInt(_loc3_.child("giftLevel")[0]);
               if(ZGlobal.player.rareResourceType == _loc3_.@index && _loc4_ != 0 && ZGlobal.player.level > _loc4_)
               {
                  _loc5_ = ZGlobal.gameSettings.getItemByName(_loc3_.@name,GameItem) as GameItem;
                  _loc6_ = _loc5_.getImageObject().url;
                  _loc1_.push(_loc5_);
               }
            }
         }
         _loc1_.sortOn("name");
         return _loc1_;
      }
      
      public function getDisplayableGifts() : Array
      {
         var _loc3_:XML = null;
         var _loc4_:GameItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:XMLList = this.getItems();
         for each(_loc3_ in _loc2_)
         {
            if(this.canGift(_loc3_))
            {
               _loc4_ = ZGlobal.gameSettings.getItemByName(_loc3_.@name,GameItem) as GameItem;
               _loc1_.push(_loc4_);
            }
         }
         _loc1_.sort(this.displayableGiftsSort);
         return _loc1_;
      }
      
      private function displayableGiftsSort(param1:GameItem, param2:GameItem) : Number
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc3_:String = param1.subType ? param1.subType : param1.type;
         var _loc4_:String = param2.subType ? param2.subType : param2.type;
         var _loc5_:int = m_topPriorityGifts.indexOf(param1.name);
         var _loc6_:int = m_topPriorityGifts.indexOf(param2.name);
         if(_loc5_ >= 0 || _loc6_ >= 0)
         {
            _loc9_ = _loc5_ >= 0 ? _loc5_ : int(m_topPriorityGifts.length);
            _loc10_ = _loc6_ >= 0 ? _loc6_ : int(m_topPriorityGifts.length);
            return _loc9_ - _loc10_;
         }
         if(_loc3_ != _loc4_)
         {
            _loc11_ = this.m_giftCategoryOrder[_loc3_] != null ? int(this.m_giftCategoryOrder[_loc3_]) : int.MAX_VALUE;
            _loc12_ = this.m_giftCategoryOrder[_loc4_] != null ? int(this.m_giftCategoryOrder[_loc4_]) : int.MAX_VALUE;
            return _loc11_ - _loc12_;
         }
         var _loc7_:int = param1.giftLevel;
         var _loc8_:int = param2.giftLevel;
         return _loc7_ < _loc8_ ? -1 : 1;
      }
      
      private function canGift(param1:XML) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         if(param1.@giftable != "true")
         {
            return false;
         }
         if(param1.@visibleInGiftPage != undefined && param1.@visibleInGiftPage == false)
         {
            return false;
         }
         if(param1.child("giftLevel"))
         {
            _loc2_ = parseInt(param1.child("giftLevel")[0]);
            if(_loc2_ > ZGlobal.player.level)
            {
               return false;
            }
         }
         if(param1.child("requiredNeighbors"))
         {
            _loc3_ = parseInt(param1.child("requiredNeighbors")[0]);
            if(_loc3_ > ZGlobal.player.numNeighbors)
            {
               return false;
            }
         }
         if(!ExperimentsManager.instance.validateItem(param1))
         {
            return false;
         }
         if(param1.@rare == "1" && ZGlobal.player.rareResourceType != param1.@index)
         {
            return false;
         }
         if(param1.hasOwnProperty("@limitedGiftEnd"))
         {
            return false;
         }
         if(param1.@type == "buildablepart")
         {
            _loc4_ = param1.@name.toString();
            _loc5_ = false;
            for each(_loc6_ in m_giftableBuildableParts)
            {
               if(_loc6_.item == _loc4_)
               {
                  if(_loc6_.experiment == "none")
                  {
                     _loc5_ = true;
                     break;
                  }
                  _loc7_ = ExperimentsManager.instance.getExperimentVariant(_loc6_.experiment);
                  _loc8_ = _loc6_.variants.split(",");
                  if(_loc8_.indexOf(_loc7_.toString()) >= 0)
                  {
                     _loc5_ = true;
                     break;
                  }
               }
            }
            if(!_loc5_)
            {
               return false;
            }
         }
         return true;
      }
      
      private function addToLevelUpArray(param1:Array, param2:XML, param3:Array) : void
      {
         var _loc4_:String = param2.expands.@code;
         if(_loc4_.length > 0)
         {
            if(param3.indexOf(_loc4_) >= 0)
            {
               return;
            }
            param3.push(_loc4_);
         }
         var _loc5_:String = param2.@code;
         if(param1.indexOf(_loc5_) < 0)
         {
            param1.push(_loc5_);
         }
      }
      
      public function get neighborVisitReward() : Object
      {
         var _loc4_:Array = null;
         var _loc1_:String = this.m_xml.@neighborVisitReward.toString();
         var _loc2_:Array = _loc1_.split(",");
         var _loc3_:Object = new Object();
         for each(_loc1_ in _loc2_)
         {
            _loc4_ = _loc1_.split(":");
            _loc3_[_loc4_[0]] = parseInt(_loc4_[1]);
         }
         return _loc3_;
      }
      
      public function get neighborVisitInterval() : Number
      {
         return ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_xml.@neighborVisitInterval.toString(),0);
      }
      
      public function getBuildCategories() : XMLList
      {
         return this.m_rawXml.buildCategories.category;
      }
      
      public function getInventoryCategories() : XMLList
      {
         return this.m_rawXml.inventoryCategories.category;
      }
      
      public function getMarketItemFilters() : Array
      {
         var _loc1_:XMLList = null;
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         if(this.m_marketItemFilters == null)
         {
            this.m_marketItemFilters = new Array();
            _loc1_ = this.m_rawXml.marketItemFilters.filter;
            while(_loc2_ < _loc1_.length())
            {
               _loc3_ = _loc1_[_loc2_];
               _loc4_ = _loc3_.@type.toString();
               if(_loc4_.length > 0)
               {
                  _loc5_ = new Object();
                  _loc5_.type = _loc4_;
                  _loc6_ = _loc3_.@subtype.toString();
                  if(_loc6_.length > 0)
                  {
                     _loc5_.subtype = _loc6_;
                  }
                  this.m_marketItemFilters.push(_loc5_);
               }
               _loc2_++;
            }
         }
         return this.m_marketItemFilters;
      }
      
      public function getCampaignMapDrift(param1:String) : String
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_rawXml.campaign.drift)
         {
            if(_loc2_.attribute("dir") == param1)
            {
               return _loc2_.attribute("value");
            }
         }
         return null;
      }
      
      public function get minCampaignNavigationIndex() : int
      {
         return parseInt(this.m_rawXml.campaign.@minLowMapIndex);
      }
      
      public function get campaignfirstMap() : String
      {
         return this.m_rawXml.campaign.@firstMap;
      }
      
      public function get campaignIsUnlocked() : Boolean
      {
         var _loc1_:String = this.m_rawXml.campaign.@unlockQuest;
         if(_loc1_.length > 0)
         {
            return ZGlobal.player.didCompleteQuest(_loc1_);
         }
         return true;
      }
      
      private function getCombatDamageValue(param1:String, param2:Number = 0) : Number
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc3_:Number = param2;
         if(this.m_rawXml.combatDamage)
         {
            _loc4_ = this.m_rawXml.combatDamage.attribute(param1);
            if(_loc4_)
            {
               _loc5_ = _loc4_.split(",");
               _loc6_ = ExperimentsManager.instance.getExperimentVariant("empire_combat_damage");
               if(_loc6_ >= 0 && _loc6_ < _loc5_.length)
               {
                  _loc3_ = Number(_loc5_[_loc6_]);
               }
            }
         }
         return _loc3_;
      }
      
      public function getCombatDamageBase(param1:Number = 0) : Number
      {
         return this.getCombatDamageValue("combatDamageBase",param1);
      }
      
      public function getCombatDamageTierIncrement(param1:Number = 0) : Number
      {
         return this.getCombatDamageValue("combatDamageTierIncrement",param1);
      }
      
      public function getCombatDamageBaseMin(param1:Number = 0) : Number
      {
         return this.getCombatDamageValue("combatDamageBaseMin",param1);
      }
      
      public function getCampaignMasteryScalar(param1:Number = 0) : Number
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc2_:Number = 1;
         if(this.m_rawXml.campaignMasteryScalars)
         {
            _loc3_ = this.m_rawXml.campaignMasteryScalars.attribute("scalars");
            if(_loc3_)
            {
               _loc4_ = _loc3_.split(",");
               if(_loc4_.length > 0 && Boolean(_loc4_[param1 - 1]))
               {
                  _loc2_ = Number(_loc4_[param1 - 1]);
               }
            }
         }
         return _loc2_;
      }
      
      public function getBuyXp(param1:Number) : Number
      {
         var _loc2_:Number = Math.floor(param1 * this.getNumber("buyXpGainRatio"));
         return Math.max(_loc2_,this.getNumber("buyXpGainMin"));
      }
      
      private function findChallengeRequirementCode() : String
      {
         var _loc1_:XML = null;
         var _loc2_:GameItem = null;
         for each(_loc1_ in this.getItems())
         {
            _loc2_ = new GameItem(_loc1_);
            if(_loc2_.isChallengeRequirement())
            {
               return _loc2_.code;
            }
         }
         return null;
      }
      
      public function getCashAmountFromDurationMilliseconds(param1:int) : int
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param1 = Math.max(0,param1);
         for each(_loc2_ in this.m_rawXml.speedups.speedup)
         {
            _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_.attribute("minDuration"),0);
            _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_.attribute("maxDuration"),0);
            _loc3_ *= 1000;
            _loc4_ *= 1000;
            if(param1 >= _loc3_ && param1 < _loc4_)
            {
               return int(_loc2_.attribute("cash"));
            }
         }
         Logger.error(this,"getCashAmountFromDurationMilliseconds","duration of " + param1 + " not found");
         return 0;
      }
      
      public function showConfirmationPopup(param1:int) : Boolean
      {
         var _loc2_:Object = {
            0:40,
            1:40,
            2:40,
            3:20,
            4:10,
            5:5,
            6:0
         };
         return param1 >= _loc2_[ZGlobal.epSpendConfirmation];
      }
      
      private function crewTemplateHelper(param1:String, param2:int) : CrewTemplateWrapper
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:String = param1 + ":" + String(param2);
         if(!this.m_crewTemplates[_loc3_])
         {
            for each(_loc4_ in this.m_rawXml.crewTemplates.crewTemplate)
            {
               _loc5_ = _loc4_.@crew;
               _loc6_ = _loc4_.@experiment.toString().length == 0 ? 0 : int(parseInt(_loc4_.@experiment));
               if(_loc5_ == param1 && _loc6_ == param2)
               {
                  _loc7_ = this.getCrewTemplateCost(param1);
                  this.m_crewTemplates[_loc3_] = new CrewTemplateWrapper(_loc4_,_loc7_);
                  break;
               }
            }
         }
         return this.m_crewTemplates[_loc3_];
      }
      
      public function getCrewTemplateWrapper(param1:String) : CrewTemplateWrapper
      {
         var _loc2_:CrewTemplateWrapper = this.crewTemplateHelper(param1,ZGlobal.player.effectiveCrewSlotCountVariation);
         if(!_loc2_)
         {
            _loc2_ = this.crewTemplateHelper(param1,0);
         }
         return _loc2_;
      }
      
      private function getCrewTemplateCost(param1:String) : int
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc2_:* = int(this.m_rawXml.crewCostTemplates.crewCostTemplate.length());
         while(_loc2_--)
         {
            _loc3_ = this.m_rawXml.crewCostTemplates.crewCostTemplate[_loc2_];
            _loc4_ = _loc3_.@crew;
            _loc5_ = _loc3_.@experiment.toString().length > 0;
            _loc6_ = _loc5_ ? int(parseInt(_loc3_.@experiment)) : 0;
            if(_loc4_ == param1 && (!_loc5_ || _loc6_ == ZGlobal.crewSlotCostExperiment))
            {
               return parseInt(_loc3_.@slotcost);
            }
         }
         return 1;
      }
      
      public function getViralXML() : XMLList
      {
         return this.m_rawXml.virals.*;
      }
      
      public function getViralXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var nameStr:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.virals["viral_" + nameStr.replace(":","")];
         }
         else
         {
            list = this.m_rawXml.virals.viral.(@name == nameStr);
         }
         return list.length() > 0 ? list[0] : null;
      }
      
      public function get zoomValues() : Array
      {
         var _loc1_:String = this.getString("zoomValues");
         return _loc1_.split(",");
      }
      
      public function get zoomDefaultIndex() : int
      {
         return this.getInt("zoomDefaultIndex");
      }
      
      public function get defaultZoom() : Number
      {
         var _loc1_:Array = this.zoomValues;
         return this.zoomValues[this.zoomDefaultIndex];
      }
      
      public function getPVPMaxOccupations(param1:int) : int
      {
         var _loc4_:XML = null;
         var _loc2_:XMLList = this.m_rawXml.pvpOccupationLimits.info;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length())
         {
            _loc4_ = _loc2_[_loc3_];
            if(!(_loc4_.@victimMinLevel == undefined || _loc4_.@maxOccupations == undefined))
            {
               if(param1 >= _loc4_.@victimMinLevel)
               {
                  return _loc4_.@maxOccupations;
               }
            }
            _loc3_++;
         }
         return 1;
      }
      
      public function getPVPReward(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var reward:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.pvpRewards["reward_" + reward];
         }
         else
         {
            list = this.m_rawXml.pvpRewards.reward.(@name == reward);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getIncentiveItems(param1:String) : Array
      {
         var itemsString:String;
         var list:XMLList = null;
         var typeXML:XML = null;
         var type:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.incentives["reward_" + type];
         }
         else
         {
            list = this.m_rawXml.incentives.reward.(@type == type);
         }
         if(list.length())
         {
            typeXML = list[0];
         }
         itemsString = typeXML.@items;
         if(itemsString)
         {
            return itemsString.split(",");
         }
         return null;
      }
      
      public function getIncentiveResources(param1:String) : Array
      {
         var itemsString:String;
         var list:XMLList = null;
         var typeXML:XML = null;
         var type:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.incentives["reward_" + type];
         }
         else
         {
            list = this.m_rawXml.incentives.reward.(@type == type);
         }
         if(list.length())
         {
            typeXML = list[0];
         }
         itemsString = typeXML.@resources;
         if(itemsString)
         {
            return itemsString.split(",");
         }
         return null;
      }
      
      public function getIncentiveEP(param1:String) : Array
      {
         var itemsString:String;
         var list:XMLList = null;
         var typeXML:XML = null;
         var type:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.incentives["reward_" + type];
         }
         else
         {
            list = this.m_rawXml.incentives.reward.(@type == type);
         }
         if(list.length())
         {
            typeXML = list[0];
         }
         itemsString = typeXML.@ep;
         if(itemsString)
         {
            return itemsString.split(",");
         }
         return null;
      }
      
      public function getIncentiveRewardText(param1:String) : String
      {
         var itemsString:String;
         var list:XMLList = null;
         var typeXML:XML = null;
         var type:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.incentives["reward_" + type];
         }
         else
         {
            list = this.m_rawXml.incentives.reward.(@type == type);
         }
         if(list.length())
         {
            typeXML = list[0];
         }
         itemsString = typeXML.@rewardText;
         if(itemsString)
         {
            return itemsString;
         }
         return null;
      }
      
      public function getPillageType(param1:GameItem) : String
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc2_:XMLList = this.m_rawXml.pillageTypes.type;
         while(_loc3_ < _loc2_.length())
         {
            _loc4_ = _loc2_[_loc3_];
            if(Boolean(_loc4_.@code) && _loc4_.@code == param1.code)
            {
               return _loc4_.@name;
            }
            if(Boolean(_loc4_.@referenceType) && _loc4_.@referenceType == param1.referenceType)
            {
               return _loc4_.@name;
            }
            if(Boolean(_loc4_.@type && _loc4_.@subtype) && Boolean(_loc4_.@type == param1.type) && _loc4_.@subtype == param1.subType)
            {
               return _loc4_.@name;
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getPillageRewardXML(param1:String) : XML
      {
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         if(Config.usingIndexedSettings)
         {
            _loc2_ = this.m_rawXml.pillageRewards["reward_" + param1];
            _loc3_ = null;
            if(_loc2_.length())
            {
               _loc3_ = _loc2_[0];
            }
            return _loc3_;
         }
         if(Boolean(param1) && Boolean(param1.length))
         {
            _loc4_ = this.m_rawXml.pillageRewards.reward;
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length())
            {
               _loc6_ = _loc4_[_loc5_];
               if(_loc6_.@name == param1)
               {
                  return _loc6_;
               }
               _loc5_++;
            }
         }
         return null;
      }
      
      public function getPillageRewardGlobalPVPXML(param1:String) : XML
      {
         var _loc2_:XMLList = null;
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         if(Boolean(param1) && Boolean(param1.length))
         {
            _loc2_ = this.m_rawXml.pillageRewardsGlobalPVP.reward;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length())
            {
               _loc4_ = _loc2_[_loc3_];
               if(_loc4_.@name == param1)
               {
                  return _loc4_;
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      public function getCombatReward(param1:String) : XMLList
      {
         return this.m_rawXml.combatRewards[param1].reward;
      }
      
      public function getCombatEnergyRewardMod() : Number
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         if(Config.usingIndexedSettings)
         {
            if(this.m_rawXml.combatEnergyExperimentModifiers["value_" + ZGlobal.energyRewardModVariant] == null || this.m_rawXml.combatEnergyExperimentModifiers["value_" + ZGlobal.energyRewardModVariant].length() == 0)
            {
               return 1;
            }
            return parseFloat(this.m_rawXml.combatEnergyExperimentModifiers["value_" + ZGlobal.energyRewardModVariant].@modifier);
         }
         var _loc1_:XMLList = this.m_rawXml.combatEnergyExperimentModifiers.value;
         var _loc2_:int = _loc1_.length();
         while(_loc3_ < _loc2_)
         {
            _loc4_ = _loc1_[_loc3_];
            if(parseInt(_loc4_.@variant) == ZGlobal.energyRewardModVariant)
            {
               return parseFloat(_loc4_.@modifier);
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function getManaExperimentValues(param1:String) : Array
      {
         var _loc2_:String = null;
         if(this.m_rawXml.manaValues)
         {
            _loc2_ = this.m_rawXml.manaValues.attribute(param1);
            if(_loc2_)
            {
               return _loc2_.split(",");
            }
         }
         Logger.error(this,"getManaExperimentValue","getManaExperimentValue key \'" + param1 + "\' not known");
         return null;
      }
      
      public function getAmmoExperimentValues(param1:String) : Array
      {
         var _loc2_:String = null;
         if(this.m_rawXml.ammoValues)
         {
            _loc2_ = this.m_rawXml.ammoValues.attribute(param1);
            if(_loc2_)
            {
               return _loc2_.split(",");
            }
         }
         Logger.error(this,"getAmmoExperimentValue","getAmmoExperimentValue key \'" + param1 + "\' not known");
         return null;
      }
      
      public function getLEUnitDiscount(param1:GameItem) : Number
      {
         var _loc2_:XMLList = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         var _loc6_:XMLList = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         if(param1.hasRequiredLevel)
         {
            _loc2_ = this.m_rawXml.LEUnitDiscounts.unitLevel;
            _loc3_ = _loc2_.length();
            for(; _loc4_ < _loc3_; _loc4_++)
            {
               _loc5_ = _loc2_[_loc4_];
               if(param1.requiredLevel >= uint(_loc5_.@min))
               {
                  _loc6_ = _loc5_.playerLevel;
                  _loc7_ = _loc6_.length();
                  while(_loc8_ < _loc7_)
                  {
                     _loc9_ = _loc6_[_loc8_];
                     if(ZGlobal.player.level >= int(_loc9_.@min))
                     {
                        return Number(_loc9_.@discount);
                     }
                     _loc8_++;
                  }
               }
            }
         }
         return 0;
      }
      
      public function getCategoryLimit(param1:String) : Number
      {
         var _loc4_:XMLList = null;
         var _loc6_:int = 0;
         var _loc7_:XMLList = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:XML = null;
         var _loc11_:int = 0;
         var _loc2_:int = 9999;
         var _loc3_:int = ZGlobal.player.level;
         if(Config.usingIndexedSettings)
         {
            _loc4_ = this.m_rawXml.categoryLimits["category_" + param1];
         }
         else
         {
            _loc4_ = this.m_rawXml.categoryLimits.category;
         }
         var _loc5_:int = _loc4_.length();
         if(Config.usingIndexedSettings)
         {
            _loc6_ = 0;
            if(_loc6_ < _loc5_)
            {
               _loc7_ = _loc4_[_loc6_].info;
               _loc8_ = _loc7_.length();
               _loc9_ = 0;
               _loc11_ = 0;
               while(_loc11_ < _loc8_)
               {
                  _loc10_ = _loc7_[_loc11_];
                  if(_loc10_.@level > _loc9_ && _loc3_ >= _loc10_.@level)
                  {
                     _loc2_ = int(_loc10_.@limit);
                     _loc9_ = int(_loc10_.@level);
                  }
                  _loc11_++;
               }
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(_loc4_[_loc6_].@name == param1)
               {
                  _loc7_ = _loc4_[_loc6_].info;
                  _loc8_ = _loc7_.length();
                  _loc9_ = 0;
                  _loc11_ = 0;
                  while(_loc11_ < _loc8_)
                  {
                     _loc10_ = _loc7_[_loc11_];
                     if(_loc10_.@level > _loc9_ && _loc3_ >= _loc10_.@level)
                     {
                        _loc2_ = int(_loc10_.@limit);
                        _loc9_ = int(_loc10_.@level);
                     }
                     _loc11_++;
                  }
                  break;
               }
               _loc6_++;
            }
         }
         return _loc2_;
      }
      
      public function getStreakReductionPercent() : Number
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_streak_bonus_reduction");
         var _loc2_:XMLList = this.m_rawXml.dooberReductionPercent[0].attributes();
         if(Boolean(_loc2_) && _loc2_[_loc1_] != undefined)
         {
            return _loc2_[_loc1_];
         }
         return 0;
      }
      
      public function getQuestTree(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var id:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml.questTrees["questTree_" + id];
         }
         else
         {
            list = this.m_rawXml.questTrees.questTree.(@id == id);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getMegaSeries(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var id:String = param1;
         list = this.m_rawXml.megaSeriesList.megaSeries.(@id == id);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getXMLForSet(param1:String) : XML
      {
         var _loc3_:XML = null;
         var _loc2_:XML = this.m_rawXml;
         if(Boolean(_loc2_) && _loc2_.questSurvivalModeSets != undefined)
         {
            for each(_loc3_ in _loc2_.questSurvivalModeSets.set)
            {
               if(_loc3_.@name != undefined && _loc3_.@name == param1)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public function getMaxWaveForSet(param1:String) : int
      {
         var _loc2_:XML = this.getXMLForSet(param1);
         var _loc3_:XMLList = _loc2_.wave;
         return _loc3_.length();
      }
      
      public function getXPromos() : XMLList
      {
         return this.m_rawXml.XPromos.xpromo;
      }
      
      public function getLEHudIcons() : XMLList
      {
         return this.m_rawXml.LEHudIcons.lehudicon;
      }
      
      public function getMaxLevel() : int
      {
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         var _loc2_:XMLList = _loc1_.levels.*;
         return _loc2_.length();
      }
      
      public function getRaffleXml() : XML
      {
         var _loc1_:XMLList = this.m_rawXml.raffleSettings;
         return _loc1_[0];
      }
      
      public function getMFSData() : Object
      {
         var _loc4_:XML = null;
         var _loc5_:Array = null;
         var _loc6_:XML = null;
         var _loc7_:Object = null;
         var _loc8_:XML = null;
         var _loc9_:Array = null;
         var _loc10_:XML = null;
         var _loc11_:Object = null;
         var _loc12_:XML = null;
         var _loc1_:Object = ZRTManager.instance.getMFSZRTData();
         if(_loc1_)
         {
            return _loc1_;
         }
         var _loc2_:XMLList = this.m_rawXml.mfsp2;
         return _loc2_[0];
      }
      
      public function getTimedBuildable() : XML
      {
         return this.m_rawXml.timedBuildable[0];
      }
      
      public function getTimedBuildableHudIcons() : XMLList
      {
         return this.m_rawXml.timedBuildableHudIcons.timedBuildableHudIcon;
      }
   }
}

