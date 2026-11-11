package core.managers.questManager
{
   import Engine.Transactions.Transaction;
   import Engine.Utilities;
   import ZQuest.Classes.Quest;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.behaviors.states.PrisonCampActiveState;
   import core.entities.components.utils.YieldHelper;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.DecorationItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.WorldResourceManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Player;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import displays.screens.Market;
   import transactions.TAssignConsumable;
   import transactions.TBuyExpansion;
   import transactions.TDecorationPlace;
   import transactions.TFullScreen;
   import transactions.TMarketAdd;
   import transactions.TMarketBuy;
   import transactions.TMove;
   import transactions.TOpenDialog;
   import transactions.TSelect;
   import transactions.TSetState;
   import transactions.TStreamPublishWithCallback;
   import transactions.TString;
   import transactions.TViewZoom;
   import transactions.TVisitorHelp;
   
   public class ZGameQuestUtility
   {
      
      public function ZGameQuestUtility()
      {
         super();
      }
      
      public static function activateXPBuff(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TSetState = getSetStateTransaction(param1);
         if(!_loc4_)
         {
            return 0;
         }
         var _loc5_:PrisonCampActiveState = _loc4_.stateMachine.currentState as PrisonCampActiveState;
         if(!_loc5_)
         {
            return 0;
         }
         var _loc6_:Number = 1;
         if(param2.minMultiplier != undefined)
         {
            _loc6_ = Number(param2.minMultiplier);
         }
         var _loc7_:Number = ZGlobal.player.xpMultiplier;
         if(Math.abs(_loc7_ - _loc6_) < 0.01)
         {
            return 1;
         }
         return 0;
      }
      
      public static function buyExpansion(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         if(param1 as TBuyExpansion)
         {
            return 1;
         }
         if(ZGlobal.player.isAtMaxExpansions)
         {
            return 1;
         }
         return 0;
      }
      
      public static function tending(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:String = null;
         var _loc5_:TVisitorHelp = null;
         var _loc6_:GameItem = null;
         if(param1 is TVisitorHelp)
         {
            _loc4_ = ZGlobal.hostPlayer.uid;
            if(param2.advisorOnly != "true" || _loc4_ == Player.FAKE_PLAYER_ID)
            {
               if(param2.helperAction == "any")
               {
                  return 1;
               }
               _loc5_ = param1 as TVisitorHelp;
               if(_loc5_.visitorHelpType == param2.helperAction)
               {
                  _loc6_ = _loc5_.gameItem;
                  if(param2.byReferenceItem == "true")
                  {
                     _loc6_ = ZGlobal.gameSettings.getItemByName(_loc5_.referenceItem,GameItem) as GameItem;
                  }
                  if(performActionHelper(param2,_loc6_))
                  {
                     return 1;
                  }
               }
            }
         }
         return 0;
      }
      
      public static function expandIsland(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         if(_loc4_.isUnlocked(param2.item))
         {
            return 1;
         }
         return 0;
      }
      
      public static function tendingRewardDropped(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TVisitorHelp = null;
         var _loc5_:String = null;
         var _loc6_:XML = null;
         var _loc7_:YieldHelper = null;
         var _loc8_:String = null;
         if(param1 is TVisitorHelp)
         {
            _loc4_ = param1 as TVisitorHelp;
            if(_loc4_)
            {
               _loc5_ = VisitorManager.getVisitorRewardLabel(_loc4_.owner,_loc4_.gameItem,_loc4_.visitorHelpType,false);
               _loc6_ = VisitorManager.getRewardXML(_loc5_);
               _loc7_ = new YieldHelper();
               _loc7_.initFromData(_loc6_);
               switch(param2.item)
               {
                  case "xp":
                     return _loc7_.xpYield;
                  case "energy":
                     return _loc7_.getEnergyYield(null);
                  default:
                     _loc8_ = WorldResourceManager.instance.resourceFromRareResource(param2.item);
                     return _loc7_.getResourceYield(_loc8_);
               }
            }
         }
         return 0;
      }
      
      public static function genericString(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TString = null;
         if(param1 is TString)
         {
            _loc4_ = param1 as TString;
            if(_loc4_.string == param2.string)
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function place(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TDecorationPlace = null;
         var _loc5_:GameItem = null;
         if(param1 is TDecorationPlace)
         {
            _loc4_ = param1 as TDecorationPlace;
            _loc5_ = ZGlobal.gameSettings.getItemByName(_loc4_.itemName,GameItem) as GameItem;
            if(performActionHelper(param2,_loc5_))
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function state(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc5_:GameItem = null;
         var _loc4_:TSetState = getSetStateTransaction(param1);
         if(_loc4_)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByName(_loc4_.itemName,GameItem) as GameItem;
            if(performActionHelper(param2,_loc5_))
            {
               if((_loc4_.stateMachine.getCurrentState() as BehaviorState).name == param2.state)
               {
                  return 1;
               }
               if(_loc4_.itemName == "Parliament" && int((_loc4_.stateMachine.getCurrentState() as BehaviorState).name) >= 67)
               {
                  return 1;
               }
            }
         }
         return 0;
      }
      
      public static function harvest(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc5_:String = null;
         var _loc6_:UpgradeItem = null;
         var _loc7_:UnitItem = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:GameItem = null;
         var _loc4_:TSetState = getSetStateTransaction(param1);
         if(_loc4_)
         {
            if((_loc4_.stateMachine.getCurrentState() as BehaviorState).isHarvestingState)
            {
               _loc5_ = _loc4_.stateMachine.referenceItemName;
               if(_loc4_.currReferenceItem == null && _loc5_ != null)
               {
                  if(param2.isUpgrade)
                  {
                     _loc6_ = ZGlobal.gameSettings.getItemByName(_loc5_,UpgradeItem) as UpgradeItem;
                     if((Boolean(_loc6_)) && performActionHelper(param2,_loc6_))
                     {
                        if(param2.unit == null)
                        {
                           return 1;
                        }
                        _loc7_ = ZGlobal.gameSettings.getItemByName(_loc4_.stateMachine.researchItemName,UnitItem) as UnitItem;
                        if((Boolean(_loc7_)) && performActionHelper(param2.unit,_loc7_))
                        {
                           return 1;
                        }
                     }
                  }
                  else if(param2.superore == "true")
                  {
                     _loc8_ = _loc4_.stateMachine.resourceType;
                     _loc9_ = param2.type;
                     if(_loc8_ != null && _loc9_ != "")
                     {
                        if(_loc8_ == WorldResourceManager.instance.resourceFromRareResource("nrare" + _loc9_))
                        {
                           _loc10_ = _loc4_.stateMachine.multiplier;
                           _loc11_ = (_loc4_.stateMachine.currentState as BehaviorState).yieldHelper.getResourceYield(_loc8_);
                           return _loc11_ * _loc10_;
                        }
                     }
                  }
                  else
                  {
                     _loc12_ = ZGlobal.gameSettings.getItemByName(_loc5_,GameItem) as GameItem;
                     if(_loc12_ != null && performActionHelper(param2,_loc12_))
                     {
                        return 1;
                     }
                  }
               }
            }
         }
         return 0;
      }
      
      public static function build(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc5_:BehaviorState = null;
         var _loc6_:Array = null;
         var _loc7_:UpgradeItem = null;
         var _loc8_:GameItem = null;
         var _loc9_:GameItem = null;
         var _loc4_:TSetState = getSetStateTransaction(param1);
         if((Boolean(_loc4_)) && Boolean(_loc4_.currReferenceItem))
         {
            _loc5_ = _loc4_.stateMachine.getCurrentState() as BehaviorState;
            if((Boolean(_loc5_)) && _loc5_.isGrowingState)
            {
               if(param2.isUpgrade)
               {
                  _loc6_ = _loc4_.currReferenceItem.split(":");
                  if(_loc6_.length == 2)
                  {
                     _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_[0],UpgradeItem) as UpgradeItem;
                     if((Boolean(_loc7_)) && performActionHelper(param2,_loc7_))
                     {
                        if(param2.unit == null)
                        {
                           return 1;
                        }
                        _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc6_[1],UnitItem) as UnitItem;
                        if((Boolean(_loc8_)) && performActionHelper(param2.unit,_loc8_))
                        {
                           return 1;
                        }
                     }
                  }
               }
               else
               {
                  _loc9_ = ZGlobal.gameSettings.getItemByCode(_loc4_.currReferenceItem,GameItem) as GameItem;
                  if(_loc9_ != null)
                  {
                     if(performActionHelper(param2,_loc9_))
                     {
                        return 1;
                     }
                     if(param2.item.length > 0 && param2.item == _loc9_.code)
                     {
                        return 1;
                     }
                     if(param2.resourceType.length > 0 && param2.resourceType == _loc9_.resourceType)
                     {
                        return 1;
                     }
                  }
               }
            }
         }
         return 0;
      }
      
      public static function openDialog(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         if(param1 is TOpenDialog)
         {
            if((param1 as TOpenDialog).dialog.search(param2.dialog) >= 0)
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function useConsumable(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TAssignConsumable = null;
         var _loc5_:ConsumableItem = null;
         var _loc6_:Boolean = false;
         var _loc7_:Fleet = null;
         var _loc8_:Boolean = false;
         var _loc9_:GameItem = null;
         if(param1 is TAssignConsumable)
         {
            _loc4_ = param1 as TAssignConsumable;
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_.code,ConsumableItem) as ConsumableItem;
            _loc6_ = (Boolean(_loc5_)) && _loc5_.targetsEnemy;
            _loc7_ = ZGlobal.player.fleets.getFleetByName(_loc4_.name);
            _loc8_ = (Boolean(_loc7_)) && _loc7_.isOwnedByPlayer(ZGlobal.player.uid);
            if(!(Boolean(_loc7_) && _loc6_ == _loc8_))
            {
               if(param2.neighbor == "true")
               {
                  if(ZGlobal.player.neighbors[_loc4_.name])
                  {
                     return 1;
                  }
               }
               else if(_loc4_.code == ConsumableItem.MERC_CONSUMABLE_ITEM_CODE && Boolean(_loc4_.name))
               {
                  if(_loc4_.name == param2.merc)
                  {
                     _loc9_ = ZGlobal.gameSettings.getItemByCode(param2.merc,GameItem) as GameItem;
                     if(_loc9_)
                     {
                        return 1;
                     }
                  }
               }
               else
               {
                  if(inStringArray(_loc4_.code,param2.code))
                  {
                     return 1;
                  }
                  if(!param2.code)
                  {
                     return 1;
                  }
               }
            }
         }
         return 0;
      }
      
      private static function inStringArray(param1:String, param2:String) : Boolean
      {
         if(!param1 || !param2)
         {
            return false;
         }
         var _loc3_:Array = param2.split(",");
         var _loc4_:int = _loc3_.indexOf(param1);
         if(_loc4_ < 0)
         {
            return false;
         }
         return true;
      }
      
      public static function marketAdd(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TMarketAdd = null;
         var _loc5_:int = 0;
         if(param1 is TMarketAdd)
         {
            _loc4_ = param1 as TMarketAdd;
            if(_loc4_.type == Market.TYPE_RESOURCE)
            {
               if(param2.item == "rare")
               {
                  _loc5_ = ZGlobal.player.rareResourceType;
               }
               else
               {
                  _loc5_ = WorldResourceManager.instance.getResourceIndexFromType(param2.item);
               }
               if(_loc5_ == int(_loc4_.item))
               {
                  return _loc4_.units;
               }
            }
            else if(_loc4_.type == Market.TYPE_BUILDABLE)
            {
               if(_loc4_.item == param2.item)
               {
                  return _loc4_.units;
               }
            }
         }
         return 0;
      }
      
      public static function marketBuy(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TMarketBuy = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         if(param1 is TMarketBuy)
         {
            _loc4_ = param1 as TMarketBuy;
            if(_loc4_.type == Market.TYPE_RESOURCE)
            {
               _loc5_ = WorldResourceManager.instance.resourceFromRareResource(param2.item);
               _loc6_ = WorldResourceManager.instance.getResourceIndexFromType(_loc5_);
               if(_loc6_ == int(_loc4_.item))
               {
                  return _loc4_.units;
               }
            }
            else if(_loc4_.type == Market.TYPE_BUILDABLE)
            {
               if(param2.item == _loc4_.item)
               {
                  return _loc4_.units;
               }
            }
         }
         return 0;
      }
      
      public static function select(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:GameItem = null;
         if(param1 is TSelect)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode((param1 as TSelect).itemCode,GameItem) as GameItem;
            if(performActionHelper(param2,_loc4_))
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function zoom(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:TViewZoom = null;
         var _loc5_:Number = NaN;
         if(param1 is TViewZoom)
         {
            _loc4_ = param1 as TViewZoom;
            _loc5_ = _loc4_.zoom;
            if(_loc5_ == param2.zoom)
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function fullscreen(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         if(param1 is TFullScreen)
         {
            return 1;
         }
         return 0;
      }
      
      public static function move(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         if(param1 is TMove)
         {
            _loc4_ = (param1 as TMove).itemName;
            _loc5_ = ZGlobal.gameSettings.getItemByName(_loc4_,GameItem) as GameItem;
            if(performActionHelper(param2,_loc5_))
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function shareReminder(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         if(param1 is TStreamPublishWithCallback)
         {
            if((param1 as TStreamPublishWithCallback).type == "crew_completion_reminder")
            {
               return 1;
            }
         }
         return 0;
      }
      
      public static function finishEnergizer(param1:Transaction, param2:Object, param3:Quest) : Number
      {
         var _loc5_:GameItem = null;
         var _loc4_:TSetState = getSetStateTransaction(param1);
         if(_loc4_)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByName(_loc4_.itemName,GameItem) as GameItem;
            if(performActionHelper(param2,_loc5_))
            {
               if(int((_loc4_.stateMachine.getCurrentState() as BehaviorState).name) > int(param2.state))
               {
                  return 1;
               }
            }
         }
         return 0;
      }
      
      private static function getSetStateTransaction(param1:Transaction) : TSetState
      {
         if(param1 is TSetState)
         {
            return param1 as TSetState;
         }
         return null;
      }
      
      private static function performActionHelper(param1:Object, param2:GameItem) : Boolean
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc13_:DecorationItem = null;
         if(param2 == null)
         {
            return false;
         }
         if(param1.type.length > 0)
         {
            if(param2.type != param1.type)
            {
               return false;
            }
         }
         if(param1.subType.length > 0)
         {
            if(param2.subType != param1.subType)
            {
               return false;
            }
         }
         if(param1.resourceType.length > 0)
         {
            _loc4_ = param1.resourceType.split(",");
            if(_loc4_.indexOf(param2.resourceType) < 0)
            {
               return false;
            }
         }
         if(param1.item.length > 0)
         {
            _loc5_ = param1.item.split(",");
            if(_loc5_.indexOf(param2.code) < 0)
            {
               return false;
            }
         }
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         if(_loc3_)
         {
            if(Boolean(param1.unitClass) && param1.unitClass.length > 0)
            {
               _loc6_ = param1.unitClass;
               _loc7_ = _loc6_.split(",");
               if(!_loc7_ || !param2.isUnit() || _loc7_.indexOf(_loc3_.unitClass) < 0)
               {
                  return false;
               }
            }
            if(Boolean(param1.unitType) && param1.unitType.length > 0)
            {
               _loc8_ = param1.unitType;
               _loc9_ = _loc8_.split(",");
               if(!_loc9_ || !_loc9_.length || !param2.isUnit() || !_loc3_.hasAnyType(_loc9_))
               {
                  return false;
               }
            }
         }
         if(Boolean(param1.decoEffect) && Boolean(param1.decoEffect.length))
         {
            _loc10_ = param1.decoEffect.split(",");
            _loc11_ = [];
            if(param2.isDecorationSource)
            {
               _loc13_ = ZGlobal.gameSettings.getItemByCode(param2.code,DecorationItem) as DecorationItem;
               if(_loc13_)
               {
                  _loc11_ = _loc13_.effectStrings;
               }
            }
            _loc12_ = Utilities.arrayIntersect(_loc10_,_loc11_);
            if(!_loc12_.length)
            {
               return false;
            }
         }
         return true;
      }
   }
}

