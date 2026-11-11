package core.entities.components
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.EspionageHQManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.SpeechPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class UnitStealPick extends PortraitSlidePick
   {
      
      protected var m_pickClass:Class;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_button:ZGameButton;
      
      private var m_iEntity:IEntity;
      
      public function UnitStealPick(param1:Number, param2:Class, param3:IEntity)
      {
         this.m_pickClass = param2;
         this.m_iEntity = param3;
         super(null,param1);
      }
      
      override protected function getPickClass() : Class
      {
         return this.m_pickClass;
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:ZGameButton = null;
         var _loc2_:MovieClip = m_pick.card_mc;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         _loc3_ = _loc2_.clone_bt;
         _loc4_ = new ZGameButton(_loc3_,this.onAddMe);
         this.m_button = _loc4_;
         _loc4_.sounds = ButtonSound.DEFAULT;
         TextFieldUtil.compactTextField(_loc3_.generic_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Clone_Button"));
         this.m_buttonSounds.addButton(_loc3_,ButtonSound.DEFAULT);
         UIDispatcher.instance.addEventListener(EspionageHQManager.DISABLE_ESPIONAGE_UNIT_PIC,this.onSelected,false,0,true);
      }
      
      private function onAddMe(param1:MouseEvent) : void
      {
         super.hide();
         var _loc2_:GenericPopup2B = new GenericPopup2B(ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Unit_Confirmation"),null,GenericPopup.TYPE_YESNO,this.stealUnit);
         PopupManager.instance.push(_loc2_);
      }
      
      private function stealUnit(param1:GenericPopupEvent) : void
      {
         if(param1.button != GenericPopup.YES)
         {
            return;
         }
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByName(this.m_iEntity.alias,UnitItem) as UnitItem;
         EspionageHQManager.instance.stolenUnit = _loc2_.code;
         UIDispatcher.instance.dispatchEvent(new Event(EspionageHQManager.DISABLE_ESPIONAGE_UNIT_PIC));
         PopupManager.instance.push(new SpeechPopup("Speech_Espionage_HQ_03"),0,true,false);
      }
      
      private function onSelected(param1:Event) : void
      {
         this.m_button.disable_visual(false);
         UIDispatcher.instance.removeEventListener(EspionageHQManager.DISABLE_ESPIONAGE_UNIT_PIC,this.onSelected);
      }
      
      override protected function get yOffset() : int
      {
         return 0;
      }
   }
}

