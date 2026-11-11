package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.LEUnitDiscountManager;
   import core.managers.TierSurfacingManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.screens.ItemTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class PremiumUnitSlotV2 extends PremiumUnitSlot
   {
      
      private var m_buyBtn:ZGameButton;
      
      private var m_highlightSupportUnit:Boolean = false;
      
      public function PremiumUnitSlotV2(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Number, param8:Boolean)
      {
         if(param8)
         {
            if(param6.secondaryAbility)
            {
               this.m_highlightSupportUnit = true;
            }
         }
         super(param1,param2,param3,param4,param5,param6,param7);
         this.m_buyBtn = new ZGameButton(slot.buy_bt,this.onBuyUnitClicked);
         this.m_buyBtn.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":param6.cash});
         if(!slot.buy_bt.visible)
         {
            this.m_buyBtn.disable();
            this.m_buyBtn.hide();
         }
         else
         {
            this.m_buyBtn.enable();
         }
      }
      
      override public function dispose() : void
      {
         this.m_buyBtn.dispose();
         Tooltip.unsubscribe(slot.unitCard_mc.strengthBar_mc);
         super.dispose();
      }
      
      override protected function filloutStats() : void
      {
         var _loc4_:int = 0;
         super.filloutStats();
         var _loc1_:BitArray = ZGlobal.player.checkGate(m_unitItem);
         var _loc2_:Boolean = _loc1_.isBitSet(Player.GATE_FAILURE_CONTRACT_LOCKED);
         if(_loc2_)
         {
            _loc1_.resetBit(Player.GATE_FAILURE_CONTRACT_LOCKED);
         }
         var _loc3_:Boolean = _loc1_.anyBitSet();
         slot.unitCard_mc.locked_mc.visible = _loc3_;
         slot.unitCard_mc.strengthBar_mc.visible = !_loc3_;
         slot.unitCard_mc.strengthValue_tf.visible = !_loc3_;
         slot.unitCard_mc.secondaryCard_mc.visible = this.m_highlightSupportUnit;
         this.displayDiscountSale();
         if(slot.unitCard_mc.tierRating_mc)
         {
            slot.unitCard_mc.tierRating_mc.visible = false;
            if(TierSurfacingManager.instance.tierSurfacingEnabled && !_loc3_)
            {
               slot.unitCard_mc.tierRating_mc.visible = true;
               _loc4_ = (ZGlobal.gameSettings.getItemByCode(m_unitItem.code,UnitItem) as UnitItem).tier;
               TextFieldUtil.compactTextField(slot.unitCard_mc.tierRating_mc.tier_tf,String(_loc4_));
            }
         }
         if(slot.unitCard_mc.doubleXP_mc)
         {
            slot.unitCard_mc.doubleXP_mc.visible = false;
            if(TierSurfacingManager.instance.tierSurfacing2Enabled && !_loc3_ && m_unitItem.isBlueDevil)
            {
               slot.unitCard_mc.doubleXP_mc.visible = true;
            }
         }
         Tooltip.subscribe(slot.unitCard_mc.strengthBar_mc,ZGameUtils.ZlocT("Tooltips","StrengthTooltip"));
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(m_unitItem.secondaryAbility ? GameItem.SUPPORT_UNIT_TOOLTIP : GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP,m_unitItem);
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      private function onBuyUnitClicked(param1:MouseEvent) : void
      {
         if(checkPremiumGate(m_unitItem))
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(PURCHASE,this));
         }
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.onBuyUnitClicked(param1);
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
      }
      
      private function displayDiscountSale() : void
      {
         var _loc1_:Number = NaN;
         if(slot.unitCard_mc.discount_tf != null)
         {
            if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(m_unitItem.code))
            {
               _loc1_ = Math.floor(LEUnitDiscountManager.instance.getLEOverrideDiscount(m_unitItem.code) * 100);
               if(_loc1_ > 0)
               {
                  if(LEUnitDiscountManager.instance.leDiscountVariant == 3)
                  {
                     TextFieldUtil.compactTextField(slot.unitCard_mc.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc1_}));
                  }
                  else
                  {
                     TextFieldUtil.compactTextField(slot.unitCard_mc.discount_tf,ZGameUtils.ZlocT("Promo","promo_RepeatPackHUD_textSale"));
                  }
                  slot.unitCard_mc.discount_tf.visible = true;
               }
               else
               {
                  slot.unitCard_mc.discount_tf.visible = false;
               }
            }
            else
            {
               slot.unitCard_mc.discount_tf.visible = false;
            }
         }
      }
   }
}

