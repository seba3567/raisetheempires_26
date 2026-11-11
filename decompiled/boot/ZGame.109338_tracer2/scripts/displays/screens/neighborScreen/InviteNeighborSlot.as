package displays.screens.neighborScreen
{
   import core.ZGameStats;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.InviteSlot;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class InviteNeighborSlot extends GridSlot
   {
      
      private var m_button:ZGameButton = null;
      
      public function InviteNeighborSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int)
      {
         super(param1,param2,param3);
         slot.x = param4;
         slot.y = 0;
      }
      
      override public function dispose() : void
      {
         this.m_button.dispose();
         super.dispose();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         return new InviteSlot();
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_button = new ZGameButton(slot.add_bt,this.onButtonClicked);
         this.m_button.compactText(ZGameUtils.ZlocT("Main",this.buttonLabel),{
            "maxLines":2,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_button.disable_visual(true);
         this.m_button.hide();
      }
      
      protected function get buttonLabel() : String
      {
         return "NeighborInvite";
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.onButtonClicked(param1);
      }
      
      protected function onButtonClicked(param1:MouseEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new Event(ZGameStats.STATS_FRIEND_INVITE));
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_NEIGHBOR_SLOT));
         }
         else
         {
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_NEIGHBOR_SLOT);
         }
      }
   }
}

