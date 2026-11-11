package displays.screens.pickConsumableScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StackedConsumableSlot extends ConsumableSlot
   {
      
      private var m_consumableInfo:StackedConsumableInfo = null;
      
      private var m_addBtn:ZGameButton = null;
      
      private var m_imageLoader:ImageLoader = null;
      
      public function StackedConsumableSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:StackedConsumableInfo, param7:int, param8:Number)
      {
         this.m_consumableInfo = param6;
         super(param1,param2,param3,param4,param5,this.m_consumableInfo.consumable,false,param7,param8);
         this.m_addBtn = new ZGameButton(slot.add_bt,this.onAddButton);
         this.m_addBtn.text = ZGameUtils.ZlocT("Dialogs","SelectButton");
      }
      
      override public function dispose() : void
      {
         this.m_addBtn.dispose();
         this.m_addBtn = null;
         this.m_imageLoader.destroy();
         this.m_imageLoader = null;
         super.dispose();
      }
      
      override protected function filloutStats() : void
      {
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(m_consumableItem.name,"icon"),slot.unitCard_mc.icon);
         this.m_imageLoader.smooth = true;
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_consumableInfo.consumable.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.underlay_mc.visible = slot.unitCard_mc.itemName_tf.numLines > 1;
         TextFieldUtil.processTextField(slot.unitCard_mc.unitNum_tf,this.m_consumableInfo.quantity.toString());
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
         this.onAddButton(param1);
      }
      
      private function onAddButton(param1:MouseEvent) : void
      {
         screen.dispatchEvent(new WorldEvent(CLICKED,m_consumableItem));
      }
   }
}

