package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.campaignManager.CampaignManager;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.popups.genericPopup.NotEnoughMasteryTokensPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MasteryUnitContractSlot extends UnitContractSlot
   {
      
      public static const BUY_MASTERY_UNIT:String = "buymasteryunit";
      
      private var m_isMasteryLocked:Boolean = true;
      
      public function MasteryUnitContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:UnitItem, param9:Number)
      {
         var _loc13_:String = null;
         var _loc14_:int = 0;
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         var _loc10_:int = m_item.cash;
         var _loc11_:Array = CampaignManager.instance.getIslandsForVillain(m_item.villain);
         var _loc12_:int = 0;
         for each(_loc13_ in _loc11_)
         {
            _loc14_ = ZGlobal.player.campaign.getIslandMastery(_loc13_);
            if(_loc14_ >= 3)
            {
               _loc12_++;
            }
         }
         if(_loc12_ >= _loc11_.length)
         {
            m_buildBtn.enable();
            m_buildBtn.callback = this.doOnClick;
            m_buildBtn.text = ZLoc.t("Dialogs","BuildButton_Mastery");
            slot.detail_mc.tokenCost_mc.text = m_item.masteryTokenCost;
            this.m_isMasteryLocked = false;
         }
         else
         {
            super.lockSlot();
            m_buildBtn.disable();
            this.m_isMasteryLocked = true;
            slot.locked_mc.visible = true;
            slot.level_tf.visible = true;
            TextFieldUtil.processTextField(slot.level_tf,ZLoc.t("Tooltips","MasteryExchangeLockedUnit_tooltip"));
         }
         m_buyNowButton = new ZGameButton(slot.emp_bt,this.onBuyClicked);
         m_buyNowButton.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":_loc10_});
         slot.emp_bt.visible = true;
      }
      
      private function onBuyClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BUY_MASTERY_UNIT,{"unitItem":m_item}));
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.doBuyForTokens(param1);
      }
      
      protected function doBuyForTokens(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(!this.m_isMasteryLocked)
         {
            _loc2_ = "VTK";
            _loc3_ = ZGlobal.player.getNumberOfInventoryItems(_loc2_) ? ZGlobal.player.getNumberOfInventoryItems(_loc2_) : 0;
            if(_loc3_ - m_item.masteryTokenCost >= 0)
            {
               m_listener.dispatchEvent(new WorldEvent(CONTRACT_SLOT_PURCHASE,purchaseEventObject()));
            }
            else
            {
               PopupManager.instance.push(new NotEnoughMasteryTokensPopup(ZGameUtils.ZlocT("Dialogs","ImpulseMasteryTokens")),0);
            }
         }
      }
   }
}

