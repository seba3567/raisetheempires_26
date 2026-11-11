package core.ui
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GMRoadPlacementSingleClick;
   import core.gamemode.GameModeManager;
   import core.gamemode.expansion.GMExpansion;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.PVPManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.viralsManager.ViralsManager;
   import dispatchers.UIDispatcher;
   import displays.popups.DominanceLevelUp;
   import displays.popups.GenericPopup;
   import displays.popups.LevelUp;
   import displays.popups.PVPWelcomePopup;
   import displays.popups.SocialLevelUp;
   import displays.screens.InventoryDialog;
   import displays.screens.Store;
   import events.EnergyMarketEvent;
   import events.MarketEvent;
   import flash.events.MouseEvent;
   import transactions.TBuyItem;
   import transactions.TPurchaseContractUnlock;
   import transactions.TPurchaseUnlock;
   import transactions.TUseItem;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.components.ThinkingComponent;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class UI extends ThinkingComponent
   {
      
      private static var m_instance:UI;
      
      protected static var m_cursors:Array = [];
      
      protected static var m_currentCursor:Object = null;
      
      public function UI()
      {
         super();
      }
      
      public static function get instance() : UI
      {
         if(!m_instance)
         {
            m_instance = new UI();
         }
         return m_instance;
      }
      
      public static function displaySocialLevelUpDialog(param1:int, param2:String, param3:Boolean) : void
      {
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:Array = [];
         _loc5_.push(param2);
         var _loc9_:SocialLevelUp = new SocialLevelUp(param1,_loc5_,_loc6_,_loc7_,_loc8_,_loc4_,true,param3);
         PopupManager.instance.push(_loc9_,0,true,true,true);
         _loc9_.addEventListener(GenericPopupEvent.SELECTED,onSocialLevelUpClosed);
      }
      
      protected static function onSocialLevelUpClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         param1.target.removeEventListener(GenericPopupEvent.SELECTED,onLevelUpClosed);
         if(param1.target.isSocialXpGood())
         {
            _loc2_ = ZGlobal.player.socialLevelGood;
            _loc3_ = "level_up_social_good";
         }
         else
         {
            _loc2_ = ZGlobal.player.socialLevelBad;
            _loc3_ = "level_up_social_bad";
         }
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendFeed(_loc3_,{"level_number":_loc2_},null);
         }
      }
      
      public static function displayDominanceLevelUpDialog(param1:int) : void
      {
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         ZGlobal.gameSettings.getNewLevelItems(param1,_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,"requiredDominanceRank",true);
         var _loc7_:DominanceLevelUp = new DominanceLevelUp(param1,_loc3_,_loc4_,_loc5_,_loc6_,_loc2_,true);
         PopupManager.instance.push(_loc7_,0,true,true,true);
         _loc7_.addEventListener(GenericPopupEvent.SELECTED,onDominanceLevelUpClosed);
      }
      
      protected static function onDominanceLevelUpClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         param1.target.removeEventListener(GenericPopupEvent.SELECTED,onDominanceLevelUpClosed);
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = DominationModeManager.instance.dominanceRank;
            _loc3_ = "dominance_level_up";
            ViralsManager.instance.sendFeed(_loc3_,{"level_number":_loc2_},null);
         }
      }
      
      public static function displayLevelUpDialog(param1:int) : void
      {
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         ZGlobal.gameSettings.getNewLevelItems(param1,_loc2_,_loc3_,_loc4_,_loc5_,_loc6_);
         var _loc7_:LevelUp = new LevelUp(param1,_loc3_,_loc4_,_loc5_,_loc6_,_loc2_);
         PopupManager.instance.push(_loc7_,0,true,true,true);
         _loc7_.addEventListener(GenericPopupEvent.SELECTED,onLevelUpClosed);
      }
      
      protected static function onLevelUpClosed(param1:GenericPopupEvent) : void
      {
         var _loc5_:String = null;
         param1.target.removeEventListener(GenericPopupEvent.SELECTED,onLevelUpClosed);
         var _loc2_:int = ZGlobal.player.level;
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc5_ = ZGameUtils.ZlocT("Levels","Level" + _loc2_);
            ViralsManager.instance.sendFeed("level_up",{
               "level_name":_loc5_.toString(),
               "level_number":_loc2_
            });
         }
         if(_loc2_ == PVPManager.pvpMinLevel)
         {
            PopupManager.instance.push(new PVPWelcomePopup());
         }
      }
      
      public function initialize() : Boolean
      {
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove,false,3);
         return true;
      }
      
      private function onStageMouseMove(param1:MouseEvent) : void
      {
      }
      
      public function displayStoreDialog(param1:Object = null) : void
      {
         WindowManager.instance.push(new Store(param1));
         this.setupForItemPurchase();
      }
      
      public function displayInventoryDialog(param1:String = "unknown") : void
      {
         if(!ZGlobal.player.isInventoryEmpty())
         {
            WindowManager.instance.push(new InventoryDialog());
            this.setupForItemPlacement();
         }
         else
         {
            PopupManager.instance.push(new GenericPopup(ZLoc.t("Dialogs","InventoryEmpty")));
         }
      }
      
      public function setupForItemPurchase() : void
      {
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_BUY,this.onMarketClick,false,0,true);
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_UNLOCK,this.onMarketUnlock,false,0,true);
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_UNLOCK_CONTRACT,this.onMarketUnlockContract,false,0,true);
      }
      
      public function setupForItemPlacement() : void
      {
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_USE,this.onUseClick,false,0,true);
      }
      
      private function onMarketUnlock(param1:MarketEvent) : void
      {
         if(UIDispatcher.instance.hasEventListener(MarketEvent.MARKET_UNLOCK))
         {
            UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_UNLOCK,this.onMarketUnlock);
         }
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(param1.item,GameItem) as GameItem;
         if(_loc2_)
         {
            ZGlobal.player.unlockItem(_loc2_);
            TransactionManager.addTransaction(new TPurchaseUnlock(_loc2_.code));
         }
      }
      
      private function onMarketUnlockContract(param1:MarketEvent) : void
      {
         if(UIDispatcher.instance.hasEventListener(MarketEvent.MARKET_UNLOCK_CONTRACT))
         {
            UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_UNLOCK_CONTRACT,this.onMarketUnlockContract);
         }
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(param1.item,GameItem) as GameItem;
         if(_loc2_)
         {
            ZGlobal.player.unlockContract(_loc2_);
            TransactionManager.addTransaction(new TPurchaseContractUnlock(_loc2_.code,param1.statsInfo));
         }
      }
      
      private function onMarketClick(param1:MarketEvent) : void
      {
         if(UIDispatcher.instance.hasEventListener(MarketEvent.MARKET_BUY))
         {
            UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_BUY,this.onMarketClick);
         }
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:GameItem = null;
         var _loc6_:Boolean = false;
         switch(param1.eventType)
         {
            case MarketEvent.EXPAND_ISLAND:
               _loc5_ = ZGlobal.gameSettings.getItemByCode(param1.item,ExpansionItem) as ExpansionItem;
               GameModeManager.instance.addGameMode(new GMExpansion(_loc5_ as ExpansionItem));
               break;
            case MarketEvent.ROADS:
               GameModeManager.instance.addGameMode(new GMRoadPlacementSingleClick(param1.item,false));
               break;
            case MarketEvent.RESOURCE:
               _loc5_ = ZGlobal.gameSettings.getItemByName(param1.item,GameItem) as GameItem;
               _loc6_ = _loc5_.cash != 0;
               ZGlobal.player.buyItem(_loc5_,_loc6_);
               ZGlobal.player.resources.updateResourceAmount(_loc5_.resourceType,_loc5_.resourceYield);
               TransactionManager.addTransaction(new TBuyItem(_loc5_.code,_loc6_,1,param1.statsInfo));
               break;
            case MarketEvent.CONSUMABLE:
               this.buyAndAddToInventory(param1);
               if(param1.source == MarketEvent.SOURCE_STORE || param1.source == MarketEvent.SOURCE_NONE && !this.onUseClick(param1))
               {
                  PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ItemPlacedIntoInventory")),100);
               }
               break;
            case MarketEvent.BOOSTER:
               if(param1.source == MarketEvent.SOURCE_NONE && !this.onUseClick(param1))
               {
               }
               break;
            default:
               _loc5_ = param1.referenceItem;
               if(_loc5_.notPlaceable)
               {
                  this.buyAndAddToInventory(param1);
               }
               else
               {
                  GameModeManager.instance.addGameMode(new GMObjectPlace(param1.item,param1.source,false,param1.statsInfo));
               }
         }
      }
      
      private function buyAndAddToInventory(param1:MarketEvent) : void
      {
         var _loc2_:GameItem = param1.referenceItem;
         var _loc3_:Boolean = _loc2_.cash != 0;
         ZGlobal.player.buyItem(_loc2_,_loc3_);
         ZGlobal.player.addToInventory(_loc2_.code);
         if(param1 as EnergyMarketEvent)
         {
            if((param1 as EnergyMarketEvent).isRefill)
            {
               TransactionManager.addTransaction(EnergyRefillItem.getRefillPurchaseTransaction(_loc2_.code,_loc3_,1,param1.statsInfo));
            }
            else
            {
               TransactionManager.addTransaction(new TBuyItem(_loc2_.code,_loc3_,1,param1.statsInfo));
            }
         }
         else
         {
            TransactionManager.addTransaction(new TBuyItem(_loc2_.code,_loc3_,1,param1.statsInfo));
         }
      }
      
      private function onUseClick(param1:MarketEvent) : Boolean
      {
         if(UIDispatcher.instance.hasEventListener(MarketEvent.MARKET_USE))
         {
            UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_USE,this.onUseClick);
         }
         var _loc2_:Boolean = false;
         switch(param1.eventType)
         {
            case MarketEvent.BUILDABLE:
               GameModeManager.instance.addGameMode(new GMObjectPlace(param1.item,param1.source));
               _loc2_ = true;
               break;
            case MarketEvent.CONSUMABLE:
               _loc2_ = this.tryUsePlayerEnergies(param1);
               break;
            case MarketEvent.BOOSTER:
               _loc2_ = this.tryUsePlayerEnergies(param1);
         }
         return _loc2_;
      }
      
      private function tryUsePlayerEnergies(param1:MarketEvent) : Boolean
      {
         var _loc6_:int = 0;
         var _loc2_:GameItem = param1.referenceItem;
         var _loc3_:Boolean = false;
         var _loc4_:int = _loc2_.energyYield;
         var _loc5_:int = _loc2_.ammoYield;
         if(_loc4_ > 0)
         {
            ZGlobal.player.m_energy.energy += _loc4_;
            _loc3_ = true;
         }
         else if(_loc5_ > 0)
         {
            ZGlobal.player.m_ammo.ammo += _loc5_;
            _loc3_ = true;
         }
         else
         {
            _loc6_ = _loc2_.manaYield;
            if(_loc6_ > 0)
            {
               ZGlobal.player.mana.give(_loc6_);
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            ZGlobal.player.removeInventoryItem(_loc2_.code);
            if(!(param1 as EnergyMarketEvent) || !(param1 as EnergyMarketEvent).isRefill)
            {
               TransactionManager.addTransaction(new TUseItem(_loc2_.code),true);
            }
         }
         return _loc3_;
      }
   }
}

