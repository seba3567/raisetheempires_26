package displays.screens.pickUnitsScreen
{
   import core.gameobjects.UnitItem;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class UnitSlotV2 extends UnitSlot
   {
      
      protected var m_addBtn:ZGameButton = null;
      
      protected var m_removeBtn:ZGameButton = null;
      
      public function UnitSlotV2(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Boolean, param8:int, param9:Number)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         if(param7)
         {
            this.select();
         }
         else
         {
            this.deselect();
         }
      }
      
      override public function dispose() : void
      {
         this.m_addBtn.dispose();
         this.m_removeBtn.dispose();
         super.dispose();
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_addBtn = this.initButton(slot.add_bt,this.onAddButton,ZGameUtils.ZlocT("Dialogs","Add"));
         this.m_removeBtn = this.initButton(slot.remove_bt,this.onRemoveButton,ZGameUtils.ZlocT("Dialogs","Remove"));
      }
      
      override protected function addButtonSounds() : void
      {
         m_buttonSounds.addButton(slot,ButtonSound.ROLLOVER_ONLY);
         m_buttonSounds.addButton(this.m_addBtn.hit,ButtonSound.CLICK_ONLY);
         m_buttonSounds.addButton(this.m_removeBtn.hit,ButtonSound.CLICK_ONLY);
      }
      
      override public function select() : void
      {
         m_selected = true;
         if(this.m_removeBtn)
         {
            this.m_removeBtn.show();
         }
         if(this.m_addBtn)
         {
            this.m_addBtn.hide();
         }
      }
      
      override public function deselect() : void
      {
         m_selected = false;
         if(this.m_addBtn)
         {
            this.m_addBtn.show();
         }
         if(this.m_removeBtn)
         {
            this.m_removeBtn.hide();
         }
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.onAddButton(param1);
      }
      
      private function onAddButton(param1:MouseEvent) : void
      {
         if(!isTutorialLocked())
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
         }
      }
      
      private function onRemoveButton(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(DESELECTED,this));
      }
      
      private function initButton(param1:MovieClip, param2:Function, param3:String) : ZGameButton
      {
         var _loc4_:ZGameButton = new ZGameButton(param1,param2);
         _loc4_.text = param3;
         _loc4_.enable();
         return _loc4_;
      }
   }
}

