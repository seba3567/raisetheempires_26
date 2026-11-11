package displays.screens.pickConsumableScreen
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleCampaign;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.pickUnitsScreen.PremiumUnitSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import transactions.TBuyItem;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class PremiumConsumableSlot extends ConsumableSlot
   {
      
      public function PremiumConsumableSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:ConsumableItem, param7:Boolean, param8:int, param9:Number)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override protected function get className() : String
      {
         return "PremiumUnitCard";
      }
      
      protected function alwaysConfirmPurchase() : Boolean
      {
         return false;
      }
      
      protected function buyUnitWithGateCheck() : void
      {
         var _loc1_:String = null;
         var _loc2_:Object = null;
         var _loc3_:LocalizationObjectToken = null;
         if(PremiumUnitSlot.checkPremiumGate(m_consumableItem))
         {
            if(this.alwaysConfirmPurchase() || ZGlobal.gameSettings.showConfirmationPopup(m_consumableItem.cash))
            {
               _loc2_ = ZGameUtils.CashTokenReplacements(m_consumableItem.cash);
               _loc3_ = m_consumableItem.getSentenceNameLocalizationObject("singular,definite");
               if(_loc3_)
               {
                  _loc2_.unit = _loc3_;
                  _loc1_ = ZGameUtils.ZlocT("Dialogs","ConfirmUnitPurchaseMessage_Object",_loc2_);
               }
               else
               {
                  _loc2_.unit = m_consumableItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  _loc1_ = ZGameUtils.ZlocT("Dialogs","ConfirmUnitPurchaseMessage",_loc2_);
               }
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc1_,ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle"),this.onPopupClose));
            }
            else
            {
               this.buyUnit(m_consumableItem);
            }
         }
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(param1.target == slot.buy_bt)
         {
            this.buyUnitWithGateCheck();
         }
      }
      
      private function onPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.OK)
         {
            this.buyUnit(m_consumableItem);
         }
      }
      
      private function buyUnit(param1:ConsumableItem) : void
      {
         var _loc2_:Boolean = true;
         ZGlobal.player.buyItem(param1,_loc2_);
         ZGlobal.player.addToInventory(param1.code);
         var _loc3_:Battle = ZGameStats.currentBattle;
         var _loc4_:int = Battle.BATTLE_STATE_ACTIVE;
         var _loc5_:Boolean = (Boolean(_loc4_)) && _loc3_ is BattleCampaign;
         var _loc6_:Boolean = _loc3_.isQuestTreeBattle;
         var _loc7_:Boolean = _loc3_.isDominationMode;
         var _loc8_:Boolean = _loc3_.isDeathMatchBattle;
         var _loc9_:String = "";
         if(_loc6_ && _loc3_.getQuestId != "")
         {
            _loc9_ = _loc3_.getQuestId;
         }
         var _loc10_:Boolean = _loc3_.isQuestSurvival;
         var _loc11_:Object = {
            "combatPhase":_loc4_,
            "isQuestSurvival":_loc10_,
            "deathmatch":_loc8_,
            "inCampaign":_loc5_,
            "gpvp":PVPManager.instance.isVisitGlobalPVP(),
            "questTree":_loc6_,
            "dominance":_loc7_,
            "questId":_loc9_
         };
         TransactionManager.addTransaction(new TBuyItem(param1.code,_loc2_,1,_loc11_));
         screen.dispatchEvent(new WorldEvent(CLICKED,param1));
      }
      
      override protected function filloutStats() : void
      {
         super.filloutStats();
         m_iconLoaders.push(PremiumUnitSlot.setupPremiumSlot(this,m_consumableItem));
      }
   }
}

