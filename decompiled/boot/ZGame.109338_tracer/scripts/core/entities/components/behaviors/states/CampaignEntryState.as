package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.ui.menuitem.OptionUIItem;
   import zlabs.Zlab;
   
   public class CampaignEntryState extends SimpleClickState
   {
      
      private var campaignName:String;
      
      public function CampaignEntryState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null);
         this.campaignName = _loc1_.xml.@campaign;
      }
      
      override protected function clicked() : void
      {
         Zlab.processManager.schedule(4000,this,this.toggleCampaign);
         super.clicked();
      }
      
      private function toggleCampaign() : void
      {
         ZGlobal.player.campaign.currentCampaignName = this.campaignName;
         OptionUIItem.instance.onToggleStrategicMap(null);
      }
   }
}

