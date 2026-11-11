package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.player.Player;
   import dispatchers.MessageDispatcher;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.screens.Market;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import events.ResourceMarketEvent;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TMarketAdd;
   import transactions.TMarketBuy;
   import transactions.TMarketRemove;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class ResourceDialogState extends DialogState
   {
      
      private var m_currentlySelling:Object;
      
      private var m_secondSelling:Object;
      
      private var overlayIconNameProperty:PropertyReference = new PropertyReference("@Overlay.iconName");
      
      public function ResourceDialogState(param1:BehaviorStateInit)
      {
         var _loc2_:String = null;
         super(param1);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.RESOURCE_DIALOG_UPDATE,this.onResourceDialogUpdate,false,0,true);
         if(param1.m_gameObject != null)
         {
            if(param1.m_gameObject.item)
            {
               this.m_currentlySelling = new Object();
               _loc2_ = param1.m_gameObject.item;
               if(_loc2_ == "0" || _loc2_ == "8")
               {
                  this.m_currentlySelling = null;
               }
               else
               {
                  this.m_currentlySelling.item = _loc2_;
                  this.m_currentlySelling.type = param1.m_gameObject.type;
                  this.m_currentlySelling.units = param1.m_gameObject.units;
               }
            }
         }
      }
      
      override protected function removeListeners() : void
      {
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.RESOURCE_DIALOG_UPDATE,this.onResourceDialogUpdate);
         UIDispatcher.instance.removeEventListener(ResourceMarketEvent.BUY,this.onResourceMarketBuy);
         UIDispatcher.instance.removeEventListener(ResourceMarketEvent.ITEM,this.onResourceMarketGuestItemChanged);
      }
      
      override protected function getQualifiedDialogClassName() : String
      {
         var _loc1_:String = super.getQualifiedDialogClassName();
         if(ZGlobal.isVisiting())
         {
            return _loc1_ + "Guest";
         }
         return _loc1_ + "Host";
      }
      
      override protected function overrideAndUpdateOverlay(param1:GameItem) : void
      {
         var _loc5_:GameItem = null;
         var _loc2_:Dictionary = param1.getStateMachineValues(null);
         var _loc3_:Dictionary = new Dictionary();
         var _loc4_:Dictionary = new Dictionary();
         if(Boolean(this.m_currentlySelling) && this.m_currentlySelling.type == Market.TYPE_BUILDABLE)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(this.m_currentlySelling.item,GameItem) as GameItem;
            if(_loc5_)
            {
               _loc3_ = _loc5_.getStateMachineValues(param1.name);
               _loc4_ = _loc5_.getReferenceImage();
            }
         }
         m_data = m_originalData.copy();
         overrideStateDefaults(m_data,_loc2_,_loc3_,_loc4_);
         updateOverrides(m_data);
         updateOverlay();
         if(Boolean(this.m_currentlySelling) && this.m_currentlySelling.type == Market.TYPE_RESOURCE)
         {
            this.addResourceIcon(this.m_currentlySelling.item);
         }
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         UIDispatcher.instance.addEventListener(ResourceMarketEvent.BUY,this.onResourceMarketBuy,false,0,true);
         UIDispatcher.instance.addEventListener(ResourceMarketEvent.ITEM,this.onResourceMarketGuestItemChanged,false,0,true);
      }
      
      override public function exit(param1:IMachine) : void
      {
         this.removeListeners();
      }
      
      override public function onClick(param1:Event) : void
      {
         super.onClick(param1);
         m_window.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
         m_window.addEventListener(ResourceMarketEvent.ITEM,this.onResourceMarketHostItemChanged,false,0,true);
         m_window.addEventListener(ResourceMarketEvent.ADD,this.onResourceMarketAdd,false,0,true);
         m_window.addEventListener(ResourceMarketEvent.REMOVE,this.onResourceMarketRemove,false,0,true);
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         m_window.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
         m_window.removeEventListener(ResourceMarketEvent.ITEM,this.onResourceMarketHostItemChanged);
         m_window.removeEventListener(ResourceMarketEvent.ADD,this.onResourceMarketAdd);
         m_window.removeEventListener(ResourceMarketEvent.REMOVE,this.onResourceMarketRemove);
         super.onCloseClick(param1);
      }
      
      private function onResourceMarketAdd(param1:ResourceMarketEvent) : void
      {
         var _loc2_:Object = param1.eventData;
         if(_loc2_ != null)
         {
            TransactionManager.addTransaction(new TMarketAdd(param1.targetObject as Market,stateMachine.propertyBag as IEntity,_loc2_.item,_loc2_.units,_loc2_.type),true);
         }
      }
      
      private function addResourceIcon(param1:int) : void
      {
         var _loc2_:String = WorldResourceManager.instance.resourceInfo[param1].mediumIcon;
         updateOverlay();
         stateMachine.propertyBag.setProperty(this.overlayIconNameProperty,_loc2_);
      }
      
      private function onResourceMarketRemove(param1:ResourceMarketEvent) : void
      {
         var _loc2_:Object = param1.eventData;
         if(_loc2_ != null)
         {
            TransactionManager.addTransaction(new TMarketRemove(param1.targetObject as Market,stateMachine.propertyBag as IEntity,_loc2_.item,_loc2_.units),true);
         }
      }
      
      private function onResourceMarketBuy(param1:ResourceMarketEvent) : void
      {
         var _loc2_:Object = param1.eventData;
         var _loc3_:GameDataComponent = GameDataComponent(IEntity(owner).lookupComponentByType(GameDataComponent));
         if(Boolean(_loc3_ && param1.marketId != 0) && Boolean(_loc3_.id == param1.marketId) && _loc2_ != null)
         {
            TransactionManager.addTransaction(new TMarketBuy(param1.targetObject as Market,stateMachine.propertyBag as IEntity,_loc2_.type,_loc2_.item,_loc2_.units,_loc2_.price,ZGlobal.getTransactionId()),true);
         }
      }
      
      private function onResourceMarketHostItemChanged(param1:ResourceMarketEvent) : void
      {
         this.updateItem(param1.eventData);
      }
      
      private function onResourceMarketGuestItemChanged(param1:ResourceMarketEvent) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent(IEntity(owner).lookupComponentByType(GameDataComponent));
         if(Boolean(_loc2_) && Boolean(param1.marketId != 0) && _loc2_.id == param1.marketId)
         {
            this.updateItem(param1.eventData);
         }
      }
      
      private function updateItem(param1:Object) : void
      {
         if(param1 == null || param1.length == 0 || param1.units == 0)
         {
            this.m_currentlySelling = null;
         }
         else
         {
            this.m_currentlySelling = param1;
         }
         var _loc2_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         this.overrideAndUpdateOverlay(_loc2_);
      }
      
      private function onResourceDialogUpdate(param1:WorldEvent) : void
      {
         var _loc3_:GameItem = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Player = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Dictionary = null;
         var _loc10_:GameItem = null;
         var _loc11_:String = null;
         var _loc12_:LocalizationObjectToken = null;
         var _loc13_:* = 0;
         var _loc14_:Object = null;
         var _loc2_:GameDataComponent = GameDataComponent(IEntity(owner).lookupComponentByType(GameDataComponent));
         if(Boolean(_loc2_) && Boolean(param1.eventData.target) && param1.eventData.target == _loc2_.id)
         {
            if(param1.eventData.id == "market.buy")
            {
               if(param1.eventData.sellout)
               {
                  this.m_currentlySelling = null;
               }
               _loc4_ = null;
               if(param1.eventData.type == Market.TYPE_RESOURCE)
               {
                  _loc7_ = WorldResourceManager.instance.getResourceTypeFromIndex(param1.eventData.item);
                  _loc4_ = {
                     "numItems":param1.eventData.units,
                     "item":ZGameUtils.ZlocTk("Items",_loc7_ + "_sentenceName","plural")
                  };
                  _loc5_ = "MarketPurchaseMessage_Object";
               }
               else
               {
                  if(param1.eventData.type != Market.TYPE_BUILDABLE)
                  {
                     return;
                  }
                  _loc8_ = param1.eventData.item;
                  _loc9_ = WorldUnitManager.instance.getUnavailableUnits(WorldUnitManager.UNIT_IN_MARKET);
                  if(_loc9_[_loc8_])
                  {
                     _loc13_ = int(Math.min(param1.eventData.units,_loc9_[_loc8_]));
                     while(_loc13_ > 0)
                     {
                        WorldUnitManager.instance.destroyUnit(_loc8_,WorldUnitManager.UNIT_IN_MARKET);
                        _loc13_--;
                     }
                  }
                  _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc8_,GameItem) as GameItem;
                  _loc11_ = param1.eventData.units > 1 ? "plural" : "singular";
                  _loc12_ = _loc10_.getSentenceNameLocalizationObject(_loc11_,true);
                  if(_loc12_)
                  {
                     _loc4_ = {
                        "numItems":param1.eventData.units,
                        "item":_loc12_
                     };
                     _loc5_ = "MarketPurchaseMessage_Object";
                  }
                  else
                  {
                     _loc4_ = {
                        "numItems":param1.eventData.units,
                        "item":_loc10_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                        "unit":ZGameUtils.ZlocTk("Objects","unit","",param1.eventData.units)
                     };
                     _loc5_ = "MarketPurchaseMessage";
                  }
               }
               _loc6_ = ZGlobal.player.findFriendById(param1.eventData.visitor);
               if((Boolean(_loc6_)) && param1.eventData.targetUser == ZGlobal.player.uid)
               {
                  _loc4_["user"] = ZGameUtils.ZlocTn(_loc6_.firstName,_loc6_.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC);
                  _loc4_["numCoins"] = param1.eventData.spent;
                  _loc4_["coin"] = ZGameUtils.ZlocTk("Objects","coin","",param1.eventData.spent);
                  PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs",_loc5_,_loc4_)));
               }
            }
            else if(param1.eventData.id == "market.add" || param1.eventData.id == "market.remove")
            {
               _loc14_ = {
                  "type":param1.eventData.type,
                  "units":param1.eventData.units,
                  "item":param1.eventData.item
               };
               if(_loc14_.units == 0)
               {
                  this.m_currentlySelling = null;
               }
               else
               {
                  this.m_currentlySelling = _loc14_;
               }
            }
            _loc3_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            this.overrideAndUpdateOverlay(_loc3_);
         }
      }
      
      override public function sell() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         super.sell();
         if(Boolean(this.m_currentlySelling) && this.m_currentlySelling.units > 0)
         {
            if(this.m_currentlySelling.type == Market.TYPE_RESOURCE)
            {
               _loc1_ = WorldResourceManager.instance.getResourceTypeFromIndex(this.m_currentlySelling.item);
               ZGlobal.player.resources.updateResourceAmount(_loc1_,this.m_currentlySelling.units);
            }
            else if(this.m_currentlySelling.type == Market.TYPE_BUILDABLE)
            {
               _loc2_ = 0;
               while(_loc2_ < this.m_currentlySelling.units)
               {
                  ZGlobal.player.addToInventory(this.m_currentlySelling.item);
                  _loc2_++;
               }
            }
            this.m_currentlySelling = null;
         }
      }
      
      override protected function shouldShowOverlay() : Object
      {
         return {
            "show":true,
            "data":m_data
         };
      }
   }
}

