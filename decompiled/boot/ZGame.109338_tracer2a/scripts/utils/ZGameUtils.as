package utils
{
   import ZLocalization.LocalizationName;
   import ZLocalization.LocalizationObjectToken;
   import ZLocalization.LocalizedString;
   import com.greensock.TweenMax;
   import com.greensock.easing.Sine;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import displays.screens.questTreeScreen.MiniSeries011QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries017QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries021QuestTreeScreen;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.PixelSnapping;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import zlabs.Constants;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.utils.ColorsUtil;
   
   public class ZGameUtils
   {
      
      public static const GRAYSCALE_ARRAY:Array = [0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0];
      
      public static const DESATURATED_ARRAY:Array = [0.58516,0.36564,0.0492,0,0,0.18516,0.76564,0.0492,0,0,0.18516,0.36564,0.4492,0,0,0,0,0,1,0,0,0,0,0,1];
      
      public static const BRIGHTSCALE_ARRAY:Array = [1.75,0,0,0,0,0,1.75,0,0,0,0,0,1.75,0,0,0,0,0,1,0];
      
      public static const SEPIA_ARRAY:Array = [0.393,0.768,0.188,0,10,0.349,0.685,0.167,0,-5,0.272,0.533,0.13,0,-10,0,0,0,1,0,0,0,0,0,1];
      
      public static const INVERSION_ARRAY:Array = [-0.574,1.43,0.144,0,0,0.426,0.43,0.144,0,0,0.426,1.43,-0.856,0,0,0,0,0,1,0];
      
      public static const EXPANSION_DARK:int = 11184810;
      
      public static const EXPANSION_DARKER:int = 6710886;
      
      public static const ExpansionTransform:ColorTransform = ColorsUtil.rgbColorTransform(ZGameUtils.EXPANSION_DARK);
      
      public static const DarkerTransform:ColorTransform = ColorsUtil.rgbColorTransform(ZGameUtils.EXPANSION_DARKER);
      
      public static const ClearTransform:ColorTransform = new ColorTransform();
      
      public static const GrayScaleFilter:BitmapFilter = new ColorMatrixFilter(GRAYSCALE_ARRAY);
      
      public static const DesaturatedFilter:BitmapFilter = new ColorMatrixFilter(DESATURATED_ARRAY);
      
      public static const SepiaFilter:BitmapFilter = new ColorMatrixFilter(SEPIA_ARRAY);
      
      public static const InvertFilter:BitmapFilter = new ColorMatrixFilter(INVERSION_ARRAY);
      
      public static const HighlightFilter:BitmapFilter = new GlowFilter(Constants.COLOR_HIGHLIGHT,1,8,8,20);
      
      public static const RedHighlighFilter:BitmapFilter = new GlowFilter(Constants.COLOR_RED_STROKE,1,2,2,20);
      
      public static const ImageStrokeFilter:BitmapFilter = new GlowFilter(Constants.COLOR_WHITE_STROKE,1,2,2,20);
      
      public static const LootFilter:BitmapFilter = new GlowFilter(Constants.COLOR_WHITE_STROKE,1,8,8,20);
      
      public static const LootShadowFilter:BitmapFilter = new GlowFilter(0,1,2,2,20);
      
      public static const NoProfileImageUrl:String = "assets/game/GeneralAssetGroup_UI.swf/portrait_noProfileImg.png";
      
      private static var classTypes:Array = [MiniSeries011QuestTreeScreen,MiniSeries017QuestTreeScreen,MiniSeries021QuestTreeScreen];
      
      public function ZGameUtils()
      {
         super();
      }
      
      public static function enableButton(param1:InteractiveObject, param2:Function) : void
      {
         param1.mouseEnabled = true;
         param1.filters = [];
         param1.addEventListener(MouseEvent.CLICK,param2,false,0,true);
      }
      
      public static function disableButton(param1:InteractiveObject, param2:Function) : void
      {
         param1.mouseEnabled = false;
         param1.filters = [new ColorMatrixFilter(GRAYSCALE_ARRAY)];
         param1.removeEventListener(MouseEvent.CLICK,param2);
      }
      
      public static function setButtonEnabled(param1:InteractiveObject, param2:Function, param3:Boolean) : void
      {
         if(param3)
         {
            enableButton(param1,param2);
         }
         else
         {
            disableButton(param1,param2);
         }
      }
      
      public static function alignTextVertically(param1:TextField, param2:InteractiveObject = null, param3:Number = 0) : void
      {
         var _loc4_:Number = param1.textHeight;
         var _loc5_:Number = param1.height;
         if(param2)
         {
            _loc5_ = param2.height;
         }
         param1.y = _loc5_ * 0.5 - _loc4_ * 0.5;
         param1.y += param3;
      }
      
      public static function buildLocalizedParams() : Object
      {
         var _loc2_:String = null;
         var _loc1_:Object = new Object();
         for each(_loc2_ in WorldResourceManager.instance.rareCompares)
         {
            _loc1_[_loc2_] = WorldResourceManager.instance.getRareFriendlyName(_loc2_,GameItem.SENTENCE_FRIENDLYNAME);
         }
         _loc1_["nrare"] = WorldResourceManager.instance.getRareFriendlyName("rare",GameItem.SENTENCE_FRIENDLYNAME);
         _loc1_["player_empire"] = ZGlobal.player.worldName;
         _loc1_["player_name"] = ZGlobal.player.name;
         return _loc1_;
      }
      
      public static function smoothImage(param1:Bitmap) : void
      {
         param1.scaleX = param1.scaleY = 1.01;
         param1.smoothing = true;
         param1.pixelSnapping = PixelSnapping.NEVER;
      }
      
      public static function localToLocal(param1:DisplayObject, param2:DisplayObject) : Point
      {
         return param2.globalToLocal(param1.localToGlobal(new Point()));
      }
      
      public static function cpuTest() : void
      {
         var _loc5_:int = 0;
         var _loc1_:* = 100000;
         var _loc2_:Number = GlobalEngine.getTimer() / 1000;
         var _loc3_:String = "abcdefghijklmopqrstuvwxyz";
         while(_loc1_ > 0)
         {
            _loc5_ = _loc3_.length;
            _loc1_--;
         }
         var _loc4_:Number = GlobalEngine.getTimer() / 1000;
         Logger.info(null,"cpuTest","time: " + (_loc4_ - _loc2_));
      }
      
      public static function hideIfExists(param1:DisplayObject) : Boolean
      {
         if(param1)
         {
            param1.visible = false;
            return true;
         }
         return false;
      }
      
      public static function showIfExists(param1:DisplayObject) : Boolean
      {
         if(param1)
         {
            param1.visible = true;
            return true;
         }
         return false;
      }
      
      public static function desaturate(param1:DisplayObject, param2:Number, param3:Number) : void
      {
         if(param2 == 1 && param1.filters.length == 0)
         {
            return;
         }
         TweenMax.to(param1,param3,{"colorMatrixFilter":{
            "saturation":param2,
            "ease":Sine.easeIn
         }});
      }
      
      public static function addFilter(param1:DisplayObject, param2:BitmapFilter) : void
      {
         param1.filters = [param2];
      }
      
      public static function removeFilter(param1:DisplayObject, param2:BitmapFilter) : void
      {
         param1.filters = [];
      }
      
      public static function ZlocTn(param1:String, param2:String = "masc") : LocalizationName
      {
         return ZLoc.tn(param1,param2);
      }
      
      public static function ZlocTk(param1:String, param2:String, param3:String = "", param4:int = -1) : LocalizationObjectToken
      {
         var pkg:String = param1;
         var key:String = param2;
         var attributes:String = param3;
         var count:int = param4;
         try
         {
            return ZLoc.tk(pkg,key,attributes,count);
         }
         catch(error:Error)
         {
            Logger.print(ZGameUtils,"ZGameUtils.ZlocTk error=" + error.toString());
         }
         return new LocalizationObjectToken(new LocalizedString(key));
      }
      
      public static function ZlocTokenGetString(param1:LocalizationObjectToken) : String
      {
         var locObject:LocalizationObjectToken = param1;
         try
         {
            return locObject.getString();
         }
         catch(error:Error)
         {
            Logger.print(ZGameUtils,"ZGameUtils.ZlocTokenGetString error=" + error.toString());
         }
         return null;
      }
      
      public static function ZlocT(param1:String, param2:String, param3:Object = null) : String
      {
         var pkg:String = param1;
         var key:String = param2;
         var replacements:Object = param3;
         try
         {
            return ZLoc.t(pkg,key,replacements);
         }
         catch(error:Error)
         {
            Logger.print(ZGameUtils,"ZGameUtils.ZlocT error=" + error.toString());
         }
         return key;
      }
      
      public static function strTokenReplace(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         for(_loc3_ in param2)
         {
            _loc4_ = "{" + _loc3_ + "}";
            while(param1.indexOf(_loc4_) >= 0)
            {
               param1 = param1.replace(_loc4_,param2[_loc3_]);
            }
         }
         return param1;
      }
      
      public static function ZlocTP(param1:String, param2:String, param3:Object = null) : String
      {
         var pkg:String = param1;
         var key:String = param2;
         var replacements:Object = param3;
         try
         {
            return ZLoc.tp(pkg,key,replacements);
         }
         catch(error:Error)
         {
            Logger.print(ZGameUtils,"ZGameUtils.ZlocTP error=" + error.toString());
         }
         return key;
      }
      
      public static function getPlayerGenderString() : String
      {
         if(!ZGlobal.player.hasOwnProperty("snUser") || !ZGlobal.player.snUser.hasOwnProperty("gender"))
         {
            return null;
         }
         return ZGlobal.player.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC;
      }
      
      public static function CashTokenReplacements(param1:int) : Object
      {
         return {
            "amount":param1,
            "cash":ZlocTk("Objects","cash","",param1)
         };
      }
      
      public static function localizedStringForToken(param1:String, param2:String = null, param3:Object = null) : String
      {
         var _loc4_:Array = null;
         if(Boolean(param1) && param1 != "")
         {
            _loc4_ = param1.split(":");
            if(_loc4_.length > 1)
            {
               return ZGameUtils.ZlocT(_loc4_[0],_loc4_[1],param3);
            }
            if(param2 != null)
            {
               return ZGameUtils.ZlocT(param2,param1);
            }
         }
         return "";
      }
      
      public static function callFunctionFromXml(param1:String, param2:Array = null) : *
      {
         var _loc3_:Array = null;
         var _loc4_:Class = null;
         var _loc5_:Function = null;
         var _loc6_:Array = null;
         if(Boolean(param1) && param1 != "")
         {
            _loc3_ = param1.split(":");
            if(_loc3_.length > 1)
            {
               _loc4_ = getDefinitionByName(_loc3_[0]) as Class;
               _loc5_ = _loc4_[_loc3_[1]];
               if(param2)
               {
                  _loc6_ = _loc3_[2] ? param2.concat([_loc3_[2]]) : param2;
               }
               else
               {
                  _loc6_ = _loc3_[2] ? [_loc3_[2]] : null;
               }
               return _loc5_.apply(null,_loc6_);
            }
         }
         return null;
      }
      
      public static function traceStrack(param1:int) : void
      {
         var str:String = null;
         var strs:Array = null;
         var c1:int = 0;
         var depth:int = param1;
         try
         {
            throw new Error();
         }
         catch(e:Error)
         {
            str = e.getStackTrace();
            strs = str.split("\n");
            str = "";
            c1 = 0;
            while(c1 < depth)
            {
               str += strs[c1] + "\n";
               c1++;
            }
         }
      }
      
      public static function fullyQualifiedName(param1:DisplayObject) : String
      {
         var _loc2_:String = param1.name;
         while(param1.parent)
         {
            param1 = param1.parent;
            _loc2_ = param1.name + "." + _loc2_;
         }
         return _loc2_;
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 < param2)
         {
            return param2;
         }
         if(param1 > param3)
         {
            return param3;
         }
         return param1;
      }
      
      public static function sortLENewest(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:Number = ZGameTimeUtil.instance.getStartSeconds(param1.xml);
         var _loc4_:Number = ZGameTimeUtil.instance.getStartSeconds(param2.xml);
         if(_loc3_ > _loc4_)
         {
            return -1;
         }
         if(_loc3_ < _loc4_)
         {
            return 1;
         }
         return 0;
      }
      
      public static function sortStrongest(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         if(_loc3_.getStrength(null) == _loc4_.getStrength(null))
         {
            return 0;
         }
         if(_loc3_.getStrength(null) > _loc4_.getStrength(null))
         {
            return -1;
         }
         return 1;
      }
      
      public static function sortWeakest(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         if(_loc3_.getStrength(null) == _loc4_.getStrength(null))
         {
            return 0;
         }
         if(_loc3_.getStrength(null) < _loc4_.getStrength(null))
         {
            return -1;
         }
         return 1;
      }
      
      public static function sortTitanParts(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:UnitItem = param1 as UnitItem;
         var _loc4_:UnitItem = param2 as UnitItem;
         var _loc5_:Boolean = _loc3_ ? _loc3_.hasType(UnitItem.MEGA_UNIT) : false;
         var _loc6_:Boolean = _loc4_ ? _loc4_.hasType(UnitItem.MEGA_UNIT) : false;
         return _loc5_ == _loc6_ ? 0 : (_loc5_ ? -1 : 1);
      }
      
      public static function sortLE(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:Boolean = ZGameTimeUtil.instance.isLimitedEdition(param1.xml);
         var _loc4_:Boolean = ZGameTimeUtil.instance.isLimitedEdition(param2.xml);
         if(_loc3_ == _loc4_)
         {
            return 0;
         }
         if(_loc3_)
         {
            return -1;
         }
         return 1;
      }
      
      public static function sortEPCostAscending(param1:GameItem, param2:GameItem) : int
      {
         if(param1.cash == param2.cash)
         {
            return 0;
         }
         if(param1.cash < param2.cash)
         {
            return -1;
         }
         return 1;
      }
      
      public static function sortRequiredLevel(param1:GameItem, param2:GameItem) : int
      {
         if(param1.requiredLevel == param2.requiredLevel)
         {
            return 0;
         }
         if(param1.requiredLevel < param2.requiredLevel)
         {
            return -1;
         }
         return 1;
      }
      
      public static function sortRequiredDominanceLevel(param1:GameItem, param2:GameItem) : int
      {
         if(param1.requiredDominanceRank == param2.requiredDominanceRank)
         {
            return 0;
         }
         if(param1.requiredDominanceRank < param2.requiredDominanceRank)
         {
            return -1;
         }
         return 1;
      }
      
      public static function printContents(param1:*, param2:int = 0, param3:String = ".") : void
      {
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc6_:int = 0;
         _loc6_ = param2 + 1;
         if(!param1)
         {
            Logger.print(null,getIndentations(param2,param3) + "[provided object is null or undefined]");
         }
         else if(isNative(param1))
         {
            Logger.print(null,getIndentations(param2,param3) + "[provided object is a native type with value: " + param1 + "]");
         }
         else if(param1 is Object)
         {
            for(_loc4_ in param1)
            {
               _loc5_ = param1[_loc4_];
               if(isNative(_loc5_))
               {
                  Logger.print(null,getIndentations(param2,param3) + "[" + _loc4_ + "]: " + _loc5_);
               }
               else if(!_loc5_)
               {
                  Logger.print(null,getIndentations(param2,param3) + "[" + _loc4_ + "]: null or undefined");
               }
               else if(_loc5_ is Object)
               {
                  Logger.print(null,getIndentations(param2,param3) + "[" + _loc4_ + "]: ");
                  printContents(_loc5_,_loc6_,param3);
               }
            }
         }
      }
      
      public static function isNative(param1:*) : Boolean
      {
         return param1 is Boolean || param1 is int || param1 is String || param1 is Number || param1 is uint;
      }
      
      public static function getIndentations(param1:int, param2:String = " ") : String
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         _loc3_ = "";
         _loc4_ = 0;
         while(_loc4_ < param1)
         {
            _loc3_ += param2;
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function testPrintContents() : void
      {
         var _loc1_:Object = null;
         _loc1_ = {};
         _loc1_.greetings = ["hi","hello","how are you?","yo","hey"];
         _loc1_.raggedArray = [0,1,"two",{"three":{"val":3}},[4],5.55,uint(6)];
         _loc1_.arrayOfObjects = [{"name":"Steele"},{"power":99},{"agility":57},{"cunning":95},{"items":["hammer","bolt","nail","axe"]}];
         _loc1_.multNestedObjects = {"personalityTraits":{
            "likesAndDislikes":[{"favoriteThings":["sugar","spice","everything","noice"]},{"unfavoriteThings":["sugar","spice","everything","noice"]}],
            "friends":[{
               "name":"Jack",
               "age":32
            },{
               "name":"Jill",
               "age":25
            },{
               "name":"Josh",
               "age":12
            },{
               "name":"Joe",
               "age":93
            },{
               "name":"James",
               "age":39
            },{
               "name":"Jimmy",
               "age":27
            },{
               "name":"Iggy",
               "age":"unknown",
               "gender":"female",
               "likes":["puppies","volleyball","the color tan","praising the lord"]
            }]
         }};
         Logger.print(null,"Starting printContents test");
         printContents(_loc1_);
      }
      
      public static function shuffleArray(param1:Array, param2:int = -1, param3:int = -1) : void
      {
         var _loc6_:int = 0;
         if(param2 == -1)
         {
            param2 = 0;
         }
         if(param3 == -1)
         {
            param3 == param1.length - 1;
         }
         var _loc4_:int = param3 - param2 + 1;
         var _loc5_:Object = null;
         var _loc7_:int = param2;
         while(_loc7_ <= param3)
         {
            _loc6_ = Math.floor(Math.random() * _loc4_) + param2;
            _loc5_ = param1[_loc7_];
            param1[_loc7_] = param1[_loc6_];
            param1[_loc6_] = _loc5_;
            _loc7_++;
         }
      }
      
      public static function getBuildingByCode(param1:String) : IEntity
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:GameDataComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:IEntity = null;
         if(_loc2_)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc6_)) && _loc6_.gameData.code == param1)
               {
                  _loc3_ = _loc6_.owner;
                  break;
               }
            }
         }
         return _loc3_;
      }
      
      public static function getWareHouse(param1:String) : IEntity
      {
         var _loc5_:Dictionary = null;
         var _loc6_:WarehouseComponent = null;
         var _loc7_:Object = null;
         var _loc8_:GameDataComponent = null;
         var _loc9_:WarehouseComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:IEntity = null;
         var _loc4_:IEntity = null;
         if(_loc2_)
         {
            _loc5_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            _loc6_ = null;
            for each(_loc7_ in _loc5_)
            {
               _loc8_ = GameDataComponent(_loc7_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc8_)) && _loc8_.gameData.code == param1)
               {
                  _loc3_ = _loc8_.owner;
                  _loc9_ = WarehouseComponent.getWarehouseComponent(_loc3_);
                  if(!_loc9_.atMaxTier())
                  {
                     if(_loc6_ == null)
                     {
                        _loc6_ = _loc9_;
                        _loc4_ = _loc3_;
                     }
                     else if(_loc6_.geTier() < _loc9_.geTier())
                     {
                        _loc6_ = _loc9_;
                        _loc4_ = _loc3_;
                     }
                  }
               }
            }
            return _loc4_;
         }
         return null;
      }
   }
}

