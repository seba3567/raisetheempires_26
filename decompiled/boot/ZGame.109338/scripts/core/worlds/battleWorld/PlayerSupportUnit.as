package core.worlds.battleWorld
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import core.ui.menuitem.combatbar.SpecialAbilityFlippingButton;
   import displays.ImageLoaderFactory;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   
   public class PlayerSupportUnit extends PlayerUnit
   {
      
      private var m_abilityButton:secondaryAbilityButton_mc = null;
      
      private var m_flippingButton:SpecialAbilityFlippingButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function PlayerSupportUnit(param1:int, param2:BattleObject)
      {
         super(param1,param2);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_abilityButton = new secondaryAbilityButton_mc();
         this.m_abilityButton.useHandCursor = true;
         this.m_abilityButton.buttonMode = true;
         this.m_buttonSounds.addButton(this.m_abilityButton,ButtonSound.DEFAULT);
         this.playButton(null);
         var _loc3_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(param2.unitItem.secondaryAbility,ConsumableItem) as ConsumableItem;
         var _loc4_:String = _loc3_.getCachedImage("icon").url;
         this.loadActiveButton(this.m_abilityButton.zToActive_mc.activeLoader_mc.icon,_loc4_);
         this.loadActiveButton(this.m_abilityButton.cancelToActive_mc.zButton_mc.icon,_loc4_);
         var _loc5_:Array = [this.m_abilityButton.zToActive_mc.activeLoader_mc.activeButton_mc,this.m_abilityButton.cancelToActive_mc.zButton_mc.activeButton_mc];
         this.m_flippingButton = new SpecialAbilityFlippingButton(this,_loc5_,this.m_abilityButton.activeToCancel_mc.cancelButton_mc);
         this.m_flippingButton.consumableItem = _loc3_;
         this.m_flippingButton.code = param2.unitItem.code;
      }
      
      private function loadActiveButton(param1:UILoader, param2:String) : void
      {
         ImageLoaderFactory.CreateImageLoader(param2,param1);
         param1.mouseEnabled = false;
         param1.mouseChildren = false;
      }
      
      override public function init(param1:Sprite, param2:BattleObject, param3:int, param4:int) : void
      {
         super.init(param1,param2,param3,param4);
         classIconVisible = false;
         this.m_abilityButton.x -= BattleUnit.CLASS_ICON_X_OFFSET;
         this.m_abilityButton.y += BattleUnit.CLASS_ICON_Y_OFFSET;
         bar.addChild(this.m_abilityButton);
      }
      
      override public function dispose(param1:Sprite) : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_abilityButton.parent.removeChild(this.m_abilityButton);
         this.m_abilityButton = null;
         this.m_flippingButton.dispose();
         this.m_flippingButton = null;
         super.dispose(param1);
      }
      
      override public function set selected(param1:Boolean) : void
      {
         if(param1)
         {
            this.playButton("zToActive_mc");
            classIconVisible = false;
         }
         else if(m_selected)
         {
            this.playButton(null);
         }
         super.selected = param1;
      }
      
      public function get selected() : Boolean
      {
         return m_selected;
      }
      
      override public function set highlight(param1:Boolean) : void
      {
         super.highlight = param1;
         if(m_selected)
         {
            classIconVisible = false;
         }
      }
      
      public function playButton(param1:String) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Array = [this.m_abilityButton.cancelToActive_mc,this.m_abilityButton.activeToZ_mc,this.m_abilityButton.zToActive_mc,this.m_abilityButton.activeToCancel_mc,this.m_abilityButton.cancelToZ_mc];
         for each(_loc3_ in _loc2_)
         {
            _loc3_.stop();
            _loc3_.visible = false;
         }
         if(param1)
         {
            this.m_abilityButton[param1].visible = true;
            this.m_abilityButton[param1].gotoAndPlay(1);
         }
      }
   }
}

