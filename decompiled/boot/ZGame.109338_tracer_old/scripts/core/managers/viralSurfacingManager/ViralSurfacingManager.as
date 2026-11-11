package core.managers.viralSurfacingManager
{
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.FriendManager;
   import core.managers.PVPManager;
   import core.managers.WorldObjectManager;
   import core.managers.ZRTManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.deathMatchManager.DeathMatchPopUp;
   import core.managers.promoManager.PromoManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.ui.CombatToaster;
   import core.ui.ImpulsePurchasePopUp;
   import core.ui.LightningDealPurchasePopup;
   import core.ui.SurvivalModePopUp;
   import core.ui.UIManager;
   import core.ui.ViralSurfacePopup;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.FriendsBarMessageTabUIItem;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import utils.ZGameTimeUtil;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class ViralSurfacingManager extends EventDispatcher
   {
      
      public static var POPUP_CLOSED:String = "popupClosed";
      
      public static var instance:ViralSurfacingManager = new ViralSurfacingManager();
      
      private static var DEFAULT_INTERVAL_SECONDS:int = 120;
      
      private static var DEFAULT_DURATION_SECONDS:int = 7;
      
      private static var FIRST_IMPULSE_PURCHASE_DELAY:int = 10;
      
      private static var IMPULSE_PURCHASE_TIMEOUT:int = 15;
      
      private static var FIRST_LIGHTNINGDEAL_PURCHASE_DELAY:int = 10;
      
      private static var FIRST_SURVIVAL_MODE_DELAY:int = 10;
      
      private static var SURVIVAL_MODE_TIMEOUT:int = 15;
      
      private static var SURVIVAL_MODE_NEXT_SHOW_GAP:int = 720;
      
      private static var FIRST_COMBAT_DELAY:int = 10;
      
      private static var COMBAT_TIMEOUT:int = 15;
      
      private static var COMBAT_SHOW_GAP:int = 720;
      
      public static const COMBAT_NO_ENERGY:String = "COMBAT_NO_ENERGY";
      
      public static const COMBAT_DOUBLE_XP:String = "COMBAT_DOUBLE_XP";
      
      public static const COMBAT_HALF_RANSOM:String = "COMBAT_HALF_RANSOM";
      
      private var m_xml:XML;
      
      private var m_currentVariant:XML;
      
      private var m_intervalSeconds:int = DEFAULT_INTERVAL_SECONDS;
      
      private var m_durationSeconds:int = DEFAULT_DURATION_SECONDS;
      
      private var m_typesThisSession:Array = new Array();
      
      private var m_seenTypes:Array;
      
      private var m_seenCounts:Object;
      
      private var m_activeInfos:Array = new Array();
      
      private var m_activeImpulsePurchases:Array = new Array();
      
      private var m_lightningDealChecked:Boolean;
      
      private var m_cachedSurfacingContainer:MovieClip;
      
      private var m_shownDeathMatchToaster:Boolean = false;
      
      private var m_survivalModeChecked:Boolean;
      
      private var m_isCombatToasterShown:Boolean = false;
      
      private var m_combatToasterType:String;
      
      public function ViralSurfacingManager()
      {
         super();
      }
      
      public function get surfacingContainer() : MovieClip
      {
         if(this.m_cachedSurfacingContainer)
         {
            return this.m_cachedSurfacingContainer;
         }
         var _loc1_:ContextualBarUIItem = UIManager.instance.getMenuItemByName(ContextualBarUIItem.ITEM_ID) as ContextualBarUIItem;
         if(!_loc1_)
         {
            return null;
         }
         this.m_cachedSurfacingContainer = _loc1_.viralNotificationContainer;
         return this.m_cachedSurfacingContainer;
      }
      
      public function setSeenFlags(param1:Array) : void
      {
         this.m_seenTypes = param1;
      }
      
      public function setSeenCounts(param1:Object) : void
      {
         this.m_seenCounts = param1;
      }
      
      public function initialize(param1:XML) : void
      {
         var variant:int = 0;
         var list:XMLList = null;
         var variantXML:XML = null;
         var delay:int = 0;
         var xml:XML = param1;
         this.m_xml = xml;
         this.initializeImpulsePurchaseInfos();
         variant = ExperimentsManager.instance.getExperimentVariant("empire_viral_surfacing");
         list = this.m_xml.variantInfo.variant.(@value == variant);
         if(Boolean(list) && Boolean(list.length()))
         {
            variantXML = list[0];
            if(variantXML.@interval != undefined)
            {
               this.m_intervalSeconds = ZGameTimeUtil.instance.parseTimeAsSeconds(variantXML.@interval.toString(),0);
            }
            if(variantXML.@duration != undefined)
            {
               this.m_durationSeconds = ZGameTimeUtil.instance.parseTimeAsSeconds(variantXML.@duration.toString(),0);
            }
            if(variantXML.@infos != undefined)
            {
               this.initializeInfos(variantXML.@infos.toString());
            }
         }
         if(ZGlobal.player.hasLightningDeal)
         {
            Zlab.processManager.schedule(FIRST_LIGHTNINGDEAL_PURCHASE_DELAY * 1000,this,this.surfaceNextPopup);
         }
         else if(Boolean(this.m_activeImpulsePurchases) && Boolean(this.m_activeImpulsePurchases.length))
         {
            Zlab.processManager.schedule(FIRST_IMPULSE_PURCHASE_DELAY * 1000,this,this.surfaceNextPopup);
         }
         else if(this.showSurvialModeToaster())
         {
            Zlab.processManager.schedule(FIRST_SURVIVAL_MODE_DELAY * 1000,this,this.surfaceNextPopup);
         }
         else if(this.showCombatToaster())
         {
            Zlab.processManager.schedule(FIRST_COMBAT_DELAY * 1000,this,this.surfaceNextPopup);
         }
         else if(Boolean(this.m_activeInfos) && Boolean(this.m_activeInfos.length) && this.m_xml.@firstSurfaceDelay != undefined)
         {
            delay = ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_xml.@firstSurfaceDelay.toString(),0);
            Zlab.processManager.schedule(delay * 1000,this,this.surfaceNextPopup);
         }
         addEventListener(POPUP_CLOSED,this.onPopupClosed,false,0,true);
      }
      
      private function onPopupClosed(param1:Event) : void
      {
         this.disposePopup();
         Zlab.processManager.schedule(this.m_intervalSeconds * 1000,this,this.onIntervalDone);
      }
      
      private function get inIslandMode() : Boolean
      {
         var _loc1_:GameMode = GameModeManager.instance.getTopGameMode();
         return Boolean(_loc1_) && _loc1_ is GMIsland;
      }
      
      private function surfaceNextPopup() : void
      {
         if(!PVPManager.instance.isStrangerBarStable)
         {
            PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGPVPUIStateChange,false,0,true);
         }
         else if(!this.inIslandMode)
         {
            GameModeManager.instance.addEventListener(GMIsland.ISLAND_MODE_ENTERED,this.onIslandModeEntered,false,0,true);
         }
         else if(!FriendManager.instance.friendInfoReceived)
         {
            FriendManager.instance.addEventListener(FriendManager.FRIEND_INFO_RECEIVED,this.onFriendInfoReceived,false,0,true);
         }
         else if(this.messageTabsVisible)
         {
            UIDispatcher.instance.addEventListener(FriendsBarMessageTabUIItem.FINISHED,this.onMessageTabsFinished,false,0,true);
         }
         else
         {
            this.launchNextSurfacing();
         }
      }
      
      private function onMessageTabsFinished(param1:Event) : void
      {
         UIDispatcher.instance.removeEventListener(FriendsBarMessageTabUIItem.FINISHED,this.onMessageTabsFinished);
         this.surfaceNextPopup();
      }
      
      private function get messageTabsVisible() : Boolean
      {
         var _loc1_:Object = {"numVisible":0};
         UIDispatcher.instance.dispatchEvent(new WorldEvent(FriendsBarMessageTabUIItem.GET_NUM_VISIBLE,_loc1_));
         return _loc1_.numVisible > 0;
      }
      
      private function onFriendInfoReceived(param1:Event) : void
      {
         FriendManager.instance.removeEventListener(FriendManager.FRIEND_INFO_RECEIVED,this.onFriendInfoReceived);
         this.surfaceNextPopup();
      }
      
      private function onIslandModeEntered(param1:Event) : void
      {
         GameModeManager.instance.removeEventListener(GMIsland.ISLAND_MODE_ENTERED,this.onIslandModeEntered);
         this.surfaceNextPopup();
      }
      
      private function onGPVPUIStateChange(param1:WorldEvent) : void
      {
         if(PVPManager.instance.isStrangerBarStable)
         {
            PVPManager.instance.removeEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGPVPUIStateChange);
            this.surfaceNextPopup();
         }
      }
      
      private function getSeenCounts(param1:String) : int
      {
         if(!this.m_seenCounts)
         {
            return 0;
         }
         if(!this.m_seenCounts.hasOwnProperty(param1))
         {
            return 0;
         }
         return this.m_seenCounts[param1];
      }
      
      private function launchNextSurfacing() : void
      {
         var code:String = null;
         var next:Object = null;
         var info:String = null;
         var list:XMLList = null;
         var gpvpBackground:Boolean = false;
         var newPopup:ViralSurfacePopup = null;
         var container:MovieClip = this.surfacingContainer;
         if(!container)
         {
            return;
         }
         if(!this.m_lightningDealChecked)
         {
            this.m_lightningDealChecked = true;
            if(ZGlobal.player.hasLightningDeal && ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_CURRENT) > 0)
            {
               code = ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_ITEMCODE);
               if(code)
               {
                  this.surfaceLightningDeal(code,container);
                  return;
               }
            }
         }
         if(this.showDeathMatchToaster())
         {
            this.surfaceDeathMatchToaster(container);
            return;
         }
         if(this.showCombatToaster())
         {
            this.surfaceCombatToaster(container);
            return;
         }
         if(this.showSurvialModeToaster())
         {
            this.surfaceSurvialModeToaster(container);
            return;
         }
         if(!(Boolean(this.m_activeImpulsePurchases) && Boolean(this.m_activeImpulsePurchases.length)))
         {
            while(Boolean(this.m_activeInfos) && Boolean(this.m_activeInfos.length))
            {
               info = this.m_activeInfos.shift();
               list = this.m_xml.viralInfo.info.(@type == info);
               if(Boolean(list) && Boolean(list.length()))
               {
                  gpvpBackground = PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_ACTIVE;
                  newPopup = ViralSurfacePopup.create(list[0],this.getSeenCounts(info),this.m_durationSeconds,gpvpBackground);
                  if(newPopup)
                  {
                     container.addChild(newPopup);
                     break;
                  }
               }
            }
            return;
         }
         next = this.m_activeImpulsePurchases.shift();
         this.surfaceImpulsePurchase(next,container);
      }
      
      private function surfaceLightningDeal(param1:String, param2:MovieClip) : void
      {
         var _loc3_:LightningDealPurchasePopup = new LightningDealPurchasePopup(param1);
         param2.addChild(_loc3_);
      }
      
      private function surfaceImpulsePurchase(param1:Object, param2:MovieClip) : void
      {
         var _loc3_:ImpulsePurchasePopUp = ImpulsePurchasePopUp.create(param1,IMPULSE_PURCHASE_TIMEOUT);
         if(_loc3_)
         {
            param2.addChild(_loc3_);
         }
      }
      
      private function onIntervalDone() : void
      {
         this.surfaceNextPopup();
      }
      
      private function disposePopup() : void
      {
         var _loc1_:MovieClip = this.surfacingContainer;
         while(_loc1_.numChildren)
         {
            _loc1_.removeChildAt(0);
         }
      }
      
      private function initializeInfos(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.split(",");
         if(Boolean(_loc2_) && Boolean(_loc2_.length))
         {
            if(Boolean(this.m_seenTypes) && Boolean(this.m_seenTypes.length))
            {
               for each(_loc3_ in _loc2_)
               {
                  if(this.m_seenTypes.indexOf(_loc3_) < 0)
                  {
                     this.m_activeInfos.push(_loc3_);
                  }
               }
            }
            else
            {
               this.m_activeInfos = _loc2_;
            }
         }
      }
      
      private function initializeImpulsePurchaseInfos() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:GameItem = null;
         var _loc4_:Object = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_IMPULSE_PURCHASE) == ExperimentsManager.VARIANT_IMPULSE_PURCHASE_ENABLED)
         {
            if(PromoManager.instance.impulsePurchases != null)
            {
               _loc1_ = PromoManager.instance.impulsePurchases;
               for(_loc2_ in _loc1_)
               {
                  if(!(_loc1_[_loc2_].nonPayer == 1 && ZGlobal.player.isPayingUser()))
                  {
                     if(!(_loc1_[_loc2_].nonPayer == 0 && !ZGlobal.player.isPayingUser()))
                     {
                        if(_loc1_[_loc2_].level <= ZGlobal.player.level)
                        {
                           _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_ as String,GameItem) as GameItem;
                           if(ZGlobal.player.canAddItemToInventory(_loc3_))
                           {
                              if(!(_loc3_.limit != GameItem.LIMIT_UNLIMITED && WorldObjectManager.instance.getNumberObjectsWithCode(_loc2_ as String) >= _loc3_.limit))
                              {
                                 _loc4_ = new Object();
                                 _loc4_.code = _loc2_;
                                 _loc4_.discount = _loc1_[_loc2_].discount;
                                 _loc4_.unlock = _loc1_[_loc2_].unlock;
                                 this.m_activeImpulsePurchases.push(_loc4_);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function showSurvialModeToaster() : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_ENHANCEMENTS) != ExperimentsManager.VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED)
         {
            return false;
         }
         var _loc1_:Date = new Date();
         var _loc2_:Number = _loc1_.time / 60000;
         if(SurvivalModeManager.instance.getSetInProgress() != null && _loc2_ - ZGlobal.player.m_survialModeToasterTime >= SURVIVAL_MODE_NEXT_SHOW_GAP)
         {
            return true;
         }
         return false;
      }
      
      private function showDeathMatchToaster() : Boolean
      {
         if(DeathMatchManager.instance.isActive)
         {
            if(!this.m_shownDeathMatchToaster)
            {
               this.m_shownDeathMatchToaster = true;
               return true;
            }
         }
         return false;
      }
      
      private function surfaceSurvialModeToaster(param1:MovieClip) : void
      {
         var _loc2_:SurvivalModePopUp = SurvivalModePopUp.create(SURVIVAL_MODE_TIMEOUT);
         if(_loc2_)
         {
            param1.addChild(_loc2_);
         }
      }
      
      private function surfaceDeathMatchToaster(param1:MovieClip) : void
      {
         var _loc2_:DeathMatchPopUp = DeathMatchPopUp.create(SURVIVAL_MODE_TIMEOUT);
         if(_loc2_)
         {
            param1.addChild(_loc2_);
         }
      }
      
      private function showCombatToaster() : Boolean
      {
         var _loc1_:Boolean = false;
         if(!this.m_isCombatToasterShown)
         {
            if(ExperimentsManager.instance.getExperimentVariant("empire_combat_no_energy") > 1 && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_NO_ENERGY))
            {
               this.m_combatToasterType = COMBAT_NO_ENERGY;
               _loc1_ = true;
            }
            else if(ExperimentsManager.instance.getExperimentVariant("empire_combat_half_ransom") > 1 && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_HALF_RANSOM))
            {
               this.m_combatToasterType = COMBAT_HALF_RANSOM;
               _loc1_ = true;
            }
            else if(ExperimentsManager.instance.getExperimentVariant("empire_combat_double_xp") > 1 && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_DOUBLE_XP))
            {
               this.m_combatToasterType = COMBAT_DOUBLE_XP;
               _loc1_ = true;
            }
         }
         return _loc1_;
      }
      
      private function surfaceCombatToaster(param1:MovieClip) : void
      {
         var _loc2_:CombatToaster = CombatToaster.create(COMBAT_TIMEOUT,this.m_combatToasterType);
         if(_loc2_)
         {
            this.m_isCombatToasterShown = true;
            param1.addChild(_loc2_);
         }
      }
   }
}

