package displays.screens.pickAlliesScreen
{
   import core.gameobjects.MercenaryItem;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class MercenarySlotV2 extends MercenarySlot
   {
      
      private var m_buyBtn:ZGameButton = null;
      
      public function MercenarySlotV2(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:MercenaryItem, param7:Number)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
      }
      
      override public function dispose() : void
      {
         this.m_buyBtn.dispose();
         super.dispose();
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_buyBtn = new ZGameButton(slot.buy_bt,this.onBuyButton);
         this.m_buyBtn.compactText(ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":MercenaryItem(getData()).cash}),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
      }
      
      override protected function addButtonSounds() : void
      {
         m_buttonSounds.addButton(slot,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(this.m_buyBtn.hit,ButtonSound.ROLLOVER_ONLY);
      }
      
      private function onBuyButton(param1:MouseEvent) : void
      {
         if(!isTutorialLocked())
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(PURCHASE,this));
         }
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.onBuyButton(param1);
      }
   }
}

