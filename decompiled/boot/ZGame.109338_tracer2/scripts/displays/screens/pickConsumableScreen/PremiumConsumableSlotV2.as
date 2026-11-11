package displays.screens.pickConsumableScreen
{
   import core.gameobjects.ConsumableItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.screens.pickUnitsScreen.IActionableSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class PremiumConsumableSlotV2 extends PremiumConsumableSlot implements IActionableSlot
   {
      
      private var m_buyBtn:ZGameButton = null;
      
      private var m_imageLoaders:Array = new Array();
      
      public function PremiumConsumableSlotV2(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:ConsumableItem, param7:int, param8:Number)
      {
         super(param1,param2,param3,param4,param5,param6,false,param7,param8);
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_buyBtn.dispose();
         this.m_buyBtn = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = null;
         super.dispose();
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_buyBtn = new ZGameButton(slot.buy_bt,this.onBuyButton);
         this.m_buyBtn.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":m_consumableItem.cash});
         super.onSlotCreated();
      }
      
      override protected function filloutStats() : void
      {
         super.filloutStats();
         slot.unitCard_mc.underlay_mc.visible = slot.unitCard_mc.itemName_tf.numLines > 1;
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.onBuyButton(param1);
      }
      
      public function showButton() : void
      {
         this.m_buyBtn.show();
         slot.cash.visible = true;
      }
      
      public function hideButton() : void
      {
         this.m_buyBtn.hide();
         slot.cash.visible = false;
      }
      
      private function onBuyButton(param1:MouseEvent) : void
      {
         buyUnitWithGateCheck();
      }
   }
}

