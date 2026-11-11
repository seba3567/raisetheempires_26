package core.ui.menuitem.combatbar
{
   import core.worlds.battleWorld.PlayerSupportUnit;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.events.WorldEvent;
   
   public class SpecialAbilityFlippingButton extends SpecialAbilityHandler
   {
      
      private var m_parent:PlayerSupportUnit = null;
      
      private var m_useButtons:Array = null;
      
      private var m_cancelButton:MovieClip = null;
      
      public function SpecialAbilityFlippingButton(param1:PlayerSupportUnit, param2:Array, param3:MovieClip)
      {
         var _loc4_:MovieClip = null;
         super();
         this.m_parent = param1;
         this.m_useButtons = param2;
         this.m_cancelButton = param3;
         for each(_loc4_ in this.m_useButtons)
         {
            _loc4_.addEventListener(MouseEvent.CLICK,onAbilityClicked);
         }
         this.m_cancelButton.addEventListener(MouseEvent.CLICK,onAbilityCanceled);
      }
      
      override public function dispose() : void
      {
         var _loc1_:MovieClip = null;
         super.dispose();
         for each(_loc1_ in this.m_useButtons)
         {
            _loc1_.removeEventListener(MouseEvent.CLICK,onAbilityClicked);
         }
         this.m_cancelButton.removeEventListener(MouseEvent.CLICK,onAbilityCanceled);
         this.m_useButtons = null;
         this.m_parent = null;
      }
      
      override protected function onAbilityButtonClicked(param1:WorldEvent) : void
      {
         if(this.m_parent.selected)
         {
            super.onAbilityButtonClicked(param1);
            this.m_parent.playButton("activeToCancel_mc");
         }
      }
      
      override protected function onCancelButtonClicked(param1:Event) : void
      {
         if(this.m_parent.selected)
         {
            super.onCancelButtonClicked(param1);
            this.m_parent.playButton("cancelToActive_mc");
         }
      }
      
      override protected function onPowerUsed(param1:WorldEvent) : void
      {
         if(this.m_parent.selected)
         {
            super.onPowerUsed(param1);
            this.m_parent.playButton("cancelToActive_mc");
         }
      }
   }
}

