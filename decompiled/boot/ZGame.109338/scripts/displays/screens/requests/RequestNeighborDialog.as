package displays.screens.requests
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.viralsManager.ViralsManager;
   import flash.events.MouseEvent;
   import transactions.TRequestNeighbor;
   import utils.ZGameUtils;
   
   public class RequestNeighborDialog extends RequestDialog
   {
      
      public static const DIALOG_TITLE:String = "NeighborRequestTitle";
      
      public static const DIALOG_BODY:String = "NeighborRequestBody";
      
      public static const DIALOG_TOASTER:String = "NeighborRequestToaster";
      
      private static var m_instanceExists:Boolean = false;
      
      private var m_inviteType:int;
      
      private var m_onCloseCallback:Function;
      
      private var m_locTitle:String = ZGameUtils.ZlocT("Dialogs",DIALOG_TITLE);
      
      private var m_locBody:String = ZGameUtils.ZlocT("Dialogs",DIALOG_BODY);
      
      private var m_iconUrl:String = ZGlobal.getAssetURL("assets/game/request2/Request_Icons_0.swf/MFS_Neighbor_96.png");
      
      public function RequestNeighborDialog(param1:int, param2:String = "empire_request2_mfs_neighbor", param3:String = "", param4:Function = null)
      {
         this.m_inviteType = param1;
         this.m_onCloseCallback = param4;
         m_instanceExists = true;
         super(getFriends(param2),this.m_locTitle,this.m_locBody,DIALOG_TOASTER,this.m_iconUrl,RequestDialog.TYPE_NEIGHBOR,param3);
      }
      
      public static function instanceExists() : Boolean
      {
         return m_instanceExists;
      }
      
      override protected function sendRequest(param1:Array) : void
      {
         TransactionManager.addTransaction(new TRequestNeighbor(param1,this.m_inviteType,RequestDialog.TYPE_NEIGHBOR),true);
      }
      
      override protected function deinitDialog() : void
      {
         m_instanceExists = false;
         super.deinitDialog();
      }
      
      override protected function exitButtonClicked(param1:MouseEvent) : void
      {
         if(this.m_onCloseCallback != null)
         {
            this.m_onCloseCallback();
         }
         super.exitButtonClicked(param1);
      }
      
      override protected function calculateMaxFriends() : uint
      {
         if(m_requestSubtype == RequestDialog.SUBTYPE_INTERSTITIAL || this.m_inviteType == ViralsManager.INVITE_REQUEST_SOURCE_IDLE || this.m_inviteType == ViralsManager.INVITE_REQUEST_SOURCE_IDLE_TUTORIAL || this.m_inviteType == ViralsManager.INVITE_REQUEST_SOURCE_INTERSTITIAL)
         {
            return 50;
         }
         return super.calculateMaxFriends();
      }
   }
}

