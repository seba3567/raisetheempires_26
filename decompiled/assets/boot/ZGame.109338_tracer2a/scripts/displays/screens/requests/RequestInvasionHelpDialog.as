package displays.screens.requests
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import transactions.TRequestInvasionHelp;
   import utils.ZGameUtils;
   
   public class RequestInvasionHelpDialog extends RequestDialog
   {
      
      public static const DIALOG_TITLE:String = "InvasionHelpRequestTitle";
      
      public static const DIALOG_BODY:String = "InvasionHelpRequestBody";
      
      public static const DIALOG_TOASTER:String = "InvasionHelpRequestToaster";
      
      private var m_invasionId:String;
      
      private var m_locTitle:String = ZGameUtils.ZlocT("Dialogs",DIALOG_TITLE);
      
      private var m_locBody:String = ZGameUtils.ZlocT("Dialogs",DIALOG_BODY);
      
      private var m_iconUrl:String = ZGlobal.getAssetURL("assets/game/request2/Request_Icons_0.swf/MFS_NeighborRepel_96.png");
      
      public function RequestInvasionHelpDialog(param1:String)
      {
         this.m_invasionId = param1;
         super(getAllFriends(ExperimentsManager.EXPERIMENT_REQUEST2_MFS_CREW),this.m_locTitle,this.m_locBody,DIALOG_TOASTER,this.m_iconUrl,RequestDialog.TYPE_INVASION_HELP);
      }
      
      override protected function sendRequest(param1:Array) : void
      {
         TransactionManager.addTransaction(new TRequestInvasionHelp(param1,this.m_invasionId,RequestDialog.TYPE_INVASION_HELP));
      }
   }
}

