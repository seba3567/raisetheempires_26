package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.PVPManager;
   import displays.popups.GenericPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.ModalPopup;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class TFightList extends Transaction
   {
      
      private var m_modal:ModalPopup = null;
      
      private var m_refreshing:Boolean;
      
      private var m_dominationMode:Boolean = false;
      
      public function TFightList(param1:Boolean, param2:Boolean = false)
      {
         super();
         this.m_refreshing = param1;
         this.m_dominationMode = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.getFightList");
      }
      
      override public function preAddTransaction() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(!this.m_dominationMode)
         {
            _loc1_ = this.m_refreshing ? "GlobalPVPFightListRefresh" : "GlobalPVPFightListGet";
            _loc2_ = ZGameUtils.ZlocT("Dialogs",_loc1_);
            this.m_modal = new ModalPopup(_loc2_);
            PopupManager.instance.push(this.m_modal,0,false,false);
         }
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:GenericPopup = null;
         if(!this.m_dominationMode)
         {
            this.m_modal.pop();
            this.m_modal = null;
         }
         super.onComplete(param1);
         if(param1.error)
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","GlobalPVPFightListError");
            _loc3_ = GenericPopup1B.NewOk(_loc2_,null);
            PopupManager.instance.push(_loc3_);
         }
         else
         {
            PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.FIGHT_LIST_RECEIVED,param1));
         }
      }
   }
}

