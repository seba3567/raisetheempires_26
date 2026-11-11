package core.ui.menuitem.combatbar
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class SpecialAbilityUnitCard extends SpecialAbilityHandler
   {
      
      private var m_useButton:ZGameButton = null;
      
      private var m_cancelButton:ZGameButton = null;
      
      private var m_clip:MovieClip = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      public function SpecialAbilityUnitCard(param1:MovieClip)
      {
         this.m_clip = param1;
         this.m_useButton = new ZGameButton(this.m_clip.use_bt,onAbilityClicked);
         this.m_cancelButton = new ZGameButton(this.m_clip.cancel_bt,onAbilityCanceled);
         this.m_cancelButton.text = ZGameUtils.ZlocT("Combat","Combat_AbilityButtonCancel");
         this.m_cancelButton.disable();
         this.m_clip.use_bt.visible = true;
         this.m_clip.cancel_bt.visible = false;
         this.m_buttonSounds.addButton(this.m_useButton.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_cancelButton.m_overlay,ButtonSound.DEFAULT);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurn);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onPlayerRegularAttack);
         super();
      }
      
      override public function dispose() : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurn);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_CLICKED,this.onPlayerRegularAttack);
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_useButton.dispose();
         this.m_useButton = null;
         this.m_cancelButton.dispose();
         this.m_cancelButton = null;
         this.m_clip.visible = false;
         this.m_clip = null;
         super.dispose();
      }
      
      override public function set consumableItem(param1:ConsumableItem) : void
      {
         super.consumableItem = param1;
         var _loc2_:int = param1.mana;
         this.m_useButton.text = ZGameUtils.ZlocT("Combat","Combat_AbilityButtonUse",{"amount":_loc2_});
         TextFieldUtil.processTextField(this.m_clip.mana_tf,_loc2_.toString());
         TextFieldUtil.processTextField(this.m_clip.secondaryAbility_tf,param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         ImageLoaderFactory.CreateImageLoader(param1.getCachedImage("icon").url,this.m_clip.icon);
      }
      
      override protected function onAbilityButtonClicked(param1:WorldEvent) : void
      {
         super.onAbilityButtonClicked(param1);
         this.m_useButton.disable();
         this.m_cancelButton.enable();
         this.m_clip.use_bt.visible = false;
         this.m_clip.cancel_bt.visible = true;
      }
      
      override protected function onCancelButtonClicked(param1:Event) : void
      {
         super.onCancelButtonClicked(param1);
         this.m_useButton.enable();
         this.m_cancelButton.disable();
         this.m_clip.use_bt.visible = true;
         this.m_clip.cancel_bt.visible = false;
      }
      
      override protected function onPowerUsed(param1:WorldEvent) : void
      {
         super.onPowerUsed(param1);
         this.m_useButton.disable();
      }
      
      private function onPlayerTurn(param1:Event) : void
      {
         this.m_useButton.enable();
      }
      
      private function onPlayerRegularAttack(param1:Event) : void
      {
         if(this.m_useButton)
         {
            this.m_useButton.disable();
         }
      }
   }
}

