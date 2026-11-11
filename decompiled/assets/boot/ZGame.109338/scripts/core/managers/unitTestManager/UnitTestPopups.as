package core.managers.unitTestManager
{
   import displays.popups.InviteIdlePopup;
   import displays.popups.genericPopup.ModalPopup;
   import flash.events.Event;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class UnitTestPopups
   {
      
      public function UnitTestPopups()
      {
         super();
      }
      
      public function startTest() : void
      {
         this.displayPopups();
      }
      
      private function displayPopups() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","SellFailBattleTitle");
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","SellFailBattleDesc");
         var _loc3_:ModalPopup = new ModalPopup("Testing...",null);
         PopupManager.instance.push(_loc3_,0,false,false);
         PopupManager.instance.push(new InviteIdlePopup(),5,true,false);
         _loc3_.pop();
         PopupManager.instance.push(new InviteIdlePopup(this.onClose),0,true,false);
      }
      
      public function onClose(param1:Event) : void
      {
         this.displayPopups();
      }
   }
}

