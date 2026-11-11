package core.ui.menuitem
{
   import core.ZGlobal;
   import core.ui.GenericButton;
   import displays.popups.obtainRequirement.ObtainRequirementPopup;
   import displays.popups.obtainRequirement.ObtainRequirementPopupInfoLevelTargetedResources;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import zlabs.managers.PopupManager;
   
   public class PlayerStatsPurchaseResourceButton
   {
      
      private var m_resource:String = null;
      
      private var m_button:GenericButton = null;
      
      public function PlayerStatsPurchaseResourceButton(param1:MovieClip, param2:String)
      {
         super();
         this.m_button = new GenericButton(param1,this.onClick);
         this.m_resource = param2;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this.m_resource == "rare")
         {
            this.m_resource = ZGlobal.player.rareResourceName;
         }
         PopupManager.instance.push(new ObtainRequirementPopup(new ObtainRequirementPopupInfoLevelTargetedResources([this.m_resource])));
      }
   }
}

