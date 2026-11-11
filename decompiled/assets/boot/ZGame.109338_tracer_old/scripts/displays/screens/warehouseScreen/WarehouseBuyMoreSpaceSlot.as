package displays.screens.warehouseScreen
{
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class WarehouseBuyMoreSpaceSlot extends GridSlot
   {
      
      private var m_selectButton:ZGameButton;
      
      public function WarehouseBuyMoreSpaceSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:Number)
      {
         var _loc7_:MovieClip = null;
         super(param1,param2,param3,param4,param5);
         slot.x = param4 * (sizerWidth * param6);
         slot.y = param5 * (sizerHeight * param6);
         _loc7_ = slot.unitCard_mc;
         _loc7_.strength_mc.visible = false;
         _loc7_.island_units_mc.visible = false;
         _loc7_.inventory_units_mc.visible = false;
         _loc7_.count_mc_decco.visible = false;
         _loc7_.label_tf_0.visible = false;
         _loc7_.label_tf_1.visible = false;
         _loc7_.icon_unit.visible = false;
         _loc7_.openDoor_mc.visible = false;
         _loc7_.openDoor_mc.mouseEnabled = false;
         _loc7_.closeDoor_mc.visible = true;
         _loc7_.closeDoor_mc.mouseEnabled = false;
         _loc7_.card_mc_decco.visible = false;
         _loc7_.premium_tf.visible = false;
         _loc7_.itemName_tf.visible = false;
         _loc7_.quantity_mc.visible = false;
         _loc7_.useInCombat_tf.visible = false;
         _loc7_.select_bt.visible = false;
         _loc7_.closeDoor_mc.locked_tf.visible = false;
         _loc7_.select_bt.visible = false;
      }
      
      private function initButton(param1:MovieClip, param2:String = "", param3:Function = null) : ZGameButton
      {
         var _loc4_:ZGameButton = new ZGameButton(param1,param3);
         _loc4_.compactText(param2,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         _loc4_.show();
         _loc4_.enable();
         return _loc4_;
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      private function onSelectButtonClick(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override public function enable() : void
      {
         m_enabled = true;
         m_buttonSounds = new ButtonMouseEventSoundContainer();
         addButtonSounds();
         slot.buttonMode = false;
         slot.useHandCursor = false;
         slot.addEventListener(MouseEvent.ROLL_OVER,onRollOver,false,0,true);
         slot.addEventListener(MouseEvent.ROLL_OUT,onRollOut,false,0,true);
      }
      
      override public function disable() : void
      {
         m_enabled = false;
         if(m_buttonSounds)
         {
            m_buttonSounds.release();
            m_buttonSounds = null;
         }
         slot.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
         slot.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
      }
   }
}

