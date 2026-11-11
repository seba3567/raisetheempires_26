package utils
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.managers.MegaseriesManager;
   import core.managers.PVPManager;
   import core.managers.WorldObjectManager;
   import core.managers.ZRTManager;
   import core.managers.promoManager.PromoManager;
   import core.player.Player;
   import entity.GameDataComponent;
   import flash.utils.Dictionary;
   
   public class CriteriaUtil
   {
      
      private static const ENTITY_PLACED:uint = 0;
      
      private static const ENTITY_BUILT:uint = 1;
      
      private static var m_discountCode:String = null;
      
      private static var m_discountExpirationDate:String = null;
      
      public static const XPROMO_STATE_NEW:String = "NEW";
      
      public static const XPROMO_STATE_VIEWED:String = "VIEWED";
      
      public static const XPROMO_STATE_ACCEPTED:String = "ACCEPTED";
      
      public static const XPROMO_STATE_DECLINED:String = "DECLINED";
      
      public static const XPROMO_STATE_COMPLETED:String = "COMPLETED";
      
      public static const XPROMO_STATE_REWARDED:String = "REWARDED";
      
      public static const XPROMO_STATE_SUSPENDED:String = "SUSPENDED";
      
      public function CriteriaUtil()
      {
         super();
      }
      
      public static function meetsCriteria(param1:XMLList) : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc6_:int = 0;
         var _loc7_:XMLList = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         var _loc12_:String = null;
         var _loc13_:XMLList = null;
         var _loc14_:Boolean = false;
         var _loc15_:String = null;
         var _loc16_:XMLList = null;
         var _loc17_:Boolean = false;
         var _loc18_:String = null;
         var _loc19_:XMLList = null;
         var _loc20_:String = null;
         var _loc21_:int = 0;
         var _loc22_:XMLList = null;
         var _loc23_:String = null;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:XMLList = null;
         var _loc27_:Boolean = false;
         var _loc2_:Player = ZGlobal.player;
         if(param1.length() == 0)
         {
            return true;
         }
         var _loc5_:XML = param1[0];
         if(_loc5_.hasOwnProperty("level"))
         {
            _loc3_ = _loc5_.level[0];
            if(outOfRangeIgnoreNeg(_loc2_.level,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("xpromoPlatform"))
         {
            _loc3_ = _loc5_.xpromoPlatform[0];
            if(!xpromoAvailable(_loc3_.attribute("id")) && !xpromoAccepted(_loc3_.attribute("id")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("requiredDate"))
         {
            _loc6_ = ZGameTimeUtil.instance.getDateStatus(null,_loc5_);
            if((_loc6_ != ZGameTimeUtil.DATE_STATUS_NONE && _loc6_) != ZGameTimeUtil.DATE_STATUS_ACTIVE)
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("ZRT"))
         {
            for each(_loc3_ in _loc5_.ZRT)
            {
               if(!isZRTOn(_loc3_))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("socialLevelGood"))
         {
            _loc3_ = _loc5_.socialLevelGood[0];
            if(outOfRangeIgnoreNeg(_loc2_.socialLevelGood,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("socialLevelBad"))
         {
            _loc3_ = _loc5_.socialLevelBad[0];
            if(outOfRangeIgnoreNeg(_loc2_.socialLevelBad,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("cash"))
         {
            _loc3_ = _loc5_.cash[0];
            if(outOfRangeIgnoreNeg(_loc2_.cash,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("coins"))
         {
            _loc3_ = _loc5_.coins[0];
            if(outOfRangeIgnoreNeg(_loc2_.coins,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("neighbors"))
         {
            _loc3_ = _loc5_.neighbors[0];
            if(outOfRangeIgnoreNeg(_loc2_.numNeighbors,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("hasPVPInvasions"))
         {
            _loc3_ = _loc5_.hasPVPInvasions[0];
            if(outOfRangeIgnoreNeg(PVPManager.instance.numOccupiedInvaders,_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("completedQuest"))
         {
            _loc7_ = _loc5_.completedQuest;
            for each(_loc3_ in _loc7_)
            {
               if(_loc2_.didCompleteQuest(_loc3_.attribute("name")) == false)
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("experiment"))
         {
            for each(_loc3_ in _loc5_.experiment)
            {
               if(!meetsExperimentCriterion(_loc3_))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("inventoryCount"))
         {
            _loc4_ = _loc5_.inventoryCount;
            for each(_loc3_ in _loc4_)
            {
               if(_loc3_.@count != undefined && _loc2_.getNumberOfInventoryItems(_loc3_.attribute("item")) < _loc3_.attribute("count"))
               {
                  return false;
               }
               if(_loc3_.@maxCount != undefined && _loc2_.getNumberOfInventoryItems(_loc3_.attribute("item")) > _loc3_.@maxCount)
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("lightningDealPresent"))
         {
            if(_loc5_.lightningDealPresent.@itemCode == undefined)
            {
               return false;
            }
            _loc8_ = _loc5_.lightningDealPresent.@itemCode.toString();
            _loc9_ = ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_ITEMCODE) as String;
            if(!_loc9_ || _loc8_ != _loc9_)
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("placed"))
         {
            _loc4_ = _loc5_.placed;
            for each(_loc3_ in _loc4_)
            {
               if(!meetsEntityCriterion(_loc3_,ENTITY_PLACED))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("finishedCrewBuilding"))
         {
            _loc4_ = _loc5_.finishedCrewBuilding;
            for each(_loc3_ in _loc4_)
            {
               if(!meetsCrewBuildingFinished(_loc3_))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("questTreeActive"))
         {
            if(_loc5_.questTreeActive.@names != undefined)
            {
               _loc10_ = _loc5_.questTreeActive.@names.toString();
               _loc11_ = _loc10_.split(",");
               if(!ZGlobal.player.questTrees.anyActive(_loc11_))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("megaseriesActive"))
         {
            if(_loc5_.megaseriesActive.@name != undefined)
            {
               _loc12_ = _loc5_.megaseriesActive.@name.toString();
               if(!MegaseriesManager.instance.getMegaseries(_loc12_))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("built"))
         {
            _loc4_ = _loc5_.built;
            for each(_loc3_ in _loc4_)
            {
               if(!meetsEntityCriterion(_loc3_,ENTITY_BUILT))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("language"))
         {
            _loc13_ = _loc5_.language;
            _loc14_ = false;
            for each(_loc3_ in _loc13_)
            {
               _loc15_ = _loc3_.attribute("value").toString();
               if(ZGlobal.localizer.langCode == _loc15_)
               {
                  _loc14_ = true;
               }
            }
            if(!_loc14_)
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("locale"))
         {
            _loc16_ = _loc5_.region;
            _loc17_ = false;
            for each(_loc3_ in _loc16_)
            {
               _loc18_ = _loc3_.attribute("value").toString();
               if(ZGlobal.localizer.localeCode == _loc18_)
               {
                  _loc17_ = true;
               }
            }
            if(!_loc17_)
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("noBuiltItems"))
         {
            _loc19_ = _loc5_.noBuiltItems;
            for each(_loc3_ in _loc19_)
            {
               _loc20_ = _loc3_.attribute("code");
               _loc21_ = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc20_);
               if(_loc21_)
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("noItems"))
         {
            _loc22_ = _loc5_.noItems;
            for each(_loc3_ in _loc22_)
            {
               _loc23_ = _loc3_.attribute("code");
               _loc24_ = _loc2_.getNumberOfInventoryItems(_loc23_);
               _loc25_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc23_);
               if(Boolean(_loc24_) || Boolean(_loc25_))
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("globalPVPOptedIn"))
         {
            if(!PVPManager.instance.globalPVPOptedIn)
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("epPurchased"))
         {
            _loc3_ = _loc5_.epPurchased[0];
            if(_loc3_.@max != undefined)
            {
               if(outOfRangeIgnoreNeg(_loc2_.cashPurchasedTotal,_loc3_.attribute("min"),_loc3_.attribute("max")))
               {
                  return false;
               }
            }
            else if(_loc2_.cashPurchasedTotal < _loc3_.attribute("min"))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("cashPurchased"))
         {
            _loc3_ = _loc5_.cashPurchased[0];
            if(_loc3_.@type != undefined && _loc3_.@type == "payer")
            {
               if(!ZGlobal.player.isPayingUser())
               {
                  return false;
               }
            }
            else if(_loc3_.@type != undefined && _loc3_.@type == "nonpayer")
            {
               if(ZGlobal.player.isPayingUser())
               {
                  return false;
               }
            }
         }
         if(_loc5_.hasOwnProperty("timeSinceLastEPPurchase"))
         {
            _loc3_ = _loc5_.timeSinceLastEPPurchase[0];
            if(_loc2_.secondsSinceLastEPPurchase < 0 || _loc2_.secondsSinceLastEPPurchase < ZGameTimeUtil.instance.parseTimeAsSeconds(_loc3_.attribute("time"),0))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("meetsAnyCriteria"))
         {
            _loc26_ = _loc5_.meetsAnyCriteria.criteria;
            _loc27_ = false;
            for each(_loc3_ in _loc26_)
            {
               if(CriteriaUtil.meetsCriteria(XMLList(_loc3_)))
               {
                  _loc27_ = true;
                  break;
               }
            }
            if(!_loc27_)
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("seenFlag"))
         {
            _loc3_ = _loc5_.seenFlag[0];
            if(outOfRangeIgnoreNeg(_loc2_.getSeenFlag(_loc3_.attribute("name")),_loc3_.attribute("min"),_loc3_.attribute("max")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("notSeenFlag"))
         {
            _loc3_ = _loc5_.notSeenFlag[0];
            if(_loc2_.getSeenFlag(_loc3_.attribute("name")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("notMotdViewed"))
         {
            _loc3_ = _loc5_.notMotdViewed[0];
            if(_loc2_.hasMotdBeenViewed(_loc3_.attribute("name")))
            {
               return false;
            }
         }
         if(_loc5_.hasOwnProperty("BuildableDiscountZRTControlled"))
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_DISCOUNT) != ExperimentsManager.VARIANT_BUILDABLE_DISCOUNT_ENABLED)
            {
               return false;
            }
            m_discountCode = PromoManager.instance.playerHasValidDiscountBuilding();
            if(m_discountCode == null)
            {
               return false;
            }
            m_discountExpirationDate = PromoManager.instance.getEndDate(m_discountCode);
         }
         if(_loc5_.hasOwnProperty("seenSpeech"))
         {
            _loc3_ = _loc5_.seenSpeech[0];
            if(!ZGlobal.player.hasSeenSpeech(_loc3_.@name))
            {
               return false;
            }
         }
         return true;
      }
      
      public static function xpromoAvailable(param1:Number) : Boolean
      {
         var _loc3_:uint = 0;
         var _loc2_:Object = PromoManager.instance.availableCrossPromos;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].id == param1)
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      public static function xpromoAccepted(param1:Number) : Boolean
      {
         var _loc3_:uint = 0;
         var _loc2_:Object = PromoManager.instance.acceptedCrossPromos;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].id == param1)
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      public static function xpromoAcceptedState(param1:Number, param2:String) : Boolean
      {
         var _loc4_:uint = 0;
         var _loc3_:Object = PromoManager.instance.acceptedCrossPromos;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(_loc3_[_loc4_].id == param1 && _loc3_[_loc4_].state == param2)
               {
                  return true;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      private static function outOfRangeIgnoreNeg(param1:Number, param2:Number, param3:Number) : Boolean
      {
         if(param1 < param2 && param2 != -1)
         {
            return true;
         }
         if(param1 > param3 && param3 != -1)
         {
            return true;
         }
         return false;
      }
      
      private static function meetsExperimentCriterion(param1:XML) : Boolean
      {
         if(param1.@experiment == undefined || param1.@variants == undefined)
         {
            return false;
         }
         var _loc2_:String = param1.@experiment.toString();
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(_loc2_);
         var _loc4_:String = param1.@variants.toString();
         var _loc5_:Array = _loc4_.split(",");
         if(_loc5_.indexOf(String(_loc3_)) < 0)
         {
            return false;
         }
         return true;
      }
      
      private static function meetsEntityCriterion(param1:XML, param2:uint) : Boolean
      {
         var _loc6_:uint = 0;
         var _loc7_:int = 0;
         var _loc8_:GameItem = null;
         var _loc9_:Dictionary = null;
         var _loc10_:Object = null;
         var _loc11_:GameDataComponent = null;
         if(param1.@item == undefined)
         {
            return false;
         }
         var _loc3_:uint = 0;
         var _loc4_:uint = uint.MAX_VALUE;
         if(param1.@minExisting != undefined)
         {
            _loc3_ = uint(param1.@minExisting);
         }
         if(param1.@maxExisting != undefined)
         {
            _loc4_ = uint(param1.@maxExisting);
         }
         var _loc5_:String = param1.@item.toString();
         switch(param2)
         {
            case ENTITY_PLACED:
               _loc6_ = uint(WorldObjectManager.instance.getNumberObjectsWithCode(_loc5_));
               break;
            case ENTITY_BUILT:
               _loc6_ = uint(WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc5_));
               break;
            default:
               return false;
         }
         if(_loc6_ > _loc4_ || _loc6_ < _loc3_)
         {
            return false;
         }
         if(param1.@state != undefined)
         {
            _loc7_ = int(param1.@state);
            _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
            _loc9_ = WorldObjectManager.instance.getObjectsBySubType(_loc8_.type,_loc8_.subType);
            for each(_loc10_ in _loc9_)
            {
               _loc11_ = GameDataComponent(_loc10_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc11_)) && _loc11_.gameData.code == _loc5_)
               {
                  if(_loc11_.state < _loc7_)
                  {
                     return false;
                  }
                  break;
               }
            }
         }
         return true;
      }
      
      private static function meetsCrewBuildingFinished(param1:XML) : Boolean
      {
         var _loc5_:Dictionary = null;
         var _loc6_:Object = null;
         var _loc7_:GameDataComponent = null;
         if(param1.@item == undefined)
         {
            return false;
         }
         var _loc2_:String = param1.@item.toString();
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
         var _loc4_:Boolean = false;
         if(_loc3_)
         {
            _loc5_ = WorldObjectManager.instance.getObjectsBySubType(_loc3_.type,_loc3_.subType);
            for each(_loc6_ in _loc5_)
            {
               _loc7_ = GameDataComponent(_loc6_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc7_)) && _loc7_.gameData.code == _loc2_)
               {
                  _loc4_ = CrewManager.isCrewBuilding(_loc7_.owner) && CrewManager.isCrewBuildingFull(_loc7_.owner);
                  if(_loc4_)
                  {
                     break;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      private static function isZRTOn(param1:XML, param2:Boolean = true) : Boolean
      {
         if(param1.@experiment == undefined)
         {
            return false;
         }
         var _loc3_:String = ZGlobal.player[param1.@experiment.toString()];
         if(_loc3_ == null || _loc3_ == "")
         {
            return false;
         }
         if(!ZRTManager.instance.isZRTOn(_loc3_))
         {
            return false;
         }
         return true;
      }
      
      public static function get discountCode() : String
      {
         return m_discountCode;
      }
      
      public static function get discountEndDate() : String
      {
         return m_discountExpirationDate;
      }
   }
}

