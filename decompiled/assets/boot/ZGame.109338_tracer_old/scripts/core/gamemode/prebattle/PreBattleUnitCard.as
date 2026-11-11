package core.gamemode.prebattle
{
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.formationManager.FormationManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import core.worlds.battleWorld.BattleSide;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class PreBattleUnitCard
   {
      
      public static const CARD_CANCEL:String = "cardCancel";
      
      private var m_dispatcher:EventDispatcher = null;
      
      protected var m_movieClip:MovieClip = null;
      
      private var m_cancelButton:ZGameButton = null;
      
      private var m_unitItem:UnitItem = null;
      
      private var m_battleUnit:PreBattleBattleUnit = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function PreBattleUnitCard(param1:EventDispatcher, param2:Class, param3:int, param4:int)
      {
         var _loc5_:Point = null;
         super();
         this.m_dispatcher = param1;
         _loc5_ = this.getFormationPosition(param3,param4);
         this.m_movieClip = new param2();
         this.m_movieClip.x = _loc5_.x;
         this.m_movieClip.y = _loc5_.y;
         this.m_movieClip.strength_mc.visible = false;
         this.addCancelButton();
         TextFieldUtil.processTextField(this.m_movieClip.grid_mc.SelectUnitInd.generic_tf,ZGameUtils.ZlocT("Dialogs","AddUnitBelow"));
         this.setVacant();
      }
      
      protected function getFormationPosition(param1:int, param2:int) : Point
      {
         return FormationManager.instance.getLocalOffset(BattleSide.PLAYER.toString() + "_" + param1.toString(),param2,1);
      }
      
      protected function addCancelButton() : void
      {
         this.m_movieClip.card_mc.remove_bt.visible = true;
         this.m_movieClip.grid_mc.SelectUnitInd.generic_tf.visible = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_cancelButton = new ZGameButton(this.m_movieClip.card_mc.remove_bt,this.onCancel);
         this.m_cancelButton.text = ZGameUtils.ZlocT("Dialogs","Remove");
         this.m_buttonSounds.addButton(this.m_cancelButton.m_overlay,ButtonSound.DEFAULT);
      }
      
      public function dispose() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_dispatcher = null;
         if(this.m_cancelButton)
         {
            this.m_cancelButton.dispose();
            this.m_cancelButton = null;
         }
         this.clearBattleUnit();
         Tooltip.unsubscribe(this.art);
         this.m_movieClip = null;
      }
      
      public function get art() : MovieClip
      {
         return this.m_movieClip;
      }
      
      public function get code() : String
      {
         return this.m_unitItem != null ? this.m_unitItem.code : null;
      }
      
      public function get unitItem() : UnitItem
      {
         return this.m_unitItem;
      }
      
      public function setVacant() : void
      {
         this.clearBattleUnit();
         this.m_unitItem = null;
         this.m_movieClip.grid_mc.gotoAndPlay("_blur");
         this.m_movieClip.card_mc.visible = false;
         this.hideStrength();
         this.configTooltip();
      }
      
      public function setActive() : void
      {
         this.clearBattleUnit();
         this.m_unitItem = null;
         this.m_movieClip.grid_mc.gotoAndPlay("_focus");
         this.m_movieClip.card_mc.visible = false;
         this.hideStrength();
         this.configTooltip();
      }
      
      private function showStrength(param1:int) : void
      {
         this.m_movieClip.strength_mc.visible = true;
         TextFieldUtil.processSingleLineTextField(this.m_movieClip.strength_mc.strengthValue_tf,String(param1));
      }
      
      private function hideStrength() : void
      {
         this.m_movieClip.strength_mc.visible = false;
      }
      
      public function setOccupied(param1:UnitItem) : void
      {
         var _loc2_:int = 0;
         this.clearBattleUnit();
         this.m_battleUnit = new PreBattleBattleUnit(this.m_movieClip.card_mc.anchor_mc,param1);
         this.m_unitItem = param1;
         this.m_movieClip.grid_mc.gotoAndPlay("_blur");
         this.m_movieClip.card_mc.visible = true;
         if(DominationModeManager.instance.isInDefenseForceEditMode() || DominationModeManager.instance.isInDominationBattle())
         {
            _loc2_ = this.m_unitItem.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_unitItem.code));
            this.showStrength(_loc2_);
         }
         else
         {
            this.hideStrength();
         }
         this.configTooltip();
         if(TutorialManager.instance.active && TutorialManager.instance.unitCardRemoveDisabled)
         {
            this.m_cancelButton.hide();
            Tooltip.unsubscribe(this.art);
         }
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.m_movieClip.visible = param1;
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         this.m_dispatcher.dispatchEvent(new WorldEvent(CARD_CANCEL,this));
      }
      
      private function clearBattleUnit() : void
      {
         if(this.m_battleUnit)
         {
            this.m_battleUnit.dispose(this.m_movieClip.card_mc.anchor_mc);
            this.m_battleUnit = null;
         }
      }
      
      private function configTooltip() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs",this.m_unitItem == null ? "AddUnitTooltip" : "RemoveUnitTooltip");
         Tooltip.unsubscribe(this.art);
         Tooltip.subscribe(this.art,_loc1_);
      }
   }
}

