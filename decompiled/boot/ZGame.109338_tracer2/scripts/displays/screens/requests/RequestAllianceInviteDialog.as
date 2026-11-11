package displays.screens.requests
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import transactions.TRequestAllianceInvite;
   import utils.ZGameUtils;
   
   public class RequestAllianceInviteDialog extends RequestDialog
   {
      
      public static const DIALOG_TITLE:String = "AllianceRequestTitle";
      
      public static const DIALOG_BODY:String = "AllianceRequestBody";
      
      public static const DIALOG_TOASTER:String = "AllianceRequestToaster";
      
      public function RequestAllianceInviteDialog()
      {
         var _loc1_:Array = this.filterFriends(getAllFriends(ExperimentsManager.EXPERIMENT_REQUEST2_MFS_CREW));
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs",DIALOG_TITLE);
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs",DIALOG_BODY);
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs",DIALOG_TOASTER);
         var _loc5_:String = ZGlobal.getAssetURL("assets/game/request2/Request_Icons_0.swf/MFS_Neighbor_96.png");
         super(_loc1_,_loc2_,_loc3_,_loc4_,_loc5_,RequestDialog.TYPE_ALLIANCE);
      }
      
      private function filterFriends(param1:Array) : Array
      {
         var _loc4_:Object = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = AlliancesManager.instance.members;
         for each(_loc4_ in param1)
         {
            if(!(Boolean(_loc3_) && Boolean(_loc3_.length > 0) && _loc3_.indexOf(_loc4_.zid) > -1))
            {
               _loc2_.push(_loc4_);
            }
         }
         return _loc2_;
      }
      
      override protected function sendRequest(param1:Array) : void
      {
         var _loc2_:Object = {
            "player":ZGlobal.player.name,
            "allianceName":AlliancesManager.instance.clanName
         };
         TransactionManager.addTransaction(new TRequestAllianceInvite(param1,RequestDialog.TYPE_ALLIANCE,_loc2_));
      }
   }
}

