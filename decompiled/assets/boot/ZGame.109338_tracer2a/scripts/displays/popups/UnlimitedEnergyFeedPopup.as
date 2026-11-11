package displays.popups
{
   import core.managers.viralsManager.ViralsManager;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class UnlimitedEnergyFeedPopup extends FeedPopup
   {
      
      private var m_index:int;
      
      public function UnlimitedEnergyFeedPopup(param1:String, param2:int)
      {
         this.m_index = param2;
         var _loc3_:String = ZGameUtils.ZlocT("Promo","promo_UnlimitedEnergy_ConfirmDialog_Title");
         var _loc4_:String = ZGameUtils.ZlocT("Promo","promo_UnlimitedEnergy_ConfirmDialog_Desc");
         var _loc5_:String = ZGameUtils.ZlocT("Promo","promo_UnlimitedEnergy_ConfirmDialog_Button");
         var _loc6_:Array = ["MOTDPopup_conf_unlimited_energy","","",""];
         super(_loc4_,_loc3_,_loc5_,GenericPopup.TYPE_SENDGIFTSCANCEL,this.onClosed,param1,FeedPopup.LARGE_IMAGE,_loc6_);
      }
      
      private function onClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendFeedWithLotsOfFriction("unlimited_energy_bought" + this.m_index,{});
         }
      }
   }
}

