package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.DecorationTargetComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gamemode.GMContract;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.managers.WorldObjectManager;
   import core.ui.UI;
   import displays.screens.ElementZColliderContractScreen;
   import displays.screens.MarketGuest;
   import displays.screens.MarketHost;
   import displays.screens.MasteryFactoryContractsScreen;
   import displays.screens.MechLabActivationScreen;
   import displays.screens.MechLabConsumableScreen;
   import displays.screens.MechLabProductionScreen;
   import displays.screens.MissionContractsScreen;
   import displays.screens.ResourceContractsScreen;
   import displays.screens.Store;
   import displays.screens.UnitContractsEnhancementScreen;
   import displays.screens.UnitContractsScreen;
   import displays.screens.blackMarket.BlackMarketContractScreen;
   import displays.screens.blackMarket.BlackMarketTradeScreen;
   import displays.screens.partsGather.MechLabPartsGather;
   import displays.screens.researchScreens.ResearchUnitSelectionScreen;
   import displays.screens.supportUnitContractScreen.SupportUnitContractsScreen;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import transactions.TBuildingReward;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.WindowManager;
   
   public class DialogState extends SimpleClickState
   {
      
      protected static var m_window:PopUpBase;
      
      private static var dialogTypes:Array = [MarketGuest,MarketHost,MasteryFactoryContractsScreen,MechLabPartsGather,MechLabActivationScreen,MechLabConsumableScreen,MechLabProductionScreen,MissionContractsScreen,ResearchUnitSelectionScreen,ResourceContractsScreen,SupportUnitContractsScreen,UnitContractsScreen,UnitContractsEnhancementScreen,ElementZColliderContractScreen,BlackMarketTradeScreen,BlackMarketContractScreen];
      
      private var m_referenceItemType:String;
      
      private var m_referenceItemSubtype:String = null;
      
      protected var m_rewardHelper:RewardHelper = null;
      
      public function DialogState(param1:BehaviorStateInit)
      {
         super(param1);
         this.m_referenceItemType = param1.m_gameItem.referenceType;
         this.m_referenceItemSubtype = param1.m_gameItem.referenceSubtype;
      }
      
      override public function onClick(param1:Event) : void
      {
         this.showDialog();
      }
      
      protected function getClassName() : String
      {
         return m_data..@dialogClassName.toString();
      }
      
      protected function getQualifiedDialogClassName() : String
      {
         if(this.getClassName().toString().length > 0)
         {
            return "displays.screens." + this.getClassName();
         }
         return null;
      }
      
      protected function showDialog() : void
      {
         var _loc1_:Class = null;
         if(this.getClassName() == "Store")
         {
            UI.instance.displayStoreDialog({"tab":Store.TAB_EXPANSION_LABEL});
         }
         else
         {
            _loc1_ = getDefinitionByName(this.getQualifiedDialogClassName()) as Class;
            this.window = new _loc1_(stateMachine.propertyBag,this.m_referenceItemType,this.m_referenceItemSubtype);
            WindowManager.instance.push(this.window);
         }
      }
      
      protected function giveBonus() : Boolean
      {
         return false;
      }
      
      protected function onPopupClose(param1:GenericPopupEvent) : void
      {
         this.m_rewardHelper.execute();
         TransactionManager.addTransaction(new TBuildingReward(IEntity(stateMachine.propertyBag)));
         this.showDialog();
      }
      
      protected function addWindowListeners() : void
      {
         this.window.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
         this.window.addEventListener(MarketEvent.MARKET_BUY,this.onBuy,false,0,true);
         this.window.addEventListener(MarketEvent.MARKET_BUY_WITH_MASTERY_TOKENS,this.onBuyWithMasteryTokens,false,0,true);
      }
      
      protected function removeWindowListeners() : void
      {
         this.window.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
         this.window.removeEventListener(MarketEvent.MARKET_BUY,this.onBuy);
         this.window.removeEventListener(MarketEvent.MARKET_BUY_WITH_MASTERY_TOKENS,this.onBuyWithMasteryTokens);
      }
      
      public function get window() : PopUpBase
      {
         return m_window;
      }
      
      public function set window(param1:PopUpBase) : void
      {
         if(m_window == param1)
         {
            return;
         }
         if(m_window != null)
         {
            this.removeWindowListeners();
         }
         m_window = param1;
         if(m_window != null)
         {
            this.addWindowListeners();
         }
      }
      
      protected function onCloseClick(param1:CloseEvent) : void
      {
         this.window = null;
      }
      
      public function buy(param1:GameItem, param2:Boolean, param3:Boolean = false) : void
      {
         var _loc9_:Dictionary = null;
         var _loc10_:String = null;
         var _loc11_:GameDataComponent = null;
         var _loc12_:GameItem = null;
         var _loc13_:BuildingFSMComponent = null;
         var _loc4_:Dictionary = this.decoDiscountInfo;
         var _loc5_:Boolean = param1.usesCashOnly();
         var _loc6_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         var _loc7_:String = _loc6_.code;
         if(_loc7_ != BlackMarketContractScreen.BUILDINGCODE)
         {
            ZGlobal.player.buyItem(param1,_loc5_,1,null,param3,_loc4_);
         }
         m_stateMachine.storeReferenceData(param1.name);
         var _loc8_:Boolean = false;
         if(_loc6_.isMultiContract() && !_loc6_.shouldExitContractMode() && ZGlobal.player.canBuy(param1,false) && WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc7_) > 1)
         {
            _loc9_ = WorldObjectManager.instance.getObjectsBySubType(_loc6_.type,_loc6_.subType);
            for(_loc10_ in _loc9_)
            {
               if(_loc9_[_loc10_])
               {
                  _loc11_ = GameDataComponent(_loc9_[_loc10_].lookupComponentByType(GameDataComponent));
                  _loc12_ = _loc11_.gameData;
                  if(_loc12_.code == _loc7_ && _loc10_ != IEntity(stateMachine.propertyBag).name)
                  {
                     _loc13_ = BuildingFSMComponent(_loc9_[_loc10_].lookupComponentByType(BuildingFSMComponent));
                     if((Boolean(_loc13_)) && Boolean(_loc13_.stateMachine.currentState is DialogState) && !(_loc13_.stateMachine.currentState is AutoDialogState))
                     {
                        if(!param2)
                        {
                           GameModeManager.instance.addGameMode(new GMContract(_loc7_,param1),false);
                           break;
                        }
                        _loc8_ = true;
                     }
                  }
               }
            }
         }
         if(param2 && !_loc8_)
         {
            GameModeManager.instance.getTopGameMode().exitMode();
         }
         clickNextState();
      }
      
      private function onBuy(param1:MarketEvent = null) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(param1.item,GameItem) as GameItem;
         this.buy(_loc2_,false);
         m_window.removeEventListener(MarketEvent.MARKET_BUY,this.onBuy);
      }
      
      private function onBuyWithMasteryTokens(param1:MarketEvent = null) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(param1.item,GameItem) as GameItem;
         this.buy(_loc2_,false,true);
         m_window.removeEventListener(MarketEvent.MARKET_BUY_WITH_MASTERY_TOKENS,this.onBuy);
      }
      
      override protected function getSetStateReferenceItemName() : String
      {
         var _loc1_:GameItem = null;
         if(stateMachine.referenceItemName)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
            return _loc1_.code;
         }
         return null;
      }
      
      protected function get decoDiscountInfo() : Dictionary
      {
         var _loc1_:DecorationTargetComponent = owner.lookupComponentByType(DecorationTargetComponent) as DecorationTargetComponent;
         if(_loc1_)
         {
            return _loc1_.getDiscount();
         }
         return null;
      }
   }
}

