package displays.screens.pickAlliesScreen
{
   import core.player.IAlly;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class PlayerSlotV2 extends PlayerSlot
   {
      
      protected var m_addBtn:ZGameButton = null;
      
      public function PlayerSlotV2(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:IAlly, param7:Boolean, param8:Number, param9:Boolean = false)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         if(slot.timer_mc != null)
         {
            TextFieldUtil.processTextField(slot.timer_mc.available_tf,ZGameUtils.ZlocT("Dialogs","AvailableIn"));
         }
         if(m_enabled)
         {
            this.enable();
         }
         else
         {
            this.disable();
         }
         if(param7)
         {
            this.select();
         }
         else
         {
            this.deselect();
         }
      }
      
      override protected function onSlotCreated() : void
      {
         if(slot.timer_mc != null)
         {
            m_timerClip = slot.timer_mc;
            m_timerText = slot.timer_mc.timer_tf;
            slot.timer_tf.visible = false;
         }
         this.m_addBtn = new ZGameButton(slot.playerCard_mc.add_bt,this.onAddButton);
         this.m_addBtn.text = ZGameUtils.ZlocT("Dialogs","SelectButton");
      }
      
      override protected function addButtonSounds() : void
      {
         m_buttonSounds.addButton(slot,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(this.m_addBtn.hit,ButtonSound.ROLLOVER_ONLY);
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(this.m_addBtn.enabled)
         {
            this.onAddButton(param1);
         }
      }
      
      override public function select() : void
      {
         super.select();
         if(this.m_addBtn)
         {
            this.m_addBtn.disable_visual();
            this.m_addBtn.hide();
         }
      }
      
      override public function deselect() : void
      {
         super.deselect();
         if(Boolean(this.m_addBtn) && m_enabled)
         {
            this.m_addBtn.enable();
            this.m_addBtn.show();
         }
      }
      
      override public function enable() : void
      {
         super.enable();
         if(this.m_addBtn)
         {
            this.m_addBtn.enable();
         }
      }
      
      override public function disable() : void
      {
         super.disable();
         if(this.m_addBtn)
         {
            this.m_addBtn.disable();
         }
      }
      
      override protected function updateTimeTextField(param1:Number) : void
      {
         TextFieldUtil.compactTextField(m_timerText,ZGameTimeUtil.instance.getTimeString(param1),{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
      }
      
      protected function onAddButton(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
      }
   }
}

