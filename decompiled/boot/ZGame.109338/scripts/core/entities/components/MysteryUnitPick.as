package core.entities.components
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.SurveillanceScanPartsDialogState;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.UnitDropManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import displays.popups.SpeechPopup;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class MysteryUnitPick extends PortraitSlidePick
   {
      
      protected var pickClass:Class;
      
      protected var item_gdc:GameDataComponent;
      
      protected var m_clock:GenericCountdownClock;
      
      protected var isRare:Boolean;
      
      public function MysteryUnitPick(param1:IPVPPlayer, param2:Number, param3:Class = null, param4:GameDataComponent = null, param5:Boolean = false)
      {
         this.pickClass = param3;
         this.item_gdc = param4;
         this.isRare = param5;
         super(param1,param2);
      }
      
      override protected function getPickClass() : Class
      {
         return this.pickClass;
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         var _loc2_:ZGameButton = null;
         var _loc3_:UnitItem = null;
         var _loc4_:UnitClass = null;
         if(m_pick.bubble.clock_mc)
         {
            this.m_clock = new GenericCountdownClock(m_pick.bubble.clock_mc,UnitDropManager.instance.worldData.lastDropTime + 7 * 24 * 60 * 60 - ZGlobal.player.timeWarpSeconds / 1000,this.onUpdate);
         }
         if(!this.item_gdc)
         {
            if(m_pick.bubble.limitedEdition_mc)
            {
               m_pick.bubble.limitedEdition_mc.visible = false;
            }
            if(m_pick.bubble.question_mc)
            {
               m_pick.bubble.question_mc.visible = true;
            }
            if(m_pick.bubble.strength_mc)
            {
               m_pick.bubble.strength_mc.visible = false;
            }
            if(m_pick.bubble.class_icon)
            {
               m_pick.bubble.class_icon.visible = false;
            }
            if(m_pick.card_mc.help_bt)
            {
               m_pick.card_mc.help_bt.visible = false;
            }
            if(m_pick.card_mc.title_tf)
            {
               TextFieldUtil.processTextField(m_pick.card_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Reveal_unit_Title"));
            }
            if(m_pick.card_mc.title01_tf)
            {
               TextFieldUtil.processTextField(m_pick.card_mc.title01_tf,ZGameUtils.ZlocT("Dialogs","Expand_unit_Text"));
            }
            if(m_pick.card_mc.reveal_bt)
            {
               _loc2_ = new ZGameButton(m_pick.card_mc.reveal_bt,this.onReveal);
               _loc2_.text = ZGameUtils.ZlocT("Dialogs","Reveal_unit_button");
            }
            if(m_pick.card_mc.reveal_bt.empirePoints_mc)
            {
               m_pick.card_mc.reveal_bt.empirePoints_mc.visible = false;
            }
         }
         else if(this.item_gdc.gameData)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(this.item_gdc.gameData.code,UnitItem) as UnitItem;
            if(m_pick.bubble.limitedEdition_mc)
            {
               if(this.isRare)
               {
                  m_pick.bubble.limitedEdition_mc.visible = true;
               }
               else
               {
                  m_pick.bubble.limitedEdition_mc.visible = false;
               }
            }
            if(m_pick.card_mc.title_tf)
            {
               TextFieldUtil.processTextField(m_pick.card_mc.title_tf,_loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            }
            if(m_pick.card_mc.title01_tf)
            {
               TextFieldUtil.processTextField(m_pick.card_mc.title01_tf,ZGameUtils.ZlocT("Dialogs","Expand_unit_Text"));
            }
            if(m_pick.card_mc.reveal_bt)
            {
               _loc2_ = new ZGameButton(m_pick.card_mc.reveal_bt,this.onChange);
               if(UnitDropManager.instance.switchFreeEnabled)
               {
                  _loc2_.text = ZGameUtils.ZlocT("Dialogs","Expand_unit_button");
               }
               else
               {
                  _loc2_.text = ZGameUtils.ZlocT("Dialogs","Expand_unit_button_cash",{"amount":UnitDropManager.SWITCH_UNIT_COST});
               }
            }
            if(m_pick.card_mc.reveal_bt.empirePoints_mc)
            {
               m_pick.card_mc.reveal_bt.empirePoints_mc.visible = !UnitDropManager.instance.switchFreeEnabled;
            }
            if(m_pick.bubble.question_mc)
            {
               m_pick.bubble.question_mc.visible = false;
            }
            if(Boolean(m_pick.bubble.strength_mc) && Boolean(m_pick.bubble.strength_mc.strength_tf))
            {
               m_pick.bubble.strength_mc.strength_tf.visible = true;
               TextFieldUtil.processTextField(m_pick.bubble.strength_mc.strength_tf,String(_loc3_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc3_.code))));
            }
            _loc4_ = UnitClassManager.instance.unitClassNamed(_loc3_.unitClass);
            if(_loc4_)
            {
               ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_.getIconURL()),m_pick.bubble.class_icon);
            }
         }
      }
      
      private function onReveal(param1:MouseEvent) : void
      {
         if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB10") > 0)
         {
            UIDispatcher.instance.dispatchEvent(new Event(SurveillanceScanPartsDialogState.DISPLAY));
         }
         else
         {
            PopupManager.instance.push(new SpeechPopup("Speech_quest_QMU02_01",this.onSpeechPopupClosed),0,true,false);
         }
      }
      
      private function onSpeechPopupClosed(param1:Event) : void
      {
      }
      
      private function onChange(param1:MouseEvent) : void
      {
         UnitDropManager.instance.switchUnit(this.item_gdc.id);
      }
      
      private function onUpdate() : void
      {
         if(UnitDropManager.instance.worldData.lastDropTime + 7 * 24 * 60 * 60 - ZGlobal.player.timeWarpSeconds / 1000 - GlobalEngine.serverTime / 1000 < 2)
         {
            UnitDropManager.instance.dispatchEvent(new Event(UnitDropManager.REMOVE_ALL_UNITS));
         }
      }
   }
}

