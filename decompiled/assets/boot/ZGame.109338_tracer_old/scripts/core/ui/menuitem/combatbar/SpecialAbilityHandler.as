package core.ui.menuitem.combatbar
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.ConsumableItem;
   import displays.popups.buyMana.BuyManaPopup;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class SpecialAbilityHandler
   {
      
      private var m_consumableItem:ConsumableItem = null;
      
      private var m_code:String = null;
      
      public function SpecialAbilityHandler()
      {
         super();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CLICKED,this.onAbilityButtonClicked);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CANCELED,this.onAbilityButtonCanceled);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_POWER_USED,this.onPowerUsed);
      }
      
      public function dispose() : void
      {
         this.m_consumableItem = null;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CLICKED,this.onAbilityButtonClicked);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CANCELED,this.onAbilityButtonCanceled);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_POWER_USED,this.onPowerUsed);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CANCEL_CONSUMABLE,this.onCancelButtonClicked);
      }
      
      public function set consumableItem(param1:ConsumableItem) : void
      {
         this.m_consumableItem = param1;
      }
      
      public function set code(param1:String) : void
      {
         this.m_code = param1;
      }
      
      protected function onAbilityClicked(param1:MouseEvent) : void
      {
         if(ZGlobal.player.mana.allow(this.m_consumableItem.mana))
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"interface",
               "kingdom":"SecondaryAbilityButton",
               "phylum":"on",
               "zclass":"class_button",
               "family":this.m_code,
               "genus":"support_units"
            }));
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CLICKED,this.m_consumableItem));
         }
         else
         {
            PopupManager.instance.push(new BuyManaPopup());
         }
      }
      
      protected function onAbilityButtonClicked(param1:WorldEvent) : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CANCEL_CONSUMABLE,this.onCancelButtonClicked);
      }
      
      protected function onAbilityButtonCanceled(param1:Event) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"interface",
            "kingdom":"SecondaryAbilityButton",
            "phylum":"off",
            "zclass":"class_button",
            "family":this.m_code,
            "genus":"support_units"
         }));
         this.onCancelButtonClicked(param1);
      }
      
      protected function onCancelButtonClicked(param1:Event) : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CANCEL_CONSUMABLE,this.onCancelButtonClicked);
      }
      
      protected function onAbilityCanceled(param1:MouseEvent) : void
      {
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_SPECIAL_ABILITY_CANCELED));
      }
      
      protected function onPowerUsed(param1:WorldEvent) : void
      {
         this.onCancelButtonClicked(null);
      }
   }
}

