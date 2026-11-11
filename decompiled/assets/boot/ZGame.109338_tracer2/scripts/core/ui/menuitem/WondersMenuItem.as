package core.ui.menuitem
{
   import displays.screens.WonderHeraquaters;
   import flash.events.MouseEvent;
   import zlabs.managers.PopupManager;
   
   public class WondersMenuItem extends PromoMenuItem
   {
      
      public function WondersMenuItem()
      {
         swfPath = "assets/game/quests/Quests_Icons_0.swf/WonderBuilding_01_64.png";
         super("WondersMenuItem",true,false);
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:WonderHeraquaters = new WonderHeraquaters();
         PopupManager.instance.push(_loc2_);
      }
   }
}

