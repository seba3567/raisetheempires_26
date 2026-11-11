package displays.screens.pickUnitsScreen
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleCampaign;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.PVPManager;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.challengesScreen.ChallengePremiumUnitsGrid;
   import displays.screens.gridScreen.GridSlot;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TBuyItem;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class UnitsPurchaseDialog extends ZGamePopUp
   {
      
      public static const UNIT_PURCHASED:String = "unitPurchased";
      
      private var m_subtype:String;
      
      private var m_premiumUnitsGrid:ChallengePremiumUnitsGrid = null;
      
      protected var m_closeOnPurchase:Boolean = true;
      
      private var m_levelLimit:int = 0;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_prioritiseSupportUnits:Boolean = false;
      
      public function UnitsPurchaseDialog(param1:String, param2:Boolean, param3:int = 0)
      {
         this.m_prioritiseSupportUnits = param2;
         this.m_subtype = param1;
         this.m_levelLimit = param3;
         super(ZGlobal.getAssetURL("assets/displays/screens/UnitsPurchaseDialog.swf"));
      }
      
      public static function display(param1:String, param2:int, param3:Boolean) : void
      {
         WindowManager.instance.push(new UnitsPurchaseDialog(param1,param3,param2));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         initDialog();
         var _loc2_:Class = param1.getAssetClass("MainScreen_mc");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.background_mc.width;
         this.contentHeight = m_window.background_mc.height;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.processTextField(m_window.caption_tf,ZGameUtils.ZlocT("Dialogs","PickPremiumUnitsHeader"));
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClick,false,0,true);
         UIDispatcher.instance.addEventListener(GridSlot.PURCHASE,this.onSlotPurchase,false,0,true);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         this.m_premiumUnitsGrid = new ChallengePremiumUnitsGrid(m_window,param1,this,this.m_subtype,0,this.m_prioritiseSupportUnits,this.m_levelLimit);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function dispose() : void
      {
         deinitDialog();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         UIDispatcher.instance.removeEventListener(GridSlot.PURCHASE,this.onSlotPurchase);
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClick);
         this.m_premiumUnitsGrid.dispose();
         this.m_premiumUnitsGrid = null;
      }
      
      protected function onSlotPurchase(param1:WorldEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:LocalizationObjectToken = null;
         var _loc7_:GenericPopup = null;
         var _loc2_:GridSlot = GridSlot(param1.eventData);
         var _loc3_:UnitItem = UnitItem(_loc2_.getData().item);
         if(ZGlobal.player.canBuyCash(UnitItem(_loc3_).cash,true))
         {
            _loc5_ = ZGameUtils.CashTokenReplacements(_loc3_.cash);
            _loc6_ = _loc3_.getSentenceNameLocalizationObject("singular,definite",true);
            if(_loc6_)
            {
               _loc5_.unit = _loc6_;
               _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmUnitPurchaseMessage_Object",_loc5_);
            }
            else
            {
               _loc5_.unit = _loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmUnitPurchaseMessage",_loc5_);
            }
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_.cash))
            {
               _loc7_ = GenericPopup2B.NewYesNo(_loc4_,ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle"),this.onConfirmPopupClose);
               _loc7_.userData = _loc2_;
               PopupManager.instance.push(_loc7_);
            }
            else
            {
               this.buyUnit(_loc2_);
            }
         }
      }
      
      private function onConfirmPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.OK)
         {
            this.buyUnit(param1.userData as GridSlot);
         }
      }
      
      protected function onExitClick(param1:MouseEvent = null) : void
      {
         this.dispose();
         close();
      }
      
      private function buyUnit(param1:GridSlot) : void
      {
         var _loc2_:Object = param1.getData();
         var _loc3_:Boolean = Boolean(_loc2_.useCash) && _loc2_.useCash == true;
         var _loc4_:UnitItem = UnitItem(_loc2_.item);
         ZGlobal.player.buyItem(GameItem(_loc4_),_loc3_);
         ZGlobal.player.addToInventory(_loc4_.code);
         var _loc5_:Battle = ZGameStats.currentBattle;
         var _loc6_:int = _loc5_ ? Battle.BATTLE_STATE_SETUP : Battle.BATTLE_STATE_NONE;
         var _loc7_:Boolean = _loc5_ is BattleCampaign;
         var _loc8_:Boolean = _loc5_.isQuestTreeBattle;
         var _loc9_:Boolean = _loc5_.isDominationMode;
         var _loc10_:Boolean = _loc5_.isQuestSurvival;
         var _loc11_:Boolean = _loc5_.isDeathMatchBattle;
         var _loc12_:Object = {
            "combatPhase":_loc6_,
            "isQuestSurvival":_loc10_,
            "deathmatch":_loc11_,
            "inCampaign":_loc7_,
            "gpvp":PVPManager.instance.isVisitGlobalPVP(),
            "questTree":_loc8_,
            "dominance":_loc9_
         };
         TransactionManager.addTransaction(new TBuyItem(_loc4_.code,_loc3_,1,_loc12_));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UNIT_PURCHASED,_loc4_));
         if(this.m_closeOnPurchase)
         {
            this.onExitClick();
         }
      }
   }
}

