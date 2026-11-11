package core.managers
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.resource.ResourceInfo;
   import core.resource.WorldResource;
   import flash.utils.Dictionary;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.utils.StringUtils;
   
   public class WorldResourceManager
   {
      
      public static var instance:WorldResourceManager = new WorldResourceManager();
      
      public static const XTRA_SMALL_ICON:int = 0;
      
      public static const SMALL_ICON:int = 1;
      
      public static const MEDIUM_ICON:int = 2;
      
      public static const LARGE_ICON:int = 3;
      
      public static const XTRA_LARGE_ICON:int = 4;
      
      private var m_rareCompares:Array = ["rare","nrare0","nrare1","nrare2","nrare3","nrare4","nrare5","nrare6","nrare7","nrare8","nrare9"];
      
      private var m_resourceInfo:Array;
      
      private var m_resourceMap:Dictionary;
      
      public function WorldResourceManager()
      {
         super();
         this.m_resourceInfo = new Array();
         this.m_resourceMap = new Dictionary();
      }
      
      public function findResourceTypesInXML(param1:XML, param2:int) : Dictionary
      {
         var _loc4_:Array = null;
         var _loc11_:XML = null;
         var _loc12_:String = null;
         var _loc13_:WorldResource = null;
         var _loc3_:Dictionary = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = "0";
         var _loc8_:String = "0|0";
         var _loc9_:ResourceInfo = null;
         var _loc10_:XMLList = param1.attributes();
         for each(_loc11_ in _loc10_)
         {
            _loc12_ = _loc11_.name();
            if(null != this.m_resourceMap[_loc12_] || this.m_rareCompares.indexOf(_loc12_) >= 0)
            {
               _loc6_ = String(_loc11_);
               if(_loc6_ != _loc7_ && _loc6_ != _loc8_)
               {
                  _loc4_ = _loc6_.split("|");
                  if(Boolean(_loc4_[1]) && ZGlobal.isVisiting())
                  {
                     _loc5_ = parseInt(_loc4_[1]);
                  }
                  else
                  {
                     _loc5_ = parseInt(_loc4_[0]);
                  }
                  _loc13_ = this.createResource(_loc12_,_loc5_,param2);
                  if(_loc3_ == null)
                  {
                     _loc3_ = new Dictionary();
                  }
                  _loc3_[_loc13_.type] = _loc13_;
               }
            }
         }
         return _loc3_;
      }
      
      public function get rareCompares() : Array
      {
         return this.m_rareCompares;
      }
      
      public function getRareFriendlyName(param1:String, param2:int) : String
      {
         var _loc3_:int = this.m_rareCompares.indexOf(param1);
         if(_loc3_ >= 0)
         {
            _loc3_ = this.rareResourceIndex(param1);
            return this.getResourceFriendlyNameFromIndex(_loc3_,param2);
         }
         return null;
      }
      
      public function resourceFromRareResource(param1:String, param2:int = -1) : String
      {
         var _loc3_:int = this.m_rareCompares.indexOf(param1);
         if(_loc3_ >= 0)
         {
            _loc3_ = this.rareResourceIndex(param1,param2);
            return this.getResourceTypeFromIndex(_loc3_);
         }
         return param1;
      }
      
      public function rareResourceIndex(param1:String, param2:int = -1) : int
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = param2 > -1 ? param2 : ZGlobal.player.rareResourceType;
         var _loc4_:int = _loc3_;
         if(param1.charAt(0) == "n")
         {
            param1 = param1.substr(5,1);
            _loc4_ = parseInt(param1);
            _loc4_ = _loc4_ + _loc3_;
            _loc5_ = WorldResourceManager.instance.numRareResources;
            _loc6_ = WorldResourceManager.instance.firstRareResourceIndex;
            if(_loc4_ - _loc6_ >= _loc5_)
            {
               _loc4_ -= _loc6_;
               _loc4_ = _loc4_ % _loc5_;
               _loc4_ = _loc4_ + _loc6_;
            }
         }
         return _loc4_;
      }
      
      public function createResource(param1:String, param2:int, param3:int = -1) : WorldResource
      {
         param1 = this.resourceFromRareResource(param1,param3);
         return new WorldResource(this.getResourceInfoByType(param1),param2);
      }
      
      public function setResources(param1:XMLList) : void
      {
         var _loc3_:ResourceInfo = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:Boolean = false;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc18_:int = 0;
         var _loc19_:String = null;
         var _loc20_:String = null;
         var _loc21_:String = null;
         var _loc22_:String = null;
         var _loc23_:int = 0;
         var _loc24_:Array = null;
         var _loc25_:XML = null;
         var _loc26_:String = null;
         var _loc27_:String = null;
         var _loc2_:int = 0;
         for each(_loc4_ in param1)
         {
            _loc5_ = _loc4_.@type.toString();
            _loc6_ = parseInt(_loc4_.@rare) == 1 ? true : false;
            _loc7_ = _loc4_.@xtraSmallIcon.toString();
            _loc8_ = _loc4_.@smallIcon.toString();
            _loc9_ = _loc4_.@mediumIcon.toString();
            _loc10_ = _loc4_.@largeIcon.toString();
            _loc11_ = _loc4_.@xtraLargeIcon.toString();
            _loc12_ = _loc4_.@visitIcon.toString();
            _loc13_ = _loc4_.@pickupSoundEvent.toString();
            _loc14_ = parseInt(_loc4_.@showInWallet) == 1 ? true : false;
            _loc15_ = parseInt(_loc4_.@marketPrice);
            _loc16_ = _loc4_.@giftableItemName.toString();
            _loc17_ = _loc4_.@tooltip.toString();
            _loc18_ = parseInt(_loc4_.@uiColor);
            _loc19_ = _loc4_.@productionInputIcon.toString();
            _loc20_ = _loc4_.@productionFactoryIcon.toString();
            _loc21_ = _loc4_.@productionOutputIcon.toString();
            _loc22_ = _loc4_.@productionPromptToken.toString();
            _loc3_ = new ResourceInfo(_loc5_,_loc6_,_loc9_,_loc13_,_loc14_,_loc15_,_loc17_,_loc18_,_loc16_);
            if(_loc4_.@startingAmount != undefined)
            {
               _loc23_ = parseInt(_loc4_.@startingAmount);
               _loc3_.startingAmount = _loc23_;
            }
            if(_loc4_.loot.length() > 0)
            {
               _loc24_ = new Array();
               for each(_loc25_ in _loc4_.loot)
               {
                  _loc26_ = _loc25_.attribute("max");
                  _loc27_ = _loc25_.attribute("url");
                  _loc24_.push({
                     "max":_loc26_,
                     "url":_loc27_
                  });
               }
               _loc3_.lootImages = _loc24_;
            }
            if(_loc7_.length > 0)
            {
               _loc3_.xtraSmallIcon = _loc7_;
            }
            if(_loc8_.length > 0)
            {
               _loc3_.smallIcon = _loc8_;
            }
            if(_loc10_.length > 0)
            {
               _loc3_.largeIcon = _loc10_;
            }
            if(_loc11_.length > 0)
            {
               _loc3_.xtraLargeIcon = _loc11_;
            }
            if(_loc12_.length > 0)
            {
               _loc3_.visitIcon = _loc12_;
            }
            if(_loc19_.length > 0)
            {
               _loc3_.productionInputIcon = _loc19_;
            }
            if(_loc20_.length > 0)
            {
               _loc3_.productionFactoryIcon = _loc20_;
            }
            if(_loc21_.length > 0)
            {
               _loc3_.productionOutputIcon = _loc21_;
            }
            if(_loc22_.length > 0)
            {
               _loc3_.productionPromptToken = _loc22_;
            }
            this.m_resourceInfo.push(_loc3_);
            this.m_resourceMap[_loc5_] = _loc2_;
            _loc2_++;
         }
      }
      
      public function getResourceSoundEvent(param1:String) : String
      {
         return this.m_resourceInfo[this.m_resourceMap[param1]].pickupSoundEvent;
      }
      
      public function getResourceInfoByType(param1:String) : ResourceInfo
      {
         if(null == this.m_resourceMap[param1])
         {
            Logger.error(this,"getResourceInfoByType","No resource type named \'" + param1 + "\' found.");
            return null;
         }
         return this.m_resourceInfo[this.m_resourceMap[param1]];
      }
      
      public function getResourceImageURL(param1:int, param2:int = 2) : String
      {
         var _loc3_:String = null;
         if(param2 == XTRA_SMALL_ICON)
         {
            _loc3_ = this.m_resourceInfo[param1].xtraSmallIcon;
            return _loc3_ ? ZGlobal.getAssetURL(_loc3_) : this.getResourceImageURL(param1,SMALL_ICON);
         }
         if(param2 == SMALL_ICON)
         {
            _loc3_ = this.m_resourceInfo[param1].smallIcon;
            return _loc3_ ? ZGlobal.getAssetURL(_loc3_) : this.getResourceImageURL(param1,MEDIUM_ICON);
         }
         if(param2 == MEDIUM_ICON)
         {
            _loc3_ = this.m_resourceInfo[param1].mediumIcon;
            return _loc3_ ? ZGlobal.getAssetURL(_loc3_) : this.getResourceImageURL(param1,LARGE_ICON);
         }
         if(param2 == LARGE_ICON)
         {
            _loc3_ = this.m_resourceInfo[param1].largeIcon;
            return _loc3_ ? ZGlobal.getAssetURL(_loc3_) : this.getResourceImageURL(param1,XTRA_LARGE_ICON);
         }
         return ZGlobal.getAssetURL(this.m_resourceInfo[param1].xtraLargeIcon);
      }
      
      public function getLootImageURLByType(param1:String, param2:int) : String
      {
         var _loc3_:Object = null;
         for each(_loc3_ in this.m_resourceInfo[this.getResourceIndexFromType(param1)].lootImages)
         {
            if(param2 < _loc3_.max)
            {
               return ZGlobal.getAssetURL(_loc3_.url);
            }
         }
         Logger.warn(this,"getLootImageURLByType","no loot image for type: " + param1 + " amount: " + param2);
         return this.getResourceImageURLByType(param1,WorldResourceManager.LARGE_ICON);
      }
      
      public function getResourceImageURLByType(param1:String, param2:int = 2) : String
      {
         if(Boolean(param1) && param1.length > 0)
         {
            return this.getResourceImageURL(this.m_resourceMap[param1],param2);
         }
         return null;
      }
      
      public function getResourceImageName(param1:int) : String
      {
         var _loc2_:String = this.getResourceImageURL(param1);
         return StringUtils.getFilenameFromPath(_loc2_);
      }
      
      public function getResourceImageNameByType(param1:String) : String
      {
         return this.getResourceImageName(this.m_resourceMap[param1]);
      }
      
      public function getResourceIndexFromType(param1:String) : int
      {
         var _loc2_:int = -1;
         if(null != this.m_resourceMap[param1])
         {
            _loc2_ = int(this.m_resourceMap[param1]);
         }
         else
         {
            Logger.error(this,"getResourceIndexFromType","resource " + param1 + " not known");
         }
         return _loc2_;
      }
      
      public function getResourceTypeFromIndex(param1:int) : String
      {
         return this.m_resourceInfo[param1].type;
      }
      
      public function getResourceFriendlyNameFromType(param1:String, param2:int, param3:Boolean = true) : String
      {
         return this.getResourceFriendlyNameFromIndex(this.getResourceIndexFromType(param1),param2,param3);
      }
      
      public function getResourceFriendlyNameFromIndex(param1:int, param2:int, param3:Boolean = true) : String
      {
         var _loc4_:String = null;
         if(param2 == GameItem.MENU_FRIENDLYNAME)
         {
            _loc4_ = ZGameUtils.ZlocT("Items",this.m_resourceInfo[param1].type + "_menuName");
         }
         else
         {
            _loc4_ = ZGameUtils.ZlocT("Main","Resource_ToolTip",{"resource":ZGameUtils.ZlocTk("Items",this.m_resourceInfo[param1].type + "_sentenceName",param3 ? "plural" : "singular")});
            _loc4_ = StringUtils.upperCaseFirstChar(_loc4_);
         }
         return _loc4_;
      }
      
      public function get resourceInfo() : Array
      {
         return this.m_resourceInfo;
      }
      
      public function get numResources() : int
      {
         return this.m_resourceInfo.length;
      }
      
      public function get numRareResources() : int
      {
         var _loc2_:ResourceInfo = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_resourceInfo)
         {
            if(_loc2_.isRare)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get firstRareResourceIndex() : int
      {
         var _loc2_:ResourceInfo = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_resourceInfo)
         {
            if(_loc2_.isRare)
            {
               break;
            }
            _loc1_++;
         }
         return _loc1_;
      }
      
      public function getResourceColor(param1:String) : int
      {
         return this.m_resourceInfo[this.getResourceIndexFromType(param1)].color;
      }
   }
}

