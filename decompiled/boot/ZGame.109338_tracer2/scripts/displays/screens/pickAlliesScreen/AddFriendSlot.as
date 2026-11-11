package displays.screens.pickAlliesScreen
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class AddFriendSlot extends GridSlot
   {
      
      public static const CLICKED:String = "clicked";
      
      public function AddFriendSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:Number)
      {
         super(param1,param2,param3);
         slot.x = param4 * (slot.width * param6);
         slot.y = param5 * (slot.height * param6);
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "AddFriendCard";
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_NEIGHBOR_SLOT));
         }
         else
         {
            ZGlobal.switchToTab("invite");
         }
      }
      
      private function filloutStats() : void
      {
         slot.addFriendCard_mc.addFriend_tf.text = ZGameUtils.ZlocT("Dialogs","AddFriendButton");
      }
      
      override public function isSpecialSlot() : Boolean
      {
         return true;
      }
   }
}

