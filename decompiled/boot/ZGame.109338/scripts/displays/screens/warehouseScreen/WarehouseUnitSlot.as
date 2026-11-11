package displays.screens.warehouseScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.pickUnitsScreen.UnitSlot;
   import entity.WarehouseComponent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class WarehouseUnitSlot extends UnitSlot
   {
      
      private var m_warehouse:WarehouseComponent;
      
      private var m_selectButton:ZGameButton;
      
      public function WarehouseUnitSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Number, param8:WarehouseComponent, param9:int)
      {
         this.m_warehouse = param8;
         super(param1,param2,param3,param4,param5,param6,false,param9,param7);
         if(slot.unitCard_mc.bg2_mc)
         {
            slot.unitCard_mc.bg2_mc.visible = false;
         }
      }
      
      override protected function filloutStats() : void
      {
         var _loc1_:MovieClip = null;
         var _loc4_:String = null;
         _loc1_ = slot.unitCard_mc;
         m_iconLoaders = new Array();
         m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(m_unitItem.name,"icon"),_loc1_.icon_unit));
         var _loc2_:UnitClass = UnitClassManager.instance.unitClassNamed(m_unitItem.unitClass);
         _loc1_.strength_mc.visible = true;
         _loc1_.class_icon.visible = true;
         if(_loc2_)
         {
            m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_.getSmIconURL()),_loc1_.class_icon));
         }
         TextFieldUtil.compactTextField(_loc1_.strength_mc.value_tf,String(m_unitItem.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(m_unitItem.code))));
         TextFieldUtil.compactTextField(slot.unitCard_mc.itemName_tf,m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         _loc1_.island_units_mc.visible = false;
         _loc1_.inventory_units_mc.visible = false;
         _loc1_.count_mc_decco.visible = false;
         _loc1_.label_tf_0.visible = true;
         _loc1_.label_tf_1.visible = false;
         _loc1_.icon.visible = false;
         _loc1_.openDoor_mc.visible = false;
         _loc1_.openDoor_mc.mouseEnabled = false;
         _loc1_.closeDoor_mc.visible = false;
         _loc1_.closeDoor_mc.mouseEnabled = false;
         _loc1_.card_mc_decco.visible = false;
         _loc1_.premium_tf.visible = false;
         _loc1_.quantity_mc.visible = false;
         _loc1_.useInCombat_tf.visible = false;
         _loc1_.select_bt.visible = true;
         slot.unitCard_mc.label_tf_0.visible = false;
         var _loc3_:Boolean = WarehouseUnitManager.instance.isSlotInCombat(this.m_warehouse.owner,m_index,m_unitItem.code);
         if(_loc3_)
         {
            this.m_selectButton = this.initButton(_loc1_.select_bt,ZGameUtils.ZlocT("Dialogs","UnitInCombat"),this.onSelectButtonClick);
            this.m_selectButton.disable();
         }
         else
         {
            this.m_selectButton = this.initButton(_loc1_.select_bt,ZGameUtils.ZlocT("Dialogs","SelectButton"),this.onSelectButtonClick);
         }
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
      
      override public function getData() : Object
      {
         return m_unitItem;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(m_unitItem.tooltipType,m_unitItem,ItemTooltip.SOURCE_STORE);
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      private function onSelectButtonClick(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
      }
      
      override public function dispose() : void
      {
         this.m_selectButton.dispose();
         this.m_selectButton = null;
         super.dispose();
      }
      
      public function get warehouse() : WarehouseComponent
      {
         return this.m_warehouse;
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

