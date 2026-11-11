package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class HealingSurfacingPopup extends GallantPopup
   {
      
      private var m_healItem:ConsumableItem;
      
      private var m_confirmCallback:Function;
      
      private var m_confirmButton:ZGameButton;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      public function HealingSurfacingPopup(param1:ConsumableItem, param2:Function)
      {
         this.m_healItem = param1;
         this.m_confirmCallback = param2;
         super(ZGlobal.getAssetURL("assets/displays/screens/PU_HealingSurfacingPopup.swf"));
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("HealingSurfacing_mc");
         return new _loc2_();
      }
      
      override protected function initDialog() : void
      {
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         var _loc1_:Object = ZGameUtils.CashTokenReplacements(this.m_healItem.cash);
         this.m_confirmButton = new ZGameButton(m_window.buy_mc,this.onConfirmClicked);
         this.m_confirmButton.text = ZGameUtils.ZlocT("Combat","HealerSurfacingDialogButton",_loc1_);
         this.m_buttonSounds.addButton(this.m_confirmButton.m_overlay,ButtonSound.DEFAULT);
         var _loc2_:Number = -this.m_healItem.di;
         var _loc3_:String = ZGameUtils.ZlocT("Combat","HealerSurfacingDialogMsg",{"healAmount":_loc2_});
         TextFieldUtil.processTextField(m_window.talkBubble_tf,_loc3_);
         super.initDialog();
      }
      
      private function onConfirmClicked(param1:MouseEvent) : void
      {
         var _loc2_:Function = this.m_confirmCallback;
         close(param1);
         _loc2_.apply();
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_confirmButton)
         {
            this.m_confirmButton.dispose();
         }
         this.m_buttonSounds.release();
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         super.deinitDialog();
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         close(param1);
      }
   }
}

