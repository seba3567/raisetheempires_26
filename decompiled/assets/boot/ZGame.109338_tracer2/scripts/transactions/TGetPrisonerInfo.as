package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.prisoncamp.PrisonCampManager;
   import displays.screens.PrisonCampActivationDialog;
   
   public class TGetPrisonerInfo extends Transaction
   {
      
      private var dialog:PrisonCampActivationDialog = null;
      
      public function TGetPrisonerInfo(param1:PrisonCampActivationDialog)
      {
         this.dialog = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getPrisonerInfo");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         PrisonCampManager.instance.setInfo(param1);
         if(this.dialog)
         {
            this.dialog.show(param1);
         }
      }
   }
}

