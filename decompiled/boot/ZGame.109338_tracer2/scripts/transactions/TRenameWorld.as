package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.menuitem.UsersBarUIItem;
   import displays.popups.genericPopup.GenericPopup1B;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class TRenameWorld extends Transaction
   {
      
      public static const SEEN_NEW_NATION:String = "newNation";
      
      private var m_worldName:String;
      
      private var m_share:Boolean = false;
      
      public function TRenameWorld(param1:String, param2:Boolean)
      {
         this.m_worldName = param1;
         this.m_share = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setWorldName",this.m_worldName);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.hasOwnProperty("name"))
         {
            if(param1["result"] == INVALID_DATA)
            {
               PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","InvalidNewNationNameText"),ZGameUtils.ZlocT("Dialogs","InvalidNewNationNameTitle"),this.onInvalidNewNationDialogClosed));
            }
            else
            {
               ZGlobal.player.m_worldName = param1["name"];
               UsersBarUIItem.worldNameUpdated(param1["name"]);
               ZGlobal.player.setSeenFlag(SEEN_NEW_NATION);
               if(this.m_share)
               {
                  ViralsManager.instance.sendFeed("new_nation",{"empire":ZGlobal.player.m_worldName});
               }
            }
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
      
      private function onInvalidNewNationDialogClosed(param1:GenericPopupEvent) : void
      {
         ViralsManager.instance.questCompleteViral("new_nation");
      }
   }
}

