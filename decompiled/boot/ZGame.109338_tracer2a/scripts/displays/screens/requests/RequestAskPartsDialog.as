package displays.screens.requests
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import transactions.TAskParts;
   import utils.ZGameUtils;
   
   public class RequestAskPartsDialog extends RequestDialog
   {
      
      public static const DIALOG_TITLE:String = "AskPartsTitle_plural";
      
      public static const DIALOG_BODY:String = "AskPartsBody_plural";
      
      public static const DIALOG_TOASTER:String = "AskPartsToaster";
      
      private var m_part:String;
      
      private var m_unit:String;
      
      private var m_trackingParams:Array;
      
      private var m_partItem:GameItem;
      
      private var m_locTitle:String;
      
      private var m_locBody:String;
      
      private var m_toaster:String;
      
      public function RequestAskPartsDialog(param1:String, param2:String, param3:Array = null, param4:String = null, param5:String = null, param6:String = null)
      {
         this.m_part = param1;
         this.m_unit = param2;
         this.m_trackingParams = param3;
         this.m_partItem = ZGlobal.gameSettings.getItemByName(param1,GameItem) as GameItem;
         this.m_locTitle = param4 ? param4 : ZGameUtils.ZlocT("Dialogs",DIALOG_TITLE,{"item":ZGameUtils.ZlocTk("Items",this.m_part + "_sentenceName","plural")});
         this.m_locBody = param5 ? param5 : ZGameUtils.ZlocT("Dialogs",DIALOG_BODY,{"item":ZGameUtils.ZlocTk("Items",this.m_part + "_sentenceName","plural")});
         this.m_toaster = param6 ? param6 : DIALOG_TOASTER;
         super(getAllFriends(ExperimentsManager.EXPERIMENT_REQUEST2_MFS_GIFT_REQUEST),this.m_locTitle,this.m_locBody,this.m_toaster,this.m_partItem.getImageObject().url,RequestDialog.TYPE_GIFT_REQUEST);
      }
      
      override protected function sendRequest(param1:Array) : void
      {
         TransactionManager.addTransaction(new TAskParts(param1,this.m_part,this.m_unit,RequestDialog.TYPE_GIFT_REQUEST,this.m_trackingParams));
      }
   }
}

