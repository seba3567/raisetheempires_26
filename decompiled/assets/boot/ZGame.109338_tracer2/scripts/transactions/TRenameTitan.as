package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.viralsManager.ViralsManager;
   import displays.popups.genericPopup.GenericPopup1B;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class TRenameTitan extends Transaction
   {
      
      public static const SEEN_NEW_TITAN:String = "newTitan";
      
      public static const TITAN_NAME_SUCCESSFUL:String = "titanNameSuccessful";
      
      private var m_titanName:String;
      
      private var m_share:Boolean = false;
      
      public function TRenameTitan(param1:String, param2:Boolean)
      {
         this.m_titanName = param1;
         this.m_share = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setTitanName",this.m_titanName);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.hasOwnProperty("name"))
         {
            if(param1["result"] == INVALID_DATA)
            {
               PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","InvalidTitanNameText"),ZGameUtils.ZlocT("Dialogs","InvalidTitanNameTitle"),this.onInvalidTitanDialogClosed));
            }
            else
            {
               ZGlobal.player.m_titanName = param1["name"];
               ZGlobal.player.setSeenFlag(SEEN_NEW_TITAN);
               if(this.m_share)
               {
                  ViralsManager.instance.sendFeed("new_titan",{"TitanName":ZGlobal.player.m_titanName});
               }
            }
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
      
      private function onInvalidTitanDialogClosed(param1:GenericPopupEvent) : void
      {
         ViralsManager.instance.questCompleteViral("new_titan");
      }
   }
}

